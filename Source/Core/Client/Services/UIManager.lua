--!strict
--[[
	@project OVHL_OJOL
	@file UIManager.lua (Client Service)
	@author OmniverseHighland + AI Co-Dev System
	@version 1.2.0
	
	@description
	"Arsitek UI" terpusat. Versi ini menambahkan kemampuan
	untuk membuat UI Tracker Misi.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Events = ReplicatedStorage:WaitForChild("OVHL_Events")

local UIManager = {}

local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
local activeTheme: any
local screens = {}

function UIManager:Init()
	local getThemeFunc: RemoteFunction = Events:WaitForChild("GetActiveTheme")
	activeTheme = getThemeFunc:InvokeServer()
	if activeTheme then
		print("✅ [UIManager] Tema '".. activeTheme.Name .."' berhasil dimuat.")
	end
end

function UIManager:CreateScreen(screenName: string)
	if screens[screenName] then return screens[screenName] end
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = screenName
	screenGui.ResetOnSpawn = false
	screenGui.Parent = playerGui
	screens[screenName] = screenGui
	return screenGui
end

function UIManager:CreateWindow(options: { Parent: GuiObject, Name: string, Size: UDim2, Position: UDim2, AnchorPoint: Vector2? })
	local frame = Instance.new("Frame")
	frame.Name = options.Name
	frame.Size = options.Size
	frame.Position = options.Position
	frame.AnchorPoint = options.AnchorPoint or Vector2.new(0, 0)
	frame.BorderSizePixel = 0
	frame.BackgroundColor3 = activeTheme.Colors.Background
	frame.BackgroundTransparency = 0.2
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = frame
	frame.Parent = options.Parent
	return frame
end

function UIManager:AddTextLabel(options: { Parent: GuiObject, Name: string, Text: string, Size: UDim2, Position: UDim2?, AnchorPoint: Vector2?, TextXAlignment: Enum.TextXAlignment?, TextSize: number? })
	local label = Instance.new("TextLabel")
	label.Name = options.Name
	label.Text = options.Text
	label.Size = options.Size
	label.Position = options.Position or UDim2.fromScale(0, 0)
	label.AnchorPoint = options.AnchorPoint or Vector2.new(0, 0)
	label.TextXAlignment = options.TextXAlignment or Enum.TextXAlignment.Left
	label.BackgroundTransparency = 1
	label.Font = activeTheme.Fonts.Body
	label.TextColor3 = activeTheme.Colors.TextPrimary
	label.TextSize = options.TextSize or activeTheme.FontSizes.Body
	label.Parent = options.Parent
	return label
end

function UIManager:AddButton(options: { Parent: GuiObject, Name: string, Text: string, Size: UDim2, Position: UDim2, AnchorPoint: Vector2? })
	local button = Instance.new("TextButton")
	button.Name = options.Name
	button.Text = options.Text
	button.Size = options.Size
	button.Position = options.Position
	button.AnchorPoint = options.AnchorPoint or Vector2.new(0, 0)
	if options.Name == "AcceptButton" then
		button.BackgroundColor3 = activeTheme.Colors.Confirm
	elseif options.Name == "DeclineButton" then
		button.BackgroundColor3 = activeTheme.Colors.Decline
	else
		button.BackgroundColor3 = activeTheme.Colors.Accent
	end
	button.Font = activeTheme.Fonts.Body
	button.TextColor3 = activeTheme.Colors.TextPrimary
	button.TextSize = activeTheme.FontSizes.Button
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 6)
	corner.Parent = button
	button.Parent = options.Parent
	return button
end

-- Fungsi baru untuk Fase 7
function UIManager:CreateMissionTracker(orderData: {to: string})
	local screen = self:CreateScreen("MissionUI")
	
	if screen:FindFirstChild("MissionTracker") then
		screen.MissionTracker:Destroy()
	end
	
	local trackerWindow = self:CreateWindow({
		Parent = screen,
		Name = "MissionTracker",
		Size = UDim2.new(0.25, 0, 0.1, 0),
		Position = UDim2.new(0.5, 0, 0.9, 0),
		AnchorPoint = Vector2.new(0.5, 0),
	})
	
	self:AddTextLabel({
		Parent = trackerWindow,
		Name = "ObjectiveLabel",
		Text = "Tujuan: " .. orderData.to,
		Size = UDim2.fromScale(0.9, 0.8),
		Position = UDim2.fromScale(0.5, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5),
		TextXAlignment = Enum.TextXAlignment.Center,
		TextSize = 18,
	})
	
	print("✅ [UIManager] UI Mission Tracker berhasil dibuat.")
end

return UIManager
