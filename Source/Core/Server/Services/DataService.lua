--!strict
--[[
	@project OVHL_OJOL
	@file DataService.lua
	@author OmniverseHighland + AI Co-Dev System
	@version 2.0.1
	
	@description
	Layer abstraksi untuk semua operasi penyimpanan data.
	Versi 2.0.1: Menambahkan sinyal 'PlayerDataReady' ke client.
]]

local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")

local Core = game:GetService("ReplicatedStorage"):WaitForChild("Core")
local Config = require(Core.Shared.Config)

local DataService = {}
DataService.__index = DataService

local ProfileTemplate = {
	Uang = 5000, Level = 1, XP = 0, Motor = "Standard Bebek",
	Inventaris = {}, Reputasi = "Baik",
}

local function deepCopy(t: table)
	local newTable = {}
	for k, v in pairs(t) do
		if typeof(v) == "table" then
			newTable[k] = deepCopy(v)
		else
			newTable[k] = v
		end
	end
	return newTable
end

function DataService.new(sm: any)
	local self = setmetatable({}, DataService)
	self.sm = sm
	self.SystemMonitor = sm:Get("SystemMonitor")
	self.playerDataStore = DataStoreService:GetDataStore("OVHL_PlayerData_v1")
	self.playerDataCache = {}
	return self
end

function DataService:Init()
	self.SystemMonitor:Log("DataService", "INFO", "INIT_START", "DataService memulai inisialisasi...")
	Players.PlayerAdded:Connect(function(player) self:_onPlayerAdded(player) end)
	Players.PlayerRemoving:Connect(function(player) self:_onPlayerRemoving(player) end)
	game:BindToClose(function() self:_onServerShutdown() end)
	task.spawn(function() self:_autoSaveLoop() end)
	self.SystemMonitor:Log("DataService", "INFO", "INIT_SUCCESS", "DataService berhasil diinisialisasi.")
end

function DataService:GetData(player: Player)
	return self.playerDataCache[player]
end

function DataService:_onPlayerAdded(player: Player)
	self:_loadPlayerData(player)
end

function DataService:_onPlayerRemoving(player: Player)
	self:_savePlayerData(player)
	self.playerDataCache[player] = nil
	self.SystemMonitor:Log("DataService", "INFO", "CACHE_CLEARED", ("Cache '%s' dibersihkan."):format(player.Name))
end

function DataService:_loadPlayerData(player: Player)
	local userId = "Player_" .. player.UserId
	self.SystemMonitor:Log("DataService", "INFO", "LOAD_ATTEMPT", ("Memuat data untuk '%s'..."):format(player.Name))

	local success, data = pcall(function()
		return self.playerDataStore:GetAsync(userId)
	end)

	if success then
		local finalData
		if data then
			finalData = data
			self.SystemMonitor:Log("DataService", "INFO", "LOAD_SUCCESS", ("Data '%s' berhasil dimuat."):format(player.Name))
		else
			finalData = deepCopy(ProfileTemplate)
			self.SystemMonitor:Log("DataService", "INFO", "NEW_PLAYER", ("Pemain baru '%s' terdeteksi."):format(player.Name))
		end
		
		self.playerDataCache[player] = finalData
		
		-- FIX: Beri tahu client bahwa datanya sudah siap
		task.wait(1) -- Beri jeda sedikit untuk memastikan client siap mendengarkan
		local EventService = self.sm:Get("EventService")
		if EventService then
			EventService:FireClient(player, "PlayerDataReady")
			self.SystemMonitor:Log("DataService", "INFO", "SIGNAL_SENT", ("Sinyal 'PlayerDataReady' dikirim ke '%s'."):format(player.Name))
		end
	else
		self.SystemMonitor:Log("DataService", "ERROR", "LOAD_FAILED", ("Gagal memuat data '%s'. Error: %s"):format(player.Name, tostring(data)))
		player:Kick("Gagal memuat data Anda. Silakan coba bergabung kembali.")
	end
end

function DataService:_savePlayerData(player: Player)
	if not self.playerDataCache[player] then return end
	local userId = "Player_" .. player.UserId
	local success, err = pcall(function()
		self.playerDataStore:SetAsync(userId, self.playerDataCache[player])
	end)
	
	if success then
		self.SystemMonitor:Log("DataService", "INFO", "SAVE_SUCCESS", ("Data '%s' berhasil disimpan."):format(player.Name))
	else
		self.SystemMonitor:Log("DataService", "ERROR", "SAVE_FAILED", ("Gagal menyimpan data '%s'. Error: %s"):format(player.Name, tostring(err)))
	end
end

function DataService:_autoSaveLoop()
	self.SystemMonitor:Log("DataService", "INFO", "AUTOSAVE_START", "Loop autosave dimulai.")
	while true do
		task.wait(Config.autosave_interval)
		local onlinePlayers = Players:GetPlayers()
		if #onlinePlayers > 0 then
			self.SystemMonitor:Log("DataService", "INFO", "AUTOSAVE_CYCLE", ("Menyimpan data untuk %d pemain..."):format(#onlinePlayers))
			for _, player in ipairs(onlinePlayers) do
				self:_savePlayerData(player)
			end
		end
	end
end

function DataService:_onServerShutdown()
	self.SystemMonitor:Log("DataService", "WARN", "SHUTDOWN_SAVE", "Server shutdown. Menyimpan data...")
	for _, player in ipairs(Players:GetPlayers()) do
		self:_savePlayerData(player)
	end
	task.wait(2)
end

return DataService
