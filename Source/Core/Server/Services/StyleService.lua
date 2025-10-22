--!strict
--[[ @project OVHL_OJOL @file StyleService.lua ]]
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

function StyleService:Init() task.defer(function() local es = self.sm:Get("EventService") if es then es:CreateFunction("GetActiveTheme", function(p) return self:GetTheme(self.activeThemeName) end) end end) self.SystemMonitor:Log("StyleService", "INFO", "INIT_SUCCESS", "StyleService siap.") end
function StyleService:GetTheme(n) return self.themes[n] end
function StyleService:_LoadThemes() self.themes["Default"] = { Name="Default",Colors={Background=Color3.fromRGB(25,25,25),BackgroundHUD=Color3.fromRGB(10,10,10),TextPrimary=Color3.fromRGB(250,250,250),TextSecondary=Color3.fromRGB(180,180,180),Accent=Color3.fromRGB(50,150,255),Confirm=Color3.fromRGB(76,175,80),Decline=Color3.fromRGB(244,67,54),Surface=Color3.fromRGB(45,45,45),Border=Color3.fromRGB(60,60,60),Success=Color3.fromRGB(76,175,80),Warning=Color3.fromRGB(255,193,7),Error=Color3.fromRGB(244,67,54),Primary=Color3.fromRGB(0,120,215),Secondary=Color3.fromRGB(100,100,100)},Fonts={Header=Enum.Font.GothamBold,Body=Enum.Font.Gotham},FontSizes={Body=16,Button=18,HUD=24}} self.SystemMonitor:Log("StyleService","INFO","THEME_LOADED",("Tema '%s' dimuat."):format(self.activeThemeName)) end

return StyleService
