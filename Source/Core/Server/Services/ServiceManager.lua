--!strict
--[[
	@project OVHL_OJOL
	@file ServiceManager.lua
	@author OmniverseHighland + AI Co-Dev System
	
	@description
	Manajer pusat untuk semua service dan modul. Bertanggung jawab
	untuk registrasi, dependency injection, dan mengelola lifecycle
	(Init, Start, Stop) dari semua komponen sistem.
]]

local ServiceManager = {}
ServiceManager.__index = ServiceManager

function ServiceManager.new()
	local self = setmetatable({}, ServiceManager)
	self.services = {} -- [serviceName: string]: serviceInstance
	self.modules = {} -- [moduleName: string]: moduleInstance
	self.SystemMonitor = nil -- Akan di-inject oleh Bootstrapper
	return self
end

-- Mendaftarkan instance service atau modul
function ServiceManager:Register(name: string, instance: any)
	if self.services[name] then
		self:Get("SystemMonitor"):Log("ServiceManager", "WARN", "DUPLICATE_REGISTER", ("Service dengan nama '%s' sudah terdaftar. Registrasi baru diabaikan."):format(name))
		return
	end
	self.services[name] = instance
end

-- Mendaftarkan modul dari manifest dan handler
function ServiceManager:RegisterModule(manifest: table, handlerModule: ModuleScript)
	if self.modules[manifest.name] then
		self:Get("SystemMonitor"):Log("ServiceManager", "WARN", "DUPLICATE_MODULE", ("Modul dengan nama '%s' sudah terdaftar. Registrasi baru diabaikan."):format(manifest.name))
		return
	end

	local moduleInstance = {
		manifest = manifest,
		handler = require(handlerModule),
		isStarted = false,
	}
	self.modules[manifest.name] = moduleInstance
end

-- Mendapatkan service yang sudah terdaftar
function ServiceManager:Get(name: string)
	local service = self.services[name]
	if not service then
		-- Menggunakan warn agar tidak menghentikan eksekusi, tapi tetap terlihat jelas
		warn(("[ServiceManager] Peringatan: Service '%s' tidak ditemukan atau belum dimuat."):format(name))
	end
	return service
end

-- Memulai semua service dan modul sesuai urutan dependency
function ServiceManager:StartAll()
	local SystemMonitor = self:Get("SystemMonitor")
	SystemMonitor:Log("ServiceManager", "INFO", "START_ALL", "Memulai semua service dan modul...")

	-- Pertama, jalankan Init() pada semua service
	for name, service in pairs(self.services) do
		if typeof(service.Init) == "function" then
			local status, err = pcall(service.Init, service)
			if not status then
				SystemMonitor:Log("ServiceManager", "ERROR", "SERVICE_INIT_FAIL", ("Gagal menjalankan Init() pada service '%s'. Pesan: %s"):format(name, err))
			end
		end
	end

	-- Kedua, jalankan Init() pada semua modul yang dependensinya terpenuhi
	for name, module in pairs(self.modules) do
		if typeof(module.handler.Init) == "function" then
			-- Cek dependency
			local canStart = true
			if module.manifest.depends then
				for _, depName in ipairs(module.manifest.depends) do
					if not self.services[depName] then
						SystemMonitor:Log("ServiceManager", "ERROR", "MODULE_DEP_MISSING", ("Gagal memulai modul '%s' karena dependensi '%s' tidak ditemukan."):format(name, depName))
						canStart = false
						break
					end
				end
			end
			
			if canStart then
				local status, err = pcall(module.handler.Init, module.handler, self)
				if not status then
					SystemMonitor:Log("ServiceManager", "ERROR", "MODULE_INIT_FAIL", ("Gagal menjalankan Init() pada modul '%s'. Pesan: %s"):format(name, err))
				else
					module.isStarted = true
				end
			end
		end
	end

	SystemMonitor:Log("ServiceManager", "INFO", "START_ALL_COMPLETE", "Proses startup semua komponen selesai.")
end

return ServiceManager
