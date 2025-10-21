--!strict
--[[
	@project OVHL_OJOL
	@file Config.lua
	@author OmniverseHighland + AI Co-Dev System
	
	@description
	Manifest Konfigurasi Global.
	Semua pengaturan sistem yang bersifat statis dan dapat diubah
	ada di sini. Akan dibaca oleh Bootstrapper saat startup.
]]

local Config = {
	-- Pengaturan Umum
	game_name = "Ojol Roleplay",
	version = "1.0.0",
	enable_debug_mode = true, -- Aktifkan log dan monitor tambahan

	-- Pengaturan DataService
	autosave_interval = 300, -- Interval autosave data pemain (dalam detik)
	datastore_retry_attempts = 3, -- Jumlah percobaan ulang jika DataStore gagal
	datastore_retry_delay = 5, -- Jeda antar percobaan ulang (dalam detik)
	
	-- Pengaturan Hot Reload
	enable_hot_reload = true, -- Mengizinkan reload modul saat runtime

	-- Pengaturan Ekonomi
	economy_multiplier = 1.0, -- Pengali pendapatan default

	-- Pengaturan Admin
	admin_user_ids = {
		1, -- UserId Roblox Studio (Owner)
		-- Tambahkan ID admin lain di sini
	},

	-- Pengaturan StyleService (UI)
	default_ui_theme = "default",
}

return table.freeze(Config)
