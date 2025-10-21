--!strict
--[[
	@project OVHL_OJOL
	@file Init.client.lua
	@author OmniverseHighland + AI Co-Dev System
	@version 3.0.0
	
	@description
	Entry point client yang bersih, hanya memanggil bootstrapper.
]]

local Core = game:GetService("ReplicatedStorage"):WaitForChild("Core")
local ClientBootstrapper = require(Core.Client.ClientBootstrapper)

ClientBootstrapper:Start()
