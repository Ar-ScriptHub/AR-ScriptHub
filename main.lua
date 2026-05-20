-- ====================================================================
-- AR SCRIPT HUB - QUANTUM ADMIN HUB (V3.7 - X-RAY UPDATE)
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

-- THEME COLOR PALETTE
local Theme = {
    Bg = Color3.fromRGB(11, 14, 22),       
    CardBg = Color3.fromRGB(18, 22, 32),   
    Stroke = Color3.fromRGB(28, 36, 50),   
    Accent = Color3.fromRGB(0, 230, 160),  
    TextMain = Color3.fromRGB(240, 245, 255),
    TextMuted = Color3.fromRGB(110, 125, 145)
}

_G.BoomboxHistory = _G.BoomboxHistory or {}
local waypointSlots = {Slot1 = nil, Slot2 = nil, Slot3 = nil, Slot4 = nil, Slot5 = nil}
local waypointEspObjects = {} 

-- FUNCTION ESP WAYPOINT CLEANER
local function clearWaypointESP(slotName)
    if waypointEspObjects[slotName] then
        if waypointEspObjects[slotName].Part then waypointEspObjects[slotName].Part:Destroy() end
        waypointEspObjects[slotName] = nil
    end
end

-- FUNCTION ESP WAYPOINT CREATOR
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

-- FLOATING TOGGLE
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
MainFrame.Visible = true 
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)
local mainStroke = Instance.new("UIStroke", MainFrame)
mainStroke.Color = Theme.Stroke
mainStroke.Thickness = 1.5

-- HEADER
local Header = Instance.new("Frame", MainFrame)
Header.Size = UDim2.new(1, 0, 0, 45)
Header.BackgroundTransparency = 1

local Title = Instance.new("TextLabel", Header)
Title.Text = "AR SCRIPT HUB v3.7"
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
    f.CanvasSize = UDim2.new(0, 0, 0, 480) 
    f.ScrollBarThickness = 2
    f.ScrollBarImageColor3 = Theme.Accent
    f.Visible = (name == activeTab)
    tabs[name].Container = f
    local layout = Instance.new("UIListLayout", f)
    layout.Padding = UDim.new(0, 6)
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

-- COMPONENTS FACTORY
local function createToggleSwitch(parent, labelText, callback)
    local card = Instance.new("Frame", parent)
    card.Size = UDim2.new(1, -5, 0, 38) card.BackgroundColor3 = Theme.CardBg
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 6)
    local cStroke = Instance.new("UIStroke", card) cStroke.Color = Theme.Stroke
    
    local lbl = Instance.new("TextLabel", card)
    lbl.Text = "  " .. labelText .. "  " lbl.Size = UDim2.new(0.6, 0, 1, 0)
    lbl.Font = Enum.Font.GothamMedium lbl.TextColor3 = Theme.TextMain lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left lbl.BackgroundTransparency = 1
    
    local bgTrack = Instance.new("TextButton", card)
    bgTrack.Size = UDim2.new(0, 42, 0, 20) bgTrack.Position = UDim2.new(1, -50, 0.5, -10)
    bgTrack.BackgroundColor3 = Theme.Bg bgTrack.Text = ""
    Instance.new("UICorner", bgTrack).CornerRadius = UDim.new(0, 10)
    local tStroke = Instance.new("UIStroke", bgTrack) tStroke.Color = Theme.Stroke
    
    local knob = Instance.new("Frame", bgTrack)
    knob.Size = UDim2.new(0, 14, 0, 14) knob.Position = UDim2.new(0, 3, 0.5, -7)
    knob.BackgroundColor3 = Theme.TextMuted Instance.new("UICorner", knob).CornerRadius = UDim.new(0, 7)
    
    local state = false
    bgTrack.MouseButton1Click:Connect(function()
        state = not state
        local targetX = state and 25 or 3
        local targetTrackColor = state and Theme.Accent or Theme.Bg
        local targetKnobColor = state and Theme.Bg or Theme.TextMuted
        TweenService:Create(knob, TweenInfo.new(0.1), {Position = UDim2.new(0, targetX, 0.5, -7), BackgroundColor3 = targetKnobColor}):Play()
        TweenService:Create(bgTrack, TweenInfo.new(0.1), {BackgroundColor3 = targetTrackColor}):Play()
        tStroke.Color = state and Theme.Accent or Theme.Stroke
        callback(state)
    end)
end

local function createLevelControl(parent, labelText, defaultLvl, min, max, callback)
    local card = Instance.new("Frame", parent)
    card.Size = UDim2.new(1, -5, 0, 38) card.BackgroundColor3 = Theme.CardBg
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 6)
    local cStroke = Instance.new("UIStroke", card) cStroke.Color = Theme.Stroke
    
    local currentLvl = defaultLvl
    local lbl = Instance.new("TextLabel", card)
    lbl.Text = "  " .. labelText .. ": " .. currentLvl lbl.Size = UDim2.new(0.5, 0, 1, 0)
    lbl.Font = Enum.Font.GothamMedium lbl.TextColor3 = Theme.TextMain lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left lbl.BackgroundTransparency = 1
    
    local btnMinus = Instance.new("TextButton", card)
    btnMinus.Text = "–" btnMinus.Size = UDim2.new(0, 24, 0, 24) btnMinus.Position = UDim2.new(1, -32, 0.5, -12)
    btnMinus.BackgroundColor3 = Theme.Bg btnMinus.TextColor3 = Theme.TextMain btnMinus.Font = Enum.Font.GothamMedium
    btnMinus.TextSize = 12 Instance.new("UICorner", btnMinus).CornerRadius = UDim.new(0, 4)
    Instance.new("UIStroke", btnMinus).Color = Theme.Stroke
    
    local btnPlus = Instance.new("TextButton", card)
    btnPlus.Text = "+" btnPlus.Size = UDim2.new(0, 24, 0, 24) btnPlus.Position = UDim2.new(1, -62, 0.5, -12)
    btnPlus.BackgroundColor3 = Theme.Bg btnPlus.TextColor3 = Theme.TextMain btnPlus.Font = Enum.Font.GothamMedium
    btnPlus.TextSize = 12 Instance.new("UICorner", btnPlus).CornerRadius = UDim.new(0, 4)
    Instance.new("UIStroke", btnPlus).Color = Theme.Stroke
    
    btnPlus.MouseButton1Click:Connect(function()
        if currentLvl < max then currentLvl = currentLvl + 1 lbl.Text = "  " .. labelText .. ": " .. currentLvl callback(currentLvl) end
    end)
    btnMinus.MouseButton1Click:Connect(function()
        if currentLvl > min then currentLvl = currentLvl - 1 lbl.Text = "  " .. labelText .. ": " .. currentLvl callback(currentLvl) end
    end)
end

local function createStandardButton(parent, textDisplay, callback)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(1, -5, 0, 36) btn.BackgroundColor3 = Theme.CardBg
    btn.Font = Enum.Font.GothamBold btn.Text = textDisplay btn.TextColor3 = Theme.TextMain btn.TextSize = 12
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    local bStroke = Instance.new("UIStroke", btn) bStroke.Color = Theme.Stroke
    btn.MouseButton1Click:Connect(callback)
end

-- ====================================================================
-- MOVEMENT MECHANICS (FLY, SPEED, NOCLIP, JUMP BYPASS, INF JUMP)
-- ====================================================================
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

createToggleSwitch(tabs.Movement.Container, "Fly Hack", function(v) if v then startFlying() else stopFlying() end end)
createLevelControl(tabs.Movement.Container, "Fly Speed", 5, 1, 20, function(lvl) flyLevel = lvl end)

local walkToggleState = false
local walkLevel = 1
local function updateWalkSpeed()
    local char = Player.Character
    if char and char:FindFirstChildOfClass("Humanoid") then
        char:FindFirstChildOfClass("Humanoid").WalkSpeed = walkToggleState and (walkLevel * 10) or 16
    end
end
createToggleSwitch(tabs.Movement.Container, "WalkSpeed Bypass", function(v) walkToggleState = v updateWalkSpeed() end)
createLevelControl(tabs.Movement.Container, "Walk Speed", 1, 1, 20, function(lvl) walkLevel = lvl updateWalkSpeed() end)

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
createToggleSwitch(tabs.Movement.Container, "JumpPower Bypass", function(v) jumpToggleState = v updateJumpPower() end)
createLevelControl(tabs.Movement.Container, "Jump Power", 5, 1, 20, function(lvl) jumpLevel = lvl updateJumpPower() end)

local infJumpActive = false
local infJumpConnection
createToggleSwitch(tabs.Movement.Container, "Infinite Jump", function(v)
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

local noclipConnection
local noclipActive = false
createToggleSwitch(tabs.Movement.Container, "Noclip", function(v)
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

Player.CharacterAdded:Connect(function(char)
    task.wait(1)
    if walkToggleState then updateWalkSpeed() end
    if jumpToggleState then updateJumpPower() end
end)

-- ====================================================================
-- TELEPORT LOGIC WITH DROPDOWN + ESP WAYPOINT
-- ====================================================================
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

local ddScroll = Instance.new("ScrollingFrame", MainFrame)
ddScroll.Size = UDim2.new(0, 240, 0, 110) ddScroll.Position = UDim2.new(0.3, 0, 0.5, 0)
ddScroll.BackgroundColor3 = Theme.CardBg ddScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
ddScroll.ScrollBarThickness = 3 ddScroll.Visible = false ddScroll.ZIndex = 10
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
            pBtn.TextColor3 = Theme.TextMain pBtn.TextSize = 12 pBtn.TextXAlignment = Enum.TextXAlignment.Left pBtn.ZIndex = 10
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
        if pObj and pObj.Character and pObj.Character:FindFirstChild("HumanoidRootPart") and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
            Player.Character.HumanoidRootPart.CFrame = pObj.Character.HumanoidRootPart.CFrame
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
        if waypointSlots[slotName] and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
            Player.Character.HumanoidRootPart.CFrame = waypointSlots[slotName]
        end
    end)
end
createWaypointUI("Slot1", "Waypoint 1")
createWaypointUI("Slot2", "Waypoint 2")
createWaypointUI("Slot3", "Waypoint 3")
createWaypointUI("Slot4", "Waypoint 4")
createWaypointUI("Slot5", "Waypoint 5")

-- ====================================================================
-- UTILITIES & MASTER TOOLS MECHANICS (HEADSIT, TOOLS, BTOOLS, X-RAY)
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

local ddScrollF = Instance.new("ScrollingFrame", MainFrame)
ddScrollF.Size = UDim2.new(0, 240, 0, 110) ddScrollF.Position = UDim2.new(0.3, 0, 0.5, 0)
ddScrollF.BackgroundColor3 = Theme.CardBg ddScrollF.CanvasSize = UDim2.new(0, 0, 0, 0)
ddScrollF.ScrollBarThickness = 3 ddScrollF.Visible = false ddScrollF.ZIndex = 10
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
            pBtn.TextColor3 = Theme.TextMain pBtn.TextSize = 12 pBtn.TextXAlignment = Enum.TextXAlignment.Left pBtn.ZIndex = 10
            pBtn.MouseButton1Click:Connect(function()
                funTargetName = p.Name ddTriggerF.Text = "  Selected: " .. p.Name .. " ▼" ddScrollF.Visible = false
            end)
        end
    end
    ddScrollF.CanvasSize = UDim2.new(0, 0, 0, count * 28)
end
ddTriggerF.MouseButton1Click:Connect(function() ddScrollF.Visible = not ddScrollF.Visible if ddScrollF.Visible then updateFunDropdown() end end)

createToggleSwitch(tabs.Utilities.Container, "Headsit Target", function(state)
    headSitting = state
    if headSitConnection then headSitConnection:Disconnect() headSitConnection = nil end
    if not state then 
        if Player.Character and Player.Character:FindFirstChildOfClass("Humanoid") then
            Player.Character:FindFirstChildOfClass("Humanoid").Sit = false
        end
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

-- ==========================================
-- ADVANCED X-RAY MECHANIC
-- ==========================================
local xrayActive = false
local originalTransparencies = {}

local function applyXray()
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") or obj:IsA("MeshPart") then
            -- Skip karakter lokal kita biar ga ikut transparan
            if not obj:IsDescendantOf(Player.Character) and not obj:IsDescendantOf(workspace.CurrentCamera) then
                if not originalTransparencies[obj] then
                    originalTransparencies[obj] = obj.Transparency
                end
                obj.Transparency = 0.55 -- Mengubah dinding jadi semi-transparan
            end
        end
    end
end

local function removeXray()
    for obj, trans in pairs(originalTransparencies) do
        if obj and obj.Parent then
            obj.Transparency = trans
        end
    end
    table.clear(originalTransparencies)
end

createToggleSwitch(tabs.Utilities.Container, "X-Ray Vision (Tembus Dinding)", function(state)
    xrayActive = state
    if state then
        applyXray()
        -- Monitor jika ada objek baru yang dirender/spawn oleh map biar ikut tembus pandang
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

createStandardButton(tabs.Utilities.Container, "🎒 Grab All Tools in Map", function()
    local backpack = Player:FindFirstChild("Backpack")
    if backpack then
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("Tool") then obj.Parent = backpack end
        end
    end
end)

createStandardButton(tabs.Utilities.Container, "🔨 Give Classic BTools (Delete)", function()
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

-- ADVANCED BOOMBOX GENERATOR WITH SAVED HISTORY SYSTEM
createStandardButton(tabs.Utilities.Container, "📻 Give Client Boombox", function()
    local backpack = Player:FindFirstChild("Backpack")
    if backpack then
        local boombox = Instance.new("Tool")
        boombox.Name = "Client Boombox"
        boombox.RequiresHandle = false
        
        local sound = Instance.new("Sound")
        sound.Name = "RadioSound"
        sound.Looped = true
        sound.Volume = 2
        
        boombox.Activated:Connect(function()
            if boombox.Parent == Player.Character then
                local hrp = Player.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    sound.Parent = hrp
                    
                    if SafeGuiTarget:FindFirstChild("Quantum_Boombox_Panel") then
                        SafeGuiTarget.Quantum_Boombox_Panel:Destroy()
                    end
                    
                    local bGui = Instance.new("ScreenGui", SafeGuiTarget)
                    bGui.Name = "Quantum_Boombox_Panel"
                    
                    local pnl = Instance.new("Frame", bGui)
                    pnl.Size = UDim2.new(0, 260, 0, 190)
                    pnl.Position = UDim2.new(0.5, -130, 0.4, -95)
                    pnl.BackgroundColor3 = Theme.Bg
                    Instance.new("UICorner", pnl).CornerRadius = UDim.new(0, 10)
                    local pnlStroke = Instance.new("UIStroke", pnl)
                    pnlStroke.Color = Theme.Accent
                    pnlStroke.Thickness = 1.5
                    
                    local headerBar = Instance.new("Frame", pnl)
                    headerBar.Size = UDim2.new(1, 0, 0, 30)
                    headerBar.BackgroundTransparency = 1
                    makeDraggable(pnl, headerBar)
                    
                    local title = Instance.new("TextLabel", headerBar)
                    title.Size = UDim2.new(0.8, 0, 1, 0)
                    title.Position = UDim2.new(0, 10, 0, 0)
                    title.Text = "BOOMBOX CONTROLLER"
                    title.Font = Enum.Font.GothamBold
                    title.TextColor3 = Theme.TextMain
                    title.TextSize = 11
                    title.TextXAlignment = Enum.TextXAlignment.Left
                    title.BackgroundTransparency = 1
                    
                    local cls = Instance.new("TextButton", headerBar)
                    cls.Size = UDim2.new(0, 30, 1, 0)
                    cls.Position = UDim2.new(1, -30, 0, 0)
                    cls.Text = "X"
                    cls.Font = Enum.Font.GothamBold
                    cls.TextColor3 = Theme.TextMuted
                    cls.TextSize = 12
                    cls.BackgroundTransparency = 1
                    cls.MouseButton1Click:Connect(function() bGui:Destroy() end)
                    
                    local box = Instance.new("TextBox", pnl)
                    box.Size = UDim2.new(1, -20, 0, 32)
                    box.Position = UDim2.new(0, 10, 0, 35)
                    box.PlaceholderText = "Paste Audio ID Here..."
                    box.Text = ""
                    box.BackgroundColor3 = Theme.CardBg
                    box.TextColor3 = Theme.TextMain
                    box.Font = Enum.Font.GothamMedium
                    box.TextSize = 12
                    Instance.new("UICorner", box).CornerRadius = UDim.new(0, 5)
                    Instance.new("UIStroke", box).Color = Theme.Stroke
                    
                    local playBtn = Instance.new("TextButton", pnl)
                    playBtn.Size = UDim2.new(1, -20, 0, 32)
                    playBtn.Position = UDim2.new(0, 10, 0, 73)
                    playBtn.Text = "⚡ PLAY AUDIO"
                    playBtn.BackgroundColor3 = Theme.Accent
                    playBtn.TextColor3 = Theme.Bg
                    playBtn.Font = Enum.Font.GothamBold
                    playBtn.TextSize = 12
                    Instance.new("UICorner", playBtn).CornerRadius = UDim.new(0, 5)
                    
                    local histLbl = Instance.new("TextLabel", pnl)
                    histLbl.Size = UDim2.new(1, -20, 0, 15)
                    histLbl.Position = UDim2.new(0, 10, 0, 112)
                    histLbl.Text = "SAVED HISTORY (CLICK TO LOAD):"
                    histLbl.Font = Enum.Font.GothamBold
                    histLbl.TextColor3 = Theme.TextMuted
                    histLbl.TextSize = 9
                    histLbl.TextXAlignment = Enum.TextXAlignment.Left
                    histLbl.BackgroundTransparency = 1
                    
                    local histScroll = Instance.new("ScrollingFrame", pnl)
                    histScroll.Size = UDim2.new(1, -20, 0, 50)
                    histScroll.Position = UDim2.new(0, 10, 0, 130)
                    histScroll.BackgroundTransparency = 1
                    histScroll.ScrollBarThickness = 2
                    histScroll.ScrollBarImageColor3 = Theme.Accent
                    local histLayout = Instance.new("UIListLayout", histScroll)
                    histLayout.Orientation = Enum.Orientation.Horizontal
                    histLayout.Padding = UDim.new(0, 5)
                    
                    local function renderHistory()
                        for _, c in pairs(histScroll:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
                        for i, savedId in ipairs(_G.BoomboxHistory) do
                            local hBtn = Instance.new("TextButton", histScroll)
                            hBtn.Size = UDim2.new(0, 70, 1, 0)
                            hBtn.BackgroundColor3 = Theme.CardBg
                            hBtn.Text = tostring(savedId)
                            hBtn.Font = Enum.Font.GothamMedium
                            hBtn.TextColor3 = Theme.Accent
                            hBtn.TextSize = 10
                            Instance.new("UICorner", hBtn).CornerRadius = UDim.new(0, 4)
                            Instance.new("UIStroke", hBtn).Color = Theme.Stroke
                            
                            hBtn.MouseButton1Click:Connect(function() box.Text = tostring(savedId) end)
                        end
                        histScroll.CanvasSize = UDim2.new(0, #_G.BoomboxHistory * 75, 0, 0)
                    end
                    renderHistory()
                    
                    playBtn.MouseButton1Click:Connect(function()
                        local id = tonumber(box.Text:match("%d+"))
                        if id then
                            sound.SoundId = "rbxassetid://" .. id
                            sound:Play()
                            
                            local exists = false
                            for _, v in pairs(_G.BoomboxHistory) do if v == id then exists = true end end
                            if not exists then
                                table.insert(_G.BoomboxHistory, 1, id)
                                if #_G.BoomboxHistory > 5 then table.remove(_G.BoomboxHistory, 6) end
                                renderHistory()
                            end
                        end
                    end)
                end
            end
        end)
        
        boombox.Unequipped:Connect(function() sound:Stop() end)
        boombox.Parent = backpack
    end
end)

-- ====================================================================
-- SETTING LOGICS
-- ====================================================================
createLevelControl(tabs.Setting.Container, "UI Transparency", 0, 0, 85, function(lvl)
    local trans = lvl / 100 MainFrame.BackgroundTransparency = trans Header.BackgroundTransparency = trans
end)

local unCard = Instance.new("Frame", tabs.Setting.Container)
unCard.Size = UDim2.new(1, -5, 0, 38) unCard.BackgroundColor3 = Color3.fromRGB(35, 15, 20)
Instance.new("UICorner", unCard).CornerRadius = UDim.new(0, 6)
local unStroke = Instance.new("UIStroke", unCard) unStroke.Color = Color3.fromRGB(120, 40, 50)

local btnDestroy = Instance.new("TextButton", unCard)
btnDestroy.Size = UDim2.new(1, 0, 1, 0) btnDestroy.BackgroundTransparency = 1
btnDestroy.Font = Enum.Font.GothamBold btnDestroy.Text = "UNLOAD QUANTUM PANEL"
btnDestroy.TextColor3 = Color3.fromRGB(255, 100, 110) btnDestroy.TextSize = 11
btnDestroy.MouseButton1Click:Connect(function() 
    stopFlying() 
    if infJumpConnection then infJumpConnection:Disconnect() end
    if headSitConnection then headSitConnection:Disconnect() end
    if noclipConnection then noclipConnection:Disconnect() end
    if _G.XrayConnection then _G.XrayConnection:Disconnect() _G.XrayConnection = nil end
    removeXray()
    
    if SafeGuiTarget:FindFirstChild("Quantum_Boombox_Panel") then SafeGuiTarget.Quantum_Boombox_Panel:Destroy() end
    
    local char = Player.Character
    if char and char:FindFirstChildOfClass("Humanoid") then
        local hum = char:FindFirstChildOfClass("Humanoid")
        hum.WalkSpeed = 16
        hum.JumpPower = 50
    end
    
    for slot, _ in pairs(waypointSlots) do clearWaypointESP(slot) end
    MainGui:Destroy() 
end)