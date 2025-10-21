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
