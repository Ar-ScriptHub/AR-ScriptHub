-- ====================================================================
-- AR SCRIPT HUB - QUANTUM ADMIN HUB (V4.0 - ADVANCED UPDATE)
-- ====================================================================
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local SafeGuiTarget = Player:FindFirstChildOfClass("PlayerGui") or Player:WaitForChild("PlayerGui", 5)
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- Bersihkan GUI Lama jika ada
if SafeGuiTarget and SafeGuiTarget:FindFirstChild("AR_Quantum_Hub") then
    SafeGuiTarget.AR_Quantum_Hub:Destroy()
end

local MainGui = Instance.new("ScreenGui")
MainGui.Name = "AR_Quantum_Hub"
MainGui.Parent = SafeGuiTarget
MainGui.ResetOnSpawn = false
MainGui.DisplayOrder = 999999999 -- MENJAMIN UI SELALU DI PALING ATAS

-- THEME COLOR PALETTE
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
LoadingPanel.Size = UDim2.new(0, 260, 0, 150)
LoadingPanel.Position = UDim2.new(0.5, -130, 0.5, -75)
LoadingPanel.BackgroundColor3 = Theme.Bg
LoadingPanel.Parent = MainGui
Instance.new("UICorner", LoadingPanel).CornerRadius = UDim.new(0, 10)
local loadStroke = Instance.new("UIStroke", LoadingPanel)
loadStroke.Color = Theme.Stroke
loadStroke.Thickness = 1.5

local LoadLogo = Instance.new("TextLabel", LoadingPanel)
LoadLogo.Size = UDim2.new(1, 0, 0, 50)
LoadLogo.Position = UDim2.new(0, 0, 0, 20)
LoadLogo.Text = "AR"
LoadLogo.Font = Enum.Font.GothamBold
LoadLogo.TextColor3 = Theme.Accent
LoadLogo.TextSize = 36
LoadLogo.BackgroundTransparency = 1

local LoadStatus = Instance.new("TextLabel", LoadingPanel)
LoadStatus.Size = UDim2.new(1, -20, 0, 20)
LoadStatus.Position = UDim2.new(0, 10, 0, 75)
LoadStatus.Text = "Initializing Core..."
LoadStatus.Font = Enum.Font.GothamMedium
LoadStatus.TextColor3 = Theme.TextMuted
LoadStatus.TextSize = 11
LoadStatus.BackgroundTransparency = 1

local BarBg = Instance.new("Frame", LoadingPanel)
BarBg.Size = UDim2.new(1, -40, 0, 4)
BarBg.Position = UDim2.new(0, 20, 0, 105)
BarBg.BackgroundColor3 = Theme.CardBg
BarBg.BorderSizePixel = 0
Instance.new("UICorner", BarBg).CornerRadius = UDim.new(1, 0)

local BarFill = Instance.new("Frame", BarBg)
BarFill.Size = UDim2.new(0, 0, 1, 0)
BarFill.BackgroundColor3 = Theme.Accent
BarFill.BorderSizePixel = 0
Instance.new("UICorner", BarFill).CornerRadius = UDim.new(1, 0)

task.spawn(function()
    while LoadingPanel.Parent and LoadingPanel.Visible do
        TweenService:Create(LoadLogo, TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {TextTransparency = 0.4}):Play()
        task.wait(0.6)
        TweenService:Create(LoadLogo, TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {TextTransparency = 0}):Play()
        task.wait(0.6)
    end
end)

local sequences = {
    {0.20, "Injecting Quantum Engine (v4.0)..."},
    {0.50, "Fixing Tool Replications Engine..."},
    {0.80, "Deploying Safe Fling & ESP Modules..."},
    {1.00, "Ready!"}
}

local function runLoading()
    for _, step in ipairs(sequences) do
        LoadStatus.Text = step[2]
        local fillTween = TweenService:Create(BarFill, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(step[0], 0, 1, 0)})
        fillTween:Play()
        fillTween.Completed:Wait()
        task.wait(0.05)
    end
    task.wait(0.1)
    LoadingPanel:Destroy()
end

-- SYSTEM DATA SETUP
_G.BoomboxHistory = _G.BoomboxHistory or {}
local waypointSlots = {Slot1 = nil, Slot2 = nil, Slot3 = nil, Slot4 = nil, Slot5 = nil}
local waypointEspObjects = {} 

local function clearWaypointESP(slotName)
    if waypointEspObjects[slotName] then
        if waypointEspObjects[slotName].Part then waypointEspObjects[slotName].Part:Destroy() end
        waypointEspObjects[slotName] = nil
    end
end

local function createWaypointESP(slotName, displayName, cframe)
    clearWaypointESP(slotName)
    local espPart = Instance.new("Part")
    espPart.Name = "ESP_" .. slotName
    espPart.Size = Vector3.new(2, 2, 2)
    espPart.CFrame = cframe
    espPart.Anchored = true
    espPart.CanCollide = false
    espPart.Transparency = 1
    espPart.Parent = workspace
    
    local bbGui = Instance.new("BillboardGui")
    bbGui.Name = "WaypointTag"
    bbGui.Size = UDim2.new(0, 120, 0, 40)
    bbGui.AlwaysOnTop = true
    bbGui.ExtentsOffset = Vector3.new(0, 2, 0)
    bbGui.Parent = espPart
    
    local box = Instance.new("Frame")
    box.Size = UDim2.new(0, 10, 0, 10)
    box.Position = UDim2.new(0.5, -5, 0.5, -5)
    box.BackgroundColor3 = Theme.Accent
    box.BorderSizePixel = 0
    box.Parent = bbGui
    Instance.new("UICorner", box).CornerRadius = UDim.new(1, 0)
    
    local txt = Instance.new("TextLabel")
    txt.Size = UDim2.new(1, 0, 0, 20)
    txt.Position = UDim2.new(0, 0, 0, -18)
    txt.BackgroundTransparency = 1
    txt.Text = displayName
    txt.Font = Enum.Font.GothamBold
    txt.TextColor3 = Theme.Accent
    txt.TextSize = 11
    txt.TextStrokeTransparency = 0.4
    txt.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    txt.Parent = bbGui
    
    waypointEspObjects[slotName] = {Part = espPart, Gui = bbGui}
end

-- DRAGGABLE SYSTEM
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

-- FLOATING TOGGLE BUTTON
local ToggleButton = Instance.new("TextButton")
ToggleButton.Name = "ToggleButton"
ToggleButton.Parent = MainGui
ToggleButton.Size = UDim2.new(0, 48, 0, 48)
ToggleButton.Position = UDim2.new(0.05, 0, 0.2, 0)
ToggleButton.BackgroundColor3 = Theme.Bg
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.Text = "AR"
ToggleButton.TextColor3 = Theme.Accent
ToggleButton.TextSize = 18
ToggleButton.Active = true
Instance.new("UICorner", ToggleButton).CornerRadius = UDim.new(0, 10)
local tbStroke = Instance.new("UIStroke", ToggleButton)
tbStroke.Color = Theme.Accent
tbStroke.Thickness = 1.5
makeDraggable(ToggleButton, ToggleButton)

-- MAIN PANEL
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = MainGui
MainFrame.Size = UDim2.new(0, 540, 0, 330)
MainFrame.Position = UDim2.new(0.5, -270, 0.5, -165)
MainFrame.BackgroundColor3 = Theme.Bg
MainFrame.Visible = false 
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)
local mainStroke = Instance.new("UIStroke", MainFrame)
mainStroke.Color = Theme.Stroke
mainStroke.Thickness = 1.5

-- HEADER
local Header = Instance.new("Frame", MainFrame)
Header.Size = UDim2.new(1, 0, 0, 45)
Header.BackgroundTransparency = 1

local Title = Instance.new("TextLabel", Header)
Title.Text = "AR SCRIPT HUB v4.0"
Title.RichText = true
Title.Size = UDim2.new(0.8, 0, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.Font = Enum.Font.GothamBold
Title.TextColor3 = Theme.TextMain
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.BackgroundTransparency = 1

local CloseBtn = Instance.new("TextButton", Header)
CloseBtn.Text = "X"
CloseBtn.Size = UDim2.new(0, 45, 1, 0)
CloseBtn.Position = UDim2.new(1, -45, 0, 0)
CloseBtn.Font = Enum.Font.Arial
CloseBtn.TextColor3 = Theme.TextMuted
CloseBtn.TextSize = 14
CloseBtn.BackgroundTransparency = 1
CloseBtn.MouseEnter:Connect(function() CloseBtn.TextColor3 = Color3.fromRGB(255, 90, 90) end)
CloseBtn.MouseLeave:Connect(function() CloseBtn.TextColor3 = Theme.TextMuted end)

makeDraggable(MainFrame, Header)
ToggleButton.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)
CloseBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false end)

-- SIDEBAR MENU
local NavFrame = Instance.new("Frame", MainFrame)
NavFrame.Size = UDim2.new(0, 100, 1, -45)
NavFrame.Position = UDim2.new(0, 15, 0, 45)
NavFrame.BackgroundTransparency = 1

local ContentFrame = Instance.new("Frame", MainFrame)
ContentFrame.Size = UDim2.new(1, -145, 1, -60)
ContentFrame.Position = UDim2.new(0, 130, 0, 45)
ContentFrame.BackgroundTransparency = 1

local tabs = {Movement = {}, Teleport = {}, Utilities = {}, Setting = {}}
local activeTab = "Movement"

local function createContainer(name)
    local f = Instance.new("ScrollingFrame", ContentFrame)
    f.Size = UDim2.new(1, 0, 1, 0)
    f.BackgroundTransparency = 1
    f.CanvasSize = UDim2.new(0, 0, 0, 550) 
    f.ScrollBarThickness = 2
    f.ScrollBarImageColor3 = Theme.Accent
    f.Visible = (name == activeTab)
    tabs[name].Container = f
    local layout = Instance.new("UIListLayout", f)
    layout.Padding = UDim.new(0, 8)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
end

createContainer("Movement")
createContainer("Teleport")
createContainer("Utilities")
createContainer("Setting")

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
    btn.Size = UDim2.new(1, 0, 0, 32)
    btn.Position = UDim2.new(0, 0, 0, (order - 1) * 36)
    btn.BackgroundTransparency = 1
    btn.Font = (name == activeTab) and Enum.Font.GothamBold or Enum.Font.GothamMedium
    btn.Text = textDisplay
    btn.TextSize = 12
    btn.TextColor3 = (name == activeTab) and Theme.Accent or Theme.TextMuted
    btn.TextXAlignment = Enum.TextXAlignment.Left
    tabs[name].Button = btn
    btn.MouseButton1Click:Connect(function() switchTab(name) end)
end

addTabButton("Movement", "Movement ⚡", 1)
addTabButton("Teleport", "Teleport", 2)
addTabButton("Utilities", "Utilities 🛠️", 3)
addTabButton("Setting", "Settings", 4)

-- SEKAT / CARD SECTION SEPARATOR CREATOR
local function createSectionCard(parent, titleText, height, layoutOrder)
    local section = Instance.new("Frame", parent)
    section.Size = UDim2.new(1, -5, 0, height)
    section.BackgroundColor3 = Theme.CardBg
    section.LayoutOrder = layoutOrder
    Instance.new("UICorner", section).CornerRadius = UDim.new(0, 8)
    local sStroke = Instance.new("UIStroke", section)
    sStroke.Color = Theme.Stroke
    sStroke.Thickness = 1
    
    local sTitle = Instance.new("TextLabel", section)
    sTitle.Size = UDim2.new(1, -10, 0, 22)
    sTitle.Position = UDim2.new(0, 10, 0, 4)
    sTitle.Text = titleText:upper()
    sTitle.Font = Enum.Font.GothamBold
    sTitle.TextColor3 = Theme.TextMuted
    sTitle.TextSize = 10
    sTitle.BackgroundTransparency = 1
    sTitle.TextXAlignment = Enum.TextXAlignment.Left
    
    local container = Instance.new("Frame", section)
    container.Size = UDim2.new(1, -16, 1, -30)
    container.Position = UDim2.new(0, 8, 0, 26)
    container.BackgroundTransparency = 1
    local innerLayout = Instance.new("UIListLayout", container)
    innerLayout.Padding = UDim.new(0, 4)
    innerLayout.SortOrder = Enum.SortOrder.LayoutOrder
    
    return container
end

local function createToggleSwitch(parent, labelText, callback)
    local holder = Instance.new("Frame", parent)
    holder.Size = UDim2.new(1, 0, 0, 32) holder.BackgroundTransparency = 1
    
    local lbl = Instance.new("TextLabel", holder)
    lbl.Text = labelText lbl.Size = UDim2.new(0.6, 0, 1, 0)
    lbl.Font = Enum.Font.GothamMedium lbl.TextColor3 = Theme.TextMain lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left lbl.BackgroundTransparency = 1
    
    local bgTrack = Instance.new("TextButton", holder)
    bgTrack.Size = UDim2.new(0, 38, 0, 18) bgTrack.Position = UDim2.new(1, -38, 0.5, -9)
    bgTrack.BackgroundColor3 = Theme.Bg bgTrack.Text = ""
    Instance.new("UICorner", bgTrack).CornerRadius = UDim.new(0, 9)
    local tStroke = Instance.new("UIStroke", bgTrack) tStroke.Color = Theme.Stroke
    
    local knob = Instance.new("Frame", bgTrack)
    knob.Size = UDim2.new(0, 12, 0, 12) knob.Position = UDim2.new(0, 3, 0.5, -6)
    knob.BackgroundColor3 = Theme.TextMuted Instance.new("UICorner", knob).CornerRadius = UDim.new(0, 6)
    
    local state = false
    bgTrack.MouseButton1Click:Connect(function()
        state = not state
        local targetX = state and 23 or 3
        local targetTrackColor = state and Theme.Accent or Theme.Bg
        local targetKnobColor = state and Theme.Bg or Theme.TextMuted
        TweenService:Create(knob, TweenInfo.new(0.1), {Position = UDim2.new(0, targetX, 0.5, -6), BackgroundColor3 = targetKnobColor}):Play()
        TweenService:Create(bgTrack, TweenInfo.new(0.1), {BackgroundColor3 = targetTrackColor}):Play()
        tStroke.Color = state and Theme.Accent or Theme.Stroke
        callback(state)
    end)
end

local function createLevelControl(parent, labelText, defaultLvl, min, max, callback)
    local holder = Instance.new("Frame", parent)
    holder.Size = UDim2.new(1, 0, 0, 32) holder.BackgroundTransparency = 1
    
    local currentLvl = defaultLvl
    local lbl = Instance.new("TextLabel", holder)
    lbl.Text = labelText .. ": " .. currentLvl lbl.Size = UDim2.new(0.5, 0, 1, 0)
    lbl.Font = Enum.Font.GothamMedium lbl.TextColor3 = Theme.TextMain lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left lbl.BackgroundTransparency = 1
    
    local btnMinus = Instance.new("TextButton", holder)
    btnMinus.Text = "–" btnMinus.Size = UDim2.new(0, 22, 0, 22) btnMinus.Position = UDim2.new(1, -22, 0.5, -11)
    btnMinus.BackgroundColor3 = Theme.Bg btnMinus.TextColor3 = Theme.TextMain btnMinus.Font = Enum.Font.GothamMedium
    btnMinus.TextSize = 12 Instance.new("UICorner", btnMinus).CornerRadius = UDim.new(0, 4)
    Instance.new("UIStroke", btnMinus).Color = Theme.Stroke
    
    local btnPlus = Instance.new("TextButton", holder)
    btnPlus.Text = "+" btnPlus.Size = UDim2.new(0, 22, 0, 22) btnPlus.Position = UDim2.new(1, -48, 0.5, -11)
    btnPlus.BackgroundColor3 = Theme.Bg btnPlus.TextColor3 = Theme.TextMain btnPlus.Font = Enum.Font.GothamMedium
    btnPlus.TextSize = 12 Instance.new("UICorner", btnPlus).CornerRadius = UDim.new(0, 4)
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
    btn.Size = UDim2.new(1, 0, 0, 32) btn.BackgroundColor3 = Theme.Bg
    btn.Font = Enum.Font.GothamBold btn.Text = textDisplay btn.TextColor3 = Theme.TextMain btn.TextSize = 12
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)
    local bStroke = Instance.new("UIStroke", btn) bStroke.Color = Theme.Stroke
    btn.MouseButton1Click:Connect(callback)
end

-- ====================================================================
-- MOVEMENT SECTION INJECTIONS
-- ====================================================================
local noclipSec = createSectionCard(tabs.Movement.Container, "Noclip Core", 65, 1)
local noclipConnection
local noclipActive = false
createToggleSwitch(noclipSec, "Enable Noclip Mode", function(v)
    noclipActive = v
    if v then
        if noclipConnection then noclipConnection:Disconnect() end
        noclipConnection = RunService.Stepped:Connect(function()
            if noclipActive and Player.Character then
                for _, part in pairs(Player.Character:GetChildren()) do
                    if part:IsA("BasePart") then part.CanCollide = false end
                end
            end
        end)
    else
        if noclipConnection then noclipConnection:Disconnect() noclipConnection = nil end
    end
end)

local flySec = createSectionCard(tabs.Movement.Container, "Fly Navigation", 95, 2)
local flying = false
local flyLevel = 5
local bg, bv

local function stopFlying()
    flying = false
    local char = Player.Character
    if bg then bg:Destroy() bg = nil end
    if bv then bv:Destroy() bv = nil end
    if char then
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid:SetStateEnabled(Enum.HumanoidStateType.Flying, false)
            humanoid:ChangeState(Enum.HumanoidStateType.Running)
        end
    end
end

local function startFlying()
    stopFlying()
    local char = Player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local torso = char.HumanoidRootPart
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    flying = true
    bg = Instance.new("BodyGyro", torso) bg.P = 9e4 bg.maxTorque = Vector3.new(9e9, 9e9, 9e9) bg.cframe = torso.CFrame
    bv = Instance.new("BodyVelocity", torso) bv.velocity = Vector3.new(0, 0, 0) bv.maxForce = Vector3.new(9e9, 9e9, 9e9)
    
    task.spawn(function()
        while flying and task.wait() do
            if humanoid and torso and bv and bg then
                humanoid:ChangeState(Enum.HumanoidStateType.Physics)
                local cam = workspace.CurrentCamera
                local speed = flyLevel * 10
                local moveDir = humanoid.MoveDirection
                if moveDir.Magnitude > 0 then
                    local camCF = cam.CFrame
                    local forwardDot = moveDir:Dot(Vector3.new(camCF.LookVector.X, 0, camCF.LookVector.Z).Unit)
                    local rightDot = moveDir:Dot(Vector3.new(camCF.RightVector.X, 0, camCF.RightVector.Z).Unit)
                    local direction = (camCF.LookVector * forwardDot) + (camCF.RightVector * rightDot)
                    bv.velocity = direction.Magnitude > 0 and direction.Unit * speed or Vector3.new(0,0,0)
                else
                    bv.velocity = Vector3.new(0, 0, 0)
                end
                bg.cframe = cam.CFrame
            end
        end
    end)
end
createToggleSwitch(flySec, "Fly Hack Enabled", function(v) if v then startFlying() else stopFlying() end end)
createLevelControl(flySec, "Velocity Speed", 5, 1, 20, function(lvl) flyLevel = lvl end)

-- FITUR PREMIUM BARU: FLOAT ENGINE SYSTEM
local floatSec = createSectionCard(tabs.Movement.Container, "Float Engine (IY Concept)", 65, 3)
local floatActive = false
local floatPart = nil
local floatConnection

local function toggleFloat(state)
    floatActive = state
    local char = Player.Character
    if state then
        if not char or not char:FindFirstChild("HumanoidRootPart") then return end
        local hrp = char.HumanoidRootPart
        floatPart = Instance.new("Part")
        floatPart.Name = "Quantum_FloatPlatform"
        floatPart.Size = Vector3.new(4, 0.5, 4)
        floatPart.Transparency = 1
        floatPart.Anchored = true
        floatPart.CanCollide = true
        floatPart.Parent = workspace
        floatPart.CFrame = hrp.CFrame * CFrame.new(0, -3.25, 0)
        
        floatConnection = RunService.RenderStepped:Connect(function()
            if floatActive and char and char:FindFirstChild("HumanoidRootPart") and floatPart then
                local currentHrp = char.HumanoidRootPart
                floatPart.CFrame = CFrame.new(currentHrp.Position.X, floatPart.Position.Y, currentHrp.Position.Z)
            end
        end)
    else
        if floatConnection then floatConnection:Disconnect() floatConnection = nil end
        if floatPart then floatPart:Destroy() floatPart = nil end
    end
end
createToggleSwitch(floatSec, "Enable Float Melayang", function(state) toggleFloat(state) end)

local wsSec = createSectionCard(tabs.Movement.Container, "Speed Regulation", 95, 4)
local walkToggleState = false
local walkLevel = 1
local function updateWalkSpeed()
    local char = Player.Character
    if char and char:FindFirstChildOfClass("Humanoid") then
        char:FindFirstChildOfClass("Humanoid").WalkSpeed = walkToggleState and (walkLevel * 10) or 16
    end
end
createToggleSwitch(wsSec, "WalkSpeed Bypass", function(v) walkToggleState = v updateWalkSpeed() end)
createLevelControl(wsSec, "Speed Multiplier", 1, 1, 20, function(lvl) walkLevel = lvl updateWalkSpeed() end)

local jumpSec = createSectionCard(tabs.Movement.Container, "Vertical Boosters", 125, 5)
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
createToggleSwitch(jumpSec, "JumpPower Bypass", function(v) jumpToggleState = v updateJumpPower() end)
createLevelControl(jumpSec, "Jump Impulse", 5, 1, 20, function(lvl) jumpLevel = lvl updateJumpPower() end)

local infJumpActive = false
local infJumpConnection
createToggleSwitch(jumpSec, "Infinite Jump Air", function(v)
    infJumpActive = v
    if v then
        if infJumpConnection then infJumpConnection:Disconnect() end
        infJumpConnection = UserInputService.JumpRequest:Connect(function()
            if infJumpActive and Player.Character and Player.Character:FindFirstChildOfClass("Humanoid") then
                Player.Character:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end)
    else
        if infJumpConnection then infJumpConnection:Disconnect() infJumpConnection = nil end
    end
end)

Player.CharacterAdded:Connect(function(char)
    task.wait(1)
    if walkToggleState then updateWalkSpeed() end
    if jumpToggleState then updateJumpPower() end
end)

-- ====================================================================
-- TELEPORT SYSTEM ENGINE
-- ====================================================================
local useTweenTeleport = false
local tpEngineCard = Instance.new("Frame", tabs.Teleport.Container)
tpEngineCard.Size = UDim2.new(1, -5, 0, 38) tpEngineCard.BackgroundColor3 = Theme.CardBg
Instance.new("UICorner", tpEngineCard).CornerRadius = UDim.new(0, 6)
Instance.new("UIStroke", tpEngineCard).Color = Theme.Stroke
local engineHolder = Instance.new("Frame", tpEngineCard)
engineHolder.Size = UDim2.new(1, -16, 1, 0) engineHolder.Position = UDim2.new(0, 8, 0, 0) engineHolder.BackgroundTransparency = 1

createToggleSwitch(engineHolder, "Tween Teleport (Anti-Rubberband)", function(state) useTweenTeleport = state end)

local function masterTeleport(targetCFrame)
    if not Player.Character or not Player.Character:FindFirstChild("HumanoidRootPart") then return end
    local hrp = Player.Character.HumanoidRootPart
    local safeTarget = targetCFrame * CFrame.new(0, 3, 0)
    hrp.Velocity = Vector3.new(0, 0, 0) hrp.RotVelocity = Vector3.new(0, 0, 0)
    if useTweenTeleport then
        local distance = (hrp.Position - safeTarget.Position).Magnitude
        local duration = math.max(distance / 180, 0.2)
        TweenService:Create(hrp, TweenInfo.new(duration, Enum.EasingStyle.Linear), {CFrame = safeTarget}):Play()
    else
        hrp.CFrame = safeTarget
    end
end

-- TELEPORT DROPDOWN
local selectedPlayer = ""
local ddMain = Instance.new("Frame", tabs.Teleport.Container)
ddMain.Size = UDim2.new(1, -5, 0, 42) ddMain.BackgroundTransparency = 1

local ddTrigger = Instance.new("TextButton", ddMain)
ddTrigger.Size = UDim2.new(0.65, 0, 0, 32) ddTrigger.Position = UDim2.new(0, 0, 0.5, -16)
ddTrigger.BackgroundColor3 = Theme.CardBg ddTrigger.Font = Enum.Font.GothamMedium
ddTrigger.Text = "  Select Player Target... ▼" ddTrigger.TextColor3 = Theme.TextMuted
ddTrigger.TextSize = 11 ddTrigger.TextXAlignment = Enum.TextXAlignment.Left
Instance.new("UICorner", ddTrigger).CornerRadius = UDim.new(0, 5)
Instance.new("UIStroke", ddTrigger).Color = Theme.Stroke

local btnTpPlayer = Instance.new("TextButton", ddMain)
btnTpPlayer.Text = "Teleport" btnTpPlayer.Size = UDim2.new(0, 75, 0, 32)
btnTpPlayer.Position = UDim2.new(1, -75, 0.5, -16) btnTpPlayer.BackgroundColor3 = Theme.Bg
btnTpPlayer.TextColor3 = Theme.Accent btnTpPlayer.Font = Enum.Font.GothamBold
Instance.new("UICorner", btnTpPlayer).CornerRadius = UDim.new(0, 4)
Instance.new("UIStroke", btnTpPlayer).Color = Theme.Stroke

local ddScroll = Instance.new("ScrollingFrame", MainGui)
ddScroll.Size = UDim2.new(0, 240, 0, 110) ddScroll.Position = UDim2.new(0.4, 0, 0.45, 0)
ddScroll.BackgroundColor3 = Theme.CardBg ddScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
ddScroll.ScrollBarThickness = 3 ddScroll.Visible = false ddScroll.ZIndex = 999999
Instance.new("UICorner", ddScroll).CornerRadius = UDim.new(0, 6)
Instance.new("UIStroke", ddScroll).Color = Theme.Accent
Instance.new("UIListLayout", ddScroll).SortOrder = Enum.SortOrder.LayoutOrder

local function updateDropdown()
    for _, child in pairs(ddScroll:GetChildren()) do if child:IsA("TextButton") then child:Destroy() end end
    local count = 0
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= Player then
            count = count + 1
            local pBtn = Instance.new("TextButton", ddScroll)
            pBtn.Size = UDim2.new(1, 0, 0, 28) pBtn.BackgroundTransparency = 1
            pBtn.Font = Enum.Font.GothamMedium pBtn.Text = "  " .. p.Name
            pBtn.TextColor3 = Theme.TextMain pBtn.TextSize = 12 pBtn.TextXAlignment = Enum.TextXAlignment.Left pBtn.ZIndex = 999999
            pBtn.MouseButton1Click:Connect(function()
                selectedPlayer = p.Name ddTrigger.Text = "  " .. p.Name .. " ▼" ddScroll.Visible = false
            end)
        end
    end
    ddScroll.CanvasSize = UDim2.new(0, 0, 0, count * 28)
end
ddTrigger.MouseButton1Click:Connect(function() ddScroll.Visible = not ddScroll.Visible if ddScroll.Visible then updateDropdown() end end)
btnTpPlayer.MouseButton1Click:Connect(function()
    if selectedPlayer ~= "" then
        local pObj = Players:FindFirstChild(selectedPlayer)
        if pObj and pObj.Character and pObj.Character:FindFirstChild("HumanoidRootPart") then
            masterTeleport(pObj.Character.HumanoidRootPart.CFrame)
        end
    end
end)

local function createWaypointUI(slotName, displayName)
    local card = Instance.new("Frame", tabs.Teleport.Container)
    card.Size = UDim2.new(1, -5, 0, 38) card.BackgroundColor3 = Theme.CardBg
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 6)
    local cStroke = Instance.new("UIStroke", card) cStroke.Color = Theme.Stroke
    
    local lbl = Instance.new("TextLabel", card)
    lbl.Text = "  " .. displayName lbl.Size = UDim2.new(0.4, 0, 1, 0)
    lbl.Font = Enum.Font.GothamMedium lbl.TextColor3 = Theme.TextMain lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left lbl.BackgroundTransparency = 1
    
    local btnTp = Instance.new("TextButton", card)
    btnTp.Text = "TP" btnTp.Size = UDim2.new(0, 35, 0, 24) btnTp.Position = UDim2.new(1, -42, 0.5, -12)
    btnTp.BackgroundColor3 = Theme.Bg btnTp.TextColor3 = Theme.Accent
    btnTp.Font = Enum.Font.GothamBold Instance.new("UICorner", btnTp).CornerRadius = UDim.new(0, 4)
    Instance.new("UIStroke", btnTp).Color = Theme.Stroke
    
    local btnSave = Instance.new("TextButton", card)
    btnSave.Text = "Save" btnSave.Size = UDim2.new(0, 45, 0, 24) btnSave.Position = UDim2.new(1, -92, 0.5, -12)
    btnSave.BackgroundColor3 = Theme.Bg btnSave.TextColor3 = Theme.Accent
    btnSave.Font = Enum.Font.GothamBold Instance.new("UICorner", btnSave).CornerRadius = UDim.new(0, 4)
    Instance.new("UIStroke", btnSave).Color = Theme.Stroke
    
    btnSave.MouseButton1Click:Connect(function()
        if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
            local currentCF = Player.Character.HumanoidRootPart.CFrame
            waypointSlots[slotName] = currentCF
            createWaypointESP(slotName, displayName, currentCF)
            btnSave.Text = "Saved!" task.delay(1, function() btnSave.Text = "Save" end)
        end
    end)
    btnTp.MouseButton1Click:Connect(function()
        if waypointSlots[slotName] then masterTeleport(waypointSlots[slotName]) end
    end)
end
createWaypointUI("Slot1", "Waypoint 1")
createWaypointUI("Slot2", "Waypoint 2")
createWaypointUI("Slot3", "Waypoint 3")
createWaypointUI("Slot4", "Waypoint 4")
createWaypointUI("Slot5", "Waypoint 5")

-- ====================================================================
-- UTILITIES SYSTEM & NEW PREMIUM INJECTIONS
-- ====================================================================
local funTargetName = ""
local headSitting = false
local headSitConnection

local ddMainF = Instance.new("Frame", tabs.Utilities.Container)
ddMainF.Size = UDim2.new(1, -5, 0, 42) ddMainF.BackgroundTransparency = 1

local ddTriggerF = Instance.new("TextButton", ddMainF)
ddTriggerF.Size = UDim2.new(1, 0, 0, 32) ddTriggerF.Position = UDim2.new(0, 0, 0.5, -16)
ddTriggerF.BackgroundColor3 = Theme.CardBg ddTriggerF.Font = Enum.Font.GothamMedium
ddTriggerF.Text = "  🎯 Select Target... ▼" ddTriggerF.TextColor3 = Theme.TextMuted
ddTriggerF.TextSize = 11 ddTriggerF.TextXAlignment = Enum.TextXAlignment.Left
Instance.new("UICorner", ddTriggerF).CornerRadius = UDim.new(0, 5)
Instance.new("UIStroke", ddTriggerF).Color = Theme.Stroke

local ddScrollF = Instance.new("ScrollingFrame", MainGui)
ddScrollF.Size = UDim2.new(0, 240, 0, 110) ddScrollF.Position = UDim2.new(0.4, 0, 0.45, 0)
ddScrollF.BackgroundColor3 = Theme.CardBg ddScrollF.CanvasSize = UDim2.new(0, 0, 0, 0)
ddScrollF.ScrollBarThickness = 3 ddScrollF.Visible = false ddScrollF.ZIndex = 999999
Instance.new("UICorner", ddScrollF).CornerRadius = UDim.new(0, 6)
Instance.new("UIStroke", ddScrollF).Color = Theme.Accent
Instance.new("UIListLayout", ddScrollF).SortOrder = Enum.SortOrder.LayoutOrder

local function updateFunDropdown()
    for _, child in pairs(ddScrollF:GetChildren()) do if child:IsA("TextButton") then child:Destroy() end end
    local count = 0
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= Player then
            count = count + 1
            local pBtn = Instance.new("TextButton", ddScrollF)
            pBtn.Size = UDim2.new(1, 0, 0, 28) pBtn.BackgroundTransparency = 1
            pBtn.Font = Enum.Font.GothamMedium pBtn.Text = "  " .. p.Name
            pBtn.TextColor3 = Theme.TextMain pBtn.TextSize = 12 pBtn.TextXAlignment = Enum.TextXAlignment.Left pBtn.ZIndex = 999999
            pBtn.MouseButton1Click:Connect(function()
                funTargetName = p.Name ddTriggerF.Text = "  Selected: " .. p.Name .. " ▼" ddScrollF.Visible = false
            end)
        end
    end
    ddScrollF.CanvasSize = UDim2.new(0, 0, 0, count * 28)
end
ddTriggerF.MouseButton1Click:Connect(function() ddScrollF.Visible = not ddScrollF.Visible if ddScrollF.Visible then updateFunDropdown() end end)

local actionSec = createSectionCard(tabs.Utilities.Container, "Target Interaction", 145, 1)

local function rebuildAndInjectTool(originalTool, destination)
    local nt = originalTool:Clone()
    nt.Activated:Connect(function()
        if nt:FindFirstChild("RemoteEvent") then nt.RemoteEvent:FireServer() end
    end)
    if nt:FindFirstChild("Handle") then
        nt.Handle.Anchored = false
        local touchTrans = nt.Handle:FindFirstChildOfClass("TouchTransmitter")
        if touchTrans then touchTrans:Destroy() end
    end
    nt.Parent = destination
end

createStandardButton(actionSec, "🎒 Copy Target Tools", function()
    if funTargetName ~= "" then
        local target = Players:FindFirstChild(funTargetName)
        local myBackpack = Player:FindFirstChild("Backpack")
        if target and myBackpack then
            local copiedCount = 0
            if target.Character then
                for _, obj in pairs(target.Character:GetChildren()) do
                    if obj:IsA("Tool") then rebuildAndInjectTool(obj, myBackpack) copiedCount = copiedCount + 1 end
                end
            end
            if target:FindFirstChild("Backpack") then
                for _, obj in pairs(target.Backpack:GetChildren()) do
                    if obj:IsA("Tool") then rebuildAndInjectTool(obj, myBackpack) copiedCount = copiedCount + 1 end
                end
            end
        end
    end
end)

-- FITUR PREMIUM BARU: FLING ENGINE V2 (TIMER 3 DETIK & AUTO-CUT ANTI CRASH)
local flingActive = false
local flingConnection
local function runTimerFling(targetPlayer)
    if not targetPlayer or not targetPlayer.Character then return end
    local targetChar = targetPlayer.Character
    local targetHrp = targetChar:FindFirstChild("HumanoidRootPart")
    local targetHum = targetChar:FindFirstChildOfClass("Humanoid")
    local myChar = Player.Character
    local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
    
    if not targetHrp or not myHrp or not targetHum or targetHum.Health <= 0 then return end
    flingActive = true
    
    local bV = Instance.new("BodyVelocity", myHrp)
    bV.MaxForce = Vector3.new(9e9, 9e9, 9e9) bV.Velocity = Vector3.new(0, 0, 0)
    local aV = Instance.new("AngularVelocity", myHrp)
    aV.MaxTorque = 9e9 aV.AngularVelocity = Vector3.new(0, 99999, 0) aV.RelativeTo = Enum.ActuatorRelativeTo.Attachment0
    local att = Instance.new("Attachment", myHrp) aV.Attachment0 = att
    
    for _, part in pairs(myChar:GetChildren()) do if part:IsA("BasePart") then part.CanCollide = false end end
    local startTime = tick()
    
    flingConnection = RunService.Heartbeat:Connect(function()
        local currentHum = targetPlayer.Character and targetPlayer.Character:FindFirstChildOfClass("Humanoid")
        local currentHrp = targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart")
        local timeElapsed = tick() - startTime
        
        if not flingActive or not currentHum or currentHum.Health <= 0 or not currentHrp or timeElapsed >= 3 then
            if flingConnection then flingConnection:Disconnect() flingConnection = nil end
            flingActive = false
            if bV then bV:Destroy() end if aV then aV:Destroy() end if att then att:Destroy() end
            
            if currentHum and currentHum.Health > 0 and flingActive == false then
                task.wait(1)
                if currentHum.Health > 0 then runTimerFling(targetPlayer) end
            end
            return
        end
        myHrp.CFrame = currentHrp.CFrame * CFrame.new(0, 0, 0.1)
        bV.Velocity = currentHrp.Velocity
    end)
end

createStandardButton(actionSec, "🚀 Fling Target (Timer & Auto-Cut)", function()
    if funTargetName ~= "" and not flingActive then
        local target = Players:FindFirstChild(funTargetName)
        if target then runTimerFling(target) end
    end
end)

createToggleSwitch(actionSec, "Headsit Target", function(state)
    headSitting = state
    if headSitConnection then headSitConnection:Disconnect() headSitConnection = nil end
    if not state then 
        if Player.Character and Player.Character:FindFirstChildOfClass("Humanoid") then Player.Character:FindFirstChildOfClass("Humanoid").Sit = false end
        return 
    end
    headSitConnection = RunService.Heartbeat:Connect(function()
        if headSitting and funTargetName ~= "" then
            local targetPlayer = Players:FindFirstChild(funTargetName)
            if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("Head") and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
                local myHum = Player.Character:FindFirstChildOfClass("Humanoid")
                if myHum then myHum.Sit = true end
                Player.Character.HumanoidRootPart.CFrame = targetPlayer.Character.Head.CFrame * CFrame.new(0, 1.3, 0)
            end
        end
    end)
end)

-- SEKAT UNTUK MAP VISUAL & ESP HACKS
local visualSec = createSectionCard(tabs.Utilities.Container, "Visual & ESP Hacks", 175, 2)
local xrayActive = false
local originalTransparencies = {}

local function applyXray()
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") or obj:IsA("MeshPart") then
            if not obj:IsDescendantOf(Player.Character) and not obj:IsDescendantOf(workspace.CurrentCamera) then
                if not originalTransparencies[obj] then originalTransparencies[obj] = obj.Transparency end
                obj.Transparency = 0.55
            end
        end
    end
end

local function removeXray()
    for obj, trans in pairs(originalTransparencies) do if obj and obj.Parent then obj.Transparency = trans end end
    table.clear(originalTransparencies)
end

createToggleSwitch(visualSec, "X-Ray Vision (Transparan)", function(state)
    xrayActive = state
    if state then
        applyXray()
        _G.XrayConnection = workspace.DescendantAdded:Connect(function(obj)
            if xrayActive and (obj:IsA("BasePart") or obj:IsA("MeshPart")) then
                task.wait()
                if not obj:IsDescendantOf(Player.Character) then
                    originalTransparencies[obj] = obj.Transparency
                    obj.Transparency = 0.55
                end
            end
        end)
    else
        if _G.XrayConnection then _G.XrayConnection:Disconnect() _G.XrayConnection = nil end
        removeXray()
    end
end)

-- FITUR PREMIUM BARU: HIGHLIGHT WALLHACK ESP
local EspActive = false
local EspObjects = {}
local function applyEspToCharacter(targetPlayer, char)
    if targetPlayer == Player or not char then return end
    if EspObjects[targetPlayer.Name] then EspObjects[targetPlayer.Name]:Destroy() EspObjects[targetPlayer.Name] = nil end
    local highlight = Instance.new("Highlight")
    highlight.Name = "Quantum_ESP_" .. targetPlayer.Name
    highlight.FillColor = Theme.Accent highlight.FillTransparency = 0.5
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255) highlight.OutlineTransparency = 0.2
    highlight.Adornee = char highlight.Parent = MainGui
    EspObjects[targetPlayer.Name] = highlight
end

local function togglePlayerEsp(state)
    EspActive = state
    if state then
        for _, p in pairs(Players:GetPlayers()) do
            if p.Character then applyEspToCharacter(p, p.Character) end
            p.CharacterAdded:Connect(function(newChar) if EspActive then task.wait(0.5) applyEspToCharacter(p, newChar) end end)
        end
        _G.EspPlayerJoinConnection = Players.PlayerAdded:Connect(function(p)
            p.CharacterAdded:Connect(function(newChar) if EspActive then task.wait(0.5) applyEspToCharacter(p, newChar) end end)
        end)
    else
        if _G.EspPlayerJoinConnection then _G.EspPlayerJoinConnection:Disconnect() _G.EspPlayerJoinConnection = nil end
        for name, obj in pairs(EspObjects) do if obj then obj:Destroy() end end
        table.clear(EspObjects)
    end
end
createToggleSwitch(visualSec, "Player ESP (Wallhack)", function(state) togglePlayerEsp(state) end)

createStandardButton(visualSec, "🎒 Grab All Tools in Map", function()
    local backpack = Player:FindFirstChild("Backpack")
    if backpack then
        for _, obj in pairs(workspace:GetDescendants()) do if obj:IsA("Tool") then obj.Parent = backpack end end
    end
end)

createStandardButton(visualSec, "🔨 Give Classic BTools (Delete)", function()
    local backpack = Player:FindFirstChild("Backpack")
    if backpack then
        local btool = Instance.new("Tool")
        btool.Name = "Quantum BTool (Delete)"
        btool.RequiresHandle = false
        btool.Activated:Connect(function()
            local mouse = Player:GetMouse()
            if mouse.Target and mouse.Target ~= workspace then mouse.Target:Destroy() end
        end)
        btool.Parent = backpack
    end
end)

-- ====================================================================
-- SETTINGS PANEL SYSTEM CLOSING
-- ====================================================================
createStandardButton(tabs.Setting.Container, "🔴 Destroy Quantum Hub UI", function()
    if _G.XrayConnection then _G.XrayConnection:Disconnect() _G.XrayConnection = nil end
    if _G.EspPlayerJoinConnection then _G.EspPlayerJoinConnection:Disconnect() _G.EspPlayerJoinConnection = nil end
    for name, obj in pairs(EspObjects) do if obj then obj:Destroy() end end
    if headSitConnection then headSitConnection:Disconnect() headSitConnection = nil end
    if infJumpConnection then infJumpConnection:Disconnect() infJumpConnection = nil end
    if noclipConnection then noclipConnection:Disconnect() noclipConnection = nil end
    if floatConnection then floatConnection:Disconnect() floatConnection = nil end
    if floatPart then floatPart:Destroy() end
    stopFlying()
    for slot, _ in pairs(waypointSlots) do clearWaypointESP(slot) end
    ddScroll:Destroy() ddScrollF:Destroy() MainGui:Destroy()
end)

createStandardButton(tabs.Setting.Container, "🔄 Re-Load UI Script", function()
    ddScroll:Destroy() ddScrollF:Destroy() MainGui:Destroy()
    task.wait(0.2)
    loadstring(game:HttpGet("https://raw.githubusercontent.com/Ar-ScriptHub/AR-ScriptHub/refs/heads/main/main.lua"))()
end)

-- EXECUTE INTRO LOAD ANIMATION
task.spawn(function()
    runLoading()
    MainFrame.Visible = true 
end)

print("[QUANTUM HUB V4.0]: All Premium Modules Successfully Deployed.")
