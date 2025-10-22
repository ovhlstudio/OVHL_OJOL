--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Core = ReplicatedStorage:WaitForChild("Core")
local UIManager = require(Core.Client.Services.UIManager)
local PlayerDataController = require(Core.Client.Controllers.PlayerDataController)
local MainHUD = require(Core.Client.UI.MainHUD)
local OrderController = require(Core.Client.Controllers.OrderController)
local DevUITester = require(Core.Client.Modules.DevUITester.Main)
local AdminPanel = require(Core.Client.Modules.AdminPanel.Main)

local ClientBootstrapper = {}

function ClientBootstrapper:Start()
    print("🚀 [ClientBootstrapper] Memulai inisialisasi sisi client...")
    
    -- Initialize UIManager first
    UIManager:Init()
    
    -- Initialize controllers
    PlayerDataController:Init({})
    
    local dependencies = {
        UIManager = UIManager
    }
    
    MainHUD:Init(dependencies)
    OrderController:Init(dependencies)
    DevUITester:Init(dependencies)
    AdminPanel:Init(dependencies)
    
    print("✅ [ClientBootstrapper] Inisialisasi client selesai.")
end

return ClientBootstrapper
