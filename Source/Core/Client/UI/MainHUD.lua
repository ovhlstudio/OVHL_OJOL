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
