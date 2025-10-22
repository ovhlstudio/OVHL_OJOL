#!/bin/bash
# ==============================================================================
# OVHL_OJOL - Fase 7 Deployment Script (UI Misi Aktif)
# Author: OmniverseHighland + AI Co-Dev System
# Version: 7.0.0
#
# Deskripsi:
# Skrip ini menyelesaikan gameplay loop pertama. Setelah pemain menerima
# order, server akan mengirim perintah untuk menampilkan UI misi aktif
# di layar client, menggantikan notifikasi order.
# ==============================================================================

# --- KONFIGURASI ---
SOURCE_DIR="Source"

# --- FUNGSI BANTUAN ---
function print_header() {
    echo "=================================================="
    echo "🚀  OVHL_OJOL Fase 7 Deployer  🚀"
    echo "          (UI Misi Aktif)"
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
print_step "Memulai upgrade untuk Fase 7..."

# 1. Upgrade EventService.lua
cat > "$SOURCE_DIR/Core/Server/Services/EventService.lua" << 'EOF'
--!strict
--[[
	@project OVHL_OJOL
	@file EventService.lua
	@author OmniverseHighland + AI Co-Dev System
	@version 2.0.4
	
	@description
	Wrapper komunikasi client-server. Versi ini menambahkan
	event untuk update UI misi.
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
	self:CreateFunction("RequestPlayerData", function(player: Player)
		local DataService = self.sm:Get("DataService")
		if DataService then return DataService:GetData(player) end
		return nil
	end)
	self:CreateEvent("PlayerDataReady")
	self:CreateEvent("NewOrderNotification")
	self:CreateEvent("RespondToOrder")
	
	-- Event baru untuk Fase 7
	self:CreateEvent("UpdateMissionUI")
	
	self.SystemMonitor:Log("EventService", "INFO", "INIT_SUCCESS", "EventService dimulai.")
end

function EventService:CreateFunction(name: string, callback: (Player, ...any) -> ...any)
	if self.functions[name] then return end
	local remoteFunc = Instance.new("RemoteFunction")
	remoteFunc.Name = name
	remoteFunc.Parent = self.container
	remoteFunc.OnServerInvoke = callback
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

function EventService:OnClientEvent(name: string, callback: (Player, ...any) -> ())
	local remoteEvent = self.events[name]
	if remoteEvent then
		remoteEvent.OnServerEvent:Connect(callback)
	end
end

return EventService
EOF
print_sub_step "Upgrade 'EventService.lua' berhasil (menambahkan UpdateMissionUI)."

# 2. Upgrade TestOrder/Handler.lua
cat > "$SOURCE_DIR/Core/Server/Modules/TestOrder/Handler.lua" << 'EOF'
--!strict
--[[
	@project OVHL_OJOL
	@module TestOrder
	@file Handler.lua
	@version 1.3.0
	
	@description
	Logika server untuk modul TestOrder. Versi ini mengirimkan
	perintah untuk menampilkan UI misi setelah order diterima.
]]

local Players = game:GetService("Players")
local TestOrderHandler = {}

local SystemMonitor: any
local EventService: any
local activeOrders = {} -- [player]: orderData

function TestOrderHandler:Init(serviceManager: any)
	SystemMonitor = serviceManager:Get("SystemMonitor")
	EventService = serviceManager:Get("EventService")
	
	for _, player in ipairs(Players:GetPlayers()) do
		self:_startOrderSimulationForPlayer(player)
	end
	
	Players.PlayerAdded:Connect(function(player)
		self:_startOrderSimulationForPlayer(player)
	end)
	
	EventService:OnClientEvent("RespondToOrder", function(player, hasAccepted)
		self:_onOrderResponse(player, hasAccepted)
	end)
	
	SystemMonitor:Log("TestOrder", "INFO", "INIT_SUCCESS", "Modul TestOrder siap.")
end

function TestOrderHandler:_startOrderSimulationForPlayer(player: Player)
	task.spawn(function()
		task.wait(5)
		if not player or not player.Parent then return end
		
		if activeOrders[player] then return end
		
		local orderData = {
			id = "ORDER-" .. math.random(1000, 9999),
			from = "Restoran Cepat Saji",
			to = "Perumahan Mekar Jaya",
			payment = 15000,
		}
		
		activeOrders[player] = orderData
		
		EventService:FireClient(player, "NewOrderNotification", orderData)
		SystemMonitor:Log("TestOrder", "INFO", "SIMULATION_SENT", ("Order '%s' dikirim ke '%s'."):format(orderData.id, player.Name))
	end)
end

function TestOrderHandler:_onOrderResponse(player: Player, hasAccepted: boolean)
	local orderData = activeOrders[player]
	if not orderData then return end
	
	if hasAccepted then
		SystemMonitor:Log("TestOrder", "INFO", "ORDER_ACCEPTED", ("Pemain '%s' MENERIMA order '%s'."):format(player.Name, orderData.id))
		
		-- Kirim perintah ke client untuk menampilkan UI misi
		EventService:FireClient(player, "UpdateMissionUI", orderData)
		
	else
		SystemMonitor:Log("TestOrder", "INFO", "ORDER_DECLINED", ("Pemain '%s' MENOLAK order '%s'."):format(player.Name, orderData.id))
		activeOrders[player] = nil
	end
end

return TestOrderHandler
EOF
print_sub_step "Upgrade 'TestOrder/Handler.lua' berhasil (mengirim event UI Misi)."

# 3. Upgrade UIManager.lua
cat > "$SOURCE_DIR/Core/Client/Services/UIManager.lua" << 'EOF'
--!strict
--[[
	@project OVHL_OJOL
	@file UIManager.lua (Client Service)
	@author OmniverseHighland + AI Co-Dev System
	@version 1.2.0
	
	@description
	"Arsitek UI" terpusat. Versi ini menambahkan kemampuan
	untuk membuat UI Tracker Misi.
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
	if activeTheme then
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

function UIManager:CreateWindow(options: { Parent: GuiObject, Name: string, Size: UDim2, Position: UDim2, AnchorPoint: Vector2? })
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

function UIManager:AddTextLabel(options: { Parent: GuiObject, Name: string, Text: string, Size: UDim2, Position: UDim2?, AnchorPoint: Vector2?, TextXAlignment: Enum.TextXAlignment?, TextSize: number? })
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
	label.TextSize = options.TextSize or activeTheme.FontSizes.Body
	label.Parent = options.Parent
	return label
end

function UIManager:AddButton(options: { Parent: GuiObject, Name: string, Text: string, Size: UDim2, Position: UDim2, AnchorPoint: Vector2? })
	local button = Instance.new("TextButton")
	button.Name = options.Name
	button.Text = options.Text
	button.Size = options.Size
	button.Position = options.Position
	button.AnchorPoint = options.AnchorPoint or Vector2.new(0, 0)
	if options.Name == "AcceptButton" then
		button.BackgroundColor3 = activeTheme.Colors.Confirm
	elseif options.Name == "DeclineButton" then
		button.BackgroundColor3 = activeTheme.Colors.Decline
	else
		button.BackgroundColor3 = activeTheme.Colors.Accent
	end
	button.Font = activeTheme.Fonts.Body
	button.TextColor3 = activeTheme.Colors.TextPrimary
	button.TextSize = activeTheme.FontSizes.Button
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 6)
	corner.Parent = button
	button.Parent = options.Parent
	return button
end

-- Fungsi baru untuk Fase 7
function UIManager:CreateMissionTracker(orderData: {to: string})
	local screen = self:CreateScreen("MissionUI")
	
	if screen:FindFirstChild("MissionTracker") then
		screen.MissionTracker:Destroy()
	end
	
	local trackerWindow = self:CreateWindow({
		Parent = screen,
		Name = "MissionTracker",
		Size = UDim2.new(0.25, 0, 0.1, 0),
		Position = UDim2.new(0.5, 0, 0.9, 0),
		AnchorPoint = Vector2.new(0.5, 1),
	})
	
	self:AddTextLabel({
		Parent = trackerWindow,
		Name = "ObjectiveLabel",
		Text = "Tujuan: " .. orderData.to,
		Size = UDim2.fromScale(0.9, 0.8),
		Position = UDim2.fromScale(0.5, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5),
		TextXAlignment = Enum.TextXAlignment.Center,
		TextSize = 18,
	})
	
	print("✅ [UIManager] UI Mission Tracker berhasil dibuat.")
end

return UIManager
EOF
print_sub_step "Upgrade 'UIManager.lua' berhasil (menambahkan CreateMissionTracker)."

# 4. Upgrade OrderController.lua
cat > "$SOURCE_DIR/Core/Client/Controllers/OrderController.lua" << 'EOF'
--!strict
--[[
	@project OVHL_OJOL
	@file OrderController.lua (Client)
	@author OmniverseHighland + AI Co-Dev System
	@version 1.2.0
	
	@description
	Mengelola logika order di client. Versi ini juga mendengarkan
	perintah untuk menampilkan UI Misi.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Events = ReplicatedStorage:WaitForChild("OVHL_Events")

local OrderController = {}
local UIManager: any

function OrderController:Init(dependencies: {UIManager: any})
	UIManager = dependencies.UIManager
	
	Events:WaitForChild("NewOrderNotification").OnClientEvent:Connect(function(orderData)
		self:_showOrderNotification(orderData)
	end)
	
	-- Dengarkan perintah untuk update UI Misi dari server
	Events:WaitForChild("UpdateMissionUI").OnClientEvent:Connect(function(orderData)
		self:_showMissionTracker(orderData)
	end)
end

function OrderController:_showOrderNotification(orderData: {from: string, to: string, payment: number})
	local screen = UIManager:CreateScreen("NotificationUI")
	if screen:FindFirstChild("OrderNotification") then screen.OrderNotification:Destroy() end
	
	local notificationWindow = UIManager:CreateWindow({ Parent = screen, Name = "OrderNotification", Size = UDim2.fromScale(0.3, 0.25), Position = UDim2.fromScale(0.5, 0.4), AnchorPoint = Vector2.new(0.5, 0.5) })
	
	UIManager:AddTextLabel({ Parent = notificationWindow, Name = "Title", Text = "ORDER BARU!", Size = UDim2.fromScale(1, 0.2), TextXAlignment = Enum.TextXAlignment.Center, TextSize = 22 })
	
	local detailsText = string.format("Dari: %s\nTujuan: %s\nBayaran: Rp. %d", orderData.from, orderData.to, orderData.payment)
	UIManager:AddTextLabel({ Parent = notificationWindow, Name = "Details", Text = detailsText, Size = UDim2.new(0.9, 0, 0.4, 0), Position = UDim2.fromScale(0.5, 0.45), AnchorPoint = Vector2.new(0.5, 0.5), TextXAlignment = Enum.TextXAlignment.Left })
	
	local acceptButton = UIManager:AddButton({ Parent = notificationWindow, Name = "AcceptButton", Text = "TERIMA", Size = UDim2.new(0.4, 0, 0.2, 0), Position = UDim2.fromScale(0.25, 0.85), AnchorPoint = Vector2.new(0.5, 0.5) })
	
	local declineButton = UIManager:AddButton({ Parent = notificationWindow, Name = "DeclineButton", Text = "TOLAK", Size = UDim2.new(0.4, 0, 0.2, 0), Position = UDim2.fromScale(0.75, 0.85), AnchorPoint = Vector2.new(0.5, 0.5) })
	
	local respondEvent: RemoteEvent = Events:WaitForChild("RespondToOrder")
	
	acceptButton.MouseButton1Click:Connect(function()
		respondEvent:FireServer(true)
		notificationWindow:Destroy()
	end)
	
	declineButton.MouseButton1Click:Connect(function()
		respondEvent:FireServer(false)
		notificationWindow:Destroy()
	end)
end

-- Fungsi baru untuk Fase 7
function OrderController:_showMissionTracker(orderData: {to: string})
	UIManager:CreateMissionTracker(orderData)
end

return OrderController
EOF
print_sub_step "Upgrade 'OrderController.lua' berhasil (mendengarkan event UI Misi)."
echo ""

# ==============================================================================
# --- TAHAP 2: SELESAI ---
# ==============================================================================
print_step "DEPLOYMENT FASE 7 SELESAI!"
echo "--------------------------------------------------"
echo "Gameplay loop pertama kini telah lengkap."
echo "Langkah selanjutnya:"
echo "1. Jalankan 'rojo serve' dan sinkronkan ke Roblox Studio."
echo "2. Tekan 'Play' dan tunggu notifikasi order."
echo "3. Klik 'TERIMA'."
echo "4. Notifikasi akan hilang dan digantikan oleh UI Misi Aktif"
echo "   di bagian bawah tengah layar."
echo "--------------------------------------------------"

