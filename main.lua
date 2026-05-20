-- ====================================================================
-- AR SCRIPT HUB - TOPBAR TWO-COLUMN EDITION (MOBILE COMFORT)
-- ====================================================================
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local SafeGuiTarget = Player:FindFirstChildOfClass("PlayerGui") or Player:WaitForChild("PlayerGui", 5)
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

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
    Bg = Color3.fromRGB(12, 10, 24),          
    BgTrans = 0.15,                           
    TopbarBg = Color3.fromRGB(18, 16, 36),     
    CardBg = Color3.fromRGB(22, 20, 42),       
    Stroke = Color3.fromRGB(48, 44, 76),       
    AccentBlue = Color3.fromRGB(115, 170, 255),
    AccentPurple = Color3.fromRGB(190, 130, 255), 
    TextMain = Color3.fromRGB(245, 245, 255),  
    TextMuted = Color3.fromRGB(140, 145, 175), 
    MinimizeColor = Color3.fromRGB(115, 170, 255), 
    CloseColor = Color3.fromRGB(255, 105, 105)     
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

-- FLOATING TOGGLE BUTTON
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

-- MAIN PANEL
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = MainGui
MainFrame.Size = UDim2.new(0, 540, 0, 360) -- Sedikit dilebarkan agar Two-Column makin lega
MainFrame.Position = UDim2.new(0.5, -270, 0.5, -180)
MainFrame.BackgroundColor3 = Theme.Bg
MainFrame.BackgroundTransparency = Theme.BgTrans
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 14)
local mainStroke = Instance.new("UIStroke", MainFrame)
mainStroke.Color = Theme.Stroke
mainStroke.Thickness = 1.5

-- HEADER (JUDUL CENTER & COLORED CONTROLS)
local Header = Instance.new("Frame", MainFrame)
Header.Name = "Header"
Header.Size = UDim2.new(1, 0, 0, 40)
Header.BackgroundTransparency = 1

local Title = Instance.new("TextLabel", Header)
Title.Text = "AR SCRIPT HUB v5.6"
Title.Size = UDim2.new(1, 0, 1, 0)
Title.Font = Enum.Font.GothamBold
Title.TextColor3 = Theme.TextMain
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Center
Title.BackgroundTransparency = 1

local ControlsContainer = Instance.new("Frame", Header)
ControlsContainer.Size = UDim2.new(0, 80, 1, 0)
ControlsContainer.Position = UDim2.new(1, -85, 0, 0)
ControlsContainer.BackgroundTransparency = 1

local ControlsLayout = Instance.new("UIListLayout", ControlsContainer)
ControlsLayout.FillDirection = Enum.FillDirection.Horizontal
ControlsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
ControlsLayout.VerticalAlignment = Enum.VerticalAlignment.Center
ControlsLayout.Padding = UDim.new(0, 6)

local MinimizeBtn = Instance.new("TextButton", ControlsContainer)
MinimizeBtn.Text = "—"
MinimizeBtn.Size = UDim2.new(0, 28, 0, 28)
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.TextColor3 = Theme.MinimizeColor
MinimizeBtn.TextSize = 12
MinimizeBtn.BackgroundColor3 = Theme.TopbarBg
MinimizeBtn.BackgroundTransparency = 0.4
Instance.new("UICorner", MinimizeBtn).CornerRadius = UDim.new(0, 6)
Instance.new("UIStroke", MinimizeBtn).Color = Theme.Stroke

local CloseBtn = Instance.new("TextButton", ControlsContainer)
CloseBtn.Text = "×"
CloseBtn.Size = UDim2.new(0, 28, 0, 28)
CloseBtn.Font = Enum.Font.GothamMedium
CloseBtn.TextColor3 = Theme.CloseColor
CloseBtn.TextSize = 20
CloseBtn.BackgroundColor3 = Theme.TopbarBg
CloseBtn.BackgroundTransparency = 0.4
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)
Instance.new("UIStroke", CloseBtn).Color = Theme.Stroke

makeDraggable(MainFrame, Header)

-- MODAL BOX POP-UP CONFIRMATION
local ConfirmModal = Instance.new("Frame", MainGui)
ConfirmModal.Size = UDim2.new(0, 320, 0, 150)
ConfirmModal.Position = UDim2.new(0.5, -160, 0.5, -75)
ConfirmModal.BackgroundColor3 = Theme.Bg
ConfirmModal.BackgroundTransparency = 0.05
ConfirmModal.Visible = false
ConfirmModal.ZIndex = 10
Instance.new("UICorner", ConfirmModal).CornerRadius = UDim.new(0, 12)
Instance.new("UIStroke", ConfirmModal).Color = Theme.Stroke

local ModalTitle = Instance.new("TextLabel", ConfirmModal)
ModalTitle.Text = "⚠️ KONFIRMASI"
ModalTitle.Font = Enum.Font.GothamBold
ModalTitle.TextSize = 13
ModalTitle.TextColor3 = Theme.CloseColor
ModalTitle.Size = UDim2.new(1, 0, 0, 35)
ModalTitle.BackgroundTransparency = 1

local ModalDesc = Instance.new("TextLabel", ConfirmModal)
ModalDesc.Text = "Apakah Anda yakin ingin menutup menu ini secara permanen?\n(Perlu menjalankan script ulang untuk membuka)"
ModalDesc.Font = Enum.Font.GothamMedium
ModalDesc.TextSize = 11
ModalDesc.TextColor3 = Theme.TextMain
ModalDesc.Size = UDim2.new(1, -24, 0, 45)
ModalDesc.Position = UDim2.new(0, 12, 0, 35)
ModalDesc.BackgroundTransparency = 1
ModalDesc.TextWrapped = true

local ModalButtonsContainer = Instance.new("Frame", ConfirmModal)
ModalButtonsContainer.Size = UDim2.new(1, -24, 0, 36)
ModalButtonsContainer.Position = UDim2.new(0, 12, 1, -48)
ModalButtonsContainer.BackgroundTransparency = 1

local ModalBtnsLayout = Instance.new("UIListLayout", ModalButtonsContainer)
ModalBtnsLayout.FillDirection = Enum.FillDirection.Horizontal
ModalBtnsLayout.Padding = UDim.new(0, 10)

local CancelBtn = Instance.new("TextButton", ModalButtonsContainer)
CancelBtn.Size = UDim2.new(0, 140, 1, 0)
CancelBtn.BackgroundColor3 = Theme.TopbarBg
CancelBtn.Font = Enum.Font.GothamMedium
CancelBtn.Text = "Batal"
CancelBtn.TextColor3 = Theme.TextMain
CancelBtn.TextSize = 12
Instance.new("UICorner", CancelBtn).CornerRadius = UDim.new(0, 6)
Instance.new("UIStroke", CancelBtn).Color = Theme.Stroke

local ConfirmCloseBtn = Instance.new("TextButton", ModalButtonsContainer)
ConfirmCloseBtn.Size = UDim2.new(0, 146, 1, 0)
ConfirmCloseBtn.BackgroundColor3 = Theme.CloseColor
ConfirmCloseBtn.BackgroundTransparency = 0.2
ConfirmCloseBtn.Font = Enum.Font.GothamBold
ConfirmCloseBtn.Text = "Ya, Tutup"
ConfirmCloseBtn.TextColor3 = Theme.TextMain
ConfirmCloseBtn.TextSize = 12
Instance.new("UICorner", ConfirmCloseBtn).CornerRadius = UDim.new(0, 6)
Instance.new("UIStroke", ConfirmCloseBtn).Color = Theme.CloseColor

ToggleButton.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)
MinimizeBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false end)
CloseBtn.MouseButton1Click:Connect(function() ConfirmModal.Visible = true end)
CancelBtn.MouseButton1Click:Connect(function() ConfirmModal.Visible = false end)
ConfirmCloseBtn.MouseButton1Click:Connect(function() MainGui:Destroy() end)

-- TOPBAR NAVIGATION SYSTEM
local TopbarContainer = Instance.new("ScrollingFrame", MainFrame)
TopbarContainer.Size = UDim2.new(1, -32, 0, 36)
TopbarContainer.Position = UDim2.new(0, 16, 0, 42)
TopbarContainer.BackgroundColor3 = Theme.TopbarBg
TopbarContainer.BackgroundTransparency = 0.3
TopbarContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
TopbarContainer.AutomaticCanvasSize = Enum.AutomaticSize.X
TopbarContainer.ScrollBarThickness = 0
TopbarContainer.ScrollingDirection = Enum.ScrollingDirection.X
Instance.new("UICorner", TopbarContainer).CornerRadius = UDim.new(0, 8)
Instance.new("UIStroke", TopbarContainer).Color = Theme.Stroke

local TopbarLayout = Instance.new("UIListLayout", TopbarContainer)
TopbarLayout.FillDirection = Enum.FillDirection.Horizontal
TopbarLayout.SortOrder = Enum.SortOrder.LayoutOrder
TopbarLayout.VerticalAlignment = Enum.VerticalAlignment.Center
TopbarLayout.Padding = UDim.new(0, 4)

local TopbarPadding = Instance.new("UIPadding", TopbarContainer)
TopbarPadding.PaddingLeft = UDim.new(0, 6)
TopbarPadding.PaddingRight = UDim.new(0, 6)

-- CONTENT VIEW AREA
local ContentView = Instance.new("Frame", MainFrame)
ContentView.Name = "ContentView"
ContentView.Size = UDim2.new(1, -32, 1, -98)
ContentView.Position = UDim2.new(0, 16, 0, 84)
ContentView.BackgroundTransparency = 1

local tabs = {Player = {}, ESP = {}, Teleport = {}, Utilities = {}, Settings = {}, Server = {}}
local activeTab = "Player"

-- FUNGSI MEMBUAT LAYOUT DUA KOLOM (KIRI & KANAN) YANG RESPONSIVE UNTUK MOBILE
local function createTwoColumnGrid(parent)
    local baseScroll = Instance.new("ScrollingFrame", parent)
    baseScroll.Size = UDim2.new(1, 0, 1, 0)
    baseScroll.BackgroundTransparency = 1
    baseScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    baseScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    baseScroll.ScrollBarThickness = 2
    baseScroll.ScrollBarImageColor3 = Theme.AccentPurple

    local gridContainer = Instance.new("Frame", baseScroll)
    gridContainer.Size = UDim2.new(1, 0, 1, 0)
    gridContainer.BackgroundTransparency = 1

    -- Kolom Kiri
    local leftCol = Instance.new("Frame", gridContainer)
    leftCol.Name = "LeftColumn"
    leftCol.Size = UDim2.new(0.49, 0, 0, 0)
    leftCol.Position = UDim2.new(0, 0, 0, 0)
    leftCol.AutomaticSize = Enum.AutomaticSize.Y
    leftCol.BackgroundTransparency = 1
    local lLayout = Instance.new("UIListLayout", leftCol)
    lLayout.Padding = UDim.new(0, 10)
    lLayout.SortOrder = Enum.SortOrder.LayoutOrder

    -- Kolom Kanan
    local rightCol = Instance.new("Frame", gridContainer)
    rightCol.Name = "RightColumn"
    rightCol.Size = UDim2.new(0.49, 0, 0, 0)
    rightCol.Position = UDim2.new(0.51, 0, 0, 0)
    rightCol.AutomaticSize = Enum.AutomaticSize.Y
    rightCol.BackgroundTransparency = 1
    local rLayout = Instance.new("UIListLayout", rightCol)
    rLayout.Padding = UDim.new(0, 10)
    rLayout.SortOrder = Enum.SortOrder.LayoutOrder

    return leftCol, rightCol
end

-- Bikin kontainer tab utama
for tabName, _ in pairs(tabs) do
    local left, right = createTwoColumnGrid(ContentView)
    tabs[tabName].LeftCol = left
    tabs[tabName].RightCol = right
    tabs[tabName].Container = left.Parent.Parent
    tabs[tabName].Container.Visible = (tabName == activeTab)
end

-- Switch Tab Engine
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

local function addTopbarButton(name, textDisplay, order)
    local btn = Instance.new("TextButton", TopbarContainer)
    btn.Size = UDim2.new(0, 90, 1, -8)
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

addTopbarButton("Player", "👤 Player", 1)
addTopbarButton("ESP", "👁️ ESP System", 2)
addTopbarButton("Teleport", "🌀 Teleport", 3)
addTopbarButton("Utilities", "🛠️ Utilities", 4)
addTopbarButton("Settings", "⚙️ Settings", 5)
addTopbarButton("Server", "🖥️ Server", 6)

-- FUNGSI MEMBUAT CARD FITUR INDIVIDUAL
local function createFeatureCard(parentCol, titleText)
    local card = Instance.new("Frame", parentCol)
    card.Size = UDim2.new(1, 0, 0, 0)
    card.AutomaticSize = Enum.AutomaticSize.Y
    card.BackgroundColor3 = Theme.CardBg
    card.BackgroundTransparency = 0.4
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 8)
    Instance.new("UIStroke", card).Color = Theme.Stroke
    
    local padding = Instance.new("UIPadding", card)
    padding.PaddingTop = UDim.new(0, 8)
    padding.PaddingBottom = UDim.new(0, 10)
    padding.PaddingLeft = UDim.new(0, 10)
    padding.PaddingRight = UDim.new(0, 10)
    
    local label = Instance.new("TextLabel", card)
    label.Text = titleText
    label.Font = Enum.Font.GothamBold
    label.TextSize = 11
    label.TextColor3 = Theme.AccentBlue
    label.Size = UDim2.new(1, 0, 0, 14)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.BackgroundTransparency = 1
    
    return card
end

-- FUNGSI KOMPONEN: TOGGLE ACTION
local function createToggle(parentCard, default, callback)
    local state = default
    local toggleFrame = Instance.new("Frame", parentCard)
    toggleFrame.Size = UDim2.new(1, 0, 0, 30)
    toggleFrame.BackgroundTransparency = 1
    toggleFrame.Position = UDim2.new(0, 0, 0, 16)

    local btn = Instance.new("TextButton", toggleFrame)
    btn.Size = UDim2.new(0, 42, 0, 22)
    btn.Position = UDim2.new(1, -42, 0.5, -11)
    btn.BackgroundColor3 = state and Theme.AccentPurple or Theme.TopbarBg
    btn.Text = ""
    Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)
    Instance.new("UIStroke", btn).Color = Theme.Stroke

    local ball = Instance.new("Frame", btn)
    ball.Size = UDim2.new(0, 16, 0, 16)
    ball.Position = UDim2.new(state and 1 or 0, state and -18 or 2, 0.5, -8)
    ball.BackgroundColor3 = Theme.TextMain
    Instance.new("UICorner", ball).CornerRadius = UDim.new(1, 0)

    local statusLabel = Instance.new("TextLabel", toggleFrame)
    statusLabel.Text = state and "Status: ON" or "Status: OFF"
    statusLabel.Font = Enum.Font.GothamMedium
    statusLabel.TextSize = 11
    statusLabel.TextColor3 = state and Theme.AccentPurple or Theme.TextMuted
    statusLabel.Size = UDim2.new(0.6, 0, 1, 0)
    statusLabel.TextXAlignment = Enum.TextXAlignment.Left
    statusLabel.BackgroundTransparency = 1

    btn.MouseButton1Click:Connect(function()
        state = not state
        statusLabel.Text = state and "Status: ON" or "Status: OFF"
        statusLabel.TextColor3 = state and Theme.AccentPurple or Theme.TextMuted
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = state and Theme.AccentPurple or Theme.TopbarBg}):Play()
        TweenService:Create(ball, TweenInfo.new(0.15), {Position = UDim2.new(state and 1 or 0, state and -18 or 2, 0.5, -8)}):Play()
        callback(state)
    end)
end

-- FUNGSI KOMPONEN: SLIDER LEVEL (1-20)
local function createLevelSlider(parentCard, min, max, default, callback)
    local sliderFrame = Instance.new("Frame", parentCard)
    sliderFrame.Size = UDim2.new(1, 0, 0, 36)
    sliderFrame.BackgroundTransparency = 1
    sliderFrame.Position = UDim2.new(0, 0, 0, 16)

    local track = Instance.new("Frame", sliderFrame)
    track.Size = UDim2.new(0.75, 0, 0, 4)
    track.Position = UDim2.new(0, 0, 0.6, -2)
    track.BackgroundColor3 = Theme.Stroke
    Instance.new("UICorner", track).CornerRadius = UDim.new(0, 2)

    local fill = Instance.new("Frame", track)
    local startPerc = (default - min) / (max - min)
    fill.Size = UDim2.new(startPerc, 0, 1, 0)
    fill.BackgroundColor3 = Theme.AccentBlue
    Instance.new("UICorner", fill).CornerRadius = UDim.new(0, 2)

    local valLabel = Instance.new("TextLabel", sliderFrame)
    valLabel.Size = UDim2.new(0.2, 0, 1, 0)
    valLabel.Position = UDim2.new(0.8, 0, 0, 0)
    valLabel.Text = tostring(default)
    valLabel.Font = Enum.Font.GothamBold
    valLabel.TextSize = 13
    valLabel.TextColor3 = Theme.AccentBlue
    valLabel.BackgroundTransparency = 1

    local sBtn = Instance.new("TextButton", track)
    sBtn.Size = UDim2.new(0, 12, 0, 12)
    sBtn.Position = UDim2.new(startPerc, -6, 0.5, -6)
    sBtn.BackgroundColor3 = Theme.TextMain
    Instance.new("UICorner", sBtn).CornerRadius = UDim.new(1, 0)

    local function update(input)
        local relX = input.Position.X - track.AbsolutePosition.X
        local perc = math.clamp(relX / track.AbsoluteSize.X, 0, 1)
        fill.Size = UDim2.new(perc, 0, 1, 0)
        sBtn.Position = UDim2.new(perc, -6, 0.5, -6)
        local val = math.round(min + (perc * (max - min)))
        valLabel.Text = tostring(val)
        callback(val)
    end

    local sliding = false
    sBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then sliding = true end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then sliding = false end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then update(input) end
    end)
end

-- Helper membuat standard button
local function createCardButton(parentCard, text, callback)
    local btn = Instance.new("TextButton", parentCard)
    btn.Size = UDim2.new(1, 0, 0, 30)
    btn.Position = UDim2.new(0, 0, 0, 16)
    btn.BackgroundColor3 = Theme.TopbarBg
    btn.Font = Enum.Font.GothamMedium
    btn.Text = text
    btn.TextColor3 = Theme.TextMain
    btn.TextSize = 11
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    Instance.new("UIStroke", btn).Color = Theme.Stroke
    btn.MouseButton1Click:Connect(callback)
    return btn
end

-- ====================================================================
-- DEPLOY ISI TAB 1: PLAYER (TWO-COLUMN ZIGZAG LOGIC)
-- ====================================================================

-- 1. KIRI (Baris 1): Fly
local flyCard = createFeatureCard(tabs.Player.LeftCol, "Fly")
local isFlying, flySpeed = false, 50
local bodyGyro, bodyVelocity
local function startFlying()
    local char = Player.Character or Player.CharacterAdded:Wait()
    local root = char:WaitForChild("HumanoidRootPart")
    bodyGyro = Instance.new("BodyGyro", root)
    bodyGyro.P = 9e4
    bodyGyro.maxTorque = Vector3.new(9e9, 9e9, 9e9)
    bodyGyro.cframe = root.CFrame
    bodyVelocity = Instance.new("BodyVelocity", root)
    bodyVelocity.velocity = Vector3.new(0, 0.1, 0)
    bodyVelocity.maxForce = Vector3.new(9e9, 9e9, 9e9)
    task.spawn(function()
        while isFlying and root and root.Parent do
            local cam = workspace.CurrentCamera
            local moveDir = Vector3.new(0,0,0)
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + cam.CFrame.RightVector end
            bodyGyro.cframe = cam.CFrame
            bodyVelocity.velocity = moveDir * flySpeed
            task.wait()
        end
    end)
end
local function stopFlying()
    isFlying = false
    if bodyGyro then bodyGyro:Destroy() end
    if bodyVelocity then bodyVelocity:Destroy() end
end
createToggle(flyCard, false, function(state)
    isFlying = state
    if state then startFlying() else stopFlying() end
end)

-- 2. KANAN (Baris 1): Jump Power
local jumpCard = createFeatureCard(tabs.Player.RightCol, "Jump Power")
local curJumpLevel = 1
createLevelSlider(jumpCard, 1, 20, 1, function(val)
    curJumpLevel = val
    pcall(function()
        local hum = Player.Character and Player.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.JumpPower = 50 + (val * 10) end
    end)
end)

-- 3. KIRI (Baris 2): Speed
local speedCard = createFeatureCard(tabs.Player.LeftCol, "Speed")
local curSpeedLevel = 1
createLevelSlider(speedCard, 1, 20, 1, function(val)
    curSpeedLevel = val
    pcall(function()
        local hum = Player.Character and Player.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = 16 + (val * 10) end
    end)
end)

-- 4. KANAN (Baris 2): Infinite Jump
local infJumpCard = createFeatureCard(tabs.Player.RightCol, "Infinite Jump")
local infJumpEnabled = false
local infJumpConnection
infJumpConnection = UserInputService.JumpRequest:Connect(function()
    if infJumpEnabled then
        pcall(function()
            local hum = Player.Character and Player.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
        end)
    end
end)
createToggle(infJumpCard, false, function(state)
    infJumpEnabled = state
end)

-- ====================================================================
-- TEMPLATE UNTUK TAB LAIN AGAR MAKIN LENGKAP SAAT ANDA ISI NANTI
-- ====================================================================
createFeatureCard(tabs.ESP.LeftCol, "Master Active ESP")
createFeatureCard(tabs.ESP.RightCol, "Show Names")
createFeatureCard(tabs.Teleport.LeftCol, "Tween Movement")
createFeatureCard(tabs.Teleport.RightCol, "Waypoint Vectors")
createFeatureCard(tabs.Utilities.LeftCol, "Fling Target")
createFeatureCard(tabs.Utilities.RightCol, "Sweep Map Tools")

-- ====================================================================
-- ISI MENU: SETTINGS (UI CONFIGURATION)
-- ====================================================================
local settingsSection = createFeatureCard(tabs.Settings.LeftCol, "UI Configuration")

-- SLIDER TRANSPARANSI
local SliderFrame = Instance.new("Frame", settingsSection)
SliderFrame.Size = UDim2.new(1, 0, 0, 40)
SliderFrame.BackgroundTransparency = 1
local SliderLabel = Instance.new("TextLabel", SliderFrame)
SliderLabel.Text = "UI Opacity"
SliderLabel.Font = Enum.Font.GothamMedium
SliderLabel.TextSize = 11
SliderLabel.TextColor3 = Theme.TextMain
SliderLabel.Size = UDim2.new(0.4, 0, 1, 0)
SliderLabel.TextXAlignment = Enum.TextXAlignment.Left
SliderLabel.BackgroundTransparency = 1
local SliderTrack = Instance.new("Frame", SliderFrame)
SliderTrack.Size = UDim2.new(0.55, 0, 0, 4)
SliderTrack.Position = UDim2.new(0.45, 0, 0.5, -2)
SliderTrack.BackgroundColor3 = Theme.Stroke
local SliderFill = Instance.new("Frame", SliderTrack)
SliderFill.Size = UDim2.new(Theme.BgTrans, 0, 1, 0)
SliderFill.BackgroundColor3 = Theme.AccentPurple
local SliderBtn = Instance.new("TextButton", SliderTrack)
SliderBtn.Size = UDim2.new(0, 12, 0, 12)
SliderBtn.Position = UDim2.new(Theme.BgTrans, -6, 0.5, -6)
SliderBtn.BackgroundColor3 = Theme.AccentBlue
SliderBtn.Text = ""
Instance.new("UICorner", SliderBtn).CornerRadius = UDim.new(1, 0)

local sliding = false
SliderBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then sliding = true end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then sliding = false end
end)
UserInputService.InputChanged:Connect(function(input)
    if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local relX = input.Position.X - SliderTrack.AbsolutePosition.X
        local perc = math.clamp(relX / SliderTrack.AbsoluteSize.X, 0, 1)
        SliderFill.Size = UDim2.new(perc, 0, 1, 0)
        SliderBtn.Position = UDim2.new(perc, -6, 0.5, -6)
        MainFrame.BackgroundTransparency = math.clamp(perc, 0, 0.95)
    end
end)

createCardButton(settingsSection, "🔄 Reload UI", function() print("Reloading...") end)
createCardButton(settingsSection, "🔴 Destroy UI", function() MainGui:Destroy() end)

-- ====================================================================
-- ISI MENU: SERVER
-- ====================================================================
local serverSection = createFeatureCard(tabs.Server.LeftCol, "Connections")
createCardButton(serverSection, "⚡ Instant Rejoin Server", function()
    game:GetService("TeleportService"):Teleport(game.PlaceId, Player)
end)
createCardButton(serverSection, "🌐 Auto Server Hop", function()
    print("Hopping server...")
end)
createCardButton(serverSection, "☠️ Force Respawn", function()
    pcall(function() Player.Character:BreakJoints() end)
end)

print("[AR SCRIPT HUB V5.6]: Two-Column Grid & Player Logic Deployed!")
