--!strict
--[[
	@file UIManager.lua
	@version 2.0.1 (FINAL)
	@description Versi final yang stabil dengan varian styling untuk HUD.
]]
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Events = ReplicatedStorage:WaitForChild("OVHL_Events")

local UIManager = {}
local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
local activeTheme: any
local screens = {}

function UIManager:Init()
	local getThemeFunc: RemoteFunction = Events:WaitForChild("GetActiveTheme", 10)
	if getThemeFunc then
		activeTheme = getThemeFunc:InvokeServer()
	end
end

function UIManager:CreateScreen(screenName: string)
	if screens[screenName] then return screens[screenName] end
	local sg = Instance.new("ScreenGui")
	sg.Name = screenName
	sg.ResetOnSpawn = false
	sg.Parent = playerGui
	screens[screenName] = sg
	return sg
end

function UIManager:CreateWindow(options: { Parent: GuiObject, Name: string, Style: string?, Size: UDim2, Position: UDim2, AnchorPoint: Vector2? })
	local f = Instance.new("Frame")
	f.Name = options.Name
	f.Size = options.Size
	f.Position = options.Position
	f.AnchorPoint = options.AnchorPoint or Vector2.new(0, 0)
	f.BorderSizePixel = 0
	if options.Style == "HUD" then
		f.BackgroundColor3 = activeTheme.Colors.BackgroundHUD
	else
		f.BackgroundColor3 = activeTheme.Colors.Background
	end
	f.BackgroundTransparency = 0.2
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, 8)
	c.Parent = f
	f.Parent = options.Parent
	return f
end

function UIManager:AddTextLabel(options: { Parent: GuiObject, Name: string, Style: string?, Text: string, Size: UDim2, Position: UDim2?, AnchorPoint: Vector2?, TextXAlignment: Enum.TextXAlignment?, TextSize: number? })
	local l = Instance.new("TextLabel")
	l.Name = options.Name
	l.Text = options.Text
	l.Size = options.Size
	l.Position = options.Position or UDim2.fromScale(0, 0)
	l.AnchorPoint = options.AnchorPoint or Vector2.new(0, 0)
	l.TextXAlignment = options.TextXAlignment or Enum.TextXAlignment.Left
	l.BackgroundTransparency = 1
	if options.Style == "HUD" then
		l.Font = activeTheme.Fonts.Header
		l.TextSize = activeTheme.FontSizes.HUD
	else
		l.Font = activeTheme.Fonts.Body
		l.TextSize = options.TextSize or activeTheme.FontSizes.Body
	end
	l.TextColor3 = activeTheme.Colors.TextPrimary
	l.Parent = options.Parent
	return l
end

function UIManager:AddButton(options: { Parent: GuiObject, Name: string, Text: string, Size: UDim2, Position: UDim2, AnchorPoint: Vector2? })
	local b = Instance.new("TextButton")
	b.Name = options.Name
	b.Text = options.Text
	b.Size = options.Size
	b.Position = options.Position
	b.AnchorPoint = options.AnchorPoint or Vector2.new(0, 0)
	if options.Name == "AcceptButton" then
		b.BackgroundColor3 = activeTheme.Colors.Confirm
	elseif options.Name == "DeclineButton" then
		b.BackgroundColor3 = activeTheme.Colors.Decline
	else
		b.BackgroundColor3 = activeTheme.Colors.Accent
	end
	b.Font = activeTheme.Fonts.Body
	b.TextColor3 = activeTheme.Colors.TextPrimary
	b.TextSize = activeTheme.FontSizes.Button
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, 6)
	c.Parent = b
	b.Parent = options.Parent
	return b
end

function UIManager:CreateMissionTracker(orderData: { to: string })
	local s = self:CreateScreen("MissionUI")
	if s:FindFirstChild("MissionTracker") then s.MissionTracker:Destroy() end
	local tW = self:CreateWindow({ Parent = s, Name = "MissionTracker", Size = UDim2.new(0.25, 0, 0.1, 0), Position = UDim2.new(0.5, 0, 0.9, 0), AnchorPoint = Vector2.new(0.5, 1) })
	self:AddTextLabel({ Parent = tW, Name = "ObjectiveLabel", Text = "Tujuan: " .. orderData.to, Size = UDim2.fromScale(0.9, 0.8), Position = UDim2.fromScale(0.5, 0.5), AnchorPoint = Vector2.new(0.5, 0.5), TextXAlignment = Enum.TextXAlignment.Center, TextSize = 18 })
end

function UIManager:DestroyMissionTracker()
	local s = screens["MissionUI"]
	if s and s:FindFirstChild("MissionTracker") then
		s.MissionTracker:Destroy()
	end
end

return UIManager
