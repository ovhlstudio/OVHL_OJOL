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
		
		-- Hanya kirim order jika pemain tidak sedang ada order
		if activeOrders[player] then return end
		
		local orderData = {
			id = "ORDER-" .. math.random(1000, 9999),
			from = "Restoran Cepat Saji",
			to = "Perumahan Mekar Jaya",
			payment = 15000,
		}
		
		activeOrders[player] = orderData -- Simpan order yang dikirim
		
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
		activeOrders[player] = nil -- Hapus order
	end
end

return TestOrderHandler
