-- ====================================================================
-- AR SCRIPT HUB - v6.8 CORE ENGINE REWORK (WITH DISCORD KEY SYSTEM)
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
    Stroke = Color3.fromRGB(45, 45, 75),     
    TextMain = Color3.fromRGB(255, 255, 255),
    TextMuted = Color3.fromRGB(160, 165, 195),
    Accent = Color3.fromRGB(0, 255, 200),    
    AccentPurple = Color3.fromRGB(130, 90, 255)
}

-- ====================================================================
-- DISCORD DYNAMIC KEY SYSTEM CONFIGURATION (LOCAL TESTING)
-- ====================================================================
local KEY_CONFIG = {
    ApiUrl = "http://192.168.1.17:3000/validate?key=", 
    GetKeyLink = "https://discord.gg/invite-server-kamu", -- Masukkan link invite Discord-mu
    Verified = false
}

-- UI Key System Container
local KeyFrame = Instance.new("Frame")
KeyFrame.Name = "KeyFrame"
KeyFrame.Parent = MainGui
KeyFrame.Size = UDim2.new(0, 320, 0, 200)
KeyFrame.Position = UDim2.new(0.5, -160, 0.5, -100)
KeyFrame.BackgroundColor3 = Theme.Bg
KeyFrame.BackgroundTransparency = 0.05
Instance.new("UICorner", KeyFrame).CornerRadius = UDim.new(0, 10)
local keyStroke = Instance.new("UIStroke", KeyFrame)
keyStroke.Color = Theme.AccentPurple
keyStroke.Thickness = 1.5

local KeyTitle = Instance.new("TextLabel", KeyFrame)
KeyTitle.Size = UDim2.new(1, 0, 0, 40)
KeyTitle.Position = UDim2.new(0, 0, 0, 15)
KeyTitle.Text = "AR SCRIPT HUB — KEY SYSTEM"
KeyTitle.Font = Enum.Font.GothamBold
KeyTitle.TextColor3 = Theme.TextMain
KeyTitle.TextSize = 14
KeyTitle.BackgroundTransparency = 1

local KeyStatus = Instance.new("TextLabel", KeyFrame)
KeyStatus.Size = UDim2.new(1, 0, 0, 20)
KeyStatus.Position = UDim2.new(0, 0, 0, 40)
KeyStatus.Text = "Silakan ambil key di Discord & masukkan ke bawah"
KeyStatus.Font = Enum.Font.GothamMedium
KeyStatus.TextColor3 = Theme.TextMuted
KeyStatus.TextSize = 11
KeyStatus.BackgroundTransparency = 1

-- Input Box Key
local KeyInputFrame = Instance.new("Frame", KeyFrame)
KeyInputFrame.Size = UDim2.new(1, -40, 0, 32)
KeyInputFrame.Position = UDim2.new(0, 20, 0, 75)
KeyInputFrame.BackgroundColor3 = Theme.CardBg
Instance.new("UICorner", KeyInputFrame).CornerRadius = UDim.new(0, 6)
local kiStroke = Instance.new("UIStroke", KeyInputFrame)
kiStroke.Color = Theme.Stroke

local KeyInput = Instance.new("TextBox", KeyInputFrame)
KeyInput.Size = UDim2.new(1, -10, 1, 0)
KeyInput.Position = UDim2.new(0, 5, 0, 0)
KeyInput.BackgroundTransparency = 1
KeyInput.Font = Enum.Font.GothamMedium
KeyInput.PlaceholderText = "Masukkan Key (AR-XXXXXX)..."
KeyInput.TextColor3 = Theme.TextMain
KeyInput.PlaceholderColor3 = Theme.TextMuted
KeyInput.TextSize = 12
KeyInput.Text = ""

-- Tombol Check Key
local BtnCheckKey = Instance.new("TextButton", KeyFrame)
BtnCheckKey.Size = UDim2.new(0, 135, 0, 32)
BtnCheckKey.Position = UDim2.new(0, 20, 0, 125)
BtnCheckKey.BackgroundColor3 = Color3.fromRGB(35, 45, 85)
BtnCheckKey.Font = Enum.Font.GothamBold
BtnCheckKey.Text = "✔ Check Key"
BtnCheckKey.TextColor3 = Theme.Accent
BtnCheckKey.TextSize = 11
Instance.new("UICorner", BtnCheckKey).CornerRadius = UDim.new(0, 6)
Instance.new("UIStroke", BtnCheckKey).Color = Theme.Stroke

-- Tombol Get Key
local BtnGetKey = Instance.new("TextButton", KeyFrame)
BtnGetKey.Size = UDim2.new(0, 135, 0, 32)
BtnGetKey.Position = UDim2.new(1, -155, 0, 125)
BtnGetKey.BackgroundColor3 = Theme.CardBg
BtnGetKey.Font = Enum.Font.GothamBold
BtnGetKey.Text = "🔑 Get Key"
BtnGetKey.TextColor3 = Theme.TextMain
BtnGetKey.TextSize = 11
Instance.new("UICorner", BtnGetKey).CornerRadius = UDim.new(0, 6)
Instance.new("UIStroke", BtnGetKey).Color = Theme.Stroke

BtnGetKey.MouseButton1Click:Connect(function()
    if setclipboard then
        setclipboard(KEY_CONFIG.GetKeyLink)
        KeyStatus.Text = "<font color='#90ff8c'>Link Discord berhasil dicopy!</font>"
        KeyStatus.RichText = true
    else
        KeyStatus.Text = "Discord: " .. KEY_CONFIG.GetKeyLink
    end
    task.spawn(function() task.wait(3) KeyStatus.Text = "Silakan ambil key di Discord & masukkan ke bawah" end)
end)

-- ====================================================================
-- STATE MANAGEMENT CONFIGURATION
-- ====================================================================
local State = {
    Fly = false, FlySpeed = 50,
    InfJump = false,
    ESP_Chams = false, ESP_Boxes = false, ESP_Names = false, ESP_Tracer = false,
    Aimbot = false, AimSmooth = 1, AimPart = "Head", TeamCheck = false,
    AutoFarm = false, AutoFarmSpeed = 50, TargetSelected = "",
    Noclip = false, SpeedHack = false, SpeedValue = 16,
    JumpHack = false, JumpValue = 50, TeleportSelected = ""
}

local NavigationTabs = {}
local ContentPanels = {}
local activeTab = nil

-- MAIN FRAME FABRICATION
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = MainGui
MainFrame.Size = UDim2.new(0, 560, 0, 340)
MainFrame.Position = UDim2.new(0.5, -280, 0.5, -170)
MainFrame.BackgroundColor3 = Theme.Bg
MainFrame.BackgroundTransparency = Theme.BgTrans
MainFrame.Visible = false -- Disembunyikan dulu untuk Key System
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)
local mfStroke = Instance.new("UIStroke", MainFrame)
mfStroke.Color = Theme.Stroke
mfStroke.Thickness = 1.2

-- LOADING CANVAS PRE-FABRICATION
local LoadingFrame = Instance.new("Frame")
LoadingFrame.Name = "LoadingFrame"
LoadingFrame.Parent = MainGui
LoadingFrame.Size = UDim2.new(0, 380, 0, 140)
LoadingFrame.Position = UDim2.new(0.5, -190, 0.5, -70)
LoadingFrame.BackgroundColor3 = Theme.Bg
LoadingFrame.BackgroundTransparency = Theme.BgTrans
LoadingFrame.Visible = false -- Disembunyikan dulu untuk Key System
Instance.new("UICorner", LoadingFrame).CornerRadius = UDim.new(0, 10)
local loadStroke = Instance.new("UIStroke", LoadingFrame)
loadStroke.Color = Theme.Stroke
loadStroke.Thickness = 1

local LoadTitle = Instance.new("TextLabel", LoadingFrame)
LoadTitle.Size = UDim2.new(1, 0, 0, 30)
LoadTitle.Position = UDim2.new(0, 0, 0, 20)
LoadTitle.Text = "AR SCRIPT HUB"
LoadTitle.Font = Enum.Font.GothamBold
LoadTitle.TextColor3 = Theme.TextMain
LoadTitle.TextSize = 18
LoadTitle.BackgroundTransparency = 1

local LoadStatus = Instance.new("TextLabel", LoadingFrame)
LoadStatus.Size = UDim2.new(1, 0, 0, 20)
LoadStatus.Position = UDim2.new(0, 0, 0, 45)
LoadStatus.Text = "Menginisialisasi sistem inti..."
LoadStatus.Font = Enum.Font.GothamMedium
LoadStatus.TextColor3 = Theme.TextMuted
LoadStatus.TextSize = 11
LoadStatus.BackgroundTransparency = 1

local LoadTrack = Instance.new("Frame", LoadingFrame)
LoadTrack.Size = UDim2.new(1, -60, 0, 6)
LoadTrack.Position = UDim2.new(0, 30, 0, 85)
LoadTrack.BackgroundColor3 = Theme.CardBg
Instance.new("UICorner", LoadTrack).CornerRadius = UDim.new(0, 3)
local ltStroke = Instance.new("UIStroke", LoadTrack)
ltStroke.Color = Theme.Stroke

local LoadFill = Instance.new("Frame", LoadTrack)
LoadFill.Size = UDim2.new(0, 0, 1, 0)
LoadFill.BackgroundColor3 = Theme.AccentPurple
Instance.new("UICorner", LoadFill).CornerRadius = UDim.new(0, 3)

local LoadProgressText = Instance.new("TextLabel", LoadingFrame)
LoadProgressText.Size = UDim2.new(1, 0, 0, 20)
LoadProgressText.Position = UDim2.new(0, 0, 0, 100)
LoadProgressText.Text = "0%"
LoadProgressText.Font = Enum.Font.GothamBold
LoadProgressText.TextColor3 = Theme.Accent
LoadProgressText.TextSize = 12
LoadProgressText.BackgroundTransparency = 1

-- SIDEBAR GENERATION
local Sidebar = Instance.new("Frame", MainFrame)
Sidebar.Size = UDim2.new(0, 150, 1, 0)
Sidebar.BackgroundColor3 = Theme.Bg
Sidebar.BackgroundTransparency = 1

local SideLine = Instance.new("Frame", MainFrame)
SideLine.Size = UDim2.new(0, 1, 1, -20)
SideLine.Position = UDim2.new(0, 150, 0, 10)
SideLine.BackgroundColor3 = Theme.Stroke
SideLine.BorderSizePixel = 0

local Title = Instance.new("TextLabel", Sidebar)
Title.Size = UDim2.new(1, 0, 0, 45)
Title.Text = "AR HUB v6.8"
Title.Font = Enum.Font.GothamBold
Title.TextColor3 = Theme.TextMain
Title.TextSize = 14
Title.BackgroundTransparency = 1

local NavScroll = Instance.new("ScrollingFrame", Sidebar)
NavScroll.Size = UDim2.new(1, 0, 1, -55)
NavScroll.Position = UDim2.new(0, 0, 0, 45)
NavScroll.BackgroundTransparency = 1
NavScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
NavScroll.ScrollBarThickness = 0
local navLayout = Instance.new("UIListLayout", NavScroll)
navLayout.Padding = UDim.new(0, 2)
navLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- CONTAINER PANELS GENERATION
local Container = Instance.new("Frame", MainFrame)
Container.Size = UDim2.new(1, -165, 1, -20)
Container.Position = UDim2.new(0, 155, 0, 10)
Container.BackgroundTransparency = 1

-- INTERFACE TOGGLE UTILITY
local ToggleButton = Instance.new("TextButton", MainGui)
ToggleButton.Size = UDim2.new(0, 50, 0, 30)
ToggleButton.Position = UDim2.new(0, 10, 0, 10)
ToggleButton.BackgroundColor3 = Theme.Bg
ToggleButton.Text = "TOGGLE"
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.TextColor3 = Theme.Accent
ToggleButton.TextSize = 10
ToggleButton.Visible = false
Instance.new("UICorner", ToggleButton).CornerRadius = UDim.new(0, 6)
local tbStroke = Instance.new("UIStroke", ToggleButton)
tbStroke.Color = Theme.Stroke

UserInputService.InputBegan:Connect(function(input, processed)
    if not processed and input.KeyCode == Enum.KeyCode.RightControl then
        MainFrame.Visible = not MainFrame.Visible
    end
end)
ToggleButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- CORE UI BUILDER ENGINE (AUTOMATED STRUCTURING)
local function CreateTab(name)
    local TabBtn = Instance.new("TextButton", NavScroll)
    TabBtn.Size = UDim2.new(0, 134, 0, 32)
    TabBtn.BackgroundColor3 = Theme.CardBg
    TabBtn.BackgroundTransparency = 1
    TabBtn.Text = name
    TabBtn.Font = Enum.Font.GothamMedium
    TabBtn.TextColor3 = Theme.TextMuted
    TabBtn.TextSize = 11
    Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 6)
    local tBtnStroke = Instance.new("UIStroke", TabBtn)
    tBtnStroke.Color = Theme.Stroke
    tBtnStroke.Transparency = 1
    
    local Panel = Instance.new("ScrollingFrame", Container)
    Panel.Size = UDim2.new(1, 0, 1, 0)
    Panel.BackgroundTransparency = 1
    Panel.Visible = false
    Panel.CanvasSize = UDim2.new(0, 0, 0, 0)
    Panel.ScrollBarThickness = 3
    Panel.ScrollBarImageColor3 = Theme.Stroke
    local pLayout = Instance.new("UIListLayout", Panel)
    pLayout.Padding = UDim.new(0, 8)
    pLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    
    TabBtn.MouseButton1Click:Connect(function()
        for _, t in pairs(NavigationTabs) do
            TweenService:Create(t.b, TweenInfo.new(0.2), {BackgroundTransparency = 1, TextColor3 = Theme.TextMuted}):Play()
            t.s.Transparency = 1
            t.p.Visible = false
        end
        TweenService:Create(TabBtn, TweenInfo.new(0.2), {BackgroundTransparency = 0, TextColor3 = Theme.Accent}):Play()
        tBtnStroke.Transparency = 0
        Panel.Visible = true
        activeTab = name
    end)
    
    NavigationTabs[name] = {b = TabBtn, p = Panel, s = tBtnStroke}
    return Panel
end

local function CreateSection(parent, title)
    local Sec = Instance.new("Frame", parent)
    Sec.Size = UDim2.new(1, -6, 0, 35)
    Sec.BackgroundColor3 = Theme.CardBg
    Instance.new("UICorner", Sec).CornerRadius = UDim.new(0, 8)
    local sStroke = Instance.new("UIStroke", Sec)
    sStroke.Color = Theme.Stroke
    
    local lbl = Instance.new("TextLabel", Sec)
    lbl.Size = UDim2.new(1, -15, 1, 0)
    lbl.Position = UDim2.new(0, 12, 0, 0)
    lbl.Text = title:upper()
    lbl.Font = Enum.Font.GothamBold
    lbl.TextColor3 = Theme.TextMain
    lbl.TextSize = 10
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.BackgroundTransparency = 1
    
    local content = Instance.new("Frame", parent)
    content.Size = UDim2.new(1, -6, 0, 0)
    content.BackgroundTransparency = 1
    local cLayout = Instance.new("UIListLayout", content)
    cLayout.Padding = UDim.new(0, 5)
    
    cLayout.AttributeChanged:Connect(function()
        content.Size = UDim2.new(1, -6, 0, cLayout.AbsoluteContentSize.Y)
        parent.CanvasSize = UDim2.new(0, 0, 0, parent.UIListLayout.AbsoluteContentSize.Y + 20)
    end)
    content.ChildAdded:Connect(function()
        task.wait()
        content.Size = UDim2.new(1, -6, 0, cLayout.AbsoluteContentSize.Y)
        parent.CanvasSize = UDim2.new(0, 0, 0, parent.UIListLayout.AbsoluteContentSize.Y + 20)
    end)
    
    return content
end

local function CreateToggle(parent, text, stateKey, callback)
    local Tgl = Instance.new("Frame", parent)
    Tgl.Size = UDim2.new(1, 0, 0, 38)
    Tgl.BackgroundColor3 = Theme.CardBg
    Tgl.BackgroundTransparency = 0.5
    Instance.new("UICorner", Tgl).CornerRadius = UDim.new(0, 6)
    Instance.new("UIStroke", Tgl).Color = Theme.Stroke
    
    local lbl = Instance.new("TextLabel", Tgl)
    lbl.Size = UDim2.new(1, -60, 1, 0)
    lbl.Position = UDim2.new(0, 12, 0, 0)
    lbl.Text = text
    lbl.Font = Enum.Font.GothamMedium
    lbl.TextColor3 = Theme.TextMuted
    lbl.TextSize = 11
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.BackgroundTransparency = 1
    
    local Switch = Instance.new("TextButton", Tgl)
    Switch.Size = UDim2.new(0, 34, 0, 18)
    Switch.Position = UDim2.new(1, -46, 0.5, -9)
    Switch.BackgroundColor3 = Color3.fromRGB(40, 42, 58)
    Switch.Text = ""
    Instance.new("UICorner", Switch).CornerRadius = UDim.new(0, 9)
    local swStroke = Instance.new("UIStroke", Switch)
    swStroke.Color = Theme.Stroke
    
    local Dot = Instance.new("Frame", Switch)
    Dot.Size = UDim2.new(0, 14, 0, 14)
    Dot.Position = UDim2.new(0, 2, 0.5, -7)
    Dot.BackgroundColor3 = Theme.TextMuted
    Instance.new("UICorner", Dot).CornerRadius = UDim.new(0, 7)
    
    local function update()
        local active = State[stateKey]
        TweenService:Create(Switch, TweenInfo.new(0.2), {BackgroundColor3 = active and Theme.AccentPurple or Color3.fromRGB(40, 42, 58)}):Play()
        TweenService:Create(Dot, TweenInfo.new(0.2), {Position = active and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7), BackgroundColor3 = active and Theme.Bg or Theme.TextMuted}):Play()
        TweenService:Create(lbl, TweenInfo.new(0.2), {TextColor3 = active and Theme.TextMain or Theme.TextMuted}):Play()
        callback(active)
    end
    
    Switch.MouseButton1Click:Connect(function()
        State[stateKey] = not State[stateKey]
        update()
    end)
end

local function CreateSlider(parent, text, min, max, default, stateKey, callback)
    local Sld = Instance.new("Frame", parent)
    Sld.Size = UDim2.new(1, 0, 0, 48)
    Sld.BackgroundColor3 = Theme.CardBg
    Sld.BackgroundTransparency = 0.5
    Instance.new("UICorner", Sld).CornerRadius = UDim.new(0, 6)
    Instance.new("UIStroke", Sld).Color = Theme.Stroke
    
    local lbl = Instance.new("TextLabel", Sld)
    lbl.Size = UDim2.new(0.5, 0, 0, 25)
    lbl.Position = UDim2.new(0, 12, 0, 2)
    lbl.Text = text
    lbl.Font = Enum.Font.GothamMedium
    lbl.TextColor3 = Theme.TextMain
    lbl.TextSize = 11
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.BackgroundTransparency = 1
    
    local valLbl = Instance.new("TextLabel", Sld)
    valLbl.Size = UDim2.new(0.5, -12, 0, 25)
    valLbl.Position = UDim2.new(0.5, 0, 0, 2)
    valLbl.Text = tostring(default)
    valLbl.Font = Enum.Font.GothamBold
    valLbl.TextColor3 = Theme.Accent
    valLbl.TextSize = 11
    valLbl.TextXAlignment = Enum.TextXAlignment.Right
    valLbl.BackgroundTransparency = 1
    
    local Bar = Instance.new("TextButton", Sld)
    Bar.Size = UDim2.new(1, -24, 0, 5)
    Bar.Position = UDim2.new(0, 12, 0, 32)
    Bar.BackgroundColor3 = Color3.fromRGB(40, 42, 58)
    Bar.Text = ""
    Instance.new("UICorner", Bar).CornerRadius = UDim.new(0, 2)
    
    local Fill = Instance.new("Frame", Bar)
    Fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    Fill.BackgroundColor3 = Theme.AccentPurple
    Instance.new("UICorner", Fill).CornerRadius = UDim.new(0, 2)
    
    local function snap(input)
        local perc = math.clamp((input.Position.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
        local val = math.floor(min + (max - min) * perc)
        Fill.Size = UDim2.new(perc, 0, 1, 0)
        valLbl.Text = tostring(val)
        State[stateKey] = val
        callback(val)
    end
    
    local sliding = false
    Bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then sliding = true snap(input) end
    end)
    Bar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then sliding = false end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if sliding and input.UserInputType == Enum.UserInputType.MouseMovement then snap(input) end
    end)
end

local function CreateDropdown(parent, text, list, stateKey, callback)
    local Drop = Instance.new("Frame", parent)
    Drop.Size = UDim2.new(1, 0, 0, 38)
    Drop.BackgroundColor3 = Theme.CardBg
    Drop.BackgroundTransparency = 0.5
    Instance.new("UICorner", Drop).CornerRadius = UDim.new(0, 6)
    local dStroke = Instance.new("UIStroke", Drop)
    dStroke.Color = Theme.Stroke
    
    local lbl = Instance.new("TextLabel", Drop)
    lbl.Size = UDim2.new(0.5, 0, 1, 0)
    lbl.Position = UDim2.new(0, 12, 0, 0)
    lbl.Text = text
    lbl.Font = Enum.Font.GothamMedium
    lbl.TextColor3 = Theme.TextMuted
    lbl.TextSize = 11
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.BackgroundTransparency = 1
    
    local Btn = Instance.new("TextButton", Drop)
    Btn.Size = UDim2.new(0.5, -12, 0, 24)
    Btn.Position = UDim2.new(0.5, 0, 0.5, -12)
    Btn.BackgroundColor3 = Color3.fromRGB(40, 42, 58)
    Btn.Text = State[stateKey] ~= "" and State[stateKey] or "Pilih..."
    Btn.Font = Enum.Font.GothamMedium
    Btn.TextColor3 = Theme.TextMain
    Btn.TextSize = 10
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 4)
    Instance.new("UIStroke", Btn).Color = Theme.Stroke
    
    local ListFrame = Instance.new("Frame", parent)
    ListFrame.Size = UDim2.new(1, 0, 0, 0)
    ListFrame.BackgroundColor3 = Theme.CardBg
    ListFrame.Visible = false
    Instance.new("UICorner", ListFrame).CornerRadius = UDim.new(0, 6)
    local lfStroke = Instance.new("UIStroke", ListFrame)
    lfStroke.Color = Theme.Stroke
    local lfLayout = Instance.new("UIListLayout", ListFrame)
    lfLayout.Padding = UDim.new(0, 2)
    
    local opened = false
    Btn.MouseButton1Click:Connect(function()
        opened = not opened
        ListFrame.Visible = opened
        ListFrame.Size = opened and UDim2.new(1, 0, 0, lfLayout.AbsoluteContentSize.Y + 4) or UDim2.new(1, 0, 0, 0)
    end)
    
    for _, item in ipairs(list) do
        local ItemBtn = Instance.new("TextButton", ListFrame)
        ItemBtn.Size = UDim2.new(1, -8, 0, 26)
        ItemBtn.BackgroundTransparency = 1
        ItemBtn.Text = item
        ItemBtn.Font = Enum.Font.GothamMedium
        ItemBtn.TextColor3 = Theme.TextMuted
        ItemBtn.TextSize = 10
        
        ItemBtn.MouseButton1Click:Connect(function()
            State[stateKey] = item
            Btn.Text = item
            opened = false
            ListFrame.Visible = false
            callback(item)
        end)
    end
end

-- ====================================================================
-- MODUL LAYOUT INTERFACE GENERATION (BALIK KE MENU ASLI KAMU)
-- ====================================================================
local CombatPanel = CreateTab("Combat Engine")
local MovementPanel = CreateTab("Movement Core")
local VisualsPanel = CreateTab("Visuals Engine")
local AutomationPanel = CreateTab("Automation Panel")
local MiscPanel = CreateTab("Miscellaneous")

local AimbotSec = CreateSection(CombatPanel, "Aimbot Mechanism")
CreateToggle(AimbotSec, "Aktifkan Aimbot Core", "Aimbot", function(v) end)
CreateSlider(AimbotSec, "Aimbot Smoothing Matrix", 1, 10, 1, "AimSmooth", function(v) end)
CreateDropdown(AimbotSec, "Target Lock Allocation", {"Head", "Torso", "HumanoidRootPart"}, "AimPart", function(v) end)
CreateToggle(AimbotSec, "Team Check Verification", "TeamCheck", function(v) end)

local FlightSec = CreateSection(MovementPanel, "Flight Matrix Vector")
local BaseWalkSec = CreateSection(MovementPanel, "Statistika Karakter")
CreateToggle(FlightSec, "Aktifkan Modul Fly Vector", "Fly", function(v) end)
CreateSlider(FlightSec, "Akselerasi Kecepatan Terbang", 10, 200, 50, "FlySpeed", function(v) end)
CreateToggle(BaseWalkSec, "Bypass Batas WalkSpeed", "SpeedHack", function(v) end)
CreateSlider(BaseWalkSec, "Amplifikasi Nilai Kecepatan", 16, 250, 16, "SpeedValue", function(v) end)
CreateToggle(BaseWalkSec, "Bypass Batas JumpPower", "JumpHack", function(v) end)
CreateSlider(BaseWalkSec, "Amplifikasi Daya Lompat", 50, 300, 50, "JumpValue", function(v) end)
CreateToggle(BaseWalkSec, "Infinite Jump Dynamics", "InfJump", function(v) end)
CreateToggle(BaseWalkSec, "Phase Noclip Collision", "Noclip", function(v) end)

local RenderSec = CreateSection(VisualsPanel, "Quantum Render Option")
CreateToggle(RenderSec, "Sensivitas Chams Visual", "ESP_Chams", function(v) end)
CreateToggle(RenderSec, "Bounding Box Frame", "ESP_Boxes", function(v) end)
CreateToggle(RenderSec, "Identifikasi Nama Objek", "ESP_Names", function(v) end)
CreateToggle(RenderSec, "Tracer Vector Link", "ESP_Tracer", function(v) end)

local MacroSec = CreateSection(AutomationPanel, "Macro Script Engine")
CreateToggle(MacroSec, "Looping Auto Farm State", "AutoFarm", function(v) end)
CreateSlider(MacroSec, "Velocity Interpolasi Farm", 10, 150, 50, "AutoFarmSpeed", function(v) end)
CreateDropdown(MacroSec, "Alokasi Target Entitas", {"Mob_Level1", "Mob_Level2", "Boss_Alpha"}, "TargetSelected", function(v) end)

local SystemSec = CreateSection(MiscPanel, "Utilitas & Jaringan")
CreateDropdown(SystemSec, "Teleportasi Koordinat Zona", {"Spawn Area", "Shop District", "PVP Arena", "Dungeon Portal"}, "TeleportSelected", function(v)
    local p = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
    if p then
        if v == "Spawn Area" then p.CFrame = CFrame.new(0, 50, 0)
        elseif v == "Shop District" then p.CFrame = CFrame.new(100, 50, 100)
        elseif v == "PVP Arena" then p.CFrame = CFrame.new(-200, 20, -50)
        elseif v == "Dungeon Portal" then p.CFrame = CFrame.new(500, 100, 500) end
    end
end)

-- DEFAULT SELECTION PRE-START
NavigationTabs["Combat Engine"].b.BackgroundTransparency = 0
NavigationTabs["Combat Engine"].b.TextColor3 = Theme.Accent
NavigationTabs["Combat Engine"].s.Transparency = 0
CombatPanel.Visible = true
activeTab = "Combat Engine"

-- ====================================================================
-- SYSTEM INTRO LOADING SEQUENCE & COUPLING RUNNER
-- ====================================================================
local function startMainScriptLoading()
    KeyFrame:Destroy() -- Hapus UI Key karena sukses
    LoadingFrame.Visible = true -- Tampilkan loading screen asli kamu
    
    task.spawn(function()
        local stages = {
            {t = 15, m = "Menyelaraskan Modul Fly..."},
            {t = 45, m = "Mengaktifkan Infinite Jump..."},
            {t = 75, m = "Menyuntikkan Chams ESP..."},
            {t = 95, m = "Menata Frame Order ke Lapisan Teratas..."}
        }
        
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
            ToggleButton.Visible = true
            MainFrame.Size = UDim2.new(0, 520, 0, 300)
            TweenService:Create(MainFrame, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 560, 0, 340)}):Play()
        end)
    end)
end

-- LOGIKA KLIK TOMBOL VERIFIKASI KEY
BtnCheckKey.MouseButton1Click:Connect(function()
    local userKey = KeyInput.Text
    if userKey == "" then
        KeyStatus.Text = "<font color='#ff5a5a'>Kolom key tidak boleh kosong!</font>"
        KeyStatus.RichText = true
        return
    end

    KeyStatus.Text = "Memverifikasi key ke bot Discord..."
    
    local success, response = pcall(function()
        return game:HttpGet(KEY_CONFIG.ApiUrl .. HttpService:UrlEncode(userKey))
    end)

    if success and response then
        if response == "VALID" then
            KeyStatus.Text = "<font color='#90ff8c'>Key Benar! Memuat Script...</font>"
            KeyStatus.RichText = true
            task.wait(1)
            startMainScriptLoading()
        elseif response == "EXPIRED" then
            KeyStatus.Text = "<font color='#ff5a5a'>Key sudah kadaluarsa (lewat 24 jam)!</font>"
            KeyStatus.RichText = true
        else
            KeyStatus.Text = "<font color='#ff5a5a'>Key Salah atau Tidak Ditemukan!</font>"
            KeyStatus.RichText = true
            -- Efek guncangan UI
            local originalPos = KeyFrame.Position
            for i = 1, 5 do
                KeyFrame.Position = originalPos + UDim2.new(0, math.random(-4, 4), 0, 0)
                task.wait(0.05)
            end
            KeyFrame.Position = originalPos
        end
    else
        KeyStatus.Text = "<font color='#ff5a5a'>Gagal terhubung! Pastikan CMD bot menyala.</font>"
        KeyStatus.RichText = true
    end
end)
