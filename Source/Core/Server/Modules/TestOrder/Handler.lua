--!strict
--[[
	@project OVHL_OJOL
	@file Handler.lua (TestOrder)
	@author OmniverseHighland + AI Co-Dev System
	@version 1.1.0
	
	@description
	Handler sisi server untuk modul TestOrder (Gameplay Loop v1).
	VERSION 1.1.0 (TAHAP 4 FIX):
	- Mengubah fungsi init() untuk membaca 'context' table.
	- Mengambil service (SystemMonitor, EventService, dll) langsung dari context.
	- Ini memperbaiki bug 'attempt to index nil with Get'.
]]
local Players = game:GetService("Players")
local TestOrderHandler = {}
local activeOrders = {}

-- Variabel ini akan diisi saat init()
local SystemMonitor: any
local EventService: any
local ZoneService: any
local DataService: any

-- Fungsi ini sekarang berdiri sendiri
local function onMissionCompleted(player: Player)
    local orderData = activeOrders[player]
    if not orderData then return end
    
    DataService:AddUang(player, orderData.payment)
    EventService:FireClient(player, "MissionCompleted", orderData.payment)
    activeOrders[player] = nil
    
    -- Panggil fungsi startOrderSimulationForPlayer yang ada di scope global modul
    startOrderSimulationForPlayer(player) 
end

-- Fungsi ini sekarang berdiri sendiri
local function onOrderResponse(player: Player, hasAccepted: boolean)
    local orderData = activeOrders[player]
    if not orderData then return end
    
    if hasAccepted then
        EventService:FireClient(player, "UpdateMissionUI", orderData)
        ZoneService:CreateZoneForPlayer(player, orderData.destination, function() onMissionCompleted(player) end)
    else
        activeOrders[player] = nil
        -- Kirim order baru lagi setelah ditolak
        startOrderSimulationForPlayer(player) 
    end
end

-- Fungsi ini sekarang berdiri sendiri
function startOrderSimulationForPlayer(player: Player)
    task.spawn(function()
        task.wait(8) -- Jeda sebelum order baru muncul
        
        -- Cek lagi player-nya masih valid dan tidak sedang ada order
        if not player or not player.Parent or activeOrders[player] then return end
        
        local char = player.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        
        -- Pastikan root ada sebelum lanjut
        if not root then
            SystemMonitor:Log("TestOrder", "WARN", "NO_ROOT_PART", ("Player '%s' tidak punya HumanoidRootPart, order dibatalkan."):format(player.Name))
            return
        end
        
        local sPos = root.Position
        local dPos = sPos + Vector3.new(math.random(30, 60) * (math.random(0, 1) * 2 - 1), 0, math.random(30, 60) * (math.random(0, 1) * 2 - 1))
        
        local oData = {
            id = "ORDER-" .. math.random(1000, 9999),
            from = "Restoran Cepat Saji",
            to = "Perumahan Mekar Jaya",
            payment = 15000,
            destination = dPos
        }
        
        activeOrders[player] = oData
        EventService:FireClient(player, "NewOrderNotification", oData)
        SystemMonitor:Log("TestOrder", "INFO", "ORDER_SENT", ("Order baru dikirim ke '%s'"):format(player.Name))
    end)
end


function TestOrderHandler:init(context) -- context SEKARANG ADALAH TABLE
    -- ================================================================
    -- INI DIA PERBAIKAN TAHAP 4.3
    -- Kita baca 'context' sebagai table
    -- ================================================================
    SystemMonitor = context.SystemMonitor
    EventService = context.EventService
    ZoneService = context.ZoneService
    DataService = context.DataService
    
    -- Safety check
    if not SystemMonitor then
        warn("TESTORDER: FATAL! SystemMonitor tidak ditemukan di context table!")
        return
    end

    SystemMonitor:Log("TestOrder", "INFO", "MODULE_START", "TestOrder module dimulai")

    -- Setup listener untuk semua player yang sudah ada
    for _, p in ipairs(Players:GetPlayers()) do 
        startOrderSimulationForPlayer(p) 
    end
    
    -- Setup listener untuk player yang baru join
    Players.PlayerAdded:Connect(startOrderSimulationForPlayer)
    
    -- Setup listener untuk respon order dari client
    EventService:OnClientEvent("RespondToOrder", onOrderResponse)
end

function TestOrderHandler:teardown()
    SystemMonitor:Log("TestOrder", "INFO", "TEARDOWN", "TestOrder module di-shutdown")
    -- TODO: Disconnect semua listener
    activeOrders = {}
end

return TestOrderHandler
