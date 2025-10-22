#!/bin/bash
# ==============================================================================
# OVHL_OJOL - Fase 6 Deployment Script (Respon Order & Komunikasi Dua Arah)
# Author: OmniverseHighland + AI Co-Dev System
# Version: 6.0.0
#
# Deskripsi:
# Skrip ini mengimplementasikan komunikasi dua arah. Client kini bisa
# mengirim respon (Terima/Tolak) kembali ke server, dan server akan
# mendengarkan serta mencatat respon tersebut.
# ==============================================================================

# --- KONFIGURASI ---
SOURCE_DIR="Source"

# --- FUNGSI BANTUAN ---
function print_header() {
    echo "=================================================="
    echo "🚀  OVHL_OJOL Fase 6 Deployer  🚀"
    echo " (Respon Order & Komunikasi Dua Arah)"
    echo "=================================================="
}

function print_step() {
    echo "✅ [$(date +'%T')] $1"
}

function print_sub_step() {
    echo "   -> $1"
}

# ==============================================================================
# --- TAHAP 1: UPGRADE MODUL & SERVICE ---
# ==============================================================================
print_header
print_step "Memulai upgrade untuk Fase 6..."

# 1. Upgrade EventService.lua
cat > "$SOURCE_DIR/Core/Server/Services/EventService.lua" << 'EOF'
--!strict
--[[
	@project OVHL_OJOL
	@file EventService.lua
	@author OmniverseHighland + AI Co-Dev System
	@version 2.0.3
	
	@description
	Wrapper komunikasi client-server. Versi ini menambahkan
	event untuk respon order dari client ke server.
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
	self:CreateEvent("NewOrderNotification")
	
	-- Event baru untuk Fase 6
	self:CreateEvent("RespondToOrder")
	
	self.SystemMonitor:Log("EventService", "INFO", "INIT_SUCCESS", "EventService dimulai.")
end

function EventService:CreateFunction(name: string, callback: (Player, ...any) -> ...any)
	if self.functions[name] then return end
	local remoteFunc = Instance.new("RemoteFunction")
	remoteFunc.Name = name
	remoteFunc.Parent = self.container
	remoteFunc.OnServerInvoke = callback
	self.functions[name] = remoteFunc
end

function EventService:CreateEvent(name: string)
	if self.events[name] then return end
	local remoteEvent = Instance.new("RemoteEvent")
	remoteEvent.Name = name
	remoteEvent.Parent = self.container
	self.events[name] = remoteEvent
end

function EventService:FireClient(player: Player, name: string, ...: any)
	local remoteEvent = self.events[name]
	if remoteEvent then
		remoteEvent:FireClient(player, ...)
	end
end

-- Fungsi baru untuk mendengarkan event dari client
function EventService:OnClientEvent(name: string, callback: (Player, ...any) -> ())
	local remoteEvent = self.events[name]
	if remoteEvent then
		remoteEvent.OnServerEvent:Connect(callback)
		self.SystemMonitor:Log("EventService", "INFO", "LISTENER_ATTACHED", ("Listener untuk event client '%s' berhasil dipasang."):format(name))
	end
end

return EventService
EOF
print_sub_step "Upgrade 'EventService.lua' berhasil (menambahkan OnClientEvent)."

# 2. Upgrade TestOrder/Handler.lua
cat > "$SOURCE_DIR/Core/Server/Modules/TestOrder/Handler.lua" << 'EOF'
--!strict
--[[
	@project OVHL_OJOL
	@module TestOrder
	@file Handler.lua
	@version 1.2.0
	
	@description
	Logika server untuk modul TestOrder. Versi ini menambahkan
	kemampuan untuk mendengarkan respon order dari client.
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

	-- Pasang listener untuk pemain yang join NANTI
	Players.PlayerAdded:Connect(function(player)
		self:_startOrderSimulationForPlayer(player)
	end)
	
	-- FIX: Tangani pemain yang SUDAH ADA saat modul ini jalan
	for _, player in ipairs(Players:GetPlayers()) do
		self:_startOrderSimulationForPlayer(player)
	end
	
	-- Pasang "kuping" untuk mendengarkan respon dari client
	EventService:OnClientEvent("RespondToOrder", function(player, hasAccepted)
		self:_onOrderResponse(player, hasAccepted)
	end)
	
	SystemMonitor:Log("TestOrder", "INFO", "INIT_SUCCESS", "Modul TestOrder siap mensimulasikan dan menerima respon order.")
end

function TestOrderHandler:_startOrderSimulationForPlayer(player: Player)
	task.spawn(function()
		task.wait(5)
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

function TestOrderHandler:_onOrderResponse(player: Player, hasAccepted: boolean)
	if hasAccepted then
		SystemMonitor:Log("TestOrder", "INFO", "ORDER_ACCEPTED", ("Pemain '%s' MENERIMA order."):format(player.Name))
		-- TODO: Fase 7 - Mulai misi & kirim update UI misi ke client
	else
		SystemMonitor:Log("TestOrder", "INFO", "ORDER_DECLINED", ("Pemain '%s' MENOLAK order."):format(player.Name))
		-- TODO: Bisa tambahkan cooldown sebelum pemain dapat order lagi
	end
end

return TestOrderHandler
EOF
print_sub_step "Upgrade 'TestOrder/Handler.lua' berhasil (menambahkan listener respon)."

# 3. Upgrade OrderController.lua
cat > "$SOURCE_DIR/Core/Client/Controllers/OrderController.lua" << 'EOF'
--!strict
--[[
	@project OVHL_OJOL
	@file OrderController.lua (Client)
	@author OmniverseHighland + AI Co-Dev System
	@version 1.1.0
	
	@description
	Mengelola logika order di client. Versi ini mengirimkan
	respon pemain (Terima/Tolak) kembali ke server.
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
		TextSize = 22,
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
	
	local respondEvent: RemoteEvent = Events:WaitForChild("RespondToOrder")
	
	acceptButton.MouseButton1Click:Connect(function()
		print("✅ Order DITERIMA! Mengirim respon ke server...")
		respondEvent:FireServer(true) -- Kirim respon 'true' (diterima)
		notificationWindow:Destroy()
	end)
	
	declineButton.MouseButton1Click:Connect(function()
		print("❌ Order DITOLAK! Mengirim respon ke server...")
		respondEvent:FireServer(false) -- Kirim respon 'false' (ditolak)
		notificationWindow:Destroy()
	end)
end

return OrderController
EOF
print_sub_step "Upgrade 'OrderController.lua' berhasil (menambahkan FireServer)."
echo ""
# ==============================================================================
# --- TAHAP 2: SELESAI ---
# ==============================================================================
print_step "DEPLOYMENT FASE 6 SELESAI!"
echo "--------------------------------------------------"
echo "Komunikasi dua arah telah diimplementasikan."
echo "Langkah selanjutnya:"
echo "1. Jalankan 'rojo serve' dan sinkronkan ke Roblox Studio."
echo "2. Tekan 'Play' dan tunggu notifikasi order."
echo "3. Klik 'TERIMA' atau 'TOLAK'."
echo "4. Periksa log di sisi SERVER. Anda akan melihat pesan"
echo "   'ORDER_ACCEPTED' atau 'ORDER_DECLINED' dari TestOrder."
echo "--------------------------------------------------"

