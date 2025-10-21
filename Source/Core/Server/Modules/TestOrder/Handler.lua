--!strict
--[[
	@project OVHL_OJOL
	@module TestOrder
	@file Handler.lua
	@version 1.4.1
]]

local Players = game:GetService("Players")
local TestOrderHandler = {}
local activeOrders = {}

function TestOrderHandler:Init(sm: any)
	local SystemMonitor = sm:Get("SystemMonitor")
	local EventService = sm:Get("EventService")
	local ZoneService = sm:Get("ZoneService")
	local DataService = sm:Get("DataService")
	
	local function onMissionCompleted(player: Player)
		local orderData = activeOrders[player]
		if not orderData then return end
		SystemMonitor:Log("TestOrder", "INFO", "MISSION_COMPLETED", ("Pemain '%s' MENYELESAIKAN order '%s'."):format(player.Name, orderData.id))
		DataService:AddUang(player, orderData.payment)
		EventService:FireClient(player, "MissionCompleted")
		activeOrders[player] = nil
		startOrderSimulationForPlayer(player)
	end

	local function onOrderResponse(player: Player, hasAccepted: boolean)
		local orderData = activeOrders[player]
		if not orderData then return end
		if hasAccepted then
			SystemMonitor:Log("TestOrder", "INFO", "ORDER_ACCEPTED", ("Pemain '%s' MENERIMA order '%s'."):format(player.Name, orderData.id))
			EventService:FireClient(player, "UpdateMissionUI", orderData)
			ZoneService:CreateZoneForPlayer(player, orderData.destination, function() onMissionCompleted(player) end)
		else
			SystemMonitor:Log("TestOrder", "INFO", "ORDER_DECLINED", ("Pemain '%s' MENOLAK order '%s'."):format(player.Name, orderData.id))
			activeOrders[player] = nil
		end
	end

	function startOrderSimulationForPlayer(player: Player)
		task.spawn(function()
			task.wait(8)
			if not player or not player.Parent or activeOrders[player] then return end
			local character = player.Character
			local rootPart = character and character:FindFirstChild("HumanoidRootPart")
			local spawnPos = rootPart and rootPart.Position or Vector3.new(0, 5, 0)
			local destPos = spawnPos + Vector3.new(math.random(30, 60), 0, math.random(30, 60))
			local orderData = {
				id = "ORDER-" .. math.random(1000, 9999), from = "Restoran Cepat Saji",
				to = "Perumahan Mekar Jaya", payment = 15000, destination = destPos,
			}
			activeOrders[player] = orderData
			EventService:FireClient(player, "NewOrderNotification", orderData)
		end)
	end

	for _, player in ipairs(Players:GetPlayers()) do startOrderSimulationForPlayer(player) end
	Players.PlayerAdded:Connect(startOrderSimulationForPlayer)
	EventService:OnClientEvent("RespondToOrder", onOrderResponse)
	
	SystemMonitor:Log("TestOrder", "INFO", "INIT_SUCCESS", "Modul TestOrder siap.")
end

return TestOrderHandler
