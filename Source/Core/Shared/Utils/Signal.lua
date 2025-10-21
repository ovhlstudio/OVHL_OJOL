--!strict
--[[
	@project OVHL_OJOL
	@file Signal.lua
	@author OmniverseHighland + AI Co-Dev System
	
	@description
	Implementasi sederhana dari event/signal dispatcher untuk komunikasi
	antar modul di sisi client tanpa coupling yang erat.
]]

local Signal = {}
Signal.__index = Signal

function Signal.new()
	local self = setmetatable({}, Signal)
	self.connections = {}
	return self
end

function Signal:Connect(callback: () -> ())
	table.insert(self.connections, callback)
	-- Di implementasi production, bisa return connection object untuk disconnect
end

function Signal:Fire(...)
	for _, callback in ipairs(self.connections) do
		task.spawn(callback, ...)
	end
end

return Signal
