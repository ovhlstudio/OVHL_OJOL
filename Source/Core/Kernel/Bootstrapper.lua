--!strict
--[[
	@project OVHL_OJOL
	@file Bootstrapper.lua
	@author OmniverseHighland + AI Co-Dev System
	
	@description
	Jantung dari Core OS. Bertugas untuk menemukan, memuat,
	menginisialisasi, dan menjalankan semua service dan modul
	secara terstruktur dan berurutan.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Core = ReplicatedStorage.Core
local Services = Core.Server.Services
local Shared = Core.Shared

local ServiceManager = require(Services.ServiceManager)
local SystemMonitor = require(Services.SystemMonitor)
local Config = require(Shared.Config)

local Bootstrapper = {}
Bootstrapper.CoreServices = {
	"EventService",
	"DataService",
	"StyleService"
}
Bootstrapper.ModulesPath = Core.Server.Modules

function Bootstrapper:Start()
	local startTime = os.clock()
	SystemMonitor:Log("Bootstrapper", "INFO", "CORE_BOOT_START", "OVHL Core OS memulai proses booting...")
	
	-- Langkah 1: Inisialisasi Service Manager & Monitor
	local serviceManager = ServiceManager.new()
	SystemMonitor:Initialize(serviceManager)
	serviceManager:Register("ServiceManager", serviceManager)
	serviceManager:Register("SystemMonitor", SystemMonitor)
	SystemMonitor:Log("Bootstrapper", "INFO", "SERVICE_INIT", "ServiceManager & SystemMonitor berhasil diinisialisasi.")
	
	-- Langkah 2: Muat dan Daftarkan Core Services
	self:_LoadCoreServices(serviceManager)
	
	-- Langkah 3: Temukan dan Daftarkan Modul Gameplay
	self:_DiscoverAndLoadModules(serviceManager)
	
	-- Langkah 4: Jalankan semua service dan modul yang terdaftar
	serviceManager:StartAll()
	
	local bootTime = (os.clock() - startTime) * 1000
	SystemMonitor:Log("Bootstrapper", "INFO", "CORE_BOOT_SUCCESS", ("OVHL Core OS berhasil dimuat dalam %.2f ms."):format(bootTime))
	
	-- TODO: Kirim event ke client bahwa sistem sudah siap
end

function Bootstrapper:_LoadCoreServices(serviceManager: any)
	SystemMonitor:Log("Bootstrapper", "INFO", "CORE_SERVICE_LOAD", "Memuat Core Services...")
	for _, serviceName in ipairs(self.CoreServices) do
		local status, serviceModule = pcall(require, Services[serviceName])
		if status and typeof(serviceModule) == "table" and typeof(serviceModule.new) == "function" then
			local serviceInstance = serviceModule.new(serviceManager)
			serviceManager:Register(serviceName, serviceInstance)
			SystemMonitor:Log("Bootstrapper", "INFO", "REGISTER_SUCCESS", ("Service '%s' berhasil dimuat dan didaftarkan."):format(serviceName))
		else
			SystemMonitor:Log("Bootstrapper", "ERROR", "REGISTER_FAIL", ("Gagal memuat Core Service '%s'. Pesan: %s"):format(serviceName, tostring(serviceModule)))
		end
	end
end

function Bootstrapper:_DiscoverAndLoadModules(serviceManager: any)
	SystemMonitor:Log("Bootstrapper", "INFO", "MODULE_DISCOVERY", "Memulai penemuan modul di " .. self.ModulesPath:GetFullName())
	for _, moduleFolder in ipairs(self.ModulesPath:GetChildren()) do
		if not moduleFolder:IsA("Folder") then continue end
		
		local manifestModule = moduleFolder:FindFirstChild("manifest")
		if manifestModule and manifestModule:IsA("ModuleScript") then
			local status, manifest = pcall(require, manifestModule)
			if status and typeof(manifest) == "table" then
				local handlerModule = moduleFolder:FindFirstChild("Handler")
				if handlerModule and handlerModule:IsA("ModuleScript") then
					serviceManager:RegisterModule(manifest, handlerModule)
					SystemMonitor:Log("Bootstrapper", "INFO", "MODULE_REGISTERED", ("Modul '%s' v%s berhasil didaftarkan."):format(manifest.name, manifest.version))
				else
					SystemMonitor:Log("Bootstrapper", "WARN", "MODULE_NO_HANDLER", ("Modul '%s' memiliki manifest, tapi tidak ditemukan Handler.lua."):format(manifest.name))
				end
			else
				SystemMonitor:Log("Bootstrapper", "WARN", "MODULE_BAD_MANIFEST", ("Gagal membaca manifest untuk modul di folder '%s'."):format(moduleFolder.Name))
			end
		end
	end
end

return Bootstrapper
