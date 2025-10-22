--!strict
--[[
	@project OVHL_OJOL
	@file Bootstrapper.lua (v2.0 FIXED + SOP Logging v1.0)
]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Core = ReplicatedStorage.Core
local Services = Core.Server.Services
local Shared = Core.Shared -- Kita butuh Config buat ambil versi
local Config = require(Shared.Config) -- Ambil versi dari sini!

local ServiceManager = require(Services.ServiceManager)
local SystemMonitor = require(Services.SystemMonitor)

local Bootstrapper = {}
Bootstrapper.CoreServices = { "EventService", "DataService", "StyleService", "ZoneService" }
Bootstrapper.ModulesPath = Core.Server.Modules
local OS_PREFIX = "[OVHL OS ENTERPRISE v"..Config.version.."] " -- PREFIX BARU!

function Bootstrapper:Start()
	local startTime = os.clock()
	-- PRINT BARU 1: Kasih tau OS lagi nyala
	print(OS_PREFIX .. "Server proses booting...")

	local serviceManager = ServiceManager.new()
	-- Initialize SystemMonitor DULUAN, baru pake Log
	SystemMonitor:Initialize(serviceManager)
	serviceManager:Register("ServiceManager", serviceManager)
	serviceManager:Register("SystemMonitor", SystemMonitor)

	-- Sekarang SystemMonitor udah siap, baru kita pake Log
	SystemMonitor:Log("Bootstrapper", "INFO", "CORE_BOOT_START", "SystemMonitor initialized, Core OS memulai proses booting...")


	self:_LoadCoreServices(serviceManager)
	self:_DiscoverAndLoadModules(serviceManager)
	serviceManager:StartAll()

	local bootTime = (os.clock() - startTime) * 1000
	SystemMonitor:Log("Bootstrapper", "INFO", "CORE_BOOT_SUCCESS", ("OVHL Core OS berhasil dimuat dalam %.2f ms."):format(bootTime))

	-- PRINT BARU 2: Kasih tau OS udah SIAP!
	print(OS_PREFIX .. "Server 100% SIAP!")
end

-- (Sisa fungsi _LoadCoreServices dan _DiscoverAndLoadModules SAMA PERSIS kayak versi v1.1 yang sukses tadi)
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
			SystemMonitor:Log("Bootstrapper", "DEBUG", "MODULE_FOUND", ("Folder modul ditemukan: %s"):format(moduleFolder.Name))
			local manifestModule = moduleFolder:FindFirstChild("manifest")
			if manifestModule and manifestModule:IsA("ModuleScript") then
				local status, manifest = pcall(require, manifestModule)
				if status and typeof(manifest) == "table" then
					local handlerModule = moduleFolder:FindFirstChild("Handler")
					if handlerModule and handlerModule:IsA("ModuleScript") then
						serviceManager:RegisterModule(manifest, handlerModule)
						SystemMonitor:Log("Bootstrapper", "INFO", "MODULE_REGISTERED", ("Modul '%s' berhasil didaftarkan."):format(manifest.name))
					else
						SystemMonitor:Log("Bootstrapper", "WARN", "HANDLER_NOT_FOUND", ("Modul '%s' punya manifest tapi tidak punya Handler.lua, skipping."):format(moduleFolder.Name))
					end
				else
					SystemMonitor:Log("Bootstrapper", "WARN", "MANIFEST_LOAD_FAIL", ("Gagal load manifest untuk modul '%s'. Pesan: %s"):format(moduleFolder.Name, tostring(manifest)))
				end
			else
				-- Ini bukan modul server, mungkin .gitkeep? Skip tanpa warning.
				-- SystemMonitor:Log("Bootstrapper", "WARN", "MANIFEST_NOT_FOUND", ("Folder '%s' tidak punya manifest.lua, skipping."):format(moduleFolder.Name))
			end
		end
	end
	SystemMonitor:Log("Bootstrapper", "INFO", "MODULE_DISCOVERY_DONE", "Penemuan modul selesai.")
end


return Bootstrapper
