-- ====================================================================
-- AR SCRIPT HUB - v7.1 CORE ENGINE (PURE 24H LOCAL TIMEOUT VERSION)
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

-- ====================================================================
-- CONFIG KEY SYSTEM (LOCAL KEY VERIFICATION)
-- ====================================================================
local MASTER_KEY = "AR-OWNER-831"
local KEY_FILE_NAME = "AR_Hub_KeySystem.json"

local function loadKeyStatus()
    local success, content = pcall(function() return readfile(KEY_FILE_NAME) end)
    if success and content then
        local decodeSuccess, decodedData = pcall(function() return HttpService:JSONDecode(content) end)
        if decodeSuccess and type(decodedData) == "table" then
            if decodedData.Timestamp and (os.time() - decodedData.Timestamp) < 86400 then
                if decodedData.Key and decodedData.Key == MASTER_KEY then 
                    return decodedData.Key
                end
            end
        end
    end
    return nil
end

local function saveKeyStatus(passedKey)
    local data = { Key = passedKey, Timestamp = os.time() }
    pcall(function() writefile(KEY_FILE_NAME, HttpService:JSONEncode(data)) end)
end

-- Master ScreenGui Context
local AR_Script_Hub = Instance.new("ScreenGui")
AR_Script_Hub.Name = "AR_Script_Hub"
AR_Script_Hub.Parent = SafeGuiTarget
AR_Script_Hub.ResetOnSpawn = false
AR_Script_Hub.DisplayOrder = 2147483647

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
    FullBright = false
}

-- ====================================================================
-- INTERFACE MENU LOGIN
-- ====================================================================
local KeyFrame = Instance.new("Frame")
KeyFrame.Name = "KeyFrame"
KeyFrame.Size = UDim2.new(0, 420, 0, 290)
KeyFrame.Position = UDim2.new(0.5, -210, 0.5, -145)
KeyFrame.BackgroundColor3 = Theme.Bg
KeyFrame.BorderSizePixel = 0
KeyFrame.ClipsDescendants = true
KeyFrame.Parent = AR_Script_Hub

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 14)
mainCorner.Parent = KeyFrame

local mainStroke = Instance.new("UIStroke")
mainStroke.Thickness = 1.5
mainStroke.Color = Theme.Stroke
mainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
mainStroke.Parent = KeyFrame

local GlowEffect = Instance.new("ImageLabel")
GlowEffect.Name = "GlowEffect"
GlowEffect.BackgroundTransparency = 1
GlowEffect.Position = UDim2.new(0, -15, 0, -15)
GlowEffect.Size = UDim2.new(1, 30, 1, 30)
GlowEffect.Image = "rbxassetid://6015897843"
GlowEffect.ImageColor3 = Theme.AccentPurple
GlowEffect.ImageTransparency = 0.85
GlowEffect.Parent = KeyFrame

local TitleHub = Instance.new("TextLabel")
TitleHub.Name = "TitleHub"
TitleHub.Size = UDim2.new(1, 0, 0, 55)
TitleHub.Position = UDim2.new(0, 0, 0, 10)
TitleHub.BackgroundTransparency = 1
TitleHub.Text = "AR SCRIPT HUB"
TitleHub.Font = Enum.Font.GothamBold
TitleHub.TextSize = 22
TitleHub.TextColor3 = Theme.TextMain
TitleHub.Parent = KeyFrame

local SubTitle = Instance.new("TextLabel")
SubTitle.Name = "SubTitle"
SubTitle.Size = UDim2.new(1, 0, 0, 20)
SubTitle.Position = UDim2.new(0, 0, 0, 58)
SubTitle.BackgroundTransparency = 1
SubTitle.Text = "Please enter your 24-hour product key below"
SubTitle.Font = Enum.Font.GothamSemibold
SubTitle.TextSize = 12
SubTitle.TextColor3 = Theme.TextMuted
SubTitle.Parent = KeyFrame

local KeyInput = Instance.new("TextBox")
KeyInput.Name = "KeyInput"
KeyInput.Size = UDim2.new(0, 340, 0, 48)
KeyInput.Position = UDim2.new(0.5, -170, 0, 105)
KeyInput.BackgroundColor3 = Theme.CardBg
KeyInput.BorderSizePixel = 0
KeyInput.Text = ""
KeyInput.PlaceholderText = "Paste your AR-XXXXXX key here..."
KeyInput.Font = Enum.Font.Gotham
KeyInput.TextSize = 14
KeyInput.TextColor3 = Theme.TextMain
KeyInput.PlaceholderColor3 = Theme.TextMuted
KeyInput.ClearTextOnFocus = false
KeyInput.Parent = KeyFrame

local inputCorner = Instance.new("UICorner")
inputCorner.CornerRadius = UDim.new(0, 8)
inputCorner.Parent = KeyInput

local inputStroke = Instance.new("UIStroke")
inputStroke.Thickness = 1
inputStroke.Color = Theme.Stroke
inputStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
inputStroke.Parent = KeyInput

local SubmitBtn = Instance.new("TextButton")
SubmitBtn.Name = "SubmitBtn"
SubmitBtn.Size = UDim2.new(0, 340, 0, 46)
SubmitBtn.Position = UDim2.new(0.5, -170, 0, 170)
SubmitBtn.BackgroundColor3 = Color3.fromRGB(35, 32, 64)
SubmitBtn.BorderSizePixel = 0
SubmitBtn.Text = "VERIFY KEY"
SubmitBtn.Font = Enum.Font.GothamBold
SubmitBtn.TextSize = 14
SubmitBtn.TextColor3 = Theme.Accent
SubmitBtn.AutoButtonColor = false
SubmitBtn.Parent = KeyFrame

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0, 8)
btnCorner.Parent = SubmitBtn

local btnStroke = Instance.new("UIStroke")
btnStroke.Color = Theme.Stroke
btnStroke.Thickness = 1
btnStroke.Parent = SubmitBtn

local DiscordBtn = Instance.new("TextButton")
DiscordBtn.Name = "DiscordBtn"
DiscordBtn.Size = UDim2.new(0, 340, 0, 38)
DiscordBtn.Position = UDim2.new(0.5, -170, 0, 230)
DiscordBtn.BackgroundColor3 = Theme.CardBg
DiscordBtn.BorderSizePixel = 0
DiscordBtn.Text = "🔑 Click to Copy Key: AR-OWNER-831"
DiscordBtn.Font = Enum.Font.GothamSemibold
DiscordBtn.TextSize = 12
DiscordBtn.TextColor3 = Color3.fromRGB(190, 130, 255)
DiscordBtn.AutoButtonColor = true
DiscordBtn.Parent = KeyFrame

local discCorner = Instance.new("UICorner")
discCorner.CornerRadius = UDim.new(0, 8)
discCorner.Parent = DiscordBtn

local discStroke = Instance.new("UIStroke")
discStroke.Thickness = 1
discStroke.Color = Theme.Stroke
discStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
discStroke.Parent = DiscordBtn

local function makeKeyDraggable(frame, dragHandle)
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
makeKeyDraggable(KeyFrame, TitleHub)

KeyFrame.Size = UDim2.new(0, 400, 0, 270)
KeyFrame.Position = UDim2.new(0.5, -200, 0.5, -135)
TweenService:Create(KeyFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 420, 0, 290), Position = UDim2.new(0.5, -210, 0.5, -145)}):Play()

-- ====================================================================
-- MAIN HUB DASHBOARD ENGINE
-- ====================================================================
local function buildMainDashboard()
    local FILE_NAME = "AR_Hub_Waypoints_v71.json"
    local CurrentPlaceId = tostring(game.PlaceId)
    local AllWaypoints = {}

    local Lighting = game:GetService("Lighting")
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
                elseif UserInputService:IsKeyDown(Enum.LeftShift) or UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then verticalSpeed = -speed end
                
                if verticalSpeed ~= 0 then flyBv.velocity = Vector3.new(finalVelocity.X, verticalSpeed, finalVelocity.Z)
                else flyBv.velocity = finalVelocity end
                
                flyBg.cframe = camCF
                task.wait()
            end
            stopFlying()
        end)
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

    -- ESP Cache System
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
            local camera = workspace.CurrentCamera local _, onScreen = camera:WorldToViewportPoint(tHrp.Position)
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

    -- GUI MAIN WINDOW FRAME
    local PopupFrame = Instance.new("Frame")
    PopupFrame.Name = "PopupFrame" PopupFrame.Parent = AR_Script_Hub PopupFrame.Size = UDim2.new(0, 280, 0, 140) PopupFrame.Position = UDim2.new(0.5, -140, 0.5, -70) PopupFrame.BackgroundColor3 = Theme.Bg PopupFrame.BackgroundTransparency = Config.UiTransparency PopupFrame.Visible = false PopupFrame.ZIndex = 1000 Instance.new("UICorner", PopupFrame).CornerRadius = UDim.new(0, 10)
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
    ToggleButton.Name = "ToggleButton" ToggleButton.Parent = AR_Script_Hub ToggleButton.Size = UDim2.new(0, 46, 0, 46) ToggleButton.Position = UDim2.new(0.02, 0, 0.2, 0) ToggleButton.BackgroundColor3 = Theme.Bg ToggleButton.BackgroundTransparency = Config.UiTransparency ToggleButton.Font = Enum.Font.GothamBold ToggleButton.Text = "AR" ToggleButton.TextColor3 = Theme.Accent ToggleButton.TextSize = 16 ToggleButton.Visible = false Instance.new("UICorner", ToggleButton).CornerRadius = UDim.new(0, 9)
    local tbStroke = Instance.new("UIStroke", ToggleButton) tbStroke.Color = Theme.AccentPurple makeDraggable(ToggleButton, ToggleButton)

    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame" MainFrame.Parent = AR_Script_Hub MainFrame.Size = UDim2.new(0, 560, 0, 340) MainFrame.Position = UDim2.new(0.5, -280, 0.5, -170) MainFrame.BackgroundColor3 = Theme.Bg MainFrame.BackgroundTransparency = Config.UiTransparency MainFrame.Visible = true Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)
    local mainStroke = Instance.new("UIStroke", MainFrame) mainStroke.Color = Theme.Stroke mainStroke.Thickness = 1.5

    local Header = Instance.new("Frame", MainFrame) Header.Size = UDim2.new(1, 0, 0, 40) Header.BackgroundTransparency = 1
    local Title = Instance.new("TextLabel", Header) Title.Text = "AR SCRIPT HUB <font color='#c092ff'>v1.1</font>" Title.RichText = true Title.Size = UDim2.new(0.5, 0, 1, 0) Title.Position = UDim2.new(0, 16, 0, 0) Title.Font = Enum.Font.GothamBold Title.TextColor3 = Theme.TextMain Title.TextSize = 14 Title.TextXAlignment = Enum.TextXAlignment.Left Title.BackgroundTransparency = 1
    local CloseBtn = Instance.new("TextButton", Header) CloseBtn.Text = "×" CloseBtn.Size = UDim2.new(0, 35, 1, 0) CloseBtn.Position = UDim2.new(1, -35, 0, 0) CloseBtn.Font = Enum.Font.GothamMedium CloseBtn.TextColor3 = Theme.DeleteRed CloseBtn.TextSize = 24 CloseBtn.BackgroundTransparency = 1
    local MinimizeBtn = Instance.new("TextButton", Header) MinimizeBtn.Text = "−" MinimizeBtn.Size = UDim2.new(0, 35, 1, 0) MinimizeBtn.Position = UDim2.new(1, -70, 0, 0) MinimizeBtn.Font = Enum.Font.GothamMedium MinimizeBtn.TextColor3 = Theme.TextMuted MinimizeBtn.TextSize = 20 MinimizeBtn.BackgroundTransparency = 1

    makeDraggable(MainFrame, Header)
    ToggleButton.MouseButton1Click:Connect(function() MainFrame.Visible = true ToggleButton.Visible = false end)
    MinimizeBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false ToggleButton.Visible = true end)
    CloseBtn.MouseButton1Click:Connect(function() showConfirmation("Hub akan ditutup secara permanen,\napakah kamu yakin?", function() AR_Script_Hub:Destroy() end) end)

    local TopBarNav = Instance.new("Frame", MainFrame) TopBarNav.Name = "TopBarNav" TopBarNav.Size = UDim2.new(1, -32, 0, 36) TopBarNav.Position = UDim2.new(0, 16, 0, 45) TopBarNav.BackgroundColor3 = Theme.CardBg TopBarNav.BackgroundTransparency = 0.6 Instance.new("UICorner", TopBarNav).CornerRadius = UDim.new(0, 6) local navStroke = Instance.new("UIStroke", TopBarNav) navStroke.Color = Theme.Stroke local NavLayout = Instance.new("UIListLayout", TopBarNav) NavLayout.FillDirection = Enum.FillDirection.Horizontal NavLayout.SortOrder = Enum.SortOrder.LayoutOrder NavLayout.VerticalAlignment = Enum.VerticalAlignment.Center NavLayout.Padding = UDim.new(0, 4) local paddingNav = Instance.new("UIPadding", TopBarNav) paddingNav.PaddingLeft = UDim.new(0, 6)

    local MainContentFrame = Instance.new("ScrollingFrame", MainFrame) MainContentFrame.Name = "MainContentFrame" MainContentFrame.Size = UDim2.new(1, -32, 1, -105) MainContentFrame.Position = UDim2.new(0, 16, 0, 95) MainContentFrame.BackgroundTransparency = 1 MainContentFrame.CanvasSize = UDim2.new(0, 0, 0, 0) MainContentFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y MainContentFrame.ScrollBarThickness = 3 MainContentFrame.ScrollBarImageColor3 = Theme.Accent

    local menuContainers = {}
    local function createMenuPage(name, isVisible)
        local page = Instance.new("Frame", MainContentFrame) page.Name = name .. "Page" page.Size = UDim2.new(1, 0, 0, 0) page.AutomaticSize = Enum.AutomaticSize.Y page.BackgroundTransparency = 1 page.Visible = isVisible
        
        -- KUNCI UTAMA: Setiap halaman harus punya UIListLayout biar toggle-nya kesusun vertikal rapi!
        local listLayout = Instance.new("UIListLayout", page)
        listLayout.SortOrder = Enum.SortOrder.LayoutOrder
        listLayout.Padding = UDim.new(0, 10)
        
        menuContainers[name] = page 
        return page
    end

    local playerPage = createMenuPage("Player", true)
    local espPage = createMenuPage("ESP", false)
    local tpPage = createMenuPage("Teleportation", false)
    local serverPage = createMenuPage("Server", false)
    local settingPage = createMenuPage("Setting", false)

    local function switchTab(tabName)
        for name, page in pairs(menuContainers) do page.Visible = (name == tabName) end
        MainContentFrame.CanvasPosition = Vector2.new(0, 0)
    end

    local function addTopBarButton(textDisplay, tabTarget, order)
        local btn = Instance.new("TextButton", TopBarNav) btn.Size = UDim2.new(0, 96, 0, 26) btn.BackgroundColor3 = Color3.fromRGB(30, 32, 54) btn.Font = Enum.Font.GothamBold btn.Text = textDisplay btn.TextSize = 11 btn.TextColor3 = Theme.TextMain btn.LayoutOrder = order Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4) local bStroke = Instance.new("UIStroke", btn) bStroke.Color = Theme.Stroke
        btn.MouseButton1Click:Connect(function()
            for _, child in pairs(TopBarNav:GetChildren()) do if child:IsA("TextButton") then child.TextColor3 = Theme.TextMain end end
            btn.TextColor3 = Theme.Accent switchTab(tabTarget)
        end)
        return btn
    end

    local btnPlayer = addTopBarButton("👤 Player", "Player", 1) btnPlayer.TextColor3 = Theme.Accent
    addTopBarButton("👁️ ESP", "ESP", 2)
    addTopBarButton("🌀 Teleportation", "Teleportation", 3)
    addTopBarButton("🌐 Server", "Server", 4)
    addTopBarButton("⚙️ Setting", "Setting", 5)

    -- Component: Toggle Builder
    local function addToggle(parent, labelText, order, configKey, callback)
        local holder = Instance.new("Frame", parent) holder.Size = UDim2.new(1, 0, 0, 26) holder.BackgroundTransparency = 1 holder.LayoutOrder = order
        local lbl = Instance.new("TextLabel", holder) lbl.Text = labelText lbl.Size = UDim2.new(1, -45, 1, 0) lbl.Font = Enum.Font.GothamMedium lbl.TextColor3 = Theme.TextMain lbl.TextSize = 12 lbl.TextXAlignment = Enum.TextXAlignment.Left lbl.BackgroundTransparency = 1
        local track = Instance.new("TextButton", holder) track.Size = UDim2.new(0, 34, 0, 18) track.Position = UDim2.new(1, -34, 0.5, -9) track.BackgroundColor3 = Theme.Bg track.Text = "" Instance.new("UICorner", track).CornerRadius = UDim.new(0, 9) local tStr = Instance.new("UIStroke", track) tStr.Color = Theme.Stroke
        local knob = Instance.new("Frame", track) knob.Size = UDim2.new(0, 12, 0, 12) knob.Position = UDim2.new(0, 3, 0.5, -6) knob.BackgroundColor3 = Theme.TextMuted Instance.new("UICorner", knob).CornerRadius = UDim.new(0, 6)
        
        track.MouseButton1Click:Connect(function()
            if not configKey then return end Config[configKey] = not Config[configKey] local active = Config[configKey]
            TweenService:Create(knob, TweenInfo.new(0.08), {Position = UDim2.new(0, active and 19 or 3, 0.5, -6)}):Play()
            TweenService:Create(track, TweenInfo.new(0.08), {BackgroundColor3 = active and Theme.Accent or Theme.Bg}):Play()
            tStr.Color = active and Theme.Accent or Theme.Stroke if callback then callback(active) end
        end)
    end

    -- KUNCI UTAMA: Fungsi Slider Dikembalikan Utuh, Presisi & Auto-Susun di UIListLayout
    local function addSliderWithInput(parent, labelText, min, max, defaultVal, order, configKey, callback)
        local holder = Instance.new("Frame", parent) holder.Size = UDim2.new(1, 0, 0, 44) holder.BackgroundTransparency = 1 holder.LayoutOrder = order
        
        local lbl = Instance.new("TextLabel", holder) lbl.Text = labelText lbl.Size = UDim2.new(0.7, 0, 0, 16) lbl.Font = Enum.Font.GothamMedium lbl.TextColor3 = Theme.TextMain lbl.TextSize = 12 lbl.TextXAlignment = Enum.TextXAlignment.Left lbl.BackgroundTransparency = 1
        local inputBox = Instance.new("TextBox", holder) inputBox.Size = UDim2.new(0, 48, 0, 20) inputBox.Position = UDim2.new(1, -48, 0, 0) inputBox.BackgroundColor3 = Theme.CardBg inputBox.Font = Enum.Font.GothamBold inputBox.Text = tostring(defaultVal) inputBox.TextColor3 = Theme.Accent inputBox.TextSize = 11 Instance.new("UICorner", inputBox).CornerRadius = UDim.new(0, 4) local bStr = Instance.new("UIStroke", inputBox) bStr.Color = Theme.Stroke
        
        local slideBar = Instance.new("TextButton", holder) slideBar.Size = UDim2.new(1, 0, 0, 6) slideBar.Position = UDim2.new(0, 0, 1, -10) slideBar.BackgroundColor3 = Theme.CardBg slideBar.Text = "" Instance.new("UICorner", slideBar).CornerRadius = UDim.new(0, 3)
        local fill = Instance.new("Frame", slideBar) fill.Size = UDim2.new(math.clamp((defaultVal - min)/(max - min), 0, 1), 0, 1, 0) fill.BackgroundColor3 = Theme.Accent Instance.new("UICorner", fill).CornerRadius = UDim.new(0, 3)
        
        local function updateSlider(inputPos)
            local percent = math.clamp((inputPos - slideBar.AbsolutePosition.X) / slideBar.AbsoluteSize.X, 0, 1)
            local val = math.round(min + (percent * (max - min)))
            inputBox.Text = tostring(val) fill.Size = UDim2.new(percent, 0, 1, 0)
            if configKey then Config[configKey] = val end if callback then callback(val) end
        end
        
        slideBar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                updateSlider(input.Position.X)
                local moveCon; moveCon = UserInputService.InputChanged:Connect(function(move)
                    if move.UserInputType == Enum.UserInputType.MouseMovement or move.UserInputType == Enum.UserInputType.Touch then
                        updateSlider(move.Position.X)
                    end
                end)
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then moveCon:Disconnect() end
                end)
            end
        end)
        
        inputBox.FocusLost:Connect(function()
            local val = tonumber(inputBox.Text) or defaultVal
            val = math.clamp(math.round(val), min, max)
            inputBox.Text = tostring(val)
            fill.Size = UDim2.new((val - min)/(max - min), 0, 1, 0)
            if configKey then Config[configKey] = val end if callback then callback(val) end
        end)
    end

    -- Rendering Menu Komponen ke dalam Tab (Isinya otomatis tersusun sempurna sekarang!)
    addToggle(playerPage, "Enable Flying Mode Control Engine", 1, "FlyMode", function(v) handleFlyEngine() end)
    addSliderWithInput(playerPage, "Custom Flight Speed Rate Factor", 1, 100, 5, 2, "FlySpeed", nil)
    addToggle(playerPage, "Activate Strict Noclip Collision State", 3, "Noclip", nil)
    addToggle(playerPage, "Modify Humanoid WalkSpeed Override", 4, "SuperSpeed", function(v) enforceHumanoidProperties() end)
    addSliderWithInput(playerPage, "Super Speed Configuration Value Target", 16, 500, 16, 5, "SuperSpeedVal", function() enforceHumanoidProperties() end)
    addToggle(playerPage, "Modify Humanoid JumpPower Override", 6, "SuperJump", function(v) enforceHumanoidProperties() end)
    addSliderWithInput(playerPage, "Super Jump Configuration Value Target", 50, 500, 50, 7, "SuperJumpVal", function() enforceHumanoidProperties() end)
    addToggle(playerPage, "Infinite Multi-Jump Activation Node", 8, "InfiniteJump", nil)
    addToggle(playerPage, "Anti-Ragdoll Physics Resolver State", 9, "AntiRagdoll", nil)
    addToggle(playerPage, "Infinite Oxygen Valve Modification", 10, "InfiniteOxygen", nil)

    addToggle(espPage, "Master Switch ESP Network System", 1, "EnableESP", nil)
    addToggle(espPage, "Render Translucent Box Adornment ESP", 2, "ShowBoxes", nil)
    addToggle(espPage, "Draw Billboard Text Overhead Tag Info", 3, "ShowNames", nil)
    addToggle(espPage, "Apply Highlight Wireframe Chams Glow", 4, "ShowGlow", nil)
    addToggle(espPage, "Enforce Ally Alliance Team-Check Guard", 5, "TeamCheck", nil)
    addSliderWithInput(espPage, "Maximum Rendering Distance Cutoff (m)", 50, 10000, 1000, 6, "MaxDistance", nil)

    print("🚀 AR Script Hub Core successfully loaded!")
end

-- ====================================================================
-- LOADING SEQUENCE EFFECT
-- ====================================================================
local function runLoadingSequence()
    local LoaderFrame = Instance.new("Frame")
    LoaderFrame.Size = UDim2.new(0, 300, 0, 100)
    LoaderFrame.Position = UDim2.new(0.5, -150, 0.5, -50)
    LoaderFrame.BackgroundColor3 = Theme.Bg
    LoaderFrame.Parent = AR_Script_Hub

    local loadCorner = Instance.new("UICorner")
    loadCorner.CornerRadius = UDim.new(0, 12)
    loadCorner.Parent = LoaderFrame

    local loadStroke = Instance.new("UIStroke")
    loadStroke.Color = Theme.AccentPurple
    loadStroke.Thickness = 1.5
    loadStroke.Parent = LoaderFrame

    local LoadTxt = Instance.new("TextLabel")
    LoadTxt.Size = UDim2.new(1, 0, 0, 40)
    LoadTxt.Position = UDim2.new(0, 0, 0, 15)
    LoadTxt.BackgroundTransparency = 1
    LoadTxt.Text = "AUTHENTICATING ENGINE..."
    LoadTxt.Font = Enum.Font.GothamBold
    LoadTxt.TextSize = 14
    LoadTxt.TextColor3 = Theme.TextMain
    LoadTxt.Parent = LoaderFrame

    local BarBg = Instance.new("Frame")
    BarBg.Size = UDim2.new(0, 240, 0, 6)
    BarBg.Position = UDim2.new(0.5, -120, 0, 65)
    BarBg.BackgroundColor3 = Theme.CardBg
    BarBg.BorderSizePixel = 0
    BarBg.Parent = LoaderFrame

    local fillCorner = Instance.new("UICorner") fillCorner.CornerRadius = UDim.new(0, 3) fillCorner.Parent = BarBg

    local BarFill = Instance.new("Frame")
    BarFill.Size = UDim2.new(0, 0, 1, 0)
    BarFill.BackgroundColor3 = Theme.ConfirmGreen
    BarFill.BorderSizePixel = 0
    BarFill.Parent = BarBg

    local barFillCorner = Instance.new("UICorner") barFillCorner.CornerRadius = UDim.new(0, 3) barFillCorner.Parent = BarFill

    local barTween = TweenService:Create(BarFill, TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 1, 0)})
    barTween:Play()
    
    barTween.Completed:Connect(function()
        LoadTxt.Text = "WELCOME TO AR HUB!"
        LoadTxt.TextColor3 = Theme.ConfirmGreen
        task.wait(0.4)
        LoaderFrame:Destroy()
        buildMainDashboard()
    end)
end

-- ====================================================================
-- CONTROLLER INTERACTIONS
-- ====================================================================
DiscordBtn.MouseButton1Click:Connect(function()
    if setclipboard then
        setclipboard(MASTER_KEY)
    end
    DiscordBtn.Text = "✅ Key Copied to Clipboard!"
    DiscordBtn.TextColor3 = Theme.ConfirmGreen
    discStroke.Color = Theme.ConfirmGreen
    task.delay(2.5, function()
        if DiscordBtn and DiscordBtn.Parent then
            DiscordBtn.Text = "🔑 Click to Copy Key: " .. MASTER_KEY
            DiscordBtn.TextColor3 = Color3.fromRGB(190, 130, 255)
            discStroke.Color = Theme.Stroke
        end
    end)
end)

SubmitBtn.MouseButton1Click:Connect(function()
    local userKey = string.gsub(KeyInput.Text, "^%s*(.-)%s*$", "%1")
    
    if userKey == "" then 
        KeyInput.PlaceholderText = "Key cannot be empty!"
        return 
    end
    
    SubmitBtn.Text = "VERIFYING..."
    SubmitBtn.Active = false
    task.wait(0.15)

    if userKey == MASTER_KEY then
        saveKeyStatus(userKey) 
        KeyFrame:Destroy() 
        runLoadingSequence() 
    else
        KeyInput.Text = "" 
        SubmitBtn.Text = "VERIFY KEY"
        SubmitBtn.Active = true
        KeyInput.PlaceholderText = "INVALID OR EXPIRED KEY!" 
        KeyInput.PlaceholderColor3 = Theme.DeleteRed
        
        local originalPos = KeyFrame.Position
        for i = 1, 5 do
            KeyFrame.Position = originalPos + UDim2.new(0, math.random(-6, 6), 0, 0)
            task.wait(0.02)
        end
        KeyFrame.Position = originalPos
    end
end)

local saved = loadKeyStatus()
if saved and saved == MASTER_KEY then
    KeyFrame:Destroy()
    runLoadingSequence()
end
