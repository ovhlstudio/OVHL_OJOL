# 🎮 OVHL GAMEPLAY DESIGN – Blueprint Resmi Beta v1 (EXPANDED)

> **Project:** Omniverse Highland – Ojol Roleplay  
> **Blueprint Versi:** 4.1 Rebuild (Expanded Roadmap Fase 3–8)  
> **Status:** ACTIVE DEVELOPMENT  
> **Author:** Hanif Saifudin (Lead Dev) + AI Co-Dev System  
> **Tanggal Update:** 2025-10-22 15:36:55

---

## 📚 Catatan Singkat
File ini adalah versi **expanded** dari `OVHL_GAMEPLAY_DESIGN.md`.  
Isinya menambahkan **rincian teknis** tiap fase (Fase 3–8), termasuk struktur folder, contoh kode, event yang digunakan, dan hubungan antar modul.  
Dokumen ini dirancang untuk developer & AI Co-Dev sebagai panduan implementasi modul.

---

# 🧱 FASE 3 — Dealer & Kepemilikan Motor 🏬🛵

**Tujuan:** Pemain dapat membeli motor, memilikinya, dan menyimpan metadata kendaraan di DataService. Menggunakan hasil Fase 2 (prototype) sebagai acuan.

### 🔧 Modul terkait
- `DealerModule` (Server) — logika jual/beli, validasi pembayaran, daftar kendaraan.
- `DealerUI` / `DealerClient` (Client) — UI marketplace, preview vehicle, ProximityPrompt handling.
- `ZoneService` (Core) — detect tag `DealerZone` untuk menampilkan UI.
- `DataService` (Core) — menyimpan `OwnedVehicles` & `CurrentVehicle` per player.

### 📁 Struktur folder contoh
```
Source/Core/Server/Modules/DealerModule/
  ├─ manifest.lua
  ├─ Handler.lua
  └─ config.lua

Source/Core/Client/Modules/DealerClient/
  ├─ ClientManifest.lua
  ├─ Main.lua
  └─ ui_template.lua
```

### 🧾 Data yang dipakai (DataService)
- Per-player:
  - `OwnedVehicles = {}` (list vehicleID)
  - `CurrentVehicle = nil`
- Global (opsional):
  - `VehicleCatalog = { vehicleID -> {price, tier, modelRef, stats} }`

### 🔁 Alur Kerja (high-level)
1. Builder men-tag area dealer dengan `DealerZone`.
2. Saat player masuk area, `ZoneService` -> client `DealerClient` tampilkan UI.
3. Player pilih vehicle -> client invoke server request `BuyVehicle`.
4. Server `DealerModule` validasi funds lewat `DataService:GetPlayerData()`.
5. Jika sukses, server `DataService:SetPlayerData(...)` & `EventService:FireClient(player, "PurchaseSuccess", details)`.

### 🧩 Contoh kode (Server Handler.lua)
```lua
-- Handler.lua
local Dealer = {}
function Dealer:init(context)
  self.DataService = context.DataService
  self.EventService = context.EventService
  self.SystemMonitor = context.SystemMonitor
  self.catalog = require(script.Parent:WaitForChild("config")).VehicleCatalog
  self.EventService:CreateFunction("BuyVehicle", function(player, vehicleID)
    local pdata = self.DataService:GetPlayerData(player)
    local price = self.catalog[vehicleID].price
    if pdata.Cash >= price then
      pdata.Cash -= price
      table.insert(pdata.OwnedVehicles, vehicleID)
      self.DataService:SavePlayerData(player) -- implementasi internal
      return true, "Beli sukses"
    else
      return false, "Uang tidak cukup"
    end
  end)
end
return Dealer
```

### 🧭 Contoh kode (Client Main.lua)
```lua
local DealerClient = {}
function DealerClient:Init(DI)
  local Events = DI.EventService -- jika ada client event wrapper
  -- saat user klik buy:
  local success, msg = Events:InvokeServer("BuyVehicle", "T1_Bebek")
  if success then UIManager:ShowToast("Pembelian berhasil!") end
end
return DealerClient
```

---

# 🧱 FASE 4 — Sistem Pekerjaan & Ekonomi Mikro 🏢💼

**Tujuan:** Pemain bisa mendaftar di perusahaan ojek, bekerja (ON DUTY), dan menerima kompensasi. Perusahaan mengatur tarif, komisi, dan sanksi.

### 🔧 Modul terkait
- `CompanyModule` (Server) — definisi perusahaan, tarif dasar per km, komisi, policy.
- `DutyModule` (Client) — UI HP Ojol, tombol [ON DUTY]/[OFF DUTY], notifikasi.
- `ProgressionModule` (Server) — audit performa dan sanksi.
- `EventService`, `DataService`.

### 📁 Struktur
```
Source/Core/Server/Modules/CompanyModule/
  ├─ manifest.lua
  ├─ Handler.lua
  └─ config.lua

Source/Core/Client/Modules/DutyModule/
  ├─ ClientManifest.lua
  └─ Main.lua
```

### 🧾 Data & Config
- Per-company config (disimpan di `CompanyModule/config.lua` atau DataService global):
  - `base_rate_per_km`
  - `commission_rate`
  - `penalty_reject`
  - `penalty_late_per_sec`
- Per-player:
  - `CurrentCompany`
  - `DutyStatus` (`OffDuty`, `OnDuty`, `InMission`)

### 🔁 Alur Kerja (high-level)
1. Player mendekati `CompanyOfficeZone` → client tampilkan UI "Daftar Kerja".
2. Setelah daftar, `DataService` simpan `CurrentCompany`.
3. Saat `[ON DUTY]`, `DutyModule` kirim `EventService` ke server: `PlayerDutyChange`.
4. Saat ada `NewOrderAvailable`, `PassengerRideModule` memilih driver `[OnDuty]` berdasarkan kriteria (proximity, rating, random).
5. Pembayaran & komisi dihitung di `CompanyModule` (server-side) → DataService Update.

### 🧩 Contoh snippet (CompanyModule Handler)
```lua
function CompanyModule:CalculateFare(base_per_km, distance, multipliers)
  local fare = base_per_km * distance * multipliers
  local commission = fare * self.config.commission_rate
  return fare - commission, commission
end
```

---

# 🧱 FASE 5 — NPC Spawner Cerdas 🤖🗺️

**Tujuan:** Spawn NPC pelanggan secara logis di pinggir jalan sesuai traffic, jam, dan event dunia.

### 🔧 Modul terkait
- `NPCSpawnerModule` (Server)
- `TimeManager`, `WeatherModule` (World Layer)
- `ZoneService`, `PathfindingService`, `CollectionService`

### 📁 Struktur
```
Source/Core/Server/Modules/NPCSpawnerModule/
  ├─ manifest.lua
  ├─ Handler.lua
  └─ spawn_rules.lua
```

### 🧾 Data penting
- `spawn_zones` (tagged parts: `SpawnZone_Mall`, etc.)
- `base_spawn_rate`
- `player_count_scaling_factor`

### 🔁 Alur Kerja
1. `NPCSpawner` scan `CollectionService:GetTagged("SpawnZone_*")`.
2. Hitung spawn rate: `spawn_rate = base_rate * f(playerCount, timeOfDay, weather)`
3. Cari titik "pinggir jalan" via Raycast + Pathfinding → spawn NPC.
4. NPC mem-publish event `NewOrderAvailable(npc, orderData)` ke server.

### 🧩 Contoh spawn rate formula
```lua
local function calc_spawn_rate(base, playerCount, trafficFactor)
  return base * math.max(0.5, (playerCount / 10) * trafficFactor)
end
```

---

# 🧱 FASE 6 — Gameplay Loop Ojek 📱🏁

**Tujuan:** Implementasi alur order end-to-end: Notifikasi → Terima → Jemput → Antar → Selesai → Reward.

### 🔧 Modul terkait
- `PassengerRideModule` (Server & Client)
- `ZoneService`, `NPCSpawnerModule`, `DataService`, `EventService`
- `PlayerDataController` (Client)

### 🔁 Alur detail (step-by-step)
1. `NPCSpawner` emit `NewOrderAvailable` (server).
2. `PassengerRideModule` memilih driver `[OnDuty]` (server) → `EventService:FireClient(driver, "NewOrderNotification", orderData)`.
3. Client `PassengerRide` tampilkan notif, player klik `Terima`.
4. Client invoke server `AcceptOrder` → server set `DutyStatus = "InMission"`.
5. Server buat pickup zone memakai `ZoneService:CreateZoneForPlayer`.
6. Saat player reach zone, jalankan hybrid seat logic:
   - Cek `PassengerSeat` di vehicle model; jika ada, seat NPC.
   - Jika tidak, buat `WeldConstraint` ke `JokBelakangPart`.
7. Setelah sampai tujuan, server hitung reward via `CompanyModule:CalculateFare`, update DataService, Fire `MissionCompleted`.

### 🧩 Hybrid seat pseudo
```lua
if vehicle:FindFirstChild("PassengerSeat") then
  npc.Humanoid.Sit = true
else
  local weld = Instance.new("WeldConstraint")
  weld.Part0 = npc.RootPart
  weld.Part1 = vehicle:FindFirstChild("JokBelakangPart")
  weld.Parent = npc
end
```

---

# 🧱 FASE 7 — Cuaca & Ekonomi Dinamis 🌦️💸

**Tujuan:** Interaksi WeatherModule & GlobalEconomyModule memengaruhi tarif, spawn, dan event.

### 🔧 Modul terkait
- `WeatherModule` (World)
- `GlobalEconomyModule` (World)
- `NPCSpawnerModule`, `PassengerRideModule`, `CompanyModule`

### 🔁 Alur Kerja
1. `WeatherModule` update weather state (autonomous) → `EventService:FireAllClients("WeatherChanged", state)`.
2. `GlobalEconomyModule` calculate multiplier berdasar weather & jam → `DataService:SetGlobal("economy_multiplier", val)`.
3. `PassengerRideModule` pakai multiplier untuk menghitung harga akhir.

### 🧩 Snippet (pengaruh cuaca ke fare)
```lua
local base = DataService:GetGlobal("tarif_dasar")
local multiplier = DataService:GetGlobal("economy_multiplier") or 1
local fare = base * distance * multiplier
```

---

# 🧱 FASE 8 — Audit & Progress Pemain 🧾📈

**Tujuan:** Implementasi `ProgressionModule` yang memantau perilaku pemain dan menjalankan kebijakan "Upgrade Paksa" jika perlu.

### 🔧 Modul terkait
- `ProgressionModule` (Server)
- `DataService`, `SystemMonitor`, `CompanyModule`

### 🧾 Ketentuan
- Pemeriksaan berkala (cron job) untuk tiap pemain: saldo, owned vehicles, playtime.
- Rules:
  - Jika `player.Cash > threshold` & `CurrentVehicle` tier rendah → beri penalti persen pendapatan sampai upgrade.
  - Jika player upgrade → remove penalti.

### 🔁 Contoh pseudocode
```lua
for _, player in ipairs(Players:GetPlayers()) do
  local pdata = DataService:GetPlayerData(player)
  if pdata.Cash > 500000 and GetVehicleTier(pdata.CurrentVehicle) == 1 then
    ApplyPenalty(player, 0.5) -- 50% pendapatan
  end
end
```

---

## 🔗 Integrasi Antar Modul & Event Summary

### 🎯 Event kunci
- `ClockSync` (Server -> Client) — sinkron jam
- `WeatherChanged` (World -> Semua) — update cuaca
- `NewOrderAvailable` (NPC -> PassengerRide) — order muncul
- `NewOrderNotification` (Server -> Client) — notifikasi order
- `AcceptOrder` (Client -> Server) — terima order
- `MissionCompleted` (Server -> Client) — reward + UI

### 🔄 Data Flow ringkas
- Global world state disimpan di `DataService.GlobalData`.
- Per-player data di `DataService.PlayerData[player]`.
- Modul baca/ubah hanya lewat API DataService / EventService.
- Semua override admin dicatat di `SystemMonitor`.

---

## 🛠️ Testing & Validation Checklist (per fase)

- [ ] Manifest valid & auto-detected
- [ ] Modul init() sukses tanpa error
- [ ] EventService: client-server roundtrip test
- [ ] DataService: read/write test (player & global)
- [ ] ZoneService: tag detection & create/destroy zone
- [ ] NPC spawn & pathfinding sanity check
- [ ] Hybrid seat handling & failover
- [ ] Economy multiplier correctness test

---

## 🏁 Penutup

Dokumen ini adalah blueprint teknis implementasi Fase 3–8 untuk Ojol Roleplay.  
Setiap bagian cukup detail untuk developer/AI agar bisa membuat modul sesuai standar OVHL Core OS.  
Selanjutnya gua bisa bantu generate template modul (manifest + handler + client main) untuk tiap fase kalo bos mau.

