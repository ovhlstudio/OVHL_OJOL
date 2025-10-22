#!/bin/bash
# ==============================================================================
# OVHL_OJOL - Fase 4 Deployment Script (Implementasi UIManager)
# Author: OmniverseHighland + AI Co-Dev System
# Version: 4.0.1
#
# Deskripsi:
# Skrip ini mengimplementasikan UIManager sebagai "Arsitek UI" terpusat,
# memperkenalkan ClientBootstrapper, dan merombak alur kerja UI client.
# Versi 4.0.1: Memperbaiki path require() yang salah di PlayerDataController.
# ==============================================================================

# --- KONFIGURASI ---
SOURCE_DIR="Source"

# --- FUNGSI BANTUAN ---
function print_header() {
    echo "=================================================="
    echo "🚀  OVHL_OJOL Fase 4 Deployer v4.0.1  🚀"
    echo "      (Implementasi UIManager)"
    echo "=================================================="
}

function print_step() {
    echo "✅ [$(date +'%T')] $1"
}

function print_sub_step() {
    echo "   -> $1"
}

# ==============================================================================
# --- TAHAP 1: PERSIAPAN STRUKTUR ---
# ==============================================================================
print_header

print_step "Memvalidasi dan mempersiapkan struktur direktori..."
# Membuat direktori baru untuk client services
mkdir -p "$SOURCE_DIR/Core/Client/Services"
print_sub_step "Direktori '$SOURCE_DIR/Core/Client/Services/' siap."
echo ""

# ==============================================================================
# --- TAHAP 2: MEMBUAT MODUL & SERVICE BARU ---
# ==============================================================================
print_step "Membuat modul dan service client baru..."

# 1. Signal.lua (Utility)
cat > "$SOURCE_DIR/Core/Shared/Utils/Signal.lua" << 'EOF'
--!strict
--[[
	@project OVHL_OJOL
	@file Signal.lua
	@author OmniverseHighland + AI Co-Dev System
	
	@description
	Implementasi sederhana dari event/signal dispatcher untuk komunikasi
	antar modul di sisi client tanpa coupling yang erat.
]]

local Signal = {}
Signal.__index = Signal

function Signal.new()
	local self = setmetatable({}, Signal)
	self.connections = {}
	return self
end

function Signal:Connect(callback: () -> ())
	table.insert(self.connections, callback)
	-- Di implementasi production, bisa return connection object untuk disconnect
end

function Signal:Fire(...)
	for _, callback in ipairs(self.connections) do
		task.spawn(callback, ...)
	end
end

return Signal
EOF
print_sub_step "File utilitas 'Signal.lua' berhasil dibuat."

# 2. UIManager.lua (Client Service)
cat > "$SOURCE_DIR/Core/Client/Services/UIManager.lua" << 'EOF'
--!strict
--[[
	@project OVHL_OJOL
	@file UIManager.lua (Client Service)
	@author OmniverseHighland + AI Co-Dev System
	
	@description
	"Arsitek UI" terpusat. Bertanggung jawab untuk membuat, men-style,
	dan mengelola semua elemen UI secara terprogram. Modul lain
	hanya memberikan perintah, UIManager yang mengeksekusi.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Events = ReplicatedStorage:WaitForChild("OVHL_Events")

local UIManager = {}

local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
local activeTheme: any
local screens = {} -- Cache untuk ScreenGuis yang sudah dibuat

function UIManager:Init()
	-- Meminta tema dari server saat UIManager pertama kali diinisialisasi
	local getThemeFunc: RemoteFunction = Events:WaitForChild("GetActiveTheme")
	activeTheme = getThemeFunc:InvokeServer()
	
	if not activeTheme then
		warn("❌ [UIManager] Gagal mendapatkan tema dari StyleService.")
	else
		print("✅ [UIManager] Tema '".. activeTheme.Name .."' berhasil dimuat.")
	end
end

function UIManager:CreateScreen(screenName: string)
	if screens[screenName] then return screens[screenName] end
	
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = screenName
	screenGui.ResetOnSpawn = false
	screenGui.Parent = playerGui
	
	screens[screenName] = screenGui
	return screenGui
end

-- Contoh fungsi "arsitek"
function UIManager:CreateWindow(options: {
	Parent: GuiObject,
	Name: string,
	Size: UDim2,
	Position: UDim2,
	AnchorPoint: Vector2?,
})
	local frame = Instance.new("Frame")
	frame.Name = options.Name
	frame.Size = options.Size
	frame.Position = options.Position
	frame.AnchorPoint = options.AnchorPoint or Vector2.new(0, 0)
	frame.BorderSizePixel = 0
	
	-- Styling dari tema
	frame.BackgroundColor3 = activeTheme.Colors.Background
	frame.BackgroundTransparency = 0.2
	
	-- Menambahkan hiasan modern
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = frame
	
	frame.Parent = options.Parent
	return frame
end

function UIManager:AddTextLabel(options: {
	Parent: GuiObject,
	Name: string,
	Text: string,
	Size: UDim2,
	Position: UDim2?,
	TextXAlignment: Enum.TextXAlignment?,
})
	local label = Instance.new("TextLabel")
	label.Name = options.Name
	label.Text = options.Text
	label.Size = options.Size
	label.Position = options.Position or UDim2.fromScale(0, 0)
	label.TextXAlignment = options.TextXAlignment or Enum.TextXAlignment.Left
	label.BackgroundTransparency = 1
	
	-- Styling dari tema
	label.Font = activeTheme.Fonts.Body
	label.TextColor3 = activeTheme.Colors.TextPrimary
	
	label.Parent = options.Parent
	return label
end

return UIManager
EOF
print_sub_step "File service 'UIManager.lua' berhasil dibuat."

# 3. ClientBootstrapper.lua
cat > "$SOURCE_DIR/Core/Client/ClientBootstrapper.lua" << 'EOF'
--!strict
--[[
	@project OVHL_OJOL
	@file ClientBootstrapper.lua
	@author OmniverseHighland + AI Co-Dev System
	@version 1.0.1
	
	@description
	Entry point terstruktur untuk sisi client. Memuat service,
	controller, dan modul UI dalam urutan yang benar.
]]

local Core = game:GetService("ReplicatedStorage"):WaitForChild("Core")

-- Client Services
local UIManager = require(Core.Client.Services.UIManager)

-- Client Controllers
local PlayerDataController = require(Core.Client.Controllers.PlayerDataController)

-- Client UI Modules
local MainHUD = require(Core.Client.UI.MainHUD)

local ClientBootstrapper = {}

function ClientBootstrapper:Start()
	print("🚀 [ClientBootstrapper] Memulai inisialisasi sisi client...")
	
	local dependencies = {
		UIManager = UIManager,
	}
	
	-- 1. Inisialisasi Service Client
	UIManager:Init()
	
	-- 2. Inisialisasi Controller
	PlayerDataController:Init(dependencies)
	
	-- 3. Inisialisasi Modul UI
	MainHUD:Init(dependencies)
	
	print("✅ [ClientBootstrapper] Inisialisasi client selesai.")
end

return ClientBootstrapper
EOF
print_sub_step "File 'ClientBootstrapper.lua' berhasil dibuat."

echo ""
# ==============================================================================
# --- TAHAP 3: REFAKTOR MODUL CLIENT LAMA ---
# ==============================================================================
print_step "Merombak modul-modul client yang sudah ada..."

# 1. Update Init.client.lua
cat > "$SOURCE_DIR/Client/Init.client.lua" << 'EOF'
--!strict
--[[
	@project OVHL_OJOL
	@file Init.client.lua
	@author OmniverseHighland + AI Co-Dev System
	@version 3.0.0
	
	@description
	Entry point client yang bersih, hanya memanggil bootstrapper.
]]

local Core = game:GetService("ReplicatedStorage"):WaitForChild("Core")
local ClientBootstrapper = require(Core.Client.ClientBootstrapper)

ClientBootstrapper:Start()
EOF
print_sub_step "File 'Init.client.lua' berhasil di-refaktor."

# 2. Update PlayerDataController.lua
cat > "$SOURCE_DIR/Core/Client/Controllers/PlayerDataController.lua" << 'EOF'
--!strict
--[[
	@project OVHL_OJOL
	@file PlayerDataController.lua (Client)
	@author OmniverseHighland + AI Co-Dev System
	@version 2.0.1
	
	@description
	Mengelola data pemain di client dan mengirim sinyal saat data siap.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Core = ReplicatedStorage:WaitForChild("Core")
local Events = ReplicatedStorage:WaitForChild("OVHL_Events")
local Signal = require(Core.Shared.Utils.Signal) -- FIX: Path yang benar

local PlayerDataController = {}

local playerData = nil
PlayerDataController.OnDataReady = Signal.new()

function PlayerDataController:Init(dependencies: {any})
	local dataReadyEvent: RemoteEvent = Events:WaitForChild("PlayerDataReady")
	
	dataReadyEvent.OnClientEvent:Connect(function()
		print("✅ [PDC] Sinyal 'PlayerDataReady' diterima. Meminta data...")
		
		local requestFunc: RemoteFunction = Events:WaitForChild("RequestPlayerData")
		playerData = requestFunc:InvokeServer()
		
		if playerData then
			print("✅ [PDC] Data pemain berhasil diterima:", playerData)
			PlayerDataController.OnDataReady:Fire(playerData)
		else
			warn("❌ [PDC] Gagal mendapatkan data pemain dari server.")
		end
	end)
end

function PlayerDataController:GetData()
	return playerData
end

return PlayerDataController
EOF
print_sub_step "File 'PlayerDataController.lua' berhasil di-refaktor."

# 3. Update MainHUD.lua
cat > "$SOURCE_DIR/Core/Client/UI/MainHUD.lua" << 'EOF'
--!strict
--[[
	@project OVHL_OJOL
	@file MainHUD.lua (Client UI Module)
	@author OmniverseHighland + AI Co-Dev System
	@version 2.0.0
	
	@description
	Modul UI yang bersih. Hanya mendengarkan sinyal dan memberikan
	perintah ke UIManager, tidak ada logika pembuatan UI sama sekali.
]]

local Core = game:GetService("ReplicatedStorage"):WaitForChild("Core")
local PlayerDataController = require(Core.Client.Controllers.PlayerDataController)

local MainHUD = {}

local moneyLabel: TextLabel

function MainHUD:Init(dependencies: {UIManager: any})
	local UIManager = dependencies.UIManager
	
	-- Dengarkan sinyal dari PlayerDataController
	PlayerDataController.OnDataReady:Connect(function(playerData)
		print("✅ [MainHUD] Sinyal data siap diterima. Memberi perintah ke UIManager...")
		
		local screen = UIManager:CreateScreen("MainHUD")
		local moneyWindow = UIManager:CreateWindow({
			Parent = screen,
			Name = "MoneyWindow",
			Size = UDim2.new(0.2, 0, 0.08, 0),
			Position = UDim2.new(0.98, 0, 0.02, 0),
			AnchorPoint = Vector2.new(1, 0),
		})
		
		moneyLabel = UIManager:AddTextLabel({
			Parent = moneyWindow,
			Name = "MoneyLabel",
			Text = "Rp. " .. tostring(playerData.Uang),
			Size = UDim2.fromScale(0.9, 0.8),
			Position = UDim2.fromScale(0.5, 0.5),
			AnchorPoint = Vector2.new(0.5, 0.5),
			TextXAlignment = Enum.TextXAlignment.Center,
		})
		
		print("✅ [MainHUD] Perintah pembuatan UI ke UIManager selesai.")
	end)
end

return MainHUD
EOF
print_sub_step "File 'MainHUD.lua' berhasil di-refaktor."

echo ""
# ==============================================================================
# --- TAHAP 4: SELESAI ---
# ==============================================================================
print_step "DEPLOYMENT FASE 4 SELESAI!"
echo "--------------------------------------------------"
echo "Arsitektur UI client telah di-upgrade dengan UIManager."
echo "Langkah selanjutnya:"
echo "1. Jalankan 'rojo serve' dan sinkronkan ke Roblox Studio."
echo "2. Tekan 'Play'. UI uang akan muncul kembali, tapi sekarang"
echo "   dibuat oleh UIManager dengan style yang lebih baik (sudut melengkung)."
echo "3. Periksa bagaimana file MainHUD.lua menjadi jauh lebih bersih."
echo "--------------------------------------------------"

