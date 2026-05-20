-- ====================================================================
-- AR SCRIPT HUB - v5.6 (PERFECT CLEAN SLIDER UPDATE)
-- ====================================================================
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local SafeGuiTarget = Player:FindFirstChildOfClass("PlayerGui") or Player:WaitForChild("PlayerGui", 5)
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- Bersihkan GUI Lama jika ada
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
    TopbarBg = Color3.fromRGB(18, 16, 36),     
    CardBg = Color3.fromRGB(22, 20, 42),     
    CardTrans = 0.4,                         
    Stroke = Color3.fromRGB(48, 44, 76),     
    Accent = Color3.fromRGB(115, 170, 255),  
    AccentPurple = Color3.fromRGB(190, 130, 255), 
    TextMain = Color3.fromRGB(245, 245, 255),
    TextMuted = Color3.fromRGB(140, 145, 175),
    MinimizeColor = Color3.fromRGB(115, 170, 255), 
    CloseColor = Color3.fromRGB(255, 105, 105)     
}

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

-- FLOATING TOGGLE
local ToggleButton = Instance.new("TextButton")
ToggleButton.Name = "ToggleButton"
ToggleButton.Parent = MainGui
ToggleButton.Size = UDim2.new(0, 48, 0, 48)
ToggleButton.Position = UDim2.new(0.02, 0, 0.2, 0)
ToggleButton.BackgroundColor3 = Theme.Bg
ToggleButton.BackgroundTransparency = 0.1
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.Text = "AR"
ToggleButton.TextColor3 = Theme.Accent
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
MainFrame.Size = UDim2.new(0, 540, 0, 360)
MainFrame.Position = UDim2.new(0.5, -270, 0.5, -180)
MainFrame.BackgroundColor3 = Theme.Bg
MainFrame.BackgroundTransparency = Theme.BgTrans
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 14)
local mainStroke = Instance.new("UIStroke", MainFrame)
mainStroke.Color = Theme.Stroke
mainStroke.Thickness = 1.5

-- HEADER ROW
local Header = Instance.new("Frame", MainFrame)
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

-- MODAL BOX CLOSE CONFIRMATION
local ConfirmModal = Instance.new("Frame", MainGui)
ConfirmModal.Size = UDim2.new(0, 320, 0, 150)
ConfirmModal.Position = UDim2.new(0.5, -160, 0.5, -75)
ConfirmModal.BackgroundColor3 = Theme.Bg
ConfirmModal.BackgroundTransparency = 0.05
ConfirmModal.Visible = false
ConfirmModal.ZIndex = 100
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
ModalDesc.Text = "Apakah Anda yakin ingin menutup menu ini secara permanen?\n(Perlu menjalankan script ulang untuk membuka kembali)"
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

-- HORIZONTAL SCROLLING TOPBAR NAVIGATION
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

-- CONTENT FRAME SYSTEM
local ContentView = Instance.new("Frame", MainFrame)
ContentView.Name = "ContentView"
ContentView.Size = UDim2.new(1, -32, 1, -98)
ContentView.Position = UDim2.new(0, 16, 0, 84)
ContentView.BackgroundTransparency = 1

local tabs = {Player = {}, ESP = {}, Teleport = {}, World = {}, Utilities = {}, Settings = {}}
local activeTab = "Player"

-- ENGINE PEMBUAT GRID DUA KOLOM
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

    local leftCol = Instance.new("Frame", gridContainer)
    leftCol.Name = "LeftColumn"
    leftCol.Size = UDim2.new(0.49, 0, 0, 0)
    leftCol.AutomaticSize = Enum.AutomaticSize.Y
    leftCol.BackgroundTransparency = 1
    local lLayout = Instance.new("UIListLayout", leftCol)
    lLayout.Padding = UDim.new(0, 12)
    lLayout.SortOrder = Enum.SortOrder.LayoutOrder

    local rightCol = Instance.new("Frame", gridContainer)
    rightCol.Name = "RightColumn"
    rightCol.Size = UDim2.new(0.49, 0, 0, 0)
    rightCol.Position = UDim2.new(0.51, 0, 0, 0)
    rightCol.AutomaticSize = Enum.AutomaticSize.Y
    rightCol.BackgroundTransparency = 1
    local rLayout = Instance.new("UIListLayout", rightCol)
    rLayout.Padding = UDim.new(0, 12)
    rLayout.SortOrder = Enum.SortOrder.LayoutOrder

    return leftCol, rightCol
end

for tabName, _ in pairs(tabs) do
    local left, right = createTwoColumnGrid(ContentView)
    tabs[tabName].LeftCol = left
    tabs[tabName].RightCol = right
    tabs[tabName].Container = left.Parent.Parent
    tabs[tabName].Container.Visible = (tabName == activeTab)
end

-- Navigation Switcher Engine
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
addTopbarButton("World", "🌐 World", 4)
addTopbarButton("Utilities", "🛠️ Utilities", 5)
addTopbarButton("Settings", "⚙️ Settings", 6)

-- FUNGSI MAKER GROUP CARD
local function createGroupCard(parentCol, titleText)
    local card = Instance.new("Frame", parentCol)
    card.Size = UDim2.new(1, 0, 0, 0)
    card.AutomaticSize = Enum.AutomaticSize.Y
    card.BackgroundColor3 = Theme.CardBg
    card.BackgroundTransparency = Theme.CardTrans
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 8)
    Instance.new("UIStroke", card).Color = Theme.Stroke
    
    local padding = Instance.new("UIPadding", card)
    padding.PaddingTop = UDim.new(0, 8)
    padding.PaddingBottom = UDim.new(0, 10)
    padding.PaddingLeft = UDim.new(0, 10)
    padding.PaddingRight = UDim.new(0, 10)
    
    local layout = Instance.new("UIListLayout", card)
    layout.Padding = UDim.new(0, 8)
    layout.SortOrder = Enum.SortOrder.LayoutOrder

    local label = Instance.new("TextLabel", card)
    label.Text = "🔹 " .. titleText:upper()
    label.Font = Enum.Font.GothamBold
    label.TextSize = 10
    label.TextColor3 = Theme.AccentPurple
    label.Size = UDim2.new(1, 0, 0, 16)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.BackgroundTransparency = 1
    label.LayoutOrder = 0
    
    return card
end

-- MINI COMPONENT: TOGGLE SWITCH
local function addCardToggle(parentCard, labelText, default, order, callback)
    local holder = Instance.new("Frame", parentCard)
    holder.Size = UDim2.new(1, 0, 0, 26) 
    holder.BackgroundTransparency = 1
    holder.LayoutOrder = order
    
    local lbl = Instance.new("TextLabel", holder)
    lbl.Text = labelText 
    lbl.Size = UDim2.new(0.65, 0, 1, 0)
    lbl.Font = Enum.Font.GothamMedium 
    lbl.TextColor3 = Theme.TextMain 
    lbl.TextSize = 11
    lbl.TextXAlignment = Enum.TextXAlignment.Left 
    lbl.BackgroundTransparency = 1
    
    local bgTrack = Instance.new("TextButton", holder)
    bgTrack.Size = UDim2.new(0, 32, 0, 16) 
    bgTrack.Position = UDim2.new(1, -32, 0.5, -8)
    bgTrack.BackgroundColor3 = default and Theme.Accent or Theme.Bg 
    bgTrack.Text = ""
    Instance.new("UICorner", bgTrack).CornerRadius = UDim.new(0, 8)
    local tStroke = Instance.new("UIStroke", bgTrack)
    tStroke.Color = default and Theme.Accent or Theme.Stroke
    
    local knob = Instance.new("Frame", bgTrack)
    knob.Size = UDim2.new(0, 12, 0, 12) 
    knob.Position = UDim2.new(0, default and 17 or 2, 0.5, -6)
    knob.BackgroundColor3 = Theme.TextMain 
    Instance.new("UICorner", knob).CornerRadius = UDim.new(0, 6)
    
    local state = default
    bgTrack.MouseButton1Click:Connect(function()
        state = not state
        local targetX = state and 17 or 2
        local targetTrackColor = state and Theme.Accent or Theme.Bg
        TweenService:Create(knob, TweenInfo.new(0.08), {Position = UDim2.new(0, targetX, 0.5, -6)}):Play()
        TweenService:Create(bgTrack, TweenInfo.new(0.08), {BackgroundColor3 = targetTrackColor}):Play()
        tStroke.Color = state and Theme.Accent or Theme.Stroke
        callback(state)
    end)
end

-- MINI COMPONENT: SLIDER ANTI TULISAN "BUTTON" + KOTAK LEVEL SEBELAH KANAN FIXED
local function addCardSlider(parentCard, labelText, min, max, default, order, callback)
    local holder = Instance.new("Frame", parentCard)
    holder.Size = UDim2.new(1, 0, 0, 34) 
    holder.BackgroundTransparency = 1
    holder.LayoutOrder = order

    -- JUDUL SLIDER
    local lbl = Instance.new("TextLabel", holder)
    lbl.Text = labelText
    lbl.Size = UDim2.new(0.7, 0, 0, 14)
    lbl.Position = UDim2.new(0, 0, 0, 0)
    lbl.Font = Enum.Font.GothamMedium 
    lbl.TextColor3 = Theme.TextMuted 
    lbl.TextSize = 10
    lbl.TextXAlignment = Enum.TextXAlignment.Left 
    lbl.BackgroundTransparency = 1

    -- KOTAK INDIKATOR LEVEL (Ditempatkan presisi di kanan atas baris slider)
    local valBox = Instance.new("Frame", holder)
    valBox.Size = UDim2.new(0, 28, 0, 15)
    valBox.Position = UDim2.new(1, -28, 0, 0)
    valBox.BackgroundColor3 = Theme.TopbarBg
    Instance.new("UICorner", valBox).CornerRadius = UDim.new(0, 4)
    local boxStroke = Instance.new("UIStroke", valBox)
    boxStroke.Color = Theme.Stroke
    boxStroke.Thickness = 1

    local valLabel = Instance.new("TextLabel", valBox)
    valLabel.Size = UDim2.new(1, 0, 1, 0)
    valLabel.Text = tostring(default)
    valLabel.Font = Enum.Font.GothamBold
    valLabel.TextColor3 = Theme.Accent
    valLabel.TextSize = 10
    valLabel.TextXAlignment = Enum.TextXAlignment.Center
    valLabel.TextYAlignment = Enum.TextYAlignment.Center
    valLabel.BackgroundTransparency = 1

    -- TRACK LINE (Garis Slider Bawah)
    local track = Instance.new("Frame", holder)
    track.Size = UDim2.new(1, 0, 0, 4)
    track.Position = UDim2.new(0, 0, 1, -4)
    track.BackgroundColor3 = Theme.Stroke
    Instance.new("UICorner", track).CornerRadius = UDim.new(0, 2)

    local fill = Instance.new("Frame", track)
    local startPerc = (default - min) / (max - min)
    fill.Size = UDim2.new(startPerc, 0, 1, 0)
    fill.BackgroundColor3 = Theme.Accent
    Instance.new("UICorner", fill).CornerRadius = UDim.new(0, 2)

    -- MENGGUNAKAN FRAME + IMAGEBUTTON TRANSPARAN AGAR ROBLOX TIDAK BISA MEMUNCULKAN TEKS "BUTTON"
    local sliderKnob = Instance.new("Frame", track)
    sliderKnob.Size = UDim2.new(0, 12, 0, 12)
    sliderKnob.Position = UDim2.new(startPerc, -6, 0.5, -6)
    sliderKnob.BackgroundColor3 = Theme.TextMain
    Instance.new("UICorner", sliderKnob).CornerRadius = UDim.new(1, 0)
    local knobStroke = Instance.new("UIStroke", sliderKnob)
    knobStroke.Color = Theme.AccentPurple
    knobStroke.Thickness = 1

    local dragTrigger = Instance.new("ImageButton", sliderKnob)
    dragTrigger.Size = UDim2.new(2, 0, 2, 0) -- Area touch lebih besar agar mudah digeser di HP
    dragTrigger.Position = UDim2.new(-0.5, 0, -0.5, 0)
    dragTrigger.BackgroundTransparency = 1
    dragTrigger.Image = "" -- Benar-benar kosong polos tanpa text element bawaan

    local function update(input)
        local relX = input.Position.X - track.AbsolutePosition.X
        local perc = math.clamp(relX / track.AbsoluteSize.X, 0, 1)
        fill.Size = UDim2.new(perc, 0, 1, 0)
        sliderKnob.Position = UDim2.new(perc, -6, 0.5, -6)
        local val = math.round(min + (perc * (max - min)))
        valLabel.Text = tostring(val) -- Nilai di kotak kanan terupdate otomatis!
        callback(val)
    end

    local sliding = false
    dragTrigger.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then sliding = true end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then sliding = false end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then update(input) end
    end)
end

-- ====================================================================
-- CORE PLACEMENT: TAB PLAYER 
-- ====================================================================

-- --- [ KOLOM KIRI: FLY & NOCLIP ] ---
local leftFlyGroup = createGroupCard(tabs.Player.LeftCol, "Fly & Noclip")
local isFlying, flySpeed = false, 50
local bodyGyro, bodyVelocity
local noclipActive, noclipConnection

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

-- 1. Toggle Fly
addCardToggle(leftFlyGroup, "Fly", false, 1, function(state)
    isFlying = state
    if state then startFlying() else stopFlying() end
end)

-- 2. Slider Fly Level
addCardSlider(leftFlyGroup, "Fly Level", 1, 20, 5, 2, function(val)
    flySpeed = val * 10
end)

-- 3. Toggle Noclip
addCardToggle(leftFlyGroup, "Noclip", false, 3, function(v)
    noclipActive = v
    if v then
        if noclipConnection then noclipConnection:Disconnect() end
        noclipConnection = RunService.Stepped:Connect(function()
            if noclipActive and Player.Character then 
                for _, p in pairs(Player.Character:GetChildren()) do 
                    if p:IsA("BasePart") then p.CanCollide = false end 
                end 
            end
        end)
    else 
        if noclipConnection then noclipConnection:Disconnect() noclipConnection = nil end 
    end
end)


-- --- [ KOLOM KANAN: JUMP ] ---
local rightJumpGroup = createGroupCard(tabs.Player.RightCol, "Jump")
local jumpToggleState = false local jumpLevel = 5
local infJumpEnabled = false local infJumpConnection

local function updateJumpPower()
    local char = Player.Character
    if char and char:FindFirstChildOfClass("Humanoid") then
        local hum = char:FindFirstChildOfClass("Humanoid") 
        hum.UseJumpPower = true 
        hum.JumpPower = jumpToggleState and (jumpLevel * 10) or 50 
    end
end

-- 1. Toggle Jump Power
addCardToggle(rightJumpGroup, "Jump Power", false, 1, function(v)
    jumpToggleState = v 
    updateJumpPower() 
end)

-- 2. Slider Jump Level
addCardSlider(rightJumpGroup, "Jump Level", 1, 20, 5, 2, function(lvl)
    jumpLevel = lvl 
    updateJumpPower() 
end)

-- 3. Toggle Infinite Jump
infJumpConnection = UserInputService.JumpRequest:Connect(function()
    if infJumpEnabled then
        pcall(function()
            local hum = Player.Character and Player.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
        end)
    end
end)

addCardToggle(rightJumpGroup, "Infinite Jump", false, 3, function(state)
    infJumpEnabled = state
end)

-- ====================================================================
-- SINKRONISASI TOMBOL KELUAR
-- ====================================================================
ConfirmCloseBtn.MouseButton1Click:Connect(function()
    if noclipConnection then noclipConnection:Disconnect() end 
    if infJumpConnection then infJumpConnection:Disconnect() end
    stopFlying() 
    MainGui:Destroy() 
end)

print("[AR SCRIPT HUB V5.6]: Slider Visual Bug Fixed completely!")
