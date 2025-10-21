--!strict
--[[
	@project OVHL_OJOL
	@file StyleService.lua
	@author OmniverseHighland + AI Co-Dev System
	@version 2.0.1
	
	@description
	Mengelola semua token styling. Versi ini menambahkan
	resep warna untuk tombol Confirm/Decline dan ukuran font.
]]

local StyleService = {}
StyleService.__index = StyleService

function StyleService.new(sm: any)
	local self = setmetatable({}, StyleService)
	self.sm = sm
	self.SystemMonitor = sm:Get("SystemMonitor")
	self.themes = {}
	self.activeThemeName = "Default"
	
	self:_LoadThemes()
	return self
end

function StyleService:Init()
	task.defer(function()
		local EventService = self.sm:Get("EventService")
		if EventService then
			EventService:CreateFunction("GetActiveTheme", function(player: Player)
				return self:GetTheme(self.activeThemeName)
			end)
		end
	end)
	self.SystemMonitor:Log("StyleService", "INFO", "INIT_SUCCESS", "StyleService dimulai.")
end

function StyleService:GetTheme(themeName: string)
	return self.themes[themeName]
end

function StyleService:_LoadThemes()
	self.themes["Default"] = {
		Name = "Default",
		Colors = {
			Background = Color3.fromRGB(25, 25, 25),
			TextPrimary = Color3.fromRGB(250, 250, 250),
			TextSecondary = Color3.fromRGB(180, 180, 180),
			Accent = Color3.fromRGB(50, 150, 255),
			Confirm = Color3.fromRGB(76, 175, 80), -- Hijau
			Decline = Color3.fromRGB(244, 67, 54), -- Merah
		},
		Fonts = {
			Header = Enum.Font.GothamBold,
			Body = Enum.Font.Gotham,
		},
		FontSizes = {
			Body = 16,
			Button = 18,
		}
	}
	self.SystemMonitor:Log("StyleService", "INFO", "THEME_LOADED", ("Tema '%s' berhasil dimuat."):format(self.activeThemeName))
end

return StyleService
