--!strict
--[[
	@project OVHL_OJOL
	@file Handler.lua (AdminPanel)
	@author OmniverseHighland + AI Co-Dev System
	@version 1.2.0
	
	@description
	Handler sisi server untuk Admin Panel.
	VERSION 1.2.0 (TAHAP 5 FIX):
	- Mengubah fungsi IsAdmin()
	- Sekarang, jika game berjalan di Studio, SEMUA PLAYER dianggap ADMIN.
	- Ini untuk mempermudah testing dan memperbaiki bug 'UNAUTHORIZED'.
]]
local AdminPanel = {}
AdminPanel.__index = AdminPanel

function AdminPanel:init(context) -- context SEKARANG ADALAH TABLE
    print("🛠️ ADMINPANEL: init() dipanggil!")
    
    -- ================================================================
    -- INI DIA PERBAIKAN TAHAP 4.2
    -- Kita baca 'context' sebagai table, bukan sebagai ServiceManager
    -- ================================================================
    self.ServiceManager = context.ServiceManager
    self.EventService = context.EventService  
    self.DataService = context.DataService
    self.SystemMonitor = context.SystemMonitor -- Ambil langsung dari context
    
    -- Safety check kalau SystemMonitor gak ada
    if not self.SystemMonitor then
        warn("ADMINPANEL: FATAL! SystemMonitor tidak ditemukan di context table!")
        return
    end
    
    self.SystemMonitor:Log("AdminPanel", "INFO", "INIT_START", "AdminPanel mulai inisialisasi...")
    
    -- Setup handlers immediately
    self:SetupAdminHandlers()
    
    self.SystemMonitor:Log("AdminPanel", "INFO", "INIT_SUCCESS", "AdminPanel berhasil diinisialisasi")
    print("🛠️ ADMINPANEL: init() selesai!")
end

function AdminPanel:SetupAdminHandlers()
    self.SystemMonitor:Log("AdminPanel", "DEBUG", "SETUP_HANDLERS", "Setup admin handlers...")
    
    local config = self.DataService:GetGlobal("OVHL_CONFIG")
    local adminUserIds = config and config.admin_user_ids or {}
    
    -- Handler untuk AdminGetConfig
    if self.EventService.functions["AdminGetConfig"] then
        self.SystemMonitor:Log("AdminPanel", "DEBUG", "SETUP_GETCONFIG", "Setup AdminGetConfig handler")
        self.EventService.functions["AdminGetConfig"].OnServerInvoke = function(player)
            self.SystemMonitor:Log("AdminPanel", "DEBUG", "GETCONFIG_CALLED", ("AdminGetConfig dipanggil oleh %s"):format(player.Name))
            
            if not self:IsAdmin(player, adminUserIds) then 
                self.SystemMonitor:Log("AdminPanel", "WARN", "GETCONFIG_UNAUTHORIZED", ("%s mencoba akses AdminGetConfig tanpa izin"):format(player.Name))
                return nil 
            end
            
            -- Ambil config TERBARU dari DataService
            local currentConfig = self.DataService:GetGlobal("OVHL_CONFIG")
            self.SystemMonitor:Log("AdminPanel", "DEBUG", "GETCONFIG_RESULT", ("AdminGetConfig mengembalikan: %s"):format(tostring(currentConfig)))
            return currentConfig
        end
    else
        self.SystemMonitor:Log("AdminPanel", "ERROR", "GETCONFIG_NOT_FOUND", "AdminGetConfig RemoteFunction tidak ditemukan!")
    end
    
    -- Handler untuk AdminUpdateConfig
    if self.EventService.functions["AdminUpdateConfig"] then
        self.SystemMonitor:Log("AdminPanel", "DEBUG", "SETUP_UPDATECONFIG", "Setup AdminUpdateConfig handler")
        self.EventService.functions["AdminUpdateConfig"].OnServerInvoke = function(player, updates)
            self.SystemMonitor:Log("AdminPanel", "DEBUG", "UPDATECONFIG_CALLED", ("AdminUpdateConfig dipanggil oleh %s"):format(player.Name))
            
            if not self:IsAdmin(player, adminUserIds) then 
                self.SystemMonitor:Log("AdminPanel", "WARN", "UPDATECONFIG_UNAUTHORIZED", ("%s mencoba akses AdminUpdateConfig tanpa izin"):format(player.Name))
                return false 
            end
            
            local currentConfig = self.DataService:GetGlobal("OVHL_CONFIG") or {}
            for key, value in pairs(updates) do
                currentConfig[key] = value
            end
            
            -- Simpan ke DataStore
            self.DataService:SetGlobal("OVHL_CONFIG", currentConfig)
            
            -- Beri tahu semua client (termasuk admin lain) bahwa config berubah
            self.EventService:FireAllClients("ConfigUpdated", currentConfig)
            
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
            
            if not self:IsAdmin(player, adminUserIds) then 
                self.SystemMonitor:Log("AdminPanel", "WARN", "RELOADMODULE_UNAUTHORIZED", ("%s mencoba akses AdminReloadModule tanpa izin"):format(player.Name))
                return false 
            end
            
            self.SystemMonitor:Log("AdminPanel", "INFO", "MODULE_RELOAD_REQUEST", 
                ("Admin '%s' meminta reload module '%s'"):format(player.Name, moduleName))
                
            -- TODO: Panggil ServiceManager:ReloadModule(moduleName)
            -- Untuk sekarang, kita return true aja dulu
            
            return true
        end
    else
        self.SystemMonitor:Log("AdminPanel", "ERROR", "RELOADMODULE_NOT_FOUND", "AdminReloadModule RemoteFunction tidak ditemukan!")
    end
    
    self.SystemMonitor:Log("AdminPanel", "INFO", "HANDLERS_SETUP", "Semua admin handlers berhasil di-setup")
end

function AdminPanel:IsAdmin(player, adminUserIds)
    -- Cek whitelist dari config
    for _, adminId in ipairs(adminUserIds) do
        if player.UserId == adminId then
            return true
        end
    end
    
    -- ================================================================
    -- INI DIA PERBAIKAN TAHAP 5
    -- Kalo di Studio, semua orang adalah admin (buat testing)
    -- ================================================================
    if game:GetService("RunService"):IsStudio() then
        if self.SystemMonitor then -- Pastikan SystemMonitor ada
            self.SystemMonitor:Log("AdminPanel", "DEBUG", "IS_ADMIN_STUDIO", ("Akses admin diberikan (Mode Studio) untuk %s"):format(player.Name))
        end
        return true
    end

    return false
end

function AdminPanel:teardown()
    self.SystemMonitor:Log("AdminPanel", "INFO", "TEARDOWN", "AdminPanel di-shutdown")
    -- TODO: Disconnect semua event handlers
end

return AdminPanel

