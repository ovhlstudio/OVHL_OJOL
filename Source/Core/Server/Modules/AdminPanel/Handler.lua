--!strict
local AdminPanel = {}
AdminPanel.__index = AdminPanel

function AdminPanel:init(context)
    print("🛠️ ADMINPANEL: init() dipanggil!")
    
    self.ServiceManager = context.ServiceManager
    self.EventService = context.EventService  
    self.DataService = context.DataService
    
    -- Gunakan SystemMonitor dari context, jangan panggil Get() lagi
    self.SystemMonitor = context.SystemMonitor or self.ServiceManager:Get("SystemMonitor")
    
    self.SystemMonitor:Log("AdminPanel", "INFO", "INIT_START", "AdminPanel mulai inisialisasi...")
    
    -- Setup handlers immediately
    self:SetupAdminHandlers()
    
    self.SystemMonitor:Log("AdminPanel", "INFO", "INIT_SUCCESS", "AdminPanel berhasil diinisialisasi")
    print("🛠️ ADMINPANEL: init() selesai!")
end

function AdminPanel:SetupAdminHandlers()
    self.SystemMonitor:Log("AdminPanel", "DEBUG", "SETUP_HANDLERS", "Setup admin handlers...")
    
    -- Handler untuk AdminGetConfig
    if self.EventService.functions["AdminGetConfig"] then
        self.SystemMonitor:Log("AdminPanel", "DEBUG", "SETUP_GETCONFIG", "Setup AdminGetConfig handler")
        self.EventService.functions["AdminGetConfig"].OnServerInvoke = function(player, key)
            self.SystemMonitor:Log("AdminPanel", "DEBUG", "GETCONFIG_CALLED", ("AdminGetConfig dipanggil oleh %s"):format(player.Name))
            
            if not self:IsAdmin(player) then 
                self.SystemMonitor:Log("AdminPanel", "WARN", "GETCONFIG_UNAUTHORIZED", ("%s mencoba akses AdminGetConfig tanpa izin"):format(player.Name))
                return nil 
            end
            
            local config = self.DataService:GetGlobal("OVHL_CONFIG") or {
                economy_multiplier = 1.0,
                ai_population_density = 0.8
            }
            local result = key and config[key] or config
            self.SystemMonitor:Log("AdminPanel", "DEBUG", "GETCONFIG_RESULT", ("AdminGetConfig mengembalikan: %s"):format(tostring(result)))
            return result
        end
    else
        self.SystemMonitor:Log("AdminPanel", "ERROR", "GETCONFIG_NOT_FOUND", "AdminGetConfig RemoteFunction tidak ditemukan!")
    end
    
    -- Handler untuk AdminUpdateConfig
    if self.EventService.functions["AdminUpdateConfig"] then
        self.SystemMonitor:Log("AdminPanel", "DEBUG", "SETUP_UPDATECONFIG", "Setup AdminUpdateConfig handler")
        self.EventService.functions["AdminUpdateConfig"].OnServerInvoke = function(player, updates)
            self.SystemMonitor:Log("AdminPanel", "DEBUG", "UPDATECONFIG_CALLED", ("AdminUpdateConfig dipanggil oleh %s"):format(player.Name))
            
            if not self:IsAdmin(player) then 
                self.SystemMonitor:Log("AdminPanel", "WARN", "UPDATECONFIG_UNAUTHORIZED", ("%s mencoba akses AdminUpdateConfig tanpa izin"):format(player.Name))
                return false 
            end
            
            local config = self.DataService:GetGlobal("OVHL_CONFIG") or {}
            for key, value in pairs(updates) do
                config[key] = value
            end
            
            self.DataService:SetGlobal("OVHL_CONFIG", config)
            
            self.SystemMonitor:Log("AdminPanel", "INFO", "CONFIG_UPDATED", 
                ("Admin '%s' mengupdate config: %s"):format(player.Name, game:GetService("HttpService"):JSONEncode(updates)))
            
            return true
        end
    else
        self.SystemMonitor:Log("AdminPanel", "ERROR", "UPDATECONFIG_NOT_FOUND", "AdminUpdateConfig RemoteFunction tidak ditemukan!")
    end
    
    -- Handler untuk AdminReloadModule
    if self.EventService.functions["AdminReloadModule"] then
        self.SystemMonitor:Log("AdminPanel", "DEBUG", "SETUP_RELOADMODULE", "Setup AdminReloadModule handler")
        self.EventService.functions["AdminReloadModule"].OnServerInvoke = function(player, moduleName)
            self.SystemMonitor:Log("AdminPanel", "DEBUG", "RELOADMODULE_CALLED", ("AdminReloadModule dipanggil oleh %s untuk module %s"):format(player.Name, moduleName))
            
            if not self:IsAdmin(player) then 
                self.SystemMonitor:Log("AdminPanel", "WARN", "RELOADMODULE_UNAUTHORIZED", ("%s mencoba akses AdminReloadModule tanpa izin"):format(player.Name))
                return false 
            end
            
            self.SystemMonitor:Log("AdminPanel", "INFO", "MODULE_RELOAD_REQUEST", 
                ("Admin '%s' meminta reload module '%s'"):format(player.Name, moduleName))
            
            return true
        end
    else
        self.SystemMonitor:Log("AdminPanel", "ERROR", "RELOADMODULE_NOT_FOUND", "AdminReloadModule RemoteFunction tidak ditemukan!")
    end
    
    self.SystemMonitor:Log("AdminPanel", "INFO", "HANDLERS_SETUP", "Semua admin handlers berhasil di-setup")
end

function AdminPanel:IsAdmin(player)
    -- Untuk testing, return true dulu
    return true
end

function AdminPanel:teardown()
    self.SystemMonitor:Log("AdminPanel", "INFO", "TEARDOWN", "AdminPanel di-shutdown")
end

return AdminPanel
