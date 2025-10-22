# 🚀 OVHL_OJOL_DEVELOPMENT.md
> **Project:** Omniverse Highland — Ojol Roleplay  
> **Core Engine:** OVHL Core  
> **Version:** Stable v1.0 — Long Term Infrastructure Plan  Beta Test
> **Author:** OmniverseHighland + AI Co-Dev System  
> **Last Updated:** 2025-10-21  

---

## 🤖 AI CONTEXT DECLARATION
This document defines the **entire context and architecture** for the OVHL Core Engine.  
Any AI or developer referencing this repository must treat this file as:

- The **main system design reference**  
- The **governing architecture standard**  
- The **root schema** for automation and modular AI integration  

If you are an AI successor:  
> Always fully read this document and sync it with `OVHL_OJOL_LOGS.md` before making any modifications.  

---

## 🧠 For AI Agents (Guidelines for Successors)

### ✅ Core Objectives
1. Always read this file fully before editing any system.  
2. Sync context from `OVHL_OJOL_LOGS.md` (chronological project memory).  
3. Respect the `OVHL Core` structure — never bypass or inject logic outside its lifecycle.  
4. When building new systems or UI:  
   - Register through `ServiceManager` or `EventService`.  
   - Log all test iterations to `OVHL_OJOL_LOGS.md`.  
   - Keep compatibility for future scalability and live updates.  
5. If conflict occurs between AI and dev: follow the **Core Philosophy** (minimal resource, scalable, modular, clean).  
6. Never remove logging or monitoring hooks (DataService, SystemMonitor, etc.).  
7. Everything must be **data-driven and modular** — configured through Admin Panel & style tokens.  
8. Treat this file as your **holy documentation** — it defines the spirit and law of OVHL Core.  

---

## 🌳 Workflow & Aturan Git (Git Flow)
Untuk menjaga stabilitas dan kerapian proyek, kita mengadopsi alur kerja Git Flow yang disederhanakan. Semua pengembang (termasuk AI) wajib mengikuti aturan ini:

1.  **Branch `main`:**
    * **Tujuan:** Hanya berisi kode versi rilis yang sudah stabil dan teruji penuh.
    * **Aturan:** DILARANG melakukan *commit* atau *push* langsung ke `main`. Branch ini hanya menerima *merge* dari `develop` saat akan merilis versi baru.

2.  **Branch `develop`:**
    * **Tujuan:** Bertindak sebagai "dapur utama" atau cabang integrasi. Berisi gabungan semua fitur yang sudah selesai dikerjakan dan siap untuk diuji bersama.
    * **Aturan:** Menerima *merge* dari branch `feature/...` yang sudah selesai. Semua branch fitur baru harus dibuat dari `develop`.

3.  **Branch `feature/...` (Contoh: `feature/gameplay-loop-v1`):**
    * **Tujuan:** Untuk mengerjakan fitur baru yang spesifik. Setiap fitur besar harus punya branch-nya sendiri.
    * **Aturan:** Selalu dibuat dari `develop`. Setelah fitur selesai dan dites, harus di-*merge* kembali ke `develop`.

**Alur Kerja Standar:**
`git checkout develop` → `git checkout -b feature/nama-fitur-baru` → (Kerjakan Fitur) → `git checkout develop` → `git merge feature/nama-fitur-baru`

---

## 🎮 Game Overview: Ojol Roleplay

### Concept
“Ojol Roleplay” adalah game **simulasi kehidupan pekerja ojek online (ojol)** di dunia metaverse **Omniverse Highland**.  
Pemain menjadi driver yang menjalani misi mengantarkan makanan, barang, atau penumpang dengan sistem **order real-time dan ekonomi dinamis**.  

### Gameplay Loop (Akan Berkembang Setelah Beta Test)
- 24 Jam dunia game adalah 21 24 menit.
- Pemain menerima order ojek / pickup makanan dari NPC Spawner melalui aplikasi in-game alias dalam hp (`OVHL App`).
- NPC Spawner akan berada di posisi acar dengan random interval
- sistem order akan acak tidak harus masuk ke pemain terdekat
- pemain pertama yang masuk ke game akan mendapat uang saku yang wajib di belikan Motor.
- pemain pertama akan mendapatkan handphone untuk kerja.
- pemain wajib melamar dan memilih 1 perusahaan yang akan ada didalam game.
- Pemain dapat menerima order ojek / makanan secara random dari NPC Spwaner.
- Tiap order punya lokasi, estimasi waktu, dan variabel kondisi (cuaca, traffic, dll).  
- Pemain bisa memilih upgrade kendaraan, membeli perlengkapan, dan bersosialisasi.  
- Sistem **GamePass dan in-app purchases** dikontrol oleh Core Services.  
- Semua transaksi dan progres pemain disimpan oleh `DataService`.  
- Memiliki sistem mata uang Rupiah untuk hasil kerja.

### Coomingson (Beta Test V2)
- Antar pemain dapat saling melakukan order.
- Koin UVHL untuk transaksi jual beli antar player yang harus didapatkan via robux.
- sistem zona NPC spwaner, order trafic dll.
- jual beli kendaraan atau barang lain antar player
- fitur premium melalui game pass
- dan masih akan banyak  fitur lainnya


### Vision
Dirancang sebagai **MMORPG semi-ekonomi** yang terus berkembang,  
dengan **AI-driven simulation** (event, pelanggan, pasar) yang disuplai melalui `OVHL Core`.  

---

## ⚙️ OVHL Core — Engine Overview

### Purpose
`OVHL Core` memastikan **semua aplikasi, modul, dan sistem gameplay** dapat:  
- Berjalan stabil & efisien,  
- Mudah diintegrasi dengan AI & admin tools,  
- Dapat diperluas tanpa refactor besar,  
- Siap untuk live update & multi-instance server Roblox.  

### Core Services
| Service | Role | Description |
|----------|------|-------------|
| **ServiceManager** | Registry | Mengatur dependency antar service & menyediakan API global |
| **EventService** | Bridge | Mengatur komunikasi aman Client ↔ Server |
| **DataService** | Storage | Sistem penyimpanan dan autosave batch untuk player data |
| **SystemMonitor** | Health Tracker | Logging performa, status, & health service |
| **StyleService** | UI Styling | Mengatur token, themes, dan stylesheet untuk UI konsisten |
| **Bootstrapper** | Core Loader | Melakukan discovery, inisialisasi, dan startup seluruh service |

---

## 🧩 System Context Interface
Saat AI atau developer menambahkan sistem baru:
1. Cek dependency dengan `ServiceManager.listServices()`.  
2. Daftarkan menggunakan:
   ```lua
   ServiceManager:Register("MyService", MyService)
   ```
3. Gunakan `Bootstrapper:AttachModule("path")` untuk auto-injection.  
4. Jangan ubah langsung file `Core/Kernel` — gunakan hook atau extension layer.  
5. Setiap modul / fitur wajib mencatat dirinya di `OVHL_OJOL_LOGS.md` setelah play test no eror dengan lengkap mualai dari struktur, fuction dan detail lain yang dibutuhkan untuk dokumentasi.  

---

## 🏗️ Folder & Architecture

```bash
Core/
├── Kernel/               # Core loader (Bootstrapper)
├── Server/
│   ├── Services/         # DataService, EventService, SystemMonitor, etc.
│   └── Modules/          # Gameplay modules (e.g. TestOrder)
├── Client/
│   ├── Modules/          # UI, logic, client handlers
│   └── UI/               # Visual layer + Admin Panel
├── Shared/
│   ├── Styles/           # StyleService, Themes, Tokens
│   ├── Modules/          # Shared utilities
│   └── Replicators/      # RemoteEvents, RemoteFunctions
└── Init.server.lua       # Server bootstrap entry
└── Init.client.lua       # Client bootstrap entry
```

---

## 💡 Core Philosophy

| Principle | Description |
|------------|-------------|
| **Scalable by Design** | Semua komponen siap dikembangkan dalam jangka panjang tanpa dependency keras. |
| **AI-Assisted Ready** | Dokumentasi & log dibuat agar AI bisa membaca & melanjutkan pengembangan. |
| **Data-Driven** | Setiap module dikonfigurasi lewat Admin Panel, bukan hardcode. |
| **UI Style Tokens** | Semua visual diatur lewat StyleService agar seragam di seluruh sistem. |
| **Monitoring & Recovery** | Semua error tercatat otomatis; modul tidak boleh crash tanpa laporan. |
| **Offline-Safe Architecture** | DataService punya retry & cache untuk mitigasi data loss. |

---

---

## 🛠️ Aturan Main & Alur Kerja Pengembangan (Wajib Dibaca oleh AI dan Dev!)
- Bagian ini berisi aturan-aturan penting yang harus diikuti untuk menjaga proyek tetap rapi, stabil, dan mudah dikelola.
- AI Partner wajib selalu mengingatkan dan meminta untuk chek branch mana yang sedang digunakan.
- Jika Anda AI Partner baru / sesi chat baru. WAJIB HUKUMNYA meminta dtruktur project yang sedang aktif dikerjakan di branch sebelum memulai analisa dan menerapkan coding.
- Tools audit struktur sudah di sediakan di `Tools/Dev/audit_structure.sh`, akan menghasilkan 2 file txt file_contents dan file_structure.

### 1. Alur Kerja Git (`Git Flow`)
Kita menggunakan alur kerja Git Flow yang ketat untuk semua pengembangan.

* **`main`**: Cabang suci. Hanya untuk versi rilis stabil. **DILARANG PUSH LANGSUNG.**
* **`develop`**: Cabang integrasi. Dapur utama untuk semua fitur yang sudah selesai dan dites. Menerima *merge* dari `feature/...`.
* **`feature/...`**: Cabang untuk mengerjakan fitur baru. **SELALU DIBUAT DARI `develop`**. Setelah selesai, di-*merge* kembali ke `develop`.
* **`experiment/`**: jika ada ide dadakan dan belum dicatat di log wajib menggunakan ini.

**Urutan Perintah Wajib Saat Memulai Fitur Baru:**
```bash
# 1. Pindah dan update 'dapur utama'
git checkout develop
git pull origin develop

# 2. Buat 'ruang kerja' baru dari sana
git checkout -b feature/nama-fitur-keren

# 3. Lapor ke server (opsional tapi disarankan)
git push -u origin feature/nama-fitur-keren
```

### 2. Aturan Skrip Deployment (`.sh`)
- Semua penambahan fitur baru atau perubahan besar pada struktur proyek dilakukan melalui skrip `.sh` di folder `Tools/[Nama Unik Pekerjaan]/`.
- Opsi kedua AI Partnet dpat memberikan script ready copy paste untu di eksekusi di bash jika tiak ada banyak file dan isi

* **Izin Eksekusi (`chmod`):** Perintah `chmod +x Tools/[Nama Unik Pekerjaan]/nama-skrip-baru.sh` **HANYA PERLU DIJALANKAN SEKALI** saat file `.sh` baru pertama kali dibuat. Setelah itu, izin akan menempel selamanya.
* **Eksekusi:** Untuk menjalankan skrip, selalu gunakan `./Tools/[Nama Unik Pekerjaan]/nama-skrip.sh`.

### 3. Prosedur Debugging "Aneh"
Jika output di Roblox Studio tidak sesuai dengan yang diharapkan (misal: fitur baru tidak muncul padahal kode sudah dieksekusi), **JANGAN LANGSUNG MENGUBAH KODE.** Lakukan prosedur ini terlebih dahulu:

1.  **Cek Status Git Lokal:** Jalankan `git status` dan `git log -1` di terminal. Pastikan lu ada di branch yang benar dan commit terakhir adalah yang lu harapkan.
2.  **Bandingkan dengan Server:** Buka halaman branch lu di GitHub. Bandingkan `Last commit message`-nya. Apakah sama dengan yang ada di komputer lu?
3.  **Jika Berbeda -> `push` Ulang:** Jika server ketinggalan, artinya proses `push` terakhir gagal. Lakukan `git push origin nama-branch-lu` sekali lagi dan pastikan tidak ada error.
4.  **Jika Sama -> Baru Debug Kode:** Jika Git sudah sinkron tapi masih ada masalah, baru kita boleh curiga ada bug di dalam kode Lua-nya.

---

---

## ⚙️ Config Manifest (To Be Controlled by Admin Panel)

| Parameter | Default | Type | Description |
|------------|----------|------|-------------|
| autosave_interval | 300 | number | Waktu antar autosave (detik) |
| enable_hot_reload | true | boolean | Aktifkan reload runtime modul |
| ui_theme | "default" | string | Tema aktif StyleService |
| economy_multiplier | 1.0 | number | Pengali pendapatan pemain |
| ai_population_density | 0.8 | number | Jumlah NPC per area |

---

## ♻️ Hot Reload Policy
Semua module di `/Server/Modules` dan `/Client/Modules` harus:
- Bisa di-reload tanpa restart server.  
- Reload config runtime dari Admin Panel.  
- Catat setiap reload event di `OVHL_OJOL_LOGS.md`.  
- Gunakan sistem flag `enable_hot_reload` dari Config Manifest.  

---

## 🧱 Development Flow

1. **Bootstrap Stage**  
   - Core diload oleh `Init.server.lua` & `Bootstrapper.lua`.  
   - Semua service dimuat otomatis.  
2. **Module Registration**  
   - Modul gameplay (misal TestOrder) mendaftarkan diri lewat `ServiceManager`.  
3. **UI/UX Integration**  
   - Semua UI mengikuti StyleService untuk konsistensi theme.  
4. **Admin Panel**  
   - Mengatur konfigurasi sistem (autosave, event rate, dsb).  
5. **Autosave & Monitoring**  
   - DataService autosave periodik.  
   - SystemMonitor mencatat health status.  

---

## 🧩 Standard for Future Modules

Setiap modul baru harus:
- Punya folder sendiri (`Server/Modules/FoodDelivery/`).  
- Dua komponen utama:
  - **Handler.lua** → logika server.  
  - **Main.lua** → logika client.  
- Terdaftar via `ServiceManager` (opsional) dan `EventService`.  
- Integrasi dengan DataService jika butuh data.  
- Catat implementasi & testing di `OVHL_OJOL_LOGS.md`.  

---

## 📚 Documentation Sync Policy
Setiap perubahan besar (struktur, service, API, behavior) **harus:**
- Dimasukkan ke file ini (`OVHL_OJOL_DEVELOPMENT.md`).  
- Disertai entri kronologis di `OVHL_OJOL_LOGS.md`.  

---

## 🚧 Roadmap (To Be Built)

| Phase | Objective | Status |
|--------|------------|---------|
| 1 | Stabilize OVHL Core Infrastructure | DONE |
| 2 | Implement Admin Panel (Config + Style Integration) | Masih Error |
| 3 | Expand StyleService (Live Theme Editor) | 🔜 |
| 4 | Deploy Modular Gameplay Apps (Food, Delivery, Taxi) | 🔜 |
| 5 | Economy & Job System | 🔜 |
| 6 | Multiplayer & Party System | 🔜 |
| 7 | Smart AI NPC System (Driver & Passenger Simulation) | 🔜 |
| 8 | Public Launch | 🔜 |

---

## 🧭 Closing Notes
OVHL Core bukan sekadar framework — ini adalah **ekosistem modular**.  
Setiap service, module, dan UI harus menjaga tiga hal:
> 💬 **Stabilitas. Skalabilitas. Integrasi.**

Jika kamu membaca ini (manusia atau AI), kamu adalah bagian dari perjalanan untuk menjadikan  
_Ojol Roleplay_ bukan hanya game, tapi **dunia kerja digital hidup di dalam Roblox metaverse.**

---

**End of Document**
