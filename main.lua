-- ====================================================================
-- AR SCRIPT HUB - FULLY AUTOMATIC SIZING & ANTI-LEAK FRAMEWORK (v5.6)
-- ====================================================================
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local SafeGuiTarget = Player:FindFirstChildOfClass("PlayerGui") or Player:WaitForChild("PlayerGui", 5)
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- Bersihkan GUI Lama jika masih menempel di memori
if SafeGuiTarget and SafeGuiTarget:FindFirstChild("AR_Script_Hub") then
    SafeGuiTarget.AR_Script_Hub:Destroy()
end

local MainGui = Instance.new("ScreenGui")
MainGui.Name = "AR_Script_Hub"
MainGui.Parent = SafeGuiTarget
MainGui.ResetOnSpawn = false
MainGui.DisplayOrder = 999999999 -- Menempatkan UI di atas semua GUI game bawaan [cite: 1]

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

-- DRAGGABLE ENGINE (Sistem Geser Menu Utama) [cite: 3]
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

-- FLOATING TOGGLE BUTTON (Tombol Pemicu Kecil Layar) [cite: 5]
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
ToggleButton.TextSize = 16 [cite: 5, 6]
Instance.new("UICorner", ToggleButton).CornerRadius = UDim.new(0, 9)
local tbStroke = Instance.new("UIStroke", ToggleButton)
tbStroke.Color = Theme.AccentPurple
makeDraggable(ToggleButton, ToggleButton)

-- MAIN PANEL [cite: 6]
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = MainGui
MainFrame.Size = UDim2.new(0, 560, 0, 420) -- Dimensi disesuaikan untuk layout grid baru [cite: 6]
MainFrame.Position = UDim2.new(0.5, -280, 0.5, -210)
MainFrame.BackgroundColor3 = Theme.Bg
MainFrame.BackgroundTransparency = Theme.BgTrans
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)
local mainStroke = Instance.new("UIStroke", MainFrame)
mainStroke.Color = Theme.Stroke
mainStroke.Thickness = 1.5

-- HEADER BLOCK [cite: 6]
local Header = Instance.new("Frame", MainFrame)
Header.Size = UDim2.new(1, 0, 0, 40)
Header.BackgroundTransparency = 1

local Title = Instance.new("TextLabel", Header)
Title.Text = "✨ AR UI PANEL <font color='#c092ff'>v5.6</font>" [cite: 6]
Title.RichText = true
Title.Size = UDim2.new(0.5, 0, 1, 0)
Title.Position = UDim2.new(0, 16, 0, 0)
Title.Font = Enum.Font.GothamBold
Title.TextColor3 = Theme.TextMain
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.BackgroundTransparency = 1

local CloseBtn = Instance.new("TextButton", Header) [cite: 6, 7]
CloseBtn.Text = "×" [cite: 7]
CloseBtn.Size = UDim2.new(0, 40, 1, 0)
CloseBtn.Position = UDim2.new(1, -40, 0, 0)
CloseBtn.Font = Enum.Font.GothamMedium
CloseBtn.TextColor3 = Theme.TextMuted
CloseBtn.TextSize = 24
CloseBtn.BackgroundTransparency = 1

makeDraggable(MainFrame, Header)
ToggleButton.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)
CloseBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false end)

-- ====================================================================
-- TOP BAR NAVIGATION MENU [cite: 7]
-- ====================================================================
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

-- CANVAS UTAMA KONTEN (Diubah ke ScrollingFrame agar mendukung penambahan Menu tak terbatas)
local MainContentFrame = Instance.new("ScrollingFrame", MainFrame)
MainContentFrame.Name = "MainContentFrame"
MainContentFrame.Size = UDim2.new(1, -32, 1, -105) [cite: 7, 8]
MainContentFrame.Position = UDim2.new(0, 16, 0, 95)
MainContentFrame.BackgroundTransparency = 1
MainContentFrame.ScrollBarThickness = 4
MainContentFrame.ScrollBarImageColor3 = Theme.Accent
MainContentFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
MainContentFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y

local menuContainers = {}

local function createMenuPage(name, isVisible)
    local page = Instance.new("Frame", MainContentFrame)
    page.Name = name .. "Page"
    page.Size = UDim2.new(1, 0, 0, 0) -- Menggunakan sistem pertumbuhan dinamis Y = 0
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
        page.Visible = (name == tabName) [cite: 8, 9]
    end
    MainContentFrame.CanvasPosition = Vector2.new(0, 0) -- Reset scroll ke atas saat ganti tab
end

local function addTopBarButton(textDisplay, tabTarget, order)
    local btn = Instance.new("TextButton", TopBarNav)
    btn.Size = UDim2.new(0, 96, 0, 26)
    btn.BackgroundColor3 = Color3.fromRGB(30, 32, 54)
    btn.Font = Enum.Font.GothamBold
    btn.Text = textDisplay
    btn.TextSize = 12 -- Dinaikkan agar visual emoji tidak pecah
    btn.TextColor3 = Theme.TextMain
    btn.LayoutOrder = order
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
    local bStroke = Instance.new("UIStroke", btn)
    bStroke.Color = Theme.Stroke
    
    btn.MouseButton1Click:Connect(function() [cite: 9, 10]
        for _, child in pairs(TopBarNav:GetChildren()) do
            if child:IsA("TextButton") then 
                child.TextColor3 = Theme.TextMain 
            end
        end
        btn.TextColor3 = Theme.Accent
        switchTab(tabTarget)
    end)
    return btn
end

local btnPlayer = addTopBarButton("👤 Player", "Player", 1)
btnPlayer.TextColor3 = Theme.Accent -- Set active secara default [cite: 10]
addTopBarButton("👁️ ESP", "ESP", 2)
addTopBarButton("🌀 Teleportation", "Teleportation", 3)
addTopBarButton("🌐 Server", "Server", 4)
addTopBarButton("⚙️ Setting", "Setting", 5)

-- ====================================================================
-- PLACEHOLDER MAKER FOR OTHER PAGES [cite: 10, 11]
-- ====================================================================
local function buildPlaceholder(pageFrame, titleText)
    local card = Instance.new("Frame", pageFrame)
    card.Size = UDim2.new(1, 0, 0, 200) -- Disesuaikan agar pas di Canvas dinamis
    card.BackgroundColor3 = Theme.CardBg
    card.BackgroundTransparency = Theme.CardTrans
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 8)
    Instance.new("UIStroke", card).Color = Theme.Stroke
    
    local txt = Instance.new("TextLabel", card)
    txt.Size = UDim2.new(1, 0, 1, 0)
    txt.Text = "<b>" .. titleText .. " MENU FRAMEWORK</b>\n\nArea kosong siap diisi komponen kustom." [cite: 11]
    txt.RichText = true txt.Font = Enum.Font.GothamMedium txt.TextColor3 = Theme.TextMuted txt.TextSize = 12 txt.BackgroundTransparency = 1 txt.TextYAlignment = Enum.TextYAlignment.Center [cite: 12]
end
buildPlaceholder(espPage, "ESP")
buildPlaceholder(tpPage, "TELEPORTATION")
buildPlaceholder(serverPage, "SERVER")

-- SETTING PAGE WITH DESTROY ACTION ONLY [cite: 12]
local setCard = Instance.new("Frame", settingPage) setCard.Size = UDim2.new(1,0,0,200) setCard.BackgroundColor3 = Theme.CardBg setCard.BackgroundTransparency = Theme.CardTrans Instance.new("UICorner", setCard).CornerRadius = UDim.new(0,8) Instance.new("UIStroke", setCard).Color = Theme.Stroke [cite: 12]
local destBtn = Instance.new("TextButton", setCard) destBtn.Size = UDim2.new(0, 160, 0, 32) destBtn.Position = UDim2.new(0.5, -80, 0.5, -16) destBtn.BackgroundColor3 = Theme.Bg destBtn.Font = Enum.Font.GothamBold destBtn.Text = "🔴 Destroy System UI" destBtn.TextColor3 = Theme.AccentPurple destBtn.TextSize = 12 Instance.new("UICorner", destBtn).CornerRadius = UDim.new(0,5) Instance.new("UIStroke", destBtn).Color = Theme.Stroke [cite: 12]
destBtn.MouseButton1Click:Connect(function() MainGui:Destroy() end)

-- ====================================================================
-- GRID GENERATOR FOR PLAYER PAGE (KOLOM KIRI & KANAN) [cite: 12, 13]
-- ====================================================================
-- Induk Layout Utama menggunakan List horizontal agar sinkronisasi AutomaticSize bekerja sempurna
local playerPageLayout = Instance.new("UIListLayout", playerPage)
playerPageLayout.FillDirection = Enum.FillDirection.Horizontal
playerPageLayout.SortOrder = Enum.SortOrder.LayoutOrder
playerPageLayout.Padding = UDim.new(0, 12)

local LeftColumn = Instance.new("Frame", playerPage)
LeftColumn.Name = "LeftColumn"
LeftColumn.Size = UDim2.new(0.5, -6, 0, 0) -- Menggunakan AutomaticSize vertikal
LeftColumn.AutomaticSize = Enum.AutomaticSize.Y
LeftColumn.BackgroundTransparency = 1
LeftColumn.LayoutOrder = 1

local RightColumn = Instance.new("Frame", playerPage)
RightColumn.Name = "RightColumn"
RightColumn.Size = UDim2.new(0.5, -6, 0, 0) -- Menggunakan AutomaticSize vertikal
RightColumn.AutomaticSize = Enum.AutomaticSize.Y
RightColumn.BackgroundTransparency = 1
RightColumn.LayoutOrder = 2

-- UI Layouts internal untuk mengatur urutan Card secara vertikal otomatis
local leftLayout = Instance.new("UIListLayout", LeftColumn) leftLayout.Padding = UDim.new(0, 12) leftLayout.SortOrder = Enum.SortOrder.LayoutOrder [cite: 13]
local rightLayout = Instance.new("UIListLayout", RightColumn) rightLayout.Padding = UDim.new(0, 12) rightLayout.SortOrder = Enum.SortOrder.LayoutOrder [cite: 13]

-- REVISI UTAMA: Fungsi createCard berbasis AutomaticSize (Anti Gunting/Leak Piksel Manual)
local function createCard(parent, titleText, order)
    local card = Instance.new("Frame", parent)
    card.Size = UDim2.new(1, 0, 0, 0) -- Mulai dari 0, membesar sesuai isi objek
    card.AutomaticSize = Enum.AutomaticSize.Y
    card.BackgroundColor3 = Theme.CardBg
    card.BackgroundTransparency = Theme.CardTrans [cite: 13, 14]
    card.LayoutOrder = order
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 8)
    Instance.new("UIStroke", card).Color = Theme.Stroke
    
    local ttl = Instance.new("TextLabel", card)
    ttl.Size = UDim2.new(1, -12, 0, 26)
    ttl.Position = UDim2.new(0, 12, 0, 4)
    ttl.Text = titleText:upper()
    ttl.Font = Enum.Font.GothamBold
    ttl.TextColor3 = Theme.AccentPurple
    ttl.TextSize = 11
    ttl.BackgroundTransparency = 1
    ttl.TextXAlignment = Enum.TextXAlignment.Left
    
    local container = Instance.new("Frame", card) [cite: 14, 15]
    container.Size = UDim2.new(1, -24, 0, 0)
    container.AutomaticSize = Enum.AutomaticSize.Y
    container.Position = UDim2.new(0, 12, 0, 32)
    container.BackgroundTransparency = 1
    
    local innerLayout = Instance.new("UIListLayout", container)
    innerLayout.Padding = UDim.new(0, 10) -- Jarak renggang ideal antar komponen
    innerLayout.SortOrder = Enum.SortOrder.LayoutOrder
    
    local padding = Instance.new("UIPadding", container)
    padding.PaddingBottom = UDim.new(0, 12) -- Ruang pengaman di dasar Card
    
    return container
end

-- ====================================================================
-- COMPONENT PRIMITIVES (DENGAN PROTEKSI TEXT WRAPPED & BOX AUTO-EXPAND)
-- ====================================================================
local function addToggle(parent, labelText, order)
    local holder = Instance.new("Frame", parent) 
    holder.Size = UDim2.new(1, 0, 0, 0) 
    holder.AutomaticSize = Enum.AutomaticSize.Y -- Mengembang otomatis jika teks terbungkus menjadi 2 baris
    holder.BackgroundTransparency = 1 
    holder.LayoutOrder = order
    
    local lbl = Instance.new("TextLabel", holder) [cite: 15, 16]
    lbl.Text = labelText 
    lbl.Size = UDim2.new(1, -40, 0, 0) -- Menyisakan ruang absolut 40px untuk tombol saklar di kanan
    lbl.AutomaticSize = Enum.AutomaticSize.Y
    lbl.Font = Enum.Font.GothamMedium 
    lbl.TextColor3 = Theme.TextMain 
    lbl.TextSize = 12 
    lbl.TextXAlignment = Enum.TextXAlignment.Left 
    lbl.BackgroundTransparency = 1
    lbl.TextWrapped = true -- Mencegah teks terpotong horizontal jika nama deskripsi terlalu panjang

    local track = Instance.new("TextButton", holder) [cite: 16]
    track.Size = UDim2.new(0, 32, 0, 16) 
    track.Position = UDim2.new(1, -32, 0, 2) -- Tetap di pojok kanan atas baris pertama teks
    track.BackgroundColor3 = Theme.Bg 
    track.Text = "" 
    Instance.new("UICorner", track).CornerRadius = UDim.new(0, 8) 
    local tStr = Instance.new("UIStroke", track) 
    tStr.Color = Theme.Stroke
    
    local knob = Instance.new("Frame", track) [cite: 16]
    knob.Size = UDim2.new(0, 10, 0, 10) 
    knob.Position = UDim2.new(0, 3, 0.5, -5) 
    knob.BackgroundColor3 = Theme.TextMuted 
    Instance.new("UICorner", knob).CornerRadius = UDim.new(0, 5)
    
    local active = false [cite: 16, 17]
    track.MouseButton1Click:Connect(function()
        active = not active
        TweenService:Create(knob, TweenInfo.new(0.08), {Position = UDim2.new(0, active and 19 or 3, 0.5, -5)}):Play()
        TweenService:Create(track, TweenInfo.new(0.08), {BackgroundColor3 = active and Theme.Accent or Theme.Bg}):Play()
        tStr.Color = active and Theme.Accent or Theme.Stroke
    end)
end

local function addSliderWithInput(parent, labelText, min, max, defaultVal, order)
    local holder = Instance.new("Frame", parent)
    holder.Size = UDim2.new(1, 0, 0, 38) -- Menaikkan tinggi default agar jarak trek horizontal aman [cite: 17, 18]
    holder.BackgroundTransparency = 1
    holder.LayoutOrder = order
    
    local lbl = Instance.new("TextLabel", holder) [cite: 18]
    lbl.Text = labelText 
    lbl.Size = UDim2.new(0.7, 0, 0, 14) 
    lbl.Font = Enum.Font.GothamMedium 
    lbl.TextColor3 = Theme.TextMain 
    lbl.TextSize = 11 
    lbl.TextXAlignment = Enum.TextXAlignment.Left 
    lbl.BackgroundTransparency = 1
    lbl.TextWrapped = true

    -- INPUT MANUAL BOX (TextBox di Sebelah Kanan Slider) [cite: 18]
    local inputBox = Instance.new("TextBox", holder)
    inputBox.Size = UDim2.new(0, 36, 0, 16)
    inputBox.Position = UDim2.new(1, -36, 0, 0)
    inputBox.BackgroundColor3 = Theme.Bg [cite: 18, 19]
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
    local startPerc = math.clamp((defaultVal - min) / (max - min), 0, 1) [cite: 19, 20]
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
    dragTrigger.Size = UDim2.new(2, 0, 2, 0) [cite: 20, 21]
    dragTrigger.Position = UDim2.new(-0.5, 0, -0.5, 0) dragTrigger.BackgroundTransparency = 1 dragTrigger.Image = ""

    local function refreshVisuals(value)
        local clampedValue = math.clamp(value, min, max)
        local perc = (clampedValue - min) / (max - min)
        fill.Size = UDim2.new(perc, 0, 1, 0)
        knob.Position = UDim2.new(perc, -5, 0.5, -5)
        inputBox.Text = tostring(clampedValue)
    end

    -- Event 1: Menggeser Slider Manual [cite: 21]
    local sliding = false [cite: 21, 22]
    dragTrigger.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then sliding = true end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then sliding = false end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local relX = input.Position.X - track.AbsolutePosition.X
            local perc = math.clamp(relX / track.AbsoluteSize.X, 0, 1) [cite: 22, 23]
            local finalVal = math.round(min + (perc * (max - min)))
            refreshVisuals(finalVal)
        end
    end)

    -- Event 2: Mengetik Angka Manual Lewat TextBox [cite: 23]
    inputBox.FocusLost:Connect(function(enterPressed)
        local num = tonumber(inputBox.Text)
        if num then
            refreshVisuals(num) [cite: 23, 24]
        else
            inputBox.Text = tostring(min)
            refreshVisuals(min)
        end
    end)
end

-- ====================================================================
-- PERAKITAN CARD PADA LAYOUT GRID PLAYER (TANPA HARDCODED PIXEL)
-- ====================================================================

-- 1. CARD FLY (Kolom Kiri - Atas)
local flyCard = createCard(LeftColumn, "Fly", 1) [cite: 24]
addToggle(flyCard, "Toggle Fly Mode", 1)
addSliderWithInput(flyCard, "Fly Speed Controller", 1, 100, 16, 2)
addToggle(flyCard, "Noclip Activator", 3)

-- 2. CARD WALKSPEED (Kolom Kiri - Bawah)
local walkCard = createCard(LeftColumn, "Walkspeed", 2) [cite: 24, 25]
addToggle(walkCard, "Toggle Speed Bypass", 1)
addSliderWithInput(walkCard, "Velocity Speed Magnitude", 16, 250, 16, 2)

-- 3. CARD JUMP (Kolom Kanan - Atas)
local jumpCard = createCard(RightColumn, "Jump", 1)
addToggle(jumpCard, "Toggle Jump Bypass", 1)
addSliderWithInput(jumpCard, "Jump Power Magnitude", 50, 500, 50, 2)
addToggle(jumpCard, "Infinite Jump Engine", 3)

print("[AR FRAMEWORK]: Script Deployed Successfully with Anti-Leak Ecosystem!")
