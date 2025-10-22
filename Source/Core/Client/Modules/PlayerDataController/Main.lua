--!strict
--[[ @file PlayerDataController/Main.lua (v2.1.0) ]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Core = ReplicatedStorage:WaitForChild("Core")
local Events = ReplicatedStorage:WaitForChild("OVHL_Events")
local Signal = require(Core.Shared.Utils.Signal)

local PlayerDataController = {}
local playerData = nil
PlayerDataController.OnDataReady = Signal.new()
PlayerDataController.OnDataUpdated = Signal.new()

function PlayerDataController:Init(DI) -- DI Container masuk sini
	print("   [PlayerDataController] Init() dipanggil...")
	Events:WaitForChild("PlayerDataReady").OnClientEvent:Connect(function()
		print("   [PlayerDataController] Menerima sinyal PlayerDataReady dari server!")
		local requestFunc: RemoteFunction = Events:WaitForChild("RequestPlayerData")
		playerData = requestFunc:InvokeServer()
		if playerData then
			print("   [PlayerDataController] Data player berhasil diambil:", playerData)
			PlayerDataController.OnDataReady:Fire(playerData) -- Kasih tau modul lain
		else
			warn("   [PlayerDataController] Gagal mengambil data player dari server (nil).")
		end
	end)
	Events:WaitForChild("UpdatePlayerData").OnClientEvent:Connect(function(updatedData: table)
		if not playerData then return end
		print("   [PlayerDataController] Menerima update data:", updatedData)
		for key, value in pairs(updatedData) do playerData[key] = value end
		PlayerDataController.OnDataUpdated:Fire(playerData) -- Kasih tau modul lain
	end)
	print("   [PlayerDataController] Listener event siap.")
end
function PlayerDataController:GetData() return playerData end
return PlayerDataController
