-- ====================================================================
-- AR SCRIPT HUB - v6.2 FULL PRODUCTION DEPLOY (FIXED LOADING STUCK)
-- ====================================================================
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local SafeGuiTarget = Player:FindFirstChildOfClass("PlayerGui") or Player:WaitForChild("PlayerGui", 5)
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

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
    BgTrans = 0.15,                          
    CardBg = Color3.fromRGB(20, 22, 38),     
    CardTrans = 0.4,                         
    Stroke = Color3.fromRGB(56, 52, 92),     
    Accent = Color3.fromRGB(115, 170, 255),  
    AccentPurple = Color3.fromRGB(190, 130, 255), 
    TextMain = Color3.fromRGB(245, 245, 255),
    TextMuted = Color3.fromRGB(140, 145, 175)
}

-- ====================================================================
-- LOADING SCREEN SYSTEM
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
LoadTitle.Text = "✨ AR SCRIPT HUB"
LoadTitle.Font = Enum.Font.GothamBold
LoadTitle.TextColor3 = Theme.TextMain
LoadTitle.TextSize = 18
LoadTitle.BackgroundTransparency = 1

local LoadStatus = Instance.new("TextLabel", LoadingFrame)
LoadStatus.Size = UDim2.new(1, 0, 0, 20)
LoadStatus.Position = UDim2.new(0, 0, 0, 65)
LoadStatus.Text = "Menghubungkan ke server..."
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
ToggleButton.Size = UDim2.new(0, 46, 0, 46)
ToggleButton.Position = UDim2.new(0.02, 0, 0.2, 0)
ToggleButton.BackgroundColor3 = Theme.Bg
ToggleButton.BackgroundTransparency = 0.15
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.Text = "AR"
ToggleButton.TextColor3 = Theme.Accent
ToggleButton.TextSize = 16
ToggleButton.Visible = false
Instance.new("UICorner", ToggleButton).CornerRadius = UDim.new(0, 9)
local tbStroke = Instance.new("UIStroke", ToggleButton)
tbStroke.Color = Theme.AccentPurple
makeDraggable(ToggleButton, ToggleButton)

-- MAIN PANEL
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = MainGui
MainFrame.Size = UDim2.new(0, 560, 0, 340)
MainFrame.Position = UDim2.new(0.5, -280, 0.5, -170)
MainFrame.BackgroundColor3 = Theme.Bg
MainFrame.BackgroundTransparency = Theme.BgTrans
MainFrame.Visible = false
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)
local mainStroke = Instance.new("UIStroke", MainFrame)
mainStroke.Color = Theme.Stroke
mainStroke.Thickness = 1.5

-- HEADER BLOCK
local Header = Instance.new("Frame", MainFrame)
Header.Size = UDim2.new(1, 0, 0, 40)
Header.BackgroundTransparency = 1

local Title = Instance.new("TextLabel", Header)
Title.Text = "✨ AR UI PANEL <font color='#c092ff'>v6.2</font>"
Title.RichText = true
Title.Size = UDim2.new(0.5, 0, 1, 0)
Title.Position = UDim2.new(0, 16, 0, 0)
Title.Font = Enum.Font.GothamBold
Title.TextColor3 = Theme.TextMain
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.BackgroundTransparency = 1

local CloseBtn = Instance.new("TextButton", Header)
CloseBtn.Text = "×"
CloseBtn.Size = UDim2.new(0, 40, 1, 0)
CloseBtn.Position = UDim2.new(1, -40, 0, 0)
CloseBtn.Font = Enum.Font.GothamMedium
CloseBtn.TextColor3 = Theme.TextMuted
CloseBtn.TextSize = 24
CloseBtn.BackgroundTransparency = 1

makeDraggable(MainFrame, Header)
ToggleButton.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)
CloseBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false end)

-- TOP BAR NAVIGATION MENU
local TopBarNav = Instance.new("Frame", MainFrame)
TopBarNav.Name = "TopBarNav"
TopBarNav.Size = UDim2.new(1, -32, 0, 36)
TopBarNav.Position = UDim2.new(0, 16, 0, 45)
TopBarNav.BackgroundColor3 = Theme.CardBg
TopBarNav.BackgroundTransparency = 0.6
Instance.new("UICorner", TopBarNav).CornerRadius = UDim.new(0, 6)
local navStroke = Instance.new("UIStroke", TopBarNav)
navStroke.Color = Theme.Stroke

local NavLayout = Instance.new("UIListLayout", TopBarNav)
NavLayout.FillDirection = Enum.FillDirection.Horizontal
NavLayout.SortOrder = Enum.SortOrder.LayoutOrder
NavLayout.VerticalAlignment = Enum.VerticalAlignment.Center
NavLayout.Padding = UDim.new(0, 4)

local paddingNav = Instance.new("UIPadding", TopBarNav)
paddingNav.PaddingLeft = UDim.new(0, 6)

-- CANVAS UTAMA KONTEN DENGAN SCROLL (PEMBATAS DIHAPUS, SCROLLBAR DI DALAM SPACE)
local MainContentFrame = Instance.new("ScrollingFrame", MainFrame)
MainContentFrame.Name = "MainContentFrame"
MainContentFrame.Size = UDim2.new(1, -16, 1, -105)
MainContentFrame.Position = UDim2.new(0, 0, 0, 95)
MainContentFrame.BackgroundTransparency = 1
MainContentFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
MainContentFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y

MainContentFrame.VerticalScrollBarInset = Enum.ScrollBarInset.None 
MainContentFrame.ScrollBarThickness = 3 
MainContentFrame.ScrollBarImageColor3 = Theme.Accent
MainContentFrame.VerticalScrollBarPosition = Enum.VerticalScrollBarPosition.Right

local framePadding = Instance.new("UIPadding", MainContentFrame)
framePadding.PaddingTop = UDim.new(0, 4)
framePadding.PaddingBottom = UDim.new(0, 20)
framePadding.PaddingLeft = UDim.new(0, 16)
framePadding.PaddingRight = UDim.new(0, 0) 

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
    for name, page in pairs(menuContainers) do
        page.Visible = (name == tabName)
    end
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
    local bStroke = Instance.new("UIStroke", btn)
    bStroke.Color = Theme.Stroke
    
    btn.MouseButton1Click:Connect(function()
        for _, child in pairs(TopBarNav:GetChildren()) do
            if child:IsA("TextButton") then child.TextColor3 = Theme.TextMain end
        end
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

-- PLACEHOLDER MAKER (Hanya untuk Server)
local function buildPlaceholder(pageFrame, titleText)
    local card = Instance.new("Frame", pageFrame)
    card.Size = UDim2.new(0, 519, 0, 150) 
    card.BackgroundColor3 = Theme.CardBg
    card.BackgroundTransparency = Theme.CardTrans
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 8)
    Instance.new("UIStroke", card).Color = Theme.Stroke
    
    local txt = Instance.new("TextLabel", card)
    txt.Size = UDim2.new(1, 0, 1, 0)
    txt.Text = "<b>" .. titleText .. " MENU FRAMEWORK</b>\n\nArea kosong siap diisi komponen kustom."
    txt.RichText = true txt.Font = Enum.Font.GothamMedium txt.TextColor3 = Theme.TextMuted txt.TextSize = 12 txt.BackgroundTransparency = 1 txt.TextYAlignment = Enum.TextYAlignment.Center
end
buildPlaceholder(serverPage, "SERVER")

-- SETTING PAGE DISSOLVE
local setCard = Instance.new("Frame", settingPage) setCard.Size = UDim2.new(0, 519, 0, 150) setCard.BackgroundColor3 = Theme.CardBg setCard.BackgroundTransparency = Theme.CardTrans Instance.new("UICorner", setCard).CornerRadius = UDim.new(0, 8) Instance.new("UIStroke", setCard).Color = Theme.Stroke
local destBtn = Instance.new("TextButton", setCard) destBtn.Size = UDim2.new(0, 160, 0, 32) destBtn.Position = UDim2.new(0.5, -80, 0.5, -16) destBtn.BackgroundColor3 = Theme.Bg destBtn.Font = Enum.Font.GothamBold destBtn.Text = "🔴 Destroy System UI" destBtn.TextColor3 = Theme.AccentPurple destBtn.TextSize = 12 Instance.new("UICorner", destBtn).CornerRadius = UDim.new(0, 5) Instance.new("UIStroke", destBtn).Color = Theme.Stroke
destBtn.MouseButton1Click:Connect(function() MainGui:Destroy() end)

-- SISTEM FILTER SEKAT 5PX & CARD RAMING 257PX PUSAT KIRI
local function createLeftColumn(parentName, columnName)
    local col = Instance.new("Frame", menuContainers[parentName])
    col.Name = columnName
    col.Size = UDim2.new(0, 257, 0, 0)
    col.AutomaticSize = Enum.AutomaticSize.Y
    col.Position = UDim2.new(0, 0, 0, 0) 
    col.BackgroundTransparency = 1
    
    local layout = Instance.new("UIListLayout", col)
    layout.Padding = UDim.new(0, 12)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    return col
end

local function createShiftedRightColumn(parentName, columnName)
    local col = Instance.new("Frame", menuContainers[parentName])
    col.Name = columnName
    col.Size = UDim2.new(0, 257, 0, 0)
    col.AutomaticSize = Enum.AutomaticSize.Y
    col.Position = UDim2.new(0, 262, 0, 0) 
    col.BackgroundTransparency = 1
    
    local layout = Instance.new("UIListLayout", col)
    layout.Padding = UDim.new(0, 12)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    return col
end

-- Registrasi Kolom-Kolom Utama Halaman
local LeftColumn = createLeftColumn("Player", "LeftColumn")
local RightColumn = createShiftedRightColumn("Player", "RightColumn")

local espLeftColumn = createLeftColumn("ESP", "EspLeftColumn")
local espRightColumn = createShiftedRightColumn("ESP", "EspRightColumn")

local tpLeftColumn = createLeftColumn("Teleportation", "TpLeftColumn")
local tpRightColumn = createShiftedRightColumn("Teleportation", "TpRightColumn")

-- FUNGSI KREASI CARD AUTOMATIC SIZE
local function createCard(parent, titleText, order)
    local card = Instance.new("Frame", parent)
    card.Size = UDim2.new(1, 0, 0, 0)
    card.AutomaticSize = Enum.AutomaticSize.Y 
    card.BackgroundColor3 = Theme.CardBg
    card.BackgroundTransparency = Theme.CardTrans
    card.LayoutOrder = order
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 8)
    
    local stroke = Instance.new("UIStroke", card)
    stroke.Color = Theme.Stroke
    stroke.Thickness = 1
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border 
    
    local ttl = Instance.new("TextLabel", card)
    ttl.Size = UDim2.new(1, -12, 0, 26)
    ttl.Position = UDim2.new(0, 12, 0, 4)
    ttl.Text = titleText:upper()
    ttl.Font = Enum.Font.GothamBold
    ttl.TextColor3 = Theme.AccentPurple
    ttl.TextSize = 11
    ttl.BackgroundTransparency = 1
    ttl.TextXAlignment = Enum.TextXAlignment.Left
    
    local container = Instance.new("Frame", card)
    container.Size = UDim2.new(1, -24, 0, 0)
    container.AutomaticSize = Enum.AutomaticSize.Y
    container.Position = UDim2.new(0, 12, 0, 32)
    container.BackgroundTransparency = 1
    
    local innerLayout = Instance.new("UIListLayout", container)
    innerLayout.Padding = UDim.new(0, 12)
    innerLayout.SortOrder = Enum.SortOrder.LayoutOrder
    
    local pdd = Instance.new("UIPadding", container)
    pdd.PaddingBottom = UDim.new(0, 12)
    
    return container
end

-- COMPONENT PRIMITIVES
local function addToggle(parent, labelText, order)
    local holder = Instance.new("Frame", parent) 
    holder.Size = UDim2.new(1, 0, 0, 24) 
    holder.BackgroundTransparency = 1 
    holder.LayoutOrder = order
    
    local lbl = Instance.new("TextLabel", holder) 
    lbl.Text = labelText 
    lbl.Size = UDim2.new(1, -40, 1, 0) 
    lbl.Font = Enum.Font.GothamMedium 
    lbl.TextColor3 = Theme.TextMain 
    lbl.TextSize = 12 
    lbl.TextXAlignment = Enum.TextXAlignment.Left 
    lbl.BackgroundTransparency = 1
    lbl.TextWrapped = true 

    local track = Instance.new("TextButton", holder) 
    track.Size = UDim2.new(0, 32, 0, 16) 
    track.Position = UDim2.new(1, -32, 0.5, -8) 
    track.BackgroundColor3 = Theme.Bg 
    track.Text = "" 
    Instance.new("UICorner", track).CornerRadius = UDim.new(0, 8) 
    local tStr = Instance.new("UIStroke", track) 
    tStr.Color = Theme.Stroke
    
    local knob = Instance.new("Frame", track) 
    knob.Size = UDim2.new(0, 10, 0, 10) 
    knob.Position = UDim2.new(0, 3, 0.5, -5) 
    knob.BackgroundColor3 = Theme.TextMuted 
    Instance.new("UICorner", knob).CornerRadius = UDim.new(0, 5)
    
    local active = false
    track.MouseButton1Click:Connect(function()
        active = not active
        TweenService:Create(knob, TweenInfo.new(0.08), {Position = UDim2.new(0, active and 19 or 3, 0.5, -5)}):Play()
        TweenService:Create(track, TweenInfo.new(0.08), {BackgroundColor3 = active and Theme.Accent or Theme.Bg}):Play()
        tStr.Color = active and Theme.Accent or Theme.Stroke
    end)
end

local function addSliderWithInput(parent, labelText, min, max, defaultVal, order)
    local holder = Instance.new("Frame", parent)
    holder.Size = UDim2.new(1, 0, 0, 38)
    holder.BackgroundTransparency = 1
    holder.LayoutOrder = order
    
    local lbl = Instance.new("TextLabel", holder)
    lbl.Text = labelText lbl.Size = UDim2.new(0.65, 0, 0, 14) lbl.Font = Enum.Font.GothamMedium lbl.TextColor3 = Theme.TextMain lbl.TextSize = 11 lbl.TextXAlignment = Enum.TextXAlignment.Left lbl.BackgroundTransparency = 1 lbl.TextWrapped = true

    local inputBox = Instance.new("TextBox", holder)
    inputBox.Size = UDim2.new(0, 36, 0, 16)
    inputBox.Position = UDim2.new(1, -36, 0, 0)
    inputBox.BackgroundColor3 = Theme.Bg
    inputBox.Font = Enum.Font.GothamBold
    inputBox.Text = tostring(defaultVal)
    inputBox.TextColor3 = Theme.Accent
    inputBox.TextSize = 10
    inputBox.ClearTextOnFocus = false
    Instance.new("UICorner", inputBox).CornerRadius = UDim.new(0, 4)
    local bStr = Instance.new("UIStroke", inputBox) bStr.Color = Theme.Stroke

    local track = Instance.new("Frame", holder)
    track.Size = UDim2.new(1, 0, 0, 4)
    track.Position = UDim2.new(0, 0, 1, -4)
    track.BackgroundColor3 = Theme.Stroke
    Instance.new("UICorner", track).CornerRadius = UDim.new(0, 2)

    local fill = Instance.new("Frame", track)
    local startPerc = math.clamp((defaultVal - min) / (max - min), 0, 1)
    fill.Size = UDim2.new(startPerc, 0, 1, 0)
    fill.BackgroundColor3 = Theme.Accent
    Instance.new("UICorner", fill).CornerRadius = UDim.new(0, 2)

    local knob = Instance.new("Frame", track)
    knob.Size = UDim2.new(0, 10, 0, 10)
    knob.Position = UDim2.new(startPerc, -5, 0.5, -5)
    knob.BackgroundColor3 = Theme.TextMain
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)
    Instance.new("UIStroke", knob).Color = Theme.AccentPurple

    local dragTrigger = Instance.new("ImageButton", knob)
    dragTrigger.Size = UDim2.new(2, 0, 2, 0) dragTrigger.Position = UDim2.new(-0.5, 0, -0.5, 0) dragTrigger.BackgroundTransparency = 1 dragTrigger.Image = ""

    local function refreshVisuals(value)
        local clampedValue = math.clamp(value, min, max)
        local perc = (clampedValue - min) / (max - min)
        fill.Size = UDim2.new(perc, 0, 1, 0)
        knob.Position = UDim2.new(perc, -5, 0.5, -5)
        inputBox.Text = tostring(clampedValue)
    end

    local sliding = false
    dragTrigger.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then sliding = true end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then sliding = false end
    end)
    UserInputService.InputChanged:Connect(function(input)
        -- KUNCI PERBAIKAN: Ditambahkan Enum.UserInputType secara utuh biar loading ga crash
        if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local relX = input.Position.X - track.AbsolutePosition.X
            local perc = math.clamp(relX / track.AbsoluteSize.X, 0, 1)
            local finalVal = math.round(min + (perc * (max - min)))
            refreshVisuals(finalVal)
        end
    end)

    inputBox.FocusLost:Connect(function(enterPressed)
        local num = tonumber(inputBox.Text)
        if num then refreshVisuals(num) else inputBox.Text = tostring(min) refreshVisuals(min) end
    end)
end

-- ====================================================================
-- PERAKITAN CARD TAB PLAYER
-- ====================================================================
local flyCard = createCard(LeftColumn, "Fly", 1)
addToggle(flyCard, "Fly Mode", 1)
addSliderWithInput(flyCard, "Fly Speed Controller", 1, 100, 16, 2)
addToggle(flyCard, "Noclip", 3)

local walkCard = createCard(LeftColumn, "Superspeed", 2)
addToggle(walkCard, "Super Speed", 1)
addSliderWithInput(walkCard, "Super Speed Controller", 16, 250, 16, 2)

local jumpCard = createCard(RightColumn, "Jump", 1)
addToggle(jumpCard, "Super Jump", 1)
addSliderWithInput(jumpCard, "Super Jump Controller", 50, 500, 50, 2)
addToggle(jumpCard, "Infinite Jump", 3)

local physicsCard = createCard(LeftColumn, "Physics", 3)
addSliderWithInput(physicsCard, "Gravity Controller", 0, 196, 196, 1)
addSliderWithInput(physicsCard, "HipHeight Modifier", 0, 20, 2, 2)

local utilCard = createCard(RightColumn, "Utilities", 2)
addToggle(utilCard, "Anti Ragdoll", 1)
addToggle(utilCard, "Infinite Oxygen", 2)

-- ====================================================================
-- PERAKITAN CARD TAB ESP
-- ====================================================================
local playerEspCard = createCard(espLeftColumn, "Player ESP", 1)
addToggle(playerEspCard, "Enable ESP", 1)
addToggle(playerEspCard, "Show Boxes", 2)
addToggle(playerEspCard, "Show Names", 3)
addToggle(playerEspCard, "Show Tracers", 4)

local espSettingsCard = createCard(espRightColumn, "ESP Settings", 1)
addToggle(espSettingsCard, "Team Check", 1)
addSliderWithInput(espSettingsCard, "Max Distance Controller", 100, 5000, 1000, 2)

-- ====================================================================
-- PERAKITAN CARD TAB TELEPORTATION (v6.3 - PERMANENT SAVING SYSTEM)
-- ====================================================================
local HttpService = game:GetService("HttpService")
local FILE_NAME = "AR_Hub_Waypoints.json"
local CurrentPlaceId = tostring(game.PlaceId)

-- Struktur Data Utama untuk menampung Waypoint di RAM
local AllWaypoints = {}

-- Fungsi Load Data dari Penyimpanan Storage (.json)
local function loadWaypointsFromStorage()
    AllWaypoints = {} -- Reset RAM
    local success, content = pcall(function()
        return readfile(FILE_NAME)
    end)
    
    if success and content then
        local decodeSuccess, decodedData = pcall(function()
            return HttpService:JSONDecode(content)
        end)
        if decodeSuccess and type(decodedData) == "table" then
            AllWaypoints = decodedData
        end
    else
        -- Jika file belum ada, buat file teks kosong baru
        pcall(function()
            writefile(FILE_NAME, HttpService:JSONEncode({}))
        end)
    end
    
    -- Pastikan slot untuk Map/PlaceId saat ini sudah tersedia berupa table
    if not AllWaypoints[CurrentPlaceId] then
        AllWaypoints[CurrentPlaceId] = {}
    end
end

-- Fungsi Save Data RAM ke dalam file Storage (.json)
local function saveWaypointsToStorage()
    pcall(function()
        writefile(FILE_NAME, HttpService:JSONEncode(AllWaypoints))
    end)
end

-- Ambil data lama saat skrip pertama kali dijalankan
loadWaypointsFromStorage()

-- Pembuatan UI Konten Kolom Kiri & Kanan
local playerTpCard = createCard(tpLeftColumn, "Player Teleport", 1)

local inputPlayerFrame = Instance.new("Frame", playerTpCard)
inputPlayerFrame.Size = UDim2.new(1, 0, 0, 28)
inputPlayerFrame.BackgroundTransparency = 1
inputPlayerFrame.LayoutOrder = 1

local tpPlayerInput = Instance.new("TextBox", inputPlayerFrame)
tpPlayerInput.Size = UDim2.new(1, 0, 1, 0)
tpPlayerInput.BackgroundColor3 = Theme.Bg
tpPlayerInput.Font = Enum.Font.GothamMedium
tpPlayerInput.PlaceholderText = "Masukkan nama player..."
tpPlayerInput.Text = ""
tpPlayerInput.TextColor3 = Theme.TextMain
tpPlayerInput.PlaceholderColor3 = Theme.TextMuted
tpPlayerInput.TextSize = 11
tpPlayerInput.ClearTextOnFocus = true
Instance.new("UICorner", tpPlayerInput).CornerRadius = UDim.new(0, 5)
local inputStroke = Instance.new("UIStroke", tpPlayerInput)
inputStroke.Color = Theme.Stroke

local btnPlayerTp = Instance.new("TextButton", playerTpCard)
btnPlayerTp.Size = UDim2.new(1, 0, 0, 26)
btnPlayerTp.BackgroundColor3 = Theme.Accent
btnPlayerTp.Font = Enum.Font.GothamBold
btnPlayerTp.Text = "⚡ Teleport ke Player"
btnPlayerTp.TextColor3 = Theme.Bg
btnPlayerTp.TextSize = 11
btnPlayerTp.LayoutOrder = 2
Instance.new("UICorner", btnPlayerTp).CornerRadius = UDim.new(0, 5)

btnPlayerTp.MouseButton1Click:Connect(function()
    local targetName = tpPlayerInput.Text:lower()
    if targetName ~= "" then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= Player and (p.Name:lower():sub(1, #targetName) == targetName or p.DisplayName:lower():sub(1, #targetName) == targetName) then
                if p.Character and p.Character:FindFirstChild("HumanoidRootPart") and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
                    Player.Character.HumanoidRootPart.CFrame = p.Character.HumanoidRootPart.CFrame * CFrame.new(0, 2, 0)
                    break
                end
            end
        end
    end
end)


-- CARD KIRI: TEMPAT INPUT & SIMPAN CUSTOM WAYPOINT
local waypointCard = createCard(tpLeftColumn, "Custom Waypoints", 2)

local inputWpFrame = Instance.new("Frame", waypointCard)
inputWpFrame.Size = UDim2.new(1, 0, 0, 28)
inputWpFrame.BackgroundTransparency = 1
inputWpFrame.LayoutOrder = 1

local wpNameInput = Instance.new("TextBox", inputWpFrame)
wpNameInput.Size = UDim2.new(1, 0, 1, 0)
wpNameInput.BackgroundColor3 = Theme.Bg
wpNameInput.Font = Enum.Font.GothamMedium
wpNameInput.PlaceholderText = "Nama waypoint baru..."
wpNameInput.Text = ""
wpNameInput.TextColor3 = Theme.TextMain
wpNameInput.PlaceholderColor3 = Theme.TextMuted
wpNameInput.TextSize = 11
wpNameInput.ClearTextOnFocus = true
Instance.new("UICorner", wpNameInput).CornerRadius = UDim.new(0, 5)
local wpInputStroke = Instance.new("UIStroke", wpNameInput)
wpInputStroke.Color = Theme.Stroke

local btnSavePos = Instance.new("TextButton", waypointCard)
btnSavePos.Size = UDim2.new(1, 0, 0, 26)
btnSavePos.BackgroundColor3 = Color3.fromRGB(35, 45, 85)
btnSavePos.Font = Enum.Font.GothamBold
btnSavePos.Text = "💾 Simpan Posisi Saat Ini"
btnSavePos.TextColor3 = Theme.Accent
btnSavePos.TextSize = 11
btnSavePos.LayoutOrder = 2
Instance.new("UICorner", btnSavePos).CornerRadius = UDim.new(0, 5)
local saveStroke = Instance.new("UIStroke", btnSavePos)
saveStroke.Color = Theme.Stroke


-- CARD KANAN: TEMPAT MENAMPILKAN LANDMARKS HASIL SAVE
local areaTpCard = createCard(tpRightColumn, "Saved Landmarks", 1)

-- Fungsi Render Ulang Tombol di Kolom Kanan (Clear lalu Gambar Ulang)
local function refreshLandmarksUI()
    -- Bersihkan tombol lama di dalam card agar tidak menumpuk saat di-update
    for _, child in pairs(areaTpCard:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end
    
    -- Ambil data koordinat khusus map/place ini
    local currentMapData = AllWaypoints[CurrentPlaceId] or {}
    local indexOrder = 1
    
    for wpName, coord in pairs(currentMapData) do
        local btn = Instance.new("TextButton", areaTpCard)
        btn.Size = UDim2.new(1, 0, 0, 26)
        btn.BackgroundColor3 = Theme.CardBg
        btn.Font = Enum.Font.GothamMedium
        btn.Text = "📍 " .. wpName
        btn.TextColor3 = Theme.TextMain
        btn.TextSize = 11
        btn.LayoutOrder = indexOrder
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)
        local bStr = Instance.new("UIStroke", btn)
        bStr.Color = Theme.Stroke
        
        -- Logika Teleportasi saat Landmark diklik
        btn.MouseButton1Click:Connect(function()
            if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
                -- Konversi data Array di JSON kembali ke tipe data CFrame Roblox
                local targetCFrame = CFrame.new(coord[1], coord[2], coord[3])
                Player.Character.HumanoidRootPart.CFrame = targetCFrame
            end
        end)
        
        -- Efek Hover Estetik
        btn.MouseEnter:Connect(function() bStr.Color = Theme.AccentPurple end)
        btn.MouseLeave:Connect(function() bStr.Color = Theme.Stroke end)
        
        indexOrder = indexOrder + 1
    end
    
    -- Jika map masih kosong belum ada landmark
    if indexOrder == 1 then
        local emptyTxt = Instance.new("TextButton", areaTpCard) -- Menggunakan TextButton tipis sebagai teks info biar serasi layoutorder
        emptyTxt.Size = UDim2.new(1, 0, 0, 20)
        emptyTxt.BackgroundTransparency = 1
        emptyTxt.Font = Enum.Font.GothamMedium
        emptyTxt.Text = "Belum ada landmark tersimpan."
        emptyTxt.TextColor3 = Theme.TextMuted
        emptyTxt.TextSize = 10
        emptyTxt.LayoutOrder = 1
    end
end

-- Logika Eksekusi ketika tombol "Simpan Posisi" diklik
btnSavePos.MouseButton1Click:Connect(function()
    local name = wpNameInput.Text
    if name ~= "" and name ~= "Nama waypoint baru..." then
        if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
            local currentPos = Player.Character.HumanoidRootPart.Position
            
            -- Simpan posisi dalam format Array biasa {X, Y, Z} agar bisa disimpan ke format JSON teks file
            AllWaypoints[CurrentPlaceId][name] = {
                math.round(currentPos.X * 100) / 100,
                math.round(currentPos.Y * 100) / 100,
                math.round(currentPos.Z * 100) / 100
            }
            
            -- Tulis permanen ke storage komputer/HP
            saveWaypointsToStorage()
            
            -- Reset kolom input teks dan gambar ulang list di sebelah kanan
            wpNameInput.Text = ""
            refreshLandmarksUI()
        end
    end
end)

-- Pertama kali buka tab langsung render list landmark yang tersimpan di map tersebut
refreshLandmarksUI()

-- ====================================================================
-- ANIMATION SYSTEM INTRO & DEPLOY
-- ====================================================================
task.spawn(function()
    local statusMessages = {
        {time = 0.5, msg = "Memeriksa lisensi skrip..."},
        {time = 1.2, msg = "Memuat modul UI List & Grid..."},
        {time = 2.0, msg = "Menyelaraskan konfigurasi framework..."},
        {time = 2.7, msg = "Sukses terhubung! Membuka panel..."}
    }

    for i = 1, 100 do
        local progress = i / 100
        TweenService:Create(LoadFill, TweenInfo.new(0.03, Enum.EasingStyle.Linear), {Size = UDim2.new(progress, 0, 1, 0)}):Play()
        LoadProgressText.Text = tostring(i) .. "%"
        
        for _, stage in ipairs(statusMessages) do
            if i == math.round(stage.time * 30) then 
                LoadStatus.Text = stage.msg
            end
        end
        task.wait(0.03) 
    end
    
    LoadStatus.Text = "Selesai!"
    task.wait(0.4)
    
    local fadeTween = TweenService:Create(LoadingFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 1})
    TweenService:Create(LoadTitle, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
    TweenService:Create(LoadStatus, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
    TweenService:Create(LoadProgressText, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
    TweenService:Create(LoadTrack, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
    TweenService:Create(LoadFill, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
    TweenService:Create(loadStroke, TweenInfo.new(0.3), {Transparency = 1}):Play()
    TweenService:Create(ltStroke, TweenInfo.new(0.3), {Transparency = 1}):Play()
    
    fadeTween:Play()
    fadeTween.Completed:Connect(function()
        LoadingFrame:Destroy() 
        
        MainFrame.Visible = true
        ToggleButton.Visible = true
        
        MainFrame.Size = UDim2.new(0, 520, 0, 300)
        TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 560, 0, 340)}):Play()
        
        print("[AR FRAMEWORK v6.2]: Loaded and deployed successfully without any crash!")
    end)
end)
