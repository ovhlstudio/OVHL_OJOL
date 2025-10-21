--!strict
--[[
	@project OVHL_OJOL
	@file StyleService.lua
	@author OmniverseHighland + AI Co-Dev System
	@version 2.0.0
	
	@description
	Mengelola semua token styling, tema, dan stylesheet untuk UI.
	Menyediakan tema ke client melalui EventService.
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
	-- EventService akan siap setelah semua service di-register
	-- jadi kita tunggu sampai StartAll dipanggil
	task.defer(function()
		local EventService = self.sm:Get("EventService")
		if EventService then
			EventService:CreateFunction("GetActiveTheme", function(player: Player)
				return self:GetTheme(self.activeThemeName)
			end)
		end
	end)

	self.SystemMonitor:Log("StyleService", "INFO", "INIT_SUCCESS", "StyleService dimulai. Tema siap disajikan.")
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
		},
		Fonts = {
			Header = Enum.Font.GothamBold,
			Body = Enum.Font.Gotham,
		},
		Sizes = {
			-- Di masa depan bisa diisi UDim2
		}
	}
	self.SystemMonitor:Log("StyleService", "INFO", "THEME_LOADED", ("Tema '%s' berhasil dimuat."):format(self.activeThemeName))
end

return StyleService
