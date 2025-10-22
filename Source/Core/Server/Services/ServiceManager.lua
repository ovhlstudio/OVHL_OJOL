--!strict
--[[ @project OVHL_OJOL @file ServiceManager.lua (v2.0 FIXED) ]]
local ServiceManager = {}
ServiceManager.__index = ServiceManager

function ServiceManager.new()
	local self = setmetatable({}, ServiceManager)
	self.services = {}
	self.modules = {}
	self.SystemMonitor = nil -- Di-inject di Bootstrapper
	return self
end

function ServiceManager:Register(name: string, instance: any)
	if self.services[name] then
		self:Get("SystemMonitor"):Log("ServiceManager", "WARN", "DUPLICATE_REGISTER", ("Service '%s' sudah terdaftar."):format(name))
		return
	end
	self.services[name] = instance
end

function ServiceManager:RegisterModule(manifest: table, handlerModule: ModuleScript)
	if self.modules[manifest.name] then
		self:Get("SystemMonitor"):Log("ServiceManager", "WARN", "DUPLICATE_MODULE", ("Modul '%s' sudah terdaftar."):format(manifest.name))
		return
	end
	local moduleInstance = { manifest = manifest, handler = require(handlerModule), isStarted = false }
	self.modules[manifest.name] = moduleInstance
	self:Get("SystemMonitor"):Log("ServiceManager", "DEBUG", "MODULE_REGISTERED", ("Modul '%s' terdaftar"):format(manifest.name))
end

function ServiceManager:Get(name: string)
	local service = self.services[name]
	if not service then
		warn(("[ServiceManager] Peringatan: Service '%s' tidak ditemukan."):format(name))
	end
	return service
end

function ServiceManager:StartAll()
	local SystemMonitor = self:Get("SystemMonitor")
	SystemMonitor:Log("ServiceManager", "INFO", "START_ALL", "Memulai semua service dan modul...")

	-- Context table untuk dependency injection ke modul (INI DIA PERBAIKANNYA!)
	local context = {}
	for name, service in pairs(self.services) do
		context[name] = service
	end

	-- Jalankan Init() pada semua service DULU
	for name, service in pairs(self.services) do
		if typeof(service.Init) == "function" then
			local status, err = pcall(service.Init, service)
			if not status then
				SystemMonitor:Log("ServiceManager", "ERROR", "SERVICE_INIT_FAIL", ("Gagal Init() service '%s': %s"):format(name, err))
			else
				SystemMonitor:Log("ServiceManager", "DEBUG", "SERVICE_INIT_SUCCESS", ("Service '%s' di-init"):format(name))
			end
		end
	end

	-- Baru jalankan init() pada semua modul (inject context table)
	for name, module in pairs(self.modules) do
		SystemMonitor:Log("ServiceManager", "DEBUG", "MODULE_START_ATTEMPT", ("Mencoba memulai modul '%s'"):format(name))
		if typeof(module.handler.init) == "function" then
			local canStart = true
			if module.manifest.depends then
				for _, depName in ipairs(module.manifest.depends) do
					if not self.services[depName] then
						SystemMonitor:Log("ServiceManager", "ERROR", "MODULE_DEP_MISSING", ("Gagal memulai '%s', dependensi '%s' tidak ditemukan."):format(name, depName))
						canStart = false; break
					end
				end
			end
			if canStart then
				SystemMonitor:Log("ServiceManager", "DEBUG", "MODULE_STARTING", ("Memulai modul '%s'..."):format(name))
				-- Inject 'context' table, BUKAN 'self'!
				local status, err = pcall(module.handler.init, module.handler, context)
				if not status then
					SystemMonitor:Log("ServiceManager", "ERROR", "MODULE_INIT_FAIL", ("Gagal init() modul '%s': %s"):format(name, err))
				else
					module.isStarted = true
					SystemMonitor:Log("ServiceManager", "INFO", "MODULE_START_SUCCESS", ("Modul '%s' berhasil dimulai"):format(name))
				end
			end
		else
			SystemMonitor:Log("ServiceManager", "ERROR", "MODULE_NO_INIT", ("Modul '%s' tidak punya function init()"):format(name))
		end
	end
	SystemMonitor:Log("ServiceManager", "INFO", "START_ALL_COMPLETE", "Proses startup selesai.")
end

return ServiceManager
