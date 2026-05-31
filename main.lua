-- ====================================================================
-- AR SCRIPT HUB - v7.1
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

local MainGui = Instance.new("ScreenGui")
MainGui.Name = "AR_Script_Hub"
MainGui.Parent = SafeGuiTarget
MainGui.ResetOnSpawn = false
MainGui.DisplayOrder = 2147483647

local rawSource = debug.infos and debug.infos() or "" 
MainGui:SetAttribute("ScriptContent", rawSource)

local Theme = {
    Bg = Color3.fromRGB(12, 10, 24),         
    BgTrans = 0.15,                          
    CardBg = Color3.fromRGB(20, 22, 38),     
    CardTrans = 0.4,                      
    Stroke = Color3.fromRGB(56, 52, 92),     
    Accent = Color3.fromRGB(115, 170, 255),  
    AccentPurple = Color3.fromRGB(190, 130, 255), 
    TextMain = Color3.fromRGB(245, 245, 255),
    TextMuted = Color3.fromRGB(140, 145, 175),
    DeleteRed = Color3.fromRGB(255, 90, 90),
    DeleteBg = Color3.fromRGB(50, 25, 35),
    ConfirmGreen = Color3.fromRGB(90, 255, 140)
}

-- ====================================================================
-- STATE MANAGEMENT CONFIGURATION
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
    AntiRagdoll = false,
    InfiniteOxygen = false,
    EnableESP = false,
    ShowBoxes = false,
    ShowNames = false,
    ShowGlow = false,
    TeamCheck = false,
    MaxDistance = 1000,
    ShadowsDisabled = false,
    AntiLag = false,
    UiTransparency = 0.15,
    TweenTeleport = false,
    TweenSpeed = 350,
    FullBright = false,
    Freecam = false
}

local FILE_NAME = "AR_Hub_Waypoints_v71.json"
local CurrentPlaceId = tostring(game.PlaceId)
local AllWaypoints = {}

local Lighting = game:GetService("Lighting")
local origAmbient = Lighting.Ambient
local origOutdoorAmbient = Lighting.OutdoorAmbient
local origBrightness = Lighting.Brightness
local origClockTime = Lighting.ClockTime

-- ====================================================================
-- CONFIG KEY SYSTEM (24 JAM BYPASS)
-- ====================================================================
local KEY_FILE_NAME = "AR_Hub_KeySystem.json"
local CorrectKey = "AR_PREMIUM_KEY"
local KeyVerified = false

local function loadKeyStatus()
    local success, content = pcall(function() return readfile(KEY_FILE_NAME) end)
    if success and content then
        local decodeSuccess, decodedData = pcall(function() return HttpService:JSONDecode(content) end)
        if decodeSuccess and type(decodedData) == "table" then
            if decodedData.Timestamp and (os.time() - decodedData.Timestamp) < 86400 then
                if decodedData.Key == CorrectKey then KeyVerified = true end
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
    if productInfo and productInfo.Name then CurrentMapName = productInfo.Name end
end)

local CurrentExecutor = (identifyexecutor or getexecutorname or function() return "Unknown Executor" end)()

-- ====================================================================
-- REAL BACKGROUND FUNCTIONAL ENGINE (ANTI-BUG FLY)
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
    if not Config.FlyMode then stopFlying() return end
    stopFlying()
    local char = Player.Character if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local torso = char.HumanoidRootPart
    local hum = char:FindFirstChildOfClass("Humanoid") if not hum then return end
    
    flyBg = Instance.new("BodyGyro", torso) flyBg.P = 9e4 flyBg.maxTorque = Vector3.new(9e9, 9e9, 9e9) flyBg.cframe = torso.CFrame
    flyBv = Instance.new("BodyVelocity", torso) flyBv.velocity = Vector3.new(0, 0, 0) flyBv.maxForce = Vector3.new(9e9, 9e9, 9e9)
    
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
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then verticalSpeed = speed
            elseif UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then verticalSpeed = -speed end
            
            if verticalSpeed ~= 0 then flyBv.velocity = Vector3.new(finalVelocity.X, verticalSpeed, finalVelocity.Z)
            else flyBv.velocity = finalVelocity end
            
            flyBg.cframe = camCF
            task.wait()
        end
        stopFlying()
    end)
end

-- ====================================================================
-- FREECAM FUNCTIONAL ENGINE
-- ====================================================================
local FreecamPart
local FreecamConnection

local function handleFreecamEngine(active)
    local camera = workspace.CurrentCamera
    if active then
        camera.CameraType = Enum.CameraType.Scriptable
        
        FreecamPart = Instance.new("Part")
        FreecamPart.Size = Vector3.new(1, 1, 1)
        FreecamPart.Transparency = 1
        FreecamPart.Anchored = true
        FreecamPart.CanCollide = false
        FreecamPart.CFrame = camera.CFrame
        FreecamPart.Parent = workspace
        
        FreecamConnection = RunService.RenderStepped:Connect(function()
            if not Config.Freecam then return end
            local speed = Config.FlySpeed * 2.5
            local moveDir = Vector3.new(0, 0, 0)
            
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0, 1, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveDir = moveDir - Vector3.new(0, 1, 0) end
            
            if moveDir.Magnitude > 0 then
                FreecamPart.CFrame = FreecamPart.CFrame + (moveDir.Unit * (speed / 10))
            end
            
            camera.CFrame = FreecamPart.CFrame
        end)
    else
        if FreecamConnection then FreecamConnection:Disconnect() FreecamConnection = nil end
        if FreecamPart then FreecamPart:Destroy() FreecamPart = nil end
        camera.CameraType = Enum.CameraType.Custom
    end
end

UserInputService.JumpRequest:Connect(function()
    if Config.InfiniteJump and Player.Character then
        local hum = Player.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

RunService.Stepped:Connect(function()
    if Config.Noclip and Player.Character then
        for _, part in pairs(Player.Character:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then part.CanCollide = false end
        end
    end
end)

local function enforceHumanoidProperties()
    if Player.Character and Player.Character:FindFirstChildOfClass("Humanoid") then
        local hum = Player.Character:FindFirstChildOfClass("Humanoid")
        hum.WalkSpeed = Config.SuperSpeed and Config.SuperSpeedVal or 16
        hum.JumpPower = Config.SuperJump and Config.SuperJumpVal or 50
        hum.UseJumpPower = true
    end
end

Player.CharacterAdded:Connect(function(char)
    char:WaitForChild("Humanoid", 5)
    enforceHumanoidProperties()
    if Config.FlyMode then task.wait(0.1) handleFlyEngine() end
end)

task.spawn(function()
    while task.wait(0.3) do
        if Config.AntiRagdoll and Player.Character and Player.Character:FindFirstChildOfClass("Humanoid") then
            local hum = Player.Character:FindFirstChildOfClass("Humanoid")
            hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
            hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
        end
        if Config.InfiniteOxygen and Player.Character then
            local oxygen = Player.Character:FindFirstChild("Oxygen") or Player:FindFirstChild("Oxygen")
            if oxygen and oxygen:IsA("NumberValue") then oxygen.Value = 100 end
        end
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
        tween.Completed:Connect(function() bodyVelocity:Destroy() end)
        return true
    end
    return false
end

-- ====================================================================
-- ESP GLOW & CHAMS ENGINE
-- ====================================================================
local espCache = {}
local function cleanESP(target)
    if espCache[target] then
        if espCache[target].Box then espCache[target].Box:Destroy() end
        if espCache[target].Label then espCache[target].Label:Destroy() end
        if espCache[target].Highlight then espCache[target].Highlight:Destroy() end
        espCache[target] = nil
   end
end

local function buildESP(target)
    if target == Player then return end
    RunService.RenderStepped:Connect(function()
        if not Config.EnableESP or not target.Character or not target.Character:FindFirstChild("HumanoidRootPart") or not Player.Character or not Player.Character:FindFirstChild("HumanoidRootPart") then
            cleanESP(target) return
        end
        local tChar = target.Character local tHrp = tChar.HumanoidRootPart local pHrp = Player.Character.HumanoidRootPart
        local camera = workspace.CurrentCamera 
        local _, onScreen = camera:WorldToViewportPoint(tHrp.Position)
        local distance = (pHrp.Position - tHrp.Position).Magnitude

        if Config.TeamCheck and target.Team == Player.Team then cleanESP(target) return end
        if distance > Config.MaxDistance then cleanESP(target) return end
        if not espCache[target] then espCache[target] = {} end

        if Config.ShowBoxes and onScreen then
            if not espCache[target].Box then
                local b = Instance.new("BoxHandleAdornment") b.Size = Vector3.new(4, 5.5, 4) b.Color3 = Theme.Accent b.AlwaysOnTop = true b.Transparency = 0.6 espCache[target].Box = b
            end
            espCache[target].Box.Adornee = tChar espCache[target].Box.Parent = SafeGuiTarget
        else
            if espCache[target].Box then espCache[target].Box:Destroy() espCache[target].Box = nil end
        end

        if Config.ShowNames and onScreen then
            if not espCache[target].Label then
                local bgui = Instance.new("BillboardGui") bgui.Size = UDim2.new(0, 150, 0, 40) bgui.AlwaysOnTop = true bgui.StudsOffset = Vector3.new(0, 3, 0)
                local txt = Instance.new("TextLabel", bgui) txt.Size = UDim2.new(1, 0, 1, 0) txt.BackgroundTransparency = 1 txt.TextColor3 = Theme.TextMain txt.Font = Enum.Font.GothamBold txt.TextSize = 10 espCache[target].Label = bgui espCache[target].TxtObject = txt
            end
            espCache[target].TxtObject.Text = string.format("%s\n[%d m]", target.DisplayName, math.round(distance))
            espCache[target].Label.Adornee = tHrp espCache[target].Label.Parent = SafeGuiTarget
        else
            if espCache[target].Label then espCache[target].Label:Destroy() espCache[target].Label = nil end
        end

        if Config.ShowGlow then
            if not espCache[target].Highlight then
                local hl = Instance.new("Highlight") hl.FillColor = Theme.AccentPurple hl.FillTransparency = 0.4 hl.OutlineColor = Theme.TextMain hl.OutlineTransparency = 0.1 hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop espCache[target].Highlight = hl
            end
            espCache[target].Highlight.Adornee = tChar espCache[target].Highlight.Parent = SafeGuiTarget
        else
            if espCache[target].Highlight then espCache[target].Highlight:Destroy() espCache[target].Highlight = nil end
        end
    end)
end

Players.PlayerAdded:Connect(buildESP)
for _, p in pairs(Players:GetPlayers()) do buildESP(p) end

local function applyGraphicsBoost()
    game:GetService("Lighting").GlobalShadows = not Config.ShadowsDisabled
    if Config.AntiLag then settings().Rendering.QualityLevel = Enum.QualityLevel.Level01 end
end

-- ====================================================================
-- WAYPOINT MANAGEMENT STORAGE (FIXED DICTIONARY STRUCT)
-- ====================================================================
local function loadWaypointsFromStorage()
    AllWaypoints = {}
    local success, content = pcall(function() return readfile(FILE_NAME) end)
    if success and content then
        local decodeSuccess, decodedData = pcall(function() return HttpService:JSONDecode(content) end)
        if decodeSuccess and type(decodedData) == "table" then AllWaypoints = decodedData end
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
-- COUPLING INTERFACE BUILDER
-- ====================================================================
local PopupFrame = Instance.new("Frame")
PopupFrame.Name = "PopupFrame" PopupFrame.Parent = MainGui PopupFrame.Size = UDim2.new(0, 280, 0, 140) PopupFrame.Position = UDim2.new(0.5, -140, 0.5, -70) PopupFrame.BackgroundColor3 = Theme.Bg PopupFrame.BackgroundTransparency = Config.UiTransparency PopupFrame.Visible = false PopupFrame.ZIndex = 1000 Instance.new("UICorner", PopupFrame).CornerRadius = UDim.new(0, 10)
local popStroke = Instance.new("UIStroke", PopupFrame) popStroke.Color = Theme.AccentPurple popStroke.Thickness = 1.5

local PopupText = Instance.new("TextLabel", PopupFrame) PopupText.Size = UDim2.new(1, -24, 0, 50) PopupText.Position = UDim2.new(0, 12, 0, 20) PopupText.Text = "Apakah anda yakin?" PopupText.Font = Enum.Font.GothamBold PopupText.TextColor3 = Theme.TextMain PopupText.TextSize = 13 PopupText.TextWrapped = true PopupText.BackgroundTransparency = 1 PopupText.ZIndex = 1001

local PopupYes = Instance.new("TextButton", PopupFrame) PopupYes.Size = UDim2.new(0, 110, 0, 30) PopupYes.Position = UDim2.new(0, 20, 1, -45) PopupYes.BackgroundColor3 = Color3.fromRGB(30, 60, 45) PopupYes.Font = Enum.Font.GothamBold PopupYes.Text = "YA" PopupYes.TextColor3 = Theme.ConfirmGreen PopupYes.TextSize = 12 PopupYes.ZIndex = 1001 Instance.new("UICorner", PopupYes).CornerRadius = UDim.new(0, 5) Instance.new("UIStroke", PopupYes).Color = Theme.Stroke

local PopupNo = Instance.new("TextButton", PopupFrame) PopupNo.Size = UDim2.new(0, 110, 0, 30) PopupNo.Position = UDim2.new(1, -130, 1, -45) PopupNo.BackgroundColor3 = Color3.fromRGB(60, 30, 35) PopupNo.Font = Enum.Font.GothamBold PopupNo.Text = "TIDAK" PopupNo.TextColor3 = Theme.DeleteRed PopupNo.TextSize = 12 PopupNo.ZIndex = 1001 Instance.new("UICorner", PopupNo).CornerRadius = UDim.new(0, 5) Instance.new("UIStroke", PopupNo).Color = Theme.Stroke

local currentCallback = nil
local function showConfirmation(message, onYes)
    PopupText.Text = message currentCallback = onYes PopupFrame.Visible = true PopupFrame.Size = UDim2.new(0, 250, 0, 120)
    TweenService:Create(PopupFrame, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 280, 0, 140)}):Play()
end
PopupYes.MouseButton1Click:Connect(function() PopupFrame.Visible = false if currentCallback then currentCallback() end end)
PopupNo.MouseButton1Click:Connect(function() PopupFrame.Visible = false end)

local LoadingFrame = Instance.new("Frame")
LoadingFrame.Name = "LoadingFrame" LoadingFrame.Parent = MainGui LoadingFrame.Size = UDim2.new(0, 320, 0, 180) LoadingFrame.Position = UDim2.new(0.5, -160, 0.5, -90) LoadingFrame.BackgroundColor3 = Theme.Bg LoadingFrame.BackgroundTransparency = 0.05 Instance.new("UICorner", LoadingFrame).CornerRadius = UDim.new(0, 10)
local loadStroke = Instance.new("UIStroke", LoadingFrame) loadStroke.Color = Theme.Stroke loadStroke.Thickness = 1.5

local LoadTitle = Instance.new("TextLabel", LoadingFrame) LoadTitle.Size = UDim2.new(1, 0, 0, 40) LoadTitle.Position = UDim2.new(0, 0, 0, 25) LoadTitle.Text = "AR SCRIPT HUB" LoadTitle.Font = Enum.Font.GothamBold LoadTitle.TextColor3 = Theme.TextMain LoadTitle.TextSize = 18 LoadTitle.BackgroundTransparency = 1
local LoadStatus = Instance.new("TextLabel", LoadingFrame) LoadStatus.Size = UDim2.new(1, 0, 0, 20) LoadStatus.Position = UDim2.new(0, 0, 0, 65) LoadStatus.Text = "Menginisialisasi core script..." LoadStatus.Font = Enum.Font.GothamMedium LoadStatus.TextColor3 = Theme.TextMuted LoadStatus.TextSize = 11 LoadStatus.BackgroundTransparency = 1
local LoadProgressText = Instance.new("TextLabel", LoadingFrame) LoadProgressText.Size = UDim2.new(1, 0, 0, 20) LoadProgressText.Position = UDim2.new(0, 0, 0, 90) LoadProgressText.Text = "0%" LoadProgressText.Font = Enum.Font.GothamBold LoadProgressText.TextColor3 = Theme.AccentPurple LoadProgressText.TextSize = 14 LoadProgressText.BackgroundTransparency = 1
local LoadTrack = Instance.new("Frame", LoadingFrame) LoadTrack.Size = UDim2.new(1, -60, 0, 6) LoadTrack.Position = UDim2.new(0, 30, 0, 125) LoadTrack.BackgroundColor3 = Theme.CardBg Instance.new("UICorner", LoadTrack).CornerRadius = UDim.new(0, 3) local ltStroke = Instance.new("UIStroke", LoadTrack) ltStroke.Color = Theme.Stroke
local LoadFill = Instance.new("Frame", LoadTrack) LoadFill.Size = UDim2.new(0, 0, 1, 0) LoadFill.BackgroundColor3 = Theme.Accent Instance.new("UICorner", LoadFill).CornerRadius = UDim.new(0, 3)

local function makeDraggable(frame, dragHandle)
    local dragging, dragInput, dragStart, startPos
    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true dragStart = input.Position startPos = frame.Position
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
        end
    end)
    dragHandle.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

local ToggleButton = Instance.new("TextButton")
ToggleButton.Name = "ToggleButton" ToggleButton.Parent = MainGui ToggleButton.Size = UDim2.new(0, 46, 0, 46) ToggleButton.Position = UDim2.new(0.02, 0, 0.2, 0) ToggleButton.BackgroundColor3 = Theme.Bg ToggleButton.BackgroundTransparency = Config.UiTransparency ToggleButton.Font = Enum.Font.GothamBold ToggleButton.Text = "AR" ToggleButton.TextColor3 = Theme.Accent ToggleButton.TextSize = 16 ToggleButton.Visible = false Instance.new("UICorner", ToggleButton).CornerRadius = UDim.new(0, 9)
local tbStroke = Instance.new("UIStroke", ToggleButton) tbStroke.Color = Theme.AccentPurple makeDraggable(ToggleButton, ToggleButton)

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame" MainFrame.Parent = MainGui MainFrame.Size = UDim2.new(0, 560, 0, 340) MainFrame.Position = UDim2.new(0.5, -280, 0.5, -170) MainFrame.BackgroundColor3 = Theme.Bg MainFrame.BackgroundTransparency = Config.UiTransparency MainFrame.Visible = false Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)
local mainStroke = Instance.new("UIStroke", MainFrame) mainStroke.Color = Theme.Stroke mainStroke.Thickness = 1.5

local function updateUiTransparency(value)
    Config.UiTransparency = value MainFrame.BackgroundTransparency = value ToggleButton.BackgroundTransparency = value PopupFrame.BackgroundTransparency = value
end

local Header = Instance.new("Frame", MainFrame) Header.Size = UDim2.new(1, 0, 0, 40) Header.BackgroundTransparency = 1
local Title = Instance.new("TextLabel", Header) Title.Text = "AR SCRIPT HUB <font color='#c092ff'>v7.1</font>" Title.RichText = true Title.Size = UDim2.new(0.5, 0, 1, 0) Title.Position = UDim2.new(0, 16, 0, 0) Title.Font = Enum.Font.GothamBold Title.TextColor3 = Theme.TextMain Title.TextSize = 14 Title.TextXAlignment = Enum.TextXAlignment.Left Title.BackgroundTransparency = 1
local CloseBtn = Instance.new("TextButton", Header) CloseBtn.Text = "×" CloseBtn.Size = UDim2.new(0, 35, 1, 0) CloseBtn.Position = UDim2.new(1, -35, 0, 0) CloseBtn.Font = Enum.Font.GothamMedium CloseBtn.TextColor3 = Theme.DeleteRed CloseBtn.TextSize = 24 CloseBtn.BackgroundTransparency = 1
local MinimizeBtn = Instance.new("TextButton", Header) MinimizeBtn.Text = "−" MinimizeBtn.Size = UDim2.new(0, 35, 1, 0) MinimizeBtn.Position = UDim2.new(1, -70, 0, 0) MinimizeBtn.Font = Enum.Font.GothamMedium MinimizeBtn.TextColor3 = Theme.TextMuted MinimizeBtn.TextSize = 20 MinimizeBtn.BackgroundTransparency = 1

makeDraggable(MainFrame, Header)
ToggleButton.MouseButton1Click:Connect(function() MainFrame.Visible = true ToggleButton.Visible = false end)
MinimizeBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false ToggleButton.Visible = true end)
CloseBtn.MouseButton1Click:Connect(function() showConfirmation("Hub akan ditutup secara permanen,\napakah kamu yakin?", function() MainGui:Destroy() end) end)

local TopBarNav = Instance.new("Frame", MainFrame) TopBarNav.Name = "TopBarNav" TopBarNav.Size = UDim2.new(1, -32, 0, 36) TopBarNav.Position = UDim2.new(0, 16, 0, 45) TopBarNav.BackgroundColor3 = Theme.CardBg TopBarNav.BackgroundTransparency = 0.6 Instance.new("UICorner", TopBarNav).CornerRadius = UDim.new(0, 6) local navStroke = Instance.new("UIStroke", TopBarNav) navStroke.Color = Theme.Stroke
local NavLayout = Instance.new("UIListLayout", TopBarNav) NavLayout.FillDirection = Enum.FillDirection.Horizontal NavLayout.SortOrder = Enum.SortOrder.LayoutOrder NavLayout.VerticalAlignment = Enum.VerticalAlignment.Center NavLayout.Padding = UDim.new(0, 4)
local paddingNav = Instance.new("UIPadding", TopBarNav) paddingNav.PaddingLeft = UDim.new(0, 6)

local MainContentFrame = Instance.new("ScrollingFrame", MainFrame) MainContentFrame.Name = "MainContentFrame" MainContentFrame.Size = UDim2.new(1, -16, 1, -105) MainContentFrame.Position = UDim2.new(0, 0, 0, 95) MainContentFrame.BackgroundTransparency = 1 MainContentFrame.CanvasSize = UDim2.new(0, 0, 0, 0) MainContentFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y MainContentFrame.ScrollBarThickness = 3 MainContentFrame.ScrollBarImageColor3 = Theme.Accent
local framePadding = Instance.new("UIPadding", MainContentFrame) framePadding.PaddingTop = UDim.new(0, 4) framePadding.PaddingBottom = UDim.new(0, 20) framePadding.PaddingLeft = UDim.new(0, 16)

local menuContainers = {}
local function createMenuPage(name, isVisible)
    local page = Instance.new("Frame", MainContentFrame) page.Name = name .. "Page" page.Size = UDim2.new(1, -16, 0, 0) page.AutomaticSize = Enum.AutomaticSize.Y page.BackgroundTransparency = 1 page.Visible = isVisible 
    local layout = Instance.new("UIListLayout", page) layout.SortOrder = Enum.SortOrder.LayoutOrder layout.Padding = UDim.new(0, 8)
    menuContainers[name] = page return page
end

local playerPage = createMenuPage("Player", true)
local espPage = createMenuPage("ESP", false)
local tpPage = createMenuPage("Teleportation", false)
local utilityPage = createMenuPage("Utility", false)
local serverPage = createMenuPage("Server", false)
local settingPage = createMenuPage("Setting", false)

local function switchTab(tabName)
    for name, page in pairs(menuContainers) do page.Visible = (name == tabName) end
    MainContentFrame.CanvasPosition = Vector2.new(0, 0)
end

local function addTopBarButton(textDisplay, tabTarget, order)
    local btn = Instance.new("TextButton", TopBarNav) btn.Size = UDim2.new(0, 80, 0, 26) btn.BackgroundColor3 = Color3.fromRGB(30, 32, 54) btn.Font = Enum.Font.GothamBold btn.Text = textDisplay btn.TextSize = 10 btn.TextColor3 = Theme.TextMain btn.LayoutOrder = order Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4) local bStroke = Instance.new("UIStroke", btn) bStroke.Color = Theme.Stroke
    btn.MouseButton1Click:Connect(function()
        for _, child in pairs(TopBarNav:GetChildren()) do if child:IsA("TextButton") then child.TextColor3 = Theme.TextMain end end
        btn.TextColor3 = Theme.Accent switchTab(tabTarget)
    end)
    return btn
end

local btnPlayer = addTopBarButton("👤 Player", "Player", 1) btnPlayer.TextColor3 = Theme.Accent
addTopBarButton("👁️ ESP", "ESP", 2)
addTopBarButton("🌀 Teleport", "Teleportation", 3)
addTopBarButton("🛠️ Utility", "Utility", 4)
addTopBarButton("🌐 Server", "Server", 5)
addTopBarButton("⚙️ Setting", "Setting", 6)

local function addToggle(parent, labelText, order, configKey, callback)
    local holder = Instance.new("Frame", parent) holder.Size = UDim2.new(1, 0, 0, 24) holder.BackgroundTransparency = 1 holder.LayoutOrder = order
    local lbl = Instance.new("TextLabel", holder) lbl.Text = labelText lbl.Size = UDim2.new(1, -40, 1, 0) lbl.Font = Enum.Font.GothamMedium lbl.TextColor3 = Theme.TextMain lbl.TextSize = 12 lbl.TextXAlignment = Enum.TextXAlignment.Left lbl.BackgroundTransparency = 1
    local track = Instance.new("TextButton", holder) track.Size = UDim2.new(0, 32, 0, 16) track.Position = UDim2.new(1, -32, 0.5, -8) track.BackgroundColor3 = Theme.Bg track.Text = "" Instance.new("UICorner", track).CornerRadius = UDim.new(0, 8) local tStr = Instance.new("UIStroke", track) tStr.Color = Theme.Stroke
    local knob = Instance.new("Frame", track) knob.Size = UDim2.new(0, 10, 0, 10) knob.Position = UDim2.new(0, 3, 0.5, -5) knob.BackgroundColor3 = Theme.TextMuted Instance.new("UICorner", knob).CornerRadius = UDim.new(0, 5)
    
    if Config[configKey] then 
        knob.Position = UDim2.new(0, 19, 0.5, -5) track.BackgroundColor3 = Theme.Accent tStr.Color = Theme.Accent 
    end
    track.MouseButton1Click:Connect(function()
        if not configKey then return end Config[configKey] = not Config[configKey] local active = Config[configKey]
        TweenService:Create(knob, TweenInfo.new(0.08), {Position = UDim2.new(0, active and 19 or 3, 0.5, -5)}):Play()
        TweenService:Create(track, TweenInfo.new(0.08), {BackgroundColor3 = active and Theme.Accent or Theme.Bg}):Play()
        tStr.Color = active and Theme.Accent or Theme.Stroke if callback then callback(active) end
    end)
end

local function addSliderWithInput(parent, labelText, min, max, defaultVal, order, configKey, callback)
    local holder = Instance.new("Frame", parent) holder.Size = UDim2.new(1, 0, 0, 38) holder.BackgroundTransparency = 1 holder.LayoutOrder = order
    local lbl = Instance.new("TextLabel", holder) lbl.Text = labelText lbl.Size = UDim2.new(0.65, 0, 0, 14) lbl.Font = Enum.Font.GothamMedium lbl.TextColor3 = Theme.TextMain lbl.TextSize = 11 lbl.TextXAlignment = Enum.TextXAlignment.Left lbl.BackgroundTransparency = 1
    local inputBox = Instance.new("TextBox", holder) inputBox.Size = UDim2.new(0, 36, 0, 16) inputBox.Position = UDim2.new(1, -36, 0, 0) inputBox.BackgroundColor3 = Theme.Bg inputBox.Font = Enum.Font.GothamBold inputBox.Text = tostring(defaultVal) inputBox.TextColor3 = Theme.Accent inputBox.TextSize = 10 Instance.new("UICorner", inputBox).CornerRadius = UDim.new(0, 4) local bStr = Instance.new("UIStroke", inputBox) bStr.Color = Theme.Stroke
    local track = Instance.new("Frame", holder) track.Size = UDim2.new(1, 0, 0, 4) track.Position = UDim2.new(0, 0, 1, -4) track.BackgroundColor3 = Theme.Stroke Instance.new("UICorner", track).CornerRadius = UDim.new(0, 2)
    local fill = Instance.new("Frame", track) local startPerc = math.clamp((defaultVal - min) / (max - min), 0, 1) fill.Size = UDim2.new(startPerc, 0, 1, 0) fill.BackgroundColor3 = Theme.Accent Instance.new("UICorner", fill).CornerRadius = UDim.new(0, 2)
    local knob = Instance.new("Frame", track) knob.Position = UDim2.new(startPerc, -5, 0.5, -5) knob.Size = UDim2.new(0, 10, 0, 10) knob.BackgroundColor3 = Theme.TextMain Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0) Instance.new("UIStroke", knob).Color = Theme.AccentPurple
    local dragTrigger = Instance.new("ImageButton", knob) dragTrigger.Size = UDim2.new(2, 0, 2, 0) dragTrigger.Position = UDim2.new(-0.5, 0, -0.5, 0) dragTrigger.BackgroundTransparency = 1
    
    local function refreshVisuals(value)
        local clampedValue = math.clamp(value, min, max) if configKey then Config[configKey] = clampedValue end
        local perc = (clampedValue - min) / (max - min) fill.Size = UDim2.new(perc, 0, 1, 0) knob.Position = UDim2.new(perc, -5, 0.5, -5) inputBox.Text = tostring(clampedValue)
        if callback then callback(clampedValue) end
    end
    
    local sliding = false
    dragTrigger.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then sliding = true end end)
    UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then sliding = false end end)
    UserInputService.InputChanged:Connect(function(input)
        if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local relX = input.Position.X - track.AbsolutePosition.X local perc = math.clamp(relX / track.AbsoluteSize.X, 0, 1)
            refreshVisuals(math.round(min + (perc * (max - min))))
        end
    end)
    inputBox.FocusLost:Connect(function() local num = tonumber(inputBox.Text) refreshVisuals(num or min) end)
end

local function createStatLabel(parent, labelText, order)
    local lbl = Instance.new("TextLabel", parent) lbl.Size = UDim2.new(1, 0, 0, 18) lbl.BackgroundTransparency = 1 lbl.Font = Enum.Font.GothamMedium lbl.Text = labelText lbl.TextColor3 = Theme.TextMain lbl.TextSize = 11 lbl.TextXAlignment = Enum.TextXAlignment.Left lbl.LayoutOrder = order return lbl
end

local function createServerButton(parent, text, color, onClick, order)
    local btn = Instance.new("TextButton", parent) btn.Size = UDim2.new(1, 0, 0, 28) btn.BackgroundColor3 = color btn.Font = Enum.Font.GothamBold btn.Text = text btn.TextColor3 = Theme.TextMain btn.TextSize = 11 btn.LayoutOrder = order Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5) Instance.new("UIStroke", btn).Color = Theme.Stroke
    btn.MouseButton1Click:Connect(onClick) return btn
end

-- ====================================================================
-- POPULATING MENU PAGES
-- ====================================================================
-- [PLAYER PAGE]
addToggle(playerPage, "Enable Fly Mode", 1, "FlyMode", function(v) handleFlyEngine() end)
addSliderWithInput(playerPage, "Fly / Freecam Speed", 1, 100, Config.FlySpeed, 2, "FlySpeed", nil)
addToggle(playerPage, "Enable Noclip", 3, "Noclip", nil)
addToggle(playerPage, "Super Speed (WalkSpeed)", 4, "SuperSpeed", function(v) enforceHumanoidProperties() end)
addSliderWithInput(playerPage, "Speed Multiplier Value", 16, 250, Config.SuperSpeedVal, 5, "SuperSpeedVal", function(v) enforceHumanoidProperties() end)
addToggle(playerPage, "Super Jump (JumpPower)", 6, "SuperJump", function(v) enforceHumanoidProperties() end)
addSliderWithInput(playerPage, "Jump Power Value", 50, 500, Config.SuperJumpVal, 7, "SuperJumpVal", function(v) enforceHumanoidProperties() end)
addToggle(playerPage, "Infinite Jump", 8, "InfiniteJump", nil)
addToggle(playerPage, "Freecam Camera", 9, "Freecam", function(v) handleFreecamEngine(v) end)
addToggle(playerPage, "Anti-Ragdoll Mechanism", 10, "AntiRagdoll", nil)
addToggle(playerPage, "Infinite Oxygen / Breathing", 11, "InfiniteOxygen", nil)

-- [ESP PAGE]
addToggle(espPage, "Master Enable ESP", 1, "EnableESP", nil)
addToggle(espPage, "Show 3D Bounding Boxes", 2, "ShowBoxes", nil)
addToggle(espPage, "Show Player Names & Distance", 3, "ShowNames", nil)
addToggle(espPage, "Show Highlight Outer Glow", 4, "ShowGlow", nil)
addToggle(espPage, "Filter Out Ally Team (Team Check)", 5, "TeamCheck", nil)
addSliderWithInput(espPage, "Max Rendering Distance (m)", 100, 5000, Config.MaxDistance, 6, "MaxDistance", nil)

-- [TELEPORTATION PAGE]
local wpContainer = Instance.new("Frame", tpPage) wpContainer.Size = UDim2.new(1, 0, 0, 160) wpContainer.BackgroundTransparency = 1 wpContainer.LayoutOrder = 1
local wpList = Instance.new("ScrollingFrame", wpContainer) wpList.Size = UDim2.new(1, 0, 1, -35) wpList.BackgroundTransparency = 0.5 wpList.BackgroundColor3 = Theme.CardBg wpList.ScrollBarThickness = 3 wpList.AutomaticCanvasSize = Enum.AutomaticSize.Y
Instance.new("UIListLayout", wpList).Padding = UDim.new(0, 4) Instance.new("UICorner", wpList).CornerRadius = UDim.new(0, 5)

local wpInput = Instance.new("TextBox", wpContainer) wpInput.Size = UDim2.new(0.6, -5, 0, 28) wpInput.Position = UDim2.new(0, 0, 1, -28) wpInput.BackgroundColor3 = Theme.CardBg wpInput.PlaceholderText = "Enter waypoint name..." wpInput.TextColor3 = Theme.TextMain wpInput.Font = Enum.Font.GothamMedium wpInput.TextSize = 11 Instance.new("UICorner", wpInput).CornerRadius = UDim.new(0, 5)

local function refreshWaypointList()
    for _, c in pairs(wpList:GetChildren()) do if c:IsA("Frame") then c:Destroy() end end
    local currentSet = AllWaypoints[CurrentPlaceId] or {}
    for name, posTable in pairs(currentSet) do
        local f = Instance.new("Frame", wpList) f.Size = UDim2.new(1, -6, 0, 26) f.BackgroundColor3 = Theme.Bg Instance.new("UICorner", f).CornerRadius = UDim.new(0, 4)
        local l = Instance.new("TextLabel", f) l.Text = "  " .. name l.Size = UDim2.new(0.6, 0, 1, 0) l.TextColor3 = Theme.TextMain l.Font = Enum.Font.GothamMedium l.TextXAlignment = Enum.TextXAlignment.Left l.BackgroundTransparency = 1 l.TextSize = 11
        local tp = Instance.new("TextButton", f) tp.Text = "TP" tp.Size = UDim2.new(0, 35, 0, 20) tp.Position = UDim2.new(0.65, 0, 0.5, -10) tp.BackgroundColor3 = Theme.Accent tp.TextColor3 = Theme.Bg tp.Font = Enum.Font.GothamBold tp.TextSize = 10 Instance.new("UICorner", tp).CornerRadius = UDim.new(0, 4)
        local del = Instance.new("TextButton", f) del.Text = "DEL" del.Size = UDim2.new(0, 40, 0, 20) del.Position = UDim2.new(1, -45, 0.5, -10) del.BackgroundColor3 = Theme.DeleteBg del.TextColor3 = Theme.DeleteRed del.Font = Enum.Font.GothamBold del.TextSize = 10 Instance.new("UICorner", del).CornerRadius = UDim.new(0, 4) Instance.new("UIStroke", del).Color = Theme.DeleteRed
        
        tp.MouseButton1Click:Connect(function()
            if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
                local targetCF = CFrame.new(posTable[1], posTable[2], posTable[3])
                if not bypassTeleportWithTween(targetCF) then Player.Character.HumanoidRootPart.CFrame = targetCF end
            end
        end)
        del.MouseButton1Click:Connect(function()
            AllWaypoints[CurrentPlaceId][name] = nil saveWaypointsToStorage() refreshWaypointList()
        end)
    end
end

local wpAdd = Instance.new("TextButton", wpContainer) wpAdd.Size = UDim2.new(0.4, 0, 0, 28) wpAdd.Position = UDim2.new(0.6, 0, 1, -28) wpAdd.BackgroundColor3 = Theme.Accent wpAdd.Text = "SAVE POSITION" wpAdd.Font = Enum.Font.GothamBold wpAdd.TextColor3 = Theme.Bg wpAdd.TextSize = 11 Instance.new("UICorner", wpAdd).CornerRadius = UDim.new(0, 5)
wpAdd.MouseButton1Click:Connect(function()
    local name = wpInput.Text if name == "" then return end
    if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
        local pos = Player.Character.HumanoidRootPart.Position
        AllWaypoints[CurrentPlaceId][name] = {pos.X, pos.Y, pos.Z} saveWaypointsToStorage() wpInput.Text = "" refreshWaypointList()
    end
end)
addToggle(tpPage, "Bypass Teleport (Tween/Smooth)", 2, "TweenTeleport", nil)
addSliderWithInput(tpPage, "Tween Movement Speed", 50, 1000, Config.TweenSpeed, 3, "TweenSpeed", nil)
refreshWaypointList()

-- [UTILITY PAGE]
addToggle(utilityPage, "Full Brightness (No Fog/Night)", 1, "FullBright", function(v) if not v then Lighting.Ambient = origAmbient Lighting.OutdoorAmbient = origOutdoorAmbient Lighting.Brightness = origBrightness Lighting.ClockTime = origClockTime end end)
addToggle(utilityPage, "Disable Global Shadows", 2, "ShadowsDisabled", function(v) applyGraphicsBoost() end)
addToggle(utilityPage, "Performance Booster (Anti-Lag)", 3, "AntiLag", function(v) applyGraphicsBoost() end)

-- [SERVER PAGE]
createServerButton(serverPage, "REJOIN CURRENT SERVER", Theme.CardBg, function() TeleportService:Teleport(game.PlaceId, Player) end, 1)
createServerButton(serverPage, "SERVER HOP (SEARCH NEW MATCH)", Theme.CardBg, function()
    local success, serverList = pcall(function() return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Desc&limit=100")) end)
    if success and serverList and serverList.data then
        for _, server in pairs(serverList.data) do
            if server.playing < server.maxPlayers and server.id ~= game.JobId then
                TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id, Player) break
            end
        end
    end
end, 2)

-- [SETTING PAGE]
addSliderWithInput(settingPage, "Menu UI Background Transparency", 0, 0.8, Config.UiTransparency, 1, "UiTransparency", function(v) updateUiTransparency(v) end)

-- ====================================================================
-- ENGINE STATS REFRESHER
-- ====================================================================
local statsContainer = Instance.new("Frame", settingPage) statsContainer.Size = UDim2.new(1, 0, 0, 80) statsContainer.BackgroundTransparency = 1 statsContainer.LayoutOrder = 2
local scLayout = Instance.new("UIListLayout", statsContainer) scLayout.Padding = UDim.new(0, 2)
local sMap = createStatLabel(statsContainer, "Game Name: " .. CurrentMapName, 1)
local sExec = createStatLabel(statsContainer, "Executor Client: " .. CurrentExecutor, 2)
local sFps = createStatLabel(statsContainer, "Frames Per Second: Calculating...", 3)
local sPing = createStatLabel(statsContainer, "Network Ping Latency: 0 ms", 4)

task.spawn(function()
    while task.wait(1) do
        pcall(function()
            sFps.Text = string.format("Frames Per Second: %d FPS", math.round(Workspace:GetRealPhysicsFPS()))
            sPing.Text = string.format("Network Ping Latency: %d ms", math.round(Stats.Network.ServerToClientPing:GetValue()))
        end)
    end
end)

-- ====================================================================
-- LOADER EXECUTION TIMELINE ANIMATION
-- ====================================================================
local function initiateLoadingAnimation()
    LoadingFrame.Visible = true
    local steps = {
        {0.15, "Loading core binary components..."},
        {0.35, "Injecting layout configuration maps..."},
        {0.55, "Decrypting local client data profiles..."},
        {0.75, "Constructing visual user interface..."},
        {1.00, "Script core loaded successfully!"}
    }
    for _, stage in ipairs(steps) do
        task.wait(0.4)
        TweenService:Create(LoadFill, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(stage[1], 0, 1, 0)}):Play()
        LoadProgressText.Text = tostring(math.round(stage[1] * 100)) .. "%"
        LoadStatus.Text = stage[2]
    end
    task.wait(0.5)
    LoadingFrame:Destroy() MainFrame.Visible = true ToggleButton.Visible = false
end

-- ====================================================================
-- KEY SYSTEM AUTHENTICATION INTERFACE
-- ====================================================================
if KeyVerified then
    task.spawn(initiateLoadingAnimation)
else
    LoadingFrame.Visible = false
    local KeyFrame = Instance.new("Frame", MainGui) KeyFrame.Name = "KeyFrame" KeyFrame.Size = UDim2.new(0, 340, 0, 170) KeyFrame.Position = UDim2.new(0.5, -170, 0.5, -85) KeyFrame.BackgroundColor3 = Theme.Bg Instance.new("UICorner", KeyFrame).CornerRadius = UDim.new(0, 10)
    local kStroke = Instance.new("UIStroke", KeyFrame) kStroke.Color = Theme.AccentPurple kStroke.Thickness = 1.5 makeDraggable(KeyFrame, KeyFrame)
    
    local KTitle = Instance.new("TextLabel", KeyFrame) KTitle.Size = UDim2.new(1, 0, 0, 35) KTitle.Position = UDim2.new(0, 0, 0, 15) KTitle.Text = "VERIFICATION REQUIRED" KTitle.Font = Enum.Font.GothamBold KTitle.TextColor3 = Theme.TextMain KTitle.TextSize = 14 KTitle.BackgroundTransparency = 1
    local KSub = Instance.new("TextLabel", KeyFrame) KSub.Size = UDim2.new(1, 0, 0, 20) KSub.Position = UDim2.new(0, 0, 0, 35) KSub.Text = "Please enter your access token below:" KSub.Font = Enum.Font.GothamMedium KSub.TextColor3 = Theme.TextMuted KSub.TextSize = 11 KSub.BackgroundTransparency = 1
    
    local KeyInput = Instance.new("TextBox", KeyFrame) KeyInput.Size = UDim2.new(1, -40, 0, 32) KeyInput.Position = UDim2.new(0, 20, 0, 65) KeyInput.BackgroundColor3 = Theme.CardBg KeyInput.Font = Enum.Font.GothamMedium KeyInput.PlaceholderText = "Paste premium key here..." KeyInput.Text = "" KeyInput.TextColor3 = Theme.TextMain KeyInput.PlaceholderColor3 = Theme.TextMuted KeyInput.TextSize = 11 Instance.new("UICorner", KeyInput).CornerRadius = UDim.new(0, 5) Instance.new("UIStroke", KeyInput).Color = Theme.Stroke
    local SubmitBtn = Instance.new("TextButton", KeyFrame) SubmitBtn.Size = UDim2.new(1, -40, 0, 32) SubmitBtn.Position = UDim2.new(0, 20, 1, -45) SubmitBtn.BackgroundColor3 = Theme.Accent SubmitBtn.Font = Enum.Font.GothamBold SubmitBtn.Text = "VERIFY KEY" SubmitBtn.TextColor3 = Theme.Bg SubmitBtn.TextSize = 11 Instance.new("UICorner", SubmitBtn).CornerRadius = UDim.new(0, 5)

    SubmitBtn.MouseButton1Click:Connect(function()
        if KeyInput.Text == CorrectKey then
            saveKeyStatus() KeyFrame:Destroy() task.spawn(initiateLoadingAnimation)
        else
            KeyInput.Text = "" KeyInput.PlaceholderText = "INVALID KEY! TRY AGAIN..." KeyInput.PlaceholderColor3 = Theme.DeleteRed
            task.spawn(function() task.wait(2) KeyInput.PlaceholderText = "Paste premium key here..." KeyInput.PlaceholderColor3 = Theme.TextMuted end)
        end
    end)
end
