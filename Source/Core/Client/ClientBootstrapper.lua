--!strict
--[[
	@project OVHL_OJOL
	@file ClientBootstrapper.lua (v2.3 - FINALIZED + FIXED MANIFEST NAMING)
	@author OmniverseHighland + AI Co-Dev System
	@version 2.3.0

	@description
	"OTAK" Sisi Client v2.3. FIX bug manifest naming (manifest.client.lua -> ClientManifest).
	Roblox tidak support nama file dengan titik (.) di tengah, jadi kita ganti jadi "ClientManifest".
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Core = ReplicatedStorage:WaitForChild("Core")
local Shared = Core.Shared
local Config = require(Shared.Config) -- Ambil versi OS dari sini!

-- Core Services (Pilar OS Client)
local UIManager = require(Core.Client.Services.UIManager)

-- Lokasi Modul
local ModulesPath = Core.Client.Modules

local ClientBootstrapper = {}

-- Ini adalah "Dependency Injection" (DI) Container kita.
local DI_Container = {
	UIManager = UIManager,
	-- Kita bisa tambahin service client lain di sini nanti
}

local OS_PREFIX = "[OVHL OS ENTERPRISE v"..Config.version.."] " -- PREFIX BARU!
local MONITOR_PREFIX = "[OVHL SYS MONITOR v1.0] " -- Client belum punya SystemMonitor, jadi kita hardcode prefix-nya

function ClientBootstrapper:Start()
	-- PRINT BARU 1: Kasih tau OS lagi nyala
	print(OS_PREFIX .. "Client proses booting...")
	print(MONITOR_PREFIX .. "[ClientBootstrapper] [BOOT_START] [INFO] OS Client memulai proses booting...")

	UIManager:Init()
	print(MONITOR_PREFIX .. "[ClientBootstrapper] [UI_READY] [INFO] UI Engine (UIManager) ready.")

	print(MONITOR_PREFIX .. "[ClientBootstrapper] [MANIFEST_WAIT] [INFO] OS Client menunggu manifes...")

	local modulesToLoad = {}
	local discoveredCount = 0
	local serviceFolderCount = 0 -- Hitung folder non-modul

	for _, item in ipairs(ModulesPath:GetChildren()) do
		if item:IsA("Folder") then
			discoveredCount += 1
			local moduleFolder = item
			-- ✅ FIXED: Ganti dari "manifest.client.lua" ke "ClientManifest" (tanpa .lua karena ModuleScript)
			local manifestScript = moduleFolder:FindFirstChild("ClientManifest")

			if manifestScript and manifestScript:IsA("ModuleScript") then
				-- Kita coba require di sini untuk validasi awal
				local success, manifestOrError = pcall(require, manifestScript)
				if success and typeof(manifestOrError) == "table" then
					local manifest = manifestOrError
					-- Validasi isi manifest
					if not manifest.name or manifest.loadOrder == nil or manifest.autoInit == nil then
						print(MONITOR_PREFIX .. (" [ClientBootstrapper] [MANIFEST_INVALID] [WARN] terdeteksi modul SAKIT (manifes tidak lengkap): %s"):format(moduleFolder.Name))
					else
						table.insert(modulesToLoad, { Folder = moduleFolder, Manifest = manifest })
					end
				else -- Gagal require manifest
					print(MONITOR_PREFIX .. (" [ClientBootstrapper] [MANIFEST_ERROR] [WARN] terdeteksi modul RUSAK (manifes error): %s. Pesan: %s"):format(moduleFolder.Name, tostring(manifestOrError)))
				end
			else -- Tidak punya manifest
				print(MONITOR_PREFIX .. ("[ClientBootstrapper] [FOLDER_NO_MANIFEST] [DEBUG] Folder '%s' tidak punya ClientManifest, diabaikan (mungkin Service?)."):format(moduleFolder.Name))
				serviceFolderCount += 1
			end
		end
	end

	table.sort(modulesToLoad, function(a, b) return a.Manifest.loadOrder < b.Manifest.loadOrder end)

	print(MONITOR_PREFIX .. ("[ClientBootstrapper] [LOAD_ORDER_START] [INFO] Ditemukan %d folder, %d manifes valid. Memulai load order..."):format(discoveredCount, #modulesToLoad))

	local totalAktif = 0
	local totalNonaktif = 0
	local totalRusakManifest = discoveredCount - #modulesToLoad - serviceFolderCount -- Hitung yg gagal manifest (yg BUKAN service)
	local totalRusakEntry = 0

	for _, moduleInfo in ipairs(modulesToLoad) do
		local manifest = moduleInfo.Manifest
		local folder = moduleInfo.Folder

		if manifest.autoInit == true then
			local entryName = manifest.entry or "Main" -- Default ke Main.lua
			-- Cari file .lua nya (ModuleScript di Roblox TIDAK perlu extension .lua)
			local entryScript = folder:FindFirstChild(entryName)

			if entryScript and entryScript:IsA("ModuleScript") then
				local success, module = pcall(require, entryScript)
				if success and typeof(module) == "table" and typeof(module.Init) == "function" then
					print(MONITOR_PREFIX .. ("[ClientBootstrapper] [MODULE_LOAD_ACTIVE] [INFO] Meload modul AKTIF: %s (Order: %d)"):format(manifest.name, manifest.loadOrder))
					local initSuccess, initError = pcall(module.Init, module, DI_Container)
					if not initSuccess then
						print(MONITOR_PREFIX .. ("      └[ClientBootstrapper] [MODULE_INIT_FAIL] [ERROR] Gagal Init() modul '%s': %s"):format(manifest.name, initError))
						totalRusakEntry += 1
					else
						-- Masukkan instance modul ke DI Container agar modul lain bisa pakai
						DI_Container[manifest.name] = module
						totalAktif += 1
					end
				else
					print(MONITOR_PREFIX .. ("[ClientBootstrapper] [MODULE_LOAD_FAIL] [ERROR] Gagal meload modul RUSAK (entry point error atau tidak punya :Init()): %s"):format(manifest.name))
					totalRusakEntry += 1
				end
			else
				print(MONITOR_PREFIX .. ("[ClientBootstrapper] [MODULE_LOAD_FAIL] [ERROR] Gagal meload modul RUSAK (entry file '%s' tidak ditemukan): %s"):format(entryName, manifest.name))
				totalRusakEntry += 1
			end
		else
			print(MONITOR_PREFIX .. ("[ClientBootstrapper] [MODULE_SKIP_DISABLED] [INFO] Dilewati modul NONAKTIF: %s (Order: %d)"):format(manifest.name, manifest.loadOrder))
			totalNonaktif += 1
		end
	end

	local totalRusak = totalRusakManifest + totalRusakEntry
	local totalModul = discoveredCount - serviceFolderCount -- Hanya hitung folder yg seharusnya modul

	-- Log Ringkasan Baru yang Lebih Gagah
	print(OS_PREFIX .. "-------------------- RINGKASAN BOOT CLIENT --------------------")
	print(OS_PREFIX .. ("   Total Folder Modules Ditemukan : %d"):format(totalModul))
	print(OS_PREFIX .. ("   Modul dengan Manifes Valid     : %d"):format(#modulesToLoad))
	print(OS_PREFIX .. ("   ✅ Modul AKTIF Berhasil Load   : %d"):format(totalAktif))
	print(OS_PREFIX .. ("   💤 Modul NONAKTIF Dilewati     : %d"):format(totalNonaktif))
	print(OS_PREFIX .. ("   ⚠️ Modul RUSAK (Total)          : %d"):format(totalRusak))
	print(OS_PREFIX .. ("      └ Rusak karena Manifes    : %d"):format(totalRusakManifest))
	print(OS_PREFIX .. ("      └ Rusak karena Entry/Init : %d"):format(totalRusakEntry))
	print(OS_PREFIX .. "-------------------------------------------------------------")

	-- PRINT BARU 2: Kasih tau OS udah SIAP!
	print(OS_PREFIX .. "Client 100% SIAP!")
	print(MONITOR_PREFIX .. "[ClientBootstrapper] [OS_READY] [INFO] OS Client 100% SIAP!")

end

return ClientBootstrapper
