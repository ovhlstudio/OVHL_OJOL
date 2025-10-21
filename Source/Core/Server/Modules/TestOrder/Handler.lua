--!strict
--[[
	@project OVHL_OJOL
	@module TestOrder
	@file Handler.lua
	
	@description
	Logika server untuk modul TestOrder.
]]

local TestOrderHandler = {}

local SystemMonitor: any

function TestOrderHandler:Init(serviceManager: any)
	SystemMonitor = serviceManager:Get("SystemMonitor")
	
	if not SystemMonitor then
		warn("[TestOrder] Peringatan: Gagal mendapatkan SystemMonitor.")
		return
	end
	
	SystemMonitor:Log("TestOrder", "INFO", "INIT_SUCCESS", "Modul TestOrder berhasil diinisialisasi!")
	
	-- Contoh penggunaan service lain
	local EventService = serviceManager:Get("EventService")
	if EventService then
		SystemMonitor:Log("TestOrder", "INFO", "DEP_CHECK", "EventService berhasil diakses.")
	end
end

function TestOrderHandler:Shutdown()
	if SystemMonitor then
		SystemMonitor:Log("TestOrder", "INFO", "SHUTDOWN", "Modul TestOrder dihentikan.")
	end
end

return TestOrderHandler
