--!strict
--[[
	@project OVHL_OJOL
	@file Init.server.lua
	@author OmniverseHighland + AI Co-Dev System
	
	@description
	Titik masuk utama (entry point) untuk seluruh logika sisi server.
	Skrip ini akan memanggil Bootstrapper untuk memulai Core OS.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Core = ReplicatedStorage:WaitForChild("Core")
local Bootstrapper = require(Core.Kernel.Bootstrapper)

-- Memulai proses booting Core OS
local status, pesan = pcall(function()
	Bootstrapper:Start()
end)

if not status then
	warn("!!! FATAL BOOTSTRAP ERROR !!!")
	warn("Gagal memulai OVHL Core OS. Pesan Error:", pesan)
end
