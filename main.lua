-- ====================================================================
-- AR SCRIPT HUB - v6.8 CORE ENGINE REWORK (PART 1 & 2 FULL COUPLING)
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

-- Pembersihan UI lama
if SafeGuiTarget and SafeGuiTarget:FindFirstChild("AR_Script_Hub") then
    SafeGuiTarget.AR_Script_Hub:Destroy()
end

local MainGui = Instance.new("ScreenGui")
MainGui.Name = "AR_Script_Hub"
MainGui.Parent = SafeGuiTarget
MainGui.ResetOnSpawn = false
-- Menggunakan nilai integer positif 32-bit tertinggi agar berada di atas Chat/Voice Mic Roblox
MainGui.DisplayOrder = 2147483647

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
    FlySpeed = 5, -- Standalone scale base
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
    ShowGlow = false, -- Fitur tubuh glowing baru
    TeamCheck = false,
    MaxDistance = 1000,
    ShadowsDisabled = false,
    AntiLag = false,
    UiTransparency = 0.15 -- Slider baru untuk transparansi UI
}

local FILE_NAME = "AR_Hub_Waypoints.json"
local CurrentPlaceId = tostring(game.PlaceId)
local AllWaypoints = {}

-- Mendapatkan info map saat ini secara aman
local CurrentMapName = "Unknown Game"
pcall(function()
    local productInfo = MarketplaceService:GetProductInfo(game.PlaceId)
    if productInfo and productInfo.Name then
        CurrentMapName = productInfo.Name
    end
end)

-- Mendapatkan nama executor secara aman
local CurrentExecutor = (identifyexecutor or getexecutorname or function() return "Unknown Executor" end)()

-- ====================================================================
-- LOGIKA DETEKSI PLOT OTOMATIS (UNTUK BRAINROT TYCOON / GAME TYCOON)
-- ====================================================================
local function getMyPlotSpawn()
    -- Mendeteksi folder plot umum di Tycoon (Tycoons, Plots, Tycoon, atau TycoonPlots)
    local tycoonsFolder = workspace:FindFirstChild("Tycoons") or workspace:FindFirstChild("Plots") or workspace:FindFirstChild("Tycoon") or workspace:FindFirstChild("TycoonPlots")
    
    if tycoonsFolder then
        for _, plot in pairs(tycoonsFolder:GetChildren()) do
            -- Periksa apakah nama plot sesuai nama kita, atau memiliki value Owner/Player
            local ownerValue = plot:FindFirstChild("Owner") or plot:FindFirstChild("Player")
            if plot.Name == Player.Name or (ownerValue and (ownerValue.Value == Player or ownerValue.Value == Player.Name)) then
                -- Cari part Spawn di dalam plot tersebut
                local plotSpawn = plot:FindFirstChild("Spawn") or plot:FindFirstChild("SpawnPoint") or plot:FindFirstChild("Essentials") and plot.Essentials:FindFirstChild("Spawn")
                if plotSpawn and plotSpawn:IsA("BasePart") then
                    return plotSpawn.Position
                end
            end
        end
    end
    return nil
end

-- ====================================================================
-- REAL BACKGROUND FUNCTIONAL ENGINE (ANTI-BUG)
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
            
            local velocityVector = Vector3.new(0, 0, 0)
            
            -- Kalkulasi pergerakan horizontal berdasarkan arah kamera
            if moveDir.Magnitude > 0 then
                local camCF = camera.CFrame
                local direction = (camCF.LookVector * moveDir:Dot(Vector3.new(camCF.LookVector.X, 0, camCF.LookVector.Z).Unit)) + (camCF.RightVector * moveDir:Dot(Vector3.new(camCF.RightVector.X, 0, camCF.RightVector.Z).Unit))
                if direction.Magnitude > 0 then
                    velocityVector = direction.Unit * speed
                end
            end
            
            -- Kontrol naik-turun menggunakan Space dan LeftShift agar tidak nyangkut
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                velocityVector = Vector3.new(velocityVector.X, speed, velocityVector.Z)
            elseif UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                velocityVector = Vector3.new(velocityVector.X, -speed, velocityVector.Z)
            else
                velocityVector = Vector3.new(velocityVector.X, 0, velocityVector.Z)
            end
            
            flyBv.velocity = velocityVector
            flyBg.cframe = camera.CFrame
            task.wait()
        end
        stopFlying()
    end)
end

-- Infinite Jump Engine menggunakan JumpRequest (100% bypass)
game:GetService("UserInputService").JumpRequest:Connect(function()
    if Config.InfiniteJump and Player.Character then
        local hum = Player.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

-- Noclip & Anti-Ragdoll Looping Engine
RunService.Stepped:Connect(function()
    if Config.Noclip and Player.Character then
        for _, part in pairs(Player.Character:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
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

-- ====================================================================
-- ADVANCED ESP GLOW & CHAMS ENGINE
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
        
        local tChar = target.Character
        local tHrp = tChar.HumanoidRootPart
        local pHrp = Player.Character.HumanoidRootPart
        local camera = workspace.CurrentCamera
        local _, onScreen = camera:WorldToViewportPoint(tHrp.Position)
        local distance = (pHrp.Position - tHrp.Position).Magnitude

        if Config.TeamCheck and target.Team == Player.Team then cleanESP(target) return end
        if distance > Config.MaxDistance then cleanESP(target) return end

        if not espCache[target] then espCache[target] = {} end

        -- 1. BOX ESP
        if Config.ShowBoxes and onScreen then
            if not espCache[target].Box then
                local b = Instance.new("BoxHandleAdornment")
                b.Size = Vector3.new(4, 5.5, 4) b.Color3 = Theme.Accent b.AlwaysOnTop = true b.Transparency = 0.6
                espCache[target].Box = b
            end
            espCache[target].Box.Adornee = tChar espCache[target].Box.Parent = SafeGuiTarget
        else
            if espCache[target].Box then espCache[target].Box:Destroy() espCache[target].Box = nil end
        end

        -- 2. NAME & DISTANCE ESP
        if Config.ShowNames and onScreen then
            if not espCache[target].Label then
                local bgui = Instance.new("BillboardGui") bgui.Size = UDim2.new(0, 150, 0, 40) bgui.AlwaysOnTop = true bgui.StudsOffset = Vector3.new(0, 3, 0)
                local txt = Instance.new("TextLabel", bgui) txt.Size = UDim2.new(1, 0, 1, 0) txt.BackgroundTransparency = 1 txt.TextColor3 = Theme.TextMain txt.Font = Enum.Font.GothamBold txt.TextSize = 10
                espCache[target].Label = bgui espCache[target].TxtObject = txt
            end
            espCache[target].TxtObject.Text = string.format("%s\n[%d m]", target.DisplayName, math.round(distance))
            espCache[target].Label.Adornee = tHrp espCache[target].Label.Parent = SafeGuiTarget
        else
            if espCache[target].Label then espCache[target].Label:Destroy() espCache[target].Label = nil end
        end

        -- 3. BODY GLOW ESP (HIGHLIGHTS - ALWAYS ON TOP)
        if Config.ShowGlow then
            if not espCache[target].Highlight then
                local hl = Instance.new("Highlight")
                hl.FillColor = Theme.AccentPurple
                hl.FillTransparency = 0.4
                hl.OutlineColor = Theme.TextMain
                hl.OutlineTransparency = 0.1
                hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                espCache[target].Highlight = hl
            end
            espCache[target].Highlight.Adornee = tChar
            espCache[target].Highlight.Parent = SafeGuiTarget
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
-- SYSTEM UTILITY STORAGE SYSTEM LOAD
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

-- GLOBAL SYSTEM POP-UP CONFIRMATION
local PopupFrame = Instance.new("Frame")
PopupFrame.Name = "PopupFrame"
PopupFrame.Parent = MainGui
PopupFrame.Size = UDim2.new(0, 280, 0, 140)
PopupFrame.Position = UDim2.new(0.5, -140, 0.5, -70)
PopupFrame.BackgroundColor3 = Theme.Bg
PopupFrame.BackgroundTransparency = Config.UiTransparency
PopupFrame.Visible = false
PopupFrame.ZIndex = 1000 
Instance.new("UICorner", PopupFrame).CornerRadius = UDim.new(0, 10)
local popStroke = Instance.new("UIStroke", PopupFrame)
popStroke.Color = Theme.AccentPurple
popStroke.Thickness = 1.5

local PopupText = Instance.new("TextLabel", PopupFrame)
PopupText.Size = UDim2.new(1, -24, 0, 50)
PopupText.Position = UDim2.new(0, 12, 0, 20)
PopupText.Text = "Apakah anda yakin?"
PopupText.Font = Enum.Font.GothamBold
PopupText.TextColor3 = Theme.TextMain
PopupText.TextSize = 13
PopupText.TextWrapped = true
PopupText.BackgroundTransparency = 1
PopupText.ZIndex = 1001

local PopupYes = Instance.new("TextButton", PopupFrame)
PopupYes.Size = UDim2.new(0, 110, 0, 30)
PopupYes.Position = UDim2.new(0, 20, 1, -45)
PopupYes.BackgroundColor3 = Color3.fromRGB(30, 60, 45)
PopupYes.Font = Enum.Font.GothamBold
PopupYes.Text = "YA"
PopupYes.TextColor3 = Theme.ConfirmGreen
PopupYes.TextSize = 12
PopupYes.ZIndex = 1001
Instance.new("UICorner", PopupYes).CornerRadius = UDim.new(0, 5)
Instance.new("UIStroke", PopupYes).Color = Theme.Stroke

local PopupNo = Instance.new("TextButton", PopupFrame)
PopupNo.Size = UDim2.new(0, 110, 0, 30)
PopupNo.Position = UDim2.new(1, -130, 1, -45)
PopupNo.BackgroundColor3 = Color3.fromRGB(60, 30, 35)
PopupNo.Font = Enum.Font.GothamBold
PopupNo.Text = "TIDAK"
PopupNo.TextColor3 = Theme.DeleteRed
PopupNo.TextSize = 12
PopupNo.ZIndex = 1001
Instance.new("UICorner", PopupNo).CornerRadius = UDim.new(0, 5)
Instance.new("UIStroke", PopupNo).Color = Theme.Stroke

local currentCallback = nil
local function showConfirmation(message, onYes)
    PopupText.Text = message
    currentCallback = onYes
    PopupFrame.Visible = true
    PopupFrame.Size = UDim2.new(0, 250, 0, 120)
    TweenService:Create(PopupFrame, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 280, 0, 140)}):Play()
end

PopupYes.MouseButton1Click:Connect(function() PopupFrame.Visible = false if currentCallback then currentCallback() end end)
PopupNo.MouseButton1Click:Connect(function() PopupFrame.Visible = false end)

-- LOADING SCREEN VISUAL ELEMENTS
local LoadingFrame = Instance.new("Frame")
LoadingFrame.Name = "LoadingFrame"
LoadingFrame.Parent = MainGui
LoadingFrame.Size = UDim2.new(0, 320, 0, 180)
LoadingFrame.Position = UDim2.new(0.5, -160, 0.5, -90)
LoadingFrame.BackgroundColor3 = Theme.Bg
LoadingFrame.BackgroundTransparency = 0.05
Instance.new("UICorner", LoadingFrame).CornerRadius = UDim.new(0, 10)
local loadStroke = Instance.new("UIStroke", LoadingFrame)
loadStroke.Color = Theme.Stroke
loadStroke.Thickness = 1.5

local LoadTitle = Instance.new("TextLabel", LoadingFrame)
LoadTitle.Size = UDim2.new(1, 0, 0, 40)
LoadTitle.Position = UDim2.new(0, 0, 0, 25)
LoadTitle.Text = "✨ AR SCRIPT HUB"
LoadTitle.Font = Enum.Font.GothamBold
LoadTitle.TextColor3 = Theme.TextMain
LoadTitle.TextSize = 18
LoadTitle.BackgroundTransparency = 1

local LoadStatus = Instance.new("TextLabel", LoadingFrame)
LoadStatus.Size = UDim2.new(1, 0, 0, 20)
LoadStatus.Position = UDim2.new(0, 0, 0, 65)
LoadStatus.Text = "Menginisialisasi modul terbang..."
LoadStatus.Font = Enum.Font.GothamMedium
LoadStatus.TextColor3 = Theme.TextMuted
LoadStatus.TextSize = 11
LoadStatus.BackgroundTransparency = 1

local LoadProgressText = Instance.new("TextLabel", LoadingFrame)
LoadProgressText.Size = UDim2.new(1, 0, 0, 20)
LoadProgressText.Position = UDim2.new(0, 0, 0, 90)
LoadProgressText.Text = "0%"
LoadProgressText.Font = Enum.Font.GothamBold
LoadProgressText.TextColor3 = Theme.AccentPurple
LoadProgressText.TextSize = 14
LoadProgressText.BackgroundTransparency = 1

local LoadTrack = Instance.new("Frame", LoadingFrame)
LoadTrack.Size = UDim2.new(1, -60, 0, 6)
LoadTrack.Position = UDim2.new(0, 30, 0, 125)
LoadTrack.BackgroundColor3 = Theme.CardBg
Instance.new("UICorner", LoadTrack).CornerRadius = UDim.new(0, 3)
local ltStroke = Instance.new("UIStroke", LoadTrack)
ltStroke.Color = Theme.Stroke

local LoadFill = Instance.new("Frame", LoadTrack)
LoadFill.Size = UDim2.new(0, 0, 1, 0)
LoadFill.BackgroundColor3 = Theme.Accent
Instance.new("UICorner", LoadFill).CornerRadius = UDim.new(0, 3)

-- DRAGGABLE BUILDER ENGINE
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

-- FLOATING BUTTON BUILDER
local ToggleButton = Instance.new("TextButton")
ToggleButton.Name = "ToggleButton"
ToggleButton.Parent = MainGui
ToggleButton.Size = UDim2.new(0, 46, 0, 46)
ToggleButton.Position = UDim2.new(0.02, 0, 0.2, 0)
ToggleButton.BackgroundColor3 = Theme.Bg
ToggleButton.BackgroundTransparency = Config.UiTransparency
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.Text = "AR"
ToggleButton.TextColor3 = Theme.Accent
ToggleButton.TextSize = 16
ToggleButton.Visible = false
Instance.new("UICorner", ToggleButton).CornerRadius = UDim.new(0, 9)
local tbStroke = Instance.new("UIStroke", ToggleButton)
tbStroke.Color = Theme.AccentPurple
makeDraggable(ToggleButton, ToggleButton)

-- MAIN PANEL CONTAINER
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = MainGui
MainFrame.Size = UDim2.new(0, 560, 0, 340)
MainFrame.Position = UDim2.new(0.5, -280, 0.5, -170)
MainFrame.BackgroundColor3 = Theme.Bg
MainFrame.BackgroundTransparency = Config.UiTransparency
MainFrame.Visible = false
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)
local mainStroke = Instance.new("UIStroke", MainFrame)
mainStroke.Color = Theme.Stroke
mainStroke.Thickness = 1.5

-- UPDATE PANEL TRANSPARENCY FUNCTION
local function updateUiTransparency(value)
    Config.UiTransparency = value
    MainFrame.BackgroundTransparency = value
    ToggleButton.BackgroundTransparency = value
    PopupFrame.BackgroundTransparency = value
end

-- HEADER CONTAINER
local Header = Instance.new("Frame", MainFrame)
Header.Size = UDim2.new(1, 0, 0, 40)
Header.BackgroundTransparency = 1

local Title = Instance.new("TextLabel", Header)
Title.Text = "✨ AR UI PANEL <font color='#c092ff'>v6.8</font>"
Title.RichText = true
Title.Size = UDim2.new(0.5, 0, 1, 0)
Title.Position = UDim2.new(0, 16, 0, 0)
Title.Font = Enum.Font.GothamBold
Title.TextColor3 = Theme.TextMain
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.BackgroundTransparency = 1

local CloseBtn = Instance.new("TextButton", Header)
CloseBtn.Text = "×" CloseBtn.Size = UDim2.new(0, 35, 1, 0) CloseBtn.Position = UDim2.new(1, -35, 0, 0) CloseBtn.Font = Enum.Font.GothamMedium CloseBtn.TextColor3 = Theme.DeleteRed CloseBtn.TextSize = 24 CloseBtn.BackgroundTransparency = 1

local MinimizeBtn = Instance.new("TextButton", Header)
MinimizeBtn.Text = "−" MinimizeBtn.Size = UDim2.new(0, 35, 1, 0) MinimizeBtn.Position = UDim2.new(1, -70, 0, 0) MinimizeBtn.Font = Enum.Font.GothamMedium MinimizeBtn.TextColor3 = Theme.TextMuted MinimizeBtn.TextSize = 20 MinimizeBtn.BackgroundTransparency = 1

makeDraggable(MainFrame, Header)
ToggleButton.MouseButton1Click:Connect(function() MainFrame.Visible = true ToggleButton.Visible = false end)
MinimizeBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false ToggleButton.Visible = true end)
CloseBtn.MouseButton1Click:Connect(function() showConfirmation("Hub akan ditutup secara permanen,\napakah kamu yakin?", function() MainGui:Destroy() end) end)

-- TOP BAR NAVIGATION
local TopBarNav = Instance.new("Frame", MainFrame)
TopBarNav.Name = "TopBarNav"
TopBarNav.Size = UDim2.new(1, -32, 0, 36)
TopBarNav.Position = UDim2.new(0, 16, 0, 45)
TopBarNav.BackgroundColor3 = Theme.CardBg
TopBarNav.BackgroundTransparency = 0.6
Instance.new("UICorner", TopBarNav).CornerRadius = UDim.new(0, 6)
local navStroke = Instance.new("UIStroke", TopBarNav)
navStroke.Color = Theme.Stroke

local NavLayout = Instance.new("UIListLayout", TopBarNav) NavLayout.FillDirection = Enum.FillDirection.Horizontal NavLayout.SortOrder = Enum.SortOrder.LayoutOrder NavLayout.VerticalAlignment = Enum.VerticalAlignment.Center NavLayout.Padding = UDim.new(0, 4)
local paddingNav = Instance.new("UIPadding", TopBarNav) paddingNav.PaddingLeft = UDim.new(0, 6)

-- CANVAS CONTENT WITH AUTOMATIC SCROLLING
local MainContentFrame = Instance.new("ScrollingFrame", MainFrame)
MainContentFrame.Name = "MainContentFrame"
MainContentFrame.Size = UDim2.new(1, -16, 1, -105)
MainContentFrame.Position = UDim2.new(0, 0, 0, 95)
MainContentFrame.BackgroundTransparency = 1
MainContentFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
MainContentFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
MainContentFrame.ScrollBarThickness = 3
MainContentFrame.ScrollBarImageColor3 = Theme.Accent

local framePadding = Instance.new("UIPadding", MainContentFrame) framePadding.PaddingTop = UDim.new(0, 4) framePadding.PaddingBottom = UDim.new(0, 20) framePadding.PaddingLeft = UDim.new(0, 16)

local menuContainers = {}
local function createMenuPage(name, isVisible)
    local page = Instance.new("Frame", MainContentFrame)
    page.Name = name .. "Page"
    page.Size = UDim2.new(0, 536, 0, 0)
    page.AutomaticSize = Enum.AutomaticSize.Y
    page.BackgroundTransparency = 1
    page.Visible = isVisible
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
    local btn = Instance.new("TextButton", TopBarNav)
    btn.Size = UDim2.new(0, 96, 0, 26)
    btn.BackgroundColor3 = Color3.fromRGB(30, 32, 54)
    btn.Font = Enum.Font.GothamBold
    btn.Text = textDisplay
    btn.TextSize = 11
    btn.TextColor3 = Theme.TextMain
    btn.LayoutOrder = order
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
    local bStroke = Instance.new("UIStroke", btn) bStroke.Color = Theme.Stroke
    
    btn.MouseButton1Click:Connect(function()
        for _, child in pairs(TopBarNav:GetChildren()) do if child:IsA("TextButton") then child.TextColor3 = Theme.TextMain end end
        btn.TextColor3 = Theme.Accent
        switchTab(tabTarget)
    end)
    return btn
end

local btnPlayer = addTopBarButton("👤 Player", "Player", 1)
btnPlayer.TextColor3 = Theme.Accent
addTopBarButton("👁️ ESP", "ESP", 2)
addTopBarButton("🌀 Teleportation", "Teleportation", 3)
addTopBarButton("🌐 Server", "Server", 4)
addTopBarButton("⚙️ Setting", "Setting", 5)

-- DYNAMIC BUILDER HELPERS FOR INLINE INTERACTION
local function addToggle(parent, labelText, order, configKey, callback)
    local holder = Instance.new("Frame", parent) holder.Size = UDim2.new(1, 0, 0, 24) holder.BackgroundTransparency = 1 holder.LayoutOrder = order
    local lbl = Instance.new("TextLabel", holder) lbl.Text = labelText lbl.Size = UDim2.new(1, -40, 1, 0) lbl.Font = Enum.Font.GothamMedium lbl.TextColor3 = Theme.TextMain lbl.TextSize = 12 lbl.TextXAlignment = Enum.TextXAlignment.Left lbl.BackgroundTransparency = 1

    local track = Instance.new("TextButton", holder) track.Size = UDim2.new(0, 32, 0, 16) track.Position = UDim2.new(1, -32, 0.5, -8) track.BackgroundColor3 = Theme.Bg track.Text = "" Instance.new("UICorner", track).CornerRadius = UDim.new(0, 8) local tStr = Instance.new("UIStroke", track) tStr.Color = Theme.Stroke
    local knob = Instance.new("Frame", track) knob.Size = UDim2.new(0, 10, 0, 10) knob.Position = UDim2.new(0, 3, 0.5, -5) knob.BackgroundColor3 = Theme.TextMuted Instance.new("UICorner", knob).CornerRadius = UDim.new(0, 5)
    
    track.MouseButton1Click:Connect(function()
        if not configKey then return end
        Config[configKey] = not Config[configKey]
        local active = Config[configKey]
        TweenService:Create(knob, TweenInfo.new(0.08), {Position = UDim2.new(0, active and 19 or 3, 0.5, -5)}):Play()
        TweenService:Create(track, TweenInfo.new(0.08), {BackgroundColor3 = active and Theme.Accent or Theme.Bg}):Play()
        tStr.Color = active and Theme.Accent or Theme.Stroke
        if callback then callback(active) end
    end)
end

local function addSliderWithInput(parent, labelText, min, max, defaultVal, order, configKey, callback)
    local holder = Instance.new("Frame", parent) holder.Size = UDim2.new(1, 0, 0, 38) holder.BackgroundTransparency = 1 holder.LayoutOrder = order
    local lbl = Instance.new("TextLabel", holder) lbl.Text = labelText lbl.Size = UDim2.new(0.65, 0, 0, 14) lbl.Font = Enum.Font.GothamMedium lbl.TextColor3 = Theme.TextMain lbl.TextSize = 11 lbl.TextXAlignment = Enum.TextXAlignment.Left lbl.BackgroundTransparency = 1

    local inputBox = Instance.new("TextBox", holder) inputBox.Size = UDim2.new(0, 36, 0, 16) inputBox.Position = UDim2.new(1, -36, 0, 0) inputBox.BackgroundColor3 = Theme.Bg inputBox.Font = Enum.Font.GothamBold inputBox.Text = tostring(defaultVal) inputBox.TextColor3 = Theme.Accent inputBox.TextSize = 10 Instance.new("UICorner", inputBox).CornerRadius = UDim.new(0, 4) local bStr = Instance.new("UIStroke", inputBox) bStr.Color = Theme.Stroke

    local track = Instance.new("Frame", holder) track.Size = UDim2.new(1, 0, 0, 4) track.Position = UDim2.new(0, 0, 1, -4) track.BackgroundColor3 = Theme.Stroke Instance.new("UICorner", track).CornerRadius = UDim.new(0, 2)
    local fill = Instance.new("Frame", track) local startPerc = math.clamp((defaultVal - min) / (max - min), 0, 1) fill.Size = UDim2.new(startPerc, 0, 1, 0) fill.BackgroundColor3 = Theme.Accent Instance.new("UICorner", fill).CornerRadius = UDim.new(0, 2)
    local knob = Instance.new("Frame", track) knob.Size = UDim2.new(0, 10, 0, 10) knob.Position = UDim2.new(startPerc, -5, 0.5, -5) knob.BackgroundColor3 = Theme.TextMain Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0) Instance.new("UIStroke", knob).Color = Theme.AccentPurple
    local dragTrigger = Instance.new("ImageButton", knob) dragTrigger.Size = UDim2.new(2, 0, 2, 0) dragTrigger.Position = UDim2.new(-0.5, 0, -0.5, 0) dragTrigger.BackgroundTransparency = 1

    local function refreshVisuals(value)
        local clampedValue = math.clamp(value, min, max)
        if configKey then Config[configKey] = clampedValue end
        local perc = (clampedValue - min) / (max - min)
        fill.Size = UDim2.new(perc, 0, 1, 0) knob.Position = UDim2.new(perc, -5, 0.5, -5) inputBox.Text = tostring(clampedValue)
        if callback then callback(clampedValue) end
    end

    local sliding = false
    dragTrigger.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then sliding = true end end)
    UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then sliding = false end end)
    UserInputService.InputChanged:Connect(function(input)
        if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local relX = input.Position.X - track.AbsolutePosition.X
            local perc = math.clamp(relX / track.AbsoluteSize.X, 0, 1)
            refreshVisuals(math.round(min + (perc * (max - min))))
        end
    end)
    inputBox.FocusLost:Connect(function() local num = tonumber(inputBox.Text) refreshVisuals(num or min) end)
end

local function createStatLabel(parent, labelText, order)
    local lbl = Instance.new("TextLabel", parent) lbl.Size = UDim2.new(1, 0, 0, 18) lbl.BackgroundTransparency = 1 lbl.Font = Enum.Font.GothamMedium lbl.Text = labelText lbl.TextColor3 = Theme.TextMain lbl.TextSize = 11 lbl.TextXAlignment = Enum.TextXAlignment.Left lbl.LayoutOrder = order
    return lbl
end

local function createServerButton(parent, text, color, onClick, order)
    local btn = Instance.new("TextButton", parent) btn.Size = UDim2.new(1, 0, 0, 26) btn.BackgroundColor3 = color btn.Font = Enum.Font.GothamBold btn.Text = text btn.TextColor3 = Theme.TextMain btn.TextSize = 11 btn.LayoutOrder = order Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5) Instance.new("UIStroke", btn).Color = Theme.Stroke btn.MouseButton1Click:Connect(onClick) return btn
end

local function createCard(parent, titleText, order)
    local card = Instance.new("Frame", parent) card.Size = UDim2.new(1, 0, 0, 0) card.AutomaticSize = Enum.AutomaticSize.Y card.BackgroundColor3 = Theme.CardBg card.BackgroundTransparency = Theme.CardTrans card.LayoutOrder = order Instance.new("UICorner", card).CornerRadius = UDim.new(0, 8) Instance.new("UIStroke", card).Color = Theme.Stroke local ttl = Instance.new("TextLabel", card) ttl.Size = UDim2.new(1, -12, 0, 26) ttl.Position = UDim2.new(0, 12, 0, 4) ttl.Text = titleText:upper() ttl.Font = Enum.Font.GothamBold ttl.TextColor3 = Theme.AccentPurple ttl.TextSize = 11 ttl.BackgroundTransparency = 1 ttl.TextXAlignment = Enum.TextXAlignment.Left local container = Instance.new("Frame", card) container.Size = UDim2.new(1, -24, 0, 0) container.AutomaticSize = Enum.AutomaticSize.Y container.Position = UDim2.new(0, 12, 0, 32) container.BackgroundTransparency = 1 local innerLayout = Instance.new("UIListLayout", container) innerLayout.Padding = UDim.new(0, 12) innerLayout.SortOrder = Enum.SortOrder.LayoutOrder Instance.new("UIPadding", container).PaddingBottom = UDim.new(0, 12) return container
end

local function createLeftColumn(parentName, columnName)
    local col = Instance.new("Frame", menuContainers[parentName]) col.Name = columnName col.Size = UDim2.new(0, 255, 0, 0) col.AutomaticSize = Enum.AutomaticSize.Y col.BackgroundTransparency = 1 local layout = Instance.new("UIListLayout", col) layout.Padding = UDim.new(0, 12) layout.SortOrder = Enum.SortOrder.LayoutOrder return col
end

local function createShiftedRightColumn(parentName, columnName)
    local col = Instance.new("Frame", menuContainers[parentName]) col.Name = columnName col.Size = UDim2.new(0, 255, 0, 0) col.AutomaticSize = Enum.AutomaticSize.Y col.Position = UDim2.new(0, 263, 0, 0) col.BackgroundTransparency = 1 local layout = Instance.new("UIListLayout", col) layout.Padding = UDim.new(0, 12) layout.SortOrder = Enum.SortOrder.LayoutOrder return col
end

-- COLUMN INSTANCES CREATION
local LeftColumn = createLeftColumn("Player", "LeftColumn")
local RightColumn = createShiftedRightColumn("Player", "RightColumn")
local espLeftColumn = createLeftColumn("ESP", "EspLeftColumn")
local espRightColumn = createShiftedRightColumn("ESP", "EspRightColumn")
local tpLeftColumn = createLeftColumn("Teleportation", "TpLeftColumn")
local tpRightColumn = createShiftedRightColumn("Teleportation", "TpRightColumn")
local serverLeftColumn = createLeftColumn("Server", "ServerLeftColumn")
local serverRightColumn = createShiftedRightColumn("Server", "ServerRightColumn")

-- ====================================================================
-- RENDERING SETTING PAGE (CLIENT INFO & TRANSPARENCY SLIDER)
-- ====================================================================
local SetLeftColumn = createLeftColumn("Setting", "SetLeftColumn")
local SetRightColumn = createShiftedRightColumn("Setting", "SetRightColumn")
local clientInfoCard = createCard(SetLeftColumn, "Client Information", 1)
local infoUser = createStatLabel(clientInfoCard, "Username: Loading...", 1)
local infoExec = createStatLabel(clientInfoCard, "Executor: Loading...", 2)
local infoMap = createStatLabel(clientInfoCard, "Map Name: Loading...", 3)
infoUser.Text = "Username: <font color='#73aaff'>" .. Player.Name .. "</font> (" .. Player.UserId .. ")"
infoUser.RichText = true
infoExec.Text = "Executor: <font color='#c092ff'>" .. CurrentExecutor .. "</font>"
infoExec.RichText = true
infoMap.Text = "Map: <font color='#73aaff'>" .. CurrentMapName .. "</font>"
infoMap.RichText = true

local visualSetCard = createCard(SetLeftColumn, "Visual Settings", 2)
addSliderWithInput(visualSetCard, "UI Background Opacity", 0, 90, 15, 1, nil, function(val) updateUiTransparency(val / 100) end)

local coreActionCard = createCard(SetRightColumn, "Core Actions", 1)
createServerButton(coreActionCard, "🔴 Destroy System UI", Theme.DeleteBg, function() showConfirmation("Apakah kamu ingin menghancurkan UI?", function() MainGui:Destroy() end) end, 1)

-- ====================================================================
-- RENDERING PLAYER PAGE
-- ====================================================================
local flyCard = createCard(LeftColumn, "Fly Control", 1)
addToggle(flyCard, "Fly Engine Active", 1, "FlyMode", handleFlyEngine)
addSliderWithInput(flyCard, "Fly Speed Multiplier", 1, 20, 5, 2, "FlySpeed")
addToggle(flyCard, "Noclip Enabled", 3, "Noclip")

local walkCard = createCard(LeftColumn, "Superspeed", 2)
addToggle(walkCard, "Super Speed Active", 1, "SuperSpeed", enforceHumanoidProperties)
addSliderWithInput(walkCard, "Speed Value Configuration", 16, 250, 16, 2, "SuperSpeedVal", enforceHumanoidProperties)

local jumpCard = createCard(RightColumn, "Jump Modification", 1)
addToggle(jumpCard, "Super Jump Active", 1, "SuperJump", enforceHumanoidProperties)
addSliderWithInput(jumpCard, "Jump Power Customization", 50, 500, 50, 2, "SuperJumpVal", enforceHumanoidProperties)
addToggle(jumpCard, "Infinite Jump Engine", 3, "InfiniteJump")

local physicsCard = createCard(LeftColumn, "Physics Modifier", 3)
addSliderWithInput(physicsCard, "Global Gravity Value", 0, 196, 196, 1, "Gravity", function(val) workspace.Gravity = val end)
addSliderWithInput(physicsCard, "Humanoid HipHeight Mod", 0, 20, 2, 2, "HipHeight", function(val) if Player.Character and Player.Character:FindFirstChildOfClass("Humanoid") then Player.Character:FindFirstChildOfClass("Humanoid").HipHeight = val end end)

local utilCard = createCard(RightColumn, "Character Utilities", 2)
addToggle(utilCard, "Anti Ragdoll / Fall State", 1, "AntiRagdoll")
addToggle(utilCard, "Infinite Oxygen Valve", 2, "InfiniteOxygen")

-- ====================================================================
-- RENDERING ESP PAGE
-- ====================================================================
local playerEspCard = createCard(espLeftColumn, "Visual ESP Engine", 1)
addToggle(playerEspCard, "Enable Master ESP", 1, "EnableESP")
addToggle(playerEspCard, "Show 3D Boxes", 2, "ShowBoxes")
addToggle(playerEspCard, "Show Text Label Info", 3, "ShowNames")
addToggle(playerEspCard, "Show Chams Highlight (Glow)", 4, "ShowGlow")
addToggle(playerEspCard, "Team Check Bypass", 5, "TeamCheck")
addSliderWithInput(playerEspCard, "Max Rendering Range (m)", 100, 5000, 1000, 6, "MaxDistance")

local visualPerformanceCard = createCard(espRightColumn, "Performance Optimization", 1)
addToggle(visualPerformanceCard, "Disable Global Shadows", 1, "ShadowsDisabled", applyGraphicsBoost)
addToggle(visualPerformanceCard, "Aggressive Lag Reducer", 2, "AntiLag", applyGraphicsBoost)

-- ====================================================================
-- RENDERING SERVER PAGE (DITAMBAHKAN RESPAWN & RESET)
-- ====================================================================
local srvManagementCard = createCard(serverLeftColumn, "Server Connections", 1)
createServerButton(srvManagementCard, "Rejoin Current Server", Color3.fromRGB(35, 45, 75), function() TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, Player) end, 1)
createServerButton(srvManagementCard, "Hop to Another Server", Color3.fromRGB(40, 35, 65), function()
    local success, servers = pcall(function() return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100")) end)
    if success and servers and servers.data then
        for _, srv in pairs(servers.data) do
            if srv.id ~= game.JobId and srv.playing < srv.maxPlayers then
                TeleportService:TeleportToPlaceInstance(game.PlaceId, srv.id, Player) break
            end
        end
    end
end, 2)

local charSrvCard = createCard(serverRightColumn, "Character Control Server", 1)
-- FITUR BARU: RESPAWN (Memaksa memuat ulang karakter tanpa membunuh status streak game)
createServerButton(charSrvCard, "⚡ Respawn Character", Color3.fromRGB(30, 55, 75), function()
    local oldPos = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") and Player.Character.HumanoidRootPart.CFrame
    Player:LoadCharacter()
    task.spawn(function()
        if oldPos then
            local char = Player.CharacterAdded:Wait()
            local hrp = char:WaitForChild("HumanoidRootPart", 5)
            if hrp then task.wait(0.2) hrp.CFrame = oldPos end
        end
    end)
end, 1)

-- FITUR BARU: RESET CHARACTER (Membunuh instan/suicide untuk reset normal)
createServerButton(charSrvCard, "💀 Reset Character (Die)", Color3.fromRGB(75, 30, 35), function()
    if Player.Character and Player.Character:FindFirstChildOfClass("Humanoid") then
        Player.Character:FindFirstChildOfClass("Humanoid").Health = 0
    end
end, 2)

-- ====================================================================
-- RENDERING TELEPORTATION PAGE (DENGAN LANDMARK OTOMATIS PLOT)
-- ====================================================================
local manualTpCard = createCard(tpLeftColumn, "Saved Landmarks Location", 1)
local areaTpCard = Instance.new("Frame", manualTpCard)
areaTpCard.Size = UDim2.new(1, 0, 0, 0)
areaTpCard.AutomaticSize = Enum.AutomaticSize.Y
areaTpCard.BackgroundTransparency = 1
local tpListLayout = Instance.new("UIListLayout", areaTpCard)
tpListLayout.Padding = UDim.new(0, 6)
tpListLayout.SortOrder = Enum.SortOrder.LayoutOrder

function deleteWaypoint(name)
    if AllWaypoints[CurrentPlaceId] and AllWaypoints[CurrentPlaceId][name] then
        AllWaypoints[CurrentPlaceId][name] = nil
        saveWaypointsToStorage()
        refreshLandmarksUI()
    end
end

function refreshLandmarksUI()
    -- Bersihkan UI lama
    for _, child in pairs(areaTpCard:GetChildren()) do 
        if child:IsA("Frame") or child:IsA("TextLabel") then child:Destroy() end 
    end
    
    local indexOrder = 1

    -- ====================================================
    -- 1. LANDMARK OTOMATIS: TITIK SPAWN PLOT (DINAMIS & PERMANEN)
    -- ====================================================
    local plotSpawnPos = getMyPlotSpawn()
    if plotSpawnPos then
        local rowFrame = Instance.new("Frame", areaTpCard) 
        rowFrame.Size = UDim2.new(1, 0, 0, 26) 
        rowFrame.BackgroundTransparency = 1 
        rowFrame.LayoutOrder = indexOrder
        
        local btn = Instance.new("TextButton", rowFrame) 
        btn.Size = UDim2.new(1, 0, 1, 0) -- Lebar 100% full
        btn.BackgroundColor3 = Color3.fromRGB(45, 35, 85) -- Penanda warna ungu spesial
        btn.Font = Enum.Font.GothamBold 
        btn.Text = "⭐ [OTOMATIS] Spawn Plot Saya" 
        btn.TextColor3 = Theme.AccentPurple
        btn.TextSize = 11 
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5) 
        Instance.new("UIStroke", btn).Color = Theme.AccentPurple
        
        btn.MouseButton1Click:Connect(function()
            -- Membaca ulang letak plot terbaru saat tombol diklik (realtime)
            local currentPlotPos = getMyPlotSpawn()
            if currentPlotPos and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
                Player.Character.HumanoidRootPart.CFrame = CFrame.new(currentPlotPos + Vector3.new(0, 3, 0))
            end
        end)
        
        indexOrder = indexOrder + 1
    end

    -- ====================================================
    -- 2. LANDMARK MANUAL (DARI STORAGE FILE JSON)
    -- ====================================================
    local currentMapData = AllWaypoints[CurrentPlaceId] or {}
    for wpName, coord in pairs(currentMapData) do
        local rowFrame = Instance.new("Frame", areaTpCard)
        rowFrame.Size = UDim2.new(1, 0, 0, 26)
        rowFrame.BackgroundTransparency = 1
        rowFrame.LayoutOrder = indexOrder
        
        local btn = Instance.new("TextButton", rowFrame)
        btn.Size = UDim2.new(1, -32, 1, 0)
        btn.BackgroundColor3 = Theme.CardBg
        btn.Font = Enum.Font.GothamMedium
        btn.Text = "📍 " .. wpName
        btn.TextColor3 = Theme.TextMain
        btn.TextSize = 11
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)
        Instance.new("UIStroke", btn).Color = Theme.Stroke
        
        btn.MouseButton1Click:Connect(function()
            if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
                Player.Character.HumanoidRootPart.CFrame = CFrame.new(coord[1], coord[2], coord[3])
            end
        end)
        
        local delBtn = Instance.new("TextButton", rowFrame)
        delBtn.Size = UDim2.new(0, 26, 1, 0)
        delBtn.Position = UDim2.new(1, -26, 0, 0)
        delBtn.BackgroundColor3 = Theme.DeleteBg
        delBtn.Font = Enum.Font.GothamBold
        delBtn.Text = "×"
        delBtn.TextColor3 = Theme.DeleteRed
        delBtn.TextSize = 16
        Instance.new("UICorner", delBtn).CornerRadius = UDim.new(0, 5)

        delBtn.MouseButton1Click:Connect(function()
            showConfirmation("Hapus posisi \"" .. wpName .. "\"?", function() deleteWaypoint(wpName) end)
        end)
        indexOrder = indexOrder + 1
    end
    
    -- Status jika tidak ada plot terdeteksi & data kosong
    if indexOrder == 1 then
        local emptyTxt = Instance.new("TextLabel", areaTpCard)
        emptyTxt.Size = UDim2.new(1, 0, 0, 24)
        emptyTxt.BackgroundTransparency = 1
        emptyTxt.Font = Enum.Font.GothamMedium
        emptyTxt.Text = "Belum ada landmark tersimpan."
        emptyTxt.TextColor3 = Theme.TextMuted
        emptyTxt.TextSize = 10
        emptyTxt.LayoutOrder = 1
    end
end

local creationCard = createCard(tpRightColumn, "Save Current Position", 1)
local wpInput = Instance.new("TextBox", creationCard)
wpInput.Size = UDim2.new(1, 0, 0, 26)
wpInput.BackgroundColor3 = Theme.Bg
wpInput.Font = Enum.Font.GothamMedium
wpInput.PlaceholderText = "Masukkan nama landmark..."
wpInput.Text = ""
wpInput.TextColor3 = Theme.TextMain
wpInput.TextSize = 11
Instance.new("UICorner", wpInput).CornerRadius = UDim.new(0, 5)
local wpiStroke = Instance.new("UIStroke", wpInput)
wpiStroke.Color = Theme.Stroke

createServerButton(creationCard, "💾 Save Position Coordinate", Color3.fromRGB(30, 55, 45), function()
    local name = wpInput.Text
    if name ~= "" and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
        local pos = Player.Character.HumanoidRootPart.Position
        if not AllWaypoints[CurrentPlaceId] then AllWaypoints[CurrentPlaceId] = {} end
        AllWaypoints[CurrentPlaceId][name] = {math.round(pos.X), math.round(pos.Y), math.round(pos.Z)}
        saveWaypointsToStorage()
        wpInput.Text = ""
        refreshLandmarksUI()
    end
end, 2)

refreshLandmarksUI()

-- ====================================================================
-- PROGRESS BAR LOADING SYSTEM ANIMATION INTERACTION (Bypass Render)
-- ====================================================================
local stages = {
    {t = 15, m = "Menginisialisasi modul terbang..."},
    {t = 35, m = "Memuat modul tembus dinding (Noclip)..."},
    {t = 55, m = "Menyusun grafis rendering Engine..."},
    {t = 75, m = "Menghubungkan penyimpanan lokal JSON..."},
    {t = 90, m = "Mencari data plot Tycoon otomatis..."}
}

task.spawn(function()
    for i = 1, 100 do
        local progress = i / 100
        TweenService:Create(LoadFill, TweenInfo.new(0.02, Enum.EasingStyle.Linear), {Size = UDim2.new(progress, 0, 1, 0)}):Play()
        LoadProgressText.Text = tostring(i) .. "%"
        for _, stage in ipairs(stages) do if i == stage.t then LoadStatus.Text = stage.m end end
        task.wait(0.02)
    end
    
    LoadStatus.Text = "Sistem Siap!"
    task.wait(0.3)
    
    local f = TweenService:Create(LoadingFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 1})
    TweenService:Create(LoadTitle, TweenInfo.new(0.2), {TextTransparency = 1}):Play()
    TweenService:Create(LoadStatus, TweenInfo.new(0.2), {TextTransparency = 1}):Play()
    TweenService:Create(LoadProgressText, TweenInfo.new(0.2), {TextTransparency = 1}):Play()
    TweenService:Create(LoadTrack, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
    TweenService:Create(LoadFill, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
    TweenService:Create(loadStroke, TweenInfo.new(0.2), {Transparency = 1}):Play()
    TweenService:Create(ltStroke, TweenInfo.new(0.2), {Transparency = 1}):Play()
    f:Play()
    
    f.Completed:Connect(function()
        LoadingFrame:Destroy()
        MainFrame.Visible = true
    end)
end)
