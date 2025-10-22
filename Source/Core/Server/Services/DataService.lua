--!strict
--[[
	@project OVHL_OJOL
	@file DataService.lua
	@author OmniverseHighland + AI Co-Dev System
	@version 2.0.0
	
	@description
	Storage layer with autosave, retry, and local cache.
	VERSION 2.0.0: Menambahkan logic _LoadGlobalConfig saat Init.
]]

local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Core = ReplicatedStorage:WaitForChild("Core")
local DefaultConfig = require(Core.Shared.Config) -- Load default config dari file

local DataService = {}
DataService.__index = DataService
local ProfileTemplate = { Uang = 5000, Level = 1, XP = 0 }
local function deepCopy(t: table) local nt = {} for k, v in pairs(t) do nt[k] = (typeof(v) == "table") and deepCopy(v) or v end return nt end

function DataService.new(sm: any)
    local self = setmetatable({}, DataService)
    self.sm = sm
    self.SystemMonitor = sm:Get("SystemMonitor")
    self.playerDataStore = DataStoreService:GetDataStore("OVHL_PlayerData_v1")
    self.globalDataStore = DataStoreService:GetDataStore("OVHL_GlobalData_v1")
    self.playerDataCache = {}
    self.globalDataCache = {} -- Inisialisasi sebagai tabel kosong
    return self
end

function DataService:Init()
    -- ================================================================
    -- FIX: Load global config saat server startup
    -- ================================================================
    self:_LoadGlobalConfig()
    
    -- Setup player listeners
    Players.PlayerAdded:Connect(function(p) self:_onPlayerAdded(p) end)
    Players.PlayerRemoving:Connect(function(p) self:_onPlayerRemoving(p) end)
    game:BindToClose(function() self:_onServerShutdown() end)
    task.spawn(function() self:_autoSaveLoop() end)
    self.SystemMonitor:Log("DataService", "INFO", "INIT_SUCCESS", "DataService berhasil diinisialisasi.")
end

-- FUNGSI BARU UNTUK LOAD GLOBAL CONFIG
function DataService:_LoadGlobalConfig()
    self.SystemMonitor:Log("DataService", "INFO", "GLOBAL_LOAD_START", "Memuat global config (OVHL_CONFIG)...")
    
    local success, data = pcall(function()
        return self.globalDataStore:GetAsync("OVHL_CONFIG")
    end)
    
    if success then
        if data and typeof(data) == "table" then
            -- Ditemukan config di DataStore, gabungkan dengan default (jika ada key baru)
            self.globalDataCache = table.clone(DefaultConfig)
            for k, v in pairs(data) do
                self.globalDataCache[k] = v
            end
            self.SystemMonitor:Log("DataService", "INFO", "GLOBAL_LOAD_SUCCESS", "Config global berhasil di-load dari DataStore.")
        else
            -- Tidak ada config di DataStore, gunakan default dari file
            self.globalDataCache = table.clone(DefaultConfig)
            self.SystemMonitor:Log("DataService", "INFO", "GLOBAL_LOAD_DEFAULT", "Config global tidak ditemukan, menggunakan default dari Config.lua.")
            -- Simpan default ini ke DataStore
            self:SetGlobal("OVHL_CONFIG", self.globalDataCache)
        end
    else
        -- Gagal load dari DataStore, gunakan default sebagai fallback
        self.globalDataCache = table.clone(DefaultConfig)
        self.SystemMonitor:Log("DataService", "ERROR", "GLOBAL_LOAD_FAIL", "Gagal load config dari DataStore. Menggunakan default. Error: " .. tostring(data))
    end
end


function DataService:GetData(player: Player) return self.playerDataCache[player] end

function DataService:AddUang(player: Player, amount: number)
    local data = self:GetData(player)
    if data and typeof(data.Uang) == "number" then
        data.Uang += amount
        self.SystemMonitor:Log("DataService", "INFO", "DATA_UPDATED", ("Uang pemain '%s' +%d. Total: %d"):format(player.Name, amount, data.Uang))
        
        -- Kirim update ke client
        local EventService = self.sm:Get("EventService")
        if EventService then
            EventService:FireClient(player, "UpdatePlayerData", {Uang = data.Uang})
        end
    end
end

-- METHODS FOR GLOBAL CONFIG (DIPERBARUI)
function DataService:GetGlobal(key: string?)
    if not self.globalDataCache then
        self.globalDataCache = {}
    end
    
    -- Jika key adalah "OVHL_CONFIG", return seluruh cache config
    if key == "OVHL_CONFIG" then
        return self.globalDataCache
    end
    
    if key then
        return self.globalDataCache[key]
    else
        return self.globalDataCache
    end
end

function DataService:SetGlobal(key: string, value: any)
    if not self.globalDataCache then
        self.globalDataCache = {}
    end
    
    -- Kita asumsikan SetGlobal("OVHL_CONFIG", dataTabel)
    if key == "OVHL_CONFIG" and typeof(value) == "table" then
        self.globalDataCache = value
    else
        -- Handle jika ingin set key individual
        self.globalDataCache[key] = value
    end
    
    -- Save to DataStore async
    task.spawn(function()
        local success, err = pcall(function()
            -- Simpan seluruh cache config
            self.globalDataStore:SetAsync("OVHL_CONFIG", self.globalDataCache)
        end)
        
        if not success then
            self.SystemMonitor:Log("DataService", "ERROR", "GLOBAL_SAVE_FAIL", ("Gagal menyimpan config global: %s"):format(tostring(err)))
        end
    end)
end


function DataService:_onPlayerAdded(player: Player) self:_loadPlayerData(player) end
function DataService:_onPlayerRemoving(player: Player) self:_savePlayerData(player) self.playerDataCache[player] = nil end

function DataService:_loadPlayerData(player: Player)
    local userId = "Player_" .. player.UserId
    local success, data = pcall(function() return self.playerDataStore:GetAsync(userId) end)
    if success then
        self.playerDataCache[player] = data or deepCopy(ProfileTemplate)
        task.wait(1)
        local EventService = self.sm:Get("EventService")
        if EventService then EventService:FireClient(player, "PlayerDataReady") end
    else
        player:Kick("Gagal memuat data Anda.")
    end
end

function DataService:_savePlayerData(player: Player) if not self.playerDataCache[player] then return end pcall(function() self.playerDataStore:SetAsync("Player_" .. player.UserId, self.playerDataCache[player]) end) end
function DataService:_autoSaveLoop() while true do task.wait(DefaultConfig.autosave_interval) for _, player in ipairs(Players:GetPlayers()) do self:_savePlayerData(player) end end end
function DataService:_onServerShutdown() for _, player in ipairs(Players:GetPlayers()) do self:_savePlayerData(player) end task.wait(2) end

return DataService

