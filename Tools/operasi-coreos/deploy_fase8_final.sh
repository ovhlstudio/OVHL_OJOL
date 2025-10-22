#!/bin/bash
# ==============================================================================
# OVHL_OJOL - Fase 8 Finalisasi Script
# Author: OmniverseHighland + AI Co-Dev System
# Version: 8.2.0 (FINAL)
#
# Deskripsi:
# Skrip ini adalah sentuhan akhir untuk Fase 8. Tidak ada perubahan logika.
# Fokus utama adalah memperbaiki tampilan Money HUD (posisi, font, warna)
# agar sesuai dengan yang direncanakan.
# ==============================================================================

# --- KONFIGURASI ---
SOURCE_DIR="Source"

# --- FUNGSI BANTUAN ---
function print_header() {
    echo "=================================================="
    echo "🚀  OVHL_OJOL Fase 8 Finalizer v8.2.0  🚀"
    echo "      (Perbaikan Visual HUD)"
    echo "=================================================="
}

function print_step() {
    echo "✅ [$(date +'%T')] $1"
}

function print_sub_step() {
    echo "   -> $1"
}

# ==============================================================================
# --- TAHAP 1: MENIMPA FILE-FILE UI ---
# ==============================================================================
print_header
print_step "Memulai finalisasi visual untuk Fase 8..."

# 1. Tulis Ulang StyleService.lua (FINAL)
cat > "$SOURCE_DIR/Core/Server/Services/StyleService.lua" << 'EOF'
--!strict
--[[
	@file StyleService.lua
	@version 3.0.1 (FINAL)
	@description Versi final yang stabil dengan token style untuk HUD.
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

function StyleService:GetTheme(name: string)
	return self.themes[name]
end

function StyleService:_LoadThemes()
	self.themes["Default"] = {
		Name = "Default",
		Colors = {
			Background = Color3.fromRGB(25, 25, 25),
			BackgroundHUD = Color3.fromRGB(10, 10, 10),
			TextPrimary = Color3.fromRGB(250, 250, 250),
			Accent = Color3.fromRGB(50, 150, 255),
			Confirm = Color3.fromRGB(76, 175, 80),
			Decline = Color3.fromRGB(244, 67, 54),
		},
		Fonts = {
			Header = Enum.Font.GothamBold,
			Body = Enum.Font.Gotham,
		},
		FontSizes = {
			Body = 16,
			Button = 18,
			HUD = 24,
		}
	}
	self.SystemMonitor:Log("StyleService", "INFO", "THEME_LOADED", ("Tema '%s' berhasil dimuat."):format(self.activeThemeName))
end

return StyleService
EOF
print_sub_step "Perbaikan 'StyleService.lua' selesai."

# 2. Tulis Ulang UIManager.lua (FINAL)
cat > "$SOURCE_DIR/Core/Client/Services/UIManager.lua" << 'EOF'
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
EOF
print_sub_step "Perbaikan 'UIManager.lua' selesai."

# 3. Tulis Ulang MainHUD.lua (FINAL)
cat > "$SOURCE_DIR/Core/Client/UI/MainHUD.lua" << 'EOF'
--!strict
--[[
	@file MainHUD.lua
	@version 2.0.1 (FINAL)
	@description Versi final yang stabil dengan posisi dan style HUD Uang yang benar.
]]
local Core = game:GetService("ReplicatedStorage"):WaitForChild("Core")
local PlayerDataController = require(Core.Client.Controllers.PlayerDataController)
local MainHUD = {}
local moneyLabel: TextLabel

function MainHUD:Init(dependencies: {UIManager: any})
	local UIManager = dependencies.UIManager
	
	PlayerDataController.OnDataReady:Connect(function(playerData)
		local screen = UIManager:CreateScreen("MainHUD")
		
		if screen:FindFirstChild("MoneyWindow") then screen.MoneyWindow:Destroy() end
		
		local moneyWindow = UIManager:CreateWindow({
			Parent = screen,
			Name = "MoneyWindow",
			Style = "HUD", -- Memberi tahu UIManager untuk pakai style HUD
			Size = UDim2.new(0.2, 0, 0.08, 0),
			Position = UDim2.new(0.5, 0, 0.02, 0), -- Tengah Atas
			AnchorPoint = Vector2.new(0.5, 0), -- Anchor di tengah atas
		})
		
		moneyLabel = UIManager:AddTextLabel({
			Parent = moneyWindow,
			Name = "MoneyLabel",
			Style = "HUD", -- Memberi tahu UIManager untuk pakai style HUD
			Text = "Rp. " .. tostring(playerData.Uang),
			Size = UDim2.fromScale(0.9, 0.8),
			Position = UDim2.fromScale(0.5, 0.5),
			AnchorPoint = Vector2.new(0.5, 0.5),
			TextXAlignment = Enum.TextXAlignment.Center,
		})
	end)
end

return MainHUD
EOF
print_sub_step "Perbaikan 'MainHUD.lua' selesai."
echo ""

# ==============================================================================
# --- TAHAP 2: SELESAI ---
# ==============================================================================
print_step "FINALISASI FASE 8 SELESAI!"
echo "--------------------------------------------------"
echo "Semua file UI telah diperbaiki."
echo "Langkah selanjutnya:"
echo "1. Jalankan 'rojo serve' dan sinkronkan ke Roblox Studio."
echo "2. Tekan 'Play'. HUD Uang kini HARUSNYA berada di tengah atas"
echo "   dengan font yang lebih besar dan tebal."
echo "--------------------------------------------------"
