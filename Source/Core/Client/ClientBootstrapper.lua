--!strict
--[[
	@project OVHL_OJOL
	@file ClientBootstrapper.lua
	@author OmniverseHighland + AI Co-Dev System
	@version 1.0.2
	
	@description
	Entry point client. Versi ini menambahkan inisialisasi
	untuk OrderController.
]]

local Core = game:GetService("ReplicatedStorage"):WaitForChild("Core")

-- Client Services
local UIManager = require(Core.Client.Services.UIManager)

-- Client Controllers
local PlayerDataController = require(Core.Client.Controllers.PlayerDataController)
local OrderController = require(Core.Client.Controllers.OrderController)

-- Client UI Modules
local MainHUD = require(Core.Client.UI.MainHUD)

local ClientBootstrapper = {}

function ClientBootstrapper:Start()
	print("🚀 [ClientBootstrapper] Memulai inisialisasi sisi client...")
	
	local dependencies = {
		UIManager = UIManager,
	}
	
	-- 1. Inisialisasi Service Client
	UIManager:Init()
	
	-- 2. Inisialisasi Controller
	PlayerDataController:Init(dependencies)
	OrderController:Init(dependencies) -- Inisialisasi controller baru
	
	-- 3. Inisialisasi Modul UI
	MainHUD:Init(dependencies)
	
	print("✅ [ClientBootstrapper] Inisialisasi client selesai.")
end

return ClientBootstrapper
