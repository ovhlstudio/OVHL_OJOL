--!strict
--[[
	@project OVHL_OJOL
	@file ServiceManager.lua
	@author OmniverseHighland + AI Co-Dev System
	@version 2.0.0
	
	@description
	Manajer pusat untuk semua service dan modul.
	VERSION 2.0.0 (TAHAP 4 FIX):
	- Mengubah StartAll() untuk membuat 'context' table (daftar kontak).
	- Me-pass 'context' table ke module:init(), BUKAN 'self'.
	- Ini memperbaiki bug 'attempt to index nil with Get' di semua modul.
]]
local ServiceManager = {}
ServiceManager.__index = ServiceManager

function ServiceManager.new()
    local self = setmetatable({}, ServiceManager)
    self.services = {}
    self.modules = {}
    self.SystemMonitor = nil -- Akan di-inject oleh Bootstrapper
    return self
end

function ServiceManager:Register(name: string, instance: any)
    if self.services[name] then
        local SystemMonitor = self:Get("SystemMonitor")
        if SystemMonitor then
            SystemMonitor:Log("ServiceManager", "WARN", "DUPLICATE_REGISTER", ("Service dengan nama '%s' sudah terdaftar. Registrasi baru diabaikan."):format(name))
        end
        return
    end
    self.services[name] = instance
end

function ServiceManager:RegisterModule(manifest: table, handlerModule: ModuleScript)
    local SystemMonitor = self:Get("SystemMonitor") -- Ambil SystemMonitor
    
    if self.modules[manifest.name] then
        SystemMonitor:Log("ServiceManager", "WARN", "DUPLICATE_MODULE", ("Modul dengan nama '%s' sudah terdaftar. Registrasi baru diabaikan."):format(manifest.name))
        return
    end

    local moduleInstance = {
        manifest = manifest,
        handler = require(handlerModule),
        isStarted = false,
    }
    self.modules[manifest.name] = moduleInstance
    
    SystemMonitor:Log("ServiceManager", "DEBUG", "MODULE_REGISTERED", ("Modul '%s' terdaftar, handler type: %s"):format(manifest.name, typeof(moduleInstance.handler)))
end

function ServiceManager:Get(name: string)
    local service = self.services[name]
    if not service then
        warn(("[ServiceManager] Peringatan: Service '%s' tidak ditemukan atau belum dimuat."):format(name))
    end
    return service
end

function ServiceManager:StartAll()
    local SystemMonitor = self:Get("SystemMonitor")
    SystemMonitor:Log("ServiceManager", "INFO", "START_ALL", "Memulai semua service dan modul...")

    -- ================================================================
    -- TAHAP 4 FIX: BUAT 'CONTEXT TABLE' (DAFTAR KONTAK)
    -- ================================================================
    local context = {
        ServiceManager = self,
        SystemMonitor = SystemMonitor
    }
    
    -- 1. Jalankan Init() pada semua service & tambahkan ke context
    for name, service in pairs(self.services) do
        if name ~= "ServiceManager" and name ~= "SystemMonitor" then -- Yg ini udah ada
            if typeof(service.Init) == "function" then
                local status, err = pcall(service.Init, service)
                if not status then
                    SystemMonitor:Log("ServiceManager", "ERROR", "SERVICE_INIT_FAIL", ("Gagal menjalankan Init() pada service '%s'. Pesan: %s"):format(name, err))
                else
                    SystemMonitor:Log("ServiceManager", "DEBUG", "SERVICE_INIT_SUCCESS", ("Service '%s' berhasil di-init"):format(name))
                end
            end
            context[name] = service -- Tambahkan service ke "Daftar Kontak"
        end
    end

    -- 2. Jalankan Init() pada semua modul, KASIH 'CONTEXT TABLE'
    for name, module in pairs(self.modules) do
        SystemMonitor:Log("ServiceManager", "DEBUG", "MODULE_START_ATTEMPT", ("Mencoba memulai modul '%s'"):format(name))
        
        if typeof(module.handler.init) == "function" then
            -- Cek dependency
            local canStart = true
            if module.manifest.depends then
                for _, depName in ipairs(module.manifest.depends) do
                    -- Cek di context table, bukan di self.services aja
                    if not context[depName] then 
                        SystemMonitor:Log("ServiceManager", "ERROR", "MODULE_DEP_MISSING", ("Gagal memulai modul '%s' karena dependensi '%s' tidak ditemukan."):format(name, depName))
                        canStart = false
                        break
                    else
                        SystemMonitor:Log("ServiceManager", "DEBUG", "MODULE_DEP_FOUND", ("Modul '%s': dependensi '%s' tersedia"):format(name, depName))
                    end
                end
            end
            
            if canStart then
                SystemMonitor:Log("ServiceManager", "DEBUG", "MODULE_STARTING", ("Memulai modul '%s'..."):format(name))
                
                -- ================================================================
                -- INI DIA PERUBAHAN UTAMANYA:
                -- Kita kasih 'context' (Daftar Kontak), bukan 'self' (Manajer)
                -- ================================================================
                local status, err = pcall(module.handler.init, module.handler, context) 
                
                if not status then
                    SystemMonitor:Log("ServiceManager", "ERROR", "MODULE_INIT_FAIL", ("Gagal menjalankan init() pada modul '%s'. Pesan: %s"):format(name, err))
                else
                    module.isStarted = true
                    SystemMonitor:Log("ServiceManager", "INFO", "MODULE_START_SUCCESS", ("Modul '%s' berhasil dimulai"):format(name))
                end
            end
        else
            SystemMonitor:Log("ServiceManager", "ERROR", "MODULE_NO_INIT", ("Modul '%s' tidak memiliki function init()"):format(name))
        end
    end

    SystemMonitor:Log("ServiceManager", "INFO", "START_ALL_COMPLETE", "Proses startup semua komponen selesai.")
end

return ServiceManager

