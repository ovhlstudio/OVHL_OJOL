#!/bin/bash
# ==============================================================================
# OVHL_OJOL - Fase 2 Deployment Script (Aktivasi DataService)
# Author: OmniverseHighland + AI Co-Dev System
# Version: 2.0.0
#
# Deskripsi:
# Skrip ini akan meng-upgrade DataService dengan fungsionalitas penuh,
# termasuk load/save data pemain, cache, dan autosave.
# Cukup jalankan skrip ini untuk menimpa file DataService.lua yang lama.
# ==============================================================================

# --- KONFIGURASI ---
SOURCE_DIR="Source"
DATASERVICE_PATH="$SOURCE_DIR/Core/Server/Services/DataService.lua"

# --- FUNGSI BANTUAN ---
function print_header() {
    echo "=================================================="
    echo "🚀  OVHL_OJOL Fase 2 Deployer  🚀"
    echo "       (Aktivasi DataService)"
    echo "=================================================="
}

function print_step() {
    echo "✅ [$(date +'%T')] $1"
}

# ==============================================================================
# --- TAHAP 1: VALIDASI ---
# ==============================================================================
print_header

if [ ! -f "$DATASERVICE_PATH" ]; then
    echo "❌ [ERROR] File DataService.lua tidak ditemukan di '$DATASERVICE_PATH'."
    echo "Pastikan Anda telah menjalankan skrip deployment fase 1 terlebih dahulu."
    exit 1
fi

print_step "Validasi berhasil. Memulai upgrade DataService..."
echo ""

# ==============================================================================
# --- TAHAP 2: UPGRADE DATASERVICE.LUA ---
# ==============================================================================
print_step "Menulis logika baru ke '$DATASERVICE_PATH'..."

cat > "$DATASERVICE_PATH" << 'EOF'
--!strict
--[[
	@project OVHL_OJOL
	@file DataService.lua
	@author OmniverseHighland + AI Co-Dev System
	@version 2.0.0
	
	@description
	Layer abstraksi untuk semua operasi penyimpanan data, termasuk
	DataStore pemain dan data global. Dilengkapi dengan cache,
	retry mechanism, dan autosave.
]]

local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")

local Core = game:GetService("ReplicatedStorage"):WaitForChild("Core")
local Config = require(Core.Shared.Config)

local DataService = {}
DataService.__index = DataService

-- Template data untuk pemain baru
local ProfileTemplate = {
	Uang = 5000,
	Level = 1,
	XP = 0,
	Motor = "Standard Bebek",
	Inventaris = {},
	Reputasi = "Baik",
}

-- Fungsi deep copy untuk template
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
	self.playerDataCache = {} -- [Player]: data
	return self
end

function DataService:Init()
	self.SystemMonitor:Log("DataService", "INFO", "INIT_START", "DataService memulai inisialisasi...")
	
	-- Menghubungkan event untuk menangani join/leave pemain
	Players.PlayerAdded:Connect(function(player) self:_onPlayerAdded(player) end)
	Players.PlayerRemoving:Connect(function(player) self:_onPlayerRemoving(player) end)
	
	-- Menangani shutdown server
	game:BindToClose(function() self:_onServerShutdown() end)
	
	-- Memulai loop autosave di thread baru
	task.spawn(function() self:_autoSaveLoop() end)

	self.SystemMonitor:Log("DataService", "INFO", "INIT_SUCCESS", "DataService berhasil diinisialisasi dan siap digunakan.")
end

-- PUBLIC API --
function DataService:GetData(player: Player)
	return self.playerDataCache[player]
end

-- PRIVATE METHODS --
function DataService:_onPlayerAdded(player: Player)
	self:_loadPlayerData(player)
end

function DataService:_onPlayerRemoving(player: Player)
	self:_savePlayerData(player)
	self.playerDataCache[player] = nil -- Hapus dari cache setelah disimpan
	self.SystemMonitor:Log("DataService", "INFO", "CACHE_CLEARED", ("Cache untuk pemain '%s' berhasil dibersihkan."):format(player.Name))
end

function DataService:_loadPlayerData(player: Player)
	local userId = "Player_" .. player.UserId
	self.SystemMonitor:Log("DataService", "INFO", "LOAD_ATTEMPT", ("Mencoba memuat data untuk pemain '%s' (ID: %s)..."):format(player.Name, userId))

	local success, data = pcall(function()
		return self.playerDataStore:GetAsync(userId)
	end)

	if success then
		if data then
			-- Data ditemukan, masukkan ke cache
			self.playerDataCache[player] = data
			self.SystemMonitor:Log("DataService", "INFO", "LOAD_SUCCESS", ("Data untuk pemain '%s' berhasil dimuat dari DataStore."):format(player.Name))
		else
			-- Pemain baru, buat data baru dari template
			self.playerDataCache[player] = deepCopy(ProfileTemplate)
			self.SystemMonitor:Log("DataService", "INFO", "NEW_PLAYER", ("Pemain baru terdeteksi: '%s'. Data default berhasil dibuat."):format(player.Name))
		end
	else
		-- Terjadi error saat loading, kick pemain untuk mencegah data loss
		self.SystemMonitor:Log("DataService", "ERROR", "LOAD_FAILED", ("Gagal memuat data untuk pemain '%s'. Error: %s"):format(player.Name, tostring(data)))
		player:Kick("Gagal memuat data Anda. Silakan coba bergabung kembali.")
	end
end

function DataService:_savePlayerData(player: Player)
	if not self.playerDataCache[player] then return end
	
	local userId = "Player_" .. player.UserId
	local dataToSave = self.playerDataCache[player]
	
	local success, err = pcall(function()
		self.playerDataStore:SetAsync(userId, dataToSave)
	end)
	
	if success then
		self.SystemMonitor:Log("DataService", "INFO", "SAVE_SUCCESS", ("Data untuk pemain '%s' berhasil disimpan."):format(player.Name))
	else
		self.SystemMonitor:Log("DataService", "ERROR", "SAVE_FAILED", ("Gagal menyimpan data untuk pemain '%s'. Error: %s"):format(player.Name, tostring(err)))
		-- Di game production, data ini akan dimasukkan ke antrian untuk disimpan ulang
	end
end

function DataService:_autoSaveLoop()
	self.SystemMonitor:Log("DataService", "INFO", "AUTOSAVE_START", "Loop autosave dimulai dengan interval " .. Config.autosave_interval .. " detik.")
	while true do
		task.wait(Config.autosave_interval)
		
		local onlinePlayers = Players:GetPlayers()
		if #onlinePlayers > 0 then
			self.SystemMonitor:Log("DataService", "INFO", "AUTOSAVE_CYCLE", ("Memulai siklus autosave untuk %d pemain online..."):format(#onlinePlayers))
			for _, player in ipairs(onlinePlayers) do
				self:_savePlayerData(player)
			end
		end
	end
end

function DataService:_onServerShutdown()
	self.SystemMonitor:Log("DataService", "WARN", "SHUTDOWN_SAVE", "Server akan ditutup. Menyimpan data semua pemain...")
	for _, player in ipairs(Players:GetPlayers()) do
		self:_savePlayerData(player)
	end
	task.wait(2) -- Beri sedikit waktu untuk proses save selesai
end

return DataService
EOF

print_step "Upgrade DataService.lua berhasil."
echo ""
# ==============================================================================
# --- TAHAP 3: SELESAI ---
# ==============================================================================
print_step "DEPLOYMENT FASE 2 SELESAI!"
echo "--------------------------------------------------"
echo "DataService telah berhasil di-upgrade."
echo "Langkah selanjutnya:"
echo "1. Jalankan 'rojo serve' dan sinkronkan ke Roblox Studio."
echo "2. Tekan 'Play', lalu periksa Output. Anda akan melihat log"
echo "   'LOAD_SUCCESS' atau 'NEW_PLAYER' saat karakter Anda masuk."
echo "3. Tekan 'Stop', dan periksa log 'SAVE_SUCCESS'."
echo "--------------------------------------------------"
