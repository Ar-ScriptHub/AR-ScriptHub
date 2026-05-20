-- ====================================================================
-- AR SCRIPT HUB - STRICT AUTO-SIZING & ANTI-BOX LEAKING FRAMEWORK
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

-- DRAGGABLE ENGINE (Sistem Geser Menu Utama)
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

-- FLOATING TOGGLE BUTTON (Tombol Pemicu Kecil Layar)
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
MainFrame.Size = UDim2.new(0, 560, 0, 320)
MainFrame.Position = UDim2.new(0.5, -280, 0.5, -160)
MainFrame.BackgroundColor3 = Theme.Bg
MainFrame.BackgroundTransparency = Theme.BgTrans
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)
local mainStroke = Instance.new("UIStroke", MainFrame)
mainStroke.Color = Theme.Stroke
mainStroke.Thickness = 1.5

-- HEADER BLOCK
local Header = Instance.new("Frame", MainFrame)
Header.Size = UDim2.new(1, 0, 0, 40)
Header.BackgroundTransparency = 1

local Title = Instance.new("TextLabel", Header)
Title.Text = "✨ AR UI PANEL <font color='#c092ff'>v5.6</font>"
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

-- CANVAS UTAMA KONTEN DENGAN SCROLL
local MainContentFrame = Instance.new("ScrollingFrame", MainFrame)
MainContentFrame.Name = "MainContentFrame"
MainContentFrame.Size = UDim2.new(1, -32, 1, -105)
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
    page.Size = UDim2.new(1, 0, 0, 0)
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

-- PLACEHOLDER MAKER
local function buildPlaceholder(pageFrame, titleText)
    local card = Instance.new("Frame", pageFrame)
    card.Size = UDim2.new(1, 0, 0, 150)
    card.BackgroundColor3 = Theme.CardBg
    card.BackgroundTransparency = Theme.CardTrans
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 8)
    Instance.new("UIStroke", card).Color = Theme.Stroke
    
    local txt = Instance.new("TextLabel", card)
    txt.Size = UDim2.new(1, 0, 1, 0)
    txt.Text = "<b>" .. titleText .. " MENU FRAMEWORK</b>\n\nArea kosong siap diisi komponen kustom."
    txt.RichText = true txt.Font = Enum.Font.GothamMedium txt.TextColor3 = Theme.TextMuted txt.TextSize = 12 txt.BackgroundTransparency = 1 txt.TextYAlignment = Enum.TextYAlignment.Center
end
buildPlaceholder(espPage, "ESP")
buildPlaceholder(tpPage, "TELEPORTATION")
buildPlaceholder(serverPage, "SERVER")

-- SETTING PAGE WITH DESTROY ACTION ONLY
local setCard = Instance.new("Frame", settingPage) setCard.Size = UDim2.new(1,0,0,150) setCard.BackgroundColor3 = Theme.CardBg setCard.BackgroundTransparency = Theme.CardTrans Instance.new("UICorner", setCard).CornerRadius = UDim.new(0,8) Instance.new("UIStroke", setCard).Color = Theme.Stroke
local destBtn = Instance.new("TextButton", setCard) destBtn.Size = UDim2.new(0, 160, 0, 32) destBtn.Position = UDim2.new(0.5, -80, 0.5, -16) destBtn.BackgroundColor3 = Theme.Bg destBtn.Font = Enum.Font.GothamBold destBtn.Text = "🔴 Destroy System UI" destBtn.TextColor3 = Theme.AccentPurple destBtn.TextSize = 12 Instance.new("UICorner", destBtn).CornerRadius = UDim.new(0,5) Instance.new("UIStroke", destBtn).Color = Theme.Stroke
destBtn.MouseButton1Click:Connect(function() MainGui:Destroy() end)

-- GRID GENERATOR FOR PLAYER PAGE (KOLOM KIRI & KANAN)
local LeftColumn = Instance.new("Frame", playerPage)
LeftColumn.Name = "LeftColumn"
LeftColumn.Size = UDim2.new(0.5, -6, 0, 0)
LeftColumn.AutomaticSize = Enum.AutomaticSize.Y
LeftColumn.Position = UDim2.new(0, 0, 0, 0)
LeftColumn.BackgroundTransparency = 1

local RightColumn = Instance.new("Frame", playerPage)
RightColumn.Name = "RightColumn"
RightColumn.Size = UDim2.new(0.5, -6, 0, 0)
RightColumn.AutomaticSize = Enum.AutomaticSize.Y
RightColumn.Position = UDim2.new(0.5, 6, 0, 0)
RightColumn.BackgroundTransparency = 1

local leftLayout = Instance.new("UIListLayout", LeftColumn) leftLayout.Padding = UDim.new(0, 12) leftLayout.SortOrder = Enum.SortOrder.LayoutOrder
local rightLayout = Instance.new("UIListLayout", RightColumn) rightLayout.Padding = UDim.new(0, 12) rightLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- FUNGSI KREASI CARD ANTI BOCOR (FIXED AUTOMATICSIZE)
local function createCard(parent, titleText, order)
    local card = Instance.new("Frame", parent)
    card.Size = UDim2.new(1, 0, 0, 0)
    card.AutomaticSize = Enum.AutomaticSize.Y 
    card.BackgroundColor3 = Theme.CardBg
    card.BackgroundTransparency = Theme.CardTrans
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
    
    local container = Instance.new("Frame", card)
    container.Size = UDim2.new(1, -24, 0, 0)
    container.AutomaticSize = Enum.AutomaticSize.Y
    container.Position = UDim2.new(0, 12, 0, 32)
    container.BackgroundTransparency = 1
    
    local innerLayout = Instance.new("UIListLayout", container)
    innerLayout.Padding = UDim.new(0, 12) -- Jarak antar komponen di dalam card diperlebar sedikit
    innerLayout.SortOrder = Enum.SortOrder.LayoutOrder
    
    local pdd = Instance.new("UIPadding", container)
    pdd.PaddingBottom = UDim.new(0, 12)
    
    return container
end

-- COMPONENT PRIMITIVES (FIXED TEXTWRAPPED ANTI OUT OF BOX)
local function addToggle(parent, labelText, order)
    local holder = Instance.new("Frame", parent) 
    holder.Size = UDim2.new(1, 0, 0, 24) 
    holder.BackgroundTransparency = 1 
    holder.LayoutOrder = order
    
    local lbl = Instance.new("TextLabel", holder) 
    lbl.Text = labelText 
    lbl.Size = UDim2.new(1, -40, 1, 0) -- Berikan ruang agar tidak tumpang tindih dengan saklar
    lbl.Font = Enum.Font.GothamMedium 
    lbl.TextColor3 = Theme.TextMain 
    lbl.TextSize = 12 
    lbl.TextXAlignment = Enum.TextXAlignment.Left 
    lbl.BackgroundTransparency = 1
    lbl.TextWrapped = true -- ANTI OUT OF BOX: Teks otomatis ganti baris jika terlalu panjang

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
        TweenService:Create(knob, TweenInfo.new(0.08), {Position = UDim2.new(0, active and 19 or 3, 0.5, -5), BackgroundColor3 = active and Theme.Bg or Theme.TextMuted}):Play()
        TweenService:Create(track, TweenInfo.new(0.08), {BackgroundColor3 = active and Theme.Accent or Theme.Bg}):Play()
        tStr.Color = active and Theme.Accent or Theme.Stroke
    end)
end

local function addSliderWithInput(parent, labelText, min, max, defaultVal, order)
    local holder = Instance.new("Frame", parent)
    holder.Size = UDim2.new(1, 0, 0, 36) -- Dinaikkan tinggi penampungnya agar aman dari kebocoran visual
    holder.BackgroundTransparency
