--!strict
--[[
	@file EventService.lua
	@version 3.0.1
	@description Menambahkan event 'UpdatePlayerData'.
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
	self:CreateEvent("UpdateMissionUI")
	self:CreateEvent("MissionCompleted")
	self:CreateEvent("UpdatePlayerData") -- Event baru
	self.SystemMonitor:Log("EventService", "INFO", "INIT_SUCCESS", "EventService dimulai.")
end

function EventService:CreateFunction(name: string, callback: (Player, ...any) -> ...any) if self.functions[name] then return end local rf = Instance.new("RemoteFunction") rf.Name = name rf.Parent = self.container rf.OnServerInvoke = callback self.functions[name] = rf end
function EventService:CreateEvent(name: string) if self.events[name] then return end local re = Instance.new("RemoteEvent") re.Name = name re.Parent = self.container self.events[name] = re end
function EventService:FireClient(player: Player, name: string, ...: any) local remoteEvent = self.events[name] if remoteEvent then remoteEvent:FireClient(player, ...) end end
function EventService:OnClientEvent(name: string, callback: (Player, ...any) -> ()) local remoteEvent = self.events[name] if remoteEvent then remoteEvent.OnServerEvent:Connect(callback) end end

return EventService
