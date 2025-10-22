--!strict
-- File ini nggak akan jalan karena autoInit=false, tapi kita kasih aja buat testing
local Module = {} function Module:Init(DI) print("   [Proto] 💤 Modul Nonaktif C (seharusnya tidak muncul)") end return Module
