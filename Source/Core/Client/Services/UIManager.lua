--!strict
--[[
	@project OVHL_OJOL
	@file UIManager.lua (Client Service)
	@author OmniverseHighland + AI Co-Dev System
	
	@description
	"Arsitek UI" terpusat. Bertanggung jawab untuk membuat, men-style,
	dan mengelola semua elemen UI secara terprogram. Modul lain
	hanya memberikan perintah, UIManager yang mengeksekusi.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Events = ReplicatedStorage:WaitForChild("OVHL_Events")

local UIManager = {}

local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
local activeTheme: any
local screens = {} -- Cache untuk ScreenGuis yang sudah dibuat

function UIManager:Init()
	-- Meminta tema dari server saat UIManager pertama kali diinisialisasi
	local getThemeFunc: RemoteFunction = Events:WaitForChild("GetActiveTheme")
	activeTheme = getThemeFunc:InvokeServer()
	
	if not activeTheme then
		warn("❌ [UIManager] Gagal mendapatkan tema dari StyleService.")
	else
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

-- Contoh fungsi "arsitek"
function UIManager:CreateWindow(options: {
	Parent: GuiObject,
	Name: string,
	Size: UDim2,
	Position: UDim2,
	AnchorPoint: Vector2?,
})
	local frame = Instance.new("Frame")
	frame.Name = options.Name
	frame.Size = options.Size
	frame.Position = options.Position
	frame.AnchorPoint = options.AnchorPoint or Vector2.new(0, 0)
	frame.BorderSizePixel = 0
	
	-- Styling dari tema
	frame.BackgroundColor3 = activeTheme.Colors.Background
	frame.BackgroundTransparency = 0.2
	
	-- Menambahkan hiasan modern
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = frame
	
	frame.Parent = options.Parent
	return frame
end

function UIManager:AddTextLabel(options: {
	Parent: GuiObject,
	Name: string,
	Text: string,
	Size: UDim2,
	Position: UDim2?,
	TextXAlignment: Enum.TextXAlignment?,
})
	local label = Instance.new("TextLabel")
	label.Name = options.Name
	label.Text = options.Text
	label.Size = options.Size
	label.Position = options.Position or UDim2.fromScale(0, 0)
	label.TextXAlignment = options.TextXAlignment or Enum.TextXAlignment.Left
	label.BackgroundTransparency = 1
	
	-- Styling dari tema
	label.Font = activeTheme.Fonts.Body
	label.TextColor3 = activeTheme.Colors.TextPrimary
	
	label.Parent = options.Parent
	return label
end

return UIManager
