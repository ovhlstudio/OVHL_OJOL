--!strict
--[[
	@project OVHL_OJOL
	@file ZoneService.lua (Server Service)
	@author OmniverseHighland + AI Co-Dev System
	
	@description
	Mengelola pembuatan dan deteksi zona interaktif di dalam Workspace.
]]

local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local ZoneService = {}
ZoneService.__index = ZoneService
local activeZones = {}

function ZoneService.new(sm: any)
	local self = setmetatable({}, ZoneService)
	self.sm = sm
	self.SystemMonitor = sm:Get("SystemMonitor")
	return self
end

function ZoneService:Init()
	self.SystemMonitor:Log("ZoneService", "INFO", "INIT_SUCCESS", "ZoneService siap digunakan.")
end

function ZoneService:CreateZoneForPlayer(player: Player, position: Vector3, onTouchedCallback: () -> ())
	self:DestroyZoneForPlayer(player)
	local zonePart = Instance.new("Part")
	zonePart.Name = "MissionZone_" .. player.Name
	zonePart.Size = Vector3.new(15, 1, 15)
	zonePart.Position = position
	zonePart.Anchored = true
	zonePart.CanCollide = false
	zonePart.Transparency = 0.7
	zonePart.Color = Color3.fromRGB(76, 175, 80)
	zonePart.Shape = Enum.PartType.Cylinder
	zonePart.Parent = Workspace
	local connection = zonePart.Touched:Connect(function(otherPart)
		local character = otherPart.Parent
		if not character then return end
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		if not humanoid then return end
		local touchingPlayer = Players:GetPlayerFromCharacter(character)
		if touchingPlayer == player then
			onTouchedCallback()
			self:DestroyZoneForPlayer(player)
		end
	end)
	activeZones[player] = {part = zonePart, connection = connection}
	self.SystemMonitor:Log("ZoneService", "INFO", "ZONE_CREATED", ("Zona tujuan dibuat untuk '%s'"):format(player.Name))
end

function ZoneService:DestroyZoneForPlayer(player: Player)
	local zoneData = activeZones[player]
	if zoneData then
		zoneData.connection:Disconnect()
		zoneData.part:Destroy()
		activeZones[player] = nil
	end
end

return ZoneService
