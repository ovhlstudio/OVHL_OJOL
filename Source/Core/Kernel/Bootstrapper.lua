--!strict
--[[
	@project OVHL_OJOL
	@file Bootstrapper.lua
	@author OmniverseHighland + AI Co-Dev System
	@version 1.1.1
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Core = ReplicatedStorage.Core
local Services = Core.Server.Services
local ServiceManager = require(Services.ServiceManager)
local SystemMonitor = require(Services.SystemMonitor)
local Bootstrapper = {}
Bootstrapper.CoreServices = { "EventService", "DataService", "StyleService", "ZoneService" }
Bootstrapper.ModulesPath = Core.Server.Modules

function Bootstrapper:Start()
	local startTime = os.clock()
	SystemMonitor:Log("Bootstrapper", "INFO", "CORE_BOOT_START", "OVHL Core OS memulai proses booting...")
	local serviceManager = ServiceManager.new()
	SystemMonitor:Initialize(serviceManager)
	serviceManager:Register("ServiceManager", serviceManager)
	serviceManager:Register("SystemMonitor", SystemMonitor)
	self:_LoadCoreServices(serviceManager)
	self:_DiscoverAndLoadModules(serviceManager)
	serviceManager:StartAll()
	local bootTime = (os.clock() - startTime) * 1000
	SystemMonitor:Log("Bootstrapper", "INFO", "CORE_BOOT_SUCCESS", ("OVHL Core OS berhasil dimuat dalam %.2f ms."):format(bootTime))
end

function Bootstrapper:_LoadCoreServices(serviceManager: any)
	SystemMonitor:Log("Bootstrapper", "INFO", "CORE_SERVICE_LOAD", "Memuat Core Services...")
	for _, serviceName in ipairs(self.CoreServices) do
		local serviceModule = Services:FindFirstChild(serviceName)
		if serviceModule and serviceModule:IsA("ModuleScript") then
			local status, serviceInstance = pcall(function() return require(serviceModule).new(serviceManager) end)
			if status and serviceInstance then
				serviceManager:Register(serviceName, serviceInstance)
				SystemMonitor:Log("Bootstrapper", "INFO", "REGISTER_SUCCESS", ("Service '%s' berhasil dimuat."):format(serviceName))
			else
				SystemMonitor:Log("Bootstrapper", "ERROR", "REGISTER_FAIL", ("Gagal menginisialisasi Core Service '%s'. Pesan: %s"):format(serviceName, tostring(serviceInstance)))
			end
		else
			SystemMonitor:Log("Bootstrapper", "ERROR", "SERVICE_NOT_FOUND", ("Core Service '%s' tidak ditemukan."):format(serviceName))
		end
	end
end

function Bootstrapper:_DiscoverAndLoadModules(serviceManager: any)
	SystemMonitor:Log("Bootstrapper", "INFO", "MODULE_DISCOVERY", "Memulai penemuan modul...")
	for _, moduleFolder in ipairs(self.ModulesPath:GetChildren()) do
		if moduleFolder:IsA("Folder") then
			local manifestModule = moduleFolder:FindFirstChild("manifest")
			if manifestModule and manifestModule:IsA("ModuleScript") then
				local status, manifest = pcall(require, manifestModule)
				if status and typeof(manifest) == "table" then
					local handlerModule = moduleFolder:FindFirstChild("Handler")
					if handlerModule and handlerModule:IsA("ModuleScript") then
						serviceManager:RegisterModule(manifest, handlerModule)
						SystemMonitor:Log("Bootstrapper", "INFO", "MODULE_REGISTERED", ("Modul '%s' berhasil didaftarkan."):format(manifest.name))
					end
				end
			end
		end
	end
end

return Bootstrapper
