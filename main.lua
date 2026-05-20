-- ====================================================================
-- AR SCRIPT HUB - TOPBAR EDITION (MOBILE COMFORT & RESTRUCTURED)
-- ====================================================================
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local SafeGuiTarget = Player:FindFirstChildOfClass("PlayerGui") or Player:WaitForChild("PlayerGui", 5)
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- Bersihkan GUI Lama jika ada
if SafeGuiTarget and SafeGuiTarget:FindFirstChild("AR_Script_Hub_Topbar") then
    SafeGuiTarget.AR_Script_Hub_Topbar:Destroy()
end

local MainGui = Instance.new("ScreenGui")
MainGui.Name = "AR_Script_Hub_Topbar"
MainGui.Parent = SafeGuiTarget
MainGui.ResetOnSpawn = false
MainGui.DisplayOrder = 999999999

-- PALET WARNA: BIRU & UNGU HALUS (Elegant Dark Core)
local Theme = {
    Bg = Color3.fromRGB(12, 10, 24),          -- Gelap pekat keunguan
    BgTrans = 0.15,                           -- Transparansi default awal
    TopbarBg = Color3.fromRGB(18, 16, 36),     -- Sedikit lebih terang dari bg utama
    CardBg = Color3.fromRGB(22, 20, 42),       -- Background untuk Pemisah Kategori (Section)
    Stroke = Color3.fromRGB(48, 44, 76),       -- Border ungu gelap halus
    AccentBlue = Color3.fromRGB(115, 170, 255),-- Biru muda halus
    AccentPurple = Color3.fromRGB(190, 130, 255), -- Ungu muda halus
    TextMain = Color3.fromRGB(245, 245, 255),  -- Putih terang kebiruan
    TextMuted = Color3.fromRGB(140, 145, 175)  -- Teks redup sekunder
}

-- DRAGGABLE ENGINE (Mobile & PC Friendly)
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

-- FLOATING TOGGLE BUTTON (Tombol Pembuka Menu)
local ToggleButton = Instance.new("TextButton")
ToggleButton.Name = "ToggleButton"
ToggleButton.Parent = MainGui
ToggleButton.Size = UDim2.new(0, 48, 0, 48)
ToggleButton.Position = UDim2.new(0.02, 0, 0.2, 0)
ToggleButton.BackgroundColor3 = Theme.Bg
ToggleButton.BackgroundTransparency = 0.1
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.Text = "AR"
ToggleButton.TextColor3 = Theme.AccentBlue
ToggleButton.TextSize = 16
Instance.new("UICorner", ToggleButton).CornerRadius = UDim.new(0, 12)
local tbStroke = Instance.new("UIStroke", ToggleButton)
tbStroke.Color = Theme.AccentPurple
tbStroke.Thickness = 1.5
makeDraggable(ToggleButton, ToggleButton)

-- MAIN PANEL (Frame Utama)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = MainGui
MainFrame.Size = UDim2.new(0, 520, 0, 340)
MainFrame.Position = UDim2.new(0.5, -260, 0.5, -170)
MainFrame.BackgroundColor3 = Theme.Bg
MainFrame.BackgroundTransparency = Theme.BgTrans
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 14)
local mainStroke = Instance.new("UIStroke", MainFrame)
mainStroke.Color = Theme.Stroke
mainStroke.Thickness = 1.5

-- ====================================================================
-- HEADER LAYOUT (JUDUL CENTER & CLOSE BUTTON)
-- ====================================================================
local Header = Instance.new("Frame", MainFrame)
Header.Name = "Header"
Header.Size = UDim2.new(1, 0, 0, 40)
Header.BackgroundTransparency = 1

local Title = Instance.new("TextLabel", Header)
Title.Text = "AR SCRIPT HUB v5.6"
Title.Size = UDim2.new(1, 0, 1, 0)
Title.Position = UDim2.new(0, 0, 0, 0)
Title.Font = Enum.Font.GothamBold
Title.TextColor3 = Theme.TextMain
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Center -- JUDUL FIX DI TENGAH
Title.BackgroundTransparency = 1

local CloseBtn = Instance.new("TextButton", Header)
CloseBtn.Text = "×"
CloseBtn.Size = UDim2.new(0, 40, 1, 0)
CloseBtn.Position = UDim2.new(1, -40, 0, 0)
CloseBtn.Font = Enum.Font.GothamMedium
CloseBtn.TextColor3 = Theme.TextMuted
CloseBtn.TextSize = 26
CloseBtn.BackgroundTransparency = 1
CloseBtn.ZIndex = 5

makeDraggable(MainFrame, Header)
ToggleButton.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)
CloseBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false end)

-- ====================================================================
-- NEW TOPBAR NAVIGATION SYSTEM (Scrolling Horizontal Mobile Comfort)
-- ====================================================================
local TopbarContainer = Instance.new("ScrollingFrame", MainFrame)
TopbarContainer.Name = "TopbarContainer"
TopbarContainer.Size = UDim2.new(1, -32, 0, 36)
TopbarContainer.Position = UDim2.new(0, 16, 0, 42)
TopbarContainer.BackgroundColor3 = Theme.TopbarBg
TopbarContainer.BackgroundTransparency = 0.3
TopbarContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
TopbarContainer.AutomaticCanvasSize = Enum.AutomaticSize.X
TopbarContainer.ScrollBarThickness = 0
TopbarContainer.ScrollingDirection = Enum.ScrollingDirection.X
Instance.new("UICorner", TopbarContainer).CornerRadius = UDim.new(0, 8)
local topbarStroke = Instance.new("UIStroke", TopbarContainer)
topbarStroke.Color = Theme.Stroke
topbarStroke.Thickness = 1

local TopbarLayout = Instance.new("UIListLayout", TopbarContainer)
TopbarLayout.FillDirection = Enum.FillDirection.Horizontal
TopbarLayout.SortOrder = Enum.SortOrder.LayoutOrder
TopbarLayout.VerticalAlignment = Enum.VerticalAlignment.Center
TopbarLayout.Padding = UDim.new(0, 4)

local TopbarPadding = Instance.new("UIPadding", TopbarContainer)
TopbarPadding.PaddingLeft = UDim.new(0, 6)
TopbarPadding.PaddingRight = UDim.new(0, 6)

-- ====================================================================
-- CONTENT VIEW AREA & SYSTEM PEMISAH KATEGORI (SECTION CARD)
-- ====================================================================
local ContentView = Instance.new("Frame", MainFrame)
ContentView.Name = "ContentView"
ContentView.Size = UDim2.new(1, -32, 1, -98)
ContentView.Position = UDim2.new(0, 16, 0, 84)
ContentView.BackgroundTransparency = 1

local tabs = {Player = {}, ESP = {}, Teleport = {}, Utilities = {}, Settings = {}, Server = {}}
local activeTab = "Player"

-- Fungsi membuat Section Card (Pemisah Kategori Berwarna Lembut)
local function createSectionCard(parent, titleText)
    local card = Instance.new("Frame", parent)
    card.Size = UDim2.new(1, -6, 0, 0) -- Lebar auto menyesuaikan, tinggi menyesuaikan isi
    card.AutomaticSize = Enum.AutomaticSize.Y
    card.BackgroundColor3 = Theme.CardBg
    card.BackgroundTransparency = 0.5
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 8)
    local cardStroke = Instance.new("UIStroke", card)
    cardStroke.Color = Theme.Stroke
    cardStroke.Thickness = 1
    
    local padding = Instance.new("UIPadding", card)
    padding.PaddingTop = UDim.new(0, 10)
    padding.PaddingBottom = UDim.new(0, 12)
    padding.PaddingLeft = UDim.new(0, 12)
    padding.PaddingRight = UDim.new(0, 12)
    
    local layout = Instance.new("UIListLayout", card)
    layout.Padding = UDim.new(0, 10)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    
    local label = Instance.new("TextLabel", card)
    label.Text = "🔹 " .. string.upper(titleText)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 11
    label.TextColor3 = Theme.AccentBlue
    label.Size = UDim2.new(1, 0, 0, 16)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.BackgroundTransparency = 1
    label.LayoutOrder = 0
    
    return card
end

-- Fungsi membuat container utama per tab
local function createTabContainer(name)
    local f = Instance.new("ScrollingFrame", ContentView)
    f.Name = name .. "Container"
    f.Size = UDim2.new(1, 0, 1, 0)
    f.BackgroundTransparency = 1
    f.CanvasSize = UDim2.new(0, 0, 0, 0)
    f.AutomaticCanvasSize = Enum.AutomaticSize.Y
    f.ScrollBarThickness = 2
    f.ScrollBarImageColor3 = Theme.AccentPurple
    f.Visible = (name == activeTab)
    tabs[name].Container = f
    
    local layout = Instance.new("UIListLayout", f)
    layout.Padding = UDim.new(0, 12)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
end

-- Bikin semua tab container
for tabName, _ in pairs(tabs) do
    createTabContainer(tabName)
end

-- Fungsi Switch Tab (Perpindahan Halaman)
local function switchTab(tabName)
    activeTab = tabName
    for k, v in pairs(tabs) do
        v.Container.Visible = (k == tabName)
        if v.Button then
            if k == tabName then
                v.Button.TextColor3 = Theme.AccentPurple
                v.Button.Font = Enum.Font.GothamBold
                TweenService:Create(v.Button, TweenInfo.new(0.15), {BackgroundTransparency = 0.85}):Play()
            else
                v.Button.TextColor3 = Theme.TextMuted
                v.Button.Font = Enum.Font.GothamMedium
                TweenService:Create(v.Button, TweenInfo.new(0.15), {BackgroundTransparency = 1}):Play()
            end
        end
    end
end

-- Fungsi Membuat Tombol Navigasi di Topbar (Mobile Comfort Clickable)
local function addTopbarButton(name, textDisplay, order)
    local btn = Instance.new("TextButton", TopbarContainer)
    btn.Name = name .. "TabBtn"
    btn.Size = UDim2.new(0, 90, 1, -8) -- Lebar 90px ideal & comfort untuk jari mobile
    btn.BackgroundColor3 = Theme.AccentPurple
    btn.BackgroundTransparency = (name == activeTab) and 0.85 or 1
    btn.Font = (name == activeTab) and Enum.Font.GothamBold or Enum.Font.GothamMedium
    btn.Text = textDisplay
    btn.TextSize = 11
    btn.TextColor3 = (name == activeTab) and Theme.AccentPurple or Theme.TextMuted
    btn.LayoutOrder = order
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    
    btn.MouseButton1Click:Connect(function() switchTab(name) end)
    tabs[name].Button = btn
end

-- Deploy Navigasi Topbar Baru (World Dihapus, Server Ditambahkan)
addTopbarButton("Player", "👤 Player", 1)
addTopbarButton("ESP", "👁️ ESP System", 2)
addTopbarButton("Teleport", "🌀 Teleport", 3)
addTopbarButton("Utilities", "🛠️ Utilities", 4)
addTopbarButton("Settings", "⚙️ Settings", 5)
addTopbarButton("Server", "🖥️ Server", 6)

-- ====================================================================
-- TEMPLATE CONTOH UNTUK MENU LAIN (MENAMPILKAN PEMISAH KATEGORI)
-- ====================================================================
local playerSec = createSectionCard(tabs.Player.Container, "Kategori Player Mod")
local espSec = createSectionCard(tabs.ESP.Container, "Kategori Visual ESP")
local tpSec = createSectionCard(tabs.Teleport.Container, "Kategori Teleportation")
local utilSec = createSectionCard(tabs.Utilities.Container, "Kategori Tools Utilities")

-- ====================================================================
-- ISI MENU: SETTINGS (UI CONFIGURATION KATEGORI)
-- ====================================================================
local settingsSection = createSectionCard(tabs.Settings.Container, "UI Configuration")

-- 1. KOMPONEN SLIDER TRANSPARANSI (Smooth & Mobile Comfort Drag)
local SliderFrame = Instance.new("Frame", settingsSection)
SliderFrame.Size = UDim2.new(1, 0, 0, 40)
SliderFrame.BackgroundTransparency = 1

local SliderLabel = Instance.new("TextLabel", SliderFrame)
SliderLabel.Text = "UI Transparency"
SliderLabel.Font = Enum.Font.GothamMedium
SliderLabel.TextSize = 12
SliderLabel.TextColor3 = Theme.TextMain
SliderLabel.Size = UDim2.new(0.4, 0, 1, 0)
SliderLabel.TextXAlignment = Enum.TextXAlignment.Left
SliderLabel.BackgroundTransparency = 1

local SliderTrack = Instance.new("Frame", SliderFrame)
SliderTrack.Size = UDim2.new(0.55, 0, 0, 6)
SliderTrack.Position = UDim2.new(0.45, 0, 0.5, -3)
SliderTrack.BackgroundColor3 = Theme.Stroke
SliderTrack.BorderThickness = 0
Instance.new("UICorner", SliderTrack).CornerRadius = UDim.new(0, 3)

local SliderFill = Instance.new("Frame", SliderTrack)
SliderFill.Size = UDim2.new(Theme.BgTrans, 0, 1, 0) -- Menyesuaikan nilai awal transparansi bg
SliderFill.BackgroundColor3 = Theme.AccentPurple
SliderFill.BorderThickness = 0
Instance.new("UICorner", SliderFill).CornerRadius = UDim.new(0, 3)

local SliderBtn = Instance.new("TextButton", SliderTrack)
SliderBtn.Size = UDim2.new(0, 14, 0, 14)
SliderBtn.Position = UDim2.new(Theme.BgTrans, -7, 0.5, -7)
SliderBtn.BackgroundColor3 = Theme.AccentBlue
SliderBtn.Text = ""
Instance.new("UICorner", SliderBtn).CornerRadius = UDim.new(1, 0)

-- Logika Perhitungan Slider Geser
local function updateSlider(input)
    local relativeX = input.Position.X - SliderTrack.AbsolutePosition.X
    local percentage = math.clamp(relativeX / SliderTrack.AbsoluteSize.X, 0, 1)
    
    SliderFill.Size = UDim2.new(percentage, 0, 1, 0)
    SliderBtn.Position = UDim2.new(percentage, -7, 0.5, -7)
    
    -- Manipulasi Transparansi Panel Utama berdasarkan nilai slider (0 sampai 0.95 biar gak hilang total)
    local targetTrans = math.clamp(percentage, 0, 0.95)
    MainFrame.BackgroundTransparency = targetTrans
end

local sliding = false
SliderBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        sliding = true
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        sliding = false
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        updateSlider(input)
    end
end)

-- Fungsi Helper membuat Button Standar di Section Card
local function createCardButton(parentCard, text, callback)
    local btn = Instance.new("TextButton", parentCard)
    btn.Size = UDim2.new(1, 0, 0, 34) -- Ukuran tombol ideal di genggaman mobile
    btn.BackgroundColor3 = Theme.TopbarBg
    btn.Font = Enum.Font.GothamMedium
    btn.Text = text
    btn.TextColor3 = Theme.TextMain
    btn.TextSize = 12
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    local btnStroke = Instance.new("UIStroke", btn)
    btnStroke.Color = Theme.Stroke
    
    btn.MouseButton1Click:Connect(callback)
    return btn
end

-- 2. TOMBOL RELOAD UI
createCardButton(settingsSection, "🔄 Reload UI", function()
    print("Reloading script UI...")
end)

-- 3. TOMBOL DESTROY UI
createCardButton(settingsSection, "🔴 Destroy UI", function()
    MainGui:Destroy()
end)


-- ====================================================================
-- ISI MENU: SERVER (PINDAHAN REJOIN, SERVER HOP, RESPAWN)
-- ====================================================================
local serverSection = createSectionCard(tabs.Server.Container, "Server & Connections")

createCardButton(serverSection, "⚡ Instant Rejoin Server", function()
    print("Rejoining server...")
end)

createCardButton(serverSection, "🌐 Auto Server Hop (Low Player)", function()
    print("Searching new server...")
end)

createCardButton(serverSection, "☠️ Force Respawn Character", function()
    print("Respawning character...")
end)

print("[AR SCRIPT HUB V5.6]: Layout & UI Config Settings Berhasil Di-deploy!")
