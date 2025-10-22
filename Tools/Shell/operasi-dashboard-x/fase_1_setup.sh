#!/bin/bash

echo "🚀 FASE 1: Setup Structure & Enhanced UIManager"

# Create enhanced UIManager
mkdir -p Source/Core/Client/Services
cat > Source/Core/Client/Services/UIManager.lua << 'EOF'
--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Events = ReplicatedStorage:WaitForChild("OVHL_Events")
local TweenService = game:GetService("TweenService")
local UIManager = {}
local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
local activeTheme: any
local screens = {}

function UIManager:Init() 
    local getThemeFunc:RemoteFunction=Events:WaitForChild("GetActiveTheme",10) 
    if getThemeFunc then 
        activeTheme=getThemeFunc:InvokeServer() 
    end 
end

function UIManager:CreateScreen(sn) 
    if screens[sn] then return screens[sn] end 
    local sg=Instance.new("ScreenGui") 
    sg.Name=sn 
    sg.ResetOnSpawn=false 
    sg.Parent=playerGui 
    screens[sn]=sg 
    return sg 
end

function UIManager:CreateWindow(o) 
    local f=Instance.new("Frame")
    f.Name=o.Name 
    f.Size=o.Size 
    f.Position=o.Position 
    f.AnchorPoint=o.AnchorPoint or Vector2.new(0,0) 
    f.BorderSizePixel=0 
    if o.Style=="HUD" then 
        f.BackgroundColor3=activeTheme.Colors.BackgroundHUD 
    else 
        f.BackgroundColor3=activeTheme.Colors.Background 
    end
    f.BackgroundTransparency=0.2 
    local c=Instance.new("UICorner")
    c.CornerRadius=UDim.new(0,8) 
    c.Parent=f 
    f.Parent=o.Parent 
    return f 
end

function UIManager:AddTextLabel(o) 
    local l=Instance.new("TextLabel")
    l.Name=o.Name 
    l.Text=o.Text 
    l.Size=o.Size 
    l.Position=o.Position or UDim2.fromScale(0,0) 
    l.AnchorPoint=o.AnchorPoint or Vector2.new(0,0) 
    l.TextXAlignment=o.TextXAlignment or Enum.TextXAlignment.Left 
    l.BackgroundTransparency=1 
    if o.Style=="HUD" then 
        l.Font=activeTheme.Fonts.Header 
        l.TextSize=activeTheme.FontSizes.HUD 
    else 
        l.Font=activeTheme.Fonts.Body 
        l.TextSize=o.TextSize or activeTheme.FontSizes.Body 
    end
    l.TextColor3=activeTheme.Colors.TextPrimary 
    l.Parent=o.Parent 
    return l 
end

function UIManager:AddButton(o) 
    local b=Instance.new("TextButton")
    b.Name=o.Name 
    b.Text=o.Text 
    b.Size=o.Size 
    b.Position=o.Position 
    b.AnchorPoint=o.AnchorPoint or Vector2.new(0,0) 
    if o.Name=="AcceptButton" then 
        b.BackgroundColor3=activeTheme.Colors.Confirm 
    elseif o.Name=="DeclineButton" then 
        b.BackgroundColor3=activeTheme.Colors.Decline 
    else 
        b.BackgroundColor3=activeTheme.Colors.Accent 
    end
    b.Font=activeTheme.Fonts.Body 
    b.TextColor3=activeTheme.Colors.TextPrimary 
    b.TextSize=activeTheme.FontSizes.Button 
    local c=Instance.new("UICorner")
    c.CornerRadius=UDim.new(0,6) 
    c.Parent=b 
    b.Parent=o.Parent 
    return b 
end

-- NEW COMPONENTS FOR ADMIN PANEL
function UIManager:AddTextBox(o)
    local tb = Instance.new("TextBox")
    tb.Name = o.Name
    tb.PlaceholderText = o.Placeholder or ""
    tb.Text = o.Text or ""
    tb.Size = o.Size
    tb.Position = o.Position
    tb.AnchorPoint = o.AnchorPoint or Vector2.new(0,0)
    tb.BackgroundColor3 = activeTheme.Colors.Surface
    tb.TextColor3 = activeTheme.Colors.TextPrimary
    tb.Font = activeTheme.Fonts.Body
    tb.TextSize = o.TextSize or activeTheme.FontSizes.Body
    tb.ClearTextOnFocus = false
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0,4)
    corner.Parent = tb
    
    local padding = Instance.new("UIPadding")
    padding.PaddingLeft = UDim.new(0,8)
    padding.PaddingRight = UDim.new(0,8)
    padding.Parent = tb
    
    tb.Parent = o.Parent
    return tb
end

function UIManager:AddDropdown(o)
    local container = Instance.new("Frame")
    container.Name = o.Name
    container.Size = o.Size
    container.Position = o.Position
    container.AnchorPoint = o.AnchorPoint or Vector2.new(0,0)
    container.BackgroundColor3 = activeTheme.Colors.Surface
    container.BackgroundTransparency = 1
    
    local button = Instance.new("TextButton")
    button.Name = "DropdownButton"
    button.Size = UDim2.fromScale(1, 1)
    button.Position = UDim2.fromScale(0, 0)
    button.BackgroundColor3 = activeTheme.Colors.Surface
    button.TextColor3 = activeTheme.Colors.TextPrimary
    button.Font = activeTheme.Fonts.Body
    button.TextSize = activeTheme.FontSizes.Body
    button.Text = o.Default or "Select..."
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0,4)
    corner.Parent = button
    
    local padding = Instance.new("UIPadding")
    padding.PaddingLeft = UDim.new(0,8)
    padding.PaddingRight = UDim.new(0,8)
    padding.Parent = button
    
    button.Parent = container
    container.Parent = o.Parent
    
    return container
end

function UIManager:AddSlider(o)
    local container = Instance.new("Frame")
    container.Name = o.Name
    container.Size = o.Size
    container.Position = o.Position
    container.AnchorPoint = o.AnchorPoint or Vector2.new(0,0)
    container.BackgroundTransparency = 1
    
    local track = Instance.new("Frame")
    track.Name = "Track"
    track.Size = UDim2.new(1, 0, 0.3, 0)
    track.Position = UDim2.new(0, 0, 0.5, 0)
    track.AnchorPoint = Vector2.new(0, 0.5)
    track.BackgroundColor3 = activeTheme.Colors.Surface
    track.BorderSizePixel = 0
    
    local fill = Instance.new("Frame")
    fill.Name = "Fill"
    fill.Size = UDim2.new(0.5, 0, 1, 0)
    fill.Position = UDim2.new(0, 0, 0, 0)
    fill.BackgroundColor3 = activeTheme.Colors.Primary
    fill.BorderSizePixel = 0
    
    local thumb = Instance.new("Frame")
    thumb.Name = "Thumb"
    thumb.Size = UDim2.new(0, 20, 1.5, 0)
    thumb.Position = UDim2.new(0.5, -10, 0.5, 0)
    thumb.AnchorPoint = Vector2.new(0, 0.5)
    thumb.BackgroundColor3 = activeTheme.Colors.Accent
    thumb.BorderSizePixel = 0
    
    local cornerTrack = Instance.new("UICorner")
    cornerTrack.CornerRadius = UDim.new(0,4)
    cornerTrack.Parent = track
    
    local cornerFill = Instance.new("UICorner")
    cornerFill.CornerRadius = UDim.new(0,4)
    cornerFill.Parent = fill
    
    local cornerThumb = Instance.new("UICorner")
    cornerThumb.CornerRadius = UDim.new(1,0)
    cornerThumb.Parent = thumb
    
    fill.Parent = track
    thumb.Parent = track
    track.Parent = container
    
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Name = "ValueLabel"
    valueLabel.Size = UDim2.new(1, 0, 0.4, 0)
    valueLabel.Position = UDim2.new(0, 0, 0, 0)
    valueLabel.BackgroundTransparency = 1
    valueLabel.TextColor3 = activeTheme.Colors.TextSecondary
    valueLabel.Font = activeTheme.Fonts.Body
    valueLabel.TextSize = activeTheme.FontSizes.Body - 2
    valueLabel.Text = tostring(o.Default or 0)
    valueLabel.TextXAlignment = Enum.TextXAlignment.Center
    valueLabel.Parent = container
    
    container.Parent = o.Parent
    return container
end

function UIManager:AddCheckbox(o)
    local container = Instance.new("Frame")
    container.Name = o.Name
    container.Size = o.Size
    container.Position = o.Position
    container.AnchorPoint = o.AnchorPoint or Vector2.new(0,0)
    container.BackgroundTransparency = 1
    
    local box = Instance.new("Frame")
    box.Name = "Checkbox"
    box.Size = UDim2.new(0, 20, 0, 20)
    box.Position = UDim2.new(0, 0, 0.5, 0)
    box.AnchorPoint = Vector2.new(0, 0.5)
    box.BackgroundColor3 = activeTheme.Colors.Surface
    box.BorderSizePixel = 0
    
    local check = Instance.new("ImageLabel")
    check.Name = "Check"
    check.Size = UDim2.new(0.7, 0, 0.7, 0)
    check.Position = UDim2.new(0.5, 0, 0.5, 0)
    check.AnchorPoint = Vector2.new(0.5, 0.5)
    check.BackgroundTransparency = 1
    check.Image = "rbxassetid://10734948227" -- Check icon
    check.Visible = o.Checked or false
    
    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.new(1, -30, 1, 0)
    label.Position = UDim2.new(0, 25, 0, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = activeTheme.Colors.TextPrimary
    label.Font = activeTheme.Fonts.Body
    label.TextSize = activeTheme.FontSizes.Body
    label.Text = o.Text or ""
    label.TextXAlignment = Enum.TextXAlignment.Left
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0,4)
    corner.Parent = box
    
    check.Parent = box
    box.Parent = container
    label.Parent = container
    container.Parent = o.Parent
    
    return container
end

function UIManager:CreateMissionTracker(orderData) 
    local s=self:CreateScreen("MissionUI") 
    if s:FindFirstChild("MissionTracker") then s.MissionTracker:Destroy() end 
    local tW=self:CreateWindow({Parent=s,Name="MissionTracker",Size=UDim2.new(0.25,0,0.1,0),Position=UDim2.new(0.5,0,0.9,0),AnchorPoint=Vector2.new(0.5,1)}) 
    self:AddTextLabel({Parent=tW,Name="ObjectiveLabel",Text="Tujuan: "..orderData.to,Size=UDim2.fromScale(0.9,0.8),Position=UDim2.fromScale(0.5,0.5),AnchorPoint=Vector2.new(0.5,0.5),TextXAlignment=Enum.TextXAlignment.Center,TextSize=18}) 
end

function UIManager:DestroyMissionTracker() 
    local s=screens["MissionUI"] 
    if s and s:FindFirstChild("MissionTracker") then s.MissionTracker:Destroy() end 
end

function UIManager:ShowToastNotification(message: string, duration: number?)
    local screen = self:CreateScreen("NotificationUI")
    local toast = self:CreateWindow({
        Parent = screen,
        Name = "ToastNotification",
        Size = UDim2.new(0.3, 0, 0.1, 0),
        Position = UDim2.new(0.5, 0, -0.1, 0),
        AnchorPoint = Vector2.new(0.5, 0),
        Style = "HUD",
    })
    self:AddTextLabel({
        Parent = toast,
        Name = "ToastLabel",
        Text = message,
        Size = UDim2.fromScale(1, 1),
        TextXAlignment = Enum.TextXAlignment.Center,
        Style = "HUD",
    })
    
    local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
    local goalIn = {Position = UDim2.new(0.5, 0, 0.05, 0)}
    local goalOut = {Position = UDim2.new(0.5, 0, -0.1, 0)}
    
    TweenService:Create(toast, tweenInfo, goalIn):Play()
    task.wait(duration or 3)
    TweenService:Create(toast, tweenInfo, goalOut):Play()
    task.wait(0.5)
    toast:Destroy()
end

return UIManager
EOF

echo "✅ FASE 1 SELESAI: Enhanced UIManager dengan 4 components baru"
echo "📝 TEST INSTRUCTION: Rojo build & check di Studio - UIManager harus ada methods baru"
echo "🚀 LANJUT KE FASE 2: ./Tools/operasi-dashboard-x/fase_2_devtester.sh"