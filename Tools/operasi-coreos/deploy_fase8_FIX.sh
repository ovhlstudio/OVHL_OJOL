#!/bin/bash
# ==============================================================================
# OVHL_OJOL - Fase 8 Perbaikan Script
# Author: OmniverseHighland + AI Co-Dev System
# Version: 8.1.0 (FIX)
#
# Deskripsi:
# Skrip ini adalah versi perbaikan dari Fase 8. Fokus utama adalah
# menulis ulang StyleService dan EventService dengan rapi untuk
# memperbaiki bug kritis dan race condition.
# ==============================================================================

# --- KONFIGURASI ---
SOURCE_DIR="Source"

# --- FUNGSI BANTUAN ---
function print_header() {
    echo "=================================================="
    echo "🚀  OVHL_OJOL Fase 8 Deployer v8.1.0 (FIX) 🚀"
    echo "       (Misi Nyata + Perbaikan Total)"
    echo "=================================================="
}

function print_step() {
    echo "✅ [$(date +'%T')] $1"
}

function print_sub_step() {
    echo "   -> $1"
}

# ==============================================================================
# --- TAHAP 1: MENULIS ULANG FILE YANG RUSAK ---
# ==============================================================================
print_header
print_step "Memulai perbaikan kritis untuk Fase 8..."

# 1. Tulis Ulang StyleService.lua (FIX KRITIS)
cat > "$SOURCE_DIR/Core/Server/Services/StyleService.lua" << 'EOF'
--!strict
--[[
	@file StyleService.lua
	@version 3.0.0 (REWRITE)
	@description Ditulis ulang dengan rapi. Memperbaiki kesalahan pemanggilan
	             metode internal dan race condition pembuatan RemoteFunction.
]]
local StyleService = {}
StyleService.__index = StyleService

function StyleService.new(sm: any)
	local self = setmetatable({}, StyleService)
	self.sm = sm
	self.SystemMonitor = sm:Get("SystemMonitor")
	self.themes = {}
	self.activeThemeName = "Default"
	
	-- Panggil metode internal dengan benar menggunakan ':'
	self:_LoadThemes() 
	
	return self
end

function StyleService:Init()
	-- FIX: RemoteFunction dibuat setelah semua service diinisialisasi
	-- untuk memastikan EventService sudah ada.
	task.defer(function()
		local EventService = self.sm:Get("EventService")
		if EventService then
			EventService:CreateFunction("GetActiveTheme", function(player: Player)
				return self:GetTheme(self.activeThemeName)
			end)
		else
			self.SystemMonitor:Log("StyleService", "ERROR", "DEP_MISSING", "EventService tidak ditemukan saat Init.")
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

# 2. Tulis Ulang EventService.lua (FIX KRITIS)
cat > "$SOURCE_DIR/Core/Server/Services/EventService.lua" << 'EOF'
--!strict
--[[
	@file EventService.lua
	@version 3.0.0 (REWRITE)
	@description Ditulis ulang dengan rapi untuk memastikan semua metode
	             terdefinisi dengan benar sebelum digunakan oleh service lain.
]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local EventService = {}
EventService.__index = EventService

function EventService.new(sm: any)
	local self = setmetatable({}, EventService)
	self.sm = sm
	self.SystemMonitor = sm:Get("SystemMonitor")
	self.container = Instance.new("Folder")
	self.container.Name = "OVHL_Events"
	self.container.Parent = ReplicatedStorage
	self.events = {}
	self.functions = {}
	return self
end

function EventService:Init()
	-- Event & Fungsi dibuat di sini untuk memastikan service sudah siap
	self:CreateFunction("RequestPlayerData", function(player: Player)
		local DataService = self.sm:Get("DataService")
		if DataService then return DataService:GetData(player) end
		return nil
	end)
	
	self:CreateEvent("PlayerDataReady")
	self:CreateEvent("NewOrderNotification")
	self:CreateEvent("RespondToOrder")
	self:CreateEvent("UpdateMissionUI")
	self:CreateEvent("MissionCompleted")
	
	self.SystemMonitor:Log("EventService", "INFO", "INIT_SUCCESS", "EventService dimulai.")
end

function EventService:CreateFunction(name: string, callback: (Player, ...any) -> ...any)
	if self.functions[name] then return end
	local remoteFunc = Instance.new("RemoteFunction")
	remoteFunc.Name = name
	remoteFunc.Parent = self.container
	remoteFunc.OnServerInvoke = callback
	self.functions[name] = remoteFunc
end

function EventService:CreateEvent(name: string)
	if self.events[name] then return end
	local remoteEvent = Instance.new("RemoteEvent")
	remoteEvent.Name = name
	remoteEvent.Parent = self.container
	self.events[name] = remoteEvent
end

function EventService:FireClient(player: Player, name: string, ...: any)
	local remoteEvent = self.events[name]
	if remoteEvent then
		remoteEvent:FireClient(player, ...)
	end
end

function EventService:OnClientEvent(name: string, callback: (Player, ...any) -> ())
	local remoteEvent = self.events[name]
	if remoteEvent then
		remoteEvent.OnServerEvent:Connect(callback)
	end
end

return EventService
EOF
print_sub_step "Perbaikan 'EventService.lua' selesai."

# 3. Tulis Ulang UIManager.lua (FIX KRITIS)
cat > "$SOURCE_DIR/Core/Client/Services/UIManager.lua" << 'EOF'
--!strict
--[[
	@file UIManager.lua
	@version 2.0.0 (REWRITE)
	@description Ditulis ulang dengan rapi. Memperbaiki race condition dengan
	             menggunakan WaitForChild secara konsisten.
]]
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Events = ReplicatedStorage:WaitForChild("OVHL_Events")

local UIManager = {}
local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
local activeTheme: any
local screens = {}

function UIManager:Init()
	-- FIX: Menunggu RemoteFunction benar-benar siap di server
	local getThemeFunc: RemoteFunction = Events:WaitForChild("GetActiveTheme", 10) -- Timeout 10 detik
	if getThemeFunc then
		activeTheme = getThemeFunc:InvokeServer()
		print("✅ [UIManager] Tema '".. (activeTheme and activeTheme.Name or "Unknown") .."' berhasil dimuat.")
	else
		warn("❌ [UIManager] Gagal mendapatkan RemoteFunction 'GetActiveTheme' dari server.")
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

echo ""
# ==============================================================================
# --- TAHAP 3: SELESAI ---
# ==============================================================================
print_step "PERBAIKAN FASE 8 SELESAI!"
echo "--------------------------------------------------"
echo "Semua file yang menyebabkan error telah ditulis ulang."
echo "Langkah selanjutnya:"
echo "1. Jalankan 'rojo serve' dan sinkronkan ke Roblox Studio."
echo "2. Tekan 'Play'. Semua alur dari Fase 8 harusnya kini"
echo "   berjalan dengan lancar tanpa error sama sekali."
echo "--------------------------------------------------"
