-- ====================================================================
-- AR SCRIPT HUB - v7.1 CORE ENGINE (FIXED JSON DICTIONARY VOID BUG)
-- MODIFIED: DYNAMIC TOGGLE KEYBIND & ADVANCED FREECAM MODE
-- ====================================================================
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local SafeGuiTarget = Player:FindFirstChildOfClass("PlayerGui") or Player:WaitForChild("PlayerGui", 5)
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Stats = game:GetService("Stats")
local TeleportService = game:GetService("TeleportService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local MarketplaceService = game:GetService("MarketplaceService")
local Workspace = game:GetService("Workspace")

-- CONFIGURATION & STATE MANAGEMENT
local Config = {
    FlyMode = false,
    FlySpeed = 50,
    Noclip = false,
    SuperSpeed = false,
    SpeedValue = 16,
    SuperJump = false,
    JumpValue = 50,
    InfiniteJump = false,
    AntiRagdoll = false,
    InfiniteOxygen = false,
    ShowBoxes = false,
    ShowNames = false,
    ShowGlow = false,
    TeamCheck = false,
    FullBright = false,
    Freecam = false,
    FreecamSpeed = 1,
    FreecamFollowCharacter = false, -- Fitur Baru: Karakter ikut kamera atau tidak
    TweenTeleport = false,
    TweenSpeed = 50,
    ToggleKey = Enum.KeyCode.RightShift -- Fitur Baru: Default Toggle Keybind
}

-- ANTI-BUG CLEAN-UP ENGINE
pcall(function()
    if Player.Character then
        for _, obj in pairs(Player.Character:GetDescendants()) do
            if obj:IsA("BodyGyro") or obj:IsA("BodyVelocity") then
                obj:Destroy()
            end
        end
        local hum = Player.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            hum:SetStateEnabled(Enum.HumanoidStateType.Flying, false)
            hum:ChangeState(Enum.HumanoidStateType.Running)
        end
    end
end)

if SafeGuiTarget and SafeGuiTarget:FindFirstChild("AR_Script_Hub") then
    SafeGuiTarget.AR_Script_Hub:Destroy()
end

-- THEME COLOR PALETTE (DARK METALLIC PURPLE)
local Theme = {
    Bg = Color3.fromRGB(15, 15, 20),
    Sidebar = Color3.fromRGB(22, 22, 30),
    CardBg = Color3.fromRGB(28, 28, 38),
    Accent = Color3.fromRGB(140, 80, 255),
    AccentGlow = Color3.fromRGB(170, 120, 255),
    TextMain = Color3.fromRGB(255, 255, 255),
    TextMuted = Color3.fromRGB(150, 150, 160),
    Stroke = Color3.fromRGB(40, 40, 55),
    Good = Color3.fromRGB(50, 220, 120),
    Bad = Color3.fromRGB(255, 80, 80)
}

-- MAIN UI BUILDING
local ScreenGui = Instance.new("ScreenGui", SafeGuiTarget)
ScreenGui.Name = "AR_Script_Hub"
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 0, 0, 0) -- Starts minimized for key system or animation
MainFrame.Position = UDim2.new(0.5, -260, 0.5, -150)
MainFrame.BackgroundColor3 = Theme.Bg
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Visible = false

local MainCorner = Instance.new("UICorner", MainFrame)
MainCorner.CornerRadius = UDim.new(0, 10)

local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Color = Theme.Stroke
MainStroke.Thickness = 1

-- SIDEBAR LOGO & TABS CONTAINER
local Sidebar = Instance.new("Frame", MainFrame)
Sidebar.Size = UDim2.new(0, 140, 1, 0)
Sidebar.BackgroundColor3 = Theme.Sidebar
Sidebar.BorderSizePixel = 0

local SidebarRightLine = Instance.new("Frame", Sidebar)
SidebarRightLine.Size = UDim2.new(0, 1, 1, 0)
SidebarRightLine.Position = UDim2.new(1, -1, 0, 0)
SidebarRightLine.BackgroundColor3 = Theme.Stroke
SidebarRightLine.BorderSizePixel = 0

local LogoLabel = Instance.new("TextLabel", Sidebar)
LogoLabel.Size = UDim2.new(1, 0, 0, 45)
LogoLabel.BackgroundTransparency = 1
LogoLabel.Font = Enum.Font.GothamBold
LogoLabel.Text = "AR HUB v7.1"
LogoLabel.TextColor3 = Theme.Accent
LogoLabel.TextSize = 16

local TabContainer = Instance.new("ScrollingFrame", Sidebar)
TabContainer.Size = UDim2.new(1, 0, 1, -55)
TabContainer.Position = UDim2.new(0, 0, 0, 50)
TabContainer.BackgroundTransparency = 1
TabContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
TabContainer.ScrollBarThickness = 0

local TabListLayout = Instance.new("UIListLayout", TabContainer)
TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabListLayout.Padding = UDim.new(0, 4)

local TabPadding = Instance.new("UIPadding", TabContainer)
TabPadding.PaddingLeft = UDim.new(0, 8)
TabPadding.PaddingRight = UDim.new(0, 8)

-- CONTENT PAGES WRAPPER
local ContentContainer = Instance.new("Frame", MainFrame)
ContentContainer.Size = UDim2.new(1, -150, 1, -15)
ContentContainer.Position = UDim2.new(0, 145, 0, 10)
ContentContainer.BackgroundTransparency = 1

-- TOGGLE FLOATING BUTTON (WHEN MENU HIDDEN)
local ToggleButton = Instance.new("TextButton", ScreenGui)
ToggleButton.Size = UDim2.new(0, 50, 0, 50)
ToggleButton.Position = UDim2.new(0, 10, 0.5, -25)
ToggleButton.BackgroundColor3 = Theme.Sidebar
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.Text = "AR"
ToggleButton.TextColor3 = Theme.Accent
ToggleButton.TextSize = 14
ToggleButton.Visible = false
Instance.new("UICorner", ToggleButton).CornerRadius = UDim.new(0, 25)
local ToggleStroke = Instance.new("UIStroke", ToggleButton)
ToggleStroke.Color = Theme.Accent
ToggleStroke.Thickness = 1.5

-- DRAGGING ENGINE CORES
local dragging, dragInput, dragStart, startPos
local function updateDrag(input)
    local delta = input.Position - dragStart
    MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)

MainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then updateDrag(input) end
end)

-- MASTER PAGE & TAB MANAGER SYSTEM
local Pages = {}
local Tabs = {}
local ActivePage = nil

local function CreatePage(name, order)
    local PageScroll = Instance.new("ScrollingFrame", ContentContainer)
    PageScroll.Size = UDim2.new(1, 0, 1, 0)
    PageScroll.BackgroundTransparency = 1
    PageScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    PageScroll.ScrollBarThickness = 3
    PageScroll.ScrollBarImageColor3 = Theme.Accent
    PageScroll.Visible = false
    
    local PageLayout = Instance.new("UIListLayout", PageScroll)
    PageLayout.SortOrder = Enum.SortOrder.LayoutOrder
    PageLayout.Padding = UDim.new(0, 8)
    
    PageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        PageScroll.CanvasSize = UDim2.new(0, 0, 0, PageLayout.AbsoluteContentSize.Y + 10)
    end)

    local TabBtn = Instance.new("TextButton", TabContainer)
    TabBtn.Size = UDim2.new(1, 0, 0, 32)
    TabBtn.BackgroundColor3 = Theme.Bg
    TabBtn.BackgroundTransparency = 1
    TabBtn.Font = Enum.Font.GothamMedium
    TabBtn.Text = name
    TabBtn.TextColor3 = Theme.TextMuted
    TabBtn.TextSize = 12
    TabBtn.LayoutOrder = order
    
    local TabCorner = Instance.new("UICorner", TabBtn)
    TabCorner.CornerRadius = UDim.new(0, 6)
    
    TabBtn.MouseButton1Click:Connect(function()
        for _, p in pairs(Pages) do p.Visible = false end
        for t, btn in pairs(Tabs) do 
            btn.TextColor3 = Theme.TextMuted
            btn.BackgroundTransparency = 1
        end
        PageScroll.Visible = true
        TabBtn.TextColor3 = Theme.Accent
        TabBtn.BackgroundColor3 = Theme.CardBg
        TabBtn.BackgroundTransparency = 0
        ActivePage = PageScroll
    end)
    
    Pages[name] = PageScroll
    Tabs[PageScroll] = TabBtn
    return PageScroll
end

-- ADVANCED SPECTATOR FREECAM CORE ENGINE
local FreecamCamera = nil
local FreecamRenderConnection = nil
local FreecamLocalConnections = {}
local FreecamVelocity = Vector3.zero
local FreecamRotX, FreecamRotY = 0, 0
local FreecamKeysDown = {}

local function BuildAdvancedFreecam()
    if Config.Freecam then
        -- Simpan camera asli
        local originalCamera = Workspace.CurrentCamera
        FreecamCamera = Instance.new("Camera")
        FreecamCamera.Name = "AR_Freecam_Instance"
        FreecamCamera.FieldOfView = originalCamera.FieldOfView
        FreecamCamera.CFrame = originalCamera.CFrame
        
        -- Dapatkan orientasi awal dari CFrame kamera lama
        local lookX, lookY, lookZ = FreecamCamera.CFrame:ToEulerAnglesXYZ()
        FreecamRotX = lookY
        FreecamRotY = lookX

        Workspace.CurrentCamera = FreecamCamera
        
        -- Event Listeners untuk Keyboard Pergerakan Freecam
        table.insert(FreecamLocalConnections, UserInputService.InputBegan:Connect(function(input, processed)
            if processed then return end
            if input.KeyCode == Enum.KeyCode.W or input.KeyCode == Enum.KeyCode.A or 
               input.KeyCode == Enum.KeyCode.S or input.KeyCode == Enum.KeyCode.D or
               input.KeyCode == Enum.KeyCode.E or input.KeyCode == Enum.KeyCode.Q then
                FreecamKeysDown[input.KeyCode] = true
            end
        end))
        
        table.insert(FreecamLocalConnections, UserInputService.InputEnded:Connect(function(input)
            if input.KeyCode == Enum.KeyCode.W or input.KeyCode == Enum.KeyCode.A or 
               input.KeyCode == Enum.KeyCode.S or input.KeyCode == Enum.KeyCode.D or
               input.KeyCode == Enum.KeyCode.E or input.KeyCode == Enum.KeyCode.Q then
                FreecamKeysDown[input.KeyCode] = nil
            end
        end))
        
        -- Event Listener untuk rotasi Mouse (Klik Kanan ditahan untuk rotasi arah pandang)
        table.insert(FreecamLocalConnections, UserInputService.InputChanged:Connect(function(input, processed)
            if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
                if input.UserInputType == Enum.UserInputType.MouseMovement then
                    local delta = input.Delta
                    FreecamRotX = FreecamRotX - (delta.X * 0.003)
                    FreecamRotY = math.clamp(FreecamRotY - (delta.Y * 0.003), -math.rad(80), math.rad(80))
                end
            end
        end))

        -- Perhitungan frame pergerakan mulus omni-directional
        FreecamRenderConnection = RunService.RenderStepped:Connect(function(dt)
            local accel = Vector3.zero
            if FreecamKeysDown[Enum.KeyCode.W] then accel = accel + Vector3.new(0, 0, -1) end
            if FreecamKeysDown[Enum.KeyCode.S] then accel = accel + Vector3.new(0, 0, 1) end
            if FreecamKeysDown[Enum.KeyCode.A] then accel = accel + Vector3.new(-1, 0, 0) end
            if FreecamKeysDown[Enum.KeyCode.D] then accel = accel + Vector3.new(1, 0, 0) end
            if FreecamKeysDown[Enum.KeyCode.E] then accel = accel + Vector3.new(0, 1, 0) end
            if FreecamKeysDown[Enum.KeyCode.Q] then accel = accel + Vector3.new(0, -1, 0) end

            local baseSpeed = 40 * Config.FreecamSpeed
            local targetVelocity = accel * baseSpeed
            FreecamVelocity = FreecamVelocity:Lerp(targetVelocity, math.clamp(dt * 10, 0, 1))

            local upAndHorizontalRotation = CFrame.fromEulerAnglesYXZ(FreecamRotY, FreecamRotX, 0)
            local worldMovement = upAndHorizontalRotation:VectorToWorldSpace(FreecamVelocity)
            
            FreecamCamera.CFrame = CFrame.new(FreecamCamera.CFrame.Position + worldMovement) * upAndHorizontalRotation

            -- Fitur Baru: Jika diaktifkan, karakter ikut dipindahkan ke posisi freecam
            if Config.FreecamFollowCharacter and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
                Player.Character.HumanoidRootPart.CFrame = CFrame.new(FreecamCamera.CFrame.Position)
            end
        end)
    else
        -- Clean up Freecam Engine
        if FreecamRenderConnection then FreecamRenderConnection:Disconnect() FreecamRenderConnection = nil end
        for _, conn in pairs(FreecamLocalConnections) do conn:Disconnect() end
        FreecamLocalConnections = {}
        FreecamKeysDown = {}
        
        if FreecamCamera then
            FreecamCamera:Destroy()
            FreecamCamera = nil
        end
        Workspace.CurrentCamera = Workspace.MainCamera or Workspace:FindFirstChildOfClass("Camera")
    end
end

-- DYNAMIC KEYBIND SYSTEM TOGGLE ENGINE
local isBinding = false
local BindButtonObject = nil

local function ToggleMenuVisibility()
    if MainFrame.Size.X.Offset > 0 then
        MainFrame:TweenSize(UDim2.new(0, 0, 0, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.3, true, function()
            MainFrame.Visible = false
            ToggleButton.Visible = true
        end)
    else
        ToggleButton.Visible = false
        MainFrame.Visible = true
        MainFrame:TweenSize(UDim2.new(0, 520, 0, 300), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.3, true)
    end
end

UserInputService.InputBegan:Connect(function(input, processed)
    if isBinding and BindButtonObject then
        if input.UserInputType == Enum.UserInputType.Keyboard then
            Config.ToggleKey = input.KeyCode
            BindButtonObject.Text = input.KeyCode.Name:upper()
            isBinding = false
            BindButtonObject = nil
        end
        return
    end
    if not processed and input.UserInputType == Enum.UserInputType.Keyboard then
        if input.KeyCode == Config.ToggleKey then
            ToggleMenuVisibility()
        end
    end
end)

ToggleButton.MouseButton1Click:Connect(ToggleMenuVisibility)

-- CARD GENERATOR COMPONENT
local function createCard(parent, title, height)
    local Card = Instance.new("Frame", parent)
    Card.Size = UDim2.new(1, -6, 0, height or 45)
    Card.BackgroundColor3 = Theme.CardBg
    Card.BorderSizePixel = 0
    Instance.new("UICorner", Card).CornerRadius = UDim.new(0, 6)
    local CardStroke = Instance.new("UIStroke", Card)
    CardStroke.Color = Theme.Stroke
    
    local CardTitle = Instance.new("TextLabel", Card)
    CardTitle.Size = UDim2.new(0.6, 0, 1, 0)
    CardTitle.Position = UDim2.new(0, 10, 0, 0)
    CardTitle.BackgroundTransparency = 1
    CardTitle.Font = Enum.Font.GothamMedium
    CardTitle.Text = title
    CardTitle.TextColor3 = Theme.TextMain
    CardTitle.TextSize = 13
    CardTitle.TextXAlignment = Enum.TextXAlignment.Left
    
    return Card
end

-- UI INTERACTION DESIGN GENERATORS
local function addToggle(parent, title, default, callback)
    local card = createCard(parent, title)
    local btn = Instance.new("TextButton", card)
    btn.Size = UDim2.new(0, 36, 0, 20)
    btn.Position = UDim2.new(1, -46, 0.5, -10)
    btn.BackgroundColor3 = default and Theme.Accent or Theme.Sidebar
    btn.Text = ""
    local btnCorner = Instance.new("UICorner", btn)
    btnCorner.CornerRadius = UDim.new(0, 10)
    local btnStroke = Instance.new("UIStroke", btn)
    btnStroke.Color = Theme.Stroke

    local indicator = Instance.new("Frame", btn)
    indicator.Size = UDim2.new(0, 14, 0, 14)
    indicator.Position = UDim2.new(0, default and 19 or 3, 0.5, -7)
    indicator.BackgroundColor3 = Theme.TextMain
    Instance.new("UICorner", indicator).CornerRadius = UDim.new(0, 7)

    local state = default
    btn.MouseButton1Click:Connect(function()
        state = not state
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = state and Theme.Accent or Theme.Sidebar}):Play()
        TweenService:Create(indicator, TweenInfo.new(0.2), {Position = UDim2.new(0, state and 19 or 3, 0.5, -7)}):Play()
        callback(state)
    end)
end

local function addSliderWithInput(parent, title, min, max, default, callback)
    local card = createCard(parent, title, 55)
    card.Size = UDim2.new(1, -6, 0, 55)
    
    local sliderFrame = Instance.new("Frame", card)
    sliderFrame.Size = UDim2.new(0.65, 0, 0, 4)
    sliderFrame.Position = UDim2.new(0, 10, 0, 38)
    sliderFrame.BackgroundColor3 = Theme.Sidebar
    Instance.new("UICorner", sliderFrame)

    local fill = Instance.new("Frame", sliderFrame)
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Theme.Accent
    Instance.new("UICorner", fill)

    local valInput = Instance.new("TextBox", card)
    valInput.Size = UDim2.new(0, 55, 0, 24)
    valInput.Position = UDim2.new(1, -65, 0, 15)
    valInput.BackgroundColor3 = Theme.Sidebar
    valInput.Font = Enum.Font.GothamMedium
    valInput.Text = tostring(default)
    valInput.TextColor3 = Theme.TextMain
    valInput.TextSize = 11
    Instance.new("UICorner", valInput).CornerRadius = UDim.new(0, 4)
    Instance.new("UIStroke", valInput).Color = Theme.Stroke

    local function updateValue(val)
        val = math.clamp(tonumber(val) or min, min, max)
        valInput.Text = tostring(math.floor(val))
        fill.Size = UDim2.new((val - min) / (max - min), 0, 1, 0)
        callback(val)
    end

    local isSliding = false
    sliderFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isSliding = true
            local p = math.clamp((input.Position.X - sliderFrame.AbsolutePosition.X) / sliderFrame.AbsoluteSize.X, 0, 1)
            updateValue(min + p * (max - min))
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if isSliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local p = math.clamp((input.Position.X - sliderFrame.AbsolutePosition.X) / sliderFrame.AbsoluteSize.X, 0, 1)
            updateValue(min + p * (max - min))
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isSliding = false
        end
    end)

    valInput.FocusLost:Connect(function()
        updateValue(valInput.Text)
    end)
end

-- PAGES INITIALIZATION
local PlayerPage = CreatePage("👤 Player", 1)
local EspPage = CreatePage("👁️ ESP", 2)
local TeleportPage = CreatePage("🌀 Teleport", 3)
local UtilityPage = CreatePage("🛠️ Utility", 4)
local ServerPage = CreatePage("🌐 Server", 5)
local SettingPage = CreatePage("⚙️ Setting", 6)

-- ==========================================
-- POPULATING TABS FUNCTIONS WITH MODS
-- ==========================================

-- PLAYER MODULE
addToggle(PlayerPage, "Enable Fly Engine", false, function(v)
    Config.FlyMode = v
    pcall(function()
        local hum = Player.Character and Player.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            if v then
                hum:ChangeState(Enum.HumanoidStateType.Flying)
            else
                hum:SetStateEnabled(Enum.HumanoidStateType.Flying, false)
                hum:ChangeState(Enum.HumanoidStateType.Running)
                local hrp = Player.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    for _, obj in pairs(hrp:GetChildren()) do
                        if obj:IsA("BodyVelocity") or obj:IsA("BodyGyro") then obj:Destroy() end
                    end
                end
            end
        end
    end)
end)

addSliderWithInput(PlayerPage, "Engine Fly Speed Multiplier", 10, 200, 50, function(v)
    Config.FlySpeed = v
end)

addToggle(PlayerPage, "Noclip Matrix (Pass Walls)", false, function(v)
    Config.Noclip = v
end)

addToggle(PlayerPage, "Override WalkSpeed", false, function(v)
    Config.SuperSpeed = v
end)

addSliderWithInput(PlayerPage, "Custom Speed Set", 16, 250, 16, function(v)
    Config.SpeedValue = v
end)

addToggle(PlayerPage, "Override JumpPower", false, function(v)
    Config.SuperJump = v
end)

addSliderWithInput(PlayerPage, "Custom Jump Force Set", 50, 500, 50, function(v)
    Config.JumpValue = v
end)

addToggle(PlayerPage, "Infinite Air Jumps", false, function(v)
    Config.InfiniteJump = v
end)

addToggle(PlayerPage, "Anti-Ragdoll Body Stabilization", false, function(v)
    Config.AntiRagdoll = v
end)

addToggle(PlayerPage, "Infinite Sub-Oxygen Supply", false, function(v)
    Config.InfiniteOxygen = v
end)

-- UTILITY MODULE (FREECAM ADVANCED RESIDES HERE)
addToggle(UtilityPage, "Advanced 3D Freecam Mode", false, function(v)
    Config.Freecam = v
    BuildAdvancedFreecam()
end)

addSliderWithInput(UtilityPage, "Freecam Camera Speed", 1, 10, 1, function(v)
    Config.FreecamSpeed = v
end)

-- Fitur Baru: Pengaturan apakah Karakter ikut bergeser atau diam di tempat saat Freecam aktif
addToggle(UtilityPage, "Freecam Character Tracking", false, function(v)
    Config.FreecamFollowCharacter = v
end)

-- SETTING MODULE (DYNAMIC TOGGLE SETTING RESIDES HERE)
do
    local card = createCard(SettingPage, "Toggle Menu Keybind")
    local bindBtn = Instance.new("TextButton", card)
    bindBtn.Size = UDim2.new(0, 90, 0, 24)
    bindBtn.Position = UDim2.new(1, -100, 0.5, -12)
    bindBtn.BackgroundColor3 = Theme.Sidebar
    bindBtn.Font = Enum.Font.GothamBold
    bindBtn.Text = Config.ToggleKey.Name:upper()
    bindBtn.TextColor3 = Theme.Accent
    bindBtn.TextSize = 11
    Instance.new("UICorner", bindBtn).CornerRadius = UDim.new(0, 4)
    Instance.new("UIStroke", bindBtn).Color = Theme.Stroke

    bindBtn.MouseButton1Click:Connect(function()
        if not isBinding then
            isBinding = true
            BindButtonObject = bindBtn
            bindBtn.Text = "..."
        end
    end)
end

addToggle(SettingPage, "Enable FPS Performance Booster", false, function(v)
    pcall(function()
        if v then
            Workspace.Terrain.WaterWaveSize = 0
            Workspace.Terrain.WaterWaveSpeed = 0
            Workspace.Terrain.WaterReflectance = 0
            game:GetService("Lighting").GlobalShadows = false
            settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
        else
            game:GetService("Lighting").GlobalShadows = true
            settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic
        end
    end)
end)

addToggle(SettingPage, "Ambience FullBright Light Changer", false, function(v)
    Config.FullBright = v
    pcall(function()
        if v then
            game:GetService("Lighting").Ambient = Color3.fromRGB(255, 255, 255)
            game:GetService("Lighting").OutdoorAmbient = Color3.fromRGB(255, 255, 255)
        else
            game:GetService("Lighting").Ambient = Color3.fromRGB(128, 128, 128)
            game:GetService("Lighting").OutdoorAmbient = Color3.fromRGB(128, 128, 128)
        end
    end)
end)

-- SERVER & NOTIFICATION COMPONENT
local function notify(txt)
    pcall(function()
        local n = Instance.new("Frame", ScreenGui)
        n.Size = UDim2.new(0, 220, 0, 35)
        n.Position = UDim2.new(1, 10, 1, -45)
        n.BackgroundColor3 = Theme.Sidebar
        Instance.new("UICorner", n).CornerRadius = UDim.new(0, 5)
        Instance.new("UIStroke", n).Color = Theme.Accent
        local t = Instance.new("TextLabel", n)
        t.Size = UDim2.new(1, -10, 1, 0)
        t.Position = UDim2.new(0, 10, 0, 0)
        t.BackgroundTransparency = 1
        t.Font = Enum.Font.GothamMedium
        t.Text = txt
        t.TextColor3 = Theme.TextMain
        t.TextSize = 11
        t.TextXAlignment = Enum.TextXAlignment.Left
        n:TweenPosition(UDim2.new(1, -230, 1, -45), "Out", "Quart", 0.3, true)
        task.wait(2.5)
        n:TweenPosition(UDim2.new(1, 10, 1, -45), "In", "Quart", 0.3, true, function() n:Destroy() end)
    end)
end

local function addActionButton(parent, title, callback)
    local card = createCard(parent, title)
    local btn = Instance.new("TextButton", card)
    btn.Size = UDim2.new(0, 80, 0, 24)
    btn.Position = UDim2.new(1, -90, 0.5, -12)
    btn.BackgroundColor3 = Theme.Sidebar
    btn.Font = Enum.Font.GothamBold
    btn.Text = "EXECUTE"
    btn.TextColor3 = Theme.Accent
    btn.TextSize = 10
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
    Instance.new("UIStroke", btn).Color = Theme.Stroke
    btn.MouseButton1Click:Connect(callback)
end

addActionButton(ServerPage, "Server Hop / Rejoin Variant", function()
    pcall(function()
        local x = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Desc&limit=100"))
        for _, s in pairs(x.data) do
            if s.playing < s.maxPlayers and s.id ~= game.JobId then
                TeleportService:TeleportToPlaceInstance(game.PlaceId, s.id, Player)
                break
            end
        end
    end)
end)

addActionButton(ServerPage, "Instant Rejoin Active Instance", function()
    TeleportService:Teleport(game.PlaceId, Player)
end)

addActionButton(ServerPage, "Copy Server Instance JobID", function()
    setclipboard(tostring(game.JobId))
    notify("Copied Server JobID to Clipboard!")
end)

-- ESP MODULE BUILDING
addToggle(EspPage, "Player ESP Box Wireframes", false, function(v) Config.ShowBoxes = v end)
addToggle(EspPage, "Player ESP Distances & Tags", false, function(v) Config.ShowNames = v end)
addToggle(EspPage, "Player Highlight Chams / Glows", false, function(v) Config.ShowGlow = v end)
addToggle(EspPage, "Ignore Team Allied Units", false, function(v) Config.TeamCheck = v end)

local function BuildESP(p)
    if p == Player then return end
    local box = Instance.new("BoxHandleAdornment")
    box.Name = "AR_Box"
    box.AlwaysOnTop = true
    box.ZIndex = 5
    box.Transparency = 0.5
    box.Color3 = Theme.Accent
    box.Adornee = nil

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "AR_Tag"
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.AlwaysOnTop = true
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    
    local tagLabel = Instance.new("TextLabel", billboard)
    tagLabel.Size = UDim2.new(1, 0, 1, 0)
    tagLabel.BackgroundTransparency = 1
    tagLabel.Font = Enum.Font.GothamBold
    tagLabel.TextSize = 11
    tagLabel.TextColor3 = Theme.TextMain

    local highlight = Instance.new("Highlight")
    highlight.Name = "AR_Highlight"
    highlight.FillColor = Theme.Accent
    highlight.OutlineColor = Theme.TextMain
    highlight.FillTransparency = 0.4
    highlight.Enabled = false

    local function updateESP()
        pcall(function()
            if not p.Character or not p.Character:FindFirstChild("HumanoidRootPart") or not p.Character:FindFirstChildOfClass("Humanoid") or p.Character:FindFirstChildOfClass("Humanoid").Health <= 0 then
                box.Adornee = nil
                billboard.Parent = nil
                highlight.Enabled = false
                return
            end

            if Config.TeamCheck and p.Team == Player.Team then
                box.Adornee = nil
                billboard.Parent = nil
                highlight.Enabled = false
                return
            end

            local hrp = p.Character.HumanoidRootPart
            if Config.ShowBoxes then
                box.Adornee = hrp
                box.Size = p.Character:GetExtentsSize()
                box.Parent = hrp
            else
                box.Adornee = nil
            end

            if Config.ShowNames then
                local dist = (Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")) and math.floor((Player.Character.HumanoidRootPart.Position - hrp.Position).Magnitude) or 0
                tagLabel.Text = p.Name .. " [" .. dist .. "m]"
                billboard.Parent = hrp
            else
                billboard.Parent = nil
            end

            if Config.ShowGlow then
                highlight.Parent = p.Character
                highlight.Enabled = true
            else
                highlight.Enabled = false
            end
        end)
    end

    RunService.RenderStepped:Connect(updateESP)
end

for _, p in pairs(Players:GetPlayers()) do BuildESP(p) end
Players.PlayerAdded:Connect(BuildESP)

-- TELEPORT & WAYPOINT SAVING DATA
local WaypointList = {}
local TeleportCardContainer = Instance.new("Frame", TeleportPage)
TeleportCardContainer.Size = UDim2.new(1, 0, 0, 0)
TeleportCardContainer.BackgroundTransparency = 1
local wpLayout = Instance.new("UIListLayout", TeleportCardContainer)
wpLayout.Padding = UDim.new(0, 4)
wpLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    TeleportCardContainer.Size = UDim2.new(1, 0, 0, wpLayout.AbsoluteContentSize.Y)
end)

local function getWpFileName() return "AR_Hub_Waypoints_" .. game.PlaceId .. ".json" end

local function saveWaypoints()
    pcall(function()
        writefile(getWpFileName(), HttpService:JSONEncode(WaypointList))
    end)
end

local function loadWaypoints()
    pcall(function()
        if isfile(getWpFileName()) then
            WaypointList = HttpService:JSONDecode(readfile(getWpFileName()))
        end
    end)
end

local function teleportTo(cf)
    pcall(function()
        local hrp = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            if Config.TweenTeleport then
                local dist = (hrp.Position - cf.Position).Magnitude
                local duration = dist / Config.TweenSpeed
                TweenService:Create(hrp, TweenInfo.new(duration, Enum.EasingStyle.Linear), {CFrame = cf}):Play()
            else
                hrp.CFrame = cf
            end
        end
    end)
end

local function redrawWaypoints()
    for _, obj in pairs(TeleportCardContainer:GetChildren()) do
        if obj:IsA("Frame") then obj:Destroy() end
    end
    for name, posTable in pairs(WaypointList) do
        local cf = CFrame.new(posTable[1], posTable[2], posTable[3], posTable[4], posTable[5], posTable[6], posTable[7], posTable[8], posTable[9], posTable[10], posTable[11], posTable[12])
        local card = createCard(TeleportCardContainer, name, 38)
        
        local tp = Instance.new("TextButton", card)
        tp.Size = UDim2.new(0, 50, 0, 22)
        tp.Position = UDim2.new(1, -115, 0.5, -11)
        tp.BackgroundColor3 = Theme.Accent
        tp.Font = Enum.Font.GothamBold
        tp.Text = "TELE"
        tp.TextColor3 = Theme.Bg
        tp.TextSize = 9
        Instance.new("UICorner", tp).CornerRadius = UDim.new(0, 4)

        local del = Instance.new("TextButton", card)
        del.Size = UDim2.new(0, 50, 0, 22)
        del.Position = UDim2.new(1, -60, 0.5, -11)
        del.BackgroundColor3 = Theme.Bad
        del.Font = Enum.Font.GothamBold
        del.Text = "DEL"
        del.TextColor3 = Theme.TextMain
        del.TextSize = 9
        Instance.new("UICorner", del).CornerRadius = UDim.new(0, 4)

        tp.MouseButton1Click:Connect(function() teleportTo(cf) end)
        del.MouseButton1Click:Connect(function()
            WaypointList[name] = nil
            saveWaypoints()
            redrawWaypoints()
        end)
    end
end

loadWaypoints()
addToggle(TeleportPage, "Interpolate Tween Teleportation", false, function(v) Config.TweenTeleport = v end)
addSliderWithInput(TeleportPage, "Tween Movement Target Speed", 10, 300, 50, function(v) Config.TweenSpeed = v end)

do
    local inputCard = createCard(TeleportPage, "Create New Saved Waypoint", 75)
    inputCard.Size = UDim2.new(1, -6, 0, 75)
    local wpNameInput = Instance.new("TextBox", inputCard)
    wpNameInput.Size = UDim2.new(0.65, 0, 0, 26)
    wpNameInput.Position = UDim2.new(0, 10, 0, 38)
    wpNameInput.BackgroundColor3 = Theme.Sidebar
    wpNameInput.Font = Enum.Font.GothamMedium
    wpNameInput.PlaceholderText = "Enter waypoint reference name..."
    wpNameInput.Text = ""
    wpNameInput.TextColor3 = Theme.TextMain
    wpNameInput.PlaceholderColor3 = Theme.TextMuted
    wpNameInput.TextSize = 11
    Instance.new("UICorner", wpNameInput).CornerRadius = UDim.new(0, 4)
    Instance.new("UIStroke", wpNameInput).Color = Theme.Stroke

    local saveWpBtn = Instance.new("TextButton", inputCard)
    saveWpBtn.Size = UDim2.new(0.25, 0, 0, 26)
    saveWpBtn.Position = UDim2.new(0.7, 5, 0, 38)
    saveWpBtn.BackgroundColor3 = Theme.Accent
    saveWpBtn.Font = Enum.Font.GothamBold
    saveWpBtn.Text = "SAVE WP"
    saveWpBtn.TextColor3 = Theme.Bg
    saveWpBtn.TextSize = 10
    Instance.new("UICorner", saveWpBtn).CornerRadius = UDim.new(0, 4)

    saveWpBtn.MouseButton1Click:Connect(function()
        local name = wpNameInput.Text
        local hrp = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
        if name ~= "" and hrp then
            local comps = {hrp.CFrame:GetComponents()}
            WaypointList[name] = comps
            saveWaypoints()
            redrawWaypoints()
            wpNameInput.Text = ""
            notify("Waypoint '" .. name .. "' Saved Successfully!")
        end
    end)
end

redrawWaypoints()

-- SYSTEM LOOPS ENGINE & WORKSPACE LISTENER
RunService.Stepped:Connect(function()
    pcall(function()
        if Player.Character then
            local hum = Player.Character:FindFirstChildOfClass("Humanoid")
            local hrp = Player.Character:FindFirstChild("HumanoidRootPart")
            
            if Config.Noclip then
                for _, part in pairs(Player.Character:GetDescendants()) do
                    if part:IsA("BasePart") then part.CanCollide = false end
                end
            end
            
            if hum then
                if Config.SuperSpeed then hum.WalkSpeed = Config.SpeedValue end
                if Config.SuperJump then hum.JumpPower = Config.JumpValue end
                if Config.InfiniteOxygen then hum.MaxOxygen = 100000 hum.Oxygen = 100000 end
                
                if Config.AntiRagdoll then
                    hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
                    hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
                end
                
                if Config.FlyMode and hrp then
                    local bv = hrp:FindFirstChild("AR_FlyVelocity") or Instance.new("BodyVelocity", hrp)
                    bv.Name = "AR_FlyVelocity"
                    bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
                    
                    local bg = hrp:FindFirstChild("AR_FlyGyro") or Instance.new("BodyGyro", hrp)
                    bg.Name = "AR_FlyGyro"
                    bg.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
                    bg.CFrame = Workspace.CurrentCamera.CFrame
                    
                    local moveDir = hum.MoveDirection
                    local camCF = Workspace.CurrentCamera.CFrame
                    local flyVel = Vector3.zero
                    
                    if moveDir.Magnitude > 0 then
                        local forward = camCF.LookVector
                        local right = camCF.RightVector
                        flyVel = (forward * moveDir.Z + right * moveDir.X).Unit * Config.FlySpeed
                    end
                    bv.Velocity = flyVel
                end
            end
        end
    end)
end)

UserInputService.JumpRequest:Connect(function()
    pcall(function()
        if Config.InfiniteJump and Player.Character then
            local hum = Player.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
        end
    end)
end)

-- INTEGRATED PREMIUM 24H VERIFICATION KEY SYSTEM
local CorrectKey = "AR_PREMIUM_KEY"
local KeyStatusFile = "AR_Hub_KeySystem.json"

local function hasValidKey()
    local success, result = pcall(function()
        if isfile(KeyStatusFile) then
            local data = HttpService:JSONDecode(readfile(KeyStatusFile))
            if data and data.Key == CorrectKey and (os.time() - data.Timestamp) < 86400 then
                return true
            end
        end
        return false
    end)
    return success and result
end

local function saveKeyStatus()
    pcall(function()
        local data = {Key = CorrectKey, Timestamp = os.time()}
        writefile(KeyStatusFile, HttpService:JSONEncode(data))
    end)
end

if hasValidKey() then
    MainFrame.Visible = true
    MainFrame.Size = UDim2.new(0, 520, 0, 300)
    if Tabs[PlayerPage] then Tabs[PlayerPage]:SetAttribute("Active", true) Pages["👤 Player"].Visible = true Tabs[PlayerPage].TextColor3 = Theme.Accent Tabs[PlayerPage].BackgroundColor3 = Theme.CardBg Tabs[PlayerPage].BackgroundTransparency = 0 ActivePage = Pages["👤 Player"] end
else
    local KeyFrame = Instance.new("Frame", ScreenGui)
    KeyFrame.Size = UDim2.new(0, 320, 0, 180)
    KeyFrame.Position = UDim2.new(0.5, -160, 0.5, -90)
    KeyFrame.BackgroundColor3 = Theme.Bg
    Instance.new("UICorner", KeyFrame).CornerRadius = UDim.new(0, 8)
    local KeyStroke = Instance.new("UIStroke", KeyFrame) KeyStroke.Color = Theme.Accent KeyStroke.Thickness = 1.5

    local KeyTitle = Instance.new("TextLabel", KeyFrame) KeyTitle.Size = UDim2.new(1, 0, 0, 40) KeyTitle.BackgroundTransparency = 1 KeyTitle.Font = Enum.Font.GothamBold KeyTitle.Text = "ENTER PREMIUM ACCESS KEY" KeyTitle.TextColor3 = Theme.TextMain KeyTitle.TextSize = 12
    local KeyInput = Instance.new("TextBox", KeyFrame) KeyInput.Size = UDim2.new(1, -40, 0, 32) KeyInput.Position = UDim2.new(0, 20, 0, 55) KeyInput.BackgroundColor3 = Theme.CardBg KeyInput.Font = Enum.Font.GothamMedium KeyInput.PlaceholderText = "Paste key here..." KeyInput.Text = "" KeyInput.TextColor3 = Theme.TextMain KeyInput.PlaceholderColor3 = Theme.TextMuted KeyInput.TextSize = 11 Instance.new("UICorner", KeyInput).CornerRadius = UDim.new(0, 5) Instance.new("UIStroke", KeyInput).Color = Theme.Stroke
    local SubmitBtn = Instance.new("TextButton", KeyFrame) SubmitBtn.Size = UDim2.new(1, -40, 0, 32) SubmitBtn.Position = UDim2.new(0, 20, 1, -50) SubmitBtn.BackgroundColor3 = Theme.Accent SubmitBtn.Font = Enum.Font.GothamBold SubmitBtn.Text = "VERIFY KEY" SubmitBtn.TextColor3 = Theme.Bg SubmitBtn.TextSize = 11 Instance.new("UICorner", SubmitBtn).CornerRadius = UDim.new(0, 5)

    SubmitBtn.MouseButton1Click:Connect(function()
        if KeyInput.Text == CorrectKey then
            saveKeyStatus() KeyFrame:Destroy() MainFrame.Visible = true MainFrame.Size = UDim2.new(0, 520, 0, 300)
            if Tabs[PlayerPage] then Tabs[PlayerPage]:SetAttribute("Active", true) Pages["👤 Player"].Visible = true Tabs[PlayerPage].TextColor3 = Theme.Accent Tabs[PlayerPage].BackgroundColor3 = Theme.CardBg Tabs[PlayerPage].BackgroundTransparency = 0 ActivePage = Pages["👤 Player"] end
        else
            KeyInput.Text = "" KeyInput.PlaceholderText = "INVALID KEY! TRY AGAIN." KeyInput.PlaceholderColor3 = Theme.Bad
        end
    end)
end
