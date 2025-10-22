--!strict
--[[ @project OVHL_OJOL @file EventService.lua (v1.1 FIXED) ]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local EventService = {}
EventService.__index = EventService

function EventService.new(sm: any)
	local self = setmetatable({}, EventService)
	self.sm = sm
	self.SystemMonitor = sm:Get("SystemMonitor")
	self.container = Instance.new("Folder") self.container.Name = "OVHL_Events" self.container.Parent = ReplicatedStorage
	self.events = {} self.functions = {}
	return self
end

function EventService:Init()
	-- Player Data
	self:CreateFunction("RequestPlayerData", function(p) local ds=self.sm:Get("DataService") return ds and ds:GetData(p) end)
	self:CreateEvent("PlayerDataReady")
	self:CreateEvent("UpdatePlayerData")
	-- Base events (mungkin akan dihapus nanti)
	self:CreateEvent("NewOrderNotification")
	self:CreateEvent("RespondToOrder")
	self:CreateEvent("UpdateMissionUI")
	self:CreateEvent("MissionCompleted")
	-- Admin / Config (jika diperlukan)
	self:CreateFunction("AdminGetConfig") self:CreateFunction("AdminUpdateConfig") self:CreateFunction("AdminReloadModule")
	self:CreateEvent("ConfigUpdated")
	self.SystemMonitor:Log("EventService", "INFO", "INIT_SUCCESS", "EventService siap.")
end

function EventService:CreateFunction(n, cb) if self.functions[n] then return end local rf = Instance.new("RemoteFunction") rf.Name = n rf.Parent = self.container if cb then rf.OnServerInvoke=cb else rf.OnServerInvoke=function(p,...) self.SystemMonitor:Log("EventService","WARN","NO_HANDLER",("Func '%s' dipanggil tanpa handler"):format(n)) return nil end end self.functions[n]=rf end
function EventService:CreateEvent(n) if self.events[n] then return end local re = Instance.new("RemoteEvent") re.Name = n re.Parent = self.container self.events[n] = re end
function EventService:FireClient(p, n, ...) local e = self.events[n] if e then e:FireClient(p, ...) end end
function EventService:OnClientEvent(n, cb) local e = self.events[n] if e then e.OnServerEvent:Connect(cb) end end
function EventService:FireAllClients(n, ...) local e = self.events[n] if e then e:FireAllClients(...) end end
function EventService:InvokeClient(p, n, ...) local f = self.functions[n] if f then return f:InvokeClient(p, ...) end return nil end

return EventService
