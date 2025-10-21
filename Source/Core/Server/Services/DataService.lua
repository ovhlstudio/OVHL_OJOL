--!strict
--[[
	@project OVHL_OJOL
	@file DataService.lua
	@author OmniverseHighland + AI Co-Dev System
	@version 2.1.0
]]

local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local Core = game:GetService("ReplicatedStorage"):WaitForChild("Core")
local Config = require(Core.Shared.Config)
local DataService = {}
DataService.__index = DataService
local ProfileTemplate = { Uang = 5000, Level = 1, XP = 0 }
local function deepCopy(t: table) local nt = {} for k, v in pairs(t) do nt[k] = (typeof(v) == "table") and deepCopy(v) or v end return nt end

function DataService.new(sm: any)
	local self = setmetatable({}, DataService)
	self.sm = sm
	self.SystemMonitor = sm:Get("SystemMonitor")
	self.playerDataStore = DataStoreService:GetDataStore("OVHL_PlayerData_v1")
	self.playerDataCache = {}
	return self
end

function DataService:Init()
	Players.PlayerAdded:Connect(function(p) self:_onPlayerAdded(p) end)
	Players.PlayerRemoving:Connect(function(p) self:_onPlayerRemoving(p) end)
	game:BindToClose(function() self:_onServerShutdown() end)
	task.spawn(function() self:_autoSaveLoop() end)
	self.SystemMonitor:Log("DataService", "INFO", "INIT_SUCCESS", "DataService berhasil diinisialisasi.")
end

function DataService:GetData(player: Player) return self.playerDataCache[player] end

function DataService:AddUang(player: Player, amount: number)
	local data = self:GetData(player)
	if data and typeof(data.Uang) == "number" then
		data.Uang += amount
		self.SystemMonitor:Log("DataService", "INFO", "DATA_UPDATED", ("Uang pemain '%s' +%d. Total: %d"):format(player.Name, amount, data.Uang))
		-- TODO: Kirim update UI Uang ke client
	end
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

function DataService:_savePlayerData(player: Player)
	if not self.playerDataCache[player] then return end
	pcall(function() self.playerDataStore:SetAsync("Player_" .. player.UserId, self.playerDataCache[player]) end)
end

function DataService:_autoSaveLoop()
	while true do
		task.wait(Config.autosave_interval)
		for _, player in ipairs(Players:GetPlayers()) do self:_savePlayerData(player) end
	end
end

function DataService:_onServerShutdown()
	for _, player in ipairs(Players:GetPlayers()) do self:_savePlayerData(player) end
	task.wait(2)
end

return DataService
