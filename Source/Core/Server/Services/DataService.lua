--!strict
--[[
	@project OVHL_OJOL
	@file DataService.lua
	@author OmniverseHighland + AI Co-Dev System
	
	@description
	Layer abstraksi untuk semua operasi penyimpanan data, termasuk
	DataStore pemain dan data global. Dilengkapi dengan cache,
	retry mechanism, dan autosave.
]]

local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")

local DataService = {}
DataService.__index = DataService

function DataService.new(sm: any)
	local self = setmetatable({}, DataService)
	self.sm = sm
	self.SystemMonitor = sm:Get("SystemMonitor")
	self.playerDataStore = DataStoreService:GetDataStore("OVHL_PlayerData_v1")
	self.playerDataCache = {}
	return self
end

function DataService:Init()
	self.SystemMonitor:Log("DataService", "INFO", "INIT", "DataService dimulai.")
	
	-- TODO: Hubungkan event PlayerAdded dan PlayerRemoving
	-- TODO: Mulai loop autosave
end

-- TODO: Implementasi fungsi-fungsi data
-- :GetPlayerData(player)
-- :SetPlayerData(player, key, value)
-- :SavePlayerData(player)

return DataService
