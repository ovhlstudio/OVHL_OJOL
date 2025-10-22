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
