--!strict
--[[
	@project OVHL_OJOL
	@file EventService.lua
	@author OmniverseHighland + AI Co-Dev System
	@version 2.0.1
	
	@description
	Menyediakan wrapper yang aman dan terstruktur untuk komunikasi
	client-server menggunakan RemoteEvents dan RemoteFunctions.
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
	-- Membuat RemoteFunction untuk meminta data pemain
	self:CreateFunction("RequestPlayerData", function(player: Player)
		local DataService = self.sm:Get("DataService")
		if DataService then
			return DataService:GetData(player)
		end
		return nil
	end)
	
	-- Membuat RemoteEvent untuk memberi sinyal ke client
	self:CreateEvent("PlayerDataReady")
	
	self.SystemMonitor:Log("EventService", "INFO", "INIT_SUCCESS", "EventService dimulai, container & komponen dasar dibuat.")
end

function EventService:CreateFunction(name: string, callback: (Player, ...any) -> ...any)
	if self.functions[name] then
		self.SystemMonitor:Log("EventService", "WARN", "DUPLICATE_FUNCTION", ("RemoteFunction '%s' sudah ada."):format(name))
		return
	end
	
	local remoteFunc = Instance.new("RemoteFunction")
	remoteFunc.Name = name
	remoteFunc.Parent = self.container
	remoteFunc.OnServerInvoke = callback
	
	self.functions[name] = remoteFunc
	self.SystemMonitor:Log("EventService", "INFO", "FUNCTION_CREATED", ("RemoteFunction '%s' berhasil dibuat."):format(name))
end

function EventService:CreateEvent(name: string)
	if self.events[name] then
		self.SystemMonitor:Log("EventService", "WARN", "DUPLICATE_EVENT", ("RemoteEvent '%s' sudah ada."):format(name))
		return
	end
	
	local remoteEvent = Instance.new("RemoteEvent")
	remoteEvent.Name = name
	remoteEvent.Parent = self.container
	
	self.events[name] = remoteEvent
	self.SystemMonitor:Log("EventService", "INFO", "EVENT_CREATED", ("RemoteEvent '%s' berhasil dibuat."):format(name))
end

function EventService:FireClient(player: Player, name: string, ...: any)
	local remoteEvent = self.events[name]
	if remoteEvent then
		remoteEvent:FireClient(player, ...)
	else
		self.SystemMonitor:Log("EventService", "WARN", "EVENT_NOT_FOUND", ("Mencoba mengirim event '%s' yang tidak ditemukan."):format(name))
	end
end

return EventService
