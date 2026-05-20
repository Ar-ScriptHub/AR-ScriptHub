-- ====================================================================
-- AR SCRIPT HUB - TOPBAR LAYOUT EDITION (MOBILE COMFORT)
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
    BgTrans = 0.15,                           -- Transparansi halus (Glassmorphism feel)
    TopbarBg = Color3.fromRGB(18, 16, 36),     -- Sedikit lebih terang dari bg utama
    Stroke = Color3.fromRGB(48, 44, 76),       -- Border ungu gelap halus
    AccentBlue = Color3.fromRGB(115, 170, 255),-- Biru muda halus (Informasional/Aktif)
    AccentPurple = Color3.fromRGB(190, 130, 255), -- Ungu muda halus (Premium/Highlight)
    TextMain = Color3.fromRGB(245, 245, 255),  -- Putih terang kebiruan
    TextMuted = Color3.fromRGB(140, 145, 175)  -- Teks sekunder agak redup
}

-- DRAGGABLE ENGINE (Sangat bersahabat untuk Mobile & PC)
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
ToggleButton.Size = UDim2.new(0, 48, 0, 48) -- Ukuran pas untuk jempol mobile (Comfort)
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
-- Ukuran disesuaikan agar proporsional di PC maupun Mobile Landscape
MainFrame.Size = UDim2.new(0, 520, 0, 340)
MainFrame.Position = UDim2.new(0.5, -260, 0.5, -170)
MainFrame.BackgroundColor3 = Theme.Bg
MainFrame.BackgroundTransparency = Theme.BgTrans
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 14)
local mainStroke = Instance.new("UIStroke", MainFrame)
mainStroke.Color = Theme.Stroke
mainStroke.Thickness = 1.5

-- ====================================================================
-- HEADER LAYOUT (Judul & Close Button)
-- ====================================================================
local Header = Instance.new("Frame", MainFrame)
Header.Name = "Header"
Header.Size = UDim2.new(1, 0, 0, 40)
Header.BackgroundTransparency = 1

local Title = Instance.new("TextLabel", Header)
Title.Text = "✨ AR SCRIPT HUB <font color='#c092ff'>v5.6</font> <font color='#73aaff'>[Topbar]</font>"
Title.RichText = true
Title.Size = UDim2.new(0.7, 0, 1, 0)
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
CloseBtn.TextSize = 26
CloseBtn.BackgroundTransparency = 1

makeDraggable(MainFrame, Header)
ToggleButton.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)
CloseBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false end)

-- ====================================================================
-- NEW TOPBAR NAVIGATION SYSTEM (Scrolling Horizontal untuk Mobile Comfort)
-- ====================================================================
local TopbarContainer = Instance.new("ScrollingFrame", MainFrame)
TopbarContainer.Name = "TopbarContainer"
TopbarContainer.Size = UDim2.new(1, -32, 0, 36) -- Memberikan padding kiri-kanan 16px
TopbarContainer.Position = UDim2.new(0, 16, 0, 42)
TopbarContainer.BackgroundColor3 = Theme.TopbarBg
TopbarContainer.BackgroundTransparency = 0.3
TopbarContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
TopbarContainer.AutomaticCanvasSize = Enum.AutomaticSize.X -- Auto scroll horizontal jika tab penuh di layar HP kecil
TopbarContainer.ScrollBarThickness = 0 -- Sembunyikan scrollbar agar clean, mobile swipe-able
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
TopbarPadding.PaddingLeft = UDim.new(0, 4)
TopbarPadding.PaddingRight = UDim.new(0, 4)

-- ====================================================================
-- CONTENT VIEW AREA (Tempat Konten Berada)
-- ====================================================================
local ContentView = Instance.new("Frame", MainFrame)
ContentView.Name = "ContentView"
ContentView.Size = UDim2.new(1, -32, 1, -98) -- Otomatis menyesuaikan sisa space di bawah topbar
ContentView.Position = UDim2.new(0, 16, 0, 84)
ContentView.BackgroundTransparency = 1

-- Properti Tab Data
local tabs = {Player = {}, ESP = {}, Teleport = {}, World = {}, Utilities = {}, Settings = {}}
local activeTab = "Player"

-- Fungsi membuat halaman isi (Container) per tab
local function createTabContainer(name)
    local f = Instance.new("ScrollingFrame", ContentView)
    f.Name = name .. "Container"
    f.Size = UDim2.new(1, 0, 1, 0)
    f.BackgroundTransparency = 1
    f.CanvasSize = UDim2.new(0, 0, 0, 0)
    f.AutomaticCanvasSize = Enum.AutomaticSize.Y -- Scroll vertikal otomatis jika item penuh
    f.ScrollBarThickness = 3
    f.ScrollBarImageColor3 = Theme.AccentPurple
    f.Visible = (name == activeTab)
    tabs[name].Container = f
    
    local layout = Instance.new("UIListLayout", f)
    layout.Padding = UDim.new(0, 10)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    
    -- CONTOH TEXT LABEL (Penanda Layout Sementara)
    local sampleLabel = Instance.new("TextLabel", f)
    sampleLabel.Size = UDim2.new(1, 0, 0, 50)
    sampleLabel.BackgroundTransparency = 0.7
    sampleLabel.BackgroundColor3 = Theme.TopbarBg
    sampleLabel.Font = Enum.Font.GothamMedium
    sampleLabel.Text = "✨ Contoh Konten untuk Menu: " .. name
    sampleLabel.TextColor3 = Theme.TextMain
    sampleLabel.TextSize = 12
    Instance.new("UICorner", sampleLabel).CornerRadius = UDim.new(0, 8)
    Instance.new("UIStroke", sampleLabel).Color = Theme.Stroke
end

createTabContainer("Player")
createTabContainer("ESP")
createTabContainer("Teleport")
createTabContainer("World")
createTabContainer("Utilities")
createTabContainer("Settings")

-- Fungsi Switch Tab (Perpindahan Halaman)
local function switchTab(tabName)
    activeTab = tabName
    for k, v in pairs(tabs) do
        v.Container.Visible = (k == tabName)
        if v.Button then
            if k == tabName then
                -- State Aktif (Biru/Ungu Halus Glow Effect)
                v.Button.TextColor3 = Theme.AccentPurple
                v.Button.Font = Enum.Font.GothamBold
                TweenService:Create(v.Button, TweenInfo.new(0.15), {BackgroundTransparency = 0.85}):Play()
            else
                -- State Tidak Aktif
                v.Button.TextColor3 = Theme.TextMuted
                v.Button.Font = Enum.Font.GothamMedium
                TweenService:Create(v.Button, TweenInfo.new(0.15), {BackgroundTransparency = 1}):Play()
            end
        end
    end
end

-- Fungsi Membuat Tombol Navigasi di Topbar
local function addTopbarButton(name, textDisplay, order)
    local btn = Instance.new("TextButton", TopbarContainer)
    btn.Name = name .. "TabBtn"
    btn.Size = UDim2.new(0, 85, 1, -8) -- Tinggi proporsional, lebar 85px (Nyaman di-tap di HP)
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

-- Deploy Tombol-Tombol Menu Utama
addTopbarButton("Player", "👤 Player", 1)
addTopbarButton("ESP", "👁️ ESP System", 2)
addTopbarButton("Teleport", "🌀 Teleport", 3)
addTopbarButton("World", "🌐 World", 4)
addTopbarButton("Utilities", "🛠️ Utilities", 5)
addTopbarButton("Settings", "⚙️ Settings", 6)

print("[AR SCRIPT HUB V5.6]: Layout Topbar Mobile Comfort Berhasil Di-deploy!")
