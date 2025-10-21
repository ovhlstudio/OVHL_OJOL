--!strict
--[[
	@project OVHL_OJOL
	@file SystemMonitor.lua
	@author OmniverseHighland + AI Co-Dev System
	
	@description
	Service terpusat untuk logging, monitoring, dan pelacakan kesehatan sistem.
	Menyediakan format log yang standar untuk memudahkan debugging.
]]

local SystemMonitor = {}

-- ServiceManager di-inject saat inisialisasi
local serviceManager: any

-- Dibuat sebagai singleton karena bersifat global
function SystemMonitor:Initialize(sm: any)
	if serviceManager then return end -- Sudah diinisialisasi
	serviceManager = sm
	self:Log("SystemMonitor", "INFO", "INIT_SUCCESS", "SystemMonitor siap digunakan.")
end

-- Fungsi logging utama
function SystemMonitor:Log(source: string, level: "INFO" | "WARN" | "ERROR", code: string, message: string)
	local logMessage = string.format("[%s] [%s] [%s] %s", source, code, level, message)
	
	if level == "ERROR" then
		warn(logMessage)
	elseif level == "WARN" then
		warn(logMessage)
	else
		print(logMessage)
	end
	
	-- TODO: Integrasi dengan log file atau webhook eksternal di masa depan
end

-- Stub kosong untuk memenuhi kontrak .new() dari Bootstrapper
-- Inisialisasi sebenarnya terjadi di :Initialize()
function SystemMonitor.new()
	return SystemMonitor
end

return SystemMonitor
