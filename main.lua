-- ====================================================================
-- AR SCRIPT HUB - CLEAN UI FRAMEWORK ONLY (NO EXPLOIT FUNCTIONS)
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
    BgTrans = 0.20,                          
    CardBg = Color3.fromRGB(20, 22, 38),     
    CardTrans = 0.4,                         
    Stroke = Color3.fromRGB(56, 52, 92),     
    Accent = Color3.fromRGB(115, 170, 255),  
    AccentPurple = Color3.fromRGB(190, 130, 255), 
    TextMain = Color3.fromRGB(245, 245, 255),
    TextMuted = Color3.fromRGB(140, 145, 175)
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
MainFrame.Size = UDim2.new(0, 460, 0, 380)
MainFrame.Position = UDim2.new(0.5, -230, 0.5, -190)
MainFrame.BackgroundColor3 = Theme.Bg
MainFrame.BackgroundTransparency = Theme.BgTrans
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)
local mainStroke = Instance.new("UIStroke", MainFrame)
mainStroke.Color = Theme.Stroke
mainStroke.Thickness = 1.5

-- HEADER
local Header = Instance.new("Frame", MainFrame)
Header.Size = UDim2.new(1, 0, 0, 45)
Header.BackgroundTransparency = 1

local Title = Instance.new("TextLabel", Header)
Title.Text = "✨ AR UI FRAMEWORK <font color='#c092ff'>v5.6</font>"
Title.RichText = true
Title.Size = UDim2.new(0.7, 0, 1, 0)
Title.Position = UDim2.new(0, 14, 0, 0)
Title.Font = Enum.Font.GothamBold
Title.TextColor3 = Theme.TextMain
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.BackgroundTransparency = 1

local CloseBtn = Instance.new("TextButton", Header)
CloseBtn.Text = "×"
CloseBtn.Size = UDim2.new(0, 45, 1, 0)
CloseBtn.Position = UDim2.new(1, -45, 0, 0)
CloseBtn.Font = Enum.Font.GothamMedium
CloseBtn.TextColor3 = Theme.TextMuted
CloseBtn.TextSize = 24
CloseBtn.BackgroundTransparency = 1

makeDraggable(MainFrame, Header)
ToggleButton.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)
CloseBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false end)

-- SIDEBAR NAV MENU
local NavFrame = Instance.new("Frame", MainFrame)
NavFrame.Size = UDim2.new(0, 100, 1, -65)
NavFrame.Position = UDim2.new(0, 14, 0, 50)
NavFrame.BackgroundTransparency = 1

local ContentFrame = Instance.new("Frame", MainFrame)
ContentFrame.Size = UDim2.new(1, -142, 1, -65)
ContentFrame.Position = UDim2.new(0, 128, 0, 50)
ContentFrame.BackgroundTransparency = 1

local tabs = {Player = {}, ESP = {}, Teleport = {}, World = {}, Utilities = {}, Settings = {}}
local activeTab = "Player"

local function createContainer(name)
    local f = Instance.new("ScrollingFrame", ContentFrame)
    f.Size = UDim2.new(1, 0, 1, 0)
    f.BackgroundTransparency = 1
    f.CanvasSize = UDim2.new(0, 0, 0, 0)
    f.AutomaticCanvasSize = Enum.AutomaticSize.Y
    f.ScrollBarThickness = 3
    f.ScrollBarImageColor3 = Theme.Accent
    f.Visible = (name == activeTab)
    tabs[name].Container = f
    
    local layout = Instance.new("UIListLayout", f)
    layout.Padding = UDim.new(0, 12)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
end

createContainer("Player")
createContainer("ESP")
createContainer("Teleport")
createContainer("World")
createContainer("Utilities")
createContainer("Settings")

local function switchTab(tabName)
    activeTab = tabName
    for k, v in pairs(tabs) do
        v.Container.Visible = (k == tabName)
        if v.Button then
            if k == tabName then
                v.Button.TextColor3 = Theme.Accent
                v.Button.Font = Enum.Font.GothamBold
                TweenService:Create(v.Button, TweenInfo.new(0.1), {Size = UDim2.new(1, 4, 0, 30)}):Play()
            else
                v.Button.TextColor3 = Theme.TextMuted
                v.Button.Font = Enum.Font.GothamMedium
                TweenService:Create(v.Button, TweenInfo.new(0.1), {Size = UDim2.new(1, 0, 0, 30)}):Play()
            end
        end
    end
end

local function addTabButton(name, textDisplay, order)
    local btn = Instance.new("TextButton", NavFrame)
    btn.Size = UDim2.new(1, 0, 0, 30)
    btn.Position = UDim2.new(0, 0, 0, (order - 1) * 34)
    btn.BackgroundTransparency = 1
    btn.Font = (name == activeTab) and Enum.Font.GothamBold or Enum.Font.GothamMedium
    btn.Text = textDisplay
    btn.TextSize = 12
    btn.TextColor3 = (name == activeTab) and Theme.Accent or Theme.TextMuted
    btn.TextXAlignment = Enum.TextXAlignment.Left
    tabs[name].Button = btn
    btn.MouseButton1Click:Connect(function() switchTab(name) end)
end

addTabButton("Player", "👤 Player", 1)
addTabButton("ESP", "👁️ ESP System", 2)
addTabButton("Teleport", "🌀 Teleport", 3)
addTabButton("World", "🌐 World", 4)
addTabButton("Utilities", "🛠️ Utilities", 5)
addTabButton("Settings", "⚙️ Settings", 6)

-- COMPONENTS GENERATOR
local function createSectionCard(parent, titleText, layoutOrder)
    local section = Instance.new("Frame", parent)
    section.Size = UDim2.new(1, -6, 0, 0)
    section.AutomaticSize = Enum.AutomaticSize.Y 
    section.BackgroundColor3 = Theme.CardBg
    section.BackgroundTransparency = Theme.CardTrans
    section.LayoutOrder = layoutOrder
    Instance.new("UICorner", section).CornerRadius = UDim.new(0, 8)
    local sStroke = Instance.new("UIStroke", section)
    sStroke.Color = Theme.Stroke
    
    local sTitle = Instance.new("TextLabel", section)
    sTitle.Size = UDim2.new(1, -12, 0, 24)
    sTitle.Position = UDim2.new(0, 12, 0, 6)
    sTitle.Text = titleText:upper()
    sTitle.Font = Enum.Font.GothamBold
    sTitle.TextColor3 = Theme.AccentPurple
    sTitle.TextSize = 10
    sTitle.BackgroundTransparency = 1
    sTitle.TextXAlignment = Enum.TextXAlignment.Left
    
    local container = Instance.new("Frame", section)
    container.Size = UDim2.new(1, -24, 0, 0)
    container.Position = UDim2.new(0, 12, 0, 34)
    container.BackgroundTransparency = 1
    container.AutomaticSize = Enum.AutomaticSize.Y
    
    local innerLayout = Instance.new("UIListLayout", container)
    innerLayout.Padding = UDim.new(0, 8)
    innerLayout.SortOrder = Enum.SortOrder.LayoutOrder
    
    local padding = Instance.new("UIPadding", container)
    padding.PaddingBottom = UDim.new(0, 10)

    return container
end

local function createToggleSwitch(parent, labelText, callback)
    local holder = Instance.new("Frame", parent)
    holder.Size = UDim2.new(1, 0, 0, 28) holder.BackgroundTransparency = 1
    
    local lbl = Instance.new("TextLabel", holder)
    lbl.Text = labelText lbl.Size = UDim2.new(0.7, 0, 1, 0)
    lbl.Font = Enum.Font.GothamMedium lbl.TextColor3 = Theme.TextMain lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left lbl.BackgroundTransparency = 1
    
    local bgTrack = Instance.new("TextButton", holder)
    bgTrack.Size = UDim2.new(0, 34, 0, 18) bgTrack.Position = UDim2.new(1, -34, 0.5, -9)
    bgTrack.BackgroundColor3 = Theme.Bg bgTrack.Text = ""
    Instance.new("UICorner", bgTrack).CornerRadius = UDim.new(0, 9)
    local tStroke = Instance.new("UIStroke", bgTrack) tStroke.Color = Theme.Stroke
    
    local knob = Instance.new("Frame", bgTrack)
    knob.Size = UDim2.new(0, 12, 0, 12) knob.Position = UDim2.new(0, 3, 0.5, -6)
    knob.BackgroundColor3 = Theme.TextMuted Instance.new("UICorner", knob).CornerRadius = UDim.new(0, 6)
    
    local state = false
    bgTrack.MouseButton1Click:Connect(function()
        state = not state
        local targetX = state and 19 or 3
        local targetTrackColor = state and Theme.Accent or Theme.Bg
        local targetKnobColor = state and Theme.Bg or Theme.TextMuted
        TweenService:Create(knob, TweenInfo.new(0.08), {Position = UDim2.new(0, targetX, 0.5, -6), BackgroundColor3 = targetKnobColor}):Play()
        TweenService:Create(bgTrack, TweenInfo.new(0.08), {BackgroundColor3 = targetTrackColor}):Play()
        tStroke.Color = state and Theme.Accent or Theme.Stroke
        callback(state)
    end)
end

local function createLevelControl(parent, labelText, defaultLvl, min, max, callback)
    local holder = Instance.new("Frame", parent)
    holder.Size = UDim2.new(1, 0, 0, 36) 
    holder.BackgroundTransparency = 1
    
    local lbl = Instance.new("TextLabel", holder)
    lbl.Text = labelText
    lbl.Size = UDim2.new(0.7, 0, 0, 14)
    lbl.Position = UDim2.new(0, 0, 0, 0)
    lbl.Font = Enum.Font.GothamMedium 
    lbl.TextColor3 = Theme.TextMain 
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left 
    lbl.BackgroundTransparency = 1

    local valBox = Instance.new("Frame", holder)
    valBox.Size = UDim2.new(0, 26, 0, 16)
    valBox.Position = UDim2.new(1, -26, 0, 0)
    valBox.BackgroundColor3 = Theme.Bg
    Instance.new("UICorner", valBox).CornerRadius = UDim.new(0, 4)
    local boxStroke = Instance.new("UIStroke", valBox)
    boxStroke.Color = Theme.Stroke
    boxStroke.Thickness = 1

    local valLabel = Instance.new("TextLabel", valBox)
    valLabel.Size = UDim2.new(1, 0, 1, 0)
    valLabel.Text = tostring(defaultLvl)
    valLabel.Font = Enum.Font.GothamBold
    valLabel.TextColor3 = Theme.Accent
    valLabel.TextSize = 10
    valLabel.TextXAlignment = Enum.TextXAlignment.Center
    valLabel.TextYAlignment = Enum.TextYAlignment.Center
    valLabel.BackgroundTransparency = 1

    local track = Instance.new("Frame", holder)
    track.Size = UDim2.new(1, 0, 0, 4)
    track.Position = UDim2.new(0, 0, 1, -4)
    track.BackgroundColor3 = Theme.Stroke
    Instance.new("UICorner", track).CornerRadius = UDim.new(0, 2)

    local fill = Instance.new("Frame", track)
    local startPerc = (defaultLvl - min) / (max - min)
    fill.Size = UDim2.new(startPerc, 0, 1, 0)
    fill.BackgroundColor3 = Theme.Accent
    Instance.new("UICorner", fill).CornerRadius = UDim.new(0, 2)

    local sliderKnob = Instance.new("Frame", track)
    sliderKnob.Size = UDim2.new(0, 12, 0, 12)
    sliderKnob.Position = UDim2.new(startPerc, -6, 0.5, -6)
    sliderKnob.BackgroundColor3 = Theme.TextMain
    Instance.new("UICorner", sliderKnob).CornerRadius = UDim.new(1, 0)
    local knobStroke = Instance.new("UIStroke", sliderKnob)
    knobStroke.Color = Theme.AccentPurple
    knobStroke.Thickness = 1

    local dragTrigger = Instance.new("ImageButton", sliderKnob)
    dragTrigger.Size = UDim2.new(2, 0, 2, 0)
    dragTrigger.Position = UDim2.new(-0.5, 0, -0.5, 0)
    dragTrigger.BackgroundTransparency = 1
    dragTrigger.Image = ""

    local function update(input)
        local relX = input.Position.X - track.AbsolutePosition.X
        local perc = math.clamp(relX / track.AbsoluteSize.X, 0, 1)
        fill.Size = UDim2.new(perc, 0, 1, 0)
        sliderKnob.Position = UDim2.new(perc, -6, 0.5, -6)
        local val = math.round(min + (perc * (max - min)))
        valLabel.Text = tostring(val)
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

local function createStandardButton(parent, textDisplay, callback)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(1, 0, 0, 28) btn.BackgroundColor3 = Theme.Bg
    btn.Font = Enum.Font.GothamBold btn.Text = textDisplay btn.TextColor3 = Theme.TextMain btn.TextSize = 12
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)
    local bStroke = Instance.new("UIStroke", btn) bStroke.Color = Theme.Stroke
    btn.MouseButton1Click:Connect(callback)
end

local GlobalTargetName = ""

-- ====================================================================
-- TAB 1: PLAYER MODIFIERS (UI ONLY)
-- ====================================================================
local pExtraNav = createSectionCard(tabs.Player.Container, "Ghost Environment Bypass", 1)
createToggleSwitch(pExtraNav, "Noclip (Ghost Pass)", function(v) 
    -- Fungsi eksekusi dihapus
end)
createToggleSwitch(pExtraNav, "Float Platform Stabilizer", function(state) 
    -- Fungsi eksekusi dihapus
end)

local pFly = createSectionCard(tabs.Player.Container, "Fly", 2)
createToggleSwitch(pFly, "Fly Hack Enabled", function(v) 
    -- Fungsi eksekusi dihapus
end)
createLevelControl(pFly, "Velocity Speed", 5, 1, 20, function(lvl) end)

local pWalk = createSectionCard(tabs.Player.Container, "WalkSpeed", 3)
createToggleSwitch(pWalk, "Bypass Speed", function(v) end)
createLevelControl(pWalk, "Speed Level", 1, 1, 20, function(lvl) end)

local pJump = createSectionCard(tabs.Player.Container, "Jump", 4)
createToggleSwitch(pJump, "Bypass Jump", function(v) end)
createLevelControl(pJump, "Power Level", 5, 1, 20, function(lvl) end)

local pDefense = createSectionCard(tabs.Player.Container, "Defense", 5)
createToggleSwitch(pDefense, "Anti-AFK Core System", function(state) end)
createToggleSwitch(pDefense, "Anti-Fling Shield Mode", function(state) end)
createToggleSwitch(pDefense, "Anti-Stun Ragdoll Lock", function(state) end)
createToggleSwitch(pDefense, "Invisible Mode Glitch", function(state) end)

-- ====================================================================
-- TAB 2: ESP SYSTEM (UI ONLY)
-- ====================================================================
local espSec = createSectionCard(tabs.ESP.Container, "Visual Monitor Configurations", 1)
createToggleSwitch(espSec, "Master Activation ESP", function(v) end)
createToggleSwitch(espSec, "Show Tag Names", function(v) end)
createToggleSwitch(espSec, "Show Distance Meter", function(v) end)
createToggleSwitch(espSec, "Show Health Monitor", function(v) end)

local colorSec = createSectionCard(tabs.ESP.Container, "🎨 ESP Color Palette Selection", 2)
local colorsData = {
    {Name = "🔵 Cyber Blue Soft", Color = Color3.fromRGB(115, 170, 255)},
    {Name = "🟣 Orchid Purple Soft", Color = Color3.fromRGB(190, 130, 255)},
    {Name = "🔴 Crimson Hell", Color = Color3.fromRGB(255, 90, 90)},
    {Name = "🟡 Golden Honey", Color = Color3.fromRGB(255, 210, 100)},
    {Name = "⚪ Absolute White", Color = Color3.fromRGB(255, 255, 255)}
}
for _, c in ipairs(colorsData) do
    local cb = Instance.new("TextButton", colorSec) cb.Size = UDim2.new(1, 0, 0, 18) cb.BackgroundTransparency = 1 cb.Font = Enum.Font.GothamMedium cb.Text = c.Name cb.TextColor3 = Theme.TextMain cb.TextSize = 11 cb.TextXAlignment = Enum.TextXAlignment.Left
    cb.MouseButton1Click:Connect(function() 
        for _, v in pairs(colorSec:GetChildren()) do if v:IsA("TextButton") then v.TextColor3 = Theme.TextMain end end cb.TextColor3 = Theme.Accent 
    end)
end

-- ====================================================================
-- TAB 3: TELEPORT HUB (UI ONLY)
-- ====================================================================
local configTpSec = createSectionCard(tabs.Teleport.Container, "Engine Settings", 1)
createToggleSwitch(configTpSec, "Use Tween Movement (Anti-Cheat)", function(state) end)

local gotoSec = createSectionCard(tabs.Teleport.Container, "Goto Player Tracker", 2)
createStandardButton(gotoSec, "🎯 Teleport to Locked Target", function() end)

local listUserSec = createSectionCard(tabs.Teleport.Container, "👥 Target Player Selector List", 3)
local listContainerFix = Instance.new("Frame", listUserSec) listContainerFix.Size = UDim2.new(1,0,0,110) listContainerFix.BackgroundTransparency = 1
local pListScroll = Instance.new("ScrollingFrame", listContainerFix) pListScroll.Size = UDim2.new(1, 0, 1, 0) pListScroll.BackgroundTransparency = 1 pListScroll.CanvasSize = UDim2.new(0,0,0,0) pListScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y pListScroll.ScrollBarThickness = 2 pListScroll.ScrollBarImageColor3 = Theme.Accent local pListLayout = Instance.new("UIListLayout", pListScroll) pListLayout.Padding = UDim.new(0, 4)

local function rebuildPlayerList()
    for _, child in pairs(pListScroll:GetChildren()) do if child:IsA("TextButton") then child:Destroy() end end
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= Player then
            local pBtn = Instance.new("TextButton", pListScroll) pBtn.Size = UDim2.new(1, -6, 0, 20) pBtn.BackgroundColor3 = Theme.Bg pBtn.BackgroundTransparency = 0.4 pBtn.Font = Enum.Font.GothamMedium pBtn.Text = "  " .. p.Name pBtn.TextColor3 = (GlobalTargetName == p.Name) and Theme.Accent or Theme.TextMain pBtn.TextSize = 11 pBtn.TextXAlignment = Enum.TextXAlignment.Left
            Instance.new("UICorner", pBtn).CornerRadius = UDim.new(0, 4) Instance.new("UIStroke", pBtn).Color = Theme.Stroke
            pBtn.MouseButton1Click:Connect(function() GlobalTargetName = p.Name rebuildPlayerList() end)
        end
    end
end
rebuildPlayerList() Players.PlayerAdded:Connect(rebuildPlayerList) Players.PlayerRemoving:Connect(rebuildPlayerList)

local wpSec = createSectionCard(tabs.Teleport.Container, "Map Waypoints Vectors (1-5)", 4)
local function createWpRow(slotKey, labelDisplayName)
    local row = Instance.new("Frame", wpSec) row.Size = UDim2.new(1, 0, 0, 26) row.BackgroundTransparency = 1
    local label = Instance.new("TextLabel", row) label.Text = "📌 " .. labelDisplayName label.Font = Enum.Font.GothamMedium label.TextColor3 = Theme.TextMain label.TextSize = 12 label.Size = UDim2.new(0.5, 0, 1, 0) label.TextXAlignment = Enum.TextXAlignment.Left label.BackgroundTransparency = 1
    local btnSave = Instance.new("TextButton", row) btnSave.Text = "Save" btnSave.Size = UDim2.new(0, 46, 0, 20) btnSave.Position = UDim2.new(0.64, 0, 0.5, -10) btnSave.BackgroundColor3 = Theme.Bg btnSave.TextColor3 = Theme.AccentPurple btnSave.Font = Enum.Font.GothamBold btnSave.TextSize = 10 Instance.new("UICorner", btnSave).CornerRadius = UDim.new(0, 4) Instance.new("UIStroke", btnSave).Color = Theme.Stroke
    local btnTp = Instance.new("TextButton", row) btnTp.Text = "TP" btnTp.Size = UDim2.new(0, 36, 0, 20) btnTp.Position = UDim2.new(0.86, 0, 0.5, -10) btnTp.BackgroundColor3 = Theme.Bg btnTp.TextColor3 = Theme.Accent btnTp.Font = Enum.Font.GothamBold btnTp.TextSize = 10 Instance.new("UICorner", btnTp).CornerRadius = UDim.new(0, 4) Instance.new("UIStroke", btnTp).Color = Theme.Stroke
    
    btnSave.MouseButton1Click:Connect(function() end)
    btnTp.MouseButton1Click:Connect(function() end)
end
createWpRow("WP1", "WP Slot 1")
createWpRow("WP2", "WP Slot 2")
createWpRow("WP3", "WP Slot 3")
createWpRow("WP4", "WP Slot 4")
createWpRow("WP5", "WP Slot 5")

-- ====================================================================
-- TAB 4: WORLD MODULE (UI ONLY)
-- ====================================================================
local worldSec = createSectionCard(tabs.World.Container, "Server Connection Manager", 1)
createStandardButton(worldSec, "⚡ Instant Rejoin Server", function() end)
createStandardButton(worldSec, "🚀 Auto Server Hop (Low Player)", function() end)

-- ====================================================================
-- TAB 5: UTILITIES MODULE (UI ONLY)
-- ====================================================================
local actSec = createSectionCard(tabs.Utilities.Container, "Interactivity Exploits", 1)
createStandardButton(actSec, "🚀 Fling Target (Brutal Spin v3)", function() end)
createStandardButton(actSec, "🛑 Stop Fling (Unfling Manual)", function() end)
createToggleSwitch(actSec, "Headsit Target Follower", function(state) end)

local utilSec2 = createSectionCard(tabs.Utilities.Container, "Structural Tools Automation", 2)
createStandardButton(utilSec2, "🎒 Replicate Target Backpack Tools", function() end)
createStandardButton(utilSec2, "🎒 Sweep Map Tools to Inventory", function() end)

-- ====================================================================
-- TAB 6: SETTINGS MODULE (UI ONLY)
-- ====================================================================
local setSec = createSectionCard(tabs.Settings.Container, "Dashboard Configuration", 1)
createStandardButton(setSec, "🔄 Quick Reload Script Hub", function() end)
createStandardButton(setSec, "🔴 Self-Destroy System UI", function() 
    MainGui:Destroy() 
end)

print("[AR FRAMEWORK]: Template UI Deployed Successfully with No Functions!")
