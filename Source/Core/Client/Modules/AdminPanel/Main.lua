--!strict
--[[
	@project OVHL_OJOL
	@file Main.lua (AdminPanel)
	@author OmniverseHighland + AI Co-Dev System
	@version 2.0.0
	
	@description
	Client-side logic untuk Admin Panel.
	VERSION 2.0.0: Menghapus hardcode, mengambil config live dari server,
	dan auto-refresh saat config di-update.
]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Core = ReplicatedStorage:WaitForChild("Core")
local UIManager = require(Core.Client.Services.UIManager)
local Events = ReplicatedStorage:WaitForChild("OVHL_Events")

local AdminPanel = {}
local adminScreen = nil
local isAdminPanelVisible = false
local currentConfig = {} -- Cache untuk config
local economyInput: TextBox = nil -- Referensi ke input box
local aiInput: TextBox = nil -- Referensi ke input box

function AdminPanel:Init()
    self:CreateAdminAccessButton()
    
    -- ================================================================
    -- FIX #1: Dengarkan event "ConfigUpdated" dari server
    -- ================================================================
    local configUpdatedEvent = Events:FindFirstChild("ConfigUpdated")
    if configUpdatedEvent and configUpdatedEvent:IsA("RemoteEvent") then
        configUpdatedEvent.OnClientEvent:Connect(function(newConfig)
            self:OnConfigUpdated(newConfig)
        end)
    end
end

function AdminPanel:CreateAdminAccessButton()
    local screen = UIManager:CreateScreen("AdminAccessUI") -- Pisahkan UI tombol
    
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
    if isAdminPanelVisible then return end
    
    adminScreen = UIManager:CreateScreen("AdminPanelUI") -- UI Panel Utama
    
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
    
    economyInput = UIManager:AddTextBox({
        Parent = adminWindow,
        Name = "EconomyInput",
        Placeholder = "Loading...",
        Text = "", -- Akan diisi oleh FetchConfig
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
    
    aiInput = UIManager:AddTextBox({
        Parent = adminWindow,
        Name = "AIInput", 
        Placeholder = "Loading...",
        Text = "", -- Akan diisi oleh FetchConfig
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
    
    -- ================================================================
    -- FIX #2: Ambil config dari server SETELAH UI dibuat
    -- ================================================================
    self:FetchConfig()
end

function AdminPanel:HideAdminPanel()
    local screen = UIManager:CreateScreen("AdminPanelUI")
    if screen:FindFirstChild("AdminPanel") then
        screen.AdminPanel:Destroy()
    end
    isAdminPanelVisible = false
    -- Kosongkan referensi
    economyInput = nil
    aiInput = nil
end

function AdminPanel:FetchConfig()
    -- Ambil config dari server
    local getConfigFunc = Events:FindFirstChild("AdminGetConfig")
    if getConfigFunc and getConfigFunc:IsA("RemoteFunction") then
        local config = getConfigFunc:InvokeServer()
        if config then
            self:OnConfigUpdated(config) -- Gunakan fungsi yang sama untuk update UI
        else
            UIManager:ShowToastNotification("❌ Gagal mengambil config dari server", 3)
        end
    else
        UIManager:ShowToastNotification("⚠️ Fitur admin belum siap (GetConfig)", 3)
    end
end

function AdminPanel:OnConfigUpdated(newConfig: table)
    -- Fungsi ini dipanggil saat pertama kali load ATAU saat ada update
    currentConfig = newConfig
    
    if isAdminPanelVisible and economyInput and aiInput then
        -- Update UI jika panel sedang terbuka
        economyInput.Text = tostring(currentConfig.economy_multiplier or 1.0)
        aiInput.Text = tostring(currentConfig.ai_population_density or 0.8)
        UIManager:ShowToastNotification("🔄 Config berhasil disinkronkan!", 2)
    end
end

function AdminPanel:ApplyConfigChanges(updates)
    local applyFunc = Events:FindFirstChild("AdminUpdateConfig")
    if applyFunc and applyFunc:IsA("RemoteFunction") then
        local success = applyFunc:InvokeServer(updates)
        if success then
            UIManager:ShowToastNotification("✅ Config updated successfully!", 3)
            -- Kita tidak perlu update UI manual di sini,
            -- karena server akan kirim event "ConfigUpdated"
            -- yang akan ditangkap oleh :OnConfigUpdated
        else
            UIManager:ShowToastNotification("❌ Gagal update config", 3)
        end
    else
        UIManager:ShowToastNotification("⚠️ Admin features not ready yet (UpdateConfig)", 3)
    end
end

function AdminPanel:ReloadModule(moduleName)
    local reloadFunc = Events:FindFirstChild("AdminReloadModule")
    if reloadFunc and reloadFunc:IsA("RemoteFunction") then
        local success = reloadFunc:InvokeServer(moduleName)
        if success then
            UIManager:ShowToastNotification("✅ " .. moduleName .. " reload requested!", 3)
        else
            UIManager:ShowToastNotification("❌ Failed to request reload " .. moduleName, 3)
        end
    else
        UIManager:ShowToastNotification("⚠️ Admin features not ready yet (ReloadModule)", 3)
    end
end

return AdminPanel

