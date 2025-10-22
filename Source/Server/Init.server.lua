--!strict
--[[ @project OVHL_OJOL @file Init.server.lua ]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Core = ReplicatedStorage:WaitForChild("Core")
local Bootstrapper = require(Core.Kernel.Bootstrapper)
local status, pesan = pcall(function() Bootstrapper:Start() end)
if not status then warn("!!! FATAL BOOTSTRAP ERROR !!! Pesan:", pesan) end
