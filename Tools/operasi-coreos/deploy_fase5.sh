#!/bin/bash
# ==============================================================================
# OVHL_OJOL - Fase 5 Deployment Script (Gameplay Loop Pertama: Notifikasi Order)
# Author: OmniverseHighland + AI Co-Dev System
# Version: 5.0.1
#
# Deskripsi:
# Skrip ini mengimplementasikan gameplay loop pertama.
# Versi 5.0.1: Menambahkan styling kustom untuk tombol Terima/Tolak
#              dan mengatur ukuran font agar lebih kontras dan jelas.
# ==============================================================================

# --- KONFIGURASI ---
SOURCE_DIR="Source"

# --- FUNGSI BANTUAN ---
function print_header() {
    echo "=================================================="
    echo "🚀  OVHL_OJOL Fase 5 Deployer v5.0.1  🚀"
    echo "  (Gameplay Loop: Notifikasi Order)"
    echo "=================================================="
}

function print_step() {
    echo "✅ [$(date +'%T')] $1"
}

function print_sub_step() {
    echo "   -> $1"
}

# ==============================================================================
# --- TAHAP 1: PERSIAPAN STRUKTUR & FILE BARU ---
# ==============================================================================
print_header

print_step "Membuat file-file baru untuk Fase 5..."

# 1. Buat OrderController.lua
cat > "$SOURCE_DIR/Core/Client/Controllers/OrderController.lua" << 'EOF'
--!strict
--[[
	@project OVHL_OJOL
	@file OrderController.lua (Client)
	@author OmniverseHighland + AI Co-Dev System
	
	@description
	Mengelola semua logika terkait order di sisi client. Mendengarkan
	notifikasi dari server dan memberi perintah ke UIManager.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Events = ReplicatedStorage:WaitForChild("OVHL_Events")

local OrderController = {}
local UIManager: any

function OrderController:Init(dependencies: {UIManager: any})
	UIManager = dependencies.UIManager
	
	local newOrderEvent: RemoteEvent = Events:WaitForChild("NewOrderNotification")
	newOrderEvent.OnClientEvent:Connect(function(orderData: {from: string, to: string, payment: number})
		self:_showOrderNotification(orderData)
	end)
end

function OrderController:_showOrderNotification(orderData: {from: string, to: string, payment: number})
	print("✅ [OrderController] Notifikasi order baru diterima:", orderData)
	
	local screen = UIManager:CreateScreen("NotificationUI")
	
	-- Hancurkan notifikasi lama jika ada
	if screen:FindFirstChild("OrderNotification") then
		screen.OrderNotification:Destroy()
	end
	
	local notificationWindow = UIManager:CreateWindow({
		Parent = screen,
		Name = "OrderNotification",
		Size = UDim2.fromScale(0.3, 0.25),
		Position = UDim2.fromScale(0.5, 0.4),
		AnchorPoint = Vector2.new(0.5, 0.5),
	})
	
	UIManager:AddTextLabel({
		Parent = notificationWindow,
		Name = "Title",
		Text = "ORDER BARU!",
		Size = UDim2.fromScale(1, 0.2),
		TextXAlignment = Enum.TextXAlignment.Center,
	})
	
	local detailsText = string.format("Dari: %s\nTujuan: %s\nBayaran: Rp. %d", orderData.from, orderData.to, orderData.payment)
	UIManager:AddTextLabel({
		Parent = notificationWindow,
		Name = "Details",
		Text = detailsText,
		Size = UDim2.new(0.9, 0, 0.4, 0),
		Position = UDim2.fromScale(0.5, 0.45),
		AnchorPoint = Vector2.new(0.5, 0.5),
		TextXAlignment = Enum.TextXAlignment.Left,
	})
	
	local acceptButton = UIManager:AddButton({
		Parent = notificationWindow,
		Name = "AcceptButton",
		Text = "TERIMA",
		Size = UDim2.new(0.4, 0, 0.2, 0),
		Position = UDim2.fromScale(0.25, 0.85),
		AnchorPoint = Vector2.new(0.5, 0.5),
	})
	
	local declineButton = UIManager:AddButton({
		Parent = notificationWindow,
		Name = "DeclineButton",
		Text = "TOLAK",
		Size = UDim2.new(0.4, 0, 0.2, 0),
		Position = UDim2.fromScale(0.75, 0.85),
		AnchorPoint = Vector2.new(0.5, 0.5),
	})
	
	-- Hubungkan event
	acceptButton.MouseButton1Click:Connect(function()
		print("✅ Order DITERIMA!")
		notificationWindow:Destroy()
		-- TODO: Kirim respon ke server
	end)
	
	declineButton.MouseButton1Click:Connect(function()
		print("❌ Order DITOLAK!")
		notificationWindow:Destroy()
		-- TODO: Kirim respon ke server
	end)
end

return OrderController
EOF
print_sub_step "File 'OrderController.lua' berhasil dibuat."
echo ""
# ==============================================================================
# --- TAHAP 2: UPGRADE MODUL & SERVICE LAMA ---
# ==============================================================================
print_step "Meng-upgrade modul dan service yang sudah ada..."

# 1. Upgrade UIManager.lua
cat > "$SOURCE_DIR/Core/Client/Services/UIManager.lua" << 'EOF'
--!strict
--[[
	@project OVHL_OJOL
	@file UIManager.lua (Client Service)
	@author OmniverseHighland + AI Co-Dev System
	@version 1.1.1
	
	@description
	"Arsitek UI" terpusat. Versi ini menambahkan styling kondisional
	berdasarkan nama tombol dan mengatur ukuran font.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Events = ReplicatedStorage:WaitForChild("OVHL_Events")

local UIManager = {}

local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
local activeTheme: any
local screens = {}

function UIManager:Init()
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

function UIManager:CreateWindow(options: {
	Parent: GuiObject, Name: string, Size: UDim2,
	Position: UDim2, AnchorPoint: Vector2?,
})
	local frame = Instance.new("Frame")
	frame.Name = options.Name
	frame.Size = options.Size
	frame.Position = options.Position
	frame.AnchorPoint = options.AnchorPoint or Vector2.new(0, 0)
	frame.BorderSizePixel = 0
	frame.BackgroundColor3 = activeTheme.Colors.Background
	frame.BackgroundTransparency = 0.2
	
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = frame
	
	frame.Parent = options.Parent
	return frame
end

function UIManager:AddTextLabel(options: {
	Parent: GuiObject, Name: string, Text: string, Size: UDim2,
	Position: UDim2?, AnchorPoint: Vector2?, TextXAlignment: Enum.TextXAlignment?,
})
	local label = Instance.new("TextLabel")
	label.Name = options.Name
	label.Text = options.Text
	label.Size = options.Size
	label.Position = options.Position or UDim2.fromScale(0, 0)
	label.AnchorPoint = options.AnchorPoint or Vector2.new(0, 0)
	label.TextXAlignment = options.TextXAlignment or Enum.TextXAlignment.Left
	label.BackgroundTransparency = 1
	label.Font = activeTheme.Fonts.Body
	label.TextColor3 = activeTheme.Colors.TextPrimary
	label.TextSize = activeTheme.FontSizes.Body -- Atur ukuran font
	label.Parent = options.Parent
	return label
end

function UIManager:AddButton(options: {
	Parent: GuiObject, Name: string, Text: string, Size: UDim2,
	Position: UDim2, AnchorPoint: Vector2?,
})
	local button = Instance.new("TextButton")
	button.Name = options.Name
	button.Text = options.Text
	button.Size = options.Size
	button.Position = options.Position
	button.AnchorPoint = options.AnchorPoint or Vector2.new(0, 0)
	
	-- Styling
	if options.Name == "AcceptButton" then
		button.BackgroundColor3 = activeTheme.Colors.Confirm
	elseif options.Name == "DeclineButton" then
		button.BackgroundColor3 = activeTheme.Colors.Decline
	else
		button.BackgroundColor3 = activeTheme.Colors.Accent
	end
	
	button.Font = activeTheme.Fonts.Body
	button.TextColor3 = activeTheme.Colors.TextPrimary
	button.TextSize = activeTheme.FontSizes.Button -- Atur ukuran font tombol
	
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 6)
	corner.Parent = button
	
	button.Parent = options.Parent
	return button
end

return UIManager
EOF
print_sub_step "Upgrade 'UIManager.lua' berhasil (styling tombol & font)."

# 2. Upgrade TestOrder/Handler.lua
cat > "$SOURCE_DIR/Core/Server/Modules/TestOrder/Handler.lua" << 'EOF'
--!strict
--[[
	@project OVHL_OJOL
	@module TestOrder
	@file Handler.lua
	@version 1.1.0
	
	@description
	Logika server untuk modul TestOrder. Versi ini secara aktif
	mensimulasikan pengiriman order baru ke pemain.
]]

local Players = game:GetService("Players")
local TestOrderHandler = {}

local SystemMonitor: any
local EventService: any

function TestOrderHandler:Init(serviceManager: any)
	SystemMonitor = serviceManager:Get("SystemMonitor")
	EventService = serviceManager:Get("EventService")
	
	if not SystemMonitor or not EventService then
		warn("[TestOrder] Peringatan: Gagal mendapatkan dependensi.")
		return
	end

	-- Setiap ada pemain baru, mulai simulasi untuknya
	Players.PlayerAdded:Connect(function(player)
		self:_startOrderSimulationForPlayer(player)
	end)
	
	SystemMonitor:Log("TestOrder", "INFO", "INIT_SUCCESS", "Modul TestOrder siap mensimulasikan order.")
end

function TestOrderHandler:_startOrderSimulationForPlayer(player: Player)
	task.spawn(function()
		-- Tunggu beberapa detik setelah pemain masuk
		task.wait(5)
		
		-- Pastikan pemain masih ada di server
		if not player or not player.Parent then return end
		
		local orderData = {
			from = "Restoran Cepat Saji",
			to = "Perumahan Mekar Jaya",
			payment = 15000,
		}
		
		EventService:FireClient(player, "NewOrderNotification", orderData)
		SystemMonitor:Log("TestOrder", "INFO", "SIMULATION_SENT", ("Simulasi order dikirim ke pemain '%s'."):format(player.Name))
	end)
end

return TestOrderHandler
EOF
print_sub_step "Upgrade 'TestOrder/Handler.lua' berhasil (tanpa perubahan)."

# 3. Upgrade EventService.lua
cat > "$SOURCE_DIR/Core/Server/Services/EventService.lua" << 'EOF'
--!strict
--[[
	@project OVHL_OJOL
	@file EventService.lua
	@author OmniverseHighland + AI Co-Dev System
	@version 2.0.2
	
	@description
	Wrapper komunikasi client-server. Versi ini menambahkan
	event untuk notifikasi order.
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
	-- Fungsi & Event yang sudah ada
	self:CreateFunction("RequestPlayerData", function(player: Player)
		local DataService = self.sm:Get("DataService")
		if DataService then return DataService:GetData(player) end
		return nil
	end)
	self:CreateEvent("PlayerDataReady")
	
	-- Event baru untuk Fase 5
	self:CreateEvent("NewOrderNotification")
	-- TODO: Tambahkan event untuk respon order dari client
	
	self.SystemMonitor:Log("EventService", "INFO", "INIT_SUCCESS", "EventService dimulai.")
end

function EventService:CreateFunction(name: string, callback: (Player, ...any) -> ...any)
	if self.functions[name] then return end
	local remoteFunc = Instance.new("RemoteFunction")
	remoteFunc.Name = name
	remoteFunc.Parent = self.container
	remoteFunc.OnServerInvoke = callback
	self.functions[name] = remoteFunc
	self.SystemMonitor:Log("EventService", "INFO", "FUNCTION_CREATED", ("Fungsi '%s' dibuat."):format(name))
end

function EventService:CreateEvent(name: string)
	if self.events[name] then return end
	local remoteEvent = Instance.new("RemoteEvent")
	remoteEvent.Name = name
	remoteEvent.Parent = self.container
	self.events[name] = remoteEvent
	self.SystemMonitor:Log("EventService", "INFO", "EVENT_CREATED", ("Event '%s' dibuat."):format(name))
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
print_sub_step "Upgrade 'EventService.lua' berhasil (tanpa perubahan)."

# 4. Upgrade ClientBootstrapper.lua
cat > "$SOURCE_DIR/Core/Client/ClientBootstrapper.lua" << 'EOF'
--!strict
--[[
	@project OVHL_OJOL
	@file ClientBootstrapper.lua
	@author OmniverseHighland + AI Co-Dev System
	@version 1.0.2
	
	@description
	Entry point client. Versi ini menambahkan inisialisasi
	untuk OrderController.
]]

local Core = game:GetService("ReplicatedStorage"):WaitForChild("Core")

-- Client Services
local UIManager = require(Core.Client.Services.UIManager)

-- Client Controllers
local PlayerDataController = require(Core.Client.Controllers.PlayerDataController)
local OrderController = require(Core.Client.Controllers.OrderController)

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
	OrderController:Init(dependencies) -- Inisialisasi controller baru
	
	-- 3. Inisialisasi Modul UI
	MainHUD:Init(dependencies)
	
	print("✅ [ClientBootstrapper] Inisialisasi client selesai.")
end

return ClientBootstrapper
EOF
print_sub_step "Upgrade 'ClientBootstrapper.lua' berhasil (tanpa perubahan)."

# 5. Upgrade StyleService.lua (Menambahkan "resep" warna & font baru)
cat > "$SOURCE_DIR/Core/Server/Services/StyleService.lua" << 'EOF'
--!strict
--[[
	@project OVHL_OJOL
	@file StyleService.lua
	@author OmniverseHighland + AI Co-Dev System
	@version 2.0.1
	
	@description
	Mengelola semua token styling. Versi ini menambahkan
	resep warna untuk tombol Confirm/Decline dan ukuran font.
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
	task.defer(function()
		local EventService = self.sm:Get("EventService")
		if EventService then
			EventService:CreateFunction("GetActiveTheme", function(player: Player)
				return self:GetTheme(self.activeThemeName)
			end)
		end
	end)
	self.SystemMonitor:Log("StyleService", "INFO", "INIT_SUCCESS", "StyleService dimulai.")
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
			Confirm = Color3.fromRGB(76, 175, 80), -- Hijau
			Decline = Color3.fromRGB(244, 67, 54), -- Merah
		},
		Fonts = {
			Header = Enum.Font.GothamBold,
			Body = Enum.Font.Gotham,
		},
		FontSizes = {
			Body = 16,
			Button = 18,
		}
	}
	self.SystemMonitor:Log("StyleService", "INFO", "THEME_LOADED", ("Tema '%s' berhasil dimuat."):format(self.activeThemeName))
end

return StyleService
EOF
print_sub_step "Upgrade 'StyleService.lua' berhasil (menambahkan resep warna & font)."
echo ""

# ==============================================================================
# --- TAHAP 3: SELESAI ---
# ==============================================================================
print_step "DEPLOYMENT FASE 5 SELESAI!"
echo "--------------------------------------------------"
echo "Gameplay loop pertama (notifikasi order) telah diimplementasikan."
echo "Langkah selanjutnya:"
echo "1. Jalankan 'rojo serve' dan sinkronkan ke Roblox Studio."
echo "2. Tekan 'Play'. Tunggu sekitar 5 detik."
echo "3. Notifikasi order akan muncul dengan warna tombol yang lebih baik."
echo "--------------------------------------------------"

