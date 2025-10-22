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

# 4. Tulis Ulang file lain yang tidak error (untuk kelengkapan)
# Ini memastikan semua file di Fase 8 tetap ada, tidak ikut ter-reset
cat > "$SOURCE_DIR/Core/Server/Services/ZoneService.lua" << 'EOF'
--!strict
--[[
	@project OVHL_OJOL
	@file ZoneService.lua (Server Service)
	@author OmniverseHighland + AI Co-Dev System
	
	@description
	Mengelola pembuatan dan deteksi zona interaktif di dalam Workspace.
]]

local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local ZoneService = {}
ZoneService.__index = ZoneService
local activeZones = {}

function ZoneService.new(sm: any)
	local self = setmetatable({}, ZoneService)
	self.sm = sm
	self.SystemMonitor = sm:Get("SystemMonitor")
	return self
end

function ZoneService:Init()
	self.SystemMonitor:Log("ZoneService", "INFO", "INIT_SUCCESS", "ZoneService siap digunakan.")
end

function ZoneService:CreateZoneForPlayer(player: Player, position: Vector3, onTouchedCallback: () -> ())
	self:DestroyZoneForPlayer(player)
	local zonePart = Instance.new("Part")
	zonePart.Name = "MissionZone_" .. player.Name
	zonePart.Size = Vector3.new(15, 1, 15)
	zonePart.Position = position
	zonePart.Anchored = true
	zonePart.CanCollide = false
	zonePart.Transparency = 0.7
	zonePart.Color = Color3.fromRGB(76, 175, 80)
	zonePart.Shape = Enum.PartType.Cylinder
	zonePart.Parent = Workspace
	local connection = zonePart.Touched:Connect(function(otherPart)
		local character = otherPart.Parent
		if not character then return end
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		if not humanoid then return end
		local touchingPlayer = Players:GetPlayerFromCharacter(character)
		if touchingPlayer == player then
			onTouchedCallback()
			self:DestroyZoneForPlayer(player)
		end
	end)
	activeZones[player] = {part = zonePart, connection = connection}
	self.SystemMonitor:Log("ZoneService", "INFO", "ZONE_CREATED", ("Zona tujuan dibuat untuk '%s'"):format(player.Name))
end

function ZoneService:DestroyZoneForPlayer(player: Player)
	local zoneData = activeZones[player]
	if zoneData then
		zoneData.connection:Disconnect()
		zoneData.part:Destroy()
		activeZones[player] = nil
	end
end

return ZoneService
EOF

cat > "$SOURCE_DIR/Core/Kernel/Bootstrapper.lua" << 'EOF'
--!strict
--[[
	@project OVHL_OJOL
	@file Bootstrapper.lua
	@author OmniverseHighland + AI Co-Dev System
	@version 1.1.1
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Core = ReplicatedStorage.Core
local Services = Core.Server.Services
local ServiceManager = require(Services.ServiceManager)
local SystemMonitor = require(Services.SystemMonitor)
local Bootstrapper = {}
Bootstrapper.CoreServices = { "EventService", "DataService", "StyleService", "ZoneService" }
Bootstrapper.ModulesPath = Core.Server.Modules

function Bootstrapper:Start()
	local startTime = os.clock()
	SystemMonitor:Log("Bootstrapper", "INFO", "CORE_BOOT_START", "OVHL Core OS memulai proses booting...")
	local serviceManager = ServiceManager.new()
	SystemMonitor:Initialize(serviceManager)
	serviceManager:Register("ServiceManager", serviceManager)
	serviceManager:Register("SystemMonitor", SystemMonitor)
	self:_LoadCoreServices(serviceManager)
	self:_DiscoverAndLoadModules(serviceManager)
	serviceManager:StartAll()
	local bootTime = (os.clock() - startTime) * 1000
	SystemMonitor:Log("Bootstrapper", "INFO", "CORE_BOOT_SUCCESS", ("OVHL Core OS berhasil dimuat dalam %.2f ms."):format(bootTime))
end

function Bootstrapper:_LoadCoreServices(serviceManager: any)
	SystemMonitor:Log("Bootstrapper", "INFO", "CORE_SERVICE_LOAD", "Memuat Core Services...")
	for _, serviceName in ipairs(self.CoreServices) do
		local serviceModule = Services:FindFirstChild(serviceName)
		if serviceModule and serviceModule:IsA("ModuleScript") then
			local status, serviceInstance = pcall(function() return require(serviceModule).new(serviceManager) end)
			if status and serviceInstance then
				serviceManager:Register(serviceName, serviceInstance)
				SystemMonitor:Log("Bootstrapper", "INFO", "REGISTER_SUCCESS", ("Service '%s' berhasil dimuat."):format(serviceName))
			else
				SystemMonitor:Log("Bootstrapper", "ERROR", "REGISTER_FAIL", ("Gagal menginisialisasi Core Service '%s'. Pesan: %s"):format(serviceName, tostring(serviceInstance)))
			end
		else
			SystemMonitor:Log("Bootstrapper", "ERROR", "SERVICE_NOT_FOUND", ("Core Service '%s' tidak ditemukan."):format(serviceName))
		end
	end
end

function Bootstrapper:_DiscoverAndLoadModules(serviceManager: any)
	SystemMonitor:Log("Bootstrapper", "INFO", "MODULE_DISCOVERY", "Memulai penemuan modul...")
	for _, moduleFolder in ipairs(self.ModulesPath:GetChildren()) do
		if moduleFolder:IsA("Folder") then
			local manifestModule = moduleFolder:FindFirstChild("manifest")
			if manifestModule and manifestModule:IsA("ModuleScript") then
				local status, manifest = pcall(require, manifestModule)
				if status and typeof(manifest) == "table" then
					local handlerModule = moduleFolder:FindFirstChild("Handler")
					if handlerModule and handlerModule:IsA("ModuleScript") then
						serviceManager:RegisterModule(manifest, handlerModule)
						SystemMonitor:Log("Bootstrapper", "INFO", "MODULE_REGISTERED", ("Modul '%s' berhasil didaftarkan."):format(manifest.name))
					end
				end
			end
		end
	end
end

return Bootstrapper
EOF

cat > "$SOURCE_DIR/Core/Server/Services/DataService.lua" << 'EOF'
--!strict
--[[
	@project OVHL_OJOL
	@file DataService.lua
	@author OmniverseHighland + AI Co-Dev System
	@version 2.1.0
]]

local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local Core = game:GetService("ReplicatedStorage"):WaitForChild("Core")
local Config = require(Core.Shared.Config)
local DataService = {}
DataService.__index = DataService
local ProfileTemplate = { Uang = 5000, Level = 1, XP = 0 }
local function deepCopy(t: table) local nt = {} for k, v in pairs(t) do nt[k] = (typeof(v) == "table") and deepCopy(v) or v end return nt end

function DataService.new(sm: any)
	local self = setmetatable({}, DataService)
	self.sm = sm
	self.SystemMonitor = sm:Get("SystemMonitor")
	self.playerDataStore = DataStoreService:GetDataStore("OVHL_PlayerData_v1")
	self.playerDataCache = {}
	return self
end

function DataService:Init()
	Players.PlayerAdded:Connect(function(p) self:_onPlayerAdded(p) end)
	Players.PlayerRemoving:Connect(function(p) self:_onPlayerRemoving(p) end)
	game:BindToClose(function() self:_onServerShutdown() end)
	task.spawn(function() self:_autoSaveLoop() end)
	self.SystemMonitor:Log("DataService", "INFO", "INIT_SUCCESS", "DataService berhasil diinisialisasi.")
end

function DataService:GetData(player: Player) return self.playerDataCache[player] end

function DataService:AddUang(player: Player, amount: number)
	local data = self:GetData(player)
	if data and typeof(data.Uang) == "number" then
		data.Uang += amount
		self.SystemMonitor:Log("DataService", "INFO", "DATA_UPDATED", ("Uang pemain '%s' +%d. Total: %d"):format(player.Name, amount, data.Uang))
		-- TODO: Kirim update UI Uang ke client
	end
end

function DataService:_onPlayerAdded(player: Player) self:_loadPlayerData(player) end
function DataService:_onPlayerRemoving(player: Player) self:_savePlayerData(player) self.playerDataCache[player] = nil end

function DataService:_loadPlayerData(player: Player)
	local userId = "Player_" .. player.UserId
	local success, data = pcall(function() return self.playerDataStore:GetAsync(userId) end)
	if success then
		self.playerDataCache[player] = data or deepCopy(ProfileTemplate)
		task.wait(1)
		local EventService = self.sm:Get("EventService")
		if EventService then EventService:FireClient(player, "PlayerDataReady") end
	else
		player:Kick("Gagal memuat data Anda.")
	end
end

function DataService:_savePlayerData(player: Player)
	if not self.playerDataCache[player] then return end
	pcall(function() self.playerDataStore:SetAsync("Player_" .. player.UserId, self.playerDataCache[player]) end)
end

function DataService:_autoSaveLoop()
	while true do
		task.wait(Config.autosave_interval)
		for _, player in ipairs(Players:GetPlayers()) do self:_savePlayerData(player) end
	end
end

function DataService:_onServerShutdown()
	for _, player in ipairs(Players:GetPlayers()) do self:_savePlayerData(player) end
	task.wait(2)
end

return DataService
EOF

cat > "$SOURCE_DIR/Core/Server/Modules/TestOrder/Handler.lua" << 'EOF'
--!strict
--[[
	@project OVHL_OJOL
	@module TestOrder
	@file Handler.lua
	@version 1.4.1
]]

local Players = game:GetService("Players")
local TestOrderHandler = {}
local activeOrders = {}

function TestOrderHandler:Init(sm: any)
	local SystemMonitor = sm:Get("SystemMonitor")
	local EventService = sm:Get("EventService")
	local ZoneService = sm:Get("ZoneService")
	local DataService = sm:Get("DataService")
	
	local function onMissionCompleted(player: Player)
		local orderData = activeOrders[player]
		if not orderData then return end
		SystemMonitor:Log("TestOrder", "INFO", "MISSION_COMPLETED", ("Pemain '%s' MENYELESAIKAN order '%s'."):format(player.Name, orderData.id))
		DataService:AddUang(player, orderData.payment)
		EventService:FireClient(player, "MissionCompleted")
		activeOrders[player] = nil
		startOrderSimulationForPlayer(player)
	end

	local function onOrderResponse(player: Player, hasAccepted: boolean)
		local orderData = activeOrders[player]
		if not orderData then return end
		if hasAccepted then
			SystemMonitor:Log("TestOrder", "INFO", "ORDER_ACCEPTED", ("Pemain '%s' MENERIMA order '%s'."):format(player.Name, orderData.id))
			EventService:FireClient(player, "UpdateMissionUI", orderData)
			ZoneService:CreateZoneForPlayer(player, orderData.destination, function() onMissionCompleted(player) end)
		else
			SystemMonitor:Log("TestOrder", "INFO", "ORDER_DECLINED", ("Pemain '%s' MENOLAK order '%s'."):format(player.Name, orderData.id))
			activeOrders[player] = nil
		end
	end

	function startOrderSimulationForPlayer(player: Player)
		task.spawn(function()
			task.wait(8)
			if not player or not player.Parent or activeOrders[player] then return end
			local character = player.Character
			local rootPart = character and character:FindFirstChild("HumanoidRootPart")
			local spawnPos = rootPart and rootPart.Position or Vector3.new(0, 5, 0)
			local destPos = spawnPos + Vector3.new(math.random(30, 60), 0, math.random(30, 60))
			local orderData = {
				id = "ORDER-" .. math.random(1000, 9999), from = "Restoran Cepat Saji",
				to = "Perumahan Mekar Jaya", payment = 15000, destination = destPos,
			}
			activeOrders[player] = orderData
			EventService:FireClient(player, "NewOrderNotification", orderData)
		end)
	end

	for _, player in ipairs(Players:GetPlayers()) do startOrderSimulationForPlayer(player) end
	Players.PlayerAdded:Connect(startOrderSimulationForPlayer)
	EventService:OnClientEvent("RespondToOrder", onOrderResponse)
	
	SystemMonitor:Log("TestOrder", "INFO", "INIT_SUCCESS", "Modul TestOrder siap.")
end

return TestOrderHandler
EOF

print_sub_step "File-file pendukung berhasil ditulis ulang."

echo ""
# ==============================================================================
# --- TAHAP 4: SELESAI ---
# ==============================================================================
print_step "PERBAIKAN FASE 8 SELESAI!"
echo "--------------------------------------------------"
echo "Semua file yang menyebabkan error telah ditulis ulang."
echo "Langkah selanjutnya:"
echo "1. Jalankan 'rojo serve' dan sinkronkan ke Roblox Studio."
echo "2. Tekan 'Play'. Semua alur dari Fase 8 harusnya kini"
echo "   berjalan dengan lancar tanpa error sama sekali."
echo "--------------------------------------------------"

