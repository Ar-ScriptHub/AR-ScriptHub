-- ====================================================================
-- ADVANCED FREECAM, SPECTATE & WAYPOINT WITH UNIVERSAL FLOATING ENGINE
-- ====================================================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local PlaceId = game.PlaceId

-- CONFIGURATION & STATE
local SystemConfig = {
    GlobalLocked = false,
    FreecamFloatVisible = false,
    SpectateFloatVisible = false,
    WaypointFloatVisible = false
}

local FreecamConfig = {
    Enabled = false,
    Speed = 1.5,
    Smoothness = 0.2,
    FreezeCharacter = true,
    Fov = 70,
    MinFov = 10,
    MaxFov = 120
}

local SpectateConfig = {
    Enabled = false,
    TargetPlayer = nil,
    Offset = Vector3.new(0, 3, 10)
}

local SavedCamPositions = {}
local JoystickInput = Vector2.new(0, 0)
local VerticalInput = 0

local cameraCFrame = Camera.CFrame
local cameraRot = Vector2.new()

local isCameraDragging = false
local cameraTouchInput = nil
local joystickTouchInput = nil
local renderConnection = nil

local SafeGui = LocalPlayer:FindFirstChildOfClass("PlayerGui") or LocalPlayer:WaitForChild("PlayerGui")
if SafeGui:FindFirstChild("Freecam_Mobile_Advanced") then
    SafeGui.Freecam_Mobile_Advanced:Destroy()
end

-- DATA SAVER
local FileName = "Freecam_Positions_Map_" .. tostring(PlaceId) .. ".json"

local function SaveDataToFile()
    if not writefile then return end
    local exportTable = {}
    for _, item in ipairs(SavedCamPositions) do
        local cf = item.CFrame
        table.insert(exportTable, { Name = item.Name, CFrame = {cf:GetComponents()} })
    end
    local success, encoded = pcall(function() return HttpService:JSONEncode(exportTable) end)
    if success then writefile(FileName, encoded) end
end

local function LoadDataFromFile()
    if not (readfile and isfile and isfile(FileName)) then return end
    local success, result = pcall(function() return HttpService:JSONDecode(readfile(FileName)) end)
    if success and type(result) == "table" then
        SavedCamPositions = {}
        for _, item in ipairs(result) do
            if item.CFrame and #item.CFrame == 12 then
                table.insert(SavedCamPositions, { Name = item.Name or "Cam Pos", CFrame = CFrame.new(unpack(item.CFrame)) })
            end
        end
    end
end
LoadDataFromFile()

-- ====================================================================
-- MAIN GUI BUILDER
-- ====================================================================
local Gui = Instance.new("ScreenGui")
Gui.Name = "Freecam_Mobile_Advanced"
Gui.ResetOnSpawn = false
Gui.Parent = SafeGui

-- HELPER: FLOATING BUTTON CREATOR
local function createFloatingButton(name, text, defaultPos)
    local btn = Instance.new("TextButton", Gui)
    btn.Name = name
    btn.Size = UDim2.new(0, 42, 0, 42)
    btn.Position = defaultPos
    btn.BackgroundColor3 = Color3.fromRGB(25, 27, 30)
    btn.Text = text
    btn.TextSize = 16
    btn.Active = true
    btn.Draggable = true
    btn.Visible = false
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)
    local stroke = Instance.new("UIStroke", btn)
    stroke.Color = Color3.fromRGB(60, 65, 70)
    stroke.Thickness = 1.5
    return btn
end

-- FLOATING BUTTONS
local MainFloatBtn = createFloatingButton("MainFloatBtn", "⚙️", UDim2.new(0.05, 0, 0.15, 0))
MainFloatBtn.Visible = true

local FlyFloatBtn = createFloatingButton("FlyFloatBtn", "📷", UDim2.new(0.05, 0, 0.23, 0))
local SpecFloatBtn = createFloatingButton("SpecFloatBtn", "👁️", UDim2.new(0.05, 0, 0.31, 0))
local WaypointFloatBtn = createFloatingButton("WaypointFloatBtn", "📍", UDim2.new(0.05, 0, 0.39, 0))

local allFloatBtns = {MainFloatBtn, FlyFloatBtn, SpecFloatBtn, WaypointFloatBtn}

-- FRAME UTAMA
local MainFrame = Instance.new("Frame", Gui)
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 250, 0, 310)
MainFrame.Position = UDim2.new(0.3, -125, 0.5, -155)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 22, 25)
MainFrame.Visible = false
MainFrame.Active = true
MainFrame.Draggable = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)
local mainStroke = Instance.new("UIStroke", MainFrame)
mainStroke.Color = Color3.fromRGB(50, 55, 60)

-- Header Frame Utama
local Header = Instance.new("Frame", MainFrame)
Header.Size = UDim2.new(1, 0, 0, 32)
Header.BackgroundTransparency = 1

local Title = Instance.new("TextLabel", Header)
Title.Text = "MAIN SYSTEM CONTROL"
Title.Size = UDim2.new(1, -70, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.Font = Enum.Font.GothamBold
Title.TextColor3 = Color3.fromRGB(240, 240, 240)
Title.TextSize = 10
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.BackgroundTransparency = 1

local LockBtn = Instance.new("TextButton", Header)
LockBtn.Size = UDim2.new(0, 26, 0, 24)
LockBtn.Position = UDim2.new(1, -58, 0, 4)
LockBtn.BackgroundColor3 = Color3.fromRGB(35, 38, 42)
LockBtn.Text = "🔓"
LockBtn.TextSize = 11
Instance.new("UICorner", LockBtn).CornerRadius = UDim.new(0, 6)

local CloseBtn = Instance.new("TextButton", Header)
CloseBtn.Size = UDim2.new(0, 26, 0, 24)
CloseBtn.Position = UDim2.new(1, -28, 0, 4)
CloseBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 11
CloseBtn.Font = Enum.Font.GothamBold
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)

local Body = Instance.new("Frame", MainFrame)
Body.Size = UDim2.new(1, -16, 1, -40)
Body.Position = UDim2.new(0, 8, 0, 34)
Body.BackgroundTransparency = 1

-- HELPER: TOGGLE FLOATING OPTION ROW
local function createFloatToggleRow(parent, labelText, topPos)
    local row = Instance.new("Frame", parent)
    row.Size = UDim2.new(1, 0, 0, 22)
    row.Position = UDim2.new(0, 0, 0, topPos)
    row.BackgroundTransparency = 1

    local lbl = Instance.new("TextLabel", row)
    lbl.Text = labelText
    lbl.Size = UDim2.new(1, -40, 1, 0)
    lbl.Font = Enum.Font.GothamMedium
    lbl.TextColor3 = Color3.fromRGB(190, 195, 200)
    lbl.TextSize = 8.5
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.BackgroundTransparency = 1

    local tgl = Instance.new("TextButton", row)
    tgl.Size = UDim2.new(0, 34, 0, 18)
    tgl.Position = UDim2.new(1, -34, 0.5, -9)
    tgl.BackgroundColor3 = Color3.fromRGB(40, 44, 48)
    tgl.Text = "OFF"
    tgl.Font = Enum.Font.GothamBold
    tgl.TextColor3 = Color3.fromRGB(150, 150, 150)
    tgl.TextSize = 7.5
    Instance.new("UICorner", tgl).CornerRadius = UDim.new(0, 4)

    return tgl
end

-- 1. FREECAM SECTION
local CamToggle = Instance.new("TextButton", Body)
CamToggle.Size = UDim2.new(1, 0, 0, 26)
CamToggle.Position = UDim2.new(0, 0, 0, 0)
CamToggle.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
CamToggle.Font = Enum.Font.GothamBold
CamToggle.Text = "FREECAM / FLY: OFF"
CamToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
CamToggle.TextSize = 9.5
Instance.new("UICorner", CamToggle).CornerRadius = UDim.new(0, 6)

local FlyFloatToggle = createFloatToggleRow(Body, "Floating Button Fly", 30)

-- 2. SPEED CONTROL
local SpeedLabel = Instance.new("TextLabel", Body)
SpeedLabel.Text = "Speed: 1.5x"
SpeedLabel.Size = UDim2.new(0, 100, 0, 20)
SpeedLabel.Position = UDim2.new(0, 0, 0, 54)
SpeedLabel.Font = Enum.Font.GothamMedium
SpeedLabel.TextColor3 = Color3.fromRGB(180, 185, 190)
SpeedLabel.TextSize = 8.5
SpeedLabel.TextXAlignment = Enum.TextXAlignment.Left
SpeedLabel.BackgroundTransparency = 1

local SpdMinus = Instance.new("TextButton", Body)
SpdMinus.Text = "-"
SpdMinus.Size = UDim2.new(0, 24, 0, 18)
SpdMinus.Position = UDim2.new(1, -52, 0, 55)
SpdMinus.BackgroundColor3 = Color3.fromRGB(35, 38, 42)
SpdMinus.TextColor3 = Color3.fromRGB(255, 255, 255)
SpdMinus.Font = Enum.Font.GothamBold
Instance.new("UICorner", SpdMinus).CornerRadius = UDim.new(0, 4)

local SpdPlus = Instance.new("TextButton", Body)
SpdPlus.Text = "+"
SpdPlus.Size = UDim2.new(0, 24, 0, 18)
SpdPlus.Position = UDim2.new(1, -24, 0, 55)
SpdPlus.BackgroundColor3 = Color3.fromRGB(35, 38, 42)
SpdPlus.TextColor3 = Color3.fromRGB(255, 255, 255)
SpdPlus.Font = Enum.Font.GothamBold
Instance.new("UICorner", SpdPlus).CornerRadius = UDim.new(0, 4)

-- 3. SPECTATE SECTION
local OpenSpectateBtn = Instance.new("TextButton", Body)
OpenSpectateBtn.Text = "👁️ OPEN SPECTATE PANEL"
OpenSpectateBtn.Size = UDim2.new(1, 0, 0, 24)
OpenSpectateBtn.Position = UDim2.new(0, 0, 0, 78)
OpenSpectateBtn.BackgroundColor3 = Color3.fromRGB(130, 60, 200)
OpenSpectateBtn.Font = Enum.Font.GothamBold
OpenSpectateBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
OpenSpectateBtn.TextSize = 8.5
Instance.new("UICorner", OpenSpectateBtn).CornerRadius = UDim.new(0, 5)

local SpecFloatToggle = createFloatToggleRow(Body, "Floating Button Spectate", 106)

-- 4. WAYPOINT SECTION
local OpenWaypointBtn = Instance.new("TextButton", Body)
OpenWaypointBtn.Text = "📍 OPEN WAYPOINT PANEL"
OpenWaypointBtn.Size = UDim2.new(1, 0, 0, 24)
OpenWaypointBtn.Position = UDim2.new(0, 0, 0, 132)
OpenWaypointBtn.BackgroundColor3 = Color3.fromRGB(0, 122, 255)
OpenWaypointBtn.Font = Enum.Font.GothamBold
OpenWaypointBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
OpenWaypointBtn.TextSize = 8.5
Instance.new("UICorner", OpenWaypointBtn).CornerRadius = UDim.new(0, 5)

local WaypointFloatToggle = createFloatToggleRow(Body, "Floating Button Waypoint", 160)

-- ====================================================================
-- SIDE PANELS (SPECTATE & WAYPOINT)
-- ====================================================================

-- 1. SPECTATE PANEL
local SpecFrame = Instance.new("Frame", Gui)
SpecFrame.Name = "SpecFrame"
SpecFrame.Size = UDim2.new(0, 210, 0, 240)
SpecFrame.Position = UDim2.new(1, 10, 0, 0)
SpecFrame.BackgroundColor3 = Color3.fromRGB(20, 22, 25)
SpecFrame.Visible = false
Instance.new("UICorner", SpecFrame).CornerRadius = UDim.new(0, 12)
local specStroke = Instance.new("UIStroke", SpecFrame)
specStroke.Color = Color3.fromRGB(130, 60, 200)

local SpecTitle = Instance.new("TextLabel", SpecFrame)
SpecTitle.Text = "SPECTATE PLAYER"
SpecTitle.Size = UDim2.new(1, -10, 0, 30)
SpecTitle.Position = UDim2.new(0, 10, 0, 0)
SpecTitle.Font = Enum.Font.GothamBold
SpecTitle.TextColor3 = Color3.fromRGB(240, 240, 240)
SpecTitle.TextSize = 9.5
SpecTitle.TextXAlignment = Enum.TextXAlignment.Left
SpecTitle.BackgroundTransparency = 1

local SpecBody = Instance.new("Frame", SpecFrame)
SpecBody.Size = UDim2.new(1, -16, 1, -38)
SpecBody.Position = UDim2.new(0, 8, 0, 32)
SpecBody.BackgroundTransparency = 1

local PlayerScroll = Instance.new("ScrollingFrame", SpecBody)
PlayerScroll.Size = UDim2.new(1, 0, 0, 125)
PlayerScroll.BackgroundColor3 = Color3.fromRGB(15, 17, 19)
PlayerScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
PlayerScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
PlayerScroll.ScrollBarThickness = 2
Instance.new("UICorner", PlayerScroll).CornerRadius = UDim.new(0, 5)

local playerListLayout = Instance.new("UIListLayout", PlayerScroll)
playerListLayout.SortOrder = Enum.SortOrder.LayoutOrder
playerListLayout.Padding = UDim.new(0, 3)

local TeleportToSpecBtn = Instance.new("TextButton", SpecBody)
TeleportToSpecBtn.Text = "📍 Teleport Ke Player"
TeleportToSpecBtn.Size = UDim2.new(1, 0, 0, 22)
TeleportToSpecBtn.Position = UDim2.new(0, 0, 0, 133)
TeleportToSpecBtn.BackgroundColor3 = Color3.fromRGB(0, 122, 255)
TeleportToSpecBtn.Font = Enum.Font.GothamBold
TeleportToSpecBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
TeleportToSpecBtn.TextSize = 8.5
Instance.new("UICorner", TeleportToSpecBtn).CornerRadius = UDim.new(0, 5)

local BackFromSpecBtn = Instance.new("TextButton", SpecBody)
BackFromSpecBtn.Text = "✕ Tutup Panel"
BackFromSpecBtn.Size = UDim2.new(1, 0, 0, 22)
BackFromSpecBtn.Position = UDim2.new(0, 0, 0, 160)
BackFromSpecBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
BackFromSpecBtn.Font = Enum.Font.GothamBold
BackFromSpecBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
BackFromSpecBtn.TextSize = 8.5
Instance.new("UICorner", BackFromSpecBtn).CornerRadius = UDim.new(0, 5)

-- 2. WAYPOINT PANEL
local WaypointFrame = Instance.new("Frame", Gui)
WaypointFrame.Name = "WaypointFrame"
WaypointFrame.Size = UDim2.new(0, 220, 0, 240)
WaypointFrame.Position = UDim2.new(1, 10, 0, 0)
WaypointFrame.BackgroundColor3 = Color3.fromRGB(20, 22, 25)
WaypointFrame.Visible = false
Instance.new("UICorner", WaypointFrame).CornerRadius = UDim.new(0, 12)
local wpStroke = Instance.new("UIStroke", WaypointFrame)
wpStroke.Color = Color3.fromRGB(0, 122, 255)

local WpTitle = Instance.new("TextLabel", WaypointFrame)
WpTitle.Text = "WAYPOINT MANAGER"
WpTitle.Size = UDim2.new(1, -10, 0, 30)
WpTitle.Position = UDim2.new(0, 10, 0, 0)
WpTitle.Font = Enum.Font.GothamBold
WpTitle.TextColor3 = Color3.fromRGB(240, 240, 240)
WpTitle.TextSize = 9.5
WpTitle.TextXAlignment = Enum.TextXAlignment.Left
WpTitle.BackgroundTransparency = 1

local WpBody = Instance.new("Frame", WaypointFrame)
WpBody.Size = UDim2.new(1, -16, 1, -38)
WpBody.Position = UDim2.new(0, 8, 0, 32)
WpBody.BackgroundTransparency = 1

local NameBox = Instance.new("TextBox", WpBody)
NameBox.PlaceholderText = "Nama Waypoint..."
NameBox.Size = UDim2.new(1, -65, 0, 22)
NameBox.Position = UDim2.new(0, 0, 0, 0)
NameBox.BackgroundColor3 = Color3.fromRGB(30, 33, 36)
NameBox.TextColor3 = Color3.fromRGB(255, 255, 255)
NameBox.PlaceholderColor3 = Color3.fromRGB(120, 125, 130)
NameBox.Font = Enum.Font.GothamMedium
NameBox.TextSize = 8.5
Instance.new("UICorner", NameBox).CornerRadius = UDim.new(0, 4)

local SaveCamBtn = Instance.new("TextButton", WpBody)
SaveCamBtn.Text = "💾 Simpan"
SaveCamBtn.Size = UDim2.new(0, 60, 0, 22)
SaveCamBtn.Position = UDim2.new(1, -60, 0, 0)
SaveCamBtn.BackgroundColor3 = Color3.fromRGB(46, 175, 105)
SaveCamBtn.Font = Enum.Font.GothamBold
SaveCamBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SaveCamBtn.TextSize = 8.5
Instance.new("UICorner", SaveCamBtn).CornerRadius = UDim.new(0, 4)

local CamScroll = Instance.new("ScrollingFrame", WpBody)
CamScroll.Size = UDim2.new(1, 0, 0, 125)
CamScroll.Position = UDim2.new(0, 0, 0, 28)
CamScroll.BackgroundTransparency = 1
CamScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
CamScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
CamScroll.ScrollBarThickness = 2

local scrollLayout = Instance.new("UIListLayout", CamScroll)
scrollLayout.SortOrder = Enum.SortOrder.LayoutOrder
scrollLayout.Padding = UDim.new(0, 3)

local CloseWpBtn = Instance.new("TextButton", WpBody)
CloseWpBtn.Text = "✕ Tutup Panel"
CloseWpBtn.Size = UDim2.new(1, 0, 0, 22)
CloseWpBtn.Position = UDim2.new(0, 0, 0, 160)
CloseWpBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
CloseWpBtn.Font = Enum.Font.GothamBold
CloseWpBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseWpBtn.TextSize = 8.5
Instance.new("UICorner", CloseWpBtn).CornerRadius = UDim.new(0, 5)

-- Auto position Side Panels menempel di kanan MainFrame
MainFrame:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
    local rightX = MainFrame.AbsolutePosition.X + MainFrame.AbsoluteSize.X + 10
    SpecFrame.Position = UDim2.new(0, rightX, 0, MainFrame.AbsolutePosition.Y)
    WaypointFrame.Position = UDim2.new(0, rightX, 0, MainFrame.AbsolutePosition.Y)
end)

-- ====================================================================
-- CONTROLS ON-SCREEN (FREECAM)
-- ====================================================================
local JoystickBase = Instance.new("Frame", Gui)
JoystickBase.Size = UDim2.new(0, 110, 0, 110)
JoystickBase.Position = UDim2.new(0.04, 0, 0.65, 0)
JoystickBase.BackgroundColor3 = Color3.fromRGB(20, 22, 25)
JoystickBase.BackgroundTransparency = 0.5
JoystickBase.Visible = false
Instance.new("UICorner", JoystickBase).CornerRadius = UDim.new(1, 0)

local JoystickKnob = Instance.new("Frame", JoystickBase)
JoystickKnob.Size = UDim2.new(0, 46, 0, 46)
JoystickKnob.Position = UDim2.new(0.5, -23, 0.5, -23)
JoystickKnob.BackgroundColor3 = Color3.fromRGB(46, 175, 105)
JoystickKnob.BackgroundTransparency = 0.2
Instance.new("UICorner", JoystickKnob).CornerRadius = UDim.new(1, 0)

local RightControls = Instance.new("Frame", Gui)
RightControls.Size = UDim2.new(0, 130, 0, 130)
RightControls.Position = UDim2.new(0.96, -130, 0.63, 0)
RightControls.BackgroundTransparency = 1
RightControls.Visible = false

local function createRightBtn(name, text, size, pos)
    local btn = Instance.new("TextButton", RightControls)
    btn.Name = name
    btn.Text = text
    btn.Size = size
    btn.Position = pos
    btn.BackgroundColor3 = Color3.fromRGB(25, 28, 32)
    btn.BackgroundTransparency = 0.3
    btn.Font = Enum.Font.GothamBold
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 9
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    return btn
end

local BtnUp = createRightBtn("BtnUp", "▲ NAIK", UDim2.new(0, 60, 0, 40), UDim2.new(0, 65, 0, 0))
local BtnDown = createRightBtn("BtnDown", "▼ TURUN", UDim2.new(0, 60, 0, 40), UDim2.new(0, 65, 0, 45))
local BtnZoomIn = createRightBtn("BtnZoomIn", "+ ZOOM", UDim2.new(0, 60, 0, 40), UDim2.new(0, 0, 0, 0))
local BtnZoomOut = createRightBtn("BtnZoomOut", "- ZOOM", UDim2.new(0, 60, 0, 40), UDim2.new(0, 0, 0, 45))

-- ====================================================================
-- SYSTEM LOCK & FLOATING MANAGER
-- ====================================================================
local function updateLockState()
    for _, btn in ipairs(allFloatBtns) do
        btn.Draggable = not SystemConfig.GlobalLocked
    end
    LockIcon.Text = SystemConfig.GlobalLocked and "🔒" or "🔓"
    LockBtn.Text = SystemConfig.GlobalLocked and "🔒" or "🔓"
end

LockBtn.MouseButton1Click:Connect(function()
    SystemConfig.GlobalLocked = not SystemConfig.GlobalLocked
    updateLockState()
end)

local function toggleFloatUI(tglBtn, targetFloat, configKey)
    SystemConfig[configKey] = not SystemConfig[configKey]
    targetFloat.Visible = SystemConfig[configKey]
    tglBtn.Text = SystemConfig[configKey] and "ON" or "OFF"
    tglBtn.BackgroundColor3 = SystemConfig[configKey] and Color3.fromRGB(46, 175, 105) or Color3.fromRGB(40, 44, 48)
    tglBtn.TextColor3 = SystemConfig[configKey] and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(150, 150, 150)
end

FlyFloatToggle.MouseButton1Click:Connect(function()
    toggleFloatUI(FlyFloatToggle, FlyFloatBtn, "FreecamFloatVisible")
end)

SpecFloatToggle.MouseButton1Click:Connect(function()
    toggleFloatUI(SpecFloatToggle, SpecFloatBtn, "SpectateFloatVisible")
end)

WaypointFloatToggle.MouseButton1Click:Connect(function()
    toggleFloatUI(WaypointFloatToggle, WaypointFloatBtn, "WaypointFloatVisible")
end)

-- Main Floating Click
MainFloatBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
    if not MainFrame.Visible then
        SpecFrame.Visible = false
        WaypointFrame.Visible = false
    end
end)

CloseBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    SpecFrame.Visible = false
    WaypointFrame.Visible = false
end)

-- ====================================================================
-- SPECTATOR & TELEPORT LOGIC
-- ====================================================================
local disableFreecam -- Forward declaration

local function getPlayerPivot(plr)
    if not plr or not plr.Character then return nil end
    local char = plr.Character
    local hrp = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Head")
    if hrp then return hrp.CFrame end
    return char:GetPivot()
end

local function stopSpectating()
    SpectateConfig.Enabled = false
    SpectateConfig.TargetPlayer = nil
    if not FreecamConfig.Enabled then
        Camera.CameraType = Enum.CameraType.Custom
    end
end

local function startSpectating(targetPlayer)
    if not targetPlayer or targetPlayer == LocalPlayer then return end
    
    if FreecamConfig.Enabled then
        disableFreecam()
    end

    SpectateConfig.TargetPlayer = targetPlayer
    SpectateConfig.Enabled = true

    Camera.CameraType = Enum.CameraType.Scriptable
end

local function refreshPlayerList()
    for _, child in pairs(PlayerScroll:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            local pBtn = Instance.new("TextButton", PlayerScroll)
            pBtn.Size = UDim2.new(1, -6, 0, 22)
            pBtn.BackgroundColor3 = (SpectateConfig.TargetPlayer == plr) and Color3.fromRGB(130, 60, 200) or Color3.fromRGB(28, 30, 34)
            pBtn.Font = Enum.Font.GothamMedium
            pBtn.Text = "  " .. plr.DisplayName .. " (@" .. plr.Name .. ")"
            pBtn.TextColor3 = Color3.fromRGB(230, 230, 230)
            pBtn.TextSize = 8.5
            pBtn.TextXAlignment = Enum.TextXAlignment.Left
            pBtn.TextTruncate = Enum.TextTruncate.AtEnd
            Instance.new("UICorner", pBtn).CornerRadius = UDim.new(0, 4)

            pBtn.MouseButton1Click:Connect(function()
                if SpectateConfig.TargetPlayer == plr then
                    stopSpectating()
                else
                    startSpectating(plr)
                end
                refreshPlayerList()
            end)
        end
    end
end

Players.PlayerAdded:Connect(refreshPlayerList)
Players.PlayerRemoving:Connect(function(plr)
    if SpectateConfig.TargetPlayer == plr then
        stopSpectating()
    end
    refreshPlayerList()
end)
refreshPlayerList()

TeleportToSpecBtn.MouseButton1Click:Connect(function()
    if SpectateConfig.TargetPlayer then
        local targetCFrame = getPlayerPivot(SpectateConfig.TargetPlayer)
        local myChar = LocalPlayer.Character
        if targetCFrame and myChar then
            local myHrp = myChar:FindFirstChild("HumanoidRootPart")
            if myHrp then
                myHrp.Anchored = false
                myHrp.CFrame = targetCFrame * CFrame.new(2, 0, 2)
            else
                myChar:PivotTo(targetCFrame * CFrame.new(2, 0, 2))
            end
        end
    end
end)

-- Open & Close Side Panels
local function openSidePanel(panel)
    SpecFrame.Visible = false
    WaypointFrame.Visible = false
    
    local rightX = MainFrame.AbsolutePosition.X + MainFrame.AbsoluteSize.X + 10
    panel.Position = UDim2.new(0, rightX, 0, MainFrame.AbsolutePosition.Y)
    panel.Visible = true
end

OpenSpectateBtn.MouseButton1Click:Connect(function()
    openSidePanel(SpecFrame)
    refreshPlayerList()
end)

SpecFloatBtn.MouseButton1Click:Connect(function()
    if SpecFrame.Visible then
        stopSpectating()
        SpecFrame.Visible = false
    else
        openSidePanel(SpecFrame)
        refreshPlayerList()
    end
end)

BackFromSpecBtn.MouseButton1Click:Connect(function()
    stopSpectating()
    SpecFrame.Visible = false
    refreshPlayerList()
end)

OpenWaypointBtn.MouseButton1Click:Connect(function()
    openSidePanel(WaypointFrame)
end)

WaypointFloatBtn.MouseButton1Click:Connect(function()
    WaypointFrame.Visible = not WaypointFrame.Visible
    if WaypointFrame.Visible then
        SpecFrame.Visible = false
    end
end)

CloseWpBtn.MouseButton1Click:Connect(function()
    WaypointFrame.Visible = false
end)

-- Loop Spectator Engine
RunService.RenderStepped:Connect(function(dt)
    if SpectateConfig.Enabled and SpectateConfig.TargetPlayer then
        local targetCFrame = getPlayerPivot(SpectateConfig.TargetPlayer)
        if targetCFrame then
            local camPos = targetCFrame * CFrame.new(SpectateConfig.Offset)
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(camPos.Position, targetCFrame.Position), 0.2)
        else
            stopSpectating()
            refreshPlayerList()
        end
    end
end)

-- ====================================================================
-- WAYPOINT MANAGER LOGIC
-- ====================================================================
local function refreshCamList()
    for _, child in pairs(CamScroll:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end
    
    for idx, data in ipairs(SavedCamPositions) do
        local card = Instance.new("Frame", CamScroll)
        card.Size = UDim2.new(1, 0, 0, 22)
        card.BackgroundColor3 = Color3.fromRGB(30, 33, 36)
        Instance.new("UICorner", card).CornerRadius = UDim.new(0, 4)

        local lbl = Instance.new("TextLabel", card)
        lbl.Text = idx .. ". " .. data.Name
        lbl.Size = UDim2.new(1, -95, 1, 0)
        lbl.Position = UDim2.new(0, 6, 0, 0)
        lbl.Font = Enum.Font.GothamMedium
        lbl.TextColor3 = Color3.fromRGB(220, 220, 220)
        lbl.TextSize = 8
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.TextTruncate = Enum.TextTruncate.AtEnd
        lbl.BackgroundTransparency = 1

        local function makeMiniBtn(text, color, pos, width)
            local btn = Instance.new("TextButton", card)
            btn.Text = text
            btn.Size = UDim2.new(0, width, 0, 14)
            btn.Position = pos
            btn.BackgroundColor3 = color
            btn.Font = Enum.Font.GothamBold
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            btn.TextSize = 8
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 3)
            return btn
        end

        local btnGo = makeMiniBtn("TP", Color3.fromRGB(46, 175, 105), UDim2.new(1, -88, 0.5, -7), 24)
        local btnUp = makeMiniBtn("▲", Color3.fromRGB(60, 65, 70), UDim2.new(1, -61, 0.5, -7), 18)
        local btnDown = makeMiniBtn("▼", Color3.fromRGB(60, 65, 70), UDim2.new(1, -40, 0.5, -7), 18)
        local btnDel = makeMiniBtn("✕", Color3.fromRGB(200, 50, 50), UDim2.new(1, -19, 0.5, -7), 16)

        -- Teleport Karakter langsung ke Waypoint
        btnGo.MouseButton1Click:Connect(function()
            local myChar = LocalPlayer.Character
            if myChar then
                local myHrp = myChar:FindFirstChild("HumanoidRootPart")
                if myHrp then
                    myHrp.Anchored = false
                    myHrp.CFrame = data.CFrame
                else
                    myChar:PivotTo(data.CFrame)
                end
            end
        end)

        btnUp.MouseButton1Click:Connect(function()
            if idx > 1 then
                SavedCamPositions[idx], SavedCamPositions[idx - 1] = SavedCamPositions[idx - 1], SavedCamPositions[idx]
                SaveDataToFile()
                refreshCamList()
            end
        end)

        btnDown.MouseButton1Click:Connect(function()
            if idx < #SavedCamPositions then
                SavedCamPositions[idx], SavedCamPositions[idx + 1] = SavedCamPositions[idx + 1], SavedCamPositions[idx]
                SaveDataToFile()
                refreshCamList()
            end
        end)

        btnDel.MouseButton1Click:Connect(function()
            table.remove(SavedCamPositions, idx)
            SaveDataToFile()
            refreshCamList()
        end)
    end
end

SaveCamBtn.MouseButton1Click:Connect(function()
    local myChar = LocalPlayer.Character
    local targetCF = Camera.CFrame
    if myChar and myChar:FindFirstChild("HumanoidRootPart") then
        targetCF = myChar.HumanoidRootPart.CFrame
    end

    local posName = NameBox.Text ~= "" and NameBox.Text or ("Waypoint " .. (#SavedCamPositions + 1))
    table.insert(SavedCamPositions, { Name = posName, CFrame = targetCF })
    NameBox.Text = ""
    SaveDataToFile()
    refreshCamList()
end)
refreshCamList()

-- ====================================================================
-- FREECAM & TOUCH ENGINE
-- ====================================================================
SpdMinus.MouseButton1Click:Connect(function()
    FreecamConfig.Speed = math.max(0.2, math.round((FreecamConfig.Speed - 0.2) * 10) / 10)
    SpeedLabel.Text = "Speed: " .. FreecamConfig.Speed .. "x"
end)
SpdPlus.MouseButton1Click:Connect(function()
    FreecamConfig.Speed = math.min(10, math.round((FreecamConfig.Speed + 0.2) * 10) / 10)
    SpeedLabel.Text = "Speed: " .. FreecamConfig.Speed .. "x"
end)

-- Joystick Engine
local draggingJoy = false
local joyCenter = Vector2.new()
local maxRadius = 40

local function resetJoystick()
    draggingJoy = false
    joystickTouchInput = nil
    JoystickKnob.Position = UDim2.new(0.5, -23, 0.5, -23)
    JoystickInput = Vector2.new(0, 0)
end

JoystickBase.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingJoy = true
        joystickTouchInput = input
        joyCenter = JoystickBase.AbsolutePosition + (JoystickBase.AbsoluteSize / 2)
    end
end)

BtnUp.MouseButton1Down:Connect(function() VerticalInput = 1 end)
BtnUp.MouseButton1Up:Connect(function() VerticalInput = 0 end)
BtnDown.MouseButton1Down:Connect(function() VerticalInput = -1 end)
BtnDown.MouseButton1Up:Connect(function() VerticalInput = 0 end)

BtnZoomIn.MouseButton1Click:Connect(function()
    FreecamConfig.Fov = math.clamp(FreecamConfig.Fov - 5, FreecamConfig.MinFov, FreecamConfig.MaxFov)
end)
BtnZoomOut.MouseButton1Click:Connect(function()
    FreecamConfig.Fov = math.clamp(FreecamConfig.Fov + 5, FreecamConfig.MinFov, FreecamConfig.MaxFov)
end)

local function isTouchInGui(pos, guiObject)
    if not guiObject or not guiObject.Visible then return false end
    local guiPos = guiObject.AbsolutePosition
    local guiSize = guiObject.AbsoluteSize
    return pos.X >= guiPos.X and pos.X <= guiPos.X + guiSize.X and pos.Y >= guiPos.Y and pos.Y <= guiPos.Y + guiSize.Y
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not FreecamConfig.Enabled then return end
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton2 then
        local pos = Vector2.new(input.Position.X, input.Position.Y)
        if gameProcessed or isTouchInGui(pos, JoystickBase) or isTouchInGui(pos, RightControls) or isTouchInGui(pos, MainFrame) or isTouchInGui(pos, SpecFrame) or isTouchInGui(pos, WaypointFrame) then
            return
        end
        for _, btn in ipairs(allFloatBtns) do
            if isTouchInGui(pos, btn) then return end
        end
        isCameraDragging = true
        cameraTouchInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if draggingJoy and input == joystickTouchInput then
        local touchPos = Vector2.new(input.Position.X, input.Position.Y)
        local delta = touchPos - joyCenter
        local distance = math.min(delta.Magnitude, maxRadius)
        local direction = delta.Magnitude > 0 and delta.Unit or Vector2.new()
        local knobPos = direction * distance
        JoystickKnob.Position = UDim2.new(0.5, knobPos.X - 23, 0.5, knobPos.Y - 23)
        JoystickInput = Vector2.new(knobPos.X / maxRadius, knobPos.Y / maxRadius)
    end

    if isCameraDragging and input == cameraTouchInput then
        local mouseDelta = UserInputService:GetMouseDelta()
        cameraRot = cameraRot - Vector2.new(math.rad(mouseDelta.X), math.rad(mouseDelta.Y))
        local maxPitch = math.rad(89)
        cameraRot = Vector2.new(cameraRot.X, math.clamp(cameraRot.Y, -maxPitch, maxPitch))
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input == joystickTouchInput then
        resetJoystick()
    elseif input == cameraTouchInput or input.UserInputType == Enum.UserInputType.MouseButton2 then
        isCameraDragging = false
        cameraTouchInput = nil
    end
end)

local function setCharacterFrozen(frozen)
    if not FreecamConfig.FreezeCharacter or not LocalPlayer.Character then return end
    local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if hrp then hrp.Anchored = frozen end
end

disableFreecam = function()
    FreecamConfig.Enabled = false
    CamToggle.Text = "FREECAM / FLY: OFF"
    CamToggle.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
    JoystickBase.Visible = false
    RightControls.Visible = false

    if renderConnection then
        renderConnection:Disconnect()
        renderConnection = nil
    end

    resetJoystick()
    VerticalInput = 0
    isCameraDragging = false
    cameraTouchInput = nil
    setCharacterFrozen(false)
    if not SpectateConfig.Enabled then
        Camera.CameraType = Enum.CameraType.Custom
    end
    Camera.FieldOfView = 70
end

local function enableFreecam()
    if SpectateConfig.Enabled then
        stopSpectating()
        refreshPlayerList()
    end

    FreecamConfig.Enabled = true
    CamToggle.Text = "FREECAM / FLY: ON"
    CamToggle.BackgroundColor3 = Color3.fromRGB(46, 175, 105)
    JoystickBase.Visible = true
    RightControls.Visible = true
    
    cameraCFrame = Camera.CFrame
    local _, yaw, pitch = cameraCFrame:ToEulerAnglesYXZ()
    cameraRot = Vector2.new(yaw, pitch)
    
    Camera.CameraType = Enum.CameraType.Scriptable
    setCharacterFrozen(true)

    renderConnection = RunService.RenderStepped:Connect(function(dt)
        if not FreecamConfig.Enabled then return end
        Camera.FieldOfView = math.clamp(Camera.FieldOfView + (FreecamConfig.Fov - Camera.FieldOfView) * 0.15, FreecamConfig.MinFov, FreecamConfig.MaxFov)
        local rotCFrame = CFrame.Angles(0, cameraRot.X, 0) * CFrame.Angles(cameraRot.Y, 0, 0)
        local moveDir = Vector3.new(JoystickInput.X, VerticalInput, JoystickInput.Y)
        local targetPosition = cameraCFrame.Position + (rotCFrame:VectorToWorldSpace(moveDir) * FreecamConfig.Speed)
        local targetCFrame = CFrame.new(targetPosition) * rotCFrame

        cameraCFrame = cameraCFrame:Lerp(targetCFrame, math.clamp(dt / FreecamConfig.Smoothness, 0, 1))
        Camera.CFrame = cameraCFrame
    end)
end

local function toggleFreecamState()
    if FreecamConfig.Enabled then
        disableFreecam()
    else
        enableFreecam()
    end
end

CamToggle.MouseButton1Click:Connect(toggleFreecamState)
FlyFloatBtn.MouseButton1Click:Connect(toggleFreecamState)
