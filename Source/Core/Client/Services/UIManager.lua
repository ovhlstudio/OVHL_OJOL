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
