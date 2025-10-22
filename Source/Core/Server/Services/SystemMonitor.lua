--!strict
--[[ @project OVHL_OJOL @file SystemMonitor.lua (SOP Logging v1.0) ]]
local SystemMonitor = {}
local serviceManager: any
local LOG_PREFIX = "[OVHL SYS MONITOR v1.0] " -- INI PREFIX BARU KITA!

function SystemMonitor:Initialize(sm: any) if serviceManager then return end serviceManager = sm self:Log("SystemMonitor", "INFO", "INIT_SUCCESS", "SystemMonitor siap.") end

function SystemMonitor:Log(source: string, level: string, code: string, message: string)
	-- Tambahin prefix di sini!
	local log = LOG_PREFIX .. string.format("[%s] [%s] [%s] %s", source, code, level, message)
	if level == "ERROR" or level == "WARN" then warn(log) else print(log) end
end

function SystemMonitor.new() return SystemMonitor end -- Singleton
return SystemMonitor
