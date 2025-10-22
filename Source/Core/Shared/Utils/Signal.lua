--!strict
--[[ @project OVHL_OJOL @file Signal.lua ]]
local Signal = {} Signal.__index = Signal
function Signal.new() local s=setmetatable({}, Signal) s.connections={} return s end
function Signal:Connect(cb) table.insert(self.connections, cb) end
function Signal:Fire(...) for _, cb in ipairs(self.connections) do task.spawn(cb, ...) end end
return Signal
