-- ====================================================================
-- AR SCRIPT HUB - QUANTUM ADMIN HUB (V5.0 - PREMIUM COMPACT DEPLOY)
-- ====================================================================
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local SafeGuiTarget = Player:FindFirstChildOfClass("PlayerGui") or Player:WaitForChild("PlayerGui", 5)
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- Bersihkan GUI Lama
if SafeGuiTarget and SafeGuiTarget:FindFirstChild("AR_Quantum_Hub") then
    SafeGuiTarget.AR_Quantum_Hub:Destroy()
end

local MainGui = Instance.new("ScreenGui")
MainGui.Name = "AR_Quantum_Hub"
MainGui.Parent = SafeGuiTarget
MainGui.ResetOnSpawn = false
MainGui.DisplayOrder = 999999999

-- THEME COLOR PALETTE (PREMIUM DARK CYBERPUNK)
local Theme = {
    Bg = Color3.fromRGB(11, 14, 22),       
    CardBg = Color3.fromRGB(18, 22, 32),   
    Stroke = Color3.fromRGB(28, 36, 50),   
    Accent = Color3.fromRGB(0, 230, 160),  
    TextMain = Color3.fromRGB(240, 245, 255),
    TextMuted = Color3.fromRGB(110, 125, 145)
}

-- ====================================================================
-- CYBERPUNK LOADING UI SYSTEM
-- ====================================================================
local LoadingPanel = Instance.new("Frame")
LoadingPanel.Name = "LoadingPanel"
LoadingPanel.Size = UDim2.new(0, 240, 0, 130)
LoadingPanel.Position = UDim2.new(0.5, -120, 0.5, -65)
LoadingPanel.BackgroundColor3 = Theme.Bg
LoadingPanel.Parent = MainGui
Instance.new("UICorner", LoadingPanel).CornerRadius = UDim.new(0, 8)
local loadStroke = Instance.new("UIStroke", LoadingPanel)
loadStroke.Color = Theme.Stroke

local LoadLogo = Instance.new("TextLabel", LoadingPanel)
LoadLogo.Size = UDim2.new(1, 0, 0, 40)
LoadLogo.Position = UDim2.new(0, 0, 0, 15)
LoadLogo.Text = "QUANTUM v5.0"
LoadLogo.Font = Enum.Font.GothamBold
LoadLogo.TextColor3 = Theme.Accent
LoadLogo.TextSize = 24
LoadLogo.BackgroundTransparency = 1

local LoadStatus = Instance.new("TextLabel", LoadingPanel)
LoadStatus.Size = UDim2.new(1, -20, 0, 20)
LoadStatus.Position = UDim2.new(0, 10, 0, 60)
LoadStatus.Text = "Assembling Interface..."
LoadStatus.Font = Enum.Font.GothamMedium
LoadStatus.TextColor3 = Theme.TextMuted
LoadStatus.TextSize = 10
LoadStatus.BackgroundTransparency = 1

local BarBg = Instance.new("Frame", LoadingPanel)
BarBg.Size = UDim2.new(1, -40, 0, 4)
BarBg.Position = UDim2.new(0, 20, 0, 90)
BarBg.BackgroundColor3 = Theme.CardBg
BarBg.BorderSizePixel = 0
Instance.new("UICorner", BarBg).CornerRadius = UDim.new(1, 0)

local BarFill = Instance.new("Frame", BarBg)
BarFill.Size = UDim2.new(0, 0, 1, 0)
BarFill.BackgroundColor3 = Theme.Accent
BarFill.BorderSizePixel = 0
Instance.new("UICorner", BarFill).CornerRadius = UDim.new(1, 0)

local sequences = {
    {0.30, "Structuring Compact Layouts..."},
    {0.60, "Injecting Anti-Fling & Stun Shields..."},
    {0.90, "Calibrating Advanced ESP Modules..."},
    {1.00, "Done!"}
}

local function runLoading()
    for _, step in ipairs(sequences) do
        LoadStatus.Text = step[2]
        local fillTween = TweenService:Create(BarFill, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(step[0], 0, 1, 0)})
        fillTween:Play()
        fillTween.Completed:Wait()
        task.wait(0.05)
    end
    task.wait(0.1)
    LoadingPanel:Destroy()
end

-- DRAGGABLE ENGINE
local function makeDraggable(frame, dragHandle)
    local dragging, dragInput, dragStart, startPos
    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    dragHandle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- COMPACT FLOATING TOGGLE
local ToggleButton = Instance.new("TextButton")
ToggleButton.Name = "ToggleButton"
ToggleButton.Parent = MainGui
ToggleButton.Size = UDim2.new(0, 42, 0, 42)
ToggleButton.Position = UDim2.new(0.02, 0, 0.2, 0)
ToggleButton.BackgroundColor3 = Theme.Bg
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.Text = "QT"
ToggleButton.TextColor3 = Theme.Accent
ToggleButton.TextSize = 15
Instance.new("UICorner", ToggleButton).CornerRadius = UDim.new(0, 8)
local tbStroke = Instance.new("UIStroke", ToggleButton)
tbStroke.Color = Theme.Accent
makeDraggable(ToggleButton, ToggleButton)

-- MAIN PANEL (SIZE FIX: 400 x 330 COMFORT MINIMALIS)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = MainGui
MainFrame.Size = UDim2.new(0, 400, 0, 330)
MainFrame.Position = UDim2.new(0.5, -200, 0.5, -165)
MainFrame.BackgroundColor3 = Theme.Bg
MainFrame.Visible = false 
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)
local mainStroke = Instance.new("UIStroke", MainFrame)
mainStroke.Color = Theme.Stroke

-- HEADER
local Header = Instance.new("Frame", MainFrame)
Header.Size = UDim2.new(1, 0, 0, 40)
Header.BackgroundTransparency = 1

local Title = Instance.new("TextLabel", Header)
Title.Text = "QUANTUM HUB <font color='#00e6a0'>v5.0</font>"
Title.RichText = true
Title.Size = UDim2.new(0.7, 0, 1, 0)
Title.Position = UDim2.new(0, 12, 0, 0)
Title.Font = Enum.Font.GothamBold
Title.TextColor3 = Theme.TextMain
Title.TextSize = 13
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.BackgroundTransparency = 1

local CloseBtn = Instance.new("TextButton", Header)
CloseBtn.Text = "×"
CloseBtn.Size = UDim2.new(0, 40, 1, 0)
CloseBtn.Position = UDim2.new(1, -40, 0, 0)
CloseBtn.Font = Enum.Font.GothamMedium
CloseBtn.TextColor3 = Theme.TextMuted
CloseBtn.TextSize = 20
CloseBtn.BackgroundTransparency = 1
CloseBtn.MouseEnter:Connect(function() CloseBtn.TextColor3 = Color3.fromRGB(255, 70, 70) end)
CloseBtn.MouseLeave:Connect(function() CloseBtn.TextColor3 = Theme.TextMuted end)

makeDraggable(MainFrame, Header)
ToggleButton.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)
CloseBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false end)

-- SIDEBAR MENU (RAMPING: 85PX)
local NavFrame = Instance.new("Frame", MainFrame)
NavFrame.Size = UDim2.new(0, 85, 1, -50)
NavFrame.Position = UDim2.new(0, 12, 0, 45)
NavFrame.BackgroundTransparency = 1

local ContentFrame = Instance.new("Frame", MainFrame)
ContentFrame.Size = UDim2.new(1, -120, 1, -55)
ContentFrame.Position = UDim2.new(0, 108, 0, 45)
ContentFrame.BackgroundTransparency = 1

local tabs = {Player = {}, ESP = {}, Utilities = {}, Settings = {}}
local activeTab = "Player"

local function createContainer(name)
    local f = Instance.new("ScrollingFrame", ContentFrame)
    f.Size = UDim2.new(1, 0, 1, 0)
    f.BackgroundTransparency = 1
    f.CanvasSize = UDim2.new(0, 0, 0, 520) 
    f.ScrollBarThickness = 2
    f.ScrollBarImageColor3 = Theme.Accent
    f.Visible = (name == activeTab)
    tabs[name].Container = f
    local layout = Instance.new("UIListLayout", f)
    layout.Padding = UDim.new(0, 6)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
end

createContainer("Player")
createContainer("ESP")
createContainer("Utilities")
createContainer("Settings")

local function switchTab(tabName)
    activeTab = tabName
    for k, v in pairs(tabs) do
        v.Container.Visible = (k == tabName)
        if v.Button then
            if k == tabName then
                v.Button.TextColor3 = Theme.Accent
                v.Button.Font = Enum.Font.GothamBold
            else
                v.Button.TextColor3 = Theme.TextMuted
                v.Button.Font = Enum.Font.GothamMedium
            end
        end
    end
end

local function addTabButton(name, textDisplay, order)
    local btn = Instance.new("TextButton", NavFrame)
    btn.Size = UDim2.new(1, 0, 0, 30)
    btn.Position = UDim2.new(0, 0, 0, (order - 1) * 34)
    btn.BackgroundTransparency = 1
    btn.Font = (name == activeTab) and Enum.Font.GothamBold or Enum.Font.GothamMedium
    btn.Text = textDisplay
    btn.TextSize = 11
    btn.TextColor3 = (name == activeTab) and Theme.Accent or Theme.TextMuted
    btn.TextXAlignment = Enum.TextXAlignment.Left
    tabs[name].Button = btn
    btn.MouseButton1Click:Connect(function() switchTab(name) end)
end

addTabButton("Player", "👤 Player", 1)
addTabButton("ESP", "👁️ ESP Sys", 2)
addTabButton("Utilities", "🛠️ Utilities", 3)
addTabButton("Settings", "⚙️ Settings", 4)

-- CLEAN LOOK COMPACT CARD GENERATOR
local function createSectionCard(parent, titleText, height, layoutOrder)
    local section = Instance.new("Frame", parent)
    section.Size = UDim2.new(1, -4, 0, height)
    section.BackgroundColor3 = Theme.CardBg
    section.LayoutOrder = layoutOrder
    Instance.new("UICorner", section).CornerRadius = UDim.new(0, 6)
    local sStroke = Instance.new("UIStroke", section)
    sStroke.Color = Theme.Stroke
    
    local sTitle = Instance.new("TextLabel", section)
    sTitle.Size = UDim2.new(1, -10, 0, 20)
    sTitle.Position = UDim2.new(0, 8, 0, 4)
    sTitle.Text = titleText:upper()
    sTitle.Font = Enum.Font.GothamBold
    sTitle.TextColor3 = Theme.TextMuted
    sTitle.TextSize = 9
    sTitle.BackgroundTransparency = 1
    sTitle.TextXAlignment = Enum.TextXAlignment.Left
    
    local container = Instance.new("Frame", section)
    container.Size = UDim2.new(1, -14, 1, -26)
    container.Position = UDim2.new(0, 7, 0, 22)
    container.BackgroundTransparency = 1
    local innerLayout = Instance.new("UIListLayout", container)
    innerLayout.Padding = UDim.new(0, 4)
    innerLayout.SortOrder = Enum.SortOrder.LayoutOrder
    
    return container
end

local function createToggleSwitch(parent, labelText, callback)
    local holder = Instance.new("Frame", parent)
    holder.Size = UDim2.new(1, 0, 0, 28) holder.BackgroundTransparency = 1
    
    local lbl = Instance.new("TextLabel", holder)
    lbl.Text = labelText lbl.Size = UDim2.new(0.65, 0, 1, 0)
    lbl.Font = Enum.Font.GothamMedium lbl.TextColor3 = Theme.TextMain lbl.TextSize = 11
    lbl.TextXAlignment = Enum.TextXAlignment.Left lbl.BackgroundTransparency = 1
    
    local bgTrack = Instance.new("TextButton", holder)
    bgTrack.Size = UDim2.new(0, 32, 0, 16) bgTrack.Position = UDim2.new(1, -32, 0.5, -8)
    bgTrack.BackgroundColor3 = Theme.Bg bgTrack.Text = ""
    Instance.new("UICorner", bgTrack).CornerRadius = UDim.new(0, 8)
    local tStroke = Instance.new("UIStroke", bgTrack) tStroke.Color = Theme.Stroke
    
    local knob = Instance.new("Frame", bgTrack)
    knob.Size = UDim2.new(0, 10, 0, 10) knob.Position = UDim2.new(0, 3, 0.5, -5)
    knob.BackgroundColor3 = Theme.TextMuted Instance.new("UICorner", knob).CornerRadius = UDim.new(0, 5)
    
    local state = false
    bgTrack.MouseButton1Click:Connect(function()
        state = not state
        local targetX = state and 19 or 3
        local targetTrackColor = state and Theme.Accent or Theme.Bg
        local targetKnobColor = state and Theme.Bg or Theme.TextMuted
        TweenService:Create(knob, TweenInfo.new(0.08), {Position = UDim2.new(0, targetX, 0.5, -5), BackgroundColor3 = targetKnobColor}):Play()
        TweenService:Create(bgTrack, TweenInfo.new(0.08), {BackgroundColor3 = targetTrackColor}):Play()
        tStroke.Color = state and Theme.Accent or Theme.Stroke
        callback(state)
    end)
end

local function createLevelControl(parent, labelText, defaultLvl, min, max, callback)
    local holder = Instance.new("Frame", parent)
    holder.Size = UDim2.new(1, 0, 0, 28) holder.BackgroundTransparency = 1
    
    local currentLvl = defaultLvl
    local lbl = Instance.new("TextLabel", holder)
    lbl.Text = labelText .. ": " .. currentLvl lbl.Size = UDim2.new(0.55, 0, 1, 0)
    lbl.Font = Enum.Font.GothamMedium lbl.TextColor3 = Theme.TextMain lbl.TextSize = 11
    lbl.TextXAlignment = Enum.TextXAlignment.Left lbl.BackgroundTransparency = 1
    
    local btnMinus = Instance.new("TextButton", holder)
    btnMinus.Text = "–" btnMinus.Size = UDim2.new(0, 20, 0, 20) btnMinus.Position = UDim2.new(1, -20, 0.5, -10)
    btnMinus.BackgroundColor3 = Theme.Bg btnMinus.TextColor3 = Theme.TextMain btnMinus.Font = Enum.Font.GothamBold
    btnMinus.TextSize = 11 Instance.new("UICorner", btnMinus).CornerRadius = UDim.new(0, 3)
    Instance.new("UIStroke", btnMinus).Color = Theme.Stroke
    
    local btnPlus = Instance.new("TextButton", holder)
    btnPlus.Text = "+" btnPlus.Size = UDim2.new(0, 20, 0, 20) btnPlus.Position = UDim2.new(1, -44, 0.5, -10)
    btnPlus.BackgroundColor3 = Theme.Bg btnPlus.TextColor3 = Theme.TextMain btnPlus.Font = Enum.Font.GothamBold
    btnPlus.TextSize = 11 Instance.new("UICorner", btnPlus).CornerRadius = UDim.new(0, 3)
    Instance.new("UIStroke", btnPlus).Color = Theme.Stroke
    
    btnPlus.MouseButton1Click:Connect(function()
        if currentLvl < max then currentLvl = currentLvl + 1 lbl.Text = labelText .. ": " .. currentLvl callback(currentLvl) end
    end)
    btnMinus.MouseButton1Click:Connect(function()
        if currentLvl > min then currentLvl = currentLvl - 1 lbl.Text = labelText .. ": " .. currentLvl callback(currentLvl) end
    end)
end

local function createStandardButton(parent, textDisplay, callback)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(1, 0, 0, 28) btn.BackgroundColor3 = Theme.Bg
    btn.Font = Enum.Font.GothamBold btn.Text = textDisplay btn.TextColor3 = Theme.TextMain btn.TextSize = 11
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
    local bStroke = Instance.new("UIStroke", btn) bStroke.Color = Theme.Stroke
    btn.MouseButton1Click:Connect(callback)
end

-- ====================================================================
-- TAB 1: PLAYER MODULES (BUFFS + SHIELDS PROTECTIONS)
-- ====================================================================
local pSec1 = createSectionCard(tabs.Player.Container, "Movement Modifiers", 120, 1)

local walkToggleState = false
local walkLevel = 1
local function updateWalkSpeed()
    local char = Player.Character
    if char and char:FindFirstChildOfClass("Humanoid") then
        char:FindFirstChildOfClass("Humanoid").WalkSpeed = walkToggleState and (walkLevel * 10) or 16
    end
end
createToggleSwitch(pSec1, "WalkSpeed Bypass", function(v) walkToggleState = v updateWalkSpeed() end)
createLevelControl(pSec1, "Speed Value", 1, 1, 20, function(lvl) walkLevel = lvl updateWalkSpeed() end)

local jumpToggleState = false
local jumpLevel = 5
local function updateJumpPower()
    local char = Player.Character
    if char and char:FindFirstChildOfClass("Humanoid") then
        local hum = char:FindFirstChildOfClass("Humanoid")
        hum.UseJumpPower = true
        hum.JumpPower = jumpToggleState and (jumpLevel * 10) or 50
    end
end
createToggleSwitch(pSec1, "JumpPower Bypass", function(v) jumpToggleState = v updateJumpPower() end)
createLevelControl(pSec1, "Jump Value", 5, 1, 20, function(lvl) jumpLevel = lvl updateJumpPower() end)

local pSec2 = createSectionCard(tabs.Player.Container, "Navigation States", 150, 2)
local noclipActive, flying, floatActive = false, false, false
local flyLevel = 5
local noclipConnection, flyConnection, floatConnection
local bg, bv, floatPart

createToggleSwitch(pSec2, "Noclip Mode (Ghost)", function(v)
    noclipActive = v
    if v then
        if noclipConnection then noclipConnection:Disconnect() end
        noclipConnection = RunService.Stepped:Connect(function()
            if noclipActive and Player.Character then
                for _, part in pairs(Player.Character:GetChildren()) do if part:IsA("BasePart") then part.CanCollide = false end end
            end
        end)
    else if noclipConnection then noclipConnection:Disconnect() noclipConnection = nil end end
end)

local function stopFlying()
    flying = false
    if bg then bg:Destroy() bg = nil end if bv then bv:Destroy() bv = nil end
    local hum = Player.Character and Player.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum:SetStateEnabled(Enum.HumanoidStateType.Flying, false) hum:ChangeState(Enum.HumanoidStateType.Running) end
end
createToggleSwitch(pSec2, "Fly Hack", function(v)
    if v then
        stopFlying() local char = Player.Character if not char or not char:FindFirstChild("HumanoidRootPart") then return end
        local torso = char.HumanoidRootPart local hum = char:FindFirstChildOfClass("Humanoid") flying = true
        bg = Instance.new("BodyGyro", torso) bg.P = 9e4 bg.maxTorque = Vector3.new(9e9, 9e9, 9e9) bg.cframe = torso.CFrame
        bv = Instance.new("BodyVelocity", torso) bv.velocity = Vector3.new(0,0,0) bv.maxForce = Vector3.new(9e9, 9e9, 9e9)
        task.spawn(function()
            while flying and task.wait() do
                if hum and torso and bv and bg then
                    hum:ChangeState(Enum.HumanoidStateType.Physics)
                    local speed = flyLevel * 10 local moveDir = hum.MoveDirection
                    if moveDir.Magnitude > 0 then
                        local camCF = workspace.CurrentCamera.CFrame
                        local direction = (camCF.LookVector * moveDir:Dot(Vector3.new(camCF.LookVector.X, 0, camCF.LookVector.Z).Unit)) + (camCF.RightVector * moveDir:Dot(Vector3.new(camCF.RightVector.X, 0, camCF.RightVector.Z).Unit))
                        bv.velocity = direction.Magnitude > 0 and direction.Unit * speed or Vector3.new(0,0,0)
                    else bv.velocity = Vector3.new(0,0,0) end
                    bg.cframe = workspace.CurrentCamera.CFrame
                end
            end
        end)
    else stopFlying() end
end)
createLevelControl(pSec2, "Fly Velocity Speed", 5, 1, 20, function(lvl) flyLevel = lvl end)

createToggleSwitch(pSec2, "Float Platform Engine", function(state)
    floatActive = state local char = Player.Character
    if state then
        if not char or not char:FindFirstChild("HumanoidRootPart") then return end
        floatPart = Instance.new("Part", workspace) floatPart.Size = Vector3.new(4, 0.5, 4) floatPart.Transparency = 1 floatPart.Anchored = true
        floatPart.CFrame = char.HumanoidRootPart.CFrame * CFrame.new(0, -3.25, 0)
        floatConnection = RunService.RenderStepped:Connect(function()
            if floatActive and char and char:FindFirstChild("HumanoidRootPart") and floatPart then
                floatPart.CFrame = CFrame.new(char.HumanoidRootPart.Position.X, floatPart.Position.Y, char.HumanoidRootPart.Position.Z)
            end
        end)
    else
        if floatConnection then floatConnection:Disconnect() floatConnection = nil end
        if floatPart then floatPart:Destroy() floatPart = nil end
    end
end)

local infJumpActive = false
local infJumpConnection
createToggleSwitch(pSec2, "Infinite Jump Exploits", function(v)
    infJumpActive = v
    if v then
        infJumpConnection = UserInputService.JumpRequest:Connect(function()
            if infJumpActive and Player.Character and Player.Character:FindFirstChildOfClass("Humanoid") then
                Player.Character:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end)
    else if infJumpConnection then infJumpConnection:Disconnect() infJumpConnection = nil end end
end)

local pSec3 = createSectionCard(tabs.Player.Container, "Defensive Protections", 145, 3)
local AntiAfkConnection, AntiFlingConnection, AntiStunConnection
local AntiFlingActive, AntiStunActive, IsInvisible = false, false, false

createToggleSwitch(pSec3, "Anti-AFK (24H Idle Bypass)", function(state)
    if state then
        AntiAfkConnection = Player.Idled:Connect(function()
            local vu = game:GetService("VirtualUser") vu:CaptureController() vu:ClickButton2(Vector2.new(0,0))
        end)
    else if AntiAfkConnection then AntiAfkConnection:Disconnect() AntiAfkConnection = nil end end
end)

createToggleSwitch(pSec3, "Anti-Fling Shield Core", function(state)
    AntiFlingActive = state
    if state then
        AntiFlingConnection = RunService.Heartbeat:Connect(function()
            local hrp = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
            if not AntiFlingActive or not hrp then return end
            if hrp.Velocity.Magnitude > 75 or hrp.RotVelocity.Magnitude > 75 then
                hrp.Velocity = Vector3.new(0,0,0) hrp.RotVelocity = Vector3.new(0,0,0)
            end
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= Player and p.Character then
                    for _, part in pairs(p.Character:GetChildren()) do if part:IsA("BasePart") then part.CanCollide = false end end
                end
            end
        end)
    else if AntiFlingConnection then AntiFlingConnection:Disconnect() AntiFlingConnection = nil end end
end)

createToggleSwitch(pSec3, "Anti-Stun / No Slowdown", function(state)
    AntiStunActive = state
    if state then
        AntiStunConnection = RunService.RenderStepped:Connect(function()
            local hum = Player.Character and Player.Character:FindFirstChildOfClass("Humanoid")
            if AntiStunActive and hum and (hum.PlatformStanding or hum.Sit) then
                hum.PlatformStanding = false hum.Sit = false hum:ChangeState(Enum.HumanoidStateType.Running)
            end
        end)
    else if AntiStunConnection then AntiStunConnection:Disconnect() AntiStunConnection = nil end end
end)

createToggleSwitch(pSec3, "Invisible Mode (Local)", function(state)
    IsInvisible = state local char = Player.Character
    if char and char:FindFirstChild("LowerTorso") then
        char.LowerTorso.RootJoint.Part0 = state and nil or char.HumanoidRootPart
    end
end)

Player.CharacterAdded:Connect(function(char)
    task.wait(1)
    if walkToggleState then updateWalkSpeed() end
    if jumpToggleState then updateJumpPower() end
    if IsInvisible and char:FindFirstChild("LowerTorso") then char.LowerTorso.RootJoint.Part0 = nil end
end)

-- ====================================================================
-- TAB 2: ADVANCED CUSTOMIZABLE ESP SYSTEM
-- ====================================================================
local espSec = createSectionCard(tabs.ESP.Container, "Visual Wallhack Configurations", 175, 1)

local EspSettings = {
    Active = false, Names = true, Distance = true, Health = true,
    Color = Color3.fromRGB(0, 230, 160)
}
local EspObjects = {}

local function applyEspToCharacter(targetPlayer, char)
    if targetPlayer == Player or not char then return end
    task.wait(0.4)
    local head = char:WaitForChild("Head", 5) local hum = char:FindFirstChildOfClass("Humanoid")
    if not head or not hum then return end
    
    if EspObjects[targetPlayer.Name] then EspObjects[targetPlayer.Name]:Destroy() EspObjects[targetPlayer.Name] = nil end
    
    local hl = Instance.new("Highlight")
    hl.Name = "Q_HL_" .. targetPlayer.Name hl.FillColor = EspSettings.Color hl.FillTransparency = 0.5
    hl.OutlineColor = Color3.fromRGB(255,255,255) hl.Adornee = char hl.Parent = MainGui
    
    local bb = Instance.new("BillboardGui", head) bb.Name = "Q_BB_" .. targetPlayer.Name
    bb.Size = UDim2.new(0, 130, 0, 40) bb.AlwaysOnTop = true bb.ExtentsOffset = Vector3.new(0, 2.5, 0)
    
    local lbl = Instance.new("TextLabel", bb) lbl.Size = UDim2.new(1, 0, 1, 0) lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.GothamBold lbl.TextSize = 10 lbl.TextColor3 = EspSettings.Color
    lbl.TextStrokeTransparency = 0.5
    
    local connection
    connection = RunService.RenderStepped:Connect(function()
        if not EspSettings.Active or not char.Parent or not hum or hum.Health <= 0 then
            hl:Destroy() bb:Destroy() if connection then connection:Disconnect() end
            EspObjects[targetPlayer.Name] = nil return
        end
        hl.FillColor = EspSettings.Color
        lbl.TextColor3 = EspSettings.Color
        
        local tx = ""
        if EspSettings.Names then tx = tx .. targetPlayer.Name .. "\n" end
        if EspSettings.Health then tx = tx .. "HP: " .. math.floor(hum.Health) .. " " end
        if EspSettings.Distance and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("HumanoidRootPart") then
            local dst = math.floor((Player.Character.HumanoidRootPart.Position - char.HumanoidRootPart.Position).Magnitude)
            tx = tx .. "[" .. dst .. "m]"
        end
        lbl.Text = tx
    end)
    EspObjects[targetPlayer.Name] = hl
end

local function triggerAllEsp()
    for _, p in pairs(Players:GetPlayers()) do if p.Character then applyEspToCharacter(p, p.Character) end end
end

createToggleSwitch(espSec, "Master Activation ESP", function(v)
    EspSettings.Active = v
    if v then
        triggerAllEsp()
        _G.EspAddC = Players.PlayerAdded:Connect(function(p)
            p.CharacterAdded:Connect(function(nc) if EspSettings.Active then applyEspToCharacter(p, nc) end end)
        end)
    else
        if _G.EspAddC then _G.EspAddC:Disconnect() _G.EspAddC = nil end
        for _, p in pairs(Players:GetPlayers()) do
            if p.Character then
                local b = p.Character.Head:FindFirstChild("Q_BB_" .. p.Name) if b then b:Destroy() end
                local h = p.Character:FindFirstChild("Q_HL_" .. p.Name) if h then h:Destroy() end
            end
        end
    end
end)
createToggleSwitch(espSec, "Show Tag Names", function(v) EspSettings.Names = v end)
createToggleSwitch(espSec, "Show Distance Meter", function(v) EspSettings.Distance = v end)
createToggleSwitch(espSec, "Show Health Monitor", function(v) EspSettings.Health = v end)

-- MINIMALIS COMFORT DROPDOWN UNTUK WARNA
local colorCard = Instance.new("Frame", tabs.ESP.Container)
colorCard.Size = UDim2.new(1, -4, 0, 32) colorCard.BackgroundColor3 = Theme.CardBg
Instance.new("UICorner", colorCard).CornerRadius = UDim.new(0, 5)
Instance.new("UIStroke", colorCard).Color = Theme.Stroke
local ccTrigger = Instance.new("TextButton", colorCard)
ccTrigger.Size = UDim2.new(1, 0, 1, 0) ccTrigger.BackgroundTransparency = 1
ccTrigger.Font = Enum.Font.GothamMedium ccTrigger.Text = "  🎨 Palette Theme: Aqua Green ▼"
ccTrigger.TextColor3 = Theme.Accent ccTrigger.TextSize = 10 ccTrigger.TextXAlignment = Enum.TextXAlignment.Left

local ccScroll = Instance.new("ScrollingFrame", MainGui)
ccScroll.Size = UDim2.new(0, 160, 0, 90) ccScroll.BackgroundColor3 = Theme.CardBg
ccScroll.Visible = false ccScroll.ZIndex = 999999 Instance.new("UIStroke", ccScroll).Color = Theme.Accent
local ccLayout = Instance.new("UIListLayout", ccScroll)

local colorsData = {
    {Name = "Aqua Neon", Color = Color3.fromRGB(0, 230, 160)},
    {Name = "Crimson Hell", Color = Color3.fromRGB(255, 60, 60)},
    {Name = "Vampire Gold", Color = Color3.fromRGB(255, 215, 0)},
    {Name = "Absolute White", Color = Color3.fromRGB(255, 255, 255)},
    {Name = "Deep Blue Cyber", Color = Color3.fromRGB(0, 120, 255)}
}
for _, c in ipairs(colorsData) do
    local b = Instance.new("TextButton", ccScroll) b.Size = UDim2.new(1,0,0,22) b.BackgroundTransparency = 1
    b.Font = Enum.Font.GothamMedium b.Text = "  " .. c.Name b.TextColor3 = Theme.TextMain b.TextSize = 10 b.TextXAlignment = Enum.TextXAlignment.Left
    b.MouseButton1Click:Connect(function()
        EspSettings.Color = c.Color ccTrigger.Text = "  🎨 Palette Theme: " .. c.Name .. " ▼" ccScroll.Visible = false
    end)
end
ccTrigger.MouseButton1Click:Connect(function()
    ccScroll.Position = UDim2.new(0, ccTrigger.AbsolutePosition.X, 0, ccTrigger.AbsolutePosition.Y + 30)
    ccScroll.Visible = not ccScroll.Visible
end)

-- ====================================================================
-- TAB 3: UTILITIES & TELEPORTS SYSTEMS
-- ====================================================================
local tpSec = createSectionCard(tabs.Utilities.Container, "Navigation Coordinates", 95, 1)
local useTweenTeleport = false
createToggleSwitch(tpSec, "Tween Physics (Anti-Kick)", function(state) useTweenTeleport = state end)

local function masterTeleport(targetCFrame)
    local hrp = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") if not hrp then return end
    local safeTarget = targetCFrame * CFrame.new(0, 2.5, 0)
    if useTweenTeleport then
        local dist = (hrp.Position - safeTarget.Position).Magnitude
        TweenService:Create(hrp, TweenInfo.new(math.max(dist/160, 0.2), Enum.EasingStyle.Linear), {CFrame = safeTarget}):Play()
    else hrp.CFrame = safeTarget end
end

local waypointSlots = {Slot1 = nil, Slot2 = nil}
local function createWpRow(slot, name)
    local row = Instance.new("Frame", tpSec) row.Size = UDim2.new(1, 0, 0, 24) row.BackgroundTransparency = 1
    local l = Instance.new("TextLabel", row) l.Text = name l.Font = Enum.Font.GothamMedium l.TextColor3 = Theme.TextMain l.TextSize = 10 l.Size = UDim2.new(0.4,0,1,0) l.TextXAlignment = Enum.TextXAlignment.Left l.BackgroundTransparency = 1
    
    local bS = Instance.new("TextButton", row) bS.Text = "Save" bS.Size = UDim2.new(0, 45, 0, 20) bS.Position = UDim2.new(0.65, 0, 0, 2) bS.BackgroundColor3 = Theme.Bg bS.TextColor3 = Theme.Accent bS.Font = Enum.Font.GothamBold bS.TextSize = 9 Instance.new("UICorner", bS)
    local bT = Instance.new("TextButton", row) bT.Text = "TP" bT.Size = UDim2.new(0, 35, 0, 20) bT.Position = UDim2.new(0.85, 0, 0, 2) bT.BackgroundColor3 = Theme.Bg bT.TextColor3 = Theme.Accent bT.Font = Enum.Font.GothamBold bT.TextSize = 9 Instance.new("UICorner", bT)
    
    bS.MouseButton1Click:Connect(function() if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then waypointSlots[slot] = Player.Character.HumanoidRootPart.CFrame bS.Text = "Saved!" task.delay(0.8, function() bS.Text = "Save" end) end end)
    bT.MouseButton1Click:Connect(function() if waypointSlots[slot] then masterTeleport(waypointSlots[slot]) end end)
end
createWpRow("Slot1", "📌 Position A")
createWpRow("Slot2", "📌 Position B")

local funTargetName = ""
local actSec = createSectionCard(tabs.Utilities.Container, "Target Interactivity Engine", 150, 2)

local ddMainF = Instance.new("Frame", actSec) ddMainF.Size = UDim2.new(1, 0, 0, 26) ddMainF.BackgroundTransparency = 1
local ddTriggerF = Instance.new("TextButton", ddMainF) ddTriggerF.Size = UDim2.new(1, 0, 1, 0) ddTriggerF.BackgroundColor3 = Theme.Bg ddTriggerF.Font = Enum.Font.GothamMedium ddTriggerF.Text = "  🎯 Click Target Selector... ▼" ddTriggerF.TextColor3 = Theme.TextMuted ddTriggerF.TextSize = 10 ddTriggerF.TextXAlignment = Enum.TextXAlignment.Left Instance.new("UICorner", ddTriggerF)
local ddScrollF = Instance.new("ScrollingFrame", MainGui) ddScrollF.Size = UDim2.new(0, 160, 0, 90) ddScrollF.BackgroundColor3 = Theme.CardBg ddScrollF.Visible = false ddScrollF.ZIndex = 999999 Instance.new("UIStroke", ddScrollF).Color = Theme.Accent Instance.new("UIListLayout", ddScrollF)

ddTriggerF.MouseButton1Click:Connect(function()
    ddScrollF.Position = UDim2.new(0, ddTriggerF.AbsolutePosition.X, 0, ddTriggerF.AbsolutePosition.Y + 28)
    for _, c in pairs(ddScrollF:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= Player then
            local b = Instance.new("TextButton", ddScrollF) b.Size = UDim2.new(1, 0, 0, 22) b.BackgroundTransparency = 1 b.Font = Enum.Font.GothamMedium b.Text = " " .. p.Name b.TextColor3 = Theme.TextMain b.TextSize = 10 b.TextXAlignment = Enum.TextXAlignment.Left
            b.MouseButton1Click:Connect(function() funTargetName = p.Name ddTriggerF.Text = "  Target: " .. p.Name .. " ▼" ddScrollF.Visible = false end)
        end
    end
    ddScrollF.Visible = not ddScrollF.Visible
end)

-- FLING ENGINE V3 CORE IMPLEMENTATION
local flingActive = false
local flingConnection
local bV, aV, att

local function cleanFlingParts()
    flingActive = false if flingConnection then flingConnection:Disconnect() flingConnection = nil end
    if bV then bV:Destroy() bV = nil end if aV then aV:Destroy() aV = nil end if att then att:Destroy() att = nil end
    if Player.Character then
        for _, part in pairs(Player.Character:GetChildren()) do if part:IsA("BasePart") then part.CanCollide = true end end
    end
end

local function runTimerFling(targetPlayer)
    if not targetPlayer or not targetPlayer.Character then return end
    local targetHrp = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
    local targetHum = targetPlayer.Character:FindFirstChildOfClass("Humanoid")
    local myHrp = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
    if not targetHrp or not myHrp or not targetHum or targetHum.Health <= 0 then return end
    
    cleanFlingParts() flingActive = true
    bV = Instance.new("BodyVelocity", myHrp) bV.MaxForce = Vector3.new(9e9, 9e9, 9e9) bV.Velocity = Vector3.new(0,0,0)
    aV = Instance.new("AngularVelocity", myHrp) aV.MaxTorque = 9e9 aV.AngularVelocity = Vector3.new(99999, 99999, 99999) aV.RelativeTo = Enum.ActuatorRelativeTo.Attachment0
    att = Instance.new("Attachment", myHrp) aV.Attachment0 = att
    for _, part in pairs(Player.Character:GetChildren()) do if part:IsA("BasePart") then part.CanCollide = false end end
    
    local startTime = tick()
    flingConnection = RunService.Heartbeat:Connect(function()
        local currentHum = targetPlayer.Character and targetPlayer.Character:FindFirstChildOfClass("Humanoid")
        local currentHrp = targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not flingActive or not currentHum or currentHum.Health <= 0 or not currentHrp or (tick() - startTime) >= 3 then
            cleanFlingParts()
            if currentHum and currentHum.Health > 0 and flingActive == false then
                task.wait(0.5) if currentHum.Health > 0 then runTimerFling(targetPlayer) end
            end
            return
        end
        myHrp.CFrame = currentHrp.CFrame * CFrame.new(0, 0, 0.05) bV.Velocity = currentHrp.Velocity
    end)
end

createStandardButton(actSec, "🚀 Fling Target (Brutal Spin v3)", function()
    if funTargetName ~= "" and not flingActive then
        local t = Players:FindFirstChild(funTargetName) if t then runTimerFling(t) end
    end
end)
createStandardButton(actSec, "🛑 Stop Fling (Unfling Manual)", function() cleanFlingParts() end)

createStandardButton(actSec, "🎒 Replicate Target Tools", function()
    if funTargetName ~= "" then
        local t = Players:FindFirstChild(funTargetName) local bp = Player:FindFirstChild("Backpack")
        if t and bp then
            local function cp(o) if o:IsA("Tool") then local nt = o:Clone() nt.Parent = bp end end
            if t.Character then for _, obj in pairs(t.Character:GetChildren()) do cp(obj) end end
            if t:FindFirstChild("Backpack") then for _, obj in pairs(t.Backpack:GetChildren()) do cp(obj) end end
        end
    end
end)

local headSitting = false local headSitC
createToggleSwitch(actSec, "Headsit Target Follower", function(state)
    headSitting = state if headSitC then headSitC:Disconnect() headSitC = nil end
    if not state then if Player.Character and Player.Character:FindFirstChildOfClass("Humanoid") then Player.Character:FindFirstChildOfClass("Humanoid").Sit = false end return end
    headSitC = RunService.Heartbeat:Connect(function()
        if headSitting and funTargetName ~= "" then
            local t = Players:FindFirstChild(funTargetName)
            if t and t.Character and t.Character:FindFirstChild("Head") and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
                Player.Character:FindFirstChildOfClass("Humanoid").Sit = true
                Player.Character.HumanoidRootPart.CFrame = t.Character.Head.CFrame * CFrame.new(0, 1.3, 0)
            end
        end
    end)
end)

local miscSec = createSectionCard(tabs.Utilities.Container, "Map Structural Utility", 65, 3)
createStandardButton(miscSec, "🎒 Sweep Map Tools to Inventory", function()
    local bp = Player:FindFirstChild("Backpack") if bp then for _, o in pairs(workspace:GetDescendants()) do if o:IsA("Tool") then o.Parent = bp end end end
end)

-- ====================================================================
-- TAB 4: SETTINGS MANAGEMENT PANEL
-- ====================================================================
local setSec = createSectionCard(tabs.Settings.Container, "Script Termination", 65, 1)
createStandardButton(setSec, "🔴 Self-Destroy System UI", function()
    cleanFlingParts() if _G.EspAddC then _G.EspAddC:Disconnect() end
    if headSitC then headSitC:Disconnect() end if infJumpConnection then infJumpConnection:Disconnect() end
    if noclipConnection then noclipConnection:Disconnect() end if floatConnection then floatConnection:Disconnect() end
    if floatPart then floatPart:Destroy() end stopFlying() ccScroll:Destroy() ddScrollF:Destroy() MainGui:Destroy()
end)

-- INTRO INVOCATION
task.spawn(function()
    runLoading()
    MainFrame.Visible = true
end)
print("[QUANTUM HUB V5.0]: Interface Optimized and Successfully Deployed.")
