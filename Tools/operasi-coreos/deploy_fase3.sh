#!/bin/bash
# ==============================================================================
# OVHL_OJOL - Fase 3 Deployment Script (Aktivasi UI & Client-Server Sync)
# Author: OmniverseHighland + AI Co-Dev System
# Version: 3.0.3
#
# Deskripsi:
# Skrip ini akan meng-upgrade StyleService dan EventService, serta
# membangun fondasi UI di client untuk menampilkan data pemain.
# Versi 3.0.3: Mengganti StyleSheet Beta dengan metode styling klasik
#              untuk stabilitas (menghindari error "Unable to create UIStyle").
# ==============================================================================

# --- KONFIGURASI ---
SOURCE_DIR="Source"

# --- FUNGSI BANTUAN ---
function print_header() {
    echo "=================================================="
    echo "🚀  OVHL_OJOL Fase 3 Deployer v3.0.3  🚀"
    echo " (Aktivasi UI & Client-Server Sync)"
    echo "=================================================="
}

function print_step() {
    echo "✅ [$(date +'%T')] $1"
}

function print_sub_step() {
    echo "   -> $1"
}

# ==============================================================================
# --- TAHAP 1: VALIDASI & PERSIAPAN ---
# ==============================================================================
print_header

# Validasi file-file penting dari fase sebelumnya
declare -a required_files=(
    "$SOURCE_DIR/Core/Server/Services/StyleService.lua"
    "$SOURCE_DIR/Core/Server/Services/EventService.lua"
    "$SOURCE_DIR/Client/Init.client.lua"
)

for file in "${required_files[@]}"; do
    if [ ! -f "$file" ]; then
        echo "❌ [ERROR] File '$file' tidak ditemukan."
        echo "Pastikan Anda telah menjalankan skrip deployment fase sebelumnya."
        exit 1
    fi
done

print_step "Validasi berhasil. Memulai upgrade ke Fase 3..."

# Membuat direktori baru untuk client controllers
mkdir -p "$SOURCE_DIR/Core/Client/Controllers"
mkdir -p "$SOURCE_DIR/Core/Client/UI"
print_sub_step "Direktori client baru berhasil dibuat."
echo ""

# ==============================================================================
# --- TAHAP 2: UPGRADE CORE SERVICES (SERVER) ---
# ==============================================================================
print_step "Meng-upgrade Core Services di server..."

# 1. Upgrade StyleService.lua
cat > "$SOURCE_DIR/Core/Server/Services/StyleService.lua" << 'EOF'
--!strict
--[[
	@project OVHL_OJOL
	@file StyleService.lua
	@author OmniverseHighland + AI Co-Dev System
	@version 2.0.0
	
	@description
	Mengelola semua token styling, tema, dan stylesheet untuk UI.
	Menyediakan tema ke client melalui EventService.
]]

local StyleService = {}
StyleService.__index = StyleService

function StyleService.new(sm: any)
	local self = setmetatable({}, StyleService)
	self.sm = sm
	self.SystemMonitor = sm:Get("SystemMonitor")
	self.themes = {}
	self.activeThemeName = "Default"
	
	self:_LoadThemes()
	return self
end

function StyleService:Init()
	-- EventService akan siap setelah semua service di-register
	-- jadi kita tunggu sampai StartAll dipanggil
	task.defer(function()
		local EventService = self.sm:Get("EventService")
		if EventService then
			EventService:CreateFunction("GetActiveTheme", function(player: Player)
				return self:GetTheme(self.activeThemeName)
			end)
		end
	end)

	self.SystemMonitor:Log("StyleService", "INFO", "INIT_SUCCESS", "StyleService dimulai. Tema siap disajikan.")
end

function StyleService:GetTheme(themeName: string)
	return self.themes[themeName]
end

function StyleService:_LoadThemes()
	self.themes["Default"] = {
		Name = "Default",
		Colors = {
			Background = Color3.fromRGB(25, 25, 25),
			TextPrimary = Color3.fromRGB(250, 250, 250),
			TextSecondary = Color3.fromRGB(180, 180, 180),
			Accent = Color3.fromRGB(50, 150, 255),
		},
		Fonts = {
			Header = Enum.Font.GothamBold,
			Body = Enum.Font.Gotham,
		},
		Sizes = {
			-- Di masa depan bisa diisi UDim2
		}
	}
	self.SystemMonitor:Log("StyleService", "INFO", "THEME_LOADED", ("Tema '%s' berhasil dimuat."):format(self.activeThemeName))
end

return StyleService
EOF
print_sub_step "Upgrade StyleService.lua berhasil."

# 2. Upgrade EventService.lua
cat > "$SOURCE_DIR/Core/Server/Services/EventService.lua" << 'EOF'
--!strict
--[[
	@project OVHL_OJOL
	@file EventService.lua
	@author OmniverseHighland + AI Co-Dev System
	@version 2.0.1
	
	@description
	Menyediakan wrapper yang aman dan terstruktur untuk komunikasi
	client-server menggunakan RemoteEvents dan RemoteFunctions.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local EventService = {}
EventService.__index = EventService

function EventService.new(sm: any)
	local self = setmetatable({}, EventService)
	self.sm = sm
	self.SystemMonitor = sm:Get("SystemMonitor")
	self.container = Instance.new("Folder")
	self.container.Name = "OVHL_Events"
	self.container.Parent = ReplicatedStorage
	self.events = {}
	self.functions = {}
	return self
end

function EventService:Init()
	-- Membuat RemoteFunction untuk meminta data pemain
	self:CreateFunction("RequestPlayerData", function(player: Player)
		local DataService = self.sm:Get("DataService")
		if DataService then
			return DataService:GetData(player)
		end
		return nil
	end)
	
	-- Membuat RemoteEvent untuk memberi sinyal ke client
	self:CreateEvent("PlayerDataReady")
	
	self.SystemMonitor:Log("EventService", "INFO", "INIT_SUCCESS", "EventService dimulai, container & komponen dasar dibuat.")
end

function EventService:CreateFunction(name: string, callback: (Player, ...any) -> ...any)
	if self.functions[name] then
		self.SystemMonitor:Log("EventService", "WARN", "DUPLICATE_FUNCTION", ("RemoteFunction '%s' sudah ada."):format(name))
		return
	end
	
	local remoteFunc = Instance.new("RemoteFunction")
	remoteFunc.Name = name
	remoteFunc.Parent = self.container
	remoteFunc.OnServerInvoke = callback
	
	self.functions[name] = remoteFunc
	self.SystemMonitor:Log("EventService", "INFO", "FUNCTION_CREATED", ("RemoteFunction '%s' berhasil dibuat."):format(name))
end

function EventService:CreateEvent(name: string)
	if self.events[name] then
		self.SystemMonitor:Log("EventService", "WARN", "DUPLICATE_EVENT", ("RemoteEvent '%s' sudah ada."):format(name))
		return
	end
	
	local remoteEvent = Instance.new("RemoteEvent")
	remoteEvent.Name = name
	remoteEvent.Parent = self.container
	
	self.events[name] = remoteEvent
	self.SystemMonitor:Log("EventService", "INFO", "EVENT_CREATED", ("RemoteEvent '%s' berhasil dibuat."):format(name))
end

function EventService:FireClient(player: Player, name: string, ...: any)
	local remoteEvent = self.events[name]
	if remoteEvent then
		remoteEvent:FireClient(player, ...)
	else
		self.SystemMonitor:Log("EventService", "WARN", "EVENT_NOT_FOUND", ("Mencoba mengirim event '%s' yang tidak ditemukan."):format(name))
	end
end

return EventService
EOF
print_sub_step "Upgrade EventService.lua berhasil."

# 3. Upgrade DataService.lua (untuk mengirim sinyal)
cat > "$SOURCE_DIR/Core/Server/Services/DataService.lua" << 'EOF'
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
EOF
print_sub_step "Upgrade DataService.lua berhasil."

echo ""
# ==============================================================================
# --- TAHAP 3: MEMBUAT MODUL CLIENT BARU ---
# ==============================================================================
print_step "Membuat modul-modul baru di client..."

# 1. PlayerDataController.lua
cat > "$SOURCE_DIR/Core/Client/Controllers/PlayerDataController.lua" << 'EOF'
--!strict
--[[
	@project OVHL_OJOL
	@file PlayerDataController.lua (Client)
	@author OmniverseHighland + AI Co-Dev System
	@version 1.0.1
	
	@description
	Mengelola data pemain di sisi client. Menunggu sinyal dari server
	sebelum meminta data untuk menghindari race condition.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Events = ReplicatedStorage:WaitForChild("OVHL_Events")
local MainHUD = require(script.Parent.Parent.UI.MainHUD)

local PlayerDataController = {}

local playerData = nil

function PlayerDataController:Init()
	-- FIX: Jangan langsung minta data. Tunggu sinyal dari server.
	local dataReadyEvent: RemoteEvent = Events:WaitForChild("PlayerDataReady")
	
	dataReadyEvent.OnClientEvent:Connect(function()
		print("✅ Sinyal 'PlayerDataReady' diterima. Meminta data ke server...")
		
		-- Sekarang baru aman untuk meminta data
		local requestFunc: RemoteFunction = Events:WaitForChild("RequestPlayerData")
		playerData = requestFunc:InvokeServer()
		
		if playerData then
			print("✅ Data pemain berhasil diterima di client:", playerData)
			MainHUD:Create()
			MainHUD:UpdateMoney(playerData.Uang)
		else
			warn("❌ Gagal mendapatkan data pemain dari server setelah menerima sinyal.")
		end
	end)
end

function PlayerDataController:GetData()
	return playerData
end

return PlayerDataController
EOF
print_sub_step "File PlayerDataController.lua berhasil dibuat."

# 2. MainHUD.lua
cat > "$SOURCE_DIR/Core/Client/UI/MainHUD.lua" << 'EOF'
--!strict
--[[
	@project OVHL_OJOL
	@file MainHUD.lua (Client)
	@author OmniverseHighland + AI Co-Dev System
	@version 1.0.2
	
	@description
	Membuat dan mengelola UI utama (HUD). Dibuat secara terprogram
	dan di-style menggunakan metode klasik untuk stabilitas.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Events = ReplicatedStorage:WaitForChild("OVHL_Events")

local MainHUD = {}

local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
local screenGui: ScreenGui
local moneyLabel: TextLabel
local activeTheme: any

function MainHUD:Create()
	-- Minta tema dari StyleService
	local getThemeFunc: RemoteFunction = Events:WaitForChild("GetActiveTheme")
	activeTheme = getThemeFunc:InvokeServer()

	if not activeTheme then
		warn("❌ Gagal mendapatkan tema dari StyleService.")
		return
	end

	-- 1. Buat ScreenGui
	screenGui = Instance.new("ScreenGui")
	screenGui.Name = "MainHUD"
	screenGui.ResetOnSpawn = false
	
	-- 2. Buat Frame untuk Uang
	local moneyFrame = Instance.new("Frame")
	moneyFrame.Name = "MoneyFrame"
	moneyFrame.Size = UDim2.new(0.2, 0, 0.08, 0)
	moneyFrame.Position = UDim2.new(0.8, -10, 0.02, 0)
	moneyFrame.AnchorPoint = Vector2.new(1, 0)
	moneyFrame.BorderSizePixel = 0
	moneyFrame.Parent = screenGui
	
	-- 3. Buat TextLabel untuk Uang
	moneyLabel = Instance.new("TextLabel")
	moneyLabel.Name = "MoneyLabel"
	moneyLabel.Size = UDim2.new(1, 0, 1, 0)
	moneyLabel.Text = "Rp. ..."
	moneyLabel.TextXAlignment = Enum.TextXAlignment.Right
	moneyLabel.Parent = moneyFrame

	-- 4. Terapkan Style secara manual (Metode Klasik & Stabil)
	moneyFrame.BackgroundColor3 = activeTheme.Colors.Background
	moneyFrame.BackgroundTransparency = 0.2
	
	moneyLabel.Font = activeTheme.Fonts.Body
	moneyLabel.TextColor3 = activeTheme.Colors.TextPrimary
	
	-- 5. Parent ke PlayerGui
	screenGui.Parent = playerGui
	print("✅ MainHUD berhasil dibuat dan di-style.")
end

function MainHUD:UpdateMoney(amount: number)
	if moneyLabel then
		moneyLabel.Text = "Rp. " .. tostring(amount)
	end
end

return MainHUD
EOF
print_sub_step "File MainHUD.lua berhasil dibuat."

echo ""
# ==============================================================================
# --- TAHAP 4: UPDATE CLIENT ENTRY POINT ---
# ==============================================================================
print_step "Meng-upgrade Init.client.lua..."

cat > "$SOURCE_DIR/Client/Init.client.lua" << 'EOF'
--!strict
--[[
	@project OVHL_OJOL
	@file Init.client.lua
	@author OmniverseHighland + AI Co-Dev System
	@version 2.0.0
	
	@description
	Titik masuk utama client. Memulai controller UI.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Core = ReplicatedStorage:WaitForChild("Core")
local PlayerDataController = require(Core.Client.Controllers.PlayerDataController)

print("✅ [OVHL_OJOL] Client Initialized. Memulai UI Controllers...")

PlayerDataController:Init()
EOF
print_sub_step "Upgrade Init.client.lua berhasil."
echo ""

# ==============================================================================
# --- TAHAP 5: SELESAI ---
# ==============================================================================
print_step "DEPLOYMENT FASE 3 SELESAI!"
echo "--------------------------------------------------"
echo "StyleService, EventService, dan UI Client telah di-upgrade."
echo "Langkah selanjutnya:"
echo "1. Jalankan 'rojo serve' dan sinkronkan ke Roblox Studio."
echo "2. Tekan 'Play'. Anda akan melihat UI sederhana di pojok"
echo "   kanan atas yang menampilkan jumlah uang Anda."
echo "3. Periksa Output untuk log sinkronisasi data dan UI."
echo "--------------------------------------------------"

