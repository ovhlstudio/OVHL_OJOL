--!strict
--[[ @project OVHL_OJOL @file DataService.lua (v1.1 FIXED) ]]
local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local Core = game:GetService("ReplicatedStorage"):WaitForChild("Core")
local Config = require(Core.Shared.Config)
local DataService = {}
DataService.__index = DataService
local ProfileTemplate = { Uang = 5000, Level = 1, XP = 0 } -- Akan di-expand
local function deepCopy(t: table) local nt = {} for k, v in pairs(t) do nt[k] = (typeof(v) == "table") and deepCopy(v) or v end return nt end

function DataService.new(sm: any)
	local self = setmetatable({}, DataService)
	self.sm = sm
	self.SystemMonitor = sm:Get("SystemMonitor")
	self.playerDataStore = DataStoreService:GetDataStore("OVHL_PlayerData_v1")
	self.globalDataStore = DataStoreService:GetDataStore("OVHL_GlobalData_v1")
	self.playerDataCache = {}
	self.globalDataCache = {}
	return self
end

function DataService:Init()
	self:_LoadGlobalConfig() -- Load config DULU
	Players.PlayerAdded:Connect(function(p) self:_onPlayerAdded(p) end)
	Players.PlayerRemoving:Connect(function(p) self:_onPlayerRemoving(p) end)
	game:BindToClose(function() self:_onServerShutdown() end)
	task.spawn(function() self:_autoSaveLoop() end)
	self.SystemMonitor:Log("DataService", "INFO", "INIT_SUCCESS", "DataService siap.")
end

function DataService:GetData(player: Player) return self.playerDataCache[player] end
function DataService:AddUang(player: Player, amount: number) local d = self:GetData(player) if d and d.Uang then d.Uang += amount local es = self.sm:Get("EventService") if es then es:FireClient(player, "UpdatePlayerData", {Uang = d.Uang}) end end end

-- Global Config Methods (FIXED)
function DataService:GetGlobal(key: string?) return key and self.globalDataCache[key] or self.globalDataCache end
function DataService:SetGlobal(key: string, value: any) self.globalDataCache[key] = value task.spawn(function() local s,e = pcall(function() self.globalDataStore:SetAsync("OVHL_CONFIG", self.globalDataCache) end) if not s then self.SystemMonitor:Log("DataService", "ERROR", "GLOBAL_SAVE_FAIL", ("Gagal save config: %s"):format(e)) end end) end

function DataService:_LoadGlobalConfig()
	self.SystemMonitor:Log("DataService", "INFO", "GLOBAL_LOAD_START", "Memuat global config (OVHL_CONFIG)...")
	local success, data = pcall(function() return self.globalDataStore:GetAsync("OVHL_CONFIG") end)
	if success and data then
		self.globalDataCache = data
		self.SystemMonitor:Log("DataService", "INFO", "GLOBAL_LOAD_SUCCESS", "Config global di-load dari DataStore.")
	else
		self.globalDataCache = deepCopy(Config) -- Ambil dari file Config.lua
		self.SystemMonitor:Log("DataService", "INFO", "GLOBAL_LOAD_DEFAULT", "Config global tidak ditemukan, pakai default & save.")
		self:SetGlobal("OVHL_CONFIG", self.globalDataCache) -- Langsung save defaultnya
	end
end

-- Player Data Methods
function DataService:_onPlayerAdded(player: Player) self:_loadPlayerData(player) end
function DataService:_onPlayerRemoving(player: Player) self:_savePlayerData(player) self.playerDataCache[player] = nil end
function DataService:_loadPlayerData(player: Player) local id="Player_"..player.UserId local s,d=pcall(function() return self.playerDataStore:GetAsync(id) end) if s then self.playerDataCache[player]=d or deepCopy(ProfileTemplate) task.wait(1) local es=self.sm:Get("EventService") if es then es:FireClient(player, "PlayerDataReady") end else player:Kick("Gagal load data.") end end
function DataService:_savePlayerData(player: Player) if not self.playerDataCache[player] then return end pcall(function() self.playerDataStore:SetAsync("Player_"..player.UserId, self.playerDataCache[player]) end) end
function DataService:_autoSaveLoop() while true do task.wait(Config.autosave_interval or 300) for _, p in ipairs(Players:GetPlayers()) do self:_savePlayerData(p) end end end
function DataService:_onServerShutdown() for _, p in ipairs(Players:GetPlayers()) do self:_savePlayerData(p) end task.wait(2) end

return DataService
