-- ====================================================================
-- AR SCRIPT HUB - FIXED TOP BAR LAYOUT ONLY (CLEAN VERSION)
-- ====================================================================
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local SafeGuiTarget = Player:FindFirstChildOfClass("PlayerGui") or Player:WaitForChild("PlayerGui", 5)
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- Bersihkan GUI Lama agar memori ter-reset sepenuhnya
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

-- SISTEM DRAGGABLE (Untuk menggeser menu utama)
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

-- FLOATING TOGGLE BUTTON (Tombol pemicu kecil di layar)
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
MainFrame.Size = UDim2.new(0, 520, 0, 340)
MainFrame.Position = UDim2.new(0.5, -260, 0.5, -170)
MainFrame.BackgroundColor3 = Theme.Bg
MainFrame.BackgroundTransparency = Theme.BgTrans
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)
local mainStroke = Instance.new("UIStroke", MainFrame)
mainStroke.Color = Theme.Stroke
mainStroke.Thickness = 1.5

-- HEADER (Judul Panel)
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

-- ====================================================================
-- FIXED: TOP BAR NAVIGATION MENU (Menggunakan UIListLayout Horizontal)
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
navStroke.Thickness = 1

-- Menggunakan UIListLayout agar susunan tombol berjejer ke kanan secara tepat
local NavLayout = Instance.new("UIListLayout", TopBarNav)
NavLayout.FillDirection = Enum.FillDirection.Horizontal
NavLayout.SortOrder = Enum.SortOrder.LayoutOrder
NavLayout.VerticalAlignment = Enum.VerticalAlignment.Center
NavLayout.Padding = UDim.new(0, 6)

local paddingNav = Instance.new("UIPadding", TopBarNav)
paddingNav.PaddingLeft = UDim.new(0, 8)

-- CANVAS UTAMA (Konten Menu Utama)
local MainContentFrame = Instance.new("Frame", MainFrame)
MainContentFrame.Name = "MainContentFrame"
MainContentFrame.Size = UDim2.new(1, -32, 1, -105)
MainContentFrame.Position = UDim2.new(0, 16, 0, 95)
MainContentFrame.BackgroundTransparency = 1

local WelcomeCard = Instance.new("Frame", MainContentFrame)
WelcomeCard.Size = UDim2.new(1, 0, 1, 0)
WelcomeCard.BackgroundColor3 = Theme.CardBg
WelcomeCard.BackgroundTransparency = Theme.CardTrans
Instance.new("UICorner", WelcomeCard).CornerRadius = UDim.new(0, 8)
Instance.new("UIStroke", WelcomeCard).Color = Theme.Stroke

local WelcomeText = Instance.new("TextLabel", WelcomeCard)
WelcomeText.Size = UDim2.new(1, -24, 1, -24)
WelcomeText.Position = UDim2.new(0, 12, 0, 12)
WelcomeText.Text = "<b>WELCOME TO MAIN MENU</b>\n\nStruktur tata letak Top Bar telah diperbaiki. Modul eksekusi cheat lama telah dibersihkan sepenuhnya dari sistem."
WelcomeText.RichText = true
WelcomeText.Font = Enum.Font.GothamMedium
WelcomeText.TextColor3 = Theme.TextMuted
WelcomeText.TextSize = 12
WelcomeText.TextWrapped = true
WelcomeText.BackgroundTransparency = 1
WelcomeText.TextYAlignment = Enum.TextYAlignment.Center

-- Fungsi Otomatisasi Tombol Menu Atas
local function addTopBarButton(textDisplay, isAction, order)
    local btn = Instance.new("TextButton", TopBarNav)
    btn.Size = UDim2.new(0, 100, 0, 24)
    btn.BackgroundColor3 = isAction and Theme.Bg or Color3.fromRGB(30, 32, 54)
    btn.Font = Enum.Font.GothamBold
    btn.Text = textDisplay
    btn.TextSize = 11
    btn.TextColor3 = isAction and Theme.AccentPurple or Theme.TextMain
    btn.LayoutOrder = order
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
    local bStroke = Instance.new("UIStroke", btn)
    bStroke.Color = Theme.Stroke
    
    return btn
end

-- Menghasilkan struktur tombol pada baris atas
local HomeBtn = addTopBarButton("🏠 Dashboard", false, 1)
local AdminBtn = addTopBarButton("🛠️ Tools", false, 2)
local ClearBtn = addTopBarButton("🔴 Destroy UI", true, 3)

-- Membersihkan interface saat tombol ditekan
ClearBtn.MouseButton1Click:Connect(function()
    MainGui:Destroy()
end)

print("[AR FRAMEWORK]: Clean Top Bar Layout Deployed Successfully!")
