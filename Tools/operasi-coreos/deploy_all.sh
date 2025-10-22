#!/bin/bash
# ==============================================================================
# OVHL_OJOL - Core OS Deployment Script
# Author: OmniverseHighland + AI Co-Dev System
# Version: 1.0.4
#
# Deskripsi:
# Skrip ini akan membuat ulang seluruh struktur folder dan file untuk
# proyek OVHL_OJOL, mengimplementasikan fondasi Core OS yang modular
# dan siap untuk pengembangan jangka panjang.
#
# Perubahan v1.0.4:
# - Memperbaiki default.project.json secara total dengan memetakan
#   file Init secara eksplisit untuk menghilangkan ambiguitas dan
#   menyelesaikan error "ClassName for Instance" pada rojo serve.
# ==============================================================================

# --- KONFIGURASI ---
# Direktori utama untuk source code
SOURCE_DIR="Source"
PROJECT_NAME="OVHL_OJOL"

# --- FUNGSI BANTUAN ---
function print_header() {
    echo "=================================================="
    echo "🚀  OVHL_OJOL Core OS Deployer v1.0.4  🚀"
    echo "=================================================="
}

function print_step() {
    echo "✅ [$(date +'%T')] $1"
}

function print_sub_step() {
    echo "   -> $1"
}

# ==============================================================================
# --- TAHAP 1: PEMBERSIHAN DAN PERSIAPAN ---
# ==============================================================================
print_header
print_step "Memulai tahap pembersihan..."

# Hapus direktori source dan file project lama jika ada
if [ -d "$SOURCE_DIR" ]; then
    rm -rf "$SOURCE_DIR"
    print_sub_step "Direktori '$SOURCE_DIR/' lama berhasil dihapus."
fi
if [ -f "default.project.json" ]; then
    rm "default.project.json"
    print_sub_step "File 'default.project.json' lama berhasil dihapus."
fi

print_step "Pembersihan selesai. Memulai pembuatan struktur baru..."
echo ""

# ==============================================================================
# --- TAHAP 2: PEMBUATAN STRUKTUR FOLDER ---
# ==============================================================================
print_step "Membuat struktur direktori utama..."

# Struktur folder berdasarkan arsitektur yang disetujui
mkdir -p "$SOURCE_DIR/Core/Kernel"
mkdir -p "$SOURCE_DIR/Core/Server/Services"
mkdir -p "$SOURCE_DIR/Core/Server/Modules/TestOrder"
mkdir -p "$SOURCE_DIR/Core/Client/UI"
mkdir -p "$SOURCE_DIR/Core/Client/Modules"
mkdir -p "$SOURCE_DIR/Core/Shared/Utils"
mkdir -p "$SOURCE_DIR/Core/Shared/Replicators"
mkdir -p "$SOURCE_DIR/Core/Shared/Styles"
mkdir -p "$SOURCE_DIR/Replicated"
mkdir -p "$SOURCE_DIR/Server"
mkdir -p "$SOURCE_DIR/Client"
mkdir -p "Tools"

print_sub_step "Struktur direktori berhasil dibuat di dalam '$SOURCE_DIR/'."

# Membuat file .gitkeep pada folder yang direncanakan kosong
print_step "Menambahkan file .gitkeep untuk direktori kosong..."
touch "$SOURCE_DIR/Core/Client/UI/.gitkeep"
touch "$SOURCE_DIR/Core/Client/Modules/.gitkeep"
touch "$SOURCE_DIR/Core/Shared/Replicators/.gitkeep"
touch "$SOURCE_DIR/Core/Shared/Styles/.gitkeep"
touch "$SOURCE_DIR/Replicated/.gitkeep"
print_sub_step "File .gitkeep berhasil ditambahkan."
echo ""

# ==============================================================================
# --- TAHAP 3: PEMBUATAN FILE KONFIGURASI DAN ENTRY POINT ---
# ==============================================================================
print_step "Membuat file konfigurasi dan entry point..."

# 1. default.project.json (untuk Rojo)
cat > default.project.json << 'EOF'
{
  "name": "OVHL_OJOL",
  "tree": {
    "$className": "DataModel",

    "ReplicatedStorage": {
      "Core": {
        "$path": "Source/Core"
      },
      "Replicated": {
        "$path": "Source/Replicated"
      }
    },

    "ServerScriptService": {
      "Init": {
        "$path": "Source/Server/Init.server.lua"
      }
    },

    "StarterPlayer": {
      "StarterPlayerScripts": {
        "Init": {
          "$path": "Source/Client/Init.client.lua"
        }
      }
    }
  }
}
EOF
print_sub_step "File 'default.project.json' berhasil diperbaiki."

# 2. Config.lua (Shared)
cat > "$SOURCE_DIR/Core/Shared/Config.lua" << 'EOF'
--!strict
--[[
	@project OVHL_OJOL
	@file Config.lua
	@author OmniverseHighland + AI Co-Dev System
	
	@description
	Manifest Konfigurasi Global.
	Semua pengaturan sistem yang bersifat statis dan dapat diubah
	ada di sini. Akan dibaca oleh Bootstrapper saat startup.
]]

local Config = {
	-- Pengaturan Umum
	game_name = "Ojol Roleplay",
	version = "1.0.0",
	enable_debug_mode = true, -- Aktifkan log dan monitor tambahan

	-- Pengaturan DataService
	autosave_interval = 300, -- Interval autosave data pemain (dalam detik)
	datastore_retry_attempts = 3, -- Jumlah percobaan ulang jika DataStore gagal
	datastore_retry_delay = 5, -- Jeda antar percobaan ulang (dalam detik)
	
	-- Pengaturan Hot Reload
	enable_hot_reload = true, -- Mengizinkan reload modul saat runtime

	-- Pengaturan Ekonomi
	economy_multiplier = 1.0, -- Pengali pendapatan default

	-- Pengaturan Admin
	admin_user_ids = {
		1, -- UserId Roblox Studio (Owner)
		-- Tambahkan ID admin lain di sini
	},

	-- Pengaturan StyleService (UI)
	default_ui_theme = "default",
}

return table.freeze(Config)
EOF
print_sub_step "File '$SOURCE_DIR/Core/Shared/Config.lua' berhasil dibuat."

# 3. Init.server.lua (Server Entry Point)
cat > "$SOURCE_DIR/Server/Init.server.lua" << 'EOF'
--!strict
--[[
	@project OVHL_OJOL
	@file Init.server.lua
	@author OmniverseHighland + AI Co-Dev System
	
	@description
	Titik masuk utama (entry point) untuk seluruh logika sisi server.
	Skrip ini akan memanggil Bootstrapper untuk memulai Core OS.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Core = ReplicatedStorage:WaitForChild("Core")
local Bootstrapper = require(Core.Kernel.Bootstrapper)

-- Memulai proses booting Core OS
local status, pesan = pcall(function()
	Bootstrapper:Start()
end)

if not status then
	warn("!!! FATAL BOOTSTRAP ERROR !!!")
	warn("Gagal memulai OVHL Core OS. Pesan Error:", pesan)
end
EOF
print_sub_step "File '$SOURCE_DIR/Server/Init.server.lua' berhasil dibuat."

# 4. Init.client.lua (Client Entry Point)
cat > "$SOURCE_DIR/Client/Init.client.lua" << 'EOF'
--!strict
--[[
	@project OVHL_OJOL
	@file Init.client.lua
	@author OmniverseHighland + AI Co-Dev System
	
	@description
	Titik masuk utama (entry point) untuk seluruh logika sisi client.
	Saat ini, hanya menunggu sinyal bahwa Core server sudah siap.
]]

print("✅ [OVHL_OJOL] Client Initialized. Menunggu Core OS di server...")

-- Di masa depan, di sini akan ada Client Bootstrapper
-- untuk memuat modul-modul UI dan logika client.
EOF
print_sub_step "File '$SOURCE_DIR/Client/Init.client.lua' berhasil dibuat."

echo ""

# ==============================================================================
# --- TAHAP 4: PEMBUATAN FILE CORE OS ---
# ==============================================================================
print_step "Membuat file-file inti OVHL Core OS..."

# 1. Bootstrapper.lua (Kernel)
cat > "$SOURCE_DIR/Core/Kernel/Bootstrapper.lua" << 'EOF'
--!strict
--[[
	@project OVHL_OJOL
	@file Bootstrapper.lua
	@author OmniverseHighland + AI Co-Dev System
	
	@description
	Jantung dari Core OS. Bertugas untuk menemukan, memuat,
	menginisialisasi, dan menjalankan semua service dan modul
	secara terstruktur dan berurutan.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Core = ReplicatedStorage.Core
local Services = Core.Server.Services
local Shared = Core.Shared

local ServiceManager = require(Services.ServiceManager)
local SystemMonitor = require(Services.SystemMonitor)
local Config = require(Shared.Config)

local Bootstrapper = {}
Bootstrapper.CoreServices = {
	"EventService",
	"DataService",
	"StyleService"
}
Bootstrapper.ModulesPath = Core.Server.Modules

function Bootstrapper:Start()
	local startTime = os.clock()
	SystemMonitor:Log("Bootstrapper", "INFO", "CORE_BOOT_START", "OVHL Core OS memulai proses booting...")
	
	-- Langkah 1: Inisialisasi Service Manager & Monitor
	local serviceManager = ServiceManager.new()
	SystemMonitor:Initialize(serviceManager)
	serviceManager:Register("ServiceManager", serviceManager)
	serviceManager:Register("SystemMonitor", SystemMonitor)
	SystemMonitor:Log("Bootstrapper", "INFO", "SERVICE_INIT", "ServiceManager & SystemMonitor berhasil diinisialisasi.")
	
	-- Langkah 2: Muat dan Daftarkan Core Services
	self:_LoadCoreServices(serviceManager)
	
	-- Langkah 3: Temukan dan Daftarkan Modul Gameplay
	self:_DiscoverAndLoadModules(serviceManager)
	
	-- Langkah 4: Jalankan semua service dan modul yang terdaftar
	serviceManager:StartAll()
	
	local bootTime = (os.clock() - startTime) * 1000
	SystemMonitor:Log("Bootstrapper", "INFO", "CORE_BOOT_SUCCESS", ("OVHL Core OS berhasil dimuat dalam %.2f ms."):format(bootTime))
	
	-- TODO: Kirim event ke client bahwa sistem sudah siap
end

function Bootstrapper:_LoadCoreServices(serviceManager: any)
	SystemMonitor:Log("Bootstrapper", "INFO", "CORE_SERVICE_LOAD", "Memuat Core Services...")
	for _, serviceName in ipairs(self.CoreServices) do
		local status, serviceModule = pcall(require, Services[serviceName])
		if status and typeof(serviceModule) == "table" and typeof(serviceModule.new) == "function" then
			local serviceInstance = serviceModule.new(serviceManager)
			serviceManager:Register(serviceName, serviceInstance)
			SystemMonitor:Log("Bootstrapper", "INFO", "REGISTER_SUCCESS", ("Service '%s' berhasil dimuat dan didaftarkan."):format(serviceName))
		else
			SystemMonitor:Log("Bootstrapper", "ERROR", "REGISTER_FAIL", ("Gagal memuat Core Service '%s'. Pesan: %s"):format(serviceName, tostring(serviceModule)))
		end
	end
end

function Bootstrapper:_DiscoverAndLoadModules(serviceManager: any)
	SystemMonitor:Log("Bootstrapper", "INFO", "MODULE_DISCOVERY", "Memulai penemuan modul di " .. self.ModulesPath:GetFullName())
	for _, moduleFolder in ipairs(self.ModulesPath:GetChildren()) do
		if not moduleFolder:IsA("Folder") then continue end
		
		local manifestModule = moduleFolder:FindFirstChild("manifest")
		if manifestModule and manifestModule:IsA("ModuleScript") then
			local status, manifest = pcall(require, manifestModule)
			if status and typeof(manifest) == "table" then
				local handlerModule = moduleFolder:FindFirstChild("Handler")
				if handlerModule and handlerModule:IsA("ModuleScript") then
					serviceManager:RegisterModule(manifest, handlerModule)
					SystemMonitor:Log("Bootstrapper", "INFO", "MODULE_REGISTERED", ("Modul '%s' v%s berhasil didaftarkan."):format(manifest.name, manifest.version))
				else
					SystemMonitor:Log("Bootstrapper", "WARN", "MODULE_NO_HANDLER", ("Modul '%s' memiliki manifest, tapi tidak ditemukan Handler.lua."):format(manifest.name))
				end
			else
				SystemMonitor:Log("Bootstrapper", "WARN", "MODULE_BAD_MANIFEST", ("Gagal membaca manifest untuk modul di folder '%s'."):format(moduleFolder.Name))
			end
		end
	end
end

return Bootstrapper
EOF
print_sub_step "File '$SOURCE_DIR/Core/Kernel/Bootstrapper.lua' berhasil dibuat."

# 2. ServiceManager.lua (Service)
cat > "$SOURCE_DIR/Core/Server/Services/ServiceManager.lua" << 'EOF'
--!strict
--[[
	@project OVHL_OJOL
	@file ServiceManager.lua
	@author OmniverseHighland + AI Co-Dev System
	
	@description
	Manajer pusat untuk semua service dan modul. Bertanggung jawab
	untuk registrasi, dependency injection, dan mengelola lifecycle
	(Init, Start, Stop) dari semua komponen sistem.
]]

local ServiceManager = {}
ServiceManager.__index = ServiceManager

function ServiceManager.new()
	local self = setmetatable({}, ServiceManager)
	self.services = {} -- [serviceName: string]: serviceInstance
	self.modules = {} -- [moduleName: string]: moduleInstance
	self.SystemMonitor = nil -- Akan di-inject oleh Bootstrapper
	return self
end

-- Mendaftarkan instance service atau modul
function ServiceManager:Register(name: string, instance: any)
	if self.services[name] then
		self:Get("SystemMonitor"):Log("ServiceManager", "WARN", "DUPLICATE_REGISTER", ("Service dengan nama '%s' sudah terdaftar. Registrasi baru diabaikan."):format(name))
		return
	end
	self.services[name] = instance
end

-- Mendaftarkan modul dari manifest dan handler
function ServiceManager:RegisterModule(manifest: table, handlerModule: ModuleScript)
	if self.modules[manifest.name] then
		self:Get("SystemMonitor"):Log("ServiceManager", "WARN", "DUPLICATE_MODULE", ("Modul dengan nama '%s' sudah terdaftar. Registrasi baru diabaikan."):format(manifest.name))
		return
	end

	local moduleInstance = {
		manifest = manifest,
		handler = require(handlerModule),
		isStarted = false,
	}
	self.modules[manifest.name] = moduleInstance
end

-- Mendapatkan service yang sudah terdaftar
function ServiceManager:Get(name: string)
	local service = self.services[name]
	if not service then
		-- Menggunakan warn agar tidak menghentikan eksekusi, tapi tetap terlihat jelas
		warn(("[ServiceManager] Peringatan: Service '%s' tidak ditemukan atau belum dimuat."):format(name))
	end
	return service
end

-- Memulai semua service dan modul sesuai urutan dependency
function ServiceManager:StartAll()
	local SystemMonitor = self:Get("SystemMonitor")
	SystemMonitor:Log("ServiceManager", "INFO", "START_ALL", "Memulai semua service dan modul...")

	-- Pertama, jalankan Init() pada semua service
	for name, service in pairs(self.services) do
		if typeof(service.Init) == "function" then
			local status, err = pcall(service.Init, service)
			if not status then
				SystemMonitor:Log("ServiceManager", "ERROR", "SERVICE_INIT_FAIL", ("Gagal menjalankan Init() pada service '%s'. Pesan: %s"):format(name, err))
			end
		end
	end

	-- Kedua, jalankan Init() pada semua modul yang dependensinya terpenuhi
	for name, module in pairs(self.modules) do
		if typeof(module.handler.Init) == "function" then
			-- Cek dependency
			local canStart = true
			if module.manifest.depends then
				for _, depName in ipairs(module.manifest.depends) do
					if not self.services[depName] then
						SystemMonitor:Log("ServiceManager", "ERROR", "MODULE_DEP_MISSING", ("Gagal memulai modul '%s' karena dependensi '%s' tidak ditemukan."):format(name, depName))
						canStart = false
						break
					end
				end
			end
			
			if canStart then
				local status, err = pcall(module.handler.Init, module.handler, self)
				if not status then
					SystemMonitor:Log("ServiceManager", "ERROR", "MODULE_INIT_FAIL", ("Gagal menjalankan Init() pada modul '%s'. Pesan: %s"):format(name, err))
				else
					module.isStarted = true
				end
			end
		end
	end

	SystemMonitor:Log("ServiceManager", "INFO", "START_ALL_COMPLETE", "Proses startup semua komponen selesai.")
end

return ServiceManager
EOF
print_sub_step "File '$SOURCE_DIR/Core/Server/Services/ServiceManager.lua' berhasil dibuat."

# 3. SystemMonitor.lua (Service)
cat > "$SOURCE_DIR/Core/Server/Services/SystemMonitor.lua" << 'EOF'
--!strict
--[[
	@project OVHL_OJOL
	@file SystemMonitor.lua
	@author OmniverseHighland + AI Co-Dev System
	
	@description
	Service terpusat untuk logging, monitoring, dan pelacakan kesehatan sistem.
	Menyediakan format log yang standar untuk memudahkan debugging.
]]

local SystemMonitor = {}

-- ServiceManager di-inject saat inisialisasi
local serviceManager: any

-- Dibuat sebagai singleton karena bersifat global
function SystemMonitor:Initialize(sm: any)
	if serviceManager then return end -- Sudah diinisialisasi
	serviceManager = sm
	self:Log("SystemMonitor", "INFO", "INIT_SUCCESS", "SystemMonitor siap digunakan.")
end

-- Fungsi logging utama
function SystemMonitor:Log(source: string, level: "INFO" | "WARN" | "ERROR", code: string, message: string)
	local logMessage = string.format("[%s] [%s] [%s] %s", source, code, level, message)
	
	if level == "ERROR" then
		warn(logMessage)
	elseif level == "WARN" then
		warn(logMessage)
	else
		print(logMessage)
	end
	
	-- TODO: Integrasi dengan log file atau webhook eksternal di masa depan
end

-- Stub kosong untuk memenuhi kontrak .new() dari Bootstrapper
-- Inisialisasi sebenarnya terjadi di :Initialize()
function SystemMonitor.new()
	return SystemMonitor
end

return SystemMonitor
EOF
print_sub_step "File '$SOURCE_DIR/Core/Server/Services/SystemMonitor.lua' berhasil dibuat."

# 4. EventService.lua (Service)
cat > "$SOURCE_DIR/Core/Server/Services/EventService.lua" << 'EOF'
--!strict
--[[
	@project OVHL_OJOL
	@file EventService.lua
	@author OmniverseHighland + AI Co-Dev System
	
	@description
	Menyediakan wrapper yang aman dan terstruktur untuk komunikasi
	antara client dan server menggunakan RemoteEvents dan RemoteFunctions.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local EventService = {}
EventService.__index = EventService

local serviceManager: any

function EventService.new(sm: any)
	local self = setmetatable({}, EventService)
	self.sm = sm
	self.SystemMonitor = sm:Get("SystemMonitor")
	self.container = Instance.new("Folder")
	self.container.Name = "OVHL_Events"
	self.container.Parent = ReplicatedStorage
	self.events = {}
	return self
end

function EventService:Init()
	self.SystemMonitor:Log("EventService", "INFO", "INIT", "EventService dimulai, container event dibuat.")
end

-- TODO: Implementasi fungsi-fungsi wrapper event
-- :CreateChannel(name)
-- :OnClient(channelName, callback)
-- :FireClient(player, channelName, ...)
-- :FireAllClients(channelName, ...)

return EventService
EOF
print_sub_step "File '$SOURCE_DIR/Core/Server/Services/EventService.lua' berhasil dibuat."

# 5. DataService.lua (Service)
cat > "$SOURCE_DIR/Core/Server/Services/DataService.lua" << 'EOF'
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
EOF
print_sub_step "File '$SOURCE_DIR/Core/Server/Services/DataService.lua' berhasil dibuat."

# 6. StyleService.lua (Service)
cat > "$SOURCE_DIR/Core/Server/Services/StyleService.lua" << 'EOF'
--!strict
--[[
	@project OVHL_OJOL
	@file StyleService.lua
	@author OmniverseHighland + AI Co-Dev System
	
	@description
	Mengelola semua token styling, tema, dan stylesheet untuk UI.
	Memastikan tampilan yang konsisten di seluruh antarmuka client.
]]

local StyleService = {}
StyleService.__index = StyleService

function StyleService.new(sm: any)
	local self = setmetatable({}, StyleService)
	self.sm = sm
	self.SystemMonitor = sm:Get("SystemMonitor")
	self.themes = {}
	self.activeTheme = "default"
	return self
end

function StyleService:Init()
	self.SystemMonitor:Log("StyleService", "INFO", "INIT", "StyleService dimulai.")
	-- TODO: Muat tema default
end

-- TODO: Implementasi fungsi-fungsi style
-- :GetToken(tokenPath)
-- :SetTheme(themeName)
-- :GetCurrentTheme()

return StyleService
EOF
print_sub_step "File '$SOURCE_DIR/Core/Server/Services/StyleService.lua' berhasil dibuat."

echo ""
# ==============================================================================
# --- TAHAP 5: PEMBUATAN MODUL CONTOH (TestOrder) ---
# ==============================================================================
print_step "Membuat modul contoh 'TestOrder'..."

# 1. manifest.lua
cat > "$SOURCE_DIR/Core/Server/Modules/TestOrder/manifest.lua" << 'EOF'
--!strict
--[[
	Manifest untuk Modul TestOrder
]]
return {
	name = "TestOrder",
	version = "0.1.0",
	description = "Modul sederhana untuk testing Core OS.",
	
	-- Daftar service yang dibutuhkan oleh modul ini
	depends = {
		"SystemMonitor",
		"EventService",
	},
}
EOF
print_sub_step "File '$SOURCE_DIR/Core/Server/Modules/TestOrder/manifest.lua' berhasil dibuat."

# 2. Handler.lua
cat > "$SOURCE_DIR/Core/Server/Modules/TestOrder/Handler.lua" << 'EOF'
--!strict
--[[
	@project OVHL_OJOL
	@module TestOrder
	@file Handler.lua
	
	@description
	Logika server untuk modul TestOrder.
]]

local TestOrderHandler = {}

local SystemMonitor: any

function TestOrderHandler:Init(serviceManager: any)
	SystemMonitor = serviceManager:Get("SystemMonitor")
	
	if not SystemMonitor then
		warn("[TestOrder] Peringatan: Gagal mendapatkan SystemMonitor.")
		return
	end
	
	SystemMonitor:Log("TestOrder", "INFO", "INIT_SUCCESS", "Modul TestOrder berhasil diinisialisasi!")
	
	-- Contoh penggunaan service lain
	local EventService = serviceManager:Get("EventService")
	if EventService then
		SystemMonitor:Log("TestOrder", "INFO", "DEP_CHECK", "EventService berhasil diakses.")
	end
end

function TestOrderHandler:Shutdown()
	if SystemMonitor then
		SystemMonitor:Log("TestOrder", "INFO", "SHUTDOWN", "Modul TestOrder dihentikan.")
	end
end

return TestOrderHandler
EOF
print_sub_step "File '$SOURCE_DIR/Core/Server/Modules/TestOrder/Handler.lua' berhasil dibuat."

echo ""
# ==============================================================================
# --- TAHAP 6: SELESAI ---
# ==============================================================================
print_step "DEPLOYMENT SELESAI!"
echo "--------------------------------------------------"
echo "Struktur proyek OVHL_OJOL telah berhasil dibuat."
echo "Langkah selanjutnya:"
echo "1. Buka project ini di VS Code."
echo "2. Jalankan plugin Rojo dan sinkronkan ke Roblox Studio."
echo "3. Tekan 'Play' dan periksa Output untuk log dari Core OS."
echo "--------------------------------------------------"

# Buka VS Code di direktori saat ini
if command -v code &> /dev/null
then
    print_step "Membuka Visual Studio Code..."
    code .
else
    print_step "VS Code tidak ditemukan. Silakan buka folder project secara manual."
fi

