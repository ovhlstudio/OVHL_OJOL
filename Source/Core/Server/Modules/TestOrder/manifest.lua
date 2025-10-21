--!strict
--[[
	Manifest untuk Modul TestOrder
]]
return {
	name = "TestOrder",
	version = "0.1.0",
	description = "Modul sederhana untuk testing Core OS.",
	
	-- Daftar service yang dibutuhkan oleh modul ini
	depends = {
		"SystemMonitor",
		"EventService",
	},
}
