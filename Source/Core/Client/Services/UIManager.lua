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
