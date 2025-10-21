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
