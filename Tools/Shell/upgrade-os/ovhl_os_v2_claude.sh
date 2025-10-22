#!/bin/bash
# ---
# 🚀 OVHL "RESET & REBORN" SAKTI v1.4 (FIXED Manifest Naming Issue)
# Nama Operasi: UPGRADE OVHL OS - ENTERPRISE (Fresh Install)
# Tujuan: 1. Bumi Hangus isi /Source/. 2. Rebuild struktur OS v2.1 dari NOL. 3. Pastikan ClientBootstrapper v2.3 (FIXED) terinstall!
# FIX: Ganti manifest.client.lua -> ClientManifest (karena Roblox tidak support titik di nama file)
# ---

set -e # Keluar kalo ada error

echo "🚀 Memulai Operasi Bumi Hangus & Reborn OS (v1.4 - FIXED MANIFEST NAMING)..."
echo "--------------------------------------------------------"

# --- FASE 1: BUMI HANGUS ---
echo "   [FASE 1] Menghapus semua isi di dalam /Source/... (Kecuali folder utama)"
rm -rf Source/Client/*
rm -rf Source/Core/*
rm -rf Source/Replicated/*
rm -rf Source/Server/*
echo "   [FASE 1] Selesai."
echo "--------------------------------------------------------"

# --- FASE 2: REBUILD STRUKTUR FOLDER ---
echo "   [FASE 2] Membangun ulang struktur folder OS Enterprise v2.1..."
# Struktur Server
mkdir -p Source/Core/Kernel
mkdir -p Source/Core/Server/Services
mkdir -p Source/Core/Server/Modules # Kosong untuk saat ini
touch Source/Core/Server/Modules/.gitkeep # Isi folder kosong
# Struktur Client (INI YANG PENTING!)
mkdir -p Source/Core/Client # Folder Core/Client harus ada DULU
mkdir -p Source/Core/Client/Services
mkdir -p Source/Core/Client/Modules/PlayerDataController
mkdir -p Source/Core/Client/Modules/MainHUD
# Struktur Shared
mkdir -p Source/Core/Shared/Utils
# Struktur Replicated
touch Source/Replicated/.gitkeep # Isi folder kosong

# Struktur Prototype Debug Client (sesuai request baru)
mkdir -p Source/Core/Client/Modules/ModPrototypeA # Aktif 1
mkdir -p Source/Core/Client/Modules/ModPrototypeB # Aktif 2
mkdir -p Source/Core/Client/Modules/ModPrototypeC # Disabled
mkdir -p Source/Core/Client/Modules/ModPrototypeD # Broken (no Main.lua)

echo "   [FASE 2] Selesai."
echo "--------------------------------------------------------"

# --- FASE 3: POPULATE FILE CORE OS (v2.1 FIXED + SOP LOGGING) ---
echo "   [FASE 3] Mengisi file-file inti Core OS (dengan SOP Logging)..."

# Entry Points (Pastikan path require ClientBootstrapper benar!)
cat <<'EOF' > Source/Client/Init.client.lua
--!strict
--[[ @project OVHL_OJOL @file Init.client.lua @version 3.0.0 ]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Core = ReplicatedStorage:WaitForChild("Core")
-- Pastikan path ini BENAR menunjuk ke file ClientBootstrapper di Core/Client/
local ClientBootstrapper = require(Core.Client.ClientBootstrapper)
ClientBootstrapper:Start()
EOF
cat <<'EOF' > Source/Server/Init.server.lua
--!strict
--[[ @project OVHL_OJOL @file Init.server.lua ]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Core = ReplicatedStorage:WaitForChild("Core")
local Bootstrapper = require(Core.Kernel.Bootstrapper)
local status, pesan = pcall(function() Bootstrapper:Start() end)
if not status then warn("!!! FATAL BOOTSTRAP ERROR !!! Pesan:", pesan) end
EOF

# Core Kernel (Server Bootstrapper v2 FIXED + SOP Logging)
cat <<'EOF' > Source/Core/Kernel/Bootstrapper.lua
--!strict
--[[
	@project OVHL_OJOL
	@file Bootstrapper.lua (v2.0 FIXED + SOP Logging v1.0)
]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Core = ReplicatedStorage.Core
local Services = Core.Server.Services
local Shared = Core.Shared -- Kita butuh Config buat ambil versi
local Config = require(Shared.Config) -- Ambil versi dari sini!

local ServiceManager = require(Services.ServiceManager)
local SystemMonitor = require(Services.SystemMonitor)

local Bootstrapper = {}
Bootstrapper.CoreServices = { "EventService", "DataService", "StyleService", "ZoneService" }
Bootstrapper.ModulesPath = Core.Server.Modules
local OS_PREFIX = "[OVHL OS ENTERPRISE v"..Config.version.."] " -- PREFIX BARU!

function Bootstrapper:Start()
	local startTime = os.clock()
	-- PRINT BARU 1: Kasih tau OS lagi nyala
	print(OS_PREFIX .. "Server proses booting...")

	local serviceManager = ServiceManager.new()
	-- Initialize SystemMonitor DULUAN, baru pake Log
	SystemMonitor:Initialize(serviceManager)
	serviceManager:Register("ServiceManager", serviceManager)
	serviceManager:Register("SystemMonitor", SystemMonitor)

	-- Sekarang SystemMonitor udah siap, baru kita pake Log
	SystemMonitor:Log("Bootstrapper", "INFO", "CORE_BOOT_START", "SystemMonitor initialized, Core OS memulai proses booting...")


	self:_LoadCoreServices(serviceManager)
	self:_DiscoverAndLoadModules(serviceManager)
	serviceManager:StartAll()

	local bootTime = (os.clock() - startTime) * 1000
	SystemMonitor:Log("Bootstrapper", "INFO", "CORE_BOOT_SUCCESS", ("OVHL Core OS berhasil dimuat dalam %.2f ms."):format(bootTime))

	-- PRINT BARU 2: Kasih tau OS udah SIAP!
	print(OS_PREFIX .. "Server 100% SIAP!")
end

-- (Sisa fungsi _LoadCoreServices dan _DiscoverAndLoadModules SAMA PERSIS kayak versi v1.1 yang sukses tadi)
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
			SystemMonitor:Log("Bootstrapper", "DEBUG", "MODULE_FOUND", ("Folder modul ditemukan: %s"):format(moduleFolder.Name))
			local manifestModule = moduleFolder:FindFirstChild("manifest")
			if manifestModule and manifestModule:IsA("ModuleScript") then
				local status, manifest = pcall(require, manifestModule)
				if status and typeof(manifest) == "table" then
					local handlerModule = moduleFolder:FindFirstChild("Handler")
					if handlerModule and handlerModule:IsA("ModuleScript") then
						serviceManager:RegisterModule(manifest, handlerModule)
						SystemMonitor:Log("Bootstrapper", "INFO", "MODULE_REGISTERED", ("Modul '%s' berhasil didaftarkan."):format(manifest.name))
					else
						SystemMonitor:Log("Bootstrapper", "WARN", "HANDLER_NOT_FOUND", ("Modul '%s' punya manifest tapi tidak punya Handler.lua, skipping."):format(moduleFolder.Name))
					end
				else
					SystemMonitor:Log("Bootstrapper", "WARN", "MANIFEST_LOAD_FAIL", ("Gagal load manifest untuk modul '%s'. Pesan: %s"):format(moduleFolder.Name, tostring(manifest)))
				end
			else
				-- Ini bukan modul server, mungkin .gitkeep? Skip tanpa warning.
				-- SystemMonitor:Log("Bootstrapper", "WARN", "MANIFEST_NOT_FOUND", ("Folder '%s' tidak punya manifest.lua, skipping."):format(moduleFolder.Name))
			end
		end
	end
	SystemMonitor:Log("Bootstrapper", "INFO", "MODULE_DISCOVERY_DONE", "Penemuan modul selesai.")
end


return Bootstrapper
EOF

# Core Server Services (INI SEMUA TIDAK BERUBAH + SOP Logging)
cat <<'EOF' > Source/Core/Server/Services/ServiceManager.lua
--!strict
--[[ @project OVHL_OJOL @file ServiceManager.lua (v2.0 FIXED) ]]
local ServiceManager = {}
ServiceManager.__index = ServiceManager

function ServiceManager.new()
	local self = setmetatable({}, ServiceManager)
	self.services = {}
	self.modules = {}
	self.SystemMonitor = nil -- Di-inject di Bootstrapper
	return self
end

function ServiceManager:Register(name: string, instance: any)
	if self.services[name] then
		self:Get("SystemMonitor"):Log("ServiceManager", "WARN", "DUPLICATE_REGISTER", ("Service '%s' sudah terdaftar."):format(name))
		return
	end
	self.services[name] = instance
end

function ServiceManager:RegisterModule(manifest: table, handlerModule: ModuleScript)
	if self.modules[manifest.name] then
		self:Get("SystemMonitor"):Log("ServiceManager", "WARN", "DUPLICATE_MODULE", ("Modul '%s' sudah terdaftar."):format(manifest.name))
		return
	end
	local moduleInstance = { manifest = manifest, handler = require(handlerModule), isStarted = false }
	self.modules[manifest.name] = moduleInstance
	self:Get("SystemMonitor"):Log("ServiceManager", "DEBUG", "MODULE_REGISTERED", ("Modul '%s' terdaftar"):format(manifest.name))
end

function ServiceManager:Get(name: string)
	local service = self.services[name]
	if not service then
		warn(("[ServiceManager] Peringatan: Service '%s' tidak ditemukan."):format(name))
	end
	return service
end

function ServiceManager:StartAll()
	local SystemMonitor = self:Get("SystemMonitor")
	SystemMonitor:Log("ServiceManager", "INFO", "START_ALL", "Memulai semua service dan modul...")

	-- Context table untuk dependency injection ke modul (INI DIA PERBAIKANNYA!)
	local context = {}
	for name, service in pairs(self.services) do
		context[name] = service
	end

	-- Jalankan Init() pada semua service DULU
	for name, service in pairs(self.services) do
		if typeof(service.Init) == "function" then
			local status, err = pcall(service.Init, service)
			if not status then
				SystemMonitor:Log("ServiceManager", "ERROR", "SERVICE_INIT_FAIL", ("Gagal Init() service '%s': %s"):format(name, err))
			else
				SystemMonitor:Log("ServiceManager", "DEBUG", "SERVICE_INIT_SUCCESS", ("Service '%s' di-init"):format(name))
			end
		end
	end

	-- Baru jalankan init() pada semua modul (inject context table)
	for name, module in pairs(self.modules) do
		SystemMonitor:Log("ServiceManager", "DEBUG", "MODULE_START_ATTEMPT", ("Mencoba memulai modul '%s'"):format(name))
		if typeof(module.handler.init) == "function" then
			local canStart = true
			if module.manifest.depends then
				for _, depName in ipairs(module.manifest.depends) do
					if not self.services[depName] then
						SystemMonitor:Log("ServiceManager", "ERROR", "MODULE_DEP_MISSING", ("Gagal memulai '%s', dependensi '%s' tidak ditemukan."):format(name, depName))
						canStart = false; break
					end
				end
			end
			if canStart then
				SystemMonitor:Log("ServiceManager", "DEBUG", "MODULE_STARTING", ("Memulai modul '%s'..."):format(name))
				-- Inject 'context' table, BUKAN 'self'!
				local status, err = pcall(module.handler.init, module.handler, context)
				if not status then
					SystemMonitor:Log("ServiceManager", "ERROR", "MODULE_INIT_FAIL", ("Gagal init() modul '%s': %s"):format(name, err))
				else
					module.isStarted = true
					SystemMonitor:Log("ServiceManager", "INFO", "MODULE_START_SUCCESS", ("Modul '%s' berhasil dimulai"):format(name))
				end
			end
		else
			SystemMonitor:Log("ServiceManager", "ERROR", "MODULE_NO_INIT", ("Modul '%s' tidak punya function init()"):format(name))
		end
	end
	SystemMonitor:Log("ServiceManager", "INFO", "START_ALL_COMPLETE", "Proses startup selesai.")
end

return ServiceManager
EOF
cat <<'EOF' > Source/Core/Server/Services/SystemMonitor.lua
--!strict
--[[ @project OVHL_OJOL @file SystemMonitor.lua (SOP Logging v1.0) ]]
local SystemMonitor = {}
local serviceManager: any
local LOG_PREFIX = "[OVHL SYS MONITOR v1.0] " -- INI PREFIX BARU KITA!

function SystemMonitor:Initialize(sm: any) if serviceManager then return end serviceManager = sm self:Log("SystemMonitor", "INFO", "INIT_SUCCESS", "SystemMonitor siap.") end

function SystemMonitor:Log(source: string, level: string, code: string, message: string)
	-- Tambahin prefix di sini!
	local log = LOG_PREFIX .. string.format("[%s] [%s] [%s] %s", source, code, level, message)
	if level == "ERROR" or level == "WARN" then warn(log) else print(log) end
end

function SystemMonitor.new() return SystemMonitor end -- Singleton
return SystemMonitor
EOF
cat <<'EOF' > Source/Core/Server/Services/DataService.lua
--!strict
--[[ @project OVHL_OJOL @file DataService.lua (v1.1 FIXED) ]]
local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local Core = game:GetService("ReplicatedStorage"):WaitForChild("Core")
local Config = require(Core.Shared.Config)
local DataService = {}
DataService.__index = DataService
local ProfileTemplate = { Uang = 5000, Level = 1, XP = 0 } -- Akan di-expand
local function deepCopy(t: table) local nt = {} for k, v in pairs(t) do nt[k] = (typeof(v) == "table") and deepCopy(v) or v end return nt end

function DataService.new(sm: any)
	local self = setmetatable({}, DataService)
	self.sm = sm
	self.SystemMonitor = sm:Get("SystemMonitor")
	self.playerDataStore = DataStoreService:GetDataStore("OVHL_PlayerData_v1")
	self.globalDataStore = DataStoreService:GetDataStore("OVHL_GlobalData_v1")
	self.playerDataCache = {}
	self.globalDataCache = {}
	return self
end

function DataService:Init()
	self:_LoadGlobalConfig() -- Load config DULU
	Players.PlayerAdded:Connect(function(p) self:_onPlayerAdded(p) end)
	Players.PlayerRemoving:Connect(function(p) self:_onPlayerRemoving(p) end)
	game:BindToClose(function() self:_onServerShutdown() end)
	task.spawn(function() self:_autoSaveLoop() end)
	self.SystemMonitor:Log("DataService", "INFO", "INIT_SUCCESS", "DataService siap.")
end

function DataService:GetData(player: Player) return self.playerDataCache[player] end
function DataService:AddUang(player: Player, amount: number) local d = self:GetData(player) if d and d.Uang then d.Uang += amount local es = self.sm:Get("EventService") if es then es:FireClient(player, "UpdatePlayerData", {Uang = d.Uang}) end end end

-- Global Config Methods (FIXED)
function DataService:GetGlobal(key: string?) return key and self.globalDataCache[key] or self.globalDataCache end
function DataService:SetGlobal(key: string, value: any) self.globalDataCache[key] = value task.spawn(function() local s,e = pcall(function() self.globalDataStore:SetAsync("OVHL_CONFIG", self.globalDataCache) end) if not s then self.SystemMonitor:Log("DataService", "ERROR", "GLOBAL_SAVE_FAIL", ("Gagal save config: %s"):format(e)) end end) end

function DataService:_LoadGlobalConfig()
	self.SystemMonitor:Log("DataService", "INFO", "GLOBAL_LOAD_START", "Memuat global config (OVHL_CONFIG)...")
	local success, data = pcall(function() return self.globalDataStore:GetAsync("OVHL_CONFIG") end)
	if success and data then
		self.globalDataCache = data
		self.SystemMonitor:Log("DataService", "INFO", "GLOBAL_LOAD_SUCCESS", "Config global di-load dari DataStore.")
	else
		self.globalDataCache = deepCopy(Config) -- Ambil dari file Config.lua
		self.SystemMonitor:Log("DataService", "INFO", "GLOBAL_LOAD_DEFAULT", "Config global tidak ditemukan, pakai default & save.")
		self:SetGlobal("OVHL_CONFIG", self.globalDataCache) -- Langsung save defaultnya
	end
end

-- Player Data Methods
function DataService:_onPlayerAdded(player: Player) self:_loadPlayerData(player) end
function DataService:_onPlayerRemoving(player: Player) self:_savePlayerData(player) self.playerDataCache[player] = nil end
function DataService:_loadPlayerData(player: Player) local id="Player_"..player.UserId local s,d=pcall(function() return self.playerDataStore:GetAsync(id) end) if s then self.playerDataCache[player]=d or deepCopy(ProfileTemplate) task.wait(1) local es=self.sm:Get("EventService") if es then es:FireClient(player, "PlayerDataReady") end else player:Kick("Gagal load data.") end end
function DataService:_savePlayerData(player: Player) if not self.playerDataCache[player] then return end pcall(function() self.playerDataStore:SetAsync("Player_"..player.UserId, self.playerDataCache[player]) end) end
function DataService:_autoSaveLoop() while true do task.wait(Config.autosave_interval or 300) for _, p in ipairs(Players:GetPlayers()) do self:_savePlayerData(p) end end end
function DataService:_onServerShutdown() for _, p in ipairs(Players:GetPlayers()) do self:_savePlayerData(p) end task.wait(2) end

return DataService
EOF
cat <<'EOF' > Source/Core/Server/Services/EventService.lua
--!strict
--[[ @project OVHL_OJOL @file EventService.lua (v1.1 FIXED) ]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local EventService = {}
EventService.__index = EventService

function EventService.new(sm: any)
	local self = setmetatable({}, EventService)
	self.sm = sm
	self.SystemMonitor = sm:Get("SystemMonitor")
	self.container = Instance.new("Folder") self.container.Name = "OVHL_Events" self.container.Parent = ReplicatedStorage
	self.events = {} self.functions = {}
	return self
end

function EventService:Init()
	-- Player Data
	self:CreateFunction("RequestPlayerData", function(p) local ds=self.sm:Get("DataService") return ds and ds:GetData(p) end)
	self:CreateEvent("PlayerDataReady")
	self:CreateEvent("UpdatePlayerData")
	-- Base events (mungkin akan dihapus nanti)
	self:CreateEvent("NewOrderNotification")
	self:CreateEvent("RespondToOrder")
	self:CreateEvent("UpdateMissionUI")
	self:CreateEvent("MissionCompleted")
	-- Admin / Config (jika diperlukan)
	self:CreateFunction("AdminGetConfig") self:CreateFunction("AdminUpdateConfig") self:CreateFunction("AdminReloadModule")
	self:CreateEvent("ConfigUpdated")
	self.SystemMonitor:Log("EventService", "INFO", "INIT_SUCCESS", "EventService siap.")
end

function EventService:CreateFunction(n, cb) if self.functions[n] then return end local rf = Instance.new("RemoteFunction") rf.Name = n rf.Parent = self.container if cb then rf.OnServerInvoke=cb else rf.OnServerInvoke=function(p,...) self.SystemMonitor:Log("EventService","WARN","NO_HANDLER",("Func '%s' dipanggil tanpa handler"):format(n)) return nil end end self.functions[n]=rf end
function EventService:CreateEvent(n) if self.events[n] then return end local re = Instance.new("RemoteEvent") re.Name = n re.Parent = self.container self.events[n] = re end
function EventService:FireClient(p, n, ...) local e = self.events[n] if e then e:FireClient(p, ...) end end
function EventService:OnClientEvent(n, cb) local e = self.events[n] if e then e.OnServerEvent:Connect(cb) end end
function EventService:FireAllClients(n, ...) local e = self.events[n] if e then e:FireAllClients(...) end end
function EventService:InvokeClient(p, n, ...) local f = self.functions[n] if f then return f:InvokeClient(p, ...) end return nil end

return EventService
EOF
cat <<'EOF' > Source/Core/Server/Services/StyleService.lua
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
EOF
cat <<'EOF' > Source/Core/Server/Services/ZoneService.lua
--!strict
--[[ @project OVHL_OJOL @file ZoneService.lua ]]
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")
local ZoneService = {}
ZoneService.__index = ZoneService
local activeZones = {} -- Untuk zona misi per player
local taggedZoneHandlers = {} -- Untuk zona area (Dealer, etc)

function ZoneService.new(sm: any)
	local self = setmetatable({}, ZoneService)
	self.sm = sm
	self.SystemMonitor = sm:Get("SystemMonitor")
	self:_SetupTaggedZoneListeners() -- Dengar zona yg sudah ada di map
	return self
end

function ZoneService:Init() self.SystemMonitor:Log("ZoneService", "INFO", "INIT_SUCCESS", "ZoneService siap.") end

-- Untuk Zona Misi (dibuat runtime)
function ZoneService:CreateZoneForPlayer(p, pos, cb) self:DestroyZoneForPlayer(p) local z = Instance.new("Part") z.Name="MissionZone_"..p.Name z.Size=Vector3.new(15,1,15) z.Position=pos z.Anchored=true z.CanCollide=false z.Transparency=0.7 z.Color=Color3.fromRGB(76,175,80) z.Shape=Enum.PartType.Cylinder z.Parent=Workspace local c=z.Touched:Connect(function(op) local char=op.Parent if not char then return end local h=char:FindFirstChildOfClass("Humanoid") if not h then return end local tp=Players:GetPlayerFromCharacter(char) if tp==p then cb() self:DestroyZoneForPlayer(p) end end) activeZones[p]={part=z,connection=c} self.SystemMonitor:Log("ZoneService","INFO","ZONE_CREATED",("Zona misi '%s' dibuat"):format(p.Name)) end
function ZoneService:DestroyZoneForPlayer(p) local zd=activeZones[p] if zd then zd.connection:Disconnect() zd.part:Destroy() activeZones[p]=nil end end

-- Untuk Zona Area (dari Tag Editor)
function ZoneService:RegisterTaggedZoneHandler(tag, enterCb, exitCb) taggedZoneHandlers[tag] = {enter = enterCb, exit = exitCb} self.SystemMonitor:Log("ZoneService", "INFO", "HANDLER_REGISTERED", ("Handler untuk Tag '%s' didaftarkan."):format(tag)) end
function ZoneService:_SetupTaggedZoneListeners()
    local playerStates = {} -- Track player state for each tag

    local function onPartTouched(tag, player, part)
        local handler = taggedZoneHandlers[tag]
        local playerTagState = playerStates[player.UserId] and playerStates[player.UserId][tag]
        if handler and handler.enter and not playerTagState then -- Only trigger enter if not already inside
            handler.enter(player, part)
            if not playerStates[player.UserId] then playerStates[player.UserId] = {} end
            playerStates[player.UserId][tag] = true -- Mark player as inside this tag zone
        end
    end

    local function onPartTouchEnded(tag, player, part)
        local handler = taggedZoneHandlers[tag]
        local playerTagState = playerStates[player.UserId] and playerStates[player.UserId][tag]
        if handler and handler.exit and playerTagState then -- Only trigger exit if currently marked as inside
            handler.exit(player, part)
            if playerStates[player.UserId] then playerStates[player.UserId][tag] = nil end -- Mark player as outside
            -- Cleanup if player state for this user is empty
            if playerStates[player.UserId] and next(playerStates[player.UserId]) == nil then
                 playerStates[player.UserId] = nil
            end
        end
    end

    -- Process existing tagged parts
    for tag, _ in pairs(taggedZoneHandlers) do
        for _, part in ipairs(CollectionService:GetTagged(tag)) do
            if part:IsA("BasePart") then
                part.Touched:Connect(function(op)
                    local char = op.Parent if not char then return end
                    local p = Players:GetPlayerFromCharacter(char) if p then onPartTouched(tag, p, part) end
                end)
                part.TouchEnded:Connect(function(op)
                    local char = op.Parent if not char then return end
                    local p = Players:GetPlayerFromCharacter(char) if p then onPartTouchEnded(tag, p, part) end
                end)
            end
        end
    end

    -- Listen for newly tagged parts (important for runtime tagging)
    for tag, _ in pairs(taggedZoneHandlers) do
        CollectionService:GetInstanceAddedSignal(tag):Connect(function(part)
            if part:IsA("BasePart") then
                part.Touched:Connect(function(op)
                    local char = op.Parent if not char then return end
                    local p = Players:GetPlayerFromCharacter(char) if p then onPartTouched(tag, p, part) end
                end)
                part.TouchEnded:Connect(function(op)
                    local char = op.Parent if not char then return end
                    local p = Players:GetPlayerFromCharacter(char) if p then onPartTouchEnded(tag, p, part) end
                end)
            end
        end)
    end

    -- Cleanup player state when they leave
    Players.PlayerRemoving:Connect(function(player)
        playerStates[player.UserId] = nil
    end)
end


return ZoneService
EOF

# Core Client Bootstrapper v2.3 (FIXED Manifest Naming + SOP Logging)
# INI VERSI FINAL DARI OTAK CLIENT - NAMA FILE MANIFEST UDAH DIUBAH!
cat <<'EOF' > Source/Core/Client/ClientBootstrapper.lua
--!strict
--[[
	@project OVHL_OJOL
	@file ClientBootstrapper.lua (v2.3 - FINALIZED + FIXED MANIFEST NAMING)
	@author OmniverseHighland + AI Co-Dev System
	@version 2.3.0

	@description
	"OTAK" Sisi Client v2.3. FIX bug manifest naming (manifest.client.lua -> ClientManifest).
	Roblox tidak support nama file dengan titik (.) di tengah, jadi kita ganti jadi "ClientManifest".
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Core = ReplicatedStorage:WaitForChild("Core")
local Shared = Core.Shared
local Config = require(Shared.Config) -- Ambil versi OS dari sini!

-- Core Services (Pilar OS Client)
local UIManager = require(Core.Client.Services.UIManager)

-- Lokasi Modul
local ModulesPath = Core.Client.Modules

local ClientBootstrapper = {}

-- Ini adalah "Dependency Injection" (DI) Container kita.
local DI_Container = {
	UIManager = UIManager,
	-- Kita bisa tambahin service client lain di sini nanti
}

local OS_PREFIX = "[OVHL OS ENTERPRISE v"..Config.version.."] " -- PREFIX BARU!
local MONITOR_PREFIX = "[OVHL SYS MONITOR v1.0] " -- Client belum punya SystemMonitor, jadi kita hardcode prefix-nya

function ClientBootstrapper:Start()
	-- PRINT BARU 1: Kasih tau OS lagi nyala
	print(OS_PREFIX .. "Client proses booting...")
	print(MONITOR_PREFIX .. "[ClientBootstrapper] [BOOT_START] [INFO] OS Client memulai proses booting...")

	UIManager:Init()
	print(MONITOR_PREFIX .. "[ClientBootstrapper] [UI_READY] [INFO] UI Engine (UIManager) ready.")

	print(MONITOR_PREFIX .. "[ClientBootstrapper] [MANIFEST_WAIT] [INFO] OS Client menunggu manifes...")

	local modulesToLoad = {}
	local discoveredCount = 0
	local serviceFolderCount = 0 -- Hitung folder non-modul

	for _, item in ipairs(ModulesPath:GetChildren()) do
		if item:IsA("Folder") then
			discoveredCount += 1
			local moduleFolder = item
			-- ✅ FIXED: Ganti dari "manifest.client.lua" ke "ClientManifest" (tanpa .lua karena ModuleScript)
			local manifestScript = moduleFolder:FindFirstChild("ClientManifest")

			if manifestScript and manifestScript:IsA("ModuleScript") then
				-- Kita coba require di sini untuk validasi awal
				local success, manifestOrError = pcall(require, manifestScript)
				if success and typeof(manifestOrError) == "table" then
					local manifest = manifestOrError
					-- Validasi isi manifest
					if not manifest.name or manifest.loadOrder == nil or manifest.autoInit == nil then
						print(MONITOR_PREFIX .. (" [ClientBootstrapper] [MANIFEST_INVALID] [WARN] terdeteksi modul SAKIT (manifes tidak lengkap): %s"):format(moduleFolder.Name))
					else
						table.insert(modulesToLoad, { Folder = moduleFolder, Manifest = manifest })
					end
				else -- Gagal require manifest
					print(MONITOR_PREFIX .. (" [ClientBootstrapper] [MANIFEST_ERROR] [WARN] terdeteksi modul RUSAK (manifes error): %s. Pesan: %s"):format(moduleFolder.Name, tostring(manifestOrError)))
				end
			else -- Tidak punya manifest
				print(MONITOR_PREFIX .. ("[ClientBootstrapper] [FOLDER_NO_MANIFEST] [DEBUG] Folder '%s' tidak punya ClientManifest, diabaikan (mungkin Service?)."):format(moduleFolder.Name))
				serviceFolderCount += 1
			end
		end
	end

	table.sort(modulesToLoad, function(a, b) return a.Manifest.loadOrder < b.Manifest.loadOrder end)

	print(MONITOR_PREFIX .. ("[ClientBootstrapper] [LOAD_ORDER_START] [INFO] Ditemukan %d folder, %d manifes valid. Memulai load order..."):format(discoveredCount, #modulesToLoad))

	local totalAktif = 0
	local totalNonaktif = 0
	local totalRusakManifest = discoveredCount - #modulesToLoad - serviceFolderCount -- Hitung yg gagal manifest (yg BUKAN service)
	local totalRusakEntry = 0

	for _, moduleInfo in ipairs(modulesToLoad) do
		local manifest = moduleInfo.Manifest
		local folder = moduleInfo.Folder

		if manifest.autoInit == true then
			local entryName = manifest.entry or "Main" -- Default ke Main.lua
			-- Cari file .lua nya (ModuleScript di Roblox TIDAK perlu extension .lua)
			local entryScript = folder:FindFirstChild(entryName)

			if entryScript and entryScript:IsA("ModuleScript") then
				local success, module = pcall(require, entryScript)
				if success and typeof(module) == "table" and typeof(module.Init) == "function" then
					print(MONITOR_PREFIX .. ("[ClientBootstrapper] [MODULE_LOAD_ACTIVE] [INFO] Meload modul AKTIF: %s (Order: %d)"):format(manifest.name, manifest.loadOrder))
					local initSuccess, initError = pcall(module.Init, module, DI_Container)
					if not initSuccess then
						print(MONITOR_PREFIX .. ("      └[ClientBootstrapper] [MODULE_INIT_FAIL] [ERROR] Gagal Init() modul '%s': %s"):format(manifest.name, initError))
						totalRusakEntry += 1
					else
						-- Masukkan instance modul ke DI Container agar modul lain bisa pakai
						DI_Container[manifest.name] = module
						totalAktif += 1
					end
				else
					print(MONITOR_PREFIX .. ("[ClientBootstrapper] [MODULE_LOAD_FAIL] [ERROR] Gagal meload modul RUSAK (entry point error atau tidak punya :Init()): %s"):format(manifest.name))
					totalRusakEntry += 1
				end
			else
				print(MONITOR_PREFIX .. ("[ClientBootstrapper] [MODULE_LOAD_FAIL] [ERROR] Gagal meload modul RUSAK (entry file '%s' tidak ditemukan): %s"):format(entryName, manifest.name))
				totalRusakEntry += 1
			end
		else
			print(MONITOR_PREFIX .. ("[ClientBootstrapper] [MODULE_SKIP_DISABLED] [INFO] Dilewati modul NONAKTIF: %s (Order: %d)"):format(manifest.name, manifest.loadOrder))
			totalNonaktif += 1
		end
	end

	local totalRusak = totalRusakManifest + totalRusakEntry
	local totalModul = discoveredCount - serviceFolderCount -- Hanya hitung folder yg seharusnya modul

	-- Log Ringkasan Baru yang Lebih Gagah
	print(OS_PREFIX .. "-------------------- RINGKASAN BOOT CLIENT --------------------")
	print(OS_PREFIX .. ("   Total Folder Modules Ditemukan : %d"):format(totalModul))
	print(OS_PREFIX .. ("   Modul dengan Manifes Valid     : %d"):format(#modulesToLoad))
	print(OS_PREFIX .. ("   ✅ Modul AKTIF Berhasil Load   : %d"):format(totalAktif))
	print(OS_PREFIX .. ("   💤 Modul NONAKTIF Dilewati     : %d"):format(totalNonaktif))
	print(OS_PREFIX .. ("   ⚠️ Modul RUSAK (Total)          : %d"):format(totalRusak))
	print(OS_PREFIX .. ("      └ Rusak karena Manifes    : %d"):format(totalRusakManifest))
	print(OS_PREFIX .. ("      └ Rusak karena Entry/Init : %d"):format(totalRusakEntry))
	print(OS_PREFIX .. "-------------------------------------------------------------")

	-- PRINT BARU 2: Kasih tau OS udah SIAP!
	print(OS_PREFIX .. "Client 100% SIAP!")
	print(MONITOR_PREFIX .. "[ClientBootstrapper] [OS_READY] [INFO] OS Client 100% SIAP!")

end

return ClientBootstrapper
EOF

# Core Client Services
cat <<'EOF' > Source/Core/Client/Services/UIManager.lua
--!strict
--[[ @project OVHL_OJOL @file UIManager.lua (Core Client Service) ]]
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UIManager = {}
local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
local activeTheme: any
local screens = {}
local EventService -- Akan diisi saat Init (jika EventService client ada)

function UIManager:Init()
	-- Kita coba dapetin theme lgsg, karena ClientBootstrapper v2 manggil ini duluan
	local Events = ReplicatedStorage:FindFirstChild("OVHL_Events")
	if Events then
		local getThemeFunc:RemoteFunction=Events:WaitForChild("GetActiveTheme",10)
		if getThemeFunc then
			activeTheme=getThemeFunc:InvokeServer()
		end
	end
	if not activeTheme then -- Fallback jika gagal
		warn("[UIManager] Gagal load theme dari server, pakai default.")
		activeTheme = {Name="Fallback",Colors={Background=Color3.fromRGB(25,25,25),BackgroundHUD=Color3.fromRGB(10,10,10),TextPrimary=Color3.fromRGB(250,250,250),TextSecondary=Color3.fromRGB(180,180,180),Accent=Color3.fromRGB(50,150,255),Confirm=Color3.fromRGB(76,175,80),Decline=Color3.fromRGB(244,67,54),Surface=Color3.fromRGB(45,45,45),Border=Color3.fromRGB(60,60,60),Success=Color3.fromRGB(76,175,80),Warning=Color3.fromRGB(255,193,7),Error=Color3.fromRGB(244,67,54),Primary=Color3.fromRGB(0,120,215),Secondary=Color3.fromRGB(100,100,100)},Fonts={Header=Enum.Font.GothamBold,Body=Enum.Font.Gotham},FontSizes={Body=16,Button=18,HUD=24}}
	end
end

function UIManager:CreateScreen(sn) if screens[sn] then return screens[sn] end local sg=Instance.new("ScreenGui") sg.Name=sn sg.ResetOnSpawn=false sg.Parent=playerGui screens[sn]=sg return sg end
function UIManager:CreateWindow(o) local f=Instance.new("Frame") f.Name=o.Name f.Size=o.Size f.Position=o.Position f.AnchorPoint=o.AnchorPoint or Vector2.new(0,0) f.BorderSizePixel=0 if o.Style=="HUD" then f.BackgroundColor3=activeTheme.Colors.BackgroundHUD else f.BackgroundColor3=activeTheme.Colors.Background end f.BackgroundTransparency=o.Transparency or 0.2 local c=Instance.new("UICorner") c.CornerRadius=UDim.new(0,8) c.Parent=f f.Parent=o.Parent return f end
function UIManager:AddTextLabel(o) local l=Instance.new("TextLabel") l.Name=o.Name l.Text=o.Text l.Size=o.Size l.Position=o.Position or UDim2.fromScale(0,0) l.AnchorPoint=o.AnchorPoint or Vector2.new(0,0) l.TextXAlignment=o.TextXAlignment or Enum.TextXAlignment.Left l.BackgroundTransparency=1 if o.Style=="HUD" then l.Font=activeTheme.Fonts.Header l.TextSize=activeTheme.FontSizes.HUD else l.Font=activeTheme.Fonts.Body l.TextSize=o.TextSize or activeTheme.FontSizes.Body end l.TextColor3=o.TextColor or activeTheme.Colors.TextPrimary l.Parent=o.Parent return l end
function UIManager:AddButton(o) local b=Instance.new("TextButton") b.Name=o.Name b.Text=o.Text b.Size=o.Size b.Position=o.Position b.AnchorPoint=o.AnchorPoint or Vector2.new(0,0) if o.ColorStyle=="Confirm" then b.BackgroundColor3=activeTheme.Colors.Confirm elseif o.ColorStyle=="Decline" then b.BackgroundColor3=activeTheme.Colors.Decline else b.BackgroundColor3=o.BackgroundColor or activeTheme.Colors.Accent end b.Font=activeTheme.Fonts.Body b.TextColor3=activeTheme.Colors.TextPrimary b.TextSize=activeTheme.FontSizes.Button local c=Instance.new("UICorner") c.CornerRadius=UDim.new(0,6) c.Parent=b b.Parent=o.Parent return b end
function UIManager:AddTextBox(o) local tb=Instance.new("TextBox") tb.Name=o.Name tb.PlaceholderText=o.Placeholder or "" tb.Text=o.Text or "" tb.Size=o.Size tb.Position=o.Position tb.AnchorPoint=o.AnchorPoint or Vector2.new(0,0) tb.BackgroundColor3=activeTheme.Colors.Surface tb.TextColor3=activeTheme.Colors.TextPrimary tb.Font=activeTheme.Fonts.Body tb.TextSize=o.TextSize or activeTheme.FontSizes.Body tb.ClearTextOnFocus=false local c=Instance.new("UICorner") c.CornerRadius=UDim.new(0,4) c.Parent=tb local p=Instance.new("UIPadding") p.PaddingLeft=UDim.new(0,8) p.PaddingRight=UDim.new(0,8) p.Parent=tb tb.Parent=o.Parent return tb end
function UIManager:AddImageLabel(o) local i=Instance.new("ImageLabel") i.Name=o.Name i.Image=o.Image i.Size=o.Size i.Position=o.Position or UDim2.fromScale(0,0) i.AnchorPoint=o.AnchorPoint or Vector2.new(0,0) i.BackgroundTransparency=1 i.Parent=o.Parent return i end
function UIManager:ShowToastNotification(m, d) local s=self:CreateScreen("NotificationUI") local t=self:CreateWindow({Parent=s,Name="Toast",Size=UDim2.new(0.3,0,0.1,0),Position=UDim2.new(0.5,0,-0.1,0),AnchorPoint=Vector2.new(0.5,0),Style="HUD"}) self:AddTextLabel({Parent=t,Name="ToastLabel",Text=m,Size=UDim2.fromScale(1,1),TextXAlignment=Enum.TextXAlignment.Center,Style="HUD"}) local ti=TweenInfo.new(0.5,Enum.EasingStyle.Quint,Enum.EasingDirection.Out) local gi={Position=UDim2.new(0.5,0,0.05,0)} local go={Position=UDim2.new(0.5,0,-0.1,0)} TweenService:Create(t,ti,gi):Play() task.wait(d or 3) TweenService:Create(t,ti,go):Play() task.wait(0.5) t:Destroy() end

return UIManager
EOF

# Core Shared Files
cat <<'EOF' > Source/Core/Shared/Config.lua
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
EOF
cat <<'EOF' > Source/Core/Shared/Utils/Signal.lua
--!strict
--[[ @project OVHL_OJOL @file Signal.lua ]]
local Signal = {} Signal.__index = Signal
function Signal.new() local s=setmetatable({}, Signal) s.connections={} return s end
function Signal:Connect(cb) table.insert(self.connections, cb) end
function Signal:Fire(...) for _, cb in ipairs(self.connections) do task.spawn(cb, ...) end end
return Signal
EOF

echo "   [FASE 3] Selesai."
echo "--------------------------------------------------------"

# --- FASE 4: POPULATE MODUL CLIENT (YANG DIPINDAH + PROTOTYPE) ---
echo "   [FASE 4] Mengisi file-file modul Client..."

# ✅ PlayerDataController (ClientManifest + Main) -- INI YANG KRITIS BUAT DEPENDENCY
cat <<'EOF' > Source/Core/Client/Modules/PlayerDataController/ClientManifest.lua
--!strict
-- ✅ Manifest untuk PlayerDataController (NAMA FILE UDAH DIUBAH!)
return {
	name = "PlayerDataController", -- Nama unik untuk DI Container
	autoInit = true,             -- Wajib jalan pas booting
	loadOrder = 1,               -- HARUS JALAN PALING PERTAMA!
	entry = "Main"               -- File utamanya Main.lua
}
EOF
cat <<'EOF' > Source/Core/Client/Modules/PlayerDataController/Main.lua
--!strict
--[[ @file PlayerDataController/Main.lua (v2.1.0) ]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Core = ReplicatedStorage:WaitForChild("Core")
local Events = ReplicatedStorage:WaitForChild("OVHL_Events")
local Signal = require(Core.Shared.Utils.Signal)

local PlayerDataController = {}
local playerData = nil
PlayerDataController.OnDataReady = Signal.new()
PlayerDataController.OnDataUpdated = Signal.new()

function PlayerDataController:Init(DI) -- DI Container masuk sini
	print("   [PlayerDataController] Init() dipanggil...")
	Events:WaitForChild("PlayerDataReady").OnClientEvent:Connect(function()
		print("   [PlayerDataController] Menerima sinyal PlayerDataReady dari server!")
		local requestFunc: RemoteFunction = Events:WaitForChild("RequestPlayerData")
		playerData = requestFunc:InvokeServer()
		if playerData then
			print("   [PlayerDataController] Data player berhasil diambil:", playerData)
			PlayerDataController.OnDataReady:Fire(playerData) -- Kasih tau modul lain
		else
			warn("   [PlayerDataController] Gagal mengambil data player dari server (nil).")
		end
	end)
	Events:WaitForChild("UpdatePlayerData").OnClientEvent:Connect(function(updatedData: table)
		if not playerData then return end
		print("   [PlayerDataController] Menerima update data:", updatedData)
		for key, value in pairs(updatedData) do playerData[key] = value end
		PlayerDataController.OnDataUpdated:Fire(playerData) -- Kasih tau modul lain
	end)
	print("   [PlayerDataController] Listener event siap.")
end
function PlayerDataController:GetData() return playerData end
return PlayerDataController
EOF

# ✅ MainHUD (ClientManifest + Main) -- Butuh PlayerDataController dari DI
cat <<'EOF' > Source/Core/Client/Modules/MainHUD/ClientManifest.lua
--!strict
-- ✅ Manifest untuk MainHUD (NAMA FILE UDAH DIUBAH!)
return {
	name = "MainHUD",           -- Nama unik
	autoInit = true,          -- Wajib jalan
	loadOrder = 10,           -- Jalan SETELAH PlayerDataController (Order 1)
	entry = "Main"            -- File utamanya Main.lua
}
EOF
cat <<'EOF' > Source/Core/Client/Modules/MainHUD/Main.lua
--!strict
--[[ @file MainHUD/Main.lua (v2.1.0) ]]
local Core = game:GetService("ReplicatedStorage"):WaitForChild("Core")
local MainHUD = {}
local moneyLabel: TextLabel
local PlayerDataController -- Akan di-inject dari DI

function MainHUD:Init(DI) -- DI Container masuk sini
	print("   [MainHUD] Init() dipanggil...")
	local UIManager = DI.UIManager -- Ambil UIManager dari DI
	PlayerDataController = DI.PlayerDataController -- Ambil PlayerDataController dari DI

	if not PlayerDataController then
		warn("   [MainHUD] ⚠️ ERROR KRITIS: PlayerDataController tidak ditemukan di DI_Container! UI Uang tidak akan muncul.")
		return -- Jangan lanjut kalo dependency nggak ada
	end

	PlayerDataController.OnDataReady:Connect(function(pd)
		print("   [MainHUD] Menerima data awal player, membuat UI Uang...")
		local s=UIManager:CreateScreen("MainHUD") if s:FindFirstChild("MoneyWindow") then s.MoneyWindow:Destroy() end
		local mw=UIManager:CreateWindow({Parent=s,Name="MoneyWindow",Style="HUD",Size=UDim2.new(0.2,0,0.08,0),Position=UDim2.new(0.5,0,0.02,0),AnchorPoint=Vector2.new(0.5,0)})
		moneyLabel=UIManager:AddTextLabel({Parent=mw,Name="MoneyLabel",Style="HUD",Text="Rp. "..tostring(pd.Uang or 0),Size=UDim2.fromScale(0.9,0.8),Position=UDim2.fromScale(0.5,0.5),AnchorPoint=Vector2.new(0.5,0.5),TextXAlignment=Enum.TextXAlignment.Center})
		print("   [MainHUD] UI Uang berhasil dibuat.")
	end)
	PlayerDataController.OnDataUpdated:Connect(function(pd)
		if moneyLabel then
			print("   [MainHUD] Menerima update data, mengupdate UI Uang...")
			moneyLabel.Text="Rp. "..tostring(pd.Uang or 0)
		end
	end)
	print("   [MainHUD] Listener data siap.")
end
return MainHUD
EOF

# ✅ DebugProtoActive A (ClientManifest + Main)
cat <<'EOF' > Source/Core/Client/Modules/ModPrototypeA/ClientManifest.lua
--!strict
-- ✅ Manifest ModPrototypeA (Aktif - NAMA FILE UDAH DIUBAH!)
return { name = "ModPrototypeA", autoInit = true, loadOrder = 100, entry = "Main" }
EOF
cat <<'EOF' > Source/Core/Client/Modules/ModPrototypeA/Main.lua
--!strict
local Module = {} function Module:Init(DI) print("   [Proto] ✅ Modul Aktif A berhasil di-Init!") end return Module
EOF

# ✅ DebugProtoActive B (ClientManifest + Main)
cat <<'EOF' > Source/Core/Client/Modules/ModPrototypeB/ClientManifest.lua
--!strict
-- ✅ Manifest ModPrototypeB (Aktif - NAMA FILE UDAH DIUBAH!)
return { name = "ModPrototypeB", autoInit = true, loadOrder = 101, entry = "Main" }
EOF
cat <<'EOF' > Source/Core/Client/Modules/ModPrototypeB/Main.lua
--!strict
local Module = {} function Module:Init(DI) print("   [Proto] ✅ Modul Aktif B berhasil di-Init!") end return Module
EOF

# ✅ DebugProtoDisabled C (ClientManifest Only - autoInit = false)
cat <<'EOF' > Source/Core/Client/Modules/ModPrototypeC/ClientManifest.lua
--!strict
-- ✅ Manifest ModPrototypeC (Nonaktif - NAMA FILE UDAH DIUBAH!)
return { name = "ModPrototypeC", autoInit = false, loadOrder = 200, entry = "Main" }
EOF
cat <<'EOF' > Source/Core/Client/Modules/ModPrototypeC/Main.lua
--!strict
-- File ini nggak akan jalan karena autoInit=false, tapi kita kasih aja buat testing
local Module = {} function Module:Init(DI) print("   [Proto] 💤 Modul Nonaktif C (seharusnya tidak muncul)") end return Module
EOF

# ✅ DebugProtoBroken D (ClientManifest Only, SENGAJA NO Main.lua untuk testing error)
cat <<'EOF' > Source/Core/Client/Modules/ModPrototypeD/ClientManifest.lua
--!strict
-- ✅ Manifest ModPrototypeD (Rusak - NAMA FILE UDAH DIUBAH!)
-- Sengaja nggak bikin Main.lua biar error "entry file not found"
return { name = "ModPrototypeD", autoInit = true, loadOrder = 201, entry = "Main" }
EOF
# (Sengaja KOSONGIN Main.lua biar error "entry file not found")

echo "   [FASE 4] Selesai."
echo "--------------------------------------------------------"

echo "✅ OPERASI BUMI HANGUS & REBORN (v1.4 - FIXED MANIFEST NAMING) SELESAI!"
echo ""
echo "📋 PERUBAHAN PENTING:"
echo "   1. Semua file manifest.client.lua → ClientManifest.lua"
echo "   2. ClientBootstrapper v2.3 sekarang cari 'ClientManifest' bukan 'manifest.client.lua'"
echo "   3. ModPrototypeC dikasih Main.lua (biar valid, cuma autoInit=false)"
echo "   4. ModPrototypeD tetap RUSAK (no Main.lua untuk testing)"
echo ""
echo "🎯 EXPECTED RESULT SAAT TEST:"
echo "   ✅ Modul AKTIF: PlayerDataController, MainHUD, ModPrototypeA, ModPrototypeB"
echo "   💤 Modul NONAKTIF: ModPrototypeC"
echo "   ⚠️ Modul RUSAK: ModPrototypeD (entry file not found)"
echo ""
echo "Silakan lanjutkan ke Pengujian!"