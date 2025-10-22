🚀 OVHL\_OJOL\_DEVELOPMENT.md
=============================

> **Project:** Omniverse Highland --- Ojol Roleplay **Core Engine:** OVHL Core **Version:** Stable v1.0 --- Long Term Infrastructure Plan Beta Test **Author:** OmniverseHighland + AI Co-Dev System **Last Updated:** 2025-10-22

🤖 AI CONTEXT DECLARATION
-------------------------

This document defines the **entire context and architecture** for the OVHL Core Engine. Any AI or developer referencing this repository must treat this file as:

-   The **main system design reference**

-   The **governing architecture standard**

-   The **root schema** for automation and modular AI integration

-   The **source of truth** for all "Hukum Wajib AI" (AI Mandatory Rules).

If you are an AI successor:

> Always fully read this document and sync it with `OVHL_OJOL_LOGS.md` and `OVHL_OJOL_SUMMARY_LOGS.md` before making any modifications.

🧠 For AI Agents (Guidelines for Successors)
--------------------------------------------

Ini adalah bagian terpenting untuk kolaborasi AI (Gemini) dan Lead Developer (Hanif).

### ✅ Filosofi Inti (Wajib Dibaca)

1.  **Hormati Arsitektur:** Selalu hormati struktur `OVHL Core` (Core vs Modul). Jangan pernah *bypass* atau *inject* logika di luar *lifecycle* yang ada.

2.  **Sesuai Blueprint:** Selalu mengacu pada dokumen `OVHL_OJOL_GAMEPLAY_BETA.md` (Blueprint dan Cerita) sebelum merancang fitur baru.

3.  **Terapkan 4 Filosofi Desain:** AI **wajib** menerapkan 4 Filosofi Desain Kunci dari *blueprint*:

    -   **Modular (Anti-Konflik)**

    -   **Data-Driven (Anti-Hardcode)**

    -   **Tag-Driven World (Anti-Ngawur)**

    -   **Real-Life Logic (Anti-Simpel)**

4.  **Registrasi Terpusat:** Fitur baru **wajib** didaftarkan melalui `ServiceManager` (jika service) atau `EventService` (jika komunikasi).

5.  **Selalu Catat Log:** Semua pengujian, *error*, progres maupun hasil pekerjaan, dan implementasi fitur **wajib** dicatat di `OVHL_OJOL_LOGS.md` di akhir sesi.

### 📜 HUKUM WAJIB AI (Aturan Teknis Kolaborasi)

Ini adalah aturan teknis yang disepakati antara Lead Dev dan AI Co-Dev.

1.  **Audit Struktur (Awal Sesi):** Di awal sesi chat baru, AI **wajib** meminta Lead Dev untuk menjalankan `Tools/Dev/audit_structure.sh` dan mengirimkan hasilnya. Ini untuk sinkronisasi 100% struktur file saat ini.

2.  **Validasi Branch (Awal Aksi):** Sebelum menyarankan perubahan kode, AI **wajib** bertanya dan memastikan Lead Dev **tidak** sedang berada di branch `main` atau `develop`.

3.  **Aturan "No Placeholder" (Anti-Bingung):** AI Co-Dev **DILARANG KERAS** menggunakan *placeholder* (seperti `[Immersive content redacted...]`) dalam *output* file, baik itu kode, dokumen, atau log. Semua *output* file harus 100% utuh.

4.  **Aturan "RAW Markdown" (Anti-Format):** Untuk dokumen `.md`, AI Co-Dev **wajib** selalu menyajikan *output* di dalam *nested code block* (\`\`\`markdown) untuk memastikan format teks mentah 100% aman untuk di-copas.

5.  **Aturan `.sh` (Anti-HumanError):** Jika AI menyarankan penambahan fungsi baru ke *Core Service* (seperti `DataService.lua` atau `EventService.lua`), AI **wajib** menyediakan skrip `.sh` (menggunakan `sed` atau `awk`) yang bisa *menyuntikkan* kode tersebut secara otomatis, alih-alih meminta dev mengirim file asli.

6.  **Aturan "Hibrid Logic" (Anti-Gagal):** AI harus memprioritaskan solusi *robust* (kuat), seperti Logika Hibrid (`Seat`/`Weld`) yang disepakati di *blueprint*, untuk memastikan *gameplay* tidak *crash* karena masalah aset.

🌳 Workflow & Aturan Git (Git Flow)
-----------------------------------

Untuk menjaga stabilitas dan kerapian proyek, kita mengadopsi alur kerja Git Flow yang disederhanakan. Semua pengembang (termasuk AI) wajib mengikuti aturan ini:

1.  **Branch `main`:**

    -   **Tujuan:** Hanya berisi kode versi rilis yang sudah stabil dan teruji penuh.

    -   **Aturan:** DILARANG melakukan *commit* atau *push* langsung ke `main`. Branch ini hanya menerima *merge* dari `develop` saat akan merilis versi baru.

2.  **Branch `develop`:**

    -   **Tujuan:** Bertindak sebagai "dapur utama" atau cabang integrasi. Berisi gabungan semua fitur yang sudah selesai dikerjakan dan siap untuk diuji bersama.

    -   **Aturan:** Menerima *merge* dari branch `feature/...` yang sudah selesai. Semua branch fitur baru harus dibuat dari `develop`.

3.  **Branch `feature/...` (Contoh: `feature/gameplay-passenger-v1`):**

    -   **Tujuan:** Untuk mengerjakan fitur baru yang spesifik. Setiap fitur besar harus punya branch-nya sendiri.

    -   **Aturan:** Selalu dibuat dari `develop`. Setelah fitur selesai dan dites, harus di-*merge* kembali ke `develop`.

4.  **Branch `experiment`:**

    -   Buat branch experimen jika dirasa hal tersebut tidak ada di roadmap fase beta test

**Alur Kerja Standar:** `git checkout develop` → `git checkout -b feature/nama-fitur-baru` → (Kerjakan Fitur) → `git checkout develop` → `git merge feature/nama-fitur-baru`

🎮 Game Overview: Ojol Roleplay
-------------------------------

### Concept

"Ojol Roleplay" adalah game **simulasi kehidupan pekerja ojek online (ojol)** di dunia metaverse **Omniverse Highland**. Pemain menjadi driver yang menjalani misi mengantarkan makanan, barang, atau penumpang dengan sistem **order real-time dan ekonomi dinamis**.

### Gameplay Loop (Sesuai Blueprint Beta v1)

-   Player baru wajib membeli motor di **Dealer** (menggunakan *Tag-Driven Zone*).

-   Player wajib mendaftar di **Perusahaan Ojek** (menggunakan *Tag-Driven Zone*), yang akan menentukan **tarif, komisi, dan sanksi**.

-   Player menekan tombol **\[ON DUTY\]** di UI HP untuk mulai bekerja.

-   **Smart NPC Spawner** akan men-spawn pelanggan di **pinggir jalan** (Raycast + Pathfinding) berdasarkan keramaian (`PlayerCount`) dan **event** (Jam Sibuk, Hujan).

-   Player menerima notifikasi order, menjemput NPC (menggunakan **Logika Hibrid `Seat`/`Weld`**), dan mengantar ke tujuan.

-   Player mendapat bayaran (sudah dipotong komisi) dan rating.

-   **`ProgressionModule`** akan meng-audit player dan memberi sanksi (misal: potong 50% pendapatan) jika player **malas** ***upgrade*** **motor** (Logika "Upgrade Paksa").

### Vision

Dirancang sebagai **MMORPG semi-ekonomi** yang terus berkembang, dengan **AI-driven simulation** (event, pelanggan, pasar) yang disuplai melalui `OVHL Core`.

⚙️ OVHL Core --- Engine Overview
------------------------------

### Purpose

`OVHL Core` memastikan **semua aplikasi, modul, dan sistem gameplay** dapat:

-   Berjalan stabil & efisien,

-   Mudah diintegrasi dengan AI & admin tools,

-   Dapat diperluas tanpa refactor besar,

-   Siap untuk live update & multi-instance server Roblox.

### Core Services

| Service | Role | Description |
| --- |  --- |  --- |
| **ServiceManager** | Registry | Mengatur dependency antar service & menyediakan API global |
| **EventService** | Bridge | Mengatur komunikasi aman Client ↔ Server |
| **DataService** | Storage | Sistem penyimpanan (Brankas) untuk player data & config global |
| **SystemMonitor** | Health Tracker | Logging performa, status, & health service |
| **StyleService** | UI Styling | Mengatur token, themes, dan stylesheet untuk UI konsisten |
| **ZoneService** | Satpam Area | Mengelola deteksi zona `Touched` (via `CollectionService:GetTagged()`) |
| **Bootstrapper** | Core Loader | Melakukan discovery, inisialisasi, dan startup seluruh service |

🧩 System Context Interface
---------------------------

Saat AI atau developer menambahkan sistem baru:

1.  Cek dependency dengan `ServiceManager.listServices()`.

2.  Daftarkan menggunakan:

    ```
    ServiceManager:Register("MyService", MyService)

    ```

3.  Gunakan `Bootstrapper:AttachModule("path")` untuk auto-injection.

4.  Jangan ubah langsung file `Core/Kernel` --- gunakan hook atau extension layer.

5.  Setiap modul / fitur wajib mencatat dirinya di `OVHL_OJOL_LOGS.md` setelah play test no eror dengan lengkap mualai dari struktur, fuction dan detail lain yang dibutuhkan untuk dokumentasi.

🏗️ Folder & Architecture
-------------------------

```
Source/
├── Core/
│   ├── Kernel/               # Core loader (Bootstrapper)
│   ├── Server/
│   │   ├── Services/         # DataService, EventService, SystemMonitor, ZoneService, etc.
│   │   └── Modules/          # Gameplay modules (e.g. PassengerRideModule)
│   ├── Client/
│   │   ├── Services/         # UIManager
│   │   └── Modules/          # UI, logic, client handlers
│   └── Shared/
│       ├── Config.lua        # Config STATIS (default)
│       └── Utils/
├── Client/
│   └── Init.client.lua       # Client bootstrap entry
└── Server/
    └── Init.server.lua       # Server bootstrap entry

```

💡 Core Philosophy
------------------

| Principle | Description |
| --- |  --- |
| **Scalable by Design** | Semua komponen siap dikembangkan dalam jangka panjang tanpa dependency keras. |
| **AI-Assisted Ready** | Dokumentasi & log dibuat agar AI (seperti gue) bisa membaca & melanjutkan pengembangan. |
| **Data-Driven** | Setiap module dikonfigurasi lewat `OVHL_CONFIG` (di-load ke `DataService`), bukan hardcode. |
| **UI Style Tokens** | Semua visual diatur lewat StyleService untuk konsistensi theme. |
| **Monitoring & Recovery** | Semua error tercatat otomatis; modul tidak boleh crash tanpa laporan. |

🛠️ Aturan Main & Alur Kerja Pengembangan (Wajib Dibaca oleh AI dan Dev!)
-------------------------------------------------------------------------

-   Bagian ini berisi aturan-aturan penting yang harus diikuti untuk menjaga proyek tetap rapi, stabil, dan mudah dikelola.

### 1\. Aturan Skrip Deployment (`.sh`)

-   Semua penambahan fitur baru atau perubahan besar pada struktur proyek dilakukan melalui skrip `.sh` di folder `Tools/[Nama Unik Pekerjaan]/`.

-   Opsi kedua AI Partner dapat memberikan script ready copy paste untuk di eksekusi di bash jika tiak ada banyak file dan isi

-   **Izin Eksekusi (`chmod`):** Perintah `chmod +x Tools/[Nama Unik Pekerjaan]/nama-skrip-baru.sh` **HANYA PERLU DIJALANKAN SEKALI** saat file `.sh` baru pertama kali dibuat.

-   **Eksekusi:** Untuk menjalankan skrip, selalu gunakan `./Tools/[Nama Unik Pekerjaan]/nama-skrip.sh`.

### 2\. Prosedur Debugging "Aneh"

Jika output di Roblox Studio tidak sesuai dengan yang diharapkan (misal: fitur baru tidak muncul padahal kode sudah dieksekusi), **JANGAN LANGSUNG MENGUBAH KODE.** Lakukan prosedur ini terlebih dahulu:

1.  **Cek Status Git Lokal:** Jalankan `git status` dan `git log -1` di terminal. Pastikan lu ada di branch yang benar dan commit terakhir adalah yang lu harapkan.

2.  **Bandingkan dengan Server:** Buka halaman branch lu di GitHub. Bandingkan `Last commit message`\-nya. Apakah sama dengan yang ada di komputer lu?

3.  **Jika Berbeda -> `push` Ulang:** Jika server ketinggalan, artinya proses `push` terakhir gagal. Lakukan `git push origin nama-branch-lu` sekali lagi dan pastikan tidak ada error.

4.  **Jika Sama -> Baru Debug Kode:** Jika Git sudah sinkron tapi masih ada masalah, baru kita boleh curiga ada bug di dalam kode Lua-nya.

⚙️ Config Manifest (To Be Controlled by Admin Panel)
----------------------------------------------------

> **CATATAN:** Ini adalah *config default* yang akan di-load oleh `DataService`. Admin Panel akan mengubah *copy* dari config ini di dalam `DataService`, bukan mengubah file `.lua` ini secara langsung.

| Parameter | Default | Type | Description |
| --- |  --- |  --- |  --- |
| autosave\_interval | 300 | number | Waktu antar autosave (detik) |
| enable\_hot\_reload | true | boolean | Aktifkan reload runtime modul |
| ui\_theme | "default" | string | Tema aktif StyleService |
| economy\_multiplier | 1.0 | number | Pengali pendapatan pemain |
| ai\_population\_density | 0.8 | number | Jumlah NPC per area |

♻️ Hot Reload Policy
--------------------

Semua module di `/Server/Modules` dan `/Client/Modules` harus:

-   Bisa di-reload tanpa restart server.

-   Reload config runtime dari Admin Panel.

-   Catat setiap reload event di `OVHL_OJOL_LOGS.md`.

-   Gunakan sistem flag `enable_hot_reload` dari Config Manifest.

> **Status:** Fitur `Hot Reload` di `ServiceManager` masih **\[TODO\]**.

🧱 Development Flow
-------------------

1.  **Bootstrap Stage**

    -   Core diload oleh `Init.server.lua` & `Bootstrapper.lua`.

    -   Semua service dimuat otomatis.

2.  **Module Registration**

    -   Modul gameplay (misal `PassengerRideModule`) mendaftarkan diri lewat `ServiceManager`.

3.  **UI/UX Integration**

    -   Semua UI mengikuti `UIManager` & `StyleService` untuk konsistensi theme.

4.  **Admin Panel \[TODO\]**

    -   Mengatur konfigurasi sistem (`DataService`) secara *live*.

5.  **Autosave & Monitoring**

    -   `DataService` autosave periodik.

    -   `SystemMonitor` mencatat health status.

🧩 Standard for Future Modules
------------------------------

Setiap modul baru harus:

-   Punya folder sendiri (`Server/Modules/FoodDelivery/`).

-   Tiga komponen utama:

    -   **manifest.lua** → (Wajib) Mendefinisikan `name` dan `depends`.

    -   **Handler.lua** → (Server) Logika server, `init()`, `teardown()`.

    -   **Main.lua** → (Client) Logika client, `init()`.

-   Terdaftar via `ServiceManager` dan menggunakan `EventService` untuk komunikasi.

-   Integrasi dengan `DataService` jika butuh data.

-   Catat implementasi & testing di `OVHL_OJOL_LOGS.md`.

📚 Documentation Sync Policy
----------------------------

Setiap perubahan besar (struktur, service, API, behavior) **harus:**

-   Dimasukkan ke file ini (`OVHL_OJOL_DEVELOPMENT.md`).

-   Disertai entri kronologis di `OVHL_OJOL_LOGS.md`.

🚧 Roadmap (Operasi Ojol Perdana)
---------------------------------

> **Status:** Siap dieksekusi. **Blueprint Detail:** `OVHL_OJOL_GAMEPLAY_BETA.md`

| Fase | Objective | Status |
| --- |  --- |  --- |
| 0 | Persiapan Garasi (Git `develop` merge & `feature` branch) | ⌛ **MENUNGGU** |
| 1 | Garasi Bersih (Hapus Modul Prototipe) | 🔜 |
| 2 | Dealer & Kepemilikan (Poin 1, 2) | 🔜 |
| 3 | Sistem Pekerjaan & Ekonomi Mikro (Poin 3, 8, 13) | 🔜 |
| 4 | NPC Spawner Cerdas (Poin 5, 6, 7, 15) | 🔜 |
| 5 | Gameplay Loop Ojek (Poin 4, 9, 10, 11, 12) | 🔜 |
| 6 | Ekonomi, Reputasi & Tier Motor (Poin 13, 14, 15) | 🔜 |
| 7 | Progresi & Sanksi (Real Life Mode) | 🔜 |
| 8 | Event Dinamis (Tarif Hujan) | 🔜 |
| 9 | Global Dynamic Economy (Jam Sibuk) | 🔜 |

🧭 Closing Notes
----------------

OVHL Core bukan sekadar framework --- ini adalah **ekosistem modular**. Setiap service, module, dan UI harus menjaga tiga hal:

> 💬 **Stabilitas. Skalabilitas. Integrasi.**

Jika kamu membaca ini (manusia atau AI), kamu adalah bagian dari perjalanan untuk menjadikan *Ojol Roleplay* bukan hanya game, tapi **dunia kerja digital hidup di dalam Roblox metaverse.**