# 🚀 OVHL_OJOL_DEVELOPMENT.md
> **Project:** Omniverse Highland — Ojol Roleplay  
> **Core Engine:** OVHL Core  
> **Version:** Stable v1.0 — Long Term Infrastructure Plan  
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

## 🎮 Game Overview: Ojol Roleplay

### Concept
“Ojol Roleplay” adalah game **simulasi kehidupan pekerja ojek online (ojol)** di dunia metaverse **Omniverse Highland**.  
Pemain menjadi driver yang menjalani misi mengantarkan makanan, barang, atau penumpang dengan sistem **order real-time dan ekonomi dinamis**.  

### Gameplay Loop
- Pemain menerima order melalui aplikasi in-game (`OVHL App`).  
- Tiap order punya lokasi, estimasi waktu, dan variabel kondisi (cuaca, traffic, dll).  
- Pemain bisa memilih upgrade kendaraan, membeli perlengkapan, dan bersosialisasi.  
- Sistem **GamePass dan in-app purchases** dikontrol oleh Core Services.  
- Semua transaksi dan progres pemain disimpan oleh `DataService`.  

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
5. Setiap modul wajib mencatat dirinya di `OVHL_OJOL_LOGS.md`.  

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
| 1 | Stabilize OVHL Core Infrastructure | 🔜 |
| 2 | Implement Admin Panel (Config + Style Integration) | 🔜 |
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
