-- ====================================================================
-- AR SCRIPT HUB - OFFICIAL VERSION v5.6 (PRO FIX & OPTIMIZED)
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

local Theme = {
    Bg = Color3.fromRGB(12, 10, 24),         
    BgTrans = 0.20,                          
    CardBg = Color3.fromRGB(20, 22, 38),     
    CardTrans = 0.4,                         
    Stroke = Color3.fromRGB(56, 52, 92),     
    Accent = Color3.fromRGB(115, 170, 255),  
    AccentPurple = Color3.fromRGB(190, 130, 255), 
    TextMain = Color3.fromRGB(245, 245, 255),
    TextMuted = Color3.fromRGB(140, 145, 175)
}

-- GLOBAL VARIABLES MANAGEMENT
local GlobalTargetName = ""
local UseTweenTeleport = false
local noclipActive, floatActive, flying, infJumpActive = false, false, false, false
local noclipConnection, floatConnection, flyConnection, infJumpConnection, headSitC, flingConnection
local floatPart, bg, bv

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

-- FLOATING TOGGLE
local ToggleButton = Instance.new("TextButton")
ToggleButton.Name = "ToggleButton"
ToggleButton.Parent = MainGui
ToggleButton.Size = UDim2.new(0, 46, 0, 46)
ToggleButton.Position = UDim2.new(0.02, 0, 0.2, 0)
ToggleButton.BackgroundColor3 = Theme.Bg
ToggleButton.BackgroundTransparency = 0.15
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.Text = "AR"
ToggleButton.TextColor3 = Theme.Accent
ToggleButton.TextSize = 16
Instance.new("UICorner", ToggleButton).CornerRadius = UDim.new(0, 9)
local tbStroke = Instance.new("UIStroke", ToggleButton)
tbStroke.Color = Theme.AccentPurple
makeDraggable(ToggleButton, ToggleButton)

-- MAIN PANEL
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = MainGui
MainFrame.Size = UDim2.new(0, 460, 0, 380)
MainFrame.Position = UDim2.new(0.5, -230, 0.5, -190)
MainFrame.BackgroundColor3 = Theme.Bg
MainFrame.BackgroundTransparency = Theme.BgTrans
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)
local mainStroke = Instance.new("UIStroke", MainFrame)
mainStroke.Color = Theme.Stroke
mainStroke.Thickness = 1.5

-- HEADER
local Header = Instance.new("Frame", MainFrame)
Header.Size = UDim2.new(1, 0, 0, 45)
Header.BackgroundTransparency = 1

local Title = Instance.new("TextLabel", Header)
Title.Text = "✨ AR SCRIPT HUB <font color='#c092ff'>v5.6</font>"
Title.RichText = true
Title.Size = UDim2.new(0.7, 0, 1, 0)
Title.Position = UDim2.new(0, 14, 0, 0)
Title.Font = Enum.Font.GothamBold
Title.TextColor3 = Theme.TextMain
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.BackgroundTransparency = 1

local CloseBtn = Instance.new("TextButton", Header)
CloseBtn.Text = "×"
CloseBtn.Size = UDim2.new(0, 45, 1, 0)
CloseBtn.Position = UDim2.new(1, -45, 0, 0)
CloseBtn.Font = Enum.Font.GothamMedium
CloseBtn.TextColor3 = Theme.TextMuted
CloseBtn.TextSize = 24
CloseBtn.BackgroundTransparency = 1

makeDraggable(MainFrame, Header)
ToggleButton.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)
CloseBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false end)

-- SIDEBAR NAV MENU
local NavFrame = Instance.new("Frame", MainFrame)
NavFrame.Size = UDim2.new(0, 100, 1, -65)
NavFrame.Position = UDim2.new(0, 14, 0, 50)
NavFrame.BackgroundTransparency = 1

local ContentFrame = Instance.new("Frame", MainFrame)
ContentFrame.Size = UDim2.new(1, -142, 1, -65)
ContentFrame.Position = UDim2.new(0, 128, 0, 50)
ContentFrame.BackgroundTransparency = 1

local tabs = {Player = {}, ESP = {}, Teleport = {}, World = {}, Utilities = {}, Settings = {}}
local activeTab = "Player"

local function createContainer(name)
    local f = Instance.new("ScrollingFrame", ContentFrame)
    f.Size = UDim2.new(1, 0, 1, 0)
    f.BackgroundTransparency = 1
    f.CanvasSize = UDim2.new(0, 0, 0, 0)
    f.AutomaticCanvasSize = Enum.AutomaticSize.Y
    f.ScrollBarThickness = 3
    f.ScrollBarImageColor3 = Theme.Accent
    f.Visible = (name == activeTab)
    tabs[name].Container = f
    
    local layout = Instance.new("UIListLayout", f)
    layout.Padding = UDim.new(0, 12)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
end

createContainer("Player")
createContainer("ESP")
createContainer("Teleport")
createContainer("World")
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
    btn.TextSize = 12
    btn.TextColor3 = (name == activeTab) and Theme.Accent or Theme.TextMuted
    btn.TextXAlignment = Enum.TextXAlignment.Left
    tabs[name].Button = btn
    btn.MouseButton1Click:Connect(function() switchTab(name) end)
end

addTabButton("Player", "👤 Player", 1)
addTabButton("ESP", "👁️ ESP System", 2)
addTabButton("Teleport", "🌀 Teleport", 3)
addTabButton("World", "🌐 World", 4)
addTabButton("Utilities", "🛠️ Utilities", 5)
addTabButton("Settings", "⚙️ Settings", 6)

-- COMPONENTS GENERATOR
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
    sTitle.Size = UDim2.new(1, -12, 0, 24)
    sTitle.Position = UDim2.new(0, 12, 0, 6)
    sTitle.Text = titleText:upper()
    sTitle.Font = Enum.Font.GothamBold
    sTitle.TextColor3 = Theme.AccentPurple
    sTitle.TextSize = 10
    sTitle.BackgroundTransparency = 1
    sTitle.TextXAlignment = Enum.TextXAlignment.Left
    
    local container = Instance.new("Frame", section)
    container.Size = UDim2.new(1, -24, 0, 0)
    container.Position = UDim2.new(0, 12, 0, 34)
    container.BackgroundTransparency = 1
    container.AutomaticSize = Enum.AutomaticSize.Y
    
    local innerLayout = Instance.new("UIListLayout", container)
    innerLayout.Padding = UDim.new(0, 8)
    innerLayout.SortOrder = Enum.SortOrder.LayoutOrder
    
    local padding = Instance.new("UIPadding", container)
    padding.PaddingBottom = UDim.new(0, 10)

    return container
end

local function createToggleSwitch(parent, labelText, callback)
    local holder = Instance.new("Frame", parent)
    holder.Size = UDim2.new(1, 0, 0, 28) holder.BackgroundTransparency = 1
    
    local lbl = Instance.new("TextLabel", holder)
    lbl.Text = labelText lbl.Size = UDim2.new(0.7, 0, 1, 0)
    lbl.Font = Enum.Font.GothamMedium lbl.TextColor3 = Theme.TextMain lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left lbl.BackgroundTransparency = 1
    
    local bgTrack = Instance.new("TextButton", holder)
    bgTrack.Size = UDim2.new(0, 34, 0, 18) bgTrack.Position = UDim2.new(1, -34, 0.5, -9)
    bgTrack.BackgroundColor3 = Theme.Bg bgTrack.Text = ""
    Instance.new("UICorner", bgTrack).CornerRadius = UDim.new(0, 9)
    local tStroke = Instance.new("UIStroke", bgTrack) tStroke.Color = Theme.Stroke
    
    local knob = Instance.new("Frame", bgTrack)
    knob.Size = UDim2.new(0, 12, 0, 12) knob.Position = UDim2.new(0, 3, 0.5, -6)
    knob.BackgroundColor3 = Theme.TextMuted Instance.new("UICorner", knob).CornerRadius = UDim.new(0, 6)
    
    local state = false
    bgTrack.MouseButton1Click:Connect(function()
        state = not state
        local targetX = state and 19 or 3
        local targetTrackColor = state and Theme.Accent or Theme.Bg
        local targetKnobColor = state and Theme.Bg or Theme.TextMuted
        TweenService:Create(knob, TweenInfo.new(0.08), {Position = UDim2.new(0, targetX, 0.5, -6), BackgroundColor3 = targetKnobColor}):Play()
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
    lbl.Text = labelText .. ": " .. currentLvl lbl.Size = UDim2.new(0.6, 0, 1, 0)
    lbl.Font = Enum.Font.GothamMedium lbl.TextColor3 = Theme.TextMain lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left lbl.BackgroundTransparency = 1
    
    local btnMinus = Instance.new("TextButton", holder)
    btnMinus.Text = "–" btnMinus.Size = UDim2.new(0, 22, 0, 20) btnMinus.Position = UDim2.new(1, -22, 0.5, -10)
    btnMinus.BackgroundColor3 = Theme.Bg btnMinus.TextColor3 = Theme.TextMain btnMinus.Font = Enum.Font.GothamBold
    btnMinus.TextSize = 12 Instance.new("UICorner", btnMinus).CornerRadius = UDim.new(0, 4)
    Instance.new("UIStroke", btnMinus).Color = Theme.Stroke
    
    local btnPlus = Instance.new("TextButton", holder)
    btnPlus.Text = "+" btnPlus.Size = UDim2.new(0, 22, 0, 20) btnPlus.Position = UDim2.new(1, -48, 0.5, -10)
    btnPlus.BackgroundColor3 = Theme.Bg btnPlus.TextColor3 = Theme.TextMain btnPlus.Font = Enum.Font.GothamBold
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
    btn.Size = UDim2.new(1, 0, 0, 28) btn.BackgroundColor3 = Theme.Bg
    btn.Font = Enum.Font.GothamBold btn.Text = textDisplay btn.TextColor3 = Theme.TextMain btn.TextSize = 12
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)
    local bStroke = Instance.new("UIStroke", btn) bStroke.Color = Theme.Stroke
    btn.MouseButton1Click:Connect(callback)
end

local function executeTeleport(targetCFrame)
    local char = Player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    if UseTweenTeleport then
        local distance = (hrp.Position - targetCFrame.Position).Magnitude
        local speed = 250
        local tweenTime = distance / speed
        local tween = TweenService:Create(hrp, TweenInfo.new(tweenTime, Enum.EasingStyle.Linear), {CFrame = targetCFrame})
        tween:Play()
    else
        hrp.CFrame = targetCFrame
    end
end

-- ====================================================================
-- CLEANUP MANAGEMENT FUNCTION
-- ====================================================================
local function cleanAllConnections()
    noclipActive = false
    if noclipConnection then noclipConnection:Disconnect() noclipConnection = nil end
    
    floatActive = false
    if floatConnection then floatConnection:Disconnect() floatConnection = nil end
    if floatPart then floatPart:Destroy() floatPart = nil end
    
    flying = false
    if flyConnection then flyConnection:Disconnect() flyConnection = nil end
    if bg then bg:Destroy() bg = nil end
    if bv then bv:Destroy() bv = nil end
    local hum = Player.Character and Player.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum:SetStateEnabled(Enum.HumanoidStateType.Flying, false) hum:ChangeState(Enum.HumanoidStateType.Running) end
    
    if infJumpConnection then infJumpConnection:Disconnect() infJumpConnection = nil end
    if headSitC then headSitC:Disconnect() headSitC = nil end
    
    -- Fling Reset Protection
    if flingConnection then flingConnection:Disconnect() flingConnection = nil end
    if Player.Character then
        for _, part in pairs(Player.Character:GetChildren()) do
            if part:IsA("BasePart") then part.CanCollide = true end
        end
    end
end

-- ====================================================================
-- TAB 1: PLAYER MODIFIERS
-- ====================================================================
-- 1. GHOST NAVIGATION (NOCLIP & FLOAT MOVED TO LAYOUT ORDER 1)
local pExtraNav = createSectionCard(tabs.Player.Container, "Ghost Environment Bypass", 1)

createToggleSwitch(pExtraNav, "Noclip (Safe Ghost Pass)", function(v)
    noclipActive = v
    if v then
        if noclipConnection then noclipConnection:Disconnect() end
        noclipConnection = RunService.Stepped:Connect(function()
            if noclipActive and Player.Character then 
                for _, p in pairs(Player.Character:GetDescendants()) do 
                    -- HRP disisakan agar tidak jatuh tembus ke Void/Bumi secara instan
                    if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then 
                        p.CanCollide = false 
                    end 
                end 
            end
        end)
    else 
        if noclipConnection then noclipConnection:Disconnect() noclipConnection = nil end 
    end
end)

createToggleSwitch(pExtraNav, "Float Platform Stabilizer", function(state)
    floatActive = state local char = Player.Character
    if state then
        if not char or not char:FindFirstChild("HumanoidRootPart") then return end
        floatPart = Instance.new("Part", workspace) floatPart.Size = Vector3.new(5, 0.5, 5) floatPart.Transparency = 1 floatPart.Anchored = true floatPart.CFrame = char.HumanoidRootPart.CFrame * CFrame.new(0, -3.25, 0)
        floatConnection = RunService.RenderStepped:Connect(function() if floatActive and char and char:FindFirstChild("HumanoidRootPart") and floatPart then floatPart.CFrame = CFrame.new(char.HumanoidRootPart.Position.X, floatPart.Position.Y, char.HumanoidRootPart.Position.Z) end end)
    else if floatConnection then floatConnection:Disconnect() floatConnection = nil end if floatPart then floatPart:Destroy() floatPart = nil end end
end)

-- 2. FLY MODULE (Layout Order 2)
local pFly = createSectionCard(tabs.Player.Container, "Fly", 2)
local flyLevel = 5
local function stopFlying()
    flying = false if bg then bg:Destroy() bg = nil end if bv then bv:Destroy() bv = nil end
    local hum = Player.Character and Player.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum:SetStateEnabled(Enum.HumanoidStateType.Flying, false) hum:ChangeState(Enum.HumanoidStateType.Running) end
end
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

-- 3. WALKSPEED MODULE (Layout Order 3)
local pWalk = createSectionCard(tabs.Player.Container, "WalkSpeed", 3)
local walkToggleState = false local walkLevel = 1
local function updateWalkSpeed()
    local char = Player.Character
    if char and char:FindFirstChildOfClass("Humanoid") then char:FindFirstChildOfClass("Humanoid").WalkSpeed = walkToggleState and (walkLevel * 10) or 16 end
end
createToggleSwitch(pWalk, "Bypass Speed", function(v) walkToggleState = v updateWalkSpeed() end)
createLevelControl(pWalk, "Speed Level", 1, 1, 20, function(lvl) walkLevel = lvl updateWalkSpeed() end)

-- 4. JUMP & AIR NAVIGATION MODULE (Layout Order 4)
local pJump = createSectionCard(tabs.Player.Container, "Jump & Air Mechanics", 4)
local jumpToggleState = false local jumpLevel = 5
local function updateJumpPower()
    local char = Player.Character
    if char and char:FindFirstChildOfClass("Humanoid") then
        local hum = char:FindFirstChildOfClass("Humanoid") hum.UseJumpPower = true hum.JumpPower = jumpToggleState and (jumpLevel * 10) or 50
    end
end
createToggleSwitch(pJump, "Bypass Jump", function(v) jumpToggleState = v updateJumpPower() end)
createLevelControl(pJump, "Power Level", 5, 1, 20, function(lvl) jumpLevel = lvl updateJumpPower() end)

-- FIXED BUG: Penambahan fungsionalitas Infinite Jump Core yang tertinggal
infJumpConnection = UserInputService.JumpRequest:Connect(function()
    if infJumpActive and Player.Character and Player.Character:FindFirstChildOfClass("Humanoid") then
        Player.Character:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)
createToggleSwitch(pJump, "Infinite Jump Engine", function(state) infJumpActive = state end)

-- 5. DEFENSE MODULE (Layout Order 5)
local pDefense = createSectionCard(tabs.Player.Container, "Defense", 5)
local AntiAfkConnection, AntiFlingConnection, AntiStunConnection local AntiFlingActive, AntiStunActive, IsInvisible = false, false, false
createToggleSwitch(pDefense, "Anti-AFK Core System", function(state)
    if state then AntiAfkConnection = Player.Idled:Connect(function() local vu = game:GetService("VirtualUser") vu:CaptureController() vu:ClickButton2(Vector2.new(0,0)) end)
    else if AntiAfkConnection then AntiAfkConnection:Disconnect() AntiAfkConnection = nil end end
end)
createToggleSwitch(pDefense, "Anti-Fling Shield Mode", function(state)
    AntiFlingActive = state
    if state then
        AntiFlingConnection = RunService.Heartbeat:Connect(function()
            local hrp = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") if not AntiFlingActive or not hrp then return end
            if hrp.Velocity.Magnitude > 75 or hrp.RotVelocity.Magnitude > 75 then hrp.Velocity = Vector3.new(0,0,0) hrp.RotVelocity = Vector3.new(0,0,0) end
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= Player and p.Character then for _, part in pairs(p.Character:GetChildren()) do if part:IsA("BasePart") then part.CanCollide = false end end end
            end
        end)
    else if AntiFlingConnection then AntiFlingConnection:Disconnect() AntiFlingConnection = nil end end
end)
createToggleSwitch(pDefense, "Anti-Stun Ragdoll Lock", function(state)
    AntiStunActive = state
    if state then
        AntiStunConnection = RunService.RenderStepped:Connect(function()
            local hum = Player.Character and Player.Character:FindFirstChildOfClass("Humanoid")
            if AntiStunActive and hum and (hum.PlatformStanding or hum.Sit) then hum.PlatformStanding = false hum.Sit = false hum:ChangeState(Enum.HumanoidStateType.Running) end
        end)
    else if AntiStunConnection then AntiStunConnection:Disconnect() AntiStunConnection = nil end end
end)
createToggleSwitch(pDefense, "Invisible Mode Glitch", function(state) IsInvisible = state local char = Player.Character if char and char:FindFirstChild("LowerTorso") then char.LowerTorso.RootJoint.Part0 = state and nil or char.HumanoidRootPart end end)

-- ====================================================================
-- TAB 2: ESP SYSTEM
-- ====================================================================
local espSec = createSectionCard(tabs.ESP.Container, "Visual Monitor Configurations", 1)
local EspSettings = { Active = false, Names = true, Distance = true, Health = true, Color = Color3.fromRGB(115, 170, 255) } local EspObjects = {}

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
        _G.EspAddC = Players.PlayerAdded:Connect(function(newPlayer)
            newPlayer.CharacterAdded:Connect(function(newChar)
                if EspSettings.Active then applyEspToCharacter(newPlayer, newChar) end
            end)
        end)
    else 
        for _, p in pairs(Players:GetPlayers()) do if p.Character then local b = p.Character.Head:FindFirstChild("A_BB_" .. p.Name) if b then b:Destroy() end local h = MainGui:FindFirstChild("A_HL_" .. p.Name) if h then h:Destroy() end end end 
    end
end)
createToggleSwitch(espSec, "Show Tag Names", function(v) EspSettings.Names = v end)
createToggleSwitch(espSec, "Show Distance Meter", function(v) EspSettings.Distance = v end)
createToggleSwitch(espSec, "Show Health Monitor", function(v) EspSettings.Health = v end)

local colorSec = createSectionCard(tabs.ESP.Container, "🎨 ESP Color Palette Selection", 2)
local colorsData = {
    {Name = "🔵 Cyber Blue Soft", Color = Color3.fromRGB(115, 170, 255)},
    {Name = "🟣 Orchid Purple Soft", Color = Color3.fromRGB(190, 130, 255)},
    {Name = "🔴 Crimson Hell", Color = Color3.fromRGB(255, 90, 90)},
    {Name = "🟡 Golden Honey", Color = Color3.fromRGB(255, 210, 100)},
    {Name = "⚪ Absolute White", Color = Color3.fromRGB(255, 255, 255)}
}
for _, c in ipairs(colorsData) do
    local cb = Instance.new("TextButton", colorSec) cb.Size = UDim2.new(1, 0, 0, 18) cb.BackgroundTransparency = 1 cb.Font = Enum.Font.GothamMedium cb.Text = c.Name cb.TextColor3 = Theme.TextMain cb.TextSize = 11 cb.TextXAlignment = Enum.TextXAlignment.Left
    cb.MouseButton1Click:Connect(function() EspSettings.Color = c.Color for _, v in pairs(colorSec:GetChildren()) do if v:IsA("TextButton") then v.TextColor3 = Theme.TextMain end end cb.TextColor3 = Theme.Accent end)
end

-- ====================================================================
-- TAB 3: TELEPORT HUB
-- ====================================================================
local configTpSec = createSectionCard(tabs.Teleport.Container, "Engine Settings", 1)
createToggleSwitch(configTpSec, "Use Tween Movement (Anti-Cheat)", function(state) UseTweenTeleport = state end)

local gotoSec = createSectionCard(tabs.Teleport.Container, "Goto Player Tracker", 2)
createStandardButton(gotoSec, "🎯 Teleport to Locked Target", function()
    if GlobalTargetName ~= "" then
        local t = Players:FindFirstChild(GlobalTargetName)
        if t and t.Character and t.Character:FindFirstChild("HumanoidRootPart") then executeTeleport(t.Character.HumanoidRootPart.CFrame * CFrame.new(0, 2, 0)) end
    end
end)

local listUserSec = createSectionCard(tabs.Teleport.Container, "👥 Target Player Selector List", 3)
local listContainerFix = Instance.new("Frame", listUserSec) listContainerFix.Size = UDim2.new(1,0,0,110) listContainerFix.BackgroundTransparency = 1
local pListScroll = Instance.new("ScrollingFrame", listContainerFix) pListScroll.Size = UDim2.new(1, 0, 1, 0) pListScroll.BackgroundTransparency = 1 pListScroll.CanvasSize = UDim2.new(0,0,0,0) pListScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y pListScroll.ScrollBarThickness = 2 pListScroll.ScrollBarImageColor3 = Theme.Accent local pListLayout = Instance.new("UIListLayout", pListScroll) pListLayout.Padding = UDim.new(0, 4)

local function rebuildPlayerList()
    for _, child in pairs(pListScroll:GetChildren()) do if child:IsA("TextButton") then child:Destroy() end end
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= Player then
            local pBtn = Instance.new("TextButton", pListScroll) pBtn.Size = UDim2.new(1, -6, 0, 20) pBtn.BackgroundColor3 = Theme.Bg pBtn.BackgroundTransparency = 0.4 pBtn.Font = Enum.Font.GothamMedium pBtn.Text = "  " .. p.Name pBtn.TextColor3 = (GlobalTargetName == p.Name) and Theme.Accent or Theme.TextMain pBtn.TextSize = 11 pBtn.TextXAlignment = Enum.TextXAlignment.Left
            Instance.new("UICorner", pBtn).CornerRadius = UDim.new(0, 4) Instance.new("UIStroke", pBtn).Color = Theme.Stroke
            pBtn.MouseButton1Click:Connect(function() GlobalTargetName = p.Name rebuildPlayerList() end)
        end
    end
end
rebuildPlayerList() Players.PlayerAdded:Connect(rebuildPlayerList) Players.PlayerRemoving:Connect(rebuildPlayerList)

local wpSec = createSectionCard(tabs.Teleport.Container, "Map Waypoints Vectors (1-5)", 4)
local waypointSlots = {WP1 = nil, WP2 = nil, WP3 = nil, WP4 = nil, WP5 = nil}

local function createWpRow(slotKey, labelDisplayName)
    local row = Instance.new("Frame", wpSec) row.Size = UDim2.new(1, 0, 0, 26) row.BackgroundTransparency = 1
    
    local label = Instance.new("TextLabel", row)
    label.Text = "📌 " .. labelDisplayName label.Font = Enum.Font.GothamMedium label.TextColor3 = Theme.TextMain label.TextSize = 12
    label.Size = UDim2.new(0.5, 0, 1, 0) label.TextXAlignment = Enum.TextXAlignment.Left label.BackgroundTransparency = 1
    
    local btnSave = Instance.new("TextButton", row)
    btnSave.Text = "Save" btnSave.Size = UDim2.new(0, 46, 0, 20) btnSave.Position = UDim2.new(0.64, 0, 0.5, -10)
    btnSave.BackgroundColor3 = Theme.Bg btnSave.TextColor3 = Theme.AccentPurple btnSave.Font = Enum.Font.GothamBold btnSave.TextSize = 10
    Instance.new("UICorner", btnSave).CornerRadius = UDim.new(0, 4) Instance.new("UIStroke", btnSave).Color = Theme.Stroke
    
    local btnTp = Instance.new("TextButton", row)
    btnTp.Text = "TP" btnTp.Size = UDim2.new(0, 36, 0, 20) btnTp.Position = UDim2.new(0.86, 0, 0.5, -10)
    btnTp.BackgroundColor3 = Theme.Bg btnTp.TextColor3 = Theme.Accent btnTp.Font = Enum.Font.GothamBold btnTp.TextSize = 10
    Instance.new("UICorner", btnTp).CornerRadius = UDim.new(0, 4) Instance.new("UIStroke", btnTp).Color = Theme.Stroke
    
    btnSave.MouseButton1Click:Connect(function()
        if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
            waypointSlots[slotKey] = Player.Character.HumanoidRootPart.CFrame
            btnSave.Text = "Saved!" task.delay(0.6, function() btnSave.Text = "Save" end)
        end
    end)
    btnTp.MouseButton1Click:Connect(function() if waypointSlots[slotKey] then executeTeleport(waypointSlots[slotKey]) end end)
end

createWpRow("WP1", "WP Slot 1")
createWpRow("WP2", "WP Slot 2")
createWpRow("WP3", "WP Slot 3")
createWpRow("WP4", "WP Slot 4")
createWpRow("WP5", "WP Slot 5")

-- ====================================================================
-- TAB 4: WORLD MODULE
-- ====================================================================
local worldSec = createSectionCard(tabs.World.Container, "Server Connection Manager", 1)
createStandardButton(worldSec, "⚡ Instant Rejoin Server", function()
    if #Players:GetPlayers() <= 1 then TeleportService:Teleport(game.PlaceId, Player) else TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, Player) end
end)
createStandardButton(worldSec, "🚀 Auto Server Hop (Low Player)", function()
    local apiLink = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
    local success, result = pcall(function() return game:HttpGet(apiLink) end)
    if success and result then
        local serverList = HttpService:JSONDecode(result)
        if serverList and serverList.data then
            for _, server in ipairs(serverList.data) do
                if server.id ~= game.JobId and tonumber(server.playing) < tonumber(server.maxPlayers) then TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id, Player) return end
            end
        end
    end
end)

-- ====================================================================
-- TAB 5: UTILITIES MODULE
-- ====================================================================
local actSec = createSectionCard(tabs.Utilities.Container, "Interactivity Exploits", 1)
local flingActive = false local bV, aV, att

local function cleanFlingParts()
    flingActive = false if flingConnection then flingConnection:Disconnect() flingConnection = nil end
    if bV then bV:Destroy() bV = nil end if aV then aV:Destroy() aV = nil end if att then att:Destroy() att = nil end
    if Player.Character then for _, part in pairs(Player.Character:GetChildren()) do if part:IsA("BasePart") then part.CanCollide = true end end end
end

local function runTimerFling(targetPlayer)
    if not targetPlayer or not targetPlayer.Character then return end
    local targetHrp = targetPlayer.Character:FindFirstChild("HumanoidRootPart") local myHrp = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") if not targetHrp or not myHrp then return end
    cleanFlingParts() flingActive = true
    
    -- Mengurangi power rotasi ekstrim (99999 -> 5000) untuk meminimalkan deteksi otomatis Anti-Cheat fisika
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
createStandardButton(actSec, "🛑 Stop Fling (Unfling Manual)", function() cleanFlingParts() end)

createToggleSwitch(actSec, "Headsit Target Follower", function(state)
    local headSitting = state if headSitC then headSitC:Disconnect() headSitC = nil end
    if not state then if Player.Character and Player.Character:FindFirstChildOfClass("Humanoid") then Player.Character:FindFirstChildOfClass("Humanoid").Sit = false end return end
    headSitC = RunService.Heartbeat:Connect(function()
        if headSitting and GlobalTargetName ~= "" then
            local t = Players:FindFirstChild(GlobalTargetName)
            if t and t.Character and t.Character:FindFirstChild("Head") and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
                Player.Character:FindFirstChildOfClass("Humanoid").Sit = true Player.Character.HumanoidRootPart.CFrame = t.Character.Head.CFrame * CFrame.new(0, 1.3, 0)
            end
        end
    end)
end)

local utilSec2 = createSectionCard(tabs.Utilities.Container, "Structural Tools Automation", 2)
createStandardButton(utilSec2, "🎒 Replicate Target Backpack Tools", function()
    if GlobalTargetName ~= "" then
        local t = Players:FindFirstChild(GlobalTargetName) local bp = Player:FindFirstChild("Backpack")
        if t and bp then
            local function cp(o) if o:IsA("Tool") then local nt = o:Clone() nt.Parent = bp end end
            if t.Character then for _, obj in pairs(t.Character:GetChildren()) do cp(obj) end end
            if t:FindFirstChild("Backpack") then for _, obj in pairs(t.Backpack:GetChildren()) do cp(obj) end end
        end
    end
end)
createStandardButton(utilSec2, "🎒 Sweep Map Tools to Inventory", function() local bp = Player:FindFirstChild("Backpack") if bp then for _, o in pairs(workspace:GetDescendants()) do if o:IsA("Tool") then o.Parent = bp end end end end)


-- ====================================================================
-- TAB 6: SETTINGS MODULE
-- ====================================================================
local setSec = createSectionCard(tabs.Settings.Container, "Dashboard Configuration", 1)

-- Tambahan Interface Settings: Pengatur Transparansi Floating Button agar tidak mengganggu pandangan game
createLevelControl(setSec, "UI Button Transparency (%)", 15, 0, 90, function(lvl)
    ToggleButton.BackgroundTransparency = lvl / 100
end)

createStandardButton(setSec, "🔄 Quick Reload Script Hub", function()
    cleanAllConnections()
    if _G.EspAddC then _G.EspAddC:Disconnect() end
    MainGui:Destroy()
    task.wait(0.3)
    pcall(function() 
        -- Masukkan link pastebin raw script utama kamu di sini jika ditaruh di github/pastebin
        loadstring(game:HttpGet("https://raw.githubusercontent.com/pastebin/raw/your_link_here"))() 
    end)
end)

createStandardButton(setSec, "🔴 Self-Destroy System UI", function()
    cleanAllConnections()
    if _G.EspAddC then _G.EspAddC:Disconnect() end
    MainGui:Destroy()
end)

print("[AR SCRIPT HUB V5.6]: Successfully Deployed and Optimized.")
