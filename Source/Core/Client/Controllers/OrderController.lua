--!strict
--[[
	@project OVHL_OJOL
	@file OrderController.lua (Client)
	@author OmniverseHighland + AI Co-Dev System
	@version 1.2.0
	
	@description
	Mengelola logika order di client. Versi ini juga mendengarkan
	perintah untuk menampilkan UI Misi.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Events = ReplicatedStorage:WaitForChild("OVHL_Events")

local OrderController = {}
local UIManager: any

function OrderController:Init(dependencies: {UIManager: any})
	UIManager = dependencies.UIManager
	
	Events:WaitForChild("NewOrderNotification").OnClientEvent:Connect(function(orderData)
		self:_showOrderNotification(orderData)
	end)
	
	-- Dengarkan perintah untuk update UI Misi dari server
	Events:WaitForChild("UpdateMissionUI").OnClientEvent:Connect(function(orderData)
		self:_showMissionTracker(orderData)
	end)
end

function OrderController:_showOrderNotification(orderData: {from: string, to: string, payment: number})
	local screen = UIManager:CreateScreen("NotificationUI")
	if screen:FindFirstChild("OrderNotification") then screen.OrderNotification:Destroy() end
	
	local notificationWindow = UIManager:CreateWindow({ Parent = screen, Name = "OrderNotification", Size = UDim2.fromScale(0.3, 0.25), Position = UDim2.fromScale(0.5, 0.4), AnchorPoint = Vector2.new(0.5, 0.5) })
	
	UIManager:AddTextLabel({ Parent = notificationWindow, Name = "Title", Text = "ORDER BARU!", Size = UDim2.fromScale(1, 0.2), TextXAlignment = Enum.TextXAlignment.Center })
	
	local detailsText = string.format("Dari: %s\nTujuan: %s\nBayaran: Rp. %d", orderData.from, orderData.to, orderData.payment)
	UIManager:AddTextLabel({ Parent = notificationWindow, Name = "Details", Text = detailsText, Size = UDim2.new(0.9, 0, 0.4, 0), Position = UDim2.fromScale(0.5, 0.45), AnchorPoint = Vector2.new(0.5, 0.5), TextXAlignment = Enum.TextXAlignment.Left })
	
	local acceptButton = UIManager:AddButton({ Parent = notificationWindow, Name = "AcceptButton", Text = "TERIMA", Size = UDim2.new(0.4, 0, 0.2, 0), Position = UDim2.fromScale(0.25, 0.85), AnchorPoint = Vector2.new(0.5, 0.5) })
	
	local declineButton = UIManager:AddButton({ Parent = notificationWindow, Name = "DeclineButton", Text = "TOLAK", Size = UDim2.new(0.4, 0, 0.2, 0), Position = UDim2.fromScale(0.75, 0.85), AnchorPoint = Vector2.new(0.5, 0.5) })
	
	local respondEvent: RemoteEvent = Events:WaitForChild("RespondToOrder")
	
	acceptButton.MouseButton1Click:Connect(function()
		respondEvent:FireServer(true)
		notificationWindow:Destroy()
	end)
	
	declineButton.MouseButton1Click:Connect(function()
		respondEvent:FireServer(false)
		notificationWindow:Destroy()
	end)
end

-- Fungsi baru untuk Fase 7
function OrderController:_showMissionTracker(orderData: {to: string})
	UIManager:CreateMissionTracker(orderData)
end

return OrderController
