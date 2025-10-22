--!strict
--[[ @project OVHL_OJOL @file Config.lua (Defaults) ]]
local Config = {
	game_name = "Ojol Roleplay", version = "1.0.0", enable_debug_mode = true,
	autosave_interval = 300, datastore_retry_attempts = 3, datastore_retry_delay = 5,
	enable_hot_reload = false, -- Belum diimplementasi
	economy_multiplier = 1.0,
	admin_user_ids = {1}, -- Owner Studio
	default_ui_theme = "Default",
	-- Config Gameplay (akan di-expand)
	traffic_default = 0.5,
	base_spawn_rate = 10, -- Detik antar spawn NPC
	player_count_scaling_factor = 0.8, -- Spawn rate = base / (playerCount * factor)
}
return table.freeze(Config)
