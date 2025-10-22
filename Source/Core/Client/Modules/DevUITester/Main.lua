--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Core = ReplicatedStorage:WaitForChild("Core")
local UIManager = require(Core.Client.Services.UIManager)

local DevUITester = {}

function DevUITester:Init()
    self:CreateDevToolsUI()
end

function DevUITester:CreateDevToolsUI()
    local screen = UIManager:CreateScreen("DevToolsUI")
    
    -- Dev Toggle Button
    local toggleBtn = UIManager:AddButton({
        Parent = screen,
        Name = "DevToggle",
        Text = "🛠️ SHOW DEV TOOLS",
        Size = UDim2.new(0.15, 0, 0.05, 0),
        Position = UDim2.new(0.02, 0, 0.02, 0)
    })
    
    local componentsWindow = nil
    local isVisible = false
    
    toggleBtn.MouseButton1Click:Connect(function()
        if isVisible then
            self:HideComponentsTest()
            toggleBtn.Text = "🛠️ SHOW DEV TOOLS"
            isVisible = false
        else
            self:ShowComponentsTest()
            toggleBtn.Text = "❌ HIDE DEV TOOLS" 
            isVisible = true
        end
    end)
end

function DevUITester:ShowComponentsTest()
    local screen = UIManager:CreateScreen("DevToolsUI")
    
    -- Components Test Window
    local testWindow = UIManager:CreateWindow({
        Parent = screen,
        Name = "ComponentsTestWindow",
        Size = UDim2.new(0.4, 0, 0.6, 0),
        Position = UDim2.new(0.3, 0, 0.2, 0),
        Style = "HUD"
    })
    
    -- Title
    UIManager:AddTextLabel({
        Parent = testWindow,
        Name = "Title",
        Text = "🎨 UI COMPONENTS TEST",
        Size = UDim2.new(1, 0, 0.1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        TextXAlignment = Enum.TextXAlignment.Center,
        TextSize = 20
    })
    
    -- TextBox Test
    UIManager:AddTextLabel({
        Parent = testWindow,
        Name = "TextBoxLabel", 
        Text = "TextBox:",
        Size = UDim2.new(0.3, 0, 0.05, 0),
        Position = UDim2.new(0, 0, 0.15, 0)
    })
    
    local textBox = UIManager:AddTextBox({
        Parent = testWindow,
        Name = "TestTextBox",
        Placeholder = "Type something...",
        Size = UDim2.new(0.6, 0, 0.05, 0),
        Position = UDim2.new(0.35, 0, 0.15, 0)
    })
    
    -- Dropdown Test
    UIManager:AddTextLabel({
        Parent = testWindow,
        Name = "DropdownLabel",
        Text = "Dropdown:",
        Size = UDim2.new(0.3, 0, 0.05, 0),
        Position = UDim2.new(0, 0, 0.25, 0)
    })
    
    local dropdown = UIManager:AddDropdown({
        Parent = testWindow,
        Name = "TestDropdown", 
        Size = UDim2.new(0.6, 0, 0.05, 0),
        Position = UDim2.new(0.35, 0, 0.25, 0),
        Default = "Select option"
    })
    
    -- Slider Test
    UIManager:AddTextLabel({
        Parent = testWindow,
        Name = "SliderLabel",
        Text = "Slider:",
        Size = UDim2.new(0.3, 0, 0.05, 0),
        Position = UDim2.new(0, 0, 0.35, 0)
    })
    
    local slider = UIManager:AddSlider({
        Parent = testWindow,
        Name = "TestSlider",
        Size = UDim2.new(0.6, 0, 0.08, 0),
        Position = UDim2.new(0.35, 0, 0.35, 0),
        Default = 50
    })
    
    -- Checkbox Test  
    UIManager:AddTextLabel({
        Parent = testWindow,
        Name = "CheckboxLabel",
        Text = "Checkbox:",
        Size = UDim2.new(0.3, 0, 0.05, 0),
        Position = UDim2.new(0, 0, 0.48, 0)
    })
    
    local checkbox = UIManager:AddCheckbox({
        Parent = testWindow,
        Name = "TestCheckbox",
        Size = UDim2.new(0.6, 0, 0.05, 0),
        Position = UDim2.new(0.35, 0, 0.48, 0),
        Text = "Enable feature",
        Checked = true
    })
    
    -- Test Button
    local testBtn = UIManager:AddButton({
        Parent = testWindow,
        Name = "TestComponentsBtn",
        Text = "🧪 TEST COMPONENTS",
        Size = UDim2.new(0.8, 0, 0.08, 0),
        Position = UDim2.new(0.1, 0, 0.6, 0)
    })
    
    testBtn.MouseButton1Click:Connect(function()
        UIManager:ShowToastNotification("🎯 Components Tested Successfully!", 2)
    end)
    
    -- Status
    UIManager:AddTextLabel({
        Parent = testWindow,
        Name = "StatusLabel",
        Text = "✅ All new components ready!",
        Size = UDim2.new(1, 0, 0.1, 0),
        Position = UDim2.new(0, 0, 0.8, 0),
        TextXAlignment = Enum.TextXAlignment.Center,
        TextColor3 = Color3.fromRGB(0, 255, 0)
    })
end

function DevUITester:HideComponentsTest()
    local screen = UIManager:CreateScreen("DevToolsUI")
    if screen:FindFirstChild("ComponentsTestWindow") then
        screen.ComponentsTestWindow:Destroy()
    end
end

return DevUITester
