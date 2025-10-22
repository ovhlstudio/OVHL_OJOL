--!strict
--[[ @project OVHL_OJOL @file Init.client.lua @version 3.0.0 ]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Core = ReplicatedStorage:WaitForChild("Core")
-- Pastikan path ini BENAR menunjuk ke file ClientBootstrapper di Core/Client/
local ClientBootstrapper = require(Core.Client.ClientBootstrapper)
ClientBootstrapper:Start()
