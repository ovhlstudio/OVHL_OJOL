--!strict
--[[
	@project OVHL_OJOL
	@file MainHUD.lua (Client UI Module)
	@author OmniverseHighland + AI Co-Dev System
	@version 2.0.0
	
	@description
	Modul UI yang bersih. Hanya mendengarkan sinyal dan memberikan
	perintah ke UIManager, tidak ada logika pembuatan UI sama sekali.
]]

local Core = game:GetService("ReplicatedStorage"):WaitForChild("Core")
local PlayerDataController = require(Core.Client.Controllers.PlayerDataController)

local MainHUD = {}

local moneyLabel: TextLabel

function MainHUD:Init(dependencies: {UIManager: any})
	local UIManager = dependencies.UIManager
	
	-- Dengarkan sinyal dari PlayerDataController
	PlayerDataController.OnDataReady:Connect(function(playerData)
		print("✅ [MainHUD] Sinyal data siap diterima. Memberi perintah ke UIManager...")
		
		local screen = UIManager:CreateScreen("MainHUD")
		local moneyWindow = UIManager:CreateWindow({
			Parent = screen,
			Name = "MoneyWindow",
			Size = UDim2.new(0.2, 0, 0.08, 0),
			Position = UDim2.new(0.98, 0, 0.02, 0),
			AnchorPoint = Vector2.new(1, 0),
		})
		
		moneyLabel = UIManager:AddTextLabel({
			Parent = moneyWindow,
			Name = "MoneyLabel",
			Text = "Rp. " .. tostring(playerData.Uang),
			Size = UDim2.fromScale(0.9, 0.8),
			Position = UDim2.fromScale(0.5, 0.5),
			AnchorPoint = Vector2.new(0.5, 0.5),
			TextXAlignment = Enum.TextXAlignment.Center,
		})
		
		print("✅ [MainHUD] Perintah pembuatan UI ke UIManager selesai.")
	end)
end

return MainHUD
