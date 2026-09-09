-- ====================================================================
-- ADVANCED FREECAM, SPECTATE, WAYPOINT & FLOATING SYSTEM
-- ====================================================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local PlaceId = game.PlaceId

-- CONFIG & STATES
local Config = {
    Freecam = { Enabled = false, Speed = 1.5, Smoothness = 0.2, Freeze = true, Fov = 70 },
    Spectate = { Enabled = false, Target = nil, Offset = Vector3.new(0, 3, 10) },
    GlobalFloatLocked = false
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
if SafeGui:FindFirstChild("Advanced_Hub_Mobile") then
    SafeGui.Advanced_Hub_Mobile:Destroy()
end

-- DATA SAVER
local FileName = "Saved_Waypoints_Map_" .. tostring(PlaceId) .. ".json"
local function SaveDataToFile()
    if not writefile then return end
    local exportTable = {}
    for _, item in ipairs(SavedCamPositions) do
        local cf = item.CFrame
        table.insert(exportTable, { Name = item.Name, CFrame = {cf:GetComponents()} })
    end
    pcall(function() writefile(FileName, HttpService:JSONEncode(exportTable)) end)
end

local function LoadDataFromFile()
    if not (readfile and isfile and isfile(FileName)) then return end
    local success, result = pcall(function() return HttpService:JSONDecode(readfile(FileName)) end)
    if success and type(result) == "table" then
        SavedCamPositions = {}
        for _, item in ipairs(result) do
            if item.CFrame and #item.CFrame == 12 then
                table.insert(SavedCamPositions, { Name = item.Name or "Pos", CFrame = CFrame.new(unpack(item.CFrame)) })
            end
        end
    end
end
LoadDataFromFile()

-- GUI CONTAINER
local Gui = Instance.new("ScreenGui", SafeGui)
Gui.Name = "Advanced_Hub_Mobile"
Gui.ResetOnSpawn = false

-- HELPER: CREATE DRAGGABLE FLOATING BTNS
local function createFloatingButton(name, text, defaultPos, color)
    local btn = Instance.new("TextButton", Gui)
    btn.Name = name
    btn.Size = UDim2.new(0, 42, 0, 42)
    btn.Position = defaultPos
    btn.BackgroundColor3 = color or Color3.fromRGB(25, 27, 30)
    btn.Text = text
    btn.TextSize = 16
    btn.Visible = false
    btn.Active = true
    btn.Draggable = true
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)
    local stroke = Instance.new("UIStroke", btn)
    stroke.Color = Color3.fromRGB(80, 85, 90)
    stroke.Thickness = 1.5
    return btn
end

-- QUICK FLOATING BUTTONS
local FloatMain = createFloatingButton("FloatMain", "⚙️", UDim2.new(0.02, 0, 0.15, 0), Color3.fromRGB(35, 38, 42))
FloatMain.Visible = true

local FloatFly = createFloatingButton("FloatFly", "🕊️", UDim2.new(0.02, 0, 0.23, 0), Color3.fromRGB(180, 50, 50))
local FloatSpec = createFloatingButton("FloatSpec", "👁️", UDim2.new(0.02, 0, 0.31, 0), Color3.fromRGB(130, 60, 200))
local FloatWp = createFloatingButton("FloatWp", "📍", UDim2.new(0.02, 0, 0.39, 0), Color3.fromRGB(0, 122, 255))

-- ====================================================================
-- MAIN FRAME
-- ====================================================================
local MainFrame = Instance.new("Frame", Gui)
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 280, 0, 360)
MainFrame.Position = UDim2.new(0.3, -140, 0.5, -180)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 22, 25)
MainFrame.Visible = false
MainFrame.Active = true
MainFrame.Draggable = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)
Instance.new("UIStroke", MainFrame).Color = Color3.fromRGB(50, 55, 60)

local Header = Instance.new("Frame", MainFrame)
Header.Size = UDim2.new(1, 0, 0, 32)
Header.BackgroundTransparency = 1

local Title = Instance.new("TextLabel", Header)
Title.Text = "MAIN MENU HUB"
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

local BodyScroll = Instance.new("ScrollingFrame", MainFrame)
BodyScroll.Size = UDim2.new(1, -16, 1, -40)
BodyScroll.Position = UDim2.new(0, 8, 0, 34)
BodyScroll.BackgroundTransparency = 1
BodyScroll.CanvasSize = UDim2.new(0, 0, 0, 450)
BodyScroll.ScrollBarThickness = 2

local layout = Instance.new("UIListLayout", BodyScroll)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Padding = UDim.new(0, 8)

-- HELPER: MENU ROW WITH FLOATING TOGGLE
local function createMenuRow(titleText, mainBtnText, mainBtnColor)
    local row = Instance.new("Frame", BodyScroll)
    row.Size = UDim2.new(1, 0, 0, 26)
    row.BackgroundTransparency = 1

    local mainBtn = Instance.new("TextButton", row)
    mainBtn.Size = UDim2.new(1, -50, 1, 0)
    mainBtn.BackgroundColor3 = mainBtnColor
    mainBtn.Font = Enum.Font.GothamBold
    mainBtn.Text = mainBtnText
    mainBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    mainBtn.TextSize = 8.5
    Instance.new("UICorner", mainBtn).CornerRadius = UDim.new(0, 5)

    local floatTgl = Instance.new("TextButton", row)
    floatTgl.Size = UDim2.new(0, 45, 1, 0)
    floatTgl.Position = UDim2.new(1, -45, 0, 0)
    floatTgl.BackgroundColor3 = Color3.fromRGB(40, 44, 50)
    floatTgl.Font = Enum.Font.GothamBold
    floatTgl.Text = "📌 OFF"
    floatTgl.TextColor3 = Color3.fromRGB(150, 150, 150)
    floatTgl.TextSize = 8
    Instance.new("UICorner", floatTgl).CornerRadius = UDim.new(0, 5)

    return mainBtn, floatTgl
end

-- MENU ITEMS
local FreecamBtn, FloatFlyTgl = createMenuRow("Freecam", "FREECAM / FLY: OFF", Color3.fromRGB(180, 50, 50))
local SpecMenuBtn, FloatSpecTgl = createMenuRow("Spectate", "👁️ OPEN SPECTATE PANEL", Color3.fromRGB(130, 60, 200))
local WpMenuBtn, FloatWpTgl = createMenuRow("Waypoint", "📍 OPEN WAYPOINT PANEL", Color3.fromRGB(0, 122, 255))

-- Section Dummy untuk Auto Teleport / Server Settings bawaan
local DummyLabel = Instance.new("TextLabel", BodyScroll)
DummyLabel.Text = "── SERVER & OTHER SETTINGS ──"
DummyLabel.Size = UDim2.new(1, 0, 0, 20)
DummyLabel.Font = Enum.Font.GothamBold
DummyLabel.TextColor3 = Color3.fromRGB(120, 125, 130)
DummyLabel.TextSize = 8
DummyLabel.BackgroundTransparency = 1

local TeleportServerBtn = Instance.new("TextButton", BodyScroll)
TeleportServerBtn.Text = "🌀 Rejoin / Server Hop"
TeleportServerBtn.Size = UDim2.new(1, 0, 0, 26)
TeleportServerBtn.BackgroundColor3 = Color3.fromRGB(45, 50, 58)
TeleportServerBtn.Font = Enum.Font.GothamBold
TeleportServerBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
TeleportServerBtn.TextSize = 8.5
Instance.new("UICorner", TeleportServerBtn).CornerRadius = UDim.new(0, 5)

-- ====================================================================
-- SIDE PANELS (SPECTATE & WAYPOINT)
-- ====================================================================
local function createSidePanel(name, title)
    local frame = Instance.new("Frame", Gui)
    frame.Name = name
    frame.Size = UDim2.new(0, 200, 0, 240)
    frame.Position = UDim2.new(0.5, 150, 0.5, -120)
    frame.BackgroundColor3 = Color3.fromRGB(20, 22, 25)
    frame.Visible = false
    frame.Active = true
    frame.Draggable = true
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)
    Instance.new("UIStroke", frame).Color = Color3.fromRGB(60, 65, 72)

    local lbl = Instance.new("TextLabel", frame)
    lbl.Text = title
    lbl.Size = UDim2.new(1, -10, 0, 28)
    lbl.Position = UDim2.new(0, 10, 0, 0)
    lbl.Font = Enum.Font.GothamBold
    lbl.TextColor3 = Color3.fromRGB(240, 240, 240)
    lbl.TextSize = 9.5
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.BackgroundTransparency = 1

    local scroll = Instance.new("ScrollingFrame", frame)
    scroll.Size = UDim2.new(1, -12, 1, -65)
    scroll.Position = UDim2.new(0, 6, 0, 30)
    scroll.BackgroundColor3 = Color3.fromRGB(15, 17, 19)
    scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scroll.ScrollBarThickness = 2
    Instance.new("UICorner", scroll).CornerRadius = UDim.new(0, 5)

    local scrollLayout = Instance.new("UIListLayout", scroll)
    scrollLayout.SortOrder = Enum.SortOrder.LayoutOrder
    scrollLayout.Padding = UDim.new(0, 3)

    return frame, scroll
end

local SpecPanel, SpecScroll = createSidePanel("SpecPanel", "SPECTATE PLAYER")
local WpPanel, WpScroll = createSidePanel("WpPanel", "WAYPOINT LOCATIONS")

-- SPECTATE ACTION BUTTONS
local SpecTpBtn = Instance.new("TextButton", SpecPanel)
SpecTpBtn.Text = "📍 Teleport Ke Player"
SpecTpBtn.Size = UDim2.new(1, -12, 0, 22)
SpecTpBtn.Position = UDim2.new(0, 6, 1, -28)
SpecTpBtn.BackgroundColor3 = Color3.fromRGB(130, 60, 200)
SpecTpBtn.Font = Enum.Font.GothamBold
SpecTpBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SpecTpBtn.TextSize = 8.5
Instance.new("UICorner", SpecTpBtn).CornerRadius = UDim.new(0, 4)

-- WAYPOINT ACTION BUTTONS
local WpSaveBox = Instance.new("TextBox", WpPanel)
WpSaveBox.PlaceholderText = "Nama Waypoint..."
WpSaveBox.Size = UDim2.new(1, -60, 0, 20)
WpSaveBox.Position = UDim2.new(0, 6, 1, -28)
WpSaveBox.BackgroundColor3 = Color3.fromRGB(30, 33, 36)
WpSaveBox.TextColor3 = Color3.fromRGB(255, 255, 255)
WpSaveBox.Font = Enum.Font.GothamMedium
WpSaveBox.TextSize = 8.5
Instance.new("UICorner", WpSaveBox).CornerRadius = UDim.new(0, 4)

local WpSaveBtn = Instance.new("TextButton", WpPanel)
WpSaveBtn.Text = "💾 Add"
WpSaveBtn.Size = UDim2.new(0, 46, 0, 20)
WpSaveBtn.Position = UDim2.new(1, -52, 1, -28)
WpSaveBtn.BackgroundColor3 = Color3.fromRGB(46, 175, 105)
WpSaveBtn.Font = Enum.Font.GothamBold
WpSaveBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
WpSaveBtn.TextSize = 8.5
Instance.new("UICorner", WpSaveBtn).CornerRadius = UDim.new(0, 4)

-- ====================================================================
-- ON-SCREEN FREECAM CONTROLS
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

local function createRightBtn(name, text, pos)
    local btn = Instance.new("TextButton", RightControls)
    btn.Name = name
    btn.Text = text
    btn.Size = UDim2.new(0, 60, 0, 40)
    btn.Position = pos
    btn.BackgroundColor3 = Color3.fromRGB(25, 28, 32)
    btn.BackgroundTransparency = 0.3
    btn.Font = Enum.Font.GothamBold
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 9
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    return btn
end

local BtnUp = createRightBtn("BtnUp", "▲ NAIK", UDim2.new(0, 65, 0, 0))
local BtnDown = createRightBtn("BtnDown", "▼ TURUN", UDim2.new(0, 65, 0, 45))

-- ====================================================================
-- LOGICS & EVENT BINDINGS
-- ====================================================================

-- Lock Floating Buttons Global
LockBtn.MouseButton1Click:Connect(function()
    Config.GlobalFloatLocked = not Config.GlobalFloatLocked
    LockBtn.Text = Config.GlobalFloatLocked and "🔒" or "🔓"
    FloatMain.Draggable = not Config.GlobalFloatLocked
    FloatFly.Draggable = not Config.GlobalFloatLocked
    FloatSpec.Draggable = not Config.GlobalFloatLocked
    FloatWp.Draggable = not Config.GlobalFloatLocked
end)

-- Toggle Floating Visibility Handlers
local function bindFloatToggle(tglBtn, floatBtn)
    tglBtn.MouseButton1Click:Connect(function()
        floatBtn.Visible = not floatBtn.Visible
        if floatBtn.Visible then
            tglBtn.Text = "📌 ON"
            tglBtn.TextColor3 = Color3.fromRGB(46, 175, 105)
        else
            tglBtn.Text = "📌 OFF"
            tglBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
        end
    end)
end

bindFloatToggle(FloatFlyTgl, FloatFly)
bindFloatToggle(FloatSpecTgl, FloatSpec)
bindFloatToggle(FloatWpTgl, FloatWp)

-- SPECTATE LOGIC
local function stopSpectating()
    Config.Spectate.Enabled = false
    Config.Spectate.Target = nil
    if not Config.Freecam.Enabled then Camera.CameraType = Enum.CameraType.Custom end
end

local function refreshSpectateList()
    for _, child in pairs(SpecScroll:GetChildren()) do if child:IsA("TextButton") then child:Destroy() end end
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            local pBtn = Instance.new("TextButton", SpecScroll)
            pBtn.Size = UDim2.new(1, -4, 0, 22)
            pBtn.BackgroundColor3 = (Config.Spectate.Target == plr) and Color3.fromRGB(130, 60, 200) or Color3.fromRGB(28, 30, 34)
            pBtn.Font = Enum.Font.GothamMedium
            pBtn.Text = " " .. plr.DisplayName
            pBtn.TextColor3 = Color3.fromRGB(230, 230, 230)
            pBtn.TextSize = 8.5
            pBtn.TextXAlignment = Enum.TextXAlignment.Left
            Instance.new("UICorner", pBtn).CornerRadius = UDim.new(0, 4)

            pBtn.MouseButton1Click:Connect(function()
                if Config.Spectate.Target == plr then stopSpectating() else
                    if Config.Freecam.Enabled then disableFreecam() end
                    Config.Spectate.Target = plr
                    Config.Spectate.Enabled = true
                    Camera.CameraType = Enum.CameraType.Scriptable
                end
                refreshSpectateList()
            end)
        end
    end
end

SpecTpBtn.MouseButton1Click:Connect(function()
    if Config.Spectate.Target and Config.Spectate.Target.Character then
        local myChar = LocalPlayer.Character
        local targetHrp = Config.Spectate.Target.Character:FindFirstChild("HumanoidRootPart")
        if myChar and targetHrp then
            myChar:PivotTo(targetHrp.CFrame * CFrame.new(2, 0, 2))
        end
    end
end)

-- WAYPOINT LOGIC
local function refreshWaypointList()
    for _, child in pairs(WpScroll:GetChildren()) do if child:IsA("Frame") then child:Destroy() end end
    for idx, data in ipairs(SavedCamPositions) do
        local card = Instance.new("Frame", WpScroll)
        card.Size = UDim2.new(1, -4, 0, 22)
        card.BackgroundColor3 = Color3.fromRGB(28, 30, 34)
        Instance.new("UICorner", card).CornerRadius = UDim.new(0, 4)

        local lbl = Instance.new("TextLabel", card)
        lbl.Text = idx .. ". " .. data.Name
        lbl.Size = UDim2.new(1, -50, 1, 0)
        lbl.Position = UDim2.new(0, 4, 0, 0)
        lbl.Font = Enum.Font.GothamMedium
        lbl.TextColor3 = Color3.fromRGB(220, 220, 220)
        lbl.TextSize = 8
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.BackgroundTransparency = 1

        local btnTp = Instance.new("TextButton", card)
        btnTp.Text = "TP"
        btnTp.Size = UDim2.new(0, 22, 0, 14)
        btnTp.Position = UDim2.new(1, -44, 0.5, -7)
        btnTp.BackgroundColor3 = Color3.fromRGB(0, 122, 255)
        btnTp.Font = Enum.Font.GothamBold
        btnTp.TextColor3 = Color3.fromRGB(255, 255, 255)
        btnTp.TextSize = 7.5
        Instance.new("UICorner", btnTp).CornerRadius = UDim.new(0, 3)

        local btnDel = Instance.new("TextButton", card)
        btnDel.Text = "✕"
        btnDel.Size = UDim2.new(0, 16, 0, 14)
        btnDel.Position = UDim2.new(1, -18, 0.5, -7)
        btnDel.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        btnDel.Font = Enum.Font.GothamBold
        btnDel.TextColor3 = Color3.fromRGB(255, 255, 255)
        btnDel.TextSize = 7.5
        Instance.new("UICorner", btnDel).CornerRadius = UDim.new(0, 3)

        btnTp.MouseButton1Click:Connect(function()
            if LocalPlayer.Character then LocalPlayer.Character:PivotTo(data.CFrame) end
        end)
        btnDel.MouseButton1Click:Connect(function()
            table.remove(SavedCamPositions, idx)
            SaveDataToFile()
            refreshWaypointList()
        end)
    end
end

WpSaveBtn.MouseButton1Click:Connect(function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local name = WpSaveBox.Text ~= "" and WpSaveBox.Text or ("Loc " .. (#SavedCamPositions + 1))
        table.insert(SavedCamPositions, { Name = name, CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame })
        WpSaveBox.Text = ""
        SaveDataToFile()
        refreshWaypointList()
    end
end)

-- FREECAM LOGIC
function disableFreecam()
    Config.Freecam.Enabled = false
    FreecamBtn.Text = "FREECAM / FLY: OFF"
    FreecamBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
    FloatFly.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
    JoystickBase.Visible = false
    RightControls.Visible = false
    if renderConnection then renderConnection:Disconnect() end
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.Anchored = false
    end
    if not Config.Spectate.Enabled then Camera.CameraType = Enum.CameraType.Custom end
end

function enableFreecam()
    if Config.Spectate.Enabled then stopSpectating() end
    Config.Freecam.Enabled = true
    FreecamBtn.Text = "FREECAM / FLY: ON"
    FreecamBtn.BackgroundColor3 = Color3.fromRGB(46, 175, 105)
    FloatFly.BackgroundColor3 = Color3.fromRGB(46, 175, 105)
    JoystickBase.Visible = true
    RightControls.Visible = true

    cameraCFrame = Camera.CFrame
    local _, yaw, pitch = cameraCFrame:ToEulerAnglesYXZ()
    cameraRot = Vector2.new(yaw, pitch)
    Camera.CameraType = Enum.CameraType.Scriptable

    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.Anchored = true
    end

    renderConnection = RunService.RenderStepped:Connect(function(dt)
        local rotCFrame = CFrame.Angles(0, cameraRot.X, 0) * CFrame.Angles(cameraRot.Y, 0, 0)
        local moveDir = Vector3.new(JoystickInput.X, VerticalInput, JoystickInput.Y)
        local targetPosition = cameraCFrame.Position + (rotCFrame:VectorToWorldSpace(moveDir) * Config.Freecam.Speed)
        cameraCFrame = cameraCFrame:Lerp(CFrame.new(targetPosition) * rotCFrame, math.clamp(dt / Config.Freecam.Smoothness, 0, 1))
        Camera.CFrame = cameraCFrame
    end)
end

-- BUTTON ACTIONS BINDING
FloatMain.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)
CloseBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false end)

FreecamBtn.MouseButton1Click:Connect(function() if Config.Freecam.Enabled then disableFreecam() else enableFreecam() end end)
FloatFly.MouseButton1Click:Connect(function() if Config.Freecam.Enabled then disableFreecam() else enableFreecam() end end)

SpecMenuBtn.MouseButton1Click:Connect(function() SpecPanel.Visible = not SpecPanel.Visible refreshSpectateList() end)
FloatSpec.MouseButton1Click:Connect(function() SpecPanel.Visible = not SpecPanel.Visible refreshSpectateList() end)

WpMenuBtn.MouseButton1Click:Connect(function() WpPanel.Visible = not WpPanel.Visible refreshWaypointList() end)
FloatWp.MouseButton1Click:Connect(function() WpPanel.Visible = not WpPanel.Visible refreshWaypointList() end)

-- CAMERA TOUCH DRAG & JOYSTICK ENGINE
local draggingJoy = false
local joyCenter = Vector2.new()
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

UserInputService.InputChanged:Connect(function(input)
    if draggingJoy and input == joystickTouchInput then
        local delta = Vector2.new(input.Position.X, input.Position.Y) - joyCenter
        local dist = math.min(delta.Magnitude, 40)
        local dir = delta.Magnitude > 0 and delta.Unit or Vector2.new()
        JoystickKnob.Position = UDim2.new(0.5, (dir * dist).X - 23, 0.5, (dir * dist).Y - 23)
        JoystickInput = Vector2.new((dir * dist).X / 40, (dir * dist).Y / 40)
    end

    if isCameraDragging and input == cameraTouchInput then
        local delta = UserInputService:GetMouseDelta()
        cameraRot = cameraRot - Vector2.new(math.rad(delta.X), math.rad(delta.Y))
        cameraRot = Vector2.new(cameraRot.X, math.clamp(cameraRot.Y, -math.rad(89), math.rad(89)))
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input == joystickTouchInput then
        draggingJoy = false
        joystickTouchInput = nil
        JoystickKnob.Position = UDim2.new(0.5, -23, 0.5, -23)
        JoystickInput = Vector2.new(0, 0)
    elseif input == cameraTouchInput then
        isCameraDragging = false
        cameraTouchInput = nil
    end
end)

-- SPECTATE RENDER LOOP
RunService.RenderStepped:Connect(function()
    if Config.Spectate.Enabled and Config.Spectate.Target and Config.Spectate.Target.Character then
        local hrp = Config.Spectate.Target.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            local camPos = hrp.CFrame * CFrame.new(Config.Spectate.Offset)
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(camPos.Position, hrp.Position), 0.2)
        end
    end
end)

refreshWaypointList()
refreshSpectateList()
