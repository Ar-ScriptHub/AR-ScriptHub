-- ====================================================================
-- AR SCRIPT HUB - PREMIUM VERSION v6.0 (FLUENT LAYOUT & COMBAT UPDATE)
-- ====================================================================
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local SafeGuiTarget = Player:FindFirstChildOfClass("PlayerGui") or Player:WaitForChild("PlayerGui", 5)
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

-- Bersihkan GUI Lama
if SafeGuiTarget and SafeGuiTarget:FindFirstChild("AR_Script_Hub") then
    SafeGuiTarget.AR_Script_Hub:Destroy()
end

local MainGui = Instance.new("ScreenGui")
MainGui.Name = "AR_Script_Hub"
MainGui.Parent = SafeGuiTarget
MainGui.ResetOnSpawn = false
MainGui.DisplayOrder = 999999999

-- PREMIUM DARK PALETTE (DEPROXWARE INSPIRED)
local Theme = {
    Bg = Color3.fromRGB(16, 16, 24),         
    BgTrans = 0.15,                          
    CardBg = Color3.fromRGB(24, 24, 37),     
    CardTrans = 0.3,                         
    Stroke = Color3.fromRGB(45, 45, 68),     
    Accent = Color3.fromRGB(0, 180, 216),    -- Neon Cyan 
    AccentPurple = Color3.fromRGB(139, 92, 246), -- Electric Violet
    TextMain = Color3.fromRGB(255, 255, 255),
    TextMuted = Color3.fromRGB(156, 163, 175),
    Hover = Color3.fromRGB(34, 34, 49)
}

-- GLOBAL VARIABLES
local GlobalTargetName = ""
local UseTweenTeleport = false
local noclipActive, floatActive, flying, infJumpActive = false, false, false, false
local damageAuraActive = false
local damageAuraRadius = 15
local noclipConnection, floatConnection, flyConnection, infJumpConnection, headSitC, flingConnection, damageAuraConnection
local floatPart, bg, bv
local walkToggleState, walkLevel, jumpToggleState, jumpLevel = false, 1, false, 5

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

-- FLOATING TOGGLE BUTTON
local ToggleButton = Instance.new("TextButton")
ToggleButton.Name = "ToggleButton"
ToggleButton.Parent = MainGui
ToggleButton.Size = UDim2.new(0, 50, 0, 50)
ToggleButton.Position = UDim2.new(0.02, 0, 0.2, 0)
ToggleButton.BackgroundColor3 = Theme.Bg
ToggleButton.BackgroundTransparency = 0.2
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.Text = "AR"
ToggleButton.TextColor3 = Theme.Accent
ToggleButton.TextSize = 16
Instance.new("UICorner", ToggleButton).CornerRadius = UDim.new(0, 12)
local tbStroke = Instance.new("UIStroke", ToggleButton)
tbStroke.Color = Theme.Accent
makeDraggable(ToggleButton, ToggleButton)

-- MAIN PANEL
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = MainGui
MainFrame.Size = UDim2.new(0, 520, 0, 390)
MainFrame.Position = UDim2.new(0.5, -260, 0.5, -195)
MainFrame.BackgroundColor3 = Theme.Bg
MainFrame.BackgroundTransparency = Theme.BgTrans
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 14)
local mainStroke = Instance.new("UIStroke", MainFrame)
mainStroke.Color = Theme.Stroke
mainStroke.Thickness = 1.5

-- HEADER WITH SEARCH / TITLE
local Header = Instance.new("Frame", MainFrame)
Header.Size = UDim2.new(1, 0, 0, 50)
Header.BackgroundTransparency = 1

local Title = Instance.new("TextLabel", Header)
Title.Text = "✨ <b>AR SCRIPT HUB</b> <font color='#8b5cf6'>PREMIUM v6.0</font>"
Title.RichText = true
Title.Size = UDim2.new(0.7, 0, 1, 0)
Title.Position = UDim2.new(0, 18, 0, 0)
Title.Font = Enum.Font.GothamMedium
Title.TextColor3 = Theme.TextMain
Title.TextSize = 15
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.BackgroundTransparency = 1

local CloseBtn = Instance.new("TextButton", Header)
CloseBtn.Text = "×"
CloseBtn.Size = UDim2.new(0, 50, 1, 0)
CloseBtn.Position = UDim2.new(1, -50, 0, 0)
CloseBtn.Font = Enum.Font.GothamMedium
CloseBtn.TextColor3 = Theme.TextMuted
CloseBtn.TextSize = 26
CloseBtn.BackgroundTransparency = 1
CloseBtn.MouseEnter:Connect(function() TweenService:Create(CloseBtn, TweenInfo.new(0.1), {TextColor3 = Color3.fromRGB(239, 68, 68)}):Play() end)
CloseBtn.MouseLeave:Connect(function() TweenService:Create(CloseBtn, TweenInfo.new(0.1), {TextColor3 = Theme.TextMuted}):Play() end)

makeDraggable(MainFrame, Header)
ToggleButton.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)
CloseBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false end)

-- LAYOUT SIDEBAR (LEFT NAV)
local NavFrame = Instance.new("Frame", MainFrame)
NavFrame.Size = UDim2.new(0, 130, 1, -65)
NavFrame.Position = UDim2.new(0, 12, 0, 55)
NavFrame.BackgroundTransparency = 1

local ContentFrame = Instance.new("Frame", MainFrame)
ContentFrame.Size = UDim2.new(1, -164, 1, -65)
ContentFrame.Position = UDim2.new(0, 152, 0, 55)
ContentFrame.BackgroundTransparency = 1

local tabs = {Combat = {}, Player = {}, ESP = {}, Teleport = {}, World = {}, Utilities = {}, Settings = {}}
local activeTab = "Combat"

local function createContainer(name)
    local f = Instance.new("ScrollingFrame", ContentFrame)
    f.Size = UDim2.new(1, 0, 1, 0)
    f.BackgroundTransparency = 1
    f.CanvasSize = UDim2.new(0, 0, 0, 0)
    f.AutomaticCanvasSize = Enum.AutomaticSize.Y
    f.ScrollBarThickness = 2
    f.ScrollBarImageColor3 = Theme.Accent
    f.Visible = (name == activeTab)
    tabs[name].Container = f
    
    local layout = Instance.new("UIListLayout", f)
    layout.Padding = UDim.new(0, 10)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
end

local tabList = {"Combat", "Player", "ESP", "Teleport", "World", "Utilities", "Settings"}
local tabIcons = {Combat="⚔️ Combat", Player="👤 Player", ESP="👁️ ESP Visual", Teleport="🌀 Teleport", World="🌐 World Server", Utilities="🛠️ Utilities", Settings="⚙️ Settings"}

for _, name in ipairs(tabList) do createContainer(name) end

local function switchTab(tabName)
    activeTab = tabName
    for k, v in pairs(tabs) do
        v.Container.Visible = (k == tabName)
        if v.Button then
            if k == tabName then
                TweenService:Create(v.Button, TweenInfo.new(0.15), {TextColor3 = Theme.Accent, BackgroundColor3 = Theme.Hover, BackgroundTransparency = 0.5}):Play()
                v.Button.Indicator.Visible = true
            else
                TweenService:Create(v.Button, TweenInfo.new(0.15), {TextColor3 = Theme.TextMuted, BackgroundColor3 = Theme.Bg, BackgroundTransparency = 1}):Play()
                v.Button.Indicator.Visible = false
            end
        end
    end
end

local function addTabButton(name, textDisplay, order)
    local btn = Instance.new("TextButton", NavFrame)
    btn.Size = UDim2.new(1, 0, 0, 34)
    btn.Position = UDim2.new(0, 0, 0, (order - 1) * 38)
    btn.BackgroundTransparency = 1
    btn.BackgroundColor3 = Theme.Hover
    btn.Font = Enum.Font.GothamMedium
    btn.Text = "   " .. textDisplay
    btn.TextSize = 12
    btn.TextColor3 = Theme.TextMuted
    btn.TextXAlignment = Enum.TextXAlignment.Left
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    
    local ind = Instance.new("Frame", btn)
    ind.Name = "Indicator"
    ind.Size = UDim2.new(0, 3, 0, 16)
    ind.Position = UDim2.new(0, 2, 0.5, -8)
    ind.BackgroundColor3 = Theme.Accent
    ind.Visible = false
    Instance.new("UICorner", ind).CornerRadius = UDim.new(0, 2)

    tabs[name].Button = btn
    btn.MouseButton1Click:Connect(function() switchTab(name) end)
end

for i, name in ipairs(tabList) do addTabButton(name, tabIcons[name], i) end
switchTab("Combat")

-- LAYOUT COMPONENTS GENERATOR (CARD DESIGN)
local function createSectionCard(parent, titleText, layoutOrder)
    local section = Instance.new("Frame", parent)
    section.Size = UDim2.new(1, -6, 0, 0)
    section.AutomaticSize = Enum.AutomaticSize.Y 
    section.BackgroundColor3 = Theme.CardBg
    section.BackgroundTransparency = Theme.CardTrans
    section.LayoutOrder = layoutOrder
    Instance.new("UICorner", section).CornerRadius = UDim.new(0, 8)
    local sStroke = Instance.new("UIStroke", section)
    sStroke.Color = Theme.Stroke
    
    local sTitle = Instance.new("TextLabel", section)
    sTitle.Size = UDim2.new(1, -12, 0, 26)
    sTitle.Position = UDim2.new(0, 12, 0, 6)
    sTitle.Text = titleText:upper()
    sTitle.Font = Enum.Font.GothamBold
    sTitle.TextColor3 = Theme.AccentPurple
    sTitle.TextSize = 10
    sTitle.BackgroundTransparency = 1
    sTitle.TextXAlignment = Enum.TextXAlignment.Left
    
    local container = Instance.new("Frame", section)
    container.Size = UDim2.new(1, -24, 0, 0)
    container.Position = UDim2.new(0, 12, 0, 36)
    container.BackgroundTransparency = 1
    container.AutomaticSize = Enum.AutomaticSize.Y
    
    local innerLayout = Instance.new("UIListLayout", container)
    innerLayout.Padding = UDim.new(0, 10)
    innerLayout.SortOrder = Enum.SortOrder.LayoutOrder
    
    local padding = Instance.new("UIPadding", container)
    padding.PaddingBottom = UDim.new(0, 12)

    return container
end

local function createToggleSwitch(parent, labelText, callback)
    local holder = Instance.new("Frame", parent)
    holder.Size = UDim2.new(1, 0, 0, 30) holder.BackgroundTransparency = 1
    
    local lbl = Instance.new("TextLabel", holder)
    lbl.Text = labelText lbl.Size = UDim2.new(0.7, 0, 1, 0)
    lbl.Font = Enum.Font.GothamMedium lbl.TextColor3 = Theme.TextMain lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left lbl.BackgroundTransparency = 1
    
    local bgTrack = Instance.new("TextButton", holder)
    bgTrack.Size = UDim2.new(0, 36, 0, 20) bgTrack.Position = UDim2.new(1, -36, 0.5, -10)
    bgTrack.BackgroundColor3 = Color3.fromRGB(30, 30, 45) bgTrack.Text = ""
    Instance.new("UICorner", bgTrack).CornerRadius = UDim.new(0, 10)
    local tStroke = Instance.new("UIStroke", bgTrack) tStroke.Color = Theme.Stroke
    
    local knob = Instance.new("Frame", bgTrack)
    knob.Size = UDim2.new(0, 14, 0, 14) knob.Position = UDim2.new(0, 3, 0.5, -7)
    knob.BackgroundColor3 = Theme.TextMuted Instance.new("UICorner", knob).CornerRadius = UDim.new(0, 7)
    
    local state = false
    bgTrack.MouseButton1Click:Connect(function()
        state = not state
        local targetX = state and 19 or 3
        local targetTrackColor = state and Theme.Accent or Color3.fromRGB(30, 30, 45)
        local targetKnobColor = state and Color3.fromRGB(16, 16, 24) or Theme.TextMuted
        TweenService:Create(knob, TweenInfo.new(0.12, Enum.EasingStyle.Quad), {Position = UDim2.new(0, targetX, 0.5, -7), BackgroundColor3 = targetKnobColor}):Play()
        TweenService:Create(bgTrack, TweenInfo.new(0.12, Enum.EasingStyle.Quad), {BackgroundColor3 = targetTrackColor}):Play()
        tStroke.Color = state and Theme.Accent or Theme.Stroke
        callback(state)
    end)
end

local function createLevelControl(parent, labelText, defaultLvl, min, max, callback)
    local holder = Instance.new("Frame", parent)
    holder.Size = UDim2.new(1, 0, 0, 30) holder.BackgroundTransparency = 1
    
    local currentLvl = defaultLvl
    local lbl = Instance.new("TextLabel", holder)
    lbl.Text = labelText .. ": <font color='#00b4d8'>" .. currentLvl .. "</font>" lbl.Size = UDim2.new(0.6, 0, 1, 0)
    lbl.RichText = true
    lbl.Font = Enum.Font.GothamMedium lbl.TextColor3 = Theme.TextMain lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left lbl.BackgroundTransparency = 1
    
    local btnMinus = Instance.new("TextButton", holder)
    btnMinus.Text = "–" btnMinus.Size = UDim2.new(0, 24, 0, 22) btnMinus.Position = UDim2.new(1, -24, 0.5, -11)
    btnMinus.BackgroundColor3 = Color3.fromRGB(30, 30, 45) btnMinus.TextColor3 = Theme.TextMain btnMinus.Font = Enum.Font.GothamBold
    btnMinus.TextSize = 12 Instance.new("UICorner", btnMinus).CornerRadius = UDim.new(0, 5)
    Instance.new("UIStroke", btnMinus).Color = Theme.Stroke
    
    local btnPlus = Instance.new("TextButton", holder)
    btnPlus.Text = "+" btnPlus.Size = UDim2.new(0, 24, 0, 22) btnPlus.Position = UDim2.new(1, -54, 0.5, -11)
    btnPlus.BackgroundColor3 = Color3.fromRGB(30, 30, 45) btnPlus.TextColor3 = Theme.TextMain btnPlus.Font = Enum.Font.GothamBold
    btnPlus.TextSize = 12 Instance.new("UICorner", btnPlus).CornerRadius = UDim.new(0, 5)
    Instance.new("UIStroke", btnPlus).Color = Theme.Stroke
    
    btnPlus.MouseButton1Click:Connect(function()
        if currentLvl < max then currentLvl = currentLvl + 1 lbl.Text = labelText .. ": <font color='#00b4d8'>" .. currentLvl .. "</font>" callback(currentLvl) end
    end)
    btnMinus.MouseButton1Click:Connect(function()
        if currentLvl > min then currentLvl = currentLvl - 1 lbl.Text = labelText .. ": <font color='#00b4d8'>" .. currentLvl .. "</font>" callback(currentLvl) end
    end)
end

local function createStandardButton(parent, textDisplay, callback)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(1, 0, 0, 30) btn.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
    btn.Font = Enum.Font.GothamMedium btn.Text = textDisplay btn.TextColor3 = Theme.TextMain btn.TextSize = 12
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    local bStroke = Instance.new("UIStroke", btn) bStroke.Color = Theme.Stroke
    
    btn.MouseEnter:Connect(function() TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = Theme.Hover}):Play() end)
    btn.MouseLeave:Connect(function() TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(30, 30, 45)}):Play() end)
    btn.MouseButton1Click:Connect(callback)
end

local function executeTeleport(targetCFrame)
    local char = Player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    if UseTweenTeleport then
        local distance = (hrp.Position - targetCFrame.Position).Magnitude
        local tween = TweenService:Create(hrp, TweenInfo.new(distance / 250, Enum.EasingStyle.Linear), {CFrame = targetCFrame})
        tween:Play()
    else hrp.CFrame = targetCFrame end
end

local function stopFlying()
    flying = false if bg then bg:Destroy() bg = nil end if bv then bv:Destroy() bv = nil end
    local hum = Player.Character and Player.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum:SetStateEnabled(Enum.HumanoidStateType.Flying, false) hum:ChangeState(Enum.HumanoidStateType.Running) end
end

local function cleanFlingParts()
    flingActive = false if flingConnection then flingConnection:Disconnect() flingConnection = nil end
    if bV then bV:Destroy() bV = nil end if aV then aV:Destroy() aV = nil end if att then att:Destroy() att = nil end
    if Player.Character then for _, part in pairs(Player.Character:GetChildren()) do if part:IsA("BasePart") then part.CanCollide = true end end end
end

-- ====================================================================
-- TAB 1: COMBAT MODULE
-- ====================================================================
local combatSec = createSectionCard(tabs.Combat.Container, "Automated Combat Aura", 1)
local remoteNames = {"Damage", "Hit", "Attack", "Activate", "Swing", "RemoteEvent"}

local function getWeaponRemote(tool)
    for _, name in pairs(remoteNames) do
        local remote = tool:FindFirstChild(name) or tool:FindFirstChildOfClass("RemoteEvent")
        if remote and remote:IsA("RemoteEvent") then return remote end
    end
    return nil
end

createToggleSwitch(combatSec, "Enable Damage Aura", function(state)
    damageAuraActive = state
    if state then
        if damageAuraConnection then damageAuraConnection:Disconnect() end
        damageAuraConnection = RunService.Heartbeat:Connect(function()
            local myChar = Player.Character
            local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
            local activeTool = myChar and myChar:FindFirstChildOfClass("Tool")
            if not damageAuraActive or not myHrp or not activeTool then return end
            local damageRemote = getWeaponRemote(activeTool)
            if not damageRemote then return end
            
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= Player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChildOfClass("Humanoid") then
                    local targetHrp = p.Character.HumanoidRootPart
                    local targetHum = p.Character:FindFirstChildOfClass("Humanoid")
                    if targetHum.Health > 0 and (myHrp.Position - targetHrp.Position).Magnitude <= damageAuraRadius then
                        damageRemote:FireServer(targetHrp, targetHrp.Position)
                        damageRemote:FireServer(targetHum)
                    end
                end
            end
        end)
    else if damageAuraConnection then damageAuraConnection:Disconnect() damageAuraConnection = nil end end
end)

createLevelControl(combatSec, "Aura Area Radius", 15, 5, 100, function(lvl) damageAuraRadius = lvl end)

-- ====================================================================
-- TAB 2: PLAYER MODIFIERS
-- ====================================================================
local pExtraNav = createSectionCard(tabs.Player.Container, "Ghost Environment Bypass", 1)
createToggleSwitch(pExtraNav, "Noclip (Safe Ghost Pass)", function(v)
    noclipActive = v
    if v then
        if noclipConnection then noclipConnection:Disconnect() end
        noclipConnection = RunService.Stepped:Connect(function()
            if noclipActive and Player.Character then 
                for _, p in pairs(Player.Character:GetDescendants()) do if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then p.CanCollide = false end end 
            end
        end)
    else if noclipConnection then noclipConnection:Disconnect() noclipConnection = nil end end
end)

createToggleSwitch(pExtraNav, "Float Platform Stabilizer", function(state)
    floatActive = state local char = Player.Character
    if state then
        if not char or not char:FindFirstChild("HumanoidRootPart") then return end
        floatPart = Instance.new("Part", workspace) floatPart.Size = Vector3.new(5, 0.5, 5) floatPart.Transparency = 1 floatPart.Anchored = true floatPart.CFrame = char.HumanoidRootPart.CFrame * CFrame.new(0, -3.25, 0)
        floatConnection = RunService.RenderStepped:Connect(function() if floatActive and char and char:FindFirstChild("HumanoidRootPart") and floatPart then floatPart.CFrame = CFrame.new(char.HumanoidRootPart.Position.X, floatPart.Position.Y, char.HumanoidRootPart.Position.Z) end end)
    else if floatConnection then floatConnection:Disconnect() floatConnection = nil end if floatPart then floatPart:Destroy() floatPart = nil end end
end)

local pFly = createSectionCard(tabs.Player.Container, "Fly Engine Mechanics", 2)
createToggleSwitch(pFly, "Fly Hack Enabled", function(v)
    if v then
        stopFlying() local char = Player.Character if not char or not char:FindFirstChild("HumanoidRootPart") then return end
        local torso = char.HumanoidRootPart local hum = char:FindFirstChildOfClass("Humanoid") flying = true
        bg = Instance.new("BodyGyro", torso) bg.P = 9e4 bg.maxTorque = Vector3.new(9e9, 9e9, 9e9) bg.cframe = torso.CFrame
        bv = Instance.new("BodyVelocity", torso) bv.velocity = Vector3.new(0,0,0) bv.maxForce = Vector3.new(9e9, 9e9, 9e9)
        task.spawn(function()
            while flying and task.wait() do
                if hum and torso and bv and bg then
                    hum:ChangeState(Enum.HumanoidStateType.Physics) local speed = flyLevel * 10 local moveDir = hum.MoveDirection
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
createLevelControl(pFly, "Velocity Speed", 5, 1, 20, function(lvl) flyLevel = lvl end)

local pWalk = createSectionCard(tabs.Player.Container, "WalkSpeed & Jumps", 3)
local function updateWalkSpeed() local char = Player.Character if char and char:FindFirstChildOfClass("Humanoid") then char:FindFirstChildOfClass("Humanoid").WalkSpeed = walkToggleState and (walkLevel * 10) or 16 end end
createToggleSwitch(pWalk, "Bypass Speed", function(v) walkToggleState = v updateWalkSpeed() end)
createLevelControl(pWalk, "Speed Level", 1, 1, 20, function(lvl) walkLevel = lvl updateWalkSpeed() end)

local function updateJumpPower() local char = Player.Character if char and char:FindFirstChildOfClass("Humanoid") then local hum = char:FindFirstChildOfClass("Humanoid") hum.UseJumpPower = true hum.JumpPower = jumpToggleState and (jumpLevel * 10) or 50 end end
createToggleSwitch(pWalk, "Bypass Jump", function(v) jumpToggleState = v updateJumpPower() end)
createLevelControl(pWalk, "Power Level", 5, 1, 20, function(lvl) jumpLevel = lvl updateJumpPower() end)

infJumpConnection = UserInputService.JumpRequest:Connect(function() if infJumpActive and Player.Character and Player.Character:FindFirstChildOfClass("Humanoid") then Player.Character:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping) end end)
createToggleSwitch(pWalk, "Infinite Jump Engine", function(state) infJumpActive = state end)

-- ====================================================================
-- TAB 3: ESP SYSTEM
-- ====================================================================
local espSec = createSectionCard(tabs.ESP.Container, "Visual Monitor Config", 1)
local EspSettings = { Active = false, Names = true, Distance = true, Health = true, Color = Color3.fromRGB(0, 180, 216) } local EspObjects = {}

local function applyEspToCharacter(targetPlayer, char)
    if targetPlayer == Player or not char then return end
    task.wait(0.4) local head = char:WaitForChild("Head", 5) local hum = char:FindFirstChildOfClass("Humanoid") if not head or not hum then return end
    if EspObjects[targetPlayer.Name] then EspObjects[targetPlayer.Name]:Destroy() EspObjects[targetPlayer.Name] = nil end
    local hl = Instance.new("Highlight") hl.Name = "A_HL_" .. targetPlayer.Name hl.FillColor = EspSettings.Color hl.FillTransparency = 0.5 hl.OutlineColor = Color3.fromRGB(255,255,255) hl.Adornee = char hl.Parent = MainGui
    local bb = Instance.new("BillboardGui", head) bb.Name = "A_BB_" .. targetPlayer.Name bb.Size = UDim2.new(0, 130, 0, 40) bb.AlwaysOnTop = true bb.ExtentsOffset = Vector3.new(0, 2.5, 0)
    local lbl = Instance.new("TextLabel", bb) lbl.Size = UDim2.new(1, 0, 1, 0) lbl.BackgroundTransparency = 1 lbl.Font = Enum.Font.GothamBold lbl.TextSize = 10 lbl.TextColor3 = EspSettings.Color lbl.TextStrokeTransparency = 0.5
    
    local connection
    connection = RunService.RenderStepped:Connect(function()
        if not EspSettings.Active or not char.Parent or not hum or hum.Health <= 0 then hl:Destroy() bb:Destroy() if connection then connection:Disconnect() end EspObjects[targetPlayer.Name] = nil return end
        hl.FillColor = EspSettings.Color lbl.TextColor3 = EspSettings.Color local tx = ""
        if EspSettings.Names then tx = tx .. targetPlayer.Name .. "\n" end
        if EspSettings.Health then tx = tx .. "HP: " .. math.floor(hum.Health) .. " " end
        if EspSettings.Distance and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("HumanoidRootPart") then
            tx = tx .. "[" .. math.floor((Player.Character.HumanoidRootPart.Position - char.HumanoidRootPart.Position).Magnitude) .. "m]"
        end
        lbl.Text = tx
    end)
    EspObjects[targetPlayer.Name] = hl
end

createToggleSwitch(espSec, "Master Activation ESP", function(v)
    if _G.EspAddC then _G.EspAddC:Disconnect() end
    EspSettings.Active = v
    if v then 
        for _, p in pairs(Players:GetPlayers()) do if p.Character then applyEspToCharacter(p, p.Character) end end
        _G.EspAddC = Players.PlayerAdded:Connect(function(np) np.CharacterAdded:Connect(function(nc) if EspSettings.Active then applyEspToCharacter(np, nc) end end) end)
    else for _, p in pairs(Players:GetPlayers()) do if p.Character then local b = p.Character.Head:FindFirstChild("A_BB_" .. p.Name) if b then b:Destroy() end local h = MainGui:FindFirstChild("A_HL_" .. p.Name) if h then h:Destroy() end end end end
end)
createToggleSwitch(espSec, "Show Tag Names", function(v) EspSettings.Names = v end)
createToggleSwitch(espSec, "Show Distance Meter", function(v) EspSettings.Distance = v end)

-- ====================================================================
-- TAB 4: TELEPORT HUB
-- ====================================================================
local configTpSec = createSectionCard(tabs.Teleport.Container, "Engine Settings", 1)
createToggleSwitch(configTpSec, "Use Tween Movement (Anti-Cheat)", function(state) UseTweenTeleport = state end)

local gotoSec = createSectionCard(tabs.Teleport.Container, "Goto Player Tracker", 2)
createStandardButton(gotoSec, "🎯 Teleport to Locked Target", function()
    if GlobalTargetName ~= "" then local t = Players:FindFirstChild(GlobalTargetName) if t and t.Character and t.Character:FindFirstChild("HumanoidRootPart") then executeTeleport(t.Character.HumanoidRootPart.CFrame * CFrame.new(0, 2, 0)) end end
end)

local listUserSec = createSectionCard(tabs.Teleport.Container, "Target Player Selector List", 3)
local listContainerFix = Instance.new("Frame", listUserSec) listContainerFix.Size = UDim2.new(1,0,0,90) listContainerFix.BackgroundTransparency = 1
local pListScroll = Instance.new("ScrollingFrame", listContainerFix) pListScroll.Size = UDim2.new(1, 0, 1, 0) pListScroll.BackgroundTransparency = 1 pListScroll.CanvasSize = UDim2.new(0,0,0,0) pListScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y pListScroll.ScrollBarThickness = 2
local pListLayout = Instance.new("UIListLayout", pListScroll) pListLayout.Padding = UDim.new(0, 4)

local function rebuildPlayerList()
    for _, child in pairs(pListScroll:GetChildren()) do if child:IsA("TextButton") then child:Destroy() end end
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= Player then
            local pBtn = Instance.new("TextButton", pListScroll) pBtn.Size = UDim2.new(1, -6, 0, 22) pBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 45) pBtn.Font = Enum.Font.GothamMedium pBtn.Text = "  " .. p.Name pBtn.TextColor3 = (GlobalTargetName == p.Name) and Theme.Accent or Theme.TextMain pBtn.TextSize = 11 pBtn.TextXAlignment = Enum.TextXAlignment.Left
            Instance.new("UICorner", pBtn).CornerRadius = UDim.new(0, 4) Instance.new("UIStroke", pBtn).Color = Theme.Stroke
            pBtn.MouseButton1Click:Connect(function() GlobalTargetName = p.Name rebuildPlayerList() end)
        end
    end
end
rebuildPlayerList() Players.PlayerAdded:Connect(rebuildPlayerList) Players.PlayerRemoving:Connect(rebuildPlayerList)

-- ====================================================================
-- TAB 5: WORLD SERVER MODULE
-- ====================================================================
local worldSec = createSectionCard(tabs.World.Container, "Server Connection Manager", 1)
createStandardButton(worldSec, "⚡ Instant Rejoin Server", function() if #Players:GetPlayers() <= 1 then TeleportService:Teleport(game.PlaceId, Player) else TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, Player) end end)

-- ====================================================================
-- TAB 6: UTILITIES MODULE
-- ====================================================================
local actSec = createSectionCard(tabs.Utilities.Container, "Interactivity Exploits", 1)
local bV, aV, att
local function runTimerFling(targetPlayer)
    if not targetPlayer or not targetPlayer.Character then return end
    local targetHrp = targetPlayer.Character:FindFirstChild("HumanoidRootPart") local myHrp = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") if not targetHrp or not myHrp then return end
    cleanFlingParts() flingActive = true
    bV = Instance.new("BodyVelocity", myHrp) bV.MaxForce = Vector3.new(9e9, 9e9, 9e9) bV.Velocity = Vector3.new(0,0,0)
    aV = Instance.new("AngularVelocity", myHrp) aV.MaxTorque = 9e9 aV.AngularVelocity = Vector3.new(5000, 5000, 5000) aV.RelativeTo = Enum.ActuatorRelativeTo.Attachment0
    att = Instance.new("Attachment", myHrp) aV.Attachment0 = att
    for _, part in pairs(Player.Character:GetChildren()) do if part:IsA("BasePart") then part.CanCollide = false end end
    local startTime = tick()
    flingConnection = RunService.Heartbeat:Connect(function()
        local currentHum = targetPlayer.Character and targetPlayer.Character:FindFirstChildOfClass("Humanoid") local currentHrp = targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not flingActive or not currentHum or currentHum.Health <= 0 or not currentHrp or (tick() - startTime) >= 4 then cleanFlingParts() return end
        myHrp.CFrame = currentHrp.CFrame * CFrame.new(0, 0, 0.05) bV.Velocity = currentHrp.Velocity
    end)
end
createStandardButton(actSec, "🚀 Fling Target (Brutal Spin v3)", function() if GlobalTargetName ~= "" and not flingActive then local t = Players:FindFirstChild(GlobalTargetName) if t then runTimerFling(t) end end end)

-- ====================================================================
-- TAB 7: SETTINGS MODULE (UI MANAGER)
-- ====================================================================
local setSec = createSectionCard(tabs.Settings.Container, "Dashboard Configuration", 1)
createLevelControl(setSec, "UI Main Transparency (%)", 15, 0, 90, function(lvl) MainFrame.BackgroundTransparency = lvl / 100 end)
createStandardButton(setSec, "🔴 Self-Destroy System UI", function()
    cleanFlingParts() if _G.EspAddC then _G.EspAddC:Disconnect() end if headSitC then headSitC:Disconnect() end if infJumpConnection then infJumpConnection:Disconnect() end
    if noclipConnection then noclipConnection:Disconnect() end if floatConnection then floatConnection:Disconnect() end if floatPart then floatPart:Destroy() end
    if damageAuraConnection then damageAuraConnection:Disconnect() end stopFlying() MainGui:Destroy()
end)

print("[AR SCRIPT HUB V6.0]: Premium Layout Successfully Deployed.")
