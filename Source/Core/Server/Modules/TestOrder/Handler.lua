--!strict
--[[
	@file TestOrder/Handler.lua
	@version 1.4.2
	@description Kini mengirim info bayaran saat misi selesai.
]]
local Players = game:GetService("Players")
local TestOrderHandler = {}
local activeOrders = {}

function TestOrderHandler:Init(sm: any)
	local SystemMonitor=sm:Get("SystemMonitor")
	local EventService=sm:Get("EventService")
	local ZoneService=sm:Get("ZoneService")
	local DataService=sm:Get("DataService")
	
	local function onMissionCompleted(player: Player)
		local orderData = activeOrders[player]
		if not orderData then return end
		DataService:AddUang(player, orderData.payment)
		EventService:FireClient(player, "MissionCompleted", orderData.payment) -- Kirim info bayaran
		activeOrders[player] = nil
		startOrderSimulationForPlayer(player)
	end

	local function onOrderResponse(player: Player, hasAccepted: boolean)
		local orderData = activeOrders[player]
		if not orderData then return end
		if hasAccepted then
			EventService:FireClient(player, "UpdateMissionUI", orderData)
			ZoneService:CreateZoneForPlayer(player, orderData.destination, function() onMissionCompleted(player) end)
		else
			activeOrders[player] = nil
		end
	end

	function startOrderSimulationForPlayer(player: Player)
		task.spawn(function()
			task.wait(8)
			if not player or not player.Parent or activeOrders[player] then return end
			local char=player.Character
			local root=char and char:FindFirstChild("HumanoidRootPart")
			local sPos=root and root.Position or Vector3.new(0,5,0)
			local dPos=sPos+Vector3.new(math.random(30,60),0,math.random(30,60))
			local oData={id="ORDER-"..math.random(1000,9999),from="Restoran Cepat Saji",to="Perumahan Mekar Jaya",payment=15000,destination=dPos}
			activeOrders[player]=oData
			EventService:FireClient(player,"NewOrderNotification",oData)
		end)
	end

	for _, p in ipairs(Players:GetPlayers()) do startOrderSimulationForPlayer(p) end
	Players.PlayerAdded:Connect(startOrderSimulationForPlayer)
	EventService:OnClientEvent("RespondToOrder",onOrderResponse)
end

return TestOrderHandler
