Blueprint Gameplay Beta v1
==========================

> **Versi:** 4.0 - Final Blueprint **Last Update:** 2025-10-22 | 11:09 WIB **Status:** LOCKED (Siap Eksekusi)

---

# 🎬 LOGLINE / CERITA GAMEPLAY
<details>
<summary> 
🎬 Logline (Pitch 1 Kalimat)
</summary>

Seorang pendatang baru di kota harus membeli motor pertamanya dan mendaftar di perusahaan ojek, lalu berjuang mengantar pelanggan NPC yang dinamis untuk meng-upgrade motornya, sambil bertahan hidup di bawah aturan ekonomi "Real Life" yang kejam di mana sanksi dan event cuaca bisa mengubah nasib kapan saja.

📖 Sinopsis Gameplay (Player's Journey)
---------------------------------------

Player memulai perjalanannya sebagai "warga sipil" yang hanya dibekali HP dan sedikit uang. Tujuan pertamanya adalah pergi ke **Dealer** (sebuah area yang ditandai *Tag* `DealerZone`), di mana dia bisa membeli motor Tier 1 pertamanya, atau bahkan melihat-lihat motor bekas.

Dengan motor di tangan, player belum bisa bekerja. Dia harus "melamar" di salah satu **Kantor Perusahaan Ojek** (area bertanda *Tag* `CompanyOfficeZone`). Di sinilah nasibnya ditentukan. Perusahaan tempat dia mendaftar akan menjadi "Otak Ekonomi"-nya, yang mengatur **tarif dasar per kilometer**, **persentase komisi** (potongan), dan **sanksi** jika dia menolak order.

Setelah terdaftar, player akhirnya bisa "bekerja". Menggunakan UI "HP Ojol" di layarnya, dia mengganti statusnya menjadi **\[ON DUTY\]**.

Server (`NPCSpawnerModule`), yang terus memantau jumlah player di server untuk **auto-scaling**, akan men-spawn "Pelanggan" (NPC) di zona-zona ramai (ditandai *Tag* `SpawnZone_Mall`, dll) di **pinggir jalan** (menggunakan logika `Raycast` + `Pathfinding`). NPC ini kemudian mengirim sinyal order.

`PassengerRideModule` di server menerima sinyal ini dan memilih player yang sedang `[ON DUTY]` secara acak. Notifikasi order---lengkap dengan info pelanggan, tujuan, dan tarif---muncul di HP player. Jika diterima, status player berubah jadi `[InMission]`.

Player kini mengikuti HUD panah ke "Zona Pickup" NPC. Saat tiba, **Logika Hibrid** berjalan: skrip akan *mencari* `PassengerSeat` di motor player; jika ada, NPC akan duduk dengan elegan. Jika tidak ada (motor jelek/modeler lupa), skrip akan me-`Weld` (menempelkan) NPC ke jok belakang untuk memastikan *gameplay* tetap jalan.

Player lalu mengantar NPC ke "Zona Dropoff". Setelah selesai, misi sukses.

Di sinilah **"REAL LIFE LOGIC"** bekerja. `CompanyModule` (Otak Ekonomi) menghitung bayaran player, langsung memotong komisi perusahaan, dan memberi sanksi jika ada. Di saat yang sama, `ProgressionModule` (Si Auditor) diam-diam mengecek: "Apakah player ini punya uang banyak tapi *malas upgrade* motor?". Jika ya, dia akan memberi sanksi "Potongan Pendapatan 50%" sampai si player membeli motor Tier 2.

Semua ini terjadi di dunia yang hidup. `WeatherModule` bisa tiba-tiba membuat **hujan**, menaikkan semua tarif 1.5x lipat. `GlobalEconomyModule` bisa memicu "Event Jam Sibuk" (18:00-20:00), menaikkan tarif lagi 1.8x lipat, membuat player harus bener-bener "nge-gas" di waktu yang tepat untuk bertahan hidup.

🔑 Fitur Kunci Beta v1 (Untuk Developer)
----------------------------------------

-   **Arsitektur Modular:** `Core OS` (Mesin) terpisah dari `Modul` (Fitur: Dealer, Ojek, Perusahaan).

-   **Dunia Cerdas (Tag-Driven):** *Builder* bisa nambahin 100 dealer baru hanya dengan memberi *Tag* `DealerZone`. Skrip otomatis jalan tanpa diubah.

-   **Ekonomi "Real Life":** Sistem ekonomi diatur oleh *Config* di `CompanyModule` (Komisi, Sanksi) dan diaudit oleh `ProgressionModule` (Upgrade Paksa).

-   **Smart NPC Spawner:** NPC 100% *spawn* di pinggir jalan (Raycast + Pathfinding) dan jumlahnya *auto-scaling* berdasarkan keramaian server.

-   **Event Dinamis:** Dunia bisa "Marah" (Hujan) atau "Berkah" (Jam Sibuk), yang *secara live* mempengaruhi tarif dan *spawn rate*.
</details>

---

# Filosofi Desain Inti (Hukum Wajib)

Dokumen ini adalah cetak biru untuk **OPERASI OJOL PERDANA (Beta v1)**. Semua fase harus mematuhi 4 filosofi ini:

1.  **Modular (Anti-Konflik):** Setiap fitur (Dealer, Ojek, Perusahaan) adalah modul independen. Jika fitur Ojek *error*, fitur Dealer harus tetap jalan.

2.  **Data-Driven (Anti-Hardcode):** Semua angka (harga, tarif, kecepatan) **WAJIB** ada di `OVHL_CONFIG` (atau `DataService`). Tidak boleh ada angka ajaib di dalam skrip modul.

3.  **Real-Life Logic (Anti-Simpel):** Ekonomi harus "serius". Ada inflasi, ada sanksi, ada *reward*. Player harus "kerja", bukan "main-main".

4.  **Tag-Driven World (Anti-Ngawur):** Interaksi dunia (Zona Dealer, Zona Kantor, Zona Spawn) **WAJIB** menggunakan `CollectionService:GetTagged()`. Tim *builder* hanya perlu ngasih "Tag", skrip otomatis jalan.

🗺️ ROADMAP OPERASI
-------------------

### 🚗 FASE 0: Persiapan Garasi (Git)

**Tujuan:** Memastikan `Core OS` sehat dan kita bekerja di *branch* yang benar.

-   **Aksi Teknis:**

    1.  `git checkout develop`

    2.  `git merge feature/admin-panel-v1` (Menyuntikkan *fix* `Core OS` ke `develop`)

    3.  `git push origin develop`

    4.  `git checkout -b feature/gameplay-passenger-v1` (Membuat *branch* kerja baru)

### 🧹 FASE 1: Garasi Bersih

**Tujuan:** Menghapus semua modul prototipe (`TestOrder`, `AdminPanel`, `DevUITester`).

-   **Aksi Teknis:**

    1.  Eksekusi `rm -rf` untuk semua folder modul prototipe di `Source/Core/Server/Modules/` dan `Source/Core/Client/Modules/`.

    2.  Edit `ClientBootstrapper.lua`: Hapus `require` dan `Init` modul yang sudah dihapus.

### 🏬 FASE 2: Dealer & Kepemilikan (Poin Visi 1, 2, 3)

**Tujuan:** Player baru bisa membeli motor pertamanya via 3 Opsi Interaksi.

-   **DataService (`ProfileTemplate`) Upgrade:**

    -   `OwnedVehicles = {}` (e.g., `{"T1_Bebek", "T2_Sport"}`)

    -   `CurrentVehicle = nil`

-   **Interaksi Dunia (Filosofi #4):**

    -   Tim *builder* menaruh `Part` transparan di depan dealer -> **Tag** `DealerZone`.

    -   Tim *builder* menaruh model motor yang dijual -> **Tag** `VehicleForSale`.

-   **Modul Baru:** `DealerModule` (Server & Client)

-   **Aksi Teknis:**

    1.  `ZoneService` mendeteksi Tag `DealerZone` -> `DealerModule` (Client) menampilkan **Opsi Interaksi #1 (Popup UI)** yang berisi daftar motor (Marketplace).

    2.  `ProximityPromptService` (Roblox) mendeteksi player mendekati **Tag** `VehicleForSale` -> Menampilkan **Opsi Interaksi #2 (Tombol \[BUY\])**.

    3.  `DealerModule` (Client) juga menyediakan **Opsi Interaksi #3 (UI Marketplace)** di HP.

    4.  Implementasi fungsi `BeliMotor(player, vehicleID)` (Cek duplikat, panggil `DataService:AddUang` & `DataService:AddVehicle`).

    5.  Implementasi fungsi `JualMotorBekas(player, vehicleID)` (misal: 60% harga beli).

### 🏢 FASE 3: Sistem Pekerjaan & Ekonomi Mikro (Poin Visi 3, 8, 13)

**Tujuan:** Player bisa mendaftar ke perusahaan ojek, yang menjadi **"Otak Ekonomi Mikro"**\-nya.

-   **DataService (`ProfileTemplate`) Upgrade:**

    -   `CurrentCompany = nil` (e.g., "OVHL-Ride")

    -   `DutyStatus = "OffDuty"`

-   **Interaksi Dunia (Filosofi #4):**

    -   Tim *builder* menaruh `Part` transparan di depan kantor -> **Tag** `CompanyOfficeZone`.

-   **`OVHL_CONFIG` (Filosofi #2):**

    -   Menyimpan data *default* perusahaan: `tarif_dasar_per_km = 1500`, `komisi_perusahaan = 0.2` (20%), `sanksi_tolak_order = -500`, `sanksi_telat_pickup_per_detik = -10`.

-   **Modul Baru:** `CompanyModule` (Server) & `DutyModule` (Client)

-   **Aksi Teknis:**

    1.  `ZoneService` mendeteksi Tag `CompanyOfficeZone` -> `UIManager` menampilkan UI "Daftar Kerja".

    2.  `DutyModule` (Client) membuat UI "HP Ojol" (inti) dengan tombol `[ON DUTY] / [OFF DUTY]`.

    3.  Tombol tsb memanggil `RemoteEvent` untuk mengubah `DutyStatus` player di `DataService`.

### 🧍 FASE 4: NPC Spawner Cerdas (Poin Visi 5, 6, 7, 15-constraint)

**Tujuan:** "Pelanggan" (NPC) muncul di *map* secara logis, di pinggir jalan, dan auto-scaling.

-   **Interaksi Dunia (Filosofi #4):**

    -   Tim *builder* menaruh `Part` area besar (misal: area mall) -> **Tag** `SpawnZone_Mall`, `SpawnZone_Kampus`, dll.

-   **Modul Baru:** `NPCSpawnerModule` (Server)

-   **Aksi Teknis:**

    1.  `NPCSpawnerModule` `init()` menggunakan `CollectionService:GetTagged()` untuk memetakan semua `SpawnZone`.

    2.  **Logika Auto-Scaling (Visi):** *Loop* spawner utama akan mengecek `PlayerCount`. `spawn_rate_final = spawn_rate_dasar * (PlayerCount / 10)`. (Disesuaikan).

    3.  **Logika Trafik Zona (Poin 7):** *Loop* akan cek jam game (`Lighting.ClockTime`) dan *config* (`OVHL_CONFIG.traffic_mall_siang`) untuk menentukan zona mana yang aktif.

    4.  **Logika Pinggir Jalan (Poin 15-constraint):** a. Pilih titik *random* di dalam `SpawnZone` aktif. b. `Raycast` ke bawah untuk menemukan `TitikTanah`. c. `PathfindingService:FindNearestPathAsync(TitikTanah, TitikJalanRayaTerdekat)`. d. Spawn NPC di `TitikJalanRayaTerdekat`. (Dijamin di pinggir jalan).

    5.  Saat spawn, NPC menembak *event* `NewOrderAvailable(npc, orderData)` ke server.

### 📱 FASE 5: Gameplay Loop Ojek (Poin Visi 4, 9, 10, 11, 12)

**Tujuan:** Alur inti: Notif -> Terima -> Jemput (Hibrid) -> Antar -> Selesai.

-   **Modul Baru:** `PassengerRideModule` (Server & Client)

-   **Aksi Teknis:**

    1.  `PassengerRideModule` (Server) mendengarkan `NewOrderAvailable`.

    2.  Pilih driver *random* yang statusnya `DutyStatus == "OnDuty"`.

    3.  `EventService:FireClient(driver, "NewOrderNotification", orderData)`.

    4.  `PassengerRideModule` (Client) menampilkan UI Notif di HP. Player klik "Terima".

    5.  Server menerima respon "Terima": a. Ubah `DutyStatus = "InMission"`. b. `ZoneService` membuat "Zona Pickup" di NPC. c. Client menampilkan HUD Panah (Poin 10).

    6.  Player sentuh "Zona Pickup" (Poin 11): a. **Logika Hibrid (Visi):** Cek `vehicle:FindFirstChild("PassengerSeat")`. b. **Jika Ada Seat:** `seat:Sit(npc.Humanoid)`. c. **Jika Gagal (Tidak Ada Seat):** `WeldConstraint.new(vehicle.JokBelakang, npc.RootPart)`. d. `ZoneService` membuat "Zona Dropoff".

    7.  Player sentuh "Zona Dropoff": NPC di-`Destroy`, `DutyStatus = "OnDuty"`, tembak *event* `MissionComplete(player, missionData)`.

### 💸 FASE 6: Ekonomi, Reputasi & Tier Motor (Poin Visi 13, 14, 15)

**Tujuan:** Memberi bayaran (sesuai aturan perusahaan) dan reputasi.

-   **`OVHL_CONFIG` (Filosofi #2):**

    -   Definisi `TierMotor = { T1 = { speed = 50, handling = 1, order_rate_bonus = 0.8 }, T2 = { ... } }`.

-   **DataService (`ProfileTemplate`) Upgrade:**

    -   `Stats_TotalOrders = 0`

    -   `Stats_Rating = 5.0`

-   **Modul Baru:** `PlayerDisplayModule` (Client)

-   **Aksi Teknis (Server):**

    1.  `CompanyModule` (Server) mendengarkan `MissionComplete`.

    2.  Ambil `tarif_dasar`, `komisi` dari *config* `CompanyModule`.

    3.  `bayaran_bersih = tarif_dasar * (1 - komisi)`.

    4.  Panggil `DataService:AddUang(player, bayaran_bersih)`.

    5.  Hitung rating (Beta v1: *random* 4-5) -> `DataService:SetRating(...)`.

    6.  `DataService:Increment("Stats_TotalOrders")`.

-   **Aksi Teknis (Client):**

    1.  `PlayerDisplayModule` (Client) membuat `BillboardGui` di atas kepala player.

    2.  `BillboardGui` menampilkan `player.Name`, `Stats_TotalOrders`, dan `Stats_Rating`.

### 📈 FASE 7: Progresi & Sanksi (REAL LIFE MODE)

**Tujuan:** Memaksa player untuk *upgrade* dan bermain "serius" (Visi "Upgrade Paksa").

-   **Modul Baru:** `ProgressionModule` (Server)

-   **Aksi Teknis:**

    1.  Modul ini berjalan di *loop* (misal: tiap 5 menit).

    2.  Dia "meng-audit" semua player.

    3.  **Logika "Upgrade Paksa":** a. `if player.Uang > OVHL_CONFIG.HargaMotorT2 * 1.5` b. `and player:HasVehicle("T2_Sport") == false then` c. `DataService:SetSanksi(player, "Sanksi_BelumUpgrade", true)` d. `end`

    4.  **Logika Sanksi:** a. Saat `CompanyModule` menghitung bayaran (FASE 6), dia ngecek: b. `if DataService:GetSanksi(player, "Sanksi_BelumUpgrade") == true then` c. `bayaran_bersih = bayaran_bersih * 0.5` (Dipotong 50%!) d. `end`

### 🌧️ FASE 8: Event Dinamis (REAL LIFE MODE)

**Tujuan:** Membuat dunia game terasa "hidup" (Visi "Tarif Hujan").

-   **Modul Baru:** `WeatherModule` (Server)

-   **Aksi Teknis:**

    1.  `WeatherModule` berjalan di *loop* (misal: tiap 15 menit).

    2.  `if math.random() < 0.3 then` -> `EventService:FireAllClients("SetWeather", "Rain")`.

    3.  Client menerima ini dan `Lighting.Atmosphere.Density` diubah.

    4.  `WeatherModule` juga mengubah `OVHL_CONFIG.current_weather_multiplier = 1.5`.

    5.  `CompanyModule` (FASE 6) saat menghitung bayaran, akan mengalikan `bayaran_bersih = bayaran_bersih * OVHL_CONFIG.current_weather_multiplier`.

### 💰 FASE 9: Global Dynamic Economy (REAL LIFE MODE)

**Tujuan:** Memberi *event* ekonomi global yang *auto-scaling* (Visi "Global Config" & "Auto-Scaling").

-   **Modul Baru:** `GlobalEconomyModule` (Server)

-   **Aksi Teknis:**

    1.  **Event Terjadwal:** Cek `ClockTime`. Jika jam 18:00 - 20:00 (Jam Sibuk), `OVHL_CONFIG.current_global_multiplier = 1.8`.

    2.  **Event Random:** `if math.random() < 0.1 then` -> "Event Jumat Berkah", `OVHL_CONFIG.current_global_multiplier = 2.0` selama 10 menit.

    3.  `CompanyModule` (FASE 6) akan *selalu* mengalikan bayaran akhir dengan *multiplier* ini.

    4.  `NPCSpawnerModule` (FASE 4) juga akan membaca *multiplier* ini dan *menaikkan* `spawn_rate`.

**\[AKHIR DOKUMEN\]**