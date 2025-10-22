#!/bin/bash
# ==============================================================================
# OVHL_OJOL - Fase 9 Deployment Script (Sinkronisasi Data Real-time)
# Author: OmniverseHighland + AI Co-Dev System
# Version: 9.0.0
#
# Deskripsi:
# Skrip ini mengimplementasikan sinkronisasi data real-time. Setiap
# perubahan data di server (seperti penambahan uang) akan langsung
# diperbarui di HUD client.
# ==============================================================================

# --- KONFIGURASI ---
SOURCE_DIR="Source"

# --- FUNGSI BANTUAN ---
function print_header() {
    echo "=================================================="
    echo "🚀  OVHL_OJOL Fase 9 Deployer  🚀"
    echo "   (Sinkronisasi Data Real-time)"
    echo "=================================================="
}

function print_step() {
    echo "✅ [$(date +'%T')] $1"
}

function print_sub_step() {
    echo "   -> $1"
}

# ==============================================================================
# --- TAHAP 1: UPGRADE MODUL & SERVICE ---
# ==============================================================================
print_header
print_step "Memulai upgrade untuk Fase 9..."

# 1. Upgrade EventService.lua
cat > "$SOURCE_DIR/Core/Server/Services/EventService.lua" << 'EOF'
--!strict
--[[
	@file EventService.lua
	@version 3.0.1
	@description Menambahkan event 'UpdatePlayerData'.
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
	self:CreateEvent("UpdatePlayerData") -- Event baru
	self.SystemMonitor:Log("EventService", "INFO", "INIT_SUCCESS", "EventService dimulai.")
end

function EventService:CreateFunction(name: string, callback: (Player, ...any) -> ...any) if self.functions[name] then return end local rf = Instance.new("RemoteFunction") rf.Name = name rf.Parent = self.container rf.OnServerInvoke = callback self.functions[name] = rf end
function EventService:CreateEvent(name: string) if self.events[name] then return end local re = Instance.new("RemoteEvent") re.Name = name re.Parent = self.container self.events[name] = re end
function EventService:FireClient(player: Player, name: string, ...: any) local remoteEvent = self.events[name] if remoteEvent then remoteEvent:FireClient(player, ...) end end
function EventService:OnClientEvent(name: string, callback: (Player, ...any) -> ()) local remoteEvent = self.events[name] if remoteEvent then remoteEvent.OnServerEvent:Connect(callback) end end

return EventService
EOF
print_sub_step "Upgrade 'EventService.lua' berhasil (menambahkan UpdatePlayerData)."

# 2. Upgrade DataService.lua
cat > "$SOURCE_DIR/Core/Server/Services/DataService.lua" << 'EOF'
--!strict
--[[
	@file DataService.lua
	@version 2.2.0
	@description Kini mengirim update data ke client saat ada perubahan.
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
		
		-- Kirim update ke client
		local EventService = self.sm:Get("EventService")
		if EventService then
			EventService:FireClient(player, "UpdatePlayerData", {Uang = data.Uang})
		end
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

function DataService:_savePlayerData(player: Player) if not self.playerDataCache[player] then return end pcall(function() self.playerDataStore:SetAsync("Player_" .. player.UserId, self.playerDataCache[player]) end) end
function DataService:_autoSaveLoop() while true do task.wait(Config.autosave_interval) for _, player in ipairs(Players:GetPlayers()) do self:_savePlayerData(player) end end end
function DataService:_onServerShutdown() for _, player in ipairs(Players:GetPlayers()) do self:_savePlayerData(player) end task.wait(2) end

return DataService
EOF
print_sub_step "Upgrade 'DataService.lua' berhasil (mengirim update)."

# 3. Upgrade PlayerDataController.lua
cat > "$SOURCE_DIR/Core/Client/Controllers/PlayerDataController.lua" << 'EOF'
--!strict
--[[
	@file PlayerDataController.lua
	@version 2.1.0
	@description Kini mendengarkan update data dari server.
]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Core = ReplicatedStorage:WaitForChild("Core")
local Events = ReplicatedStorage:WaitForChild("OVHL_Events")
local Signal = require(Core.Shared.Utils.Signal)

local PlayerDataController = {}
local playerData = nil
PlayerDataController.OnDataReady = Signal.new()
PlayerDataController.OnDataUpdated = Signal.new() -- Sinyal baru

function PlayerDataController:Init(dependencies: {any})
	-- Menunggu sinyal data awal siap
	Events:WaitForChild("PlayerDataReady").OnClientEvent:Connect(function()
		local requestFunc: RemoteFunction = Events:WaitForChild("RequestPlayerData")
		playerData = requestFunc:InvokeServer()
		if playerData then
			PlayerDataController.OnDataReady:Fire(playerData)
		end
	end)
	
	-- Mendengarkan update data berkelanjutan
	Events:WaitForChild("UpdatePlayerData").OnClientEvent:Connect(function(updatedData: table)
		if not playerData then return end
		
		-- Gabungkan data baru ke data lokal
		for key, value in pairs(updatedData) do
			playerData[key] = value
		end
		
		-- Kirim sinyal bahwa data telah di-update
		PlayerDataController.OnDataUpdated:Fire(playerData)
	end)
end

function PlayerDataController:GetData() return playerData end

return PlayerDataController
EOF
print_sub_step "Upgrade 'PlayerDataController.lua' berhasil (mendengarkan update)."

# 4. Upgrade MainHUD.lua
cat > "$SOURCE_DIR/Core/Client/UI/MainHUD.lua" << 'EOF'
--!strict
--[[
	@file MainHUD.lua
	@version 2.1.0
	@description Kini mendengarkan sinyal update data dan memperbarui UI.
]]
local Core = game:GetService("ReplicatedStorage"):WaitForChild("Core")
local PlayerDataController = require(Core.Client.Controllers.PlayerDataController)
local MainHUD = {}
local moneyLabel: TextLabel

function MainHUD:Init(dependencies: {UIManager: any})
	local UIManager = dependencies.UIManager
	
	-- Buat UI saat data pertama kali siap
	PlayerDataController.OnDataReady:Connect(function(playerData)
		local screen = UIManager:CreateScreen("MainHUD")
		if screen:FindFirstChild("MoneyWindow") then screen.MoneyWindow:Destroy() end
		local moneyWindow = UIManager:CreateWindow({ Parent = screen, Name = "MoneyWindow", Style = "HUD", Size = UDim2.new(0.2, 0, 0.08, 0), Position = UDim2.new(0.5, 0, 0.02, 0), AnchorPoint = Vector2.new(0.5, 0) })
		moneyLabel = UIManager:AddTextLabel({ Parent = moneyWindow, Name = "MoneyLabel", Style = "HUD", Text = "Rp. " .. tostring(playerData.Uang), Size = UDim2.fromScale(0.9, 0.8), Position = UDim2.fromScale(0.5, 0.5), AnchorPoint = Vector2.new(0.5, 0.5), TextXAlignment = Enum.TextXAlignment.Center })
	end)

	-- Dengarkan update data berkelanjutan
	PlayerDataController.OnDataUpdated:Connect(function(playerData)
		if moneyLabel then
			moneyLabel.Text = "Rp. " .. tostring(playerData.Uang)
		end
	end)
end

return MainHUD
EOF
print_sub_step "Upgrade 'MainHUD.lua' berhasil (memperbarui UI secara real-time)."

# 5. Upgrade UIManager.lua (Bonus: notifikasi misi selesai)
cat > "$SOURCE_DIR/Core/Client/Services/UIManager.lua" << 'EOF'
--!strict
--[[
	@file UIManager.lua
	@version 2.1.0
	@description Menambahkan notifikasi sementara (toast).
]]
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Events = ReplicatedStorage:WaitForChild("OVHL_Events")
local TweenService = game:GetService("TweenService")
local UIManager = {}
local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
local activeTheme: any
local screens = {}

function UIManager:Init() local getThemeFunc:RemoteFunction=Events:WaitForChild("GetActiveTheme",10) if getThemeFunc then activeTheme=getThemeFunc:InvokeServer() end end
function UIManager:CreateScreen(sn) if screens[sn] then return screens[sn] end local sg=Instance.new("ScreenGui") sg.Name=sn sg.ResetOnSpawn=false sg.Parent=playerGui screens[sn]=sg return sg end
function UIManager:CreateWindow(o) local f=Instance.new("Frame") f.Name=o.Name f.Size=o.Size f.Position=o.Position f.AnchorPoint=o.AnchorPoint or Vector2.new(0,0) f.BorderSizePixel=0 if o.Style=="HUD" then f.BackgroundColor3=activeTheme.Colors.BackgroundHUD else f.BackgroundColor3=activeTheme.Colors.Background end f.BackgroundTransparency=0.2 local c=Instance.new("UICorner") c.CornerRadius=UDim.new(0,8) c.Parent=f f.Parent=o.Parent return f end
function UIManager:AddTextLabel(o) local l=Instance.new("TextLabel") l.Name=o.Name l.Text=o.Text l.Size=o.Size l.Position=o.Position or UDim2.fromScale(0,0) l.AnchorPoint=o.AnchorPoint or Vector2.new(0,0) l.TextXAlignment=o.TextXAlignment or Enum.TextXAlignment.Left l.BackgroundTransparency=1 if o.Style=="HUD" then l.Font=activeTheme.Fonts.Header l.TextSize=activeTheme.FontSizes.HUD else l.Font=activeTheme.Fonts.Body l.TextSize=o.TextSize or activeTheme.FontSizes.Body end l.TextColor3=activeTheme.Colors.TextPrimary l.Parent=o.Parent return l end
function UIManager:AddButton(o) local b=Instance.new("TextButton") b.Name=o.Name b.Text=o.Text b.Size=o.Size b.Position=o.Position b.AnchorPoint=o.AnchorPoint or Vector2.new(0,0) if o.Name=="AcceptButton" then b.BackgroundColor3=activeTheme.Colors.Confirm elseif o.Name=="DeclineButton" then b.BackgroundColor3=activeTheme.Colors.Decline else b.BackgroundColor3=activeTheme.Colors.Accent end b.Font=activeTheme.Fonts.Body b.TextColor3=activeTheme.Colors.TextPrimary b.TextSize=activeTheme.FontSizes.Button local c=Instance.new("UICorner") c.CornerRadius=UDim.new(0,6) c.Parent=b b.Parent=o.Parent return b end
function UIManager:CreateMissionTracker(orderData) local s=self:CreateScreen("MissionUI") if s:FindFirstChild("MissionTracker") then s.MissionTracker:Destroy() end local tW=self:CreateWindow({Parent=s,Name="MissionTracker",Size=UDim2.new(0.25,0,0.1,0),Position=UDim2.new(0.5,0,0.9,0),AnchorPoint=Vector2.new(0.5,1)}) self:AddTextLabel({Parent=tW,Name="ObjectiveLabel",Text="Tujuan: "..orderData.to,Size=UDim2.fromScale(0.9,0.8),Position=UDim2.fromScale(0.5,0.5),AnchorPoint=Vector2.new(0.5,0.5),TextXAlignment=Enum.TextXAlignment.Center,TextSize=18}) end
function UIManager:DestroyMissionTracker() local s=screens["MissionUI"] if s and s:FindFirstChild("MissionTracker") then s.MissionTracker:Destroy() end end

function UIManager:ShowToastNotification(message: string, duration: number?)
	local screen = self:CreateScreen("NotificationUI")
	local toast = self:CreateWindow({
		Parent = screen,
		Name = "ToastNotification",
		Size = UDim2.new(0.3, 0, 0.1, 0),
		Position = UDim2.new(0.5, 0, -0.1, 0),
		AnchorPoint = Vector2.new(0.5, 0),
		Style = "HUD",
	})
	self:AddTextLabel({
		Parent = toast,
		Name = "ToastLabel",
		Text = message,
		Size = UDim2.fromScale(1, 1),
		TextXAlignment = Enum.TextXAlignment.Center,
		Style = "HUD",
	})
	
	local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
	local goalIn = {Position = UDim2.new(0.5, 0, 0.05, 0)}
	local goalOut = {Position = UDim2.new(0.5, 0, -0.1, 0)}
	
	TweenService:Create(toast, tweenInfo, goalIn):Play()
	task.wait(duration or 3)
	TweenService:Create(toast, tweenInfo, goalOut):Play()
	task.wait(0.5)
	toast:Destroy()
end

return UIManager
EOF
print_sub_step "Upgrade 'UIManager.lua' berhasil (menambahkan notifikasi 'toast')."

# 6. Upgrade OrderController.lua (Bonus: notifikasi misi selesai)
cat > "$SOURCE_DIR/Core/Client/Controllers/OrderController.lua" << 'EOF'
--!strict
--[[
	@file OrderController.lua
	@version 1.2.2
	@description Menampilkan notifikasi saat misi selesai.
]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Events = ReplicatedStorage:WaitForChild("OVHL_Events")
local OrderController = {}
local UIManager: any

function OrderController:Init(d: {UIManager: any})
	UIManager = d.UIManager
	Events.NewOrderNotification.OnClientEvent:Connect(function(o) self:_showOrderNotification(o) end)
	Events.UpdateMissionUI.OnClientEvent:Connect(function(o) self:_showMissionTracker(o) end)
	Events.MissionCompleted.OnClientEvent:Connect(function(payment) self:_onMissionCompleted(payment) end)
end

function OrderController:_showOrderNotification(o: {from: string, to: string, payment: number})
	local s = UIManager:CreateScreen("NotificationUI")
	if s:FindFirstChild("OrderNotification") then s.OrderNotification:Destroy() end
	local nW=UIManager:CreateWindow({Parent=s,Name="OrderNotification",Size=UDim2.fromScale(0.3,0.25),Position=UDim2.fromScale(0.5,0.4),AnchorPoint=Vector2.new(0.5,0.5)})
	UIManager:AddTextLabel({Parent=nW,Name="Title",Text="ORDER BARU!",Size=UDim2.fromScale(1,0.2),TextXAlignment=Enum.TextXAlignment.Center,TextSize=22})
	local dT=string.format("Dari: %s\nTujuan: %s\nBayaran: Rp. %d",o.from,o.to,o.payment)
	UIManager:AddTextLabel({Parent=nW,Name="Details",Text=dT,Size=UDim2.new(0.9,0,0.4,0),Position=UDim2.fromScale(0.5,0.45),AnchorPoint=Vector2.new(0.5,0.5),TextXAlignment=Enum.TextXAlignment.Left})
	local aB=UIManager:AddButton({Parent=nW,Name="AcceptButton",Text="TERIMA",Size=UDim2.new(0.4,0,0.2,0),Position=UDim2.fromScale(0.25,0.85),AnchorPoint=Vector2.new(0.5,0.5)})
	local dB=UIManager:AddButton({Parent=nW,Name="DeclineButton",Text="TOLAK",Size=UDim2.new(0.4,0,0.2,0),Position=UDim2.fromScale(0.75,0.85),AnchorPoint=Vector2.new(0.5,0.5)})
	local rE:RemoteEvent=Events:WaitForChild("RespondToOrder")
	aB.MouseButton1Click:Connect(function()rE:FireServer(true) nW:Destroy()end)
	dB.MouseButton1Click:Connect(function()rE:FireServer(false) nW:Destroy()end)
end

function OrderController:_showMissionTracker(o: {to: string}) UIManager:CreateMissionTracker(o) end

function OrderController:_onMissionCompleted(payment: number)
	UIManager:DestroyMissionTracker()
	UIManager:ShowToastNotification("Misi Selesai! +Rp. " .. tostring(payment))
end

return OrderController
EOF
print_sub_step "Upgrade 'OrderController.lua' berhasil (menampilkan notifikasi 'toast')."

# 7. Upgrade TestOrder/Handler.lua (Bonus: kirim info bayaran)
cat > "$SOURCE_DIR/Core/Server/Modules/TestOrder/Handler.lua" << 'EOF'
--!strict
--[[
	@file TestOrder/Handler.lua
	@version 1.4.2
	@description Kini mengirim info bayaran saat misi selesai.
]]
local Players = game:GetService("Players")
local TestOrderHandler = {}
local activeOrders = {}

function TestOrderHandler:Init(sm: any)
	local SystemMonitor=sm:Get("SystemMonitor")
	local EventService=sm:Get("EventService")
	local ZoneService=sm:Get("ZoneService")
	local DataService=sm:Get("DataService")
	
	local function onMissionCompleted(player: Player)
		local orderData = activeOrders[player]
		if not orderData then return end
		DataService:AddUang(player, orderData.payment)
		EventService:FireClient(player, "MissionCompleted", orderData.payment) -- Kirim info bayaran
		activeOrders[player] = nil
		startOrderSimulationForPlayer(player)
	end

	local function onOrderResponse(player: Player, hasAccepted: boolean)
		local orderData = activeOrders[player]
		if not orderData then return end
		if hasAccepted then
			EventService:FireClient(player, "UpdateMissionUI", orderData)
			ZoneService:CreateZoneForPlayer(player, orderData.destination, function() onMissionCompleted(player) end)
		else
			activeOrders[player] = nil
		end
	end

	function startOrderSimulationForPlayer(player: Player)
		task.spawn(function()
			task.wait(8)
			if not player or not player.Parent or activeOrders[player] then return end
			local char=player.Character
			local root=char and char:FindFirstChild("HumanoidRootPart")
			local sPos=root and root.Position or Vector3.new(0,5,0)
			local dPos=sPos+Vector3.new(math.random(30,60),0,math.random(30,60))
			local oData={id="ORDER-"..math.random(1000,9999),from="Restoran Cepat Saji",to="Perumahan Mekar Jaya",payment=15000,destination=dPos}
			activeOrders[player]=oData
			EventService:FireClient(player,"NewOrderNotification",oData)
		end)
	end

	for _, p in ipairs(Players:GetPlayers()) do startOrderSimulationForPlayer(p) end
	Players.PlayerAdded:Connect(startOrderSimulationForPlayer)
	EventService:OnClientEvent("RespondToOrder",onOrderResponse)
end

return TestOrderHandler
EOF
print_sub_step "Upgrade 'TestOrder/Handler.lua' berhasil."

echo ""

# ==============================================================================
# --- TAHAP 2: SELESAI ---
# ==============================================================================
print_step "DEPLOYMENT FASE 9 SELESAI!"
echo "--------------------------------------------------"
echo "Sistem sinkronisasi data real-time telah diimplementasikan."
echo "Langkah selanjutnya:"
echo "1. Jalankan 'rojo serve' dan sinkronkan ke Roblox Studio."
echo "2. Selesaikan satu misi."
echo "3. Perhatikan HUD Uang Anda. Angkanya akan langsung bertambah!"
echo "4. Anda juga akan melihat notifikasi 'Misi Selesai!' di layar."
echo "--------------------------------------------------"

