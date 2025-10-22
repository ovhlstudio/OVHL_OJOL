--!strict
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
                
                -- Init service immediately
                if typeof(serviceInstance.Init) == "function" then
                    pcall(serviceInstance.Init, serviceInstance)
                end
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
    
    -- DEBUG: List semua modules yang ada
    for _, moduleFolder in ipairs(self.ModulesPath:GetChildren()) do
        if moduleFolder:IsA("Folder") then
            SystemMonitor:Log("Bootstrapper", "DEBUG", "MODULE_FOUND", ("Folder modul ditemukan: %s"):format(moduleFolder.Name))
        end
    end
    
    -- Load AdminPanel module FIRST dengan debug
    local adminPanelFolder = self.ModulesPath:FindFirstChild("AdminPanel")
    if adminPanelFolder and adminPanelFolder:IsA("Folder") then
        SystemMonitor:Log("Bootstrapper", "DEBUG", "ADMINPANEL_FOUND", "AdminPanel folder ditemukan!")
        
        local manifestModule = adminPanelFolder:FindFirstChild("manifest")
        if manifestModule and manifestModule:IsA("ModuleScript") then
            SystemMonitor:Log("Bootstrapper", "DEBUG", "MANIFEST_FOUND", "AdminPanel manifest ditemukan!")
            
            local status, manifest = pcall(require, manifestModule)
            if status and typeof(manifest) == "table" then
                SystemMonitor:Log("Bootstrapper", "DEBUG", "MANIFEST_LOADED", ("AdminPanel manifest loaded: %s"):format(manifest.name))
                
                local handlerModule = adminPanelFolder:FindFirstChild("Handler")
                if handlerModule and handlerModule:IsA("ModuleScript") then
                    SystemMonitor:Log("Bootstrapper", "DEBUG", "HANDLER_FOUND", "AdminPanel Handler ditemukan!")
                    
                    serviceManager:RegisterModule(manifest, handlerModule)
                    SystemMonitor:Log("Bootstrapper", "INFO", "MODULE_REGISTERED", ("Modul '%s' berhasil didaftarkan."):format(manifest.name))
                else
                    SystemMonitor:Log("Bootstrapper", "ERROR", "HANDLER_NOT_FOUND", "AdminPanel Handler tidak ditemukan!")
                end
            else
                SystemMonitor:Log("Bootstrapper", "ERROR", "MANIFEST_LOAD_FAIL", ("Gagal load AdminPanel manifest: %s"):format(tostring(manifest)))
            end
        else
            SystemMonitor:Log("Bootstrapper", "ERROR", "MANIFEST_NOT_FOUND", "AdminPanel manifest tidak ditemukan!")
        end
    else
        SystemMonitor:Log("Bootstrapper", "ERROR", "ADMINPANEL_NOT_FOUND", "AdminPanel folder tidak ditemukan di ModulesPath!")
    end
    
    -- Load other modules
    for _, moduleFolder in ipairs(self.ModulesPath:GetChildren()) do
        if moduleFolder:IsA("Folder") and moduleFolder.Name ~= "AdminPanel" then
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
