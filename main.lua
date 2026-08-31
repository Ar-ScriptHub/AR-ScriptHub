-- ====================================================================
-- CORE SERVICES & INITIALIZATION
-- ====================================================================
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Stats = game:GetService("Stats")
local TeleportService = game:GetService("TeleportService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local MarketplaceService = game:GetService("MarketplaceService")
local Lighting = game:GetService("Lighting")

local Player = Players.LocalPlayer
local SafeGuiTarget = Player:FindFirstChildOfClass("PlayerGui") or Player:WaitForChild("PlayerGui", 5)

-- ====================================================================
-- ANTI-BUG CLEAN-UP ENGINE
-- ====================================================================
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

-- ====================================================================
-- CONFIGURATION & STATE MANAGEMENT
-- ====================================================================
local Config = {
    FlyMode = false,
    FlySpeed = 5,
    Noclip = false,
    SuperSpeed = false,
    SuperSpeedVal = 16,
    SuperJump = false,
    SuperJumpVal = 50,
    InfiniteJump = false,
    Gravity = 196,
    HipHeight = 2,
    EnableESP = false,
    ShowBoxes = false,
    ShowNames = false,
    ShowGlow = false,
    TeamCheck = false,
    MaxDistance = 3000,
    ShadowsDisabled = false,
    AntiLag = false,
    UiTransparency = 0,
    TweenTeleport = false,
    TweenSpeed = 350,
    FullBright = false,
    
    -- AUTOMATION CONFIGS
    FastAttack = false,
    AttackDelay = 0.05,
    ExpandProximity = false,
    ProximityDistance = 10000,
    InstantProximityHold = false,
    ProximityLineOfSight = false,

    -- FREECAM CONFIGS
    FreecamMode = false,
    FreecamSpeed = 1,
    FreecamSmoothness = 0.15,
    FreecamFov = 70,
    FreecamFreezeChar = false
}

local Theme = {
    HeaderBg = Color3.fromRGB(46, 125, 90),     -- Hijau Header Top Bar
    Bg = Color3.fromRGB(24, 26, 28),             -- Background Utama
    SidebarBg = Color3.fromRGB(32, 35, 38),      -- Sidebar Kiri
    CardBg = Color3.fromRGB(38, 42, 46),         -- Background Elemen / Card
    Stroke = Color3.fromRGB(55, 60, 65),         -- Border Outline / Divider
    Accent = Color3.fromRGB(52, 199, 123),       -- Hijau Mint Terang
    AccentHover = Color3.fromRGB(42, 169, 103),  
    TextMain = Color3.fromRGB(245, 245, 245),
    TextMuted = Color3.fromRGB(160, 165, 170),
    DeleteRed = Color3.fromRGB(255, 90, 90),
    DeleteBg = Color3.fromRGB(60, 30, 35),
    ConfirmGreen = Color3.fromRGB(52, 199, 123)
}

local FILE_NAME = "AR_Hub_Waypoints_v71.json"
local KEY_FILE_NAME = "AR_Hub_KeySystem.json"
local CorrectKey = "AR"

local CurrentPlaceId = tostring(game.PlaceId)
local AllWaypoints = {}
local KeyVerified = false

local origAmbient = Lighting.Ambient
local origOutdoorAmbient = Lighting.OutdoorAmbient
local origBrightness = Lighting.Brightness
local origClockTime = Lighting.ClockTime

local hiddenGuisCache = {}

-- ====================================================================
-- SECURITY & DATA LICENSE SYSTEM
-- ====================================================================
local function loadKeyStatus()
    local success, content = pcall(function() return readfile(KEY_FILE_NAME) end)
    if success and content then
        local decodeSuccess, decodedData = pcall(function() return HttpService:JSONDecode(content) end)
        if decodeSuccess and type(decodedData) == "table" then
            if decodedData.Timestamp and (os.time() - decodedData.Timestamp) < 86400 then
                if decodedData.Key == CorrectKey then 
                    KeyVerified = true 
                end
            end
        end
    end
end

local function saveKeyStatus()
    local data = { Key = CorrectKey, Timestamp = os.time() }
    pcall(function() writefile(KEY_FILE_NAME, HttpService:JSONEncode(data)) end)
end

loadKeyStatus()

local CurrentMapName = "Unknown Game"
pcall(function()
    local productInfo = MarketplaceService:GetProductInfo(game.PlaceId)
    if productInfo and productInfo.Name then 
        CurrentMapName = productInfo.Name 
    end
end)

local CurrentExecutor = (identifyexecutor or getexecutorname or function() return "Unknown Executor" end)()

-- ====================================================================
-- HELPER & ENGINE UTILITIES (DEFINED FIRST)
-- ====================================================================
local function applyGraphicsBoost()
    Lighting.GlobalShadows = not Config.ShadowsDisabled
    if Config.AntiLag then 
        pcall(function()
            settings().Rendering.QualityLevel = Enum.QualityLevel.Level01 
        end)
    end
end

local function enforceHumanoidProperties()
    if Player.Character and Player.Character:FindFirstChildOfClass("Humanoid") then
        local hum = Player.Character:FindFirstChildOfClass("Humanoid")
        hum.WalkSpeed = Config.SuperSpeed and Config.SuperSpeedVal or 16
        hum.JumpPower = Config.SuperJump and Config.SuperJumpVal or 50
        hum.UseJumpPower = true
    end
end

local function bypassTeleportWithTween(targetCFrame)
    if not Player.Character or not Player.Character:FindFirstChild("HumanoidRootPart") then return false end
    local hrp = Player.Character.HumanoidRootPart
    if Config.TweenTeleport then
        local distance = (hrp.Position - targetCFrame.Position).Magnitude
        local duration = distance / math.max(Config.TweenSpeed, 50)
        local bodyVelocity = Instance.new("BodyVelocity")
        
        bodyVelocity.Velocity = Vector3.new(0, 0, 0)
        bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bodyVelocity.Parent = hrp
        
        local tween = TweenService:Create(hrp, TweenInfo.new(duration, Enum.EasingStyle.Linear), {CFrame = targetCFrame})
        tween:Play()
        tween.Completed:Connect(function() 
            bodyVelocity:Destroy() 
        end)
        return true
    end
    return false
end

-- ====================================================================
-- MOVEMENT BACKGROUND CORE ENGINE
-- ====================================================================
local flyBg, flyBv

local function stopFlying()
    if flyBg then flyBg:Destroy() flyBg = nil end
    if flyBv then flyBv:Destroy() flyBv = nil end
    local char = Player.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum:SetStateEnabled(Enum.HumanoidStateType.Flying, false)
        hum:ChangeState(Enum.HumanoidStateType.Running)
    end
end

local function handleFlyEngine()
    if not Config.FlyMode then 
        stopFlying() 
        return 
    end
    stopFlying()
    
    local char = Player.Character 
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local torso = char.HumanoidRootPart
    local hum = char:FindFirstChildOfClass("Humanoid") 
    if not hum then return end
    
    flyBg = Instance.new("BodyGyro", torso) 
    flyBg.P = 9e4 
    flyBg.maxTorque = Vector3.new(9e9, 9e9, 9e9) 
    flyBg.cframe = torso.CFrame
    
    flyBv = Instance.new("BodyVelocity", torso) 
    flyBv.velocity = Vector3.new(0, 0, 0) 
    flyBv.maxForce = Vector3.new(9e9, 9e9, 9e9)
    
    task.spawn(function()
        local camera = workspace.CurrentCamera
        while Config.FlyMode and Player.Character and torso and flyBv and flyBg do
            hum:ChangeState(Enum.HumanoidStateType.Physics)
            local speed = Config.FlySpeed * 10
            local moveDir = hum.MoveDirection
            local camCF = camera.CFrame
            local direction = Vector3.new(0, 0, 0)
            
            if moveDir.Magnitude > 0 then
                local lookVector = camCF.LookVector
                local rightVector = camCF.RightVector
                local forwardInput = moveDir:Dot(Vector3.new(lookVector.X, 0, lookVector.Z).Unit)
                local sideInput = moveDir:Dot(Vector3.new(rightVector.X, 0, rightVector.Z).Unit)
                direction = (lookVector * forwardInput) + (rightVector * sideInput)
            end
            
            local finalVelocity = (direction.Magnitude > 0) and (direction.Unit * speed) or Vector3.new(0, 0, 0)
            local verticalSpeed = 0
            
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then 
                verticalSpeed = speed
            elseif UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then 
                verticalSpeed = -speed 
            end
            
            if verticalSpeed ~= 0 then 
                flyBv.velocity = Vector3.new(finalVelocity.X, verticalSpeed, finalVelocity.Z)
            else 
                flyBv.velocity = finalVelocity 
            end
            
            flyBg.cframe = camCF
            task.wait()
        end
        stopFlying()
    end)
end

-- ====================================================================
-- AUTOMATION ENGINE WORKERS (FAST ATTACK & PROXIMITY)
-- ====================================================================
task.spawn(function()
    while true do
        task.wait(Config.AttackDelay)
        if Config.FastAttack and Player.Character then
            local tool = Player.Character:FindFirstChildOfClass("Tool")
            if tool then
                pcall(function()
                    tool:Activate()
                end)
            end
        end
    end
end)

task.spawn(function()
    while task.wait(1) do
        if Config.ExpandProximity then
            for _, prompt in pairs(workspace:GetDescendants()) do
                if prompt:IsA("ProximityPrompt") then
                    pcall(function()
                        prompt.MaxActivationDistance = Config.ProximityDistance
                        if Config.InstantProximityHold then
                            prompt.HoldDuration = 0
                        end
                        if Config.ProximityLineOfSight then
                            prompt.RequiresLineOfSight = false
                        end
                    end)
                end
            end
        end
    end
end)

-- ====================================================================
-- MOVEMENT PROPERTY WORKERS
-- ====================================================================
UserInputService.JumpRequest:Connect(function()
    if Config.InfiniteJump and Player.Character then
        local hum = Player.Character:FindFirstChildOfClass("Humanoid")
        if hum then 
            hum:ChangeState(Enum.HumanoidStateType.Jumping) 
        end
    end
end)

RunService.Stepped:Connect(function()
    if Config.Noclip and Player.Character then
        for _, part in pairs(Player.Character:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then 
                part.CanCollide = false 
            end
        end
    end
end)

Player.CharacterAdded:Connect(function(char)
    char:WaitForChild("Humanoid", 5)
    enforceHumanoidProperties()
    if Config.FlyMode then 
        task.wait(0.1) 
        handleFlyEngine() 
    end
end)

RunService.RenderStepped:Connect(function()
    if Config.FullBright then
        Lighting.Ambient = Color3.fromRGB(255, 255, 255)
        Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
    end
end)

-- ====================================================================
-- ESP RENDER CHAMS ENGINE (FIXED MEMORY LEAK & RE-CONNECTIONS)
-- ====================================================================
local espCache = {}

local function cleanESP(target)
    if espCache[target] then
        if espCache[target].Box then espCache[target].Box:Destroy() end
        if espCache[target].Label then espCache[target].Label:Destroy() end
        if espCache[target].Highlight then espCache[target].Highlight:Destroy() end
        if espCache[target].Connection then espCache[target].Connection:Disconnect() end
        espCache[target] = nil
    end
end

local function buildESP(target)
    if target == Player then return end
    cleanESP(target)
    
    local data = {}
    espCache[target] = data

    data.Connection = RunService.RenderStepped:Connect(function()
        if not Config.EnableESP or not target.Character or not target.Character:FindFirstChild("HumanoidRootPart") or not Player.Character or not Player.Character:FindFirstChild("HumanoidRootPart") then
            if data.Box then data.Box:Destroy() data.Box = nil end
            if data.Label then data.Label:Destroy() data.Label = nil end
            if data.Highlight then data.Highlight:Destroy() data.Highlight = nil end
            return
        end
        
        local tChar = target.Character 
        local tHrp = tChar.HumanoidRootPart 
        local pHrp = Player.Character.HumanoidRootPart
        local camera = workspace.CurrentCamera 
        local _, onScreen = camera:WorldToViewportPoint(tHrp.Position)
        local distance = (pHrp.Position - tHrp.Position).Magnitude

        if (Config.TeamCheck and target.Team == Player.Team) or (distance > Config.MaxDistance) then 
            if data.Box then data.Box:Destroy() data.Box = nil end
            if data.Label then data.Label:Destroy() data.Label = nil end
            if data.Highlight then data.Highlight:Destroy() data.Highlight = nil end
            return 
        end

        if Config.ShowBoxes and onScreen then
            if not data.Box then
                local b = Instance.new("BoxHandleAdornment") 
                b.Size = Vector3.new(4, 5.5, 4) 
                b.Color3 = Theme.Accent 
                b.AlwaysOnTop = true 
                b.Transparency = 0.6 
                data.Box = b
            end
            data.Box.Adornee = tChar 
            data.Box.Parent = SafeGuiTarget
        else
            if data.Box then data.Box:Destroy() data.Box = nil end
        end

        if Config.ShowNames and onScreen then
            if not data.Label then
                local bgui = Instance.new("BillboardGui") 
                bgui.Size = UDim2.new(0, 150, 0, 40) 
                bgui.AlwaysOnTop = true 
                bgui.StudsOffset = Vector3.new(0, 3, 0)
                
                local txt = Instance.new("TextLabel", bgui) 
                txt.Size = UDim2.new(1, 0, 1, 0) 
                txt.BackgroundTransparency = 1 
                txt.TextColor3 = Theme.TextMain 
                txt.Font = Enum.Font.GothamBold 
                txt.TextSize = 10 
                
                data.Label = bgui 
                data.TxtObject = txt
            end
            data.TxtObject.Text = string.format("%s\n[%d m]", target.DisplayName, math.round(distance))
            data.Label.Adornee = tHrp 
            data.Label.Parent = SafeGuiTarget
        else
            if data.Label then data.Label:Destroy() data.Label = nil end
        end

        if Config.ShowGlow then
            if not data.Highlight then
                local hl = Instance.new("Highlight") 
                hl.FillColor = Theme.Accent 
                hl.FillTransparency = 0.4 
                hl.OutlineColor = Theme.TextMain 
                hl.OutlineTransparency = 0.1 
                hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop 
                data.Highlight = hl
            end
            data.Highlight.Adornee = tChar 
            data.Highlight.Parent = SafeGuiTarget
        else
            if data.Highlight then data.Highlight:Destroy() data.Highlight = nil end
        end
    end)
end

Players.PlayerAdded:Connect(buildESP)
Players.PlayerRemoving:Connect(cleanESP)
for _, p in pairs(Players:GetPlayers()) do buildESP(p) end

-- ====================================================================
-- LOCAL WAYPOINT STORAGE SYSTEM
-- ====================================================================
local function loadWaypointsFromStorage()
    AllWaypoints = {}
    local success, content = pcall(function() return readfile(FILE_NAME) end)
    if success and content then
        local decodeSuccess, decodedData = pcall(function() return HttpService:JSONDecode(content) end)
        if decodeSuccess and type(decodedData) == "table" then 
            AllWaypoints = decodedData 
        end
    else
        pcall(function() writefile(FILE_NAME, HttpService:JSONEncode({})) end)
    end
    if not AllWaypoints[CurrentPlaceId] then AllWaypoints[CurrentPlaceId] = {} end
end

local function saveWaypointsToStorage()
    pcall(function() writefile(FILE_NAME, HttpService:JSONEncode(AllWaypoints)) end)
end

loadWaypointsFromStorage()

-- ====================================================================
-- DRAG ENGINE BUILDER
-- ====================================================================
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

-- ====================================================================
-- GUI CORE INSTANCE INITIALIZATION
-- ====================================================================
local MainGui = Instance.new("ScreenGui")
MainGui.Name = "AR_Script_Hub"
MainGui.Parent = SafeGuiTarget
MainGui.ResetOnSpawn = false
MainGui.DisplayOrder = 2147483647

local rawSource = debug.infos and debug.infos() or "" 
MainGui:SetAttribute("ScriptContent", rawSource)

-- POPUP CONFIRMATION FRAME
local PopupFrame = Instance.new("Frame")
PopupFrame.Name = "PopupFrame" 
PopupFrame.Parent = MainGui 
PopupFrame.Size = UDim2.new(0, 240, 0, 110) 
PopupFrame.Position = UDim2.new(0.5, -120, 0.5, -55) 
PopupFrame.BackgroundColor3 = Theme.Bg 
PopupFrame.Visible = false 
PopupFrame.ZIndex = 1000 
Instance.new("UICorner", PopupFrame).CornerRadius = UDim.new(0, 8)

local popStroke = Instance.new("UIStroke", PopupFrame) 
popStroke.Color = Theme.Accent 
popStroke.Thickness = 1.2

local PopupText = Instance.new("TextLabel", PopupFrame) 
PopupText.Size = UDim2.new(1, -16, 0, 40) 
PopupText.Position = UDim2.new(0, 8, 0, 12) 
PopupText.Text = "Apakah anda yakin?" 
PopupText.Font = Enum.Font.GothamBold 
PopupText.TextColor3 = Theme.TextMain 
PopupText.TextSize = 11 
PopupText.TextWrapped = true 
PopupText.BackgroundTransparency = 1 
PopupText.ZIndex = 1001

local PopupYes = Instance.new("TextButton", PopupFrame) 
PopupYes.Size = UDim2.new(0, 95, 0, 26) 
PopupYes.Position = UDim2.new(0, 16, 1, -36) 
PopupYes.BackgroundColor3 = Color3.fromRGB(30, 60, 45) 
PopupYes.Font = Enum.Font.GothamBold 
PopupYes.Text = "YA" 
PopupYes.TextColor3 = Theme.ConfirmGreen 
PopupYes.TextSize = 10 
PopupYes.ZIndex = 1001 
Instance.new("UICorner", PopupYes).CornerRadius = UDim.new(0, 4) 

local PopupNo = Instance.new("TextButton", PopupFrame) 
PopupNo.Size = UDim2.new(0, 95, 0, 26) 
PopupNo.Position = UDim2.new(1, -111, 1, -36) 
PopupNo.BackgroundColor3 = Color3.fromRGB(60, 30, 35) 
PopupNo.Font = Enum.Font.GothamBold 
PopupNo.Text = "TIDAK" 
PopupNo.TextColor3 = Theme.DeleteRed 
PopupNo.TextSize = 10 
PopupNo.ZIndex = 1001 
Instance.new("UICorner", PopupNo).CornerRadius = UDim.new(0, 4) 

local currentCallback = nil
local function showConfirmation(message, onYes)
    PopupText.Text = message 
    currentCallback = onYes 
    PopupFrame.Visible = true 
    PopupFrame.Size = UDim2.new(0, 210, 0, 95)
    TweenService:Create(PopupFrame, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 240, 0, 110)}):Play()
end

PopupYes.MouseButton1Click:Connect(function() 
    PopupFrame.Visible = false 
    if currentCallback then currentCallback() end 
end)

PopupNo.MouseButton1Click:Connect(function() 
    PopupFrame.Visible = false 
end)

-- ====================================================================
-- MAIN INTERFACE FRAME & TOGGLES
-- ====================================================================
local ToggleButton = Instance.new("TextButton")
ToggleButton.Name = "ToggleButton" 
ToggleButton.Parent = MainGui 
ToggleButton.Size = UDim2.new(0, 38, 0, 38) 
ToggleButton.Position = UDim2.new(0.02, 0, 0.2, 0) 
ToggleButton.BackgroundColor3 = Theme.HeaderBg 
ToggleButton.Font = Enum.Font.GothamBold 
ToggleButton.Text = "AR" 
ToggleButton.TextColor3 = Theme.TextMain 
ToggleButton.TextSize = 14 
ToggleButton.Visible = false 
Instance.new("UICorner", ToggleButton).CornerRadius = UDim.new(0, 10)
makeDraggable(ToggleButton, ToggleButton)

local EyeRestoreButton = Instance.new("ImageButton")
EyeRestoreButton.Name = "EyeRestoreButton"
EyeRestoreButton.Parent = MainGui
EyeRestoreButton.Size = UDim2.new(0, 34, 0, 34)
EyeRestoreButton.Position = UDim2.new(1, -45, 0, 10)
EyeRestoreButton.BackgroundColor3 = Theme.HeaderBg
EyeRestoreButton.Image = "rbxassetid://3926313437"
EyeRestoreButton.ImageColor3 = Theme.TextMain
EyeRestoreButton.Visible = false
EyeRestoreButton.ZIndex = 9999999
Instance.new("UICorner", EyeRestoreButton).CornerRadius = UDim.new(0, 17)
makeDraggable(EyeRestoreButton, EyeRestoreButton)

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame" 
MainFrame.Parent = MainGui 
MainFrame.Size = UDim2.new(0, 430, 0, 240) 
MainFrame.Position = UDim2.new(0.5, -215, 0.5, -120) 
MainFrame.BackgroundColor3 = Theme.Bg 
MainFrame.Visible = false 
MainFrame.ClipsDescendants = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)

local mainStroke = Instance.new("UIStroke", MainFrame) 
mainStroke.Color = Theme.Stroke 
mainStroke.Thickness = 1

local Header = Instance.new("Frame", MainFrame) 
Header.Name = "Header"
Header.Size = UDim2.new(1, 0, 0, 30) 
Header.BackgroundColor3 = Theme.HeaderBg
Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 8)

local HeaderFix = Instance.new("Frame", Header)
HeaderFix.Size = UDim2.new(1, 0, 0, 8)
HeaderFix.Position = UDim2.new(0, 0, 1, -8)
HeaderFix.BackgroundColor3 = Theme.HeaderBg
HeaderFix.BorderSizePixel = 0

local RobloxLogo = Instance.new("ImageLabel", Header)
RobloxLogo.Size = UDim2.new(0, 16, 0, 16)
RobloxLogo.Position = UDim2.new(0, 8, 0.5, -8)
RobloxLogo.BackgroundTransparency = 1
RobloxLogo.Image = "rbxassetid://10423184683" 
RobloxLogo.ImageColor3 = Theme.TextMain

local Title = Instance.new("TextLabel", Header) 
Title.Text = "AR Script Hub" 
Title.Size = UDim2.new(0.5, 0, 1, 0) 
Title.Position = UDim2.new(0, 30, 0, 0) 
Title.Font = Enum.Font.GothamBold 
Title.TextColor3 = Theme.TextMain 
Title.TextSize = 11 
Title.TextXAlignment = Enum.TextXAlignment.Left 
Title.BackgroundTransparency = 1

local CloseBtn = Instance.new("TextButton", Header) 
CloseBtn.Text = "✕" 
CloseBtn.Size = UDim2.new(0, 30, 1, 0) 
CloseBtn.Position = UDim2.new(1, -30, 0, 0) 
CloseBtn.Font = Enum.Font.GothamBold 
CloseBtn.TextColor3 = Theme.TextMain 
CloseBtn.TextSize = 12 
CloseBtn.BackgroundTransparency = 1

local MinimizeBtn = Instance.new("TextButton", Header) 
MinimizeBtn.Text = "─" 
MinimizeBtn.Size = UDim2.new(0, 30, 1, 0) 
MinimizeBtn.Position = UDim2.new(1, -60, 0, 0) 
MinimizeBtn.Font = Enum.Font.GothamBold 
MinimizeBtn.TextColor3 = Theme.TextMain 
MinimizeBtn.TextSize = 10 
MinimizeBtn.BackgroundTransparency = 1

makeDraggable(MainFrame, Header)

ToggleButton.MouseButton1Click:Connect(function() MainFrame.Visible = true ToggleButton.Visible = false end)
MinimizeBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false ToggleButton.Visible = true end)
CloseBtn.MouseButton1Click:Connect(function() showConfirmation("Hub akan ditutup secara permanen,\napakah kamu yakin?", function() MainGui:Destroy() end) end)

local function toggleCleanGuiView(hide)
    if hide then
        hiddenGuisCache = {}
        if SafeGuiTarget then
            for _, gui in pairs(SafeGuiTarget:GetChildren()) do
                if gui:IsA("ScreenGui") and gui.Enabled then
                    table.insert(hiddenGuisCache, gui)
                    gui.Enabled = false
                end
            end
        end
        MainGui.Enabled = true
        MainFrame.Visible = false
        ToggleButton.Visible = false
        EyeRestoreButton.Visible = true
    else
        for _, gui in pairs(hiddenGuisCache) do
            if gui and gui.Parent then
                gui.Enabled = true
            end
        end
        hiddenGuisCache = {}
        EyeRestoreButton.Visible = false
        MainFrame.Visible = true
    end
end

EyeRestoreButton.MouseButton1Click:Connect(function()
    toggleCleanGuiView(false)
end)

-- ====================================================================
-- SIDEBAR NAVIGATION & PAGES
-- ====================================================================
local Sidebar = Instance.new("Frame", MainFrame)
Sidebar.Name = "Sidebar"
Sidebar.Size = UDim2.new(0, 85, 1, -30)
Sidebar.Position = UDim2.new(0, 0, 0, 30)
Sidebar.BackgroundColor3 = Theme.SidebarBg
Sidebar.BorderSizePixel = 0

local SidebarLayout = Instance.new("UIListLayout", Sidebar)
SidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder
SidebarLayout.Padding = UDim.new(0, 3)

local SidebarPadding = Instance.new("UIPadding", Sidebar)
SidebarPadding.PaddingTop = UDim.new(0, 4)
SidebarPadding.PaddingLeft = UDim.new(0, 4)
SidebarPadding.PaddingRight = UDim.new(0, 4)

local ContentArea = Instance.new("Frame", MainFrame)
ContentArea.Name = "ContentArea"
ContentArea.Size = UDim2.new(1, -85, 1, -30)
ContentArea.Position = UDim2.new(0, 85, 0, 30)
ContentArea.BackgroundTransparency = 1

local menuContainers = {}
local function createMenuPage(name, isVisible)
    local scroll = Instance.new("ScrollingFrame", ContentArea) 
    scroll.Name = name .. "Page" 
    scroll.Size = UDim2.new(1, 0, 1, 0) 
    scroll.BackgroundTransparency = 1 
    scroll.CanvasSize = UDim2.new(0, 0, 0, 0) 
    scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y 
    scroll.ScrollBarThickness = 2 
    scroll.ScrollBarImageColor3 = Theme.Accent
    scroll.Visible = isVisible 
    
    local pad = Instance.new("UIPadding", scroll)
    pad.PaddingTop = UDim.new(0, 6)
    pad.PaddingLeft = UDim.new(0, 6)
    pad.PaddingRight = UDim.new(0, 6)
    pad.PaddingBottom = UDim.new(0, 10)

    local layout = Instance.new("UIListLayout", scroll)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 5)

    menuContainers[name] = scroll 
    return scroll
end

local playerPage = createMenuPage("Player", true)
local autoPage = createMenuPage("Automation", false)
local espPage = createMenuPage("ESP", false)
local tpPage = createMenuPage("Teleportation", false)
local serverPage = createMenuPage("Server", false)
local settingPage = createMenuPage("Setting", false)

local navButtons = {}
local function switchTab(tabName)
    for name, page in pairs(menuContainers) do 
        page.Visible = (name == tabName) 
    end
    for name, btn in pairs(navButtons) do
        if name == tabName then
            btn.BackgroundColor3 = Theme.CardBg
            btn.TextColor3 = Theme.Accent
        else
            btn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            btn.BackgroundTransparency = 1
            btn.TextColor3 = Theme.TextMuted
        end
    end
end

local function addSidebarButton(textDisplay, tabTarget, order)
    local btn = Instance.new("TextButton", Sidebar)
    btn.Size = UDim2.new(1, 0, 0, 24)
    btn.BackgroundColor3 = (order == 1) and Theme.CardBg or Color3.fromRGB(0, 0, 0)
    btn.BackgroundTransparency = (order == 1) and 0 or 1
    btn.Font = Enum.Font.GothamMedium
    btn.Text = textDisplay
    btn.TextColor3 = (order == 1) and Theme.Accent or Theme.TextMuted
    btn.TextSize = 10
    btn.LayoutOrder = order
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)

    btn.MouseButton1Click:Connect(function()
        switchTab(tabTarget)
    end)

    navButtons[tabTarget] = btn
    return btn
end

local function addSidebarDivider(order)
    local divider = Instance.new("Frame", Sidebar)
    divider.Size = UDim2.new(1, -8, 0, 1)
    divider.Position = UDim2.new(0, 4, 0, 0)
    divider.BackgroundColor3 = Theme.Stroke
    divider.BorderSizePixel = 0
    divider.LayoutOrder = order
end

addSidebarButton("Player", "Player", 1)
addSidebarDivider(2)
addSidebarButton("Auto", "Automation", 3)
addSidebarDivider(4)
addSidebarButton("Visuals", "ESP", 5)
addSidebarDivider(6)
addSidebarButton("Teleport", "Teleportation", 7)
addSidebarDivider(8)
addSidebarButton("Server", "Server", 9)
addSidebarDivider(10)
addSidebarButton("Settings", "Setting", 11)

-- ====================================================================
-- CONTROL INTERFACE FRAME FACTORY
-- ====================================================================
local function addToggle(parent, labelText, order, configKey, callback)
    local card = Instance.new("Frame", parent)
    card.Size = UDim2.new(1, 0, 0, 28)
    card.BackgroundColor3 = Theme.CardBg
    card.LayoutOrder = order
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 5)

    local lbl = Instance.new("TextLabel", card)
    lbl.Text = labelText
    lbl.Size = UDim2.new(1, -55, 1, 0)
    lbl.Position = UDim2.new(0, 8, 0, 0)
    lbl.Font = Enum.Font.GothamMedium
    lbl.TextColor3 = Theme.TextMain
    lbl.TextSize = 10
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.BackgroundTransparency = 1

    local track = Instance.new("TextButton", card)
    track.Size = UDim2.new(0, 38, 0, 18)
    track.Position = UDim2.new(1, -44, 0.5, -9)
    track.BackgroundColor3 = Config[configKey] and Theme.Accent or Color3.fromRGB(25, 28, 30)
    track.Text = Config[configKey] and "ON" or "OFF"
    track.Font = Enum.Font.GothamBold
    track.TextSize = 8
    track.TextColor3 = Theme.TextMain
    track.TextXAlignment = Config[configKey] and Enum.TextXAlignment.Left or Enum.TextXAlignment.Right
    Instance.new("UICorner", track).CornerRadius = UDim.new(0, 9)

    local pad = Instance.new("UIPadding", track)
    pad.PaddingLeft = UDim.new(0, 4)
    pad.PaddingRight = UDim.new(0, 4)

    local knob = Instance.new("Frame", track)
    knob.Size = UDim2.new(0, 12, 0, 12)
    knob.Position = UDim2.new(Config[configKey] and 1 or 0, Config[configKey] and -12 or 0, 0.5, -6)
    knob.BackgroundColor3 = Theme.TextMain
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

    track.MouseButton1Click:Connect(function()
        if not configKey then return end
        Config[configKey] = not Config[configKey]
        local active = Config[configKey]
        
        track.Text = active and "ON" or "OFF"
        track.TextXAlignment = active and Enum.TextXAlignment.Left or Enum.TextXAlignment.Right
        
        TweenService:Create(knob, TweenInfo.new(0.12), {Position = UDim2.new(active and 1 or 0, active and -12 or 0, 0.5, -6)}):Play()
        TweenService:Create(track, TweenInfo.new(0.12), {BackgroundColor3 = active and Theme.Accent or Color3.fromRGB(25, 28, 30)}):Play()
        
        if callback then callback(active) end
    end)
end

local function addSliderWithInput(parent, labelText, min, max, defaultVal, order, configKey, callback)
    local card = Instance.new("Frame", parent)
    card.Size = UDim2.new(1, 0, 0, 36)
    card.BackgroundColor3 = Theme.CardBg
    card.LayoutOrder = order
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 5)

    local lbl = Instance.new("TextLabel", card)
    lbl.Text = labelText
    lbl.Size = UDim2.new(0.7, 0, 0, 16)
    lbl.Position = UDim2.new(0, 8, 0, 3)
    lbl.Font = Enum.Font.GothamMedium
    lbl.TextColor3 = Theme.TextMain
    lbl.TextSize = 10
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.BackgroundTransparency = 1

    local inputBox = Instance.new("TextBox", card)
    inputBox.Size = UDim2.new(0, 35, 0, 14)
    inputBox.Position = UDim2.new(1, -42, 0, 4)
    inputBox.BackgroundTransparency = 1
    inputBox.Font = Enum.Font.GothamBold
    inputBox.Text = tostring(defaultVal)
    inputBox.TextColor3 = Theme.Accent
    inputBox.TextSize = 10
    inputBox.TextXAlignment = Enum.TextXAlignment.Right

    local track = Instance.new("Frame", card)
    track.Size = UDim2.new(1, -16, 0, 3)
    track.Position = UDim2.new(0, 8, 1, -8)
    track.BackgroundColor3 = Color3.fromRGB(25, 28, 30)
    Instance.new("UICorner", track).CornerRadius = UDim.new(0, 2)

    local startPerc = math.clamp((defaultVal - min) / (max - min), 0, 1)
    local fill = Instance.new("Frame", track)
    fill.Size = UDim2.new(startPerc, 0, 1, 0)
    fill.BackgroundColor3 = Theme.Accent
    Instance.new("UICorner", fill).CornerRadius = UDim.new(0, 2)

    local knob = Instance.new("Frame", track)
    knob.Position = UDim2.new(startPerc, -4, 0.5, -4)
    knob.Size = UDim2.new(0, 8, 0, 8)
    knob.BackgroundColor3 = Theme.TextMain
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

    local dragTrigger = Instance.new("ImageButton", knob)
    dragTrigger.Size = UDim2.new(2, 0, 2, 0)
    dragTrigger.Position = UDim2.new(-0.5, 0, -0.5, 0)
    dragTrigger.BackgroundTransparency = 1

    local function refreshVisuals(value)
        local clampedValue = math.clamp(value, min, max)
        if configKey then Config[configKey] = clampedValue end
        local perc = (clampedValue - min) / (max - min)
        fill.Size = UDim2.new(perc, 0, 1, 0)
        knob.Position = UDim2.new(perc, -4, 0.5, -4)
        inputBox.Text = tostring(clampedValue)
        if callback then callback(clampedValue) end
    end

    local sliding = false
    dragTrigger.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then sliding = true end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then sliding = false end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local relX = input.Position.X - track.AbsolutePosition.X
            local perc = math.clamp(relX / track.AbsoluteSize.X, 0, 1)
            refreshVisuals(math.round(min + (perc * (max - min))))
        end
    end)
    inputBox.FocusLost:Connect(function()
        local num = tonumber(inputBox.Text) refreshVisuals(num or min)
    end)
end

local function createActionButton(parent, text, color, onClick, order)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(1, 0, 0, 26)
    btn.BackgroundColor3 = color
    btn.Font = Enum.Font.GothamBold
    btn.Text = text
    btn.TextColor3 = Theme.TextMain
    btn.TextSize = 10
    btn.LayoutOrder = order
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)
    btn.MouseButton1Click:Connect(onClick)
    return btn
end

local function createStatLabel(parent, labelText, order)
    local card = Instance.new("Frame", parent)
    card.Size = UDim2.new(1, 0, 0, 22)
    card.BackgroundColor3 = Theme.CardBg
    card.LayoutOrder = order
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 5)

    local lbl = Instance.new("TextLabel", card)
    lbl.Size = UDim2.new(1, -16, 1, 0)
    lbl.Position = UDim2.new(0, 8, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.GothamMedium
    lbl.Text = labelText
    lbl.TextColor3 = Theme.TextMain
    lbl.TextSize = 9
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    return lbl
end

-- ====================================================================
-- FREECAM CINEMATIC ENGINE (DEFINED BEFORE SETTINGS USAGE)
-- ====================================================================
local CurrentCinematicMode = "Manual"
local FreecamConnection = nil
local targetFC_CFrame = workspace.CurrentCamera.CFrame
local fcVelocity = Vector3.zero
local fcRotX, fcRotY = 0, 0
local orbitAngle = 0
local autoPanDir = Vector3.new(1, 0, 0)
local dollyStartFov = 70
local shakeTime = 0

local origCameraType = workspace.CurrentCamera.CameraType
local origCameraCFrame = workspace.CurrentCamera.CFrame
local origCameraFov = workspace.CurrentCamera.FieldOfView

local function handleCharacterFreeze(freeze)
    local char = Player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then hrp.Anchored = freeze end
end

local FreecamHud = Instance.new("Frame")
FreecamHud.Name = "FreecamCinematicHud"
FreecamHud.Parent = MainGui
FreecamHud.Size = UDim2.new(0, 200, 0, 280)
FreecamHud.Position = UDim2.new(1, -210, 0.5, -140)
FreecamHud.BackgroundColor3 = Theme.Bg
FreecamHud.Visible = false
Instance.new("UICorner", FreecamHud).CornerRadius = UDim.new(0, 8)
local fhStroke = Instance.new("UIStroke", FreecamHud)
fhStroke.Color = Theme.HeaderBg
fhStroke.Thickness = 1.2

makeDraggable(FreecamHud, FreecamHud)

local fhTitle = Instance.new("TextLabel", FreecamHud)
fhTitle.Size = UDim2.new(1, 0, 0, 26)
fhTitle.Text = "🎬 FREECAM CINEMATIC"
fhTitle.Font = Enum.Font.GothamBold
fhTitle.TextColor3 = Theme.Accent
fhTitle.TextSize = 10
fhTitle.BackgroundTransparency = 1

local fhScroll = Instance.new("ScrollingFrame", FreecamHud)
fhScroll.Size = UDim2.new(1, -10, 1, -30)
fhScroll.Position = UDim2.new(0, 5, 0, 26)
fhScroll.BackgroundTransparency = 1
fhScroll.ScrollBarThickness = 2
fhScroll.ScrollBarImageColor3 = Theme.Accent
fhScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y

local fhLayout = Instance.new("UIListLayout", fhScroll)
fhLayout.Padding = UDim.new(0, 4)
fhLayout.SortOrder = Enum.SortOrder.LayoutOrder

local function updateFreecamEngine()
    if not Config.FreecamMode then
        if FreecamConnection then FreecamConnection:Disconnect() FreecamConnection = nil end
        workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
        workspace.CurrentCamera.FieldOfView = origCameraFov
        handleCharacterFreeze(false)
        UserInputService.MouseBehavior = Enum.MouseBehavior.Default
        FreecamHud.Visible = false
        return
    end

    origCameraType = workspace.CurrentCamera.CameraType
    origCameraCFrame = workspace.CurrentCamera.CFrame
    origCameraFov = workspace.CurrentCamera.FieldOfView
    
    targetFC_CFrame = workspace.CurrentCamera.CFrame
    local look = targetFC_CFrame.LookVector
    fcRotX = math.asin(look.Y)
    fcRotY = math.atan2(-look.X, -look.Z)
    orbitAngle = fcRotY
    dollyStartFov = Config.FreecamFov
    shakeTime = 0
    
    workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
    FreecamHud.Visible = true

    handleCharacterFreeze(Config.FreecamFreezeChar)

    FreecamConnection = RunService.RenderStepped:Connect(function(dt)
        handleCharacterFreeze(Config.FreecamFreezeChar)

        if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
            UserInputService.MouseBehavior = Enum.MouseBehavior.LockCurrentPosition
            local delta = UserInputService:GetMouseDelta()
            fcRotY = fcRotY - (delta.X * 0.003)
            fcRotX = math.clamp(fcRotX - (delta.Y * 0.003), -math.pi/2.2, math.pi/2.2)
        else
            UserInputService.MouseBehavior = Enum.MouseBehavior.Default
        end

        local targetRotation = CFrame.Angles(0, fcRotY, 0) * CFrame.Angles(fcRotX, 0, 0)
        local char = Player.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")

        if CurrentCinematicMode == "Manual" then
            workspace.CurrentCamera.FieldOfView = Config.FreecamFov
            local moveDir = Vector3.zero
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + Vector3.new(0, 0, -1) end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir + Vector3.new(0, 0, 1) end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir + Vector3.new(-1, 0, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + Vector3.new(1, 0, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.E) then moveDir = moveDir + Vector3.new(0, 1, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.Q) then moveDir = moveDir + Vector3.new(0, -1, 0) end

            local worldMoveDir = targetRotation:VectorToWorldSpace(moveDir)
            local targetVelocity = worldMoveDir * (Config.FreecamSpeed * 40)
            fcVelocity = fcVelocity:Lerp(targetVelocity, Config.FreecamSmoothness)
            targetFC_CFrame = targetFC_CFrame + (fcVelocity * dt)
            workspace.CurrentCamera.CFrame = CFrame.new(targetFC_CFrame.Position) * targetRotation

        elseif CurrentCinematicMode == "Orbit" then
            workspace.CurrentCamera.FieldOfView = Config.FreecamFov
            if hrp then
                orbitAngle = orbitAngle + (Config.FreecamSpeed * 0.5 * dt)
                local radius = 15
                local offset = Vector3.new(math.sin(orbitAngle) * radius, 3, math.cos(orbitAngle) * radius)
                workspace.CurrentCamera.CFrame = CFrame.new(hrp.Position + offset, hrp.Position)
                targetFC_CFrame = workspace.CurrentCamera.CFrame
            end

        elseif CurrentCinematicMode == "DollyZoom" then
            if hrp then
                local camPos = targetFC_CFrame.Position
                local toTarget = (hrp.Position - camPos)
                local dist = toTarget.Magnitude
                if dist > 5 then
                    targetFC_CFrame = targetFC_CFrame + (toTarget.Unit * (Config.FreecamSpeed * 2 * dt))
                    local currentDist = (hrp.Position - targetFC_CFrame.Position).Magnitude
                    workspace.CurrentCamera.FieldOfView = math.clamp((currentDist / dist) * dollyStartFov, 10, 120)
                end
                workspace.CurrentCamera.CFrame = CFrame.new(targetFC_CFrame.Position) * targetRotation
            end

        elseif CurrentCinematicMode == "AutoPan" then
            workspace.CurrentCamera.FieldOfView = Config.FreecamFov
            local worldPanDir = targetRotation:VectorToWorldSpace(autoPanDir)
            targetFC_CFrame = targetFC_CFrame + (worldPanDir * (Config.FreecamSpeed * 10) * dt)
            workspace.CurrentCamera.CFrame = CFrame.new(targetFC_CFrame.Position) * targetRotation

        elseif CurrentCinematicMode == "Handheld" then
            workspace.CurrentCamera.FieldOfView = Config.FreecamFov
            shakeTime = shakeTime + dt * 5
            local moveDir = Vector3.zero
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + Vector3.new(0, 0, -1) end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir + Vector3.new(0, 0, 1) end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir + Vector3.new(-1, 0, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + Vector3.new(1, 0, 0) end
            
            local worldMoveDir = targetRotation:VectorToWorldSpace(moveDir)
            targetFC_CFrame = targetFC_CFrame + (worldMoveDir * (Config.FreecamSpeed * 40) * dt)
            
            local shakeX = math.noise(shakeTime, 0, 0) * 0.03
            local shakeY = math.noise(0, shakeTime, 0) * 0.03
            local shakeOffset = Vector3.new(math.noise(shakeTime, shakeTime, 0) * 0.1, math.noise(0, 0, shakeTime) * 0.1, 0)
            
            workspace.CurrentCamera.CFrame = CFrame.new(targetFC_CFrame.Position + shakeOffset) * (targetRotation * CFrame.Angles(shakeX, shakeY, 0))

        elseif CurrentCinematicMode == "LookAt" then
            workspace.CurrentCamera.FieldOfView = Config.FreecamFov
            local moveDir = Vector3.zero
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + Vector3.new(0, 0, -1) end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir + Vector3.new(0, 0, 1) end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir + Vector3.new(-1, 0, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + Vector3.new(1, 0, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.E) then moveDir = moveDir + Vector3.new(0, 1, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.Q) then moveDir = moveDir + Vector3.new(0, -1, 0) end
            
            local worldMoveDir = targetRotation:VectorToWorldSpace(moveDir)
            targetFC_CFrame = targetFC_CFrame + (worldMoveDir * (Config.FreecamSpeed * 40) * dt)
            
            if hrp then
                workspace.CurrentCamera.CFrame = CFrame.new(targetFC_CFrame.Position, hrp.Position)
                local look = workspace.CurrentCamera.CFrame.LookVector
                fcRotX = math.asin(look.Y)
                fcRotY = math.atan2(-look.X, -look.Z)
            else
                workspace.CurrentCamera.CFrame = CFrame.new(targetFC_CFrame.Position) * targetRotation
            end
        end
    end)
end

addSliderWithInput(fhScroll, "Speed", 1, 100, 10, 1, nil, function(v) Config.FreecamSpeed = math.clamp(v / 10, 0.1, 10) end)
addSliderWithInput(fhScroll, "Inertia Damping", 1, 50, 15, 2, nil, function(v) Config.FreecamSmoothness = math.clamp(v / 100, 0.01, 1) end)
addSliderWithInput(fhScroll, "Lens FOV", 10, 120, 70, 3, "FreecamFov", function(v) dollyStartFov = v end)
addToggle(fhScroll, "Freeze Character", 4, "FreecamFreezeChar")

createActionButton(fhScroll, "📍 TELEPORT TO FREECAM", Color3.fromRGB(35, 65, 50), function()
    local char = Player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then
        local wasAnchored = hrp.Anchored
        hrp.Anchored = false
        hrp.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position)
        task.wait(0.05)
        hrp.Anchored = wasAnchored
    end
end, 5)

createActionButton(fhScroll, "🎮 Mode: Manual", Theme.CardBg, function() CurrentCinematicMode = "Manual" end, 6)
createActionButton(fhScroll, "🔄 Mode: Orbit", Theme.CardBg, function() CurrentCinematicMode = "Orbit" end, 7)
createActionButton(fhScroll, "🔍 Mode: Dolly Zoom", Theme.CardBg, function() CurrentCinematicMode = "DollyZoom" end, 8)
createActionButton(fhScroll, "➡️ Mode: Auto Pan", Theme.CardBg, function() CurrentCinematicMode = "AutoPan" end, 9)
createActionButton(fhScroll, "🎥 Mode: Handheld", Theme.CardBg, function() CurrentCinematicMode = "Handheld" end, 10)
createActionButton(fhScroll, "🎯 Mode: Target LookAt", Theme.CardBg, function() CurrentCinematicMode = "LookAt" end, 11)

createActionButton(fhScroll, "✕ EXIT FREECAM", Theme.DeleteBg, function()
    Config.FreecamMode = false
    updateFreecamEngine()
end, 12)

-- ====================================================================
-- POPULATING MENU PAGES
-- ====================================================================

-- 1. PLAYER PAGE
addToggle(playerPage, "🚀 Fly Mode", 1, "FlyMode", handleFlyEngine)
addSliderWithInput(playerPage, "Fly Speed", 1, 20, 5, 2, "FlySpeed")
addToggle(playerPage, "👻 Noclip Mode", 3, "Noclip")
addToggle(playerPage, "⚡ Super Speed", 4, "SuperSpeed", enforceHumanoidProperties)
addSliderWithInput(playerPage, "Speed Value", 16, 250, 16, 5, "SuperSpeedVal", enforceHumanoidProperties)
addToggle(playerPage, "🦘 Super Jump", 6, "SuperJump", enforceHumanoidProperties)
addSliderWithInput(playerPage, "Jump Power", 50, 500, 50, 7, "SuperJumpVal", enforceHumanoidProperties)
addToggle(playerPage, "🦘 Infinite Jump", 8, "InfiniteJump")
addSliderWithInput(playerPage, "Global Gravity", 0, 196, 196, 9, "Gravity", function(val) workspace.Gravity = val end)
addSliderWithInput(playerPage, "HipHeight Modifier", 0, 20, 2, 10, "HipHeight", function(val) 
    if Player.Character and Player.Character:FindFirstChildOfClass("Humanoid") then 
        Player.Character:FindFirstChildOfClass("Humanoid").HipHeight = val 
    end 
end)

-- 2. AUTOMATION PAGE
addToggle(autoPage, "⚔️ Fast Attack / Auto Hit", 1, "FastAttack")
addSliderWithInput(autoPage, "Attack Cooldown (s)", 0, 1, 0.05, 2, "AttackDelay")
addToggle(autoPage, "🔘 Expand Proximity (Distance E)", 3, "ExpandProximity")
addSliderWithInput(autoPage, "Proximity Distance (Studs)", 10, 1000, 50, 4, "ProximityDistance")
addToggle(autoPage, "⚡ Instant Hold E (No Delay)", 5, "InstantProximityHold")
addToggle(autoPage, "🧱 Ignore Walls for E (No LineOfSight)", 6, "ProximityLineOfSight")

-- 3. ESP PAGE
addToggle(espPage, "👁️ Enable Master ESP", 1, "EnableESP")
addToggle(espPage, "📦 Show 3D Bounding Boxes", 2, "ShowBoxes")
addToggle(espPage, "🏷️ Show Name & Distance", 3, "ShowNames")
addToggle(espPage, "✨ Show Chams Glow", 4, "ShowGlow")
addToggle(espPage, "🛡️ Enable Team Check", 5, "TeamCheck")
addSliderWithInput(espPage, "ESP Max Distance", 100, 5000, 1000, 6, "MaxDistance")

-- 4. TELEPORT PAGE
addToggle(tpPage, "🌀 Enable Tween Glide", 1, "TweenTeleport")
addSliderWithInput(tpPage, "Tween Speed (Studs/s)", 50, 1000, 350, 2, "TweenSpeed")

local playerTpInputCard = Instance.new("Frame", tpPage)
playerTpInputCard.Size = UDim2.new(1, 0, 0, 26)
playerTpInputCard.BackgroundColor3 = Theme.CardBg
playerTpInputCard.LayoutOrder = 3
Instance.new("UICorner", playerTpInputCard).CornerRadius = UDim.new(0, 5)

local tpPlayerInput = Instance.new("TextBox", playerTpInputCard)
tpPlayerInput.Size = UDim2.new(1, -16, 1, 0)
tpPlayerInput.Position = UDim2.new(0, 8, 0, 0)
tpPlayerInput.BackgroundTransparency = 1
tpPlayerInput.Font = Enum.Font.GothamMedium
tpPlayerInput.PlaceholderText = "Masukkan nama player..."
tpPlayerInput.TextColor3 = Theme.TextMain
tpPlayerInput.PlaceholderColor3 = Theme.TextMuted
tpPlayerInput.TextSize = 10
tpPlayerInput.TextXAlignment = Enum.TextXAlignment.Left

createActionButton(tpPage, "⚡ Teleport ke Player", Theme.HeaderBg, function()
    local targetText = tpPlayerInput.Text:lower():gsub("%s+", "")
    if targetText == "" then return end
    local targetPlayer = nil
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= Player then
            local pName = p.Name:lower()
            local pDisplay = p.DisplayName:lower()
            if pName:sub(1, #targetText) == targetText or pDisplay:sub(1, #targetText) == targetText or pName:find(targetText) or pDisplay:find(targetText) then
                targetPlayer = p
                break
            end
        end
    end
    if targetPlayer and targetPlayer.Character then
        local targetHrp = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
        local myHrp = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
        if targetHrp and myHrp then
            local targetCF = targetHrp.CFrame * CFrame.new(0, 2, 0)
            if not bypassTeleportWithTween(targetCF) then 
                myHrp.CFrame = targetCF 
            end
        end
    end
end, 4)

local wpInputCard = Instance.new("Frame", tpPage)
wpInputCard.Size = UDim2.new(1, 0, 0, 26)
wpInputCard.BackgroundColor3 = Theme.CardBg
wpInputCard.LayoutOrder = 5
Instance.new("UICorner", wpInputCard).CornerRadius = UDim.new(0, 5)

local wpNameInput = Instance.new("TextBox", wpInputCard)
wpNameInput.Size = UDim2.new(1, -16, 1, 0)
wpNameInput.Position = UDim2.new(0, 8, 0, 0)
wpNameInput.BackgroundTransparency = 1
wpNameInput.Font = Enum.Font.GothamMedium
wpNameInput.PlaceholderText = "Nama waypoint baru..."
wpNameInput.TextColor3 = Theme.TextMain
wpNameInput.PlaceholderColor3 = Theme.TextMuted
wpNameInput.TextSize = 10
wpNameInput.TextXAlignment = Enum.TextXAlignment.Left

local btnSavePos = createActionButton(tpPage, "💾 Simpan Posisi Saat Ini", Color3.fromRGB(35, 55, 45), function() end, 6)

local waypointsListFrame = Instance.new("Frame", tpPage)
waypointsListFrame.Size = UDim2.new(1, 0, 0, 0)
waypointsListFrame.AutomaticSize = Enum.AutomaticSize.Y
waypointsListFrame.BackgroundTransparency = 1
waypointsListFrame.LayoutOrder = 7

local wpLayout = Instance.new("UIListLayout", waypointsListFrame)
wpLayout.Padding = UDim.new(0, 4)
wpLayout.SortOrder = Enum.SortOrder.LayoutOrder

local refreshLandmarksUI

local function deleteWaypoint(wpName)
    if AllWaypoints[CurrentPlaceId] and AllWaypoints[CurrentPlaceId][wpName] then
        AllWaypoints[CurrentPlaceId][wpName] = nil 
        saveWaypointsToStorage() 
        refreshLandmarksUI()
    end
end

-- Waypoints System Task
task.spawn(function()
    local char = Player.Character or Player.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart", 10)
    local hum = char:WaitForChild("Humanoid", 10)
    
    if not hrp or not hum then return end
    
    for i = 1, 30 do
        if hum.FloorMaterial ~= Enum.Material.Air or hrp.Velocity.Magnitude < 0.1 then break end
        task.wait(0.5)
    end
    task.wait(1.5)
    
    local spawnPos = hrp.Position
    local initialSpawnCFrame = CFrame.new(spawnPos.X, spawnPos.Y + 3.5, spawnPos.Z)

    local function makeTeleportRow(wpName, targetX, targetY, targetZ, orderIndex)
        local rowFrame = Instance.new("Frame", waypointsListFrame) 
        rowFrame.Size = UDim2.new(1, 0, 0, 24) 
        rowFrame.BackgroundTransparency = 1 
        rowFrame.LayoutOrder = orderIndex
        
        local btn = Instance.new("TextButton", rowFrame) 
        btn.Size = UDim2.new(1, -28, 1, 0) 
        btn.BackgroundColor3 = Theme.CardBg 
        btn.Font = Enum.Font.GothamMedium 
        btn.Text = "📌 " .. wpName 
        btn.TextColor3 = Theme.TextMain 
        btn.TextSize = 10 
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5) 
        
        btn.MouseButton1Click:Connect(function()
            if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
                local targetCF = CFrame.new(tonumber(targetX) or 0, tonumber(targetY) or 0, tonumber(targetZ) or 0)
                if not bypassTeleportWithTween(targetCF) then Player.Character.HumanoidRootPart.CFrame = targetCF end
            end
        end)
        
        local delBtn = Instance.new("TextButton", rowFrame) 
        delBtn.Size = UDim2.new(0, 24, 1, 0) 
        delBtn.Position = UDim2.new(1, -24, 0, 0) 
        delBtn.BackgroundColor3 = Theme.DeleteBg 
        delBtn.Font = Enum.Font.GothamBold 
        delBtn.Text = "✕" 
        delBtn.TextColor3 = Theme.DeleteRed 
        delBtn.TextSize = 10 
        Instance.new("UICorner", delBtn).CornerRadius = UDim.new(0, 5)
        
        delBtn.MouseButton1Click:Connect(function() 
            showConfirmation("Hapus posisi \"" .. wpName .. "\"? ", function() deleteWaypoint(wpName) end) 
        end)
    end

    function refreshLandmarksUI()
        for _, child in pairs(waypointsListFrame:GetChildren()) do 
            if child:IsA("Frame") then child:Destroy() end 
        end
        
        local rowFrameSpawn = Instance.new("Frame", waypointsListFrame) 
        rowFrameSpawn.Size = UDim2.new(1, 0, 0, 24) 
        rowFrameSpawn.BackgroundTransparency = 1 
        rowFrameSpawn.LayoutOrder = 0
        
        local btnSpawn = Instance.new("TextButton", rowFrameSpawn) 
        btnSpawn.Size = UDim2.new(1, 0, 1, 0) 
        btnSpawn.BackgroundColor3 = Color3.fromRGB(24, 45, 36) 
        btnSpawn.Font = Enum.Font.GothamBold 
        btnSpawn.Text = "📍 Initial Spawn Point" 
        btnSpawn.TextColor3 = Theme.ConfirmGreen 
        btnSpawn.TextSize = 10 
        Instance.new("UICorner", btnSpawn).CornerRadius = UDim.new(0, 5) 
        
        btnSpawn.MouseButton1Click:Connect(function()
            if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
                if not bypassTeleportWithTween(initialSpawnCFrame) then Player.Character.HumanoidRootPart.CFrame = initialSpawnCFrame end
            end
        end)
        
        if not AllWaypoints[CurrentPlaceId] then AllWaypoints[CurrentPlaceId] = {} end
        local currentMapData = AllWaypoints[CurrentPlaceId]
        local indexOrder = 1
        
        for wpName, coord in pairs(currentMapData) do
            if type(coord) == "table" then
                makeTeleportRow(wpName, coord.X or 0, coord.Y or 0, coord.Z or 0, indexOrder)
                indexOrder = indexOrder + 1
            end
        end
    end

    btnSavePos.MouseButton1Click:Connect(function()
        local name = wpNameInput.Text
        if name ~= "" and name ~= "Initial Spawn Point" then
            if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
                local currentPos = Player.Character.HumanoidRootPart.Position
                if not AllWaypoints[CurrentPlaceId] then AllWaypoints[CurrentPlaceId] = {} end
                
                AllWaypoints[CurrentPlaceId][name] = {
                    X = math.round(currentPos.X * 100) / 100, 
                    Y = math.round(currentPos.Y * 100) / 100, 
                    Z = math.round(currentPos.Z * 100) / 100
                }
                saveWaypointsToStorage() 
                wpNameInput.Text = "" 
                refreshLandmarksUI()
             end
        end
    end)

    refreshLandmarksUI()
end)

-- 5. SERVER PAGE
local lblFps = createStatLabel(serverPage, "FPS: 00.0", 1)
local lblPing = createStatLabel(serverPage, "Ping: 0.00 ms", 2)
local lblTime = createStatLabel(serverPage, "Server Age: 00:00:00", 3)

task.spawn(function()
    local lastTime = os.clock() 
    local frameCount = 0 
    local currentFps = 60

    while task.wait(0.1) do
        if not MainGui or not MainGui.Parent then break end
        frameCount = frameCount + 1 
        local now = os.clock()
        
        if now - lastTime >= 0.5 then 
            currentFps = math.round(frameCount / (now - lastTime)) 
            frameCount = 0 
            lastTime = now 
        end
        
        local pingVal = 0 
        pcall(function() pingVal = math.round(Stats.Network.ServerToClientPingPerSecond:GetLastValue() * 1000) end)
        if pingVal <= 0 then pingVal = math.round(Player:GetNetworkPing() * 2000) end
        if pingVal <= 0 then pingVal = 15 end
        
        local sTime = math.round(workspace.DistributedGameTime)
        local hours = string.format("%02d", math.floor(sTime / 3600)) 
        local minutes = string.format("%02d", math.floor((sTime % 3600) / 60)) 
        local seconds = string.format("%02d", sTime % 60)
        
        lblFps.Text = "FPS: " .. tostring(currentFps) .. " FPS" 
        lblPing.Text = "Ping: " .. tostring(pingVal) .. " ms" 
        lblTime.Text = "Server Age: " .. hours .. ":" .. minutes .. ":" .. seconds
    end
end)

createActionButton(serverPage, "🔄 Rejoin Current Instance", Theme.CardBg, function()
    showConfirmation("Rejoin ke server saat ini?", function() TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, Player) end)
end, 4)

createActionButton(serverPage, "🚀 Matchmaking Server Hop", Theme.CardBg, function()
    showConfirmation("Cari dan pindah server?", function()
        local success, servers = pcall(function() return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100")) end)
        if success and servers and servers.data then
            for _, s in pairs(servers.data) do
                if s.playing < s.maxPlayers and s.id ~= game.JobId then TeleportService:TeleportToPlaceInstance(game.PlaceId, s.id, Player) break end
            end
        end
    end)
end, 5)

createActionButton(serverPage, "🗑️ Purge Environmental Memory", Color3.fromRGB(45, 35, 30), function()
    local c = 0 
    for _, o in pairs(workspace:GetDescendants()) do 
        if o:IsA("VisualEffect") or o:IsA("Decal") or o:IsA("Texture") then o:Destroy() c = c + 1 end 
    end
    showConfirmation("Berhasil membersihkan " .. tostring(c) .. " objek lag.", function() end)
end, 6)

addToggle(serverPage, "Disable Global Shadows", 7, "ShadowsDisabled", applyGraphicsBoost)
addToggle(serverPage, "Anti-Lag Core Engine", 8, "AntiLag", applyGraphicsBoost)
addToggle(serverPage, "💡 FullBright Core Engine", 9, "FullBright", function(active)
    if active then
        Lighting.Ambient = Color3.fromRGB(255, 255, 255) 
        Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255) 
        Lighting.Brightness = 2 
        Lighting.ClockTime = 14
    else
        Lighting.Ambient = origAmbient 
        Lighting.OutdoorAmbient = origOutdoorAmbient 
        Lighting.Brightness = origBrightness 
        Lighting.ClockTime = origClockTime
    end
end)

-- 6. SETTINGS PAGE
createStatLabel(settingPage, "User: " .. Player.Name .. " (" .. Player.UserId .. ")", 1)
createStatLabel(settingPage, "Executor: " .. CurrentExecutor, 2)
createStatLabel(settingPage, "Map: " .. CurrentMapName, 3)

createActionButton(settingPage, "👁️ Hide All GUIs (Clean View)", Theme.CardBg, function()
    toggleCleanGuiView(true)
end, 4)

createActionButton(settingPage, "🎥 Open Freecam Cinematic Engine", Theme.HeaderBg, function()
    Config.FreecamMode = true
    updateFreecamEngine()
end, 5)

createActionButton(settingPage, "🔄 Reload System UI", Theme.CardBg, function()
    showConfirmation("Apakah kamu ingin memuat ulang UI?", function()
        if Config.FlyMode then Config.FlyMode = false pcall(handleFlyEngine) end
        local currentScript = MainGui:GetAttribute("ScriptContent") or ""
        MainGui:Destroy()
        task.wait(0.15)
        if loadstring and currentScript ~= "" then
            pcall(function() loadstring(currentScript)() end)
        end
    end)
end, 6)

createActionButton(settingPage, "🔴 Close System UI", Theme.DeleteBg, function()
    showConfirmation("Apakah kamu ingin menutup UI?", function() MainGui:Destroy() end)
end, 7)

-- ====================================================================
-- INITIALIZATION ENGINE & LICENSE KEY VERIFICATION
-- ====================================================================
task.spawn(function()
    if KeyVerified then
        MainFrame.Visible = true 
        ToggleButton.Visible = false 
    else
        local KeyFrame = Instance.new("Frame")
        KeyFrame.Name = "KeyFrame" 
        KeyFrame.Parent = MainGui 
        KeyFrame.Size = UDim2.new(0, 230, 0, 130) 
        KeyFrame.Position = UDim2.new(0.5, -115, 0.5, -65) 
        KeyFrame.BackgroundColor3 = Theme.Bg 
        Instance.new("UICorner", KeyFrame).CornerRadius = UDim.new(0, 8)
        
        local keyStroke = Instance.new("UIStroke", KeyFrame) 
        keyStroke.Color = Theme.HeaderBg 
        keyStroke.Thickness = 1.2

        local KeyTitle = Instance.new("TextLabel", KeyFrame) 
        KeyTitle.Size = UDim2.new(1, 0, 0, 30) 
        KeyTitle.Text = "ENTER LICENSE KEY" 
        KeyTitle.Font = Enum.Font.GothamBold 
        KeyTitle.TextColor3 = Theme.TextMain 
        KeyTitle.TextSize = 10 
        KeyTitle.BackgroundTransparency = 1
        
        local KeyInput = Instance.new("TextBox", KeyFrame) 
        KeyInput.Size = UDim2.new(1, -24, 0, 26) 
        KeyInput.Position = UDim2.new(0, 12, 0, 38) 
        KeyInput.BackgroundColor3 = Theme.CardBg 
        KeyInput.Font = Enum.Font.GothamMedium 
        KeyInput.PlaceholderText = "Paste key here..." 
        KeyInput.Text = "" 
        KeyInput.TextColor3 = Theme.TextMain 
        KeyInput.PlaceholderColor3 = Theme.TextMuted 
        KeyInput.TextSize = 10 
        Instance.new("UICorner", KeyInput).CornerRadius = UDim.new(0, 5) 
        
        local SubmitBtn = Instance.new("TextButton", KeyFrame) 
        SubmitBtn.Size = UDim2.new(1, -24, 0, 26) 
        SubmitBtn.Position = UDim2.new(0, 12, 1, -36) 
        SubmitBtn.BackgroundColor3 = Theme.HeaderBg 
        SubmitBtn.Font = Enum.Font.GothamBold 
        SubmitBtn.Text = "VERIFY KEY" 
        SubmitBtn.TextColor3 = Theme.TextMain 
        SubmitBtn.TextSize = 10 
        Instance.new("UICorner", SubmitBtn).CornerRadius = UDim.new(0, 5)

        SubmitBtn.MouseButton1Click:Connect(function()
            if KeyInput.Text == CorrectKey then
                saveKeyStatus() 
                KeyFrame:Destroy() 
                MainFrame.Visible = true 
                ToggleButton.Visible = false 
            else
                KeyInput.Text = "" 
                KeyInput.PlaceholderText = "INVALID KEY! Try Again..." 
                KeyInput.PlaceholderColor3 = Theme.DeleteRed
            end
        end)
    end
end)
