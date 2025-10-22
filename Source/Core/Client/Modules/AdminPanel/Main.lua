--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Core = ReplicatedStorage:WaitForChild("Core")
local UIManager = require(Core.Client.Services.UIManager)
local Events = ReplicatedStorage:WaitForChild("OVHL_Events")

local AdminPanel = {}
local adminScreen = nil
local isAdminPanelVisible = false

function AdminPanel:Init()
    self:CreateAdminAccessButton()
end

function AdminPanel:CreateAdminAccessButton()
    local screen = UIManager:CreateScreen("AdminUI")
    
    -- Hidden admin access button (bisa di-move ke corner)
    local accessBtn = UIManager:AddButton({
        Parent = screen,
        Name = "AdminAccessBtn",
        Text = "⚙️",
        Size = UDim2.new(0, 40, 0, 40),
        Position = UDim2.new(0.95, 0, 0.02, 0),
        AnchorPoint = Vector2.new(1, 0)
    })
    
    accessBtn.MouseButton1Click:Connect(function()
        self:ToggleAdminPanel()
    end)
end

function AdminPanel:ToggleAdminPanel()
    if isAdminPanelVisible then
        self:HideAdminPanel()
    else
        self:ShowAdminPanel()
    end
end

function AdminPanel:ShowAdminPanel()
    adminScreen = UIManager:CreateScreen("AdminUI")
    
    -- Main Admin Window
    local adminWindow = UIManager:CreateWindow({
        Parent = adminScreen,
        Name = "AdminPanel",
        Size = UDim2.new(0.8, 0, 0.8, 0),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Style = "HUD"
    })
    
    -- Title
    UIManager:AddTextLabel({
        Parent = adminWindow,
        Name = "Title",
        Text = "🛠️ OVHL ADMIN PANEL",
        Size = UDim2.new(1, 0, 0.08, 0),
        Position = UDim2.new(0, 0, 0, 0),
        TextXAlignment = Enum.TextXAlignment.Center,
        TextSize = 24
    })
    
    -- Config Editor Section
    UIManager:AddTextLabel({
        Parent = adminWindow,
        Name = "ConfigSectionTitle",
        Text = "⚙️ GAME CONFIG",
        Size = UDim2.new(0.9, 0, 0.05, 0),
        Position = UDim2.new(0.05, 0, 0.1, 0),
        TextSize = 18
    })
    
    -- Economy Multiplier
    UIManager:AddTextLabel({
        Parent = adminWindow,
        Name = "EconomyLabel",
        Text = "Economy Multiplier:",
        Size = UDim2.new(0.3, 0, 0.04, 0),
        Position = UDim2.new(0.05, 0, 0.18, 0)
    })
    
    local economyInput = UIManager:AddTextBox({
        Parent = adminWindow,
        Name = "EconomyInput",
        Placeholder = "1.0",
        Text = "1.0",
        Size = UDim2.new(0.2, 0, 0.04, 0),
        Position = UDim2.new(0.35, 0, 0.18, 0)
    })
    
    -- AI Density
    UIManager:AddTextLabel({
        Parent = adminWindow,
        Name = "AILabel",
        Text = "AI Population:",
        Size = UDim2.new(0.3, 0, 0.04, 0),
        Position = UDim2.new(0.05, 0, 0.25, 0)
    })
    
    local aiInput = UIManager:AddTextBox({
        Parent = adminWindow,
        Name = "AIInput", 
        Placeholder = "0.8",
        Text = "0.8",
        Size = UDim2.new(0.2, 0, 0.04, 0),
        Position = UDim2.new(0.35, 0, 0.25, 0)
    })
    
    -- Module Management Section
    UIManager:AddTextLabel({
        Parent = adminWindow,
        Name = "ModuleSectionTitle",
        Text = "📦 MODULE MANAGEMENT",
        Size = UDim2.new(0.9, 0, 0.05, 0),
        Position = UDim2.new(0.05, 0, 0.35, 0),
        TextSize = 18
    })
    
    -- Reload TestOrder Button
    local reloadTestOrderBtn = UIManager:AddButton({
        Parent = adminWindow,
        Name = "ReloadTestOrderBtn",
        Text = "🔄 Reload TestOrder",
        Size = UDim2.new(0.4, 0, 0.05, 0),
        Position = UDim2.new(0.05, 0, 0.43, 0)
    })
    
    reloadTestOrderBtn.MouseButton1Click:Connect(function()
        self:ReloadModule("TestOrder")
    end)
    
    -- Reload DevUITester Button
    local reloadDevBtn = UIManager:AddButton({
        Parent = adminWindow,
        Name = "ReloadDevBtn", 
        Text = "🔄 Reload DevUITester",
        Size = UDim2.new(0.4, 0, 0.05, 0),
        Position = UDim2.new(0.55, 0, 0.43, 0)
    })
    
    reloadDevBtn.MouseButton1Click:Connect(function()
        self:ReloadModule("DevUITester")
    end)
    
    -- Apply Config Button
    local applyBtn = UIManager:AddButton({
        Parent = adminWindow,
        Name = "ApplyConfigBtn",
        Text = "💾 APPLY CONFIG",
        Size = UDim2.new(0.9, 0, 0.06, 0),
        Position = UDim2.new(0.05, 0, 0.55, 0)
    })
    
    applyBtn.MouseButton1Click:Connect(function()
        self:ApplyConfigChanges({
            economy_multiplier = tonumber(economyInput.Text) or 1.0,
            ai_population_density = tonumber(aiInput.Text) or 0.8
        })
    end)
    
    -- Close Button
    local closeBtn = UIManager:AddButton({
        Parent = adminWindow,
        Name = "CloseAdminBtn",
        Text = "❌ CLOSE ADMIN PANEL", 
        Size = UDim2.new(0.9, 0, 0.06, 0),
        Position = UDim2.new(0.05, 0, 0.85, 0)
    })
    
    closeBtn.MouseButton1Click:Connect(function()
        self:HideAdminPanel()
    end)
    
    isAdminPanelVisible = true
end

function AdminPanel:HideAdminPanel()
    local screen = UIManager:CreateScreen("AdminUI")
    if screen:FindFirstChild("AdminPanel") then
        screen.AdminPanel:Destroy()
    end
    isAdminPanelVisible = false
end

function AdminPanel:ApplyConfigChanges(updates)
    local applyFunc = Events:FindFirstChild("AdminUpdateConfig")
    if applyFunc and applyFunc:IsA("RemoteFunction") then
        local success = applyFunc:InvokeServer(updates)
        if success then
            UIManager:ShowToastNotification("✅ Config updated successfully!", 3)
        else
            UIManager:ShowToastNotification("❌ Failed to update config", 3)
        end
    else
        UIManager:ShowToastNotification("⚠️ Admin features not ready yet", 3)
    end
end

function AdminPanel:ReloadModule(moduleName)
    local reloadFunc = Events:FindFirstChild("AdminReloadModule")
    if reloadFunc and reloadFunc:IsA("RemoteFunction") then
        local success = reloadFunc:InvokeServer(moduleName)
        if success then
            UIManager:ShowToastNotification("✅ " .. moduleName .. " reloaded!", 3)
        else
            UIManager:ShowToastNotification("❌ Failed to reload " .. moduleName, 3)
        end
    else
        UIManager:ShowToastNotification("⚠️ Admin features not ready yet", 3)
    end
end

return AdminPanel
