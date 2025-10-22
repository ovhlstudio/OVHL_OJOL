--!strict
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
    
    -- Existing events
    self:CreateEvent("PlayerDataReady")
    self:CreateEvent("NewOrderNotification")
    self:CreateEvent("RespondToOrder")
    self:CreateEvent("UpdateMissionUI")
    self:CreateEvent("MissionCompleted")
    self:CreateEvent("UpdatePlayerData")
    
    -- NEW ADMIN EVENTS
    self:CreateFunction("AdminGetConfig")
    self:CreateFunction("AdminUpdateConfig") 
    self:CreateFunction("AdminReloadModule")
    self:CreateEvent("ConfigUpdated")
    
    self.SystemMonitor:Log("EventService", "INFO", "INIT_SUCCESS", "EventService dimulai.")
end

function EventService:CreateFunction(name: string, callback: (Player, ...any) -> ...any) 
    if self.functions[name] then return end 
    local rf = Instance.new("RemoteFunction") 
    rf.Name = name 
    rf.Parent = self.container 
    if callback then
        rf.OnServerInvoke = callback
    else
        -- Default handler untuk admin functions
        rf.OnServerInvoke = function(player, ...)
            self.SystemMonitor:Log("EventService", "WARN", "NO_HANDLER", ("RemoteFunction '%s' dipanggil tapi belum ada handler"):format(name))
            return nil
        end
    end
    self.functions[name] = rf 
end

function EventService:CreateEvent(name: string) 
    if self.events[name] then return end 
    local re = Instance.new("RemoteEvent") 
    re.Name = name 
    re.Parent = self.container 
    self.events[name] = re 
end

function EventService:FireClient(player: Player, name: string, ...: any) 
    local remoteEvent = self.events[name] 
    if remoteEvent then 
        remoteEvent:FireClient(player, ...) 
    end 
end

function EventService:OnClientEvent(name: string, callback: (Player, ...any) -> ()) 
    local remoteEvent = self.events[name] 
    if remoteEvent then 
        remoteEvent.OnServerEvent:Connect(callback) 
    end 
end

function EventService:FireAllClients(name: string, ...: any)
    local remoteEvent = self.events[name]
    if remoteEvent then
        remoteEvent:FireAllClients(...)
    end
end

return EventService
