--!strict
--[[
	@file PlayerDataController.lua
	@version 2.1.0
	@description Kini mendengarkan update data dari server.
]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Core = ReplicatedStorage:WaitForChild("Core")
local Events = ReplicatedStorage:WaitForChild("OVHL_Events")
local Signal = require(Core.Shared.Utils.Signal)

local PlayerDataController = {}
local playerData = nil
PlayerDataController.OnDataReady = Signal.new()
PlayerDataController.OnDataUpdated = Signal.new() -- Sinyal baru

function PlayerDataController:Init(dependencies: {any})
	-- Menunggu sinyal data awal siap
	Events:WaitForChild("PlayerDataReady").OnClientEvent:Connect(function()
		local requestFunc: RemoteFunction = Events:WaitForChild("RequestPlayerData")
		playerData = requestFunc:InvokeServer()
		if playerData then
			PlayerDataController.OnDataReady:Fire(playerData)
		end
	end)
	
	-- Mendengarkan update data berkelanjutan
	Events:WaitForChild("UpdatePlayerData").OnClientEvent:Connect(function(updatedData: table)
		if not playerData then return end
		
		-- Gabungkan data baru ke data lokal
		for key, value in pairs(updatedData) do
			playerData[key] = value
		end
		
		-- Kirim sinyal bahwa data telah di-update
		PlayerDataController.OnDataUpdated:Fire(playerData)
	end)
end

function PlayerDataController:GetData() return playerData end

return PlayerDataController
