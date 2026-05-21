-- ====================================================================
-- AR SCRIPT HUB - v6.8 MODULAR CORE LOADER
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
-- STATE MANAGEMENT CONFIGURATION (GLOBAL CONFIG)
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
    UiTransparency = 0.15
}

-- ====================================================================
-- GITHUB EXTERNAL MODULES INJECTION (MENGAMBIL MODUL TERPISAH)
-- ====================================================================
local GITHUB_BASE = "https://raw.githubusercontent.com/UsernameKamu/RepoKamu/main/"

local function GetModule(path)
    local success, result = pcall(function()
        return loadstring(game:HttpGet(GITHUB_BASE .. path))()
    end)
    if success and result then
        return result
    else
        warn("[-] Gagal memuat modul: " .. path)
        return nil
    end
end

-- Ambil modul eksternal via GitHub
local PlayerModule = GetModule("modules/player.lua")
local EspModule   = GetModule("modules/esp.lua")
local TpModule    = GetModule("modules/teleport.lua")
local ServerModule = GetModule("modules/server.lua")

-- Metadata System Info
local CurrentMapName = "Unknown Game"
pcall(function()
    local productInfo = MarketplaceService:GetProductInfo(game.PlaceId)
    if productInfo and productInfo.Name then CurrentMapName = productInfo.Name end
end)
local CurrentExecutor = (identifyexecutor or getexecutorname or function() return "Unknown Executor" end)()

-- ====================================================================
-- POP-UP CONFIRMATION SYSTEM
-- ====================================================================
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

-- ====================================================================
-- DRAGGABLE ENGINE & UI UTILITIES
-- ====================================================================
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

-- Floating Toggle Button
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

-- Main Base Frame
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

local function updateUiTransparency(value)
    Config.UiTransparency = value
    MainFrame.BackgroundTransparency = value
    ToggleButton.BackgroundTransparency = value
    PopupFrame.BackgroundTransparency = value
end

-- ====================================================================
-- HEADER & NAVIGATION LAYOUTING
-- ====================================================================
local Header = Instance.new("Frame", MainFrame)
Header.Size = UDim2.new(1, 0, 0, 40)
Header.BackgroundTransparency = 1

local Title = Instance.new("TextLabel", Header)
Title.Text = "AR SCRIPT HUB <font color='#c092ff'>v6.8</font>"
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

local TopBarNav = Instance.new("Frame", MainFrame)
TopBarNav.Size = UDim2.new(1, -32, 0, 36)
TopBarNav.Position = UDim2.new(0, 16, 0, 45)
TopBarNav.BackgroundColor3 = Theme.CardBg
TopBarNav.BackgroundTransparency = 0.6
Instance.new("UICorner", TopBarNav).CornerRadius = UDim.new(0, 6)
local navStroke = Instance.new("UIStroke", TopBarNav)
navStroke.Color = Theme.Stroke

local NavLayout = Instance.new("UIListLayout", TopBarNav) NavLayout.FillDirection = Enum.FillDirection.Horizontal NavLayout.SortOrder = Enum.SortOrder.LayoutOrder NavLayout.VerticalAlignment = Enum.VerticalAlignment.Center NavLayout.Padding = UDim.new(0, 4)
local paddingNav = Instance.new("UIPadding", TopBarNav) paddingNav.PaddingLeft = UDim.new(0, 6)

local MainContentFrame = Instance.new("ScrollingFrame", MainFrame)
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

-- ====================================================================
-- INTERACTION DYNAMIC CREATOR
-- ====================================================================
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
    local btn = Instance.new("TextButton", parent) btn.Size = UDim2.new(1, 0, 0, 26) btn.BackgroundColor3 = color btn.Font = Enum.Font.GothamBold btn.Text = text btn.TextColor3 = Theme.TextMain btn.TextSize = 11 btn.LayoutOrder = order Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5) Instance.new("UIStroke", btn).Color = Theme.Stroke
    btn.MouseButton1Click:Connect(onClick) return btn
end

local function createCard(parent, titleText, order)
    local card = Instance.new("Frame", parent) card.Size = UDim2.new(1, 0, 0, 0) card.AutomaticSize = Enum.AutomaticSize.Y card.BackgroundColor3 = Theme.CardBg card.BackgroundTransparency = Theme.CardTrans card.LayoutOrder = order Instance.new("UICorner", card).CornerRadius = UDim.new(0, 8) Instance.new("UIStroke", card).Color = Theme.Stroke
    local ttl = Instance.new("TextLabel", card) ttl.Size = UDim2.new(1, -12, 0, 26) ttl.Position = UDim2.new(0, 12, 0, 4) ttl.Text = titleText:upper() ttl.Font = Enum.Font.GothamBold ttl.TextColor3 = Theme.AccentPurple ttl.TextSize = 11 ttl.BackgroundTransparency = 1 ttl.TextXAlignment = Enum.TextXAlignment.Left
    local container = Instance.new("Frame", card) container.Size = UDim2.new(1, -24, 0, 0) container.AutomaticSize = Enum.AutomaticSize.Y container.Position = UDim2.new(0, 12, 0, 32) container.BackgroundTransparency = 1
    local innerLayout = Instance.new("UIListLayout", container) innerLayout.Padding = UDim.new(0, 12) innerLayout.SortOrder = Enum.SortOrder.LayoutOrder
    Instance.new("UIPadding", container).PaddingBottom = UDim.new(0, 12)
    return container
end

local function createLeftColumn(parentName, columnName)
    local col = Instance.new("Frame", menuContainers[parentName]) col.Name = columnName col.Size = UDim2.new(0, 255, 0, 0) col.AutomaticSize = Enum.AutomaticSize.Y col.BackgroundTransparency = 1
    local layout = Instance.new("UIListLayout", col) layout.Padding = UDim.new(0, 12) layout.SortOrder = Enum.SortOrder.LayoutOrder
    return col
end

local function createShiftedRightColumn(parentName, columnName)
    local col = Instance.new("Frame", menuContainers[parentName]) col.Name = columnName col.Size = UDim2.new(0, 255, 0, 0) col.AutomaticSize = Enum.AutomaticSize.Y col.Position = UDim2.new(0, 263, 0, 0) col.BackgroundTransparency = 1
    local layout = Instance.new("UIListLayout", col) layout.Padding = UDim.new(0, 12) layout.SortOrder = Enum.SortOrder.LayoutOrder
    return col
end

-- Instansiasi Kolom Grid
local LeftColumn = createLeftColumn("Player", "LeftColumn")
local RightColumn = createShiftedRightColumn("Player", "RightColumn")
local espLeftColumn = createLeftColumn("ESP", "EspLeftColumn")
local espRightColumn = createShiftedRightColumn("ESP", "EspRightColumn")
local tpLeftColumn = createLeftColumn("Teleportation", "TpLeftColumn")
local tpRightColumn = createShiftedRightColumn("Teleportation", "TpRightColumn")
local serverLeftColumn = createLeftColumn("Server", "ServerLeftColumn")
local serverRightColumn = createShiftedRightColumn("Server", "ServerRightColumn")
local SetLeftColumn = createLeftColumn("Setting", "SetLeftColumn")
local SetRightColumn = createShiftedRightColumn("Setting", "SetRightColumn")

-- ====================================================================
-- RENDER MENU: PLAYER PAGE
-- ====================================================================
local flyCard = createCard(LeftColumn, "Fly Control", 1)
addToggle(flyCard, "Fly Mode", 1, "FlyMode", function(state) if PlayerModule then PlayerModule.ToggleFly(state, Config) end end) 
addSliderWithInput(flyCard, "Fly Speed Costumization", 1, 20, 5, 2, "FlySpeed") 
addToggle(flyCard, "Noclip", 3, "Noclip", function(state) if PlayerModule then PlayerModule.ToggleNoclip(state) end end)

local walkCard = createCard(LeftColumn, "Superspeed", 2)
addToggle(walkCard, "Super Speed", 1, "SuperSpeed", function() if PlayerModule then PlayerModule.UpdateHumanoid(Config) end end) 
addSliderWithInput(walkCard, "Super Speed Costumization", 16, 250, 16, 2, "SuperSpeedVal", function() if PlayerModule then PlayerModule.UpdateHumanoid(Config) end end)

local jumpCard = createCard(RightColumn, "Jump Modification", 1)
addToggle(jumpCard, "Super Jump", 1, "SuperJump", function() if PlayerModule then PlayerModule.UpdateHumanoid(Config) end end) 
addSliderWithInput(jumpCard, "Jump Power Customization", 50, 500, 50, 2, "SuperJumpVal", function() if PlayerModule then PlayerModule.UpdateHumanoid(Config) end end) 
addToggle(jumpCard, "Infinite Jump", 3, "InfiniteJump", function(state) if PlayerModule then PlayerModule.ToggleInfJump(state) end end)

local physicsCard = createCard(LeftColumn, "Physics Modifier", 3)
addSliderWithInput(physicsCard, "Global Gravity ", 0, 196, 196, 1, "Gravity", function(val) workspace.Gravity = val end) 
addSliderWithInput(physicsCard, "HipHeight Controller", 0, 20, 2, 2, "HipHeight", function(val) if PlayerModule then PlayerModule.SetHipHeight(val) end end)

local utilCard = createCard(RightColumn, "Character Utilities", 2)
addToggle(utilCard, "Anti Ragdoll / Fall State", 1, "AntiRagdoll", function(state) if PlayerModule then PlayerModule.ToggleAntiRagdoll(state) end end) 
addToggle(utilCard, "Infinite Oxygen Valve", 2, "InfiniteOxygen", function(state) if PlayerModule then PlayerModule.ToggleInfOxygen(state) end end)

-- ====================================================================
-- RENDER MENU: ESP PAGE
-- ====================================================================
local playerEspCard = createCard(espLeftColumn, "Visual ESP Engine", 1)
addToggle(playerEspCard, "Enable ESP Master", 1, "EnableESP", function(state) if EspModule then EspModule.ToggleESP(state, Config, Theme, SafeGuiTarget) end end) 
addToggle(playerEspCard, "Show Outer 3D Boxes", 2, "ShowBoxes") 
addToggle(playerEspCard, "Show Text Identifiers", 3, "ShowNames") 
addToggle(playerEspCard, "Show Chams", 4, "ShowGlow")

local espSettingsCard = createCard(espRightColumn, "ESP Configuration", 1)
addToggle(espSettingsCard, "Enforce Team Check", 1, "TeamCheck") 
addSliderWithInput(espSettingsCard, "Max Distance Threshold", 100, 5000, 1000, 2, "MaxDistance")

-- ====================================================================
-- RENDER MENU: TELEPORTATION PAGE
-- ====================================================================
if TpModule then TpModule.Init(HttpService, game.PlaceId) end

local playerTpCard = createCard(tpLeftColumn, "Target Player Teleport", 1)
local inputPlayerFrame = Instance.new("Frame", playerTpCard) inputPlayerFrame.Size = UDim2.new(1, 0, 0, 28) inputPlayerFrame.BackgroundTransparency = 1 inputPlayerFrame.LayoutOrder = 1
local tpPlayerInput = Instance.new("TextBox", inputPlayerFrame) tpPlayerInput.Size = UDim2.new(1, 0, 1, 0) tpPlayerInput.BackgroundColor3 = Theme.Bg tpPlayerInput.Font = Enum.Font.GothamMedium tpPlayerInput.PlaceholderText = "Masukkan nama player..." tpPlayerInput.TextColor3 = Theme.TextMain tpPlayerInput.PlaceholderColor3 = Theme.TextMuted tpPlayerInput.TextSize = 11 Instance.new("UICorner", tpPlayerInput).CornerRadius = UDim.new(0, 5) Instance.new("UIStroke", tpPlayerInput).Color = Theme.Stroke

local btnPlayerTp = Instance.new("TextButton", playerTpCard) btnPlayerTp.Size = UDim2.new(1, 0, 0, 26) btnPlayerTp.BackgroundColor3 = Theme.Accent btnPlayerTp.Font = Enum.Font.GothamBold btnPlayerTp.Text = "⚡ Teleport ke Player" btnPlayerTp.TextColor3 = Theme.Bg btnPlayerTp.TextSize = 11 btnPlayerTp.LayoutOrder = 2 Instance.new("UICorner", btnPlayerTp).CornerRadius = UDim.new(0, 5)

btnPlayerTp.MouseButton1Click:Connect(function()
    if TpModule then TpModule.TeleportToPlayer(tpPlayerInput.Text) end
end)

local waypointCard = createCard(tpLeftColumn, "Local Position Saver", 2)
local inputWpFrame = Instance.new("Frame", waypointCard) inputWpFrame.Size = UDim2.new(1, 0, 0, 28) inputWpFrame.BackgroundTransparency = 1 inputWpFrame.LayoutOrder = 1
local wpNameInput = Instance.new("TextBox", inputWpFrame) wpNameInput.Size = UDim2.new(1, 0, 1, 0) wpNameInput.BackgroundColor3 = Theme.Bg wpNameInput.Font = Enum.Font.GothamMedium wpNameInput.PlaceholderText = "Nama waypoint baru..." wpNameInput.TextColor3 = Theme.TextMain wpNameInput.PlaceholderColor3 = Theme.TextMuted wpNameInput.TextSize = 11 Instance.new("UICorner", wpNameInput).CornerRadius = UDim.new(0, 5) Instance.new("UIStroke", wpNameInput).Color = Theme.Stroke

local btnSavePos = Instance.new("TextButton", waypointCard) btnSavePos.Size = UDim2.new(1, 0, 0, 26) btnSavePos.BackgroundColor3 = Color3.fromRGB(35, 45, 85) btnSavePos.Font = Enum.Font.GothamBold btnSavePos.Text = "💾 Simpan Posisi Saat Ini" btnSavePos.TextColor3 = Theme.Accent btnSavePos.TextSize = 11 btnSavePos.LayoutOrder = 2 Instance.new("UICorner", btnSavePos).CornerRadius = UDim.new(0, 5) Instance.new("UIStroke", btnSavePos).Color = Theme.Stroke

local areaTpCard = createCard(tpRightColumn, "Saved CFrame Milestones", 1)
local refreshLandmarksUI

function refreshLandmarksUI()
    for _, child in pairs(areaTpCard:GetChildren()) do if child:IsA("Frame") or child:IsA("TextLabel") then child:Destroy() end end
    if not TpModule then return end
    
    local landmarks = TpModule.GetWaypoints()
    local indexOrder = 1
    for wpName, coord in pairs(landmarks) do
        local rowFrame = Instance.new("Frame", areaTpCard) rowFrame.Size = UDim2.new(1, 0, 0, 26) rowFrame.BackgroundTransparency = 1 rowFrame.LayoutOrder = indexOrder
        local btn = Instance.new("TextButton", rowFrame) btn.Size = UDim2.new(1, -32, 1, 0) btn.BackgroundColor3 = Theme.CardBg btn.Font = Enum.Font.GothamMedium btn.Text = "📍 " .. wpName btn.TextColor3 = Theme.TextMain btn.TextSize = 11 Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5) Instance.new("UIStroke", btn).Color = Theme.Stroke
        
        btn.MouseButton1Click:Connect(function() TpModule.TeleportToWaypoint(wpName) end)
        
        local delBtn = Instance.new("TextButton", rowFrame) delBtn.Size = UDim2.new(0, 26, 1, 0) delBtn.Position = UDim2.new(1, -26, 0, 0) delBtn.BackgroundColor3 = Theme.DeleteBg delBtn.Font = Enum.Font.GothamBold delBtn.Text = "×" delBtn.TextColor3 = Theme.DeleteRed delBtn.TextSize = 16 Instance.new("UICorner", delBtn).CornerRadius = UDim.new(0, 5)
        delBtn.MouseButton1Click:Connect(function() 
            showConfirmation("Hapus posisi \"" .. wpName .. "\"?", function() 
                TpModule.DeleteWaypoint(wpName) refreshLandmarksUI() 
            end) 
        end)
        indexOrder = indexOrder + 1
    end
    if indexOrder == 1 then
        local emptyTxt = Instance.new("TextLabel", areaTpCard) emptyTxt.Size = UDim2.new(1, 0, 0, 24) emptyTxt.BackgroundTransparency = 1 emptyTxt.Font = Enum.Font.GothamMedium emptyTxt.Text = "Belum ada landmark tersimpan." emptyTxt.TextColor3 = Theme.TextMuted emptyTxt.TextSize = 10 emptyTxt.LayoutOrder = 1
    end
end

btnSavePos.MouseButton1Click:Connect(function()
    if TpModule and wpNameInput.Text ~= "" then
        TpModule.SaveCurrentPosition(wpNameInput.Text)
        wpNameInput.Text = ""
        refreshLandmarksUI()
    end
end)
refreshLandmarksUI()

-- ====================================================================
-- RENDER MENU: SERVER PAGE
-- ====================================================================
local statsCard = createCard(serverLeftColumn, "Live Server Telemetry", 1)
local lblFps = createStatLabel(statsCard, "FPS: 00.0", 1)
local lblPing = createStatLabel(statsCard, "Ping: 0.00 ms", 2)
local lblTime = createStatLabel(statsCard, "Server Age: 00:00:00", 3)

task.spawn(function()
    while task.wait(0.2) do
        if not MainGui or not MainGui.Parent then break end
        if ServerModule then
            local fps, ping, serverAge = ServerModule.GetTelemetry(Stats)
            lblFps.Text = "FPS: <font color='#73aaff'>" .. fps .. " FPS</font>"
            lblFps.RichText = true
            lblPing.Text = "Ping: <font color='#73aaff'>" .. ping .. " ms</font>"
            lblPing.RichText = true
            lblTime.Text = "Server Age: <font color='#c092ff'>" .. serverAge .. "</font>"
            lblTime.RichText = true
        end
    end
end)

local navCard = createCard(serverLeftColumn, "Server Connections", 2)
createServerButton(navCard, "🔄 Rejoin Current Instance", Color3.fromRGB(30, 35, 60), function()
    showConfirmation("Rejoin ke server saat ini?", function() if ServerModule then ServerModule.Rejoin() end end)
end, 1)

createServerButton(navCard, "🚀 Matchmaking Server Hop", Color3.fromRGB(45, 30, 60), function()
    showConfirmation("Cari dan pindah server?", function() if ServerModule then ServerModule.ServerHop(HttpService, TeleportService) end end)
end, 2)

local optiCard = createCard(serverRightColumn, "Graphic Optimizations", 1)
createServerButton(optiCard, "🗑️ Purge Environmental Memory", Color3.fromRGB(25, 45, 35), function()
    if ServerModule then
        local cleaned = ServerModule.PurgeMemory()
        showConfirmation("Berhasil membersihkan " .. tostring(cleaned) .. " objek lag.", function() end)
    end
end, 1)
addToggle(optiCard, "Disable Global Shadows", 2, "ShadowsDisabled", function(state) if ServerModule then ServerModule.ToggleShadows(state) end end)
addToggle(optiCard, "Anti-Lag Core Engine", 3, "AntiLag", function(state) if ServerModule then ServerModule.ToggleAntiLag(state) end end)

-- ====================================================================
-- RENDER MENU: SETTING PAGE
-- ====================================================================
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
addSliderWithInput(visualSetCard, "UI Background Opacity", 0, 90, 15, 1, nil, function(val)
    updateUiTransparency(val / 100)
end)

local coreActionCard = createCard(SetRightColumn, "Core Actions", 1)
createServerButton(coreActionCard, "🔴 Close System UI", Theme.DeleteBg, function()
    showConfirmation("Apakah kamu ingin menutup UI?", function() MainGui:Destroy() end)
end, 1)

-- Hook Event Player demi stabilitas modul
Player.CharacterAdded:Connect(function(char)
    char:WaitForChild("Humanoid", 5)
    if PlayerModule then PlayerModule.UpdateHumanoid(Config) end
end)

-- ====================================================================
-- INTRO LOADING SEQUENCE ANIMATION
-- ====================================================================
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
LoadTitle.Text = "AR SCRIPT HUB"
LoadTitle.Font = Enum.Font.GothamBold
LoadTitle.TextColor3 = Theme.TextMain
LoadTitle.TextSize = 18
LoadTitle.BackgroundTransparency = 1

local LoadStatus = Instance.new("TextLabel", LoadingFrame)
LoadStatus.Size = UDim2.new(1, 0, 0, 20)
LoadStatus.Position = UDim2.new(0, 0, 0, 65)
LoadStatus.Text = "Menghubungkan ke GitHub modules..."
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

task.spawn(function()
    local stages = {
        {t = 20, m = "Mengunduh Player Modules..."},
        {t = 50, m = "Menyuntikkan ESP Chams..."},
        {t = 80, m = "Menyinkronkan Waypoint Storage..."}
    }
    for i = 1, 100 do
        local progress = i / 100
        TweenService:Create(LoadFill, TweenInfo.new(0.01, Enum.EasingStyle.Linear), {Size = UDim2.new(progress, 0, 1, 0)}):Play()
        LoadProgressText.Text = tostring(i) .. "%"
        for _, stage in ipairs(stages) do if i == stage.t then LoadStatus.Text = stage.m end end
        task.wait(0.015)
    end
    LoadStatus.Text = "Sistem Siap!"
    task.wait(0.2)
    
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
        ToggleButton.Visible = false
        MainFrame.Size = UDim2.new(0, 520, 0, 300)
        TweenService:Create(MainFrame, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 560, 0, 340)}):Play()
    end)
end)
