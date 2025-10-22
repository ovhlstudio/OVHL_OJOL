# 📜 OVHL OjolRoleplay – Development & Error Logs

# PANDUAN
<details>
<summary>
Gunakan file ini untuk mencatat setiap kejadian penting:
</summary>

- 🧠 Ide baru
- 🐞 Bug
- ⚙️ Pengujian sistem
- 🧱 Refactor atau perubahan arsitektur
- 💡 Insight desain
- ✅ Progres Tracker
- Dan Kategori Lain Yang Belum

> SETIAP LOG BARU HARUS DI CATAT PALING ATAS
---

## 🗓️ Format Log Standar
```
### [YYYY-MM-DD | HH:MM:SS] [KATEGORI]
Deskripsi singkat tentang kejadian.
Jika relevan, tambahkan detail teknis, path file, atau error message.
```

---

## 🧩 Contoh Log

### [2025-10-21 | 14:37:00] [🧱 INFRASTRUCTURE]
CoreOS V2 Bootstrapper stabil, seluruh service berhasil dimuat otomatis.
EventService dan DataService berhasil sinkron tanpa infinite yield.

---

### [2025-10-21 | 14:44:00] [🐞 BUG]
Masalah pada DataService line 101 – token `if` error akibat parsing config manager lama.
✔️ Solusi: hapus referensi legacy dan ganti dengan placeholder `loadConfigFromManager()`.

---

### [2025-10-21 | 15:22:00] [💡 IDEA]
Tambahkan Admin Panel sebagai modul independen yang bisa mengubah konfigurasi runtime
(Data autosave, event monitor, style theme switcher, dsb).

---

### [2025-10-21 | 15:30:00] [✅ TEST]
Core sukses menjalankan test module `TestOrder` tanpa error.
Client berhasil memanggil server event dengan response valid.

---

> Semua log bersifat kronologis dan akan menjadi timeline resmi pengembangan OVHL CoreOS.
</details>

---
# LOG BARU MULAI DARI SINI

### [2025-10-22 | 16:11:00] [📘 DOCUMENTATION] [🧱 INFRASTRUCTURE]

**Judul:** Penyelesaian Dokumen Inti OVHL – Fase Dokumentasi & Sinkronisasi Repo (v1.1 Final)

**Kolaborator:** Hanif Saifudin (Lead Dev) & Chat GPT (AI Co-Dev)

<details>
<summary><strong>Klik untuk membuka rangkuman detail Operasi Dokumentasi OVHL...</strong></summary>

---

#### **KONTEKS AWAL:**
Setelah penyelesaian upgrade Core OS v2.3 Enterprise dan stabilisasi sistem *auto-detek*, tim memasuki **fase dokumentasi infrastruktur**.  
Tujuan fase ini adalah menyatukan seluruh dokumentasi kerja OVHL agar siap digunakan untuk *AI onboarding*, audit sistem, dan kontrol Git.

#### **TUJUAN OPERASI:**
Membangun 3 dokumen inti dengan format modern OVHL:
1. `OVHL_ENGINE_SPEC.md` — Kitab Teknis Engine  
2. `OVHL_GAMEPLAY_DESIGN_EXPANDED.md` — Blueprint Gameplay Lengkap  
3. `OVHL_DEV_PROTOCOLS.md` — Kitab Hukum Wajib AI & Developer  

Dokumen ketiga menjadi prioritas karena berfungsi sebagai “konstitusi utama” dalam sistem kerja multi-AI dan developer manusia.

---

#### **LANGKAH-LANGKAH OPERASI:**

1. **🧠 FASE 1 – Analisis Awal & Sinkronisasi:**  
   Membaca semua dokumen lama (`OVHL_CORE_OS.md`, `OVHL_OJOL_DEVELOPMENT.md`, `OVHL_GAMEPLAY_BETA.md`) dan menetapkan format dokumentasi final berbasis Markdown OVHL Style (emoji, heading modern, tanpa placeholder).  

2. **🧱 FASE 2 – Penulisan `OVHL_ENGINE_SPEC.md`:**  
   Menyatukan arsitektur OS, ServiceManager, Bootstrapper, dan sistem auto-discovery dalam satu dokumen teknis lengkap.  

3. **🎮 FASE 3 – Revisi Total `OVHL_GAMEPLAY_DESIGN.md`:**  
   Mengembangkan hingga versi **Expanded**, dengan detail fase 3–8, logic modul, world automation, dan data-driven gameplay system.  

4. **⚙️ FASE 4 – Pembangunan `OVHL_DEV_PROTOCOLS.md`:**  
   Menulis dokumen etika AI–Dev, workflow Git, SOP `.sh`, standar folder, serta contoh non-teknis untuk dev baru.  
   Menambahkan juga format baru untuk direktori `Tools/`, `Shell/`, dan `Audit/` yang menyesuaikan struktur repo GitHub:  
   ```
   Tools/
   ├─ Audit/
   ├─ Rojo/
   └─ Shell/[SessionAI]/
   ```

5. **📂 FASE 5 – Sinkronisasi dengan Repo GitHub:**  
   Semua path diverifikasi agar cocok dengan repo `ovhlstudio/OVHL_OJOL`.  
   Struktur folder final dimasukkan ke `OVHL_DEV_PROTOCOLS.md` dan disesuaikan dengan file `default.project.json`.

6. **🧩 FASE 6 – Validasi Encoding & Placeholder Check:**  
   Semua file diperiksa UTF-8 valid dan tidak ada placeholder yang tersisa.  
   Sistem log sudah kompatibel dengan `SystemMonitor` dan `OVHL_OJOL_LOGS.md`.

---

#### **CATATAN KHUSUS:**
- Semua `.sh` script sekarang wajib disimpan di `Tools/Shell/[NamaFolderKerja]`.  
- AI wajib meminta struktur repo di awal sesi dan menjalankan `audit_structure.sh` di akhir sesi.  
- File `Tools/Rojo/default.project.json` dinyatakan sebagai **file suci OS** (immutable).  

---

#### **STATUS AKHIR:**
📘 **Fase Dokumentasi & Sinkronisasi Repo Selesai.**  
Semua dokumen inti sudah ditulis dan tervalidasi:  
✅ `OVHL_ENGINE_SPEC.md`  
✅ `OVHL_GAMEPLAY_DESIGN_EXPANDED.md`  
✅ `OVHL_DEV_PROTOCOLS.md (v1.1 Final)`  

Seluruh file siap **commit → push ke branch aktif → merge ke develop**.  
Langkah berikutnya adalah membuka **meja baru** untuk restrukturisasi Core & Modules agar sesuai blueprint OVHL Ideal.

---

</details>

### [2025-10-22 | 14:05:00] [✅ MILESTONE] [🧱 INFRASTRUCTURE]

**Judul:** Operasi Upgrade OS Selesai - Core OS v2.3 Enterprise (Client Auto-Detek)!

**Kolaborator:** Hanif Saifudin (Lead Dev) & Gemini (AI Co-Dev)

<details>
<summary><strong>Klik untuk membuka rangkuman detail Operasi Upgrade OS...</strong></summary>

---

#### **KONTEKS AWAL:**
Setelah berhasil menstabilkan `AdminPanel` prototype (Fase 2) dan memperbaiki *bug* `ServiceManager` (TAHAP 4 & 5), Lead Dev menyadari adanya **kelemahan fundamental** pada arsitektur *client-side*. `ClientBootstrapper` v1.0 masih bersifat manual (`require` satu per satu), melanggar "Hukum Wajib Zero-Touch" dan visi "Reusable Engine" Core OS.

#### **TUJUAN OPERASI:**
Merombak total `ClientBootstrapper` (menjadi v2.x) agar 100% otomatis mendeteksi modul client melalui sistem `manifest` (mirip sisi server), sehingga Core OS (Server & Client) benar-benar *plug-and-play* dan siap dicopy-paste ke proyek game lain.

#### **LANGKAH-LANGKAH OPERASI & DRAMA DEBUGGING:**

1.  **FASE 0 (Persiapan Git):** Berhasil memindahkan semua *fix* dari `feature/admin-panel-v1` ke `develop`, lalu membuat *branch* kerja baru yang bersih: `feature/upgrade-ovhl-os`.

2.  **SUB-TUGAS 1 (Refactor Struktur):** Berhasil merombak struktur folder `Source/Core/Client/` menggunakan skrip `.sh`. `PlayerDataController` & `MainHUD` dipindah ke `Modules/`, folder lama (`Controllers/`, `UI/`) dihapus, dan 3 modul *debug* dibuat (`DebugProtoActive`, `Disabled`, `Broken`). `ClientBootstrapper.lua` v1 dihapus.

3.  **SUB-TUGAS 2 (Implementasi Otak v2.0):** Mengisi `ClientBootstrapper.lua` v2.0 dengan logika *auto-detek* baru yang mencari file `manifest.client.lua`.

4.  **SUB-TUGAS 3-5 (Pengisian Manifest & Debug):** Mengisi file `manifest.client.lua` untuk `PlayerDataController`, `MainHUD`, dan 3 modul *debug*. Mengisi `Main.lua` untuk modul debug aktif.

5.  **SUB-TUGAS 6 (TESTING #1 - GAGAL TOTAL ❌):**
    * **Hasil:** Log menunjukkan `0 manifes valid`, `Rusak 6`.
    * **Analisa:** `ClientBootstrapper` v2.0 **GAGAL TOTAL** menemukan file `manifest.client.lua`.
    * **Biang Kerok:** *Bug* pada skrip `.sh` sebelumnya yang **GAGAL** membuat/mengisi file `manifest.client.lua` dengan benar (kemungkinan karena metode `echo`).

6.  **REVISI SKRIP `.sh` (v1.3):** Skrip `.sh` ditulis ulang menggunakan metode `cat <<'EOF'` yang lebih aman untuk memastikan semua file manifest **BENAR-BENAR TERBUAT DAN TERISI**.

7.  **TESTING #2 (MASIH GAGAL ❌ - *Insight* dari Claude):**
    * **Hasil:** Log *masih* menunjukkan `0 manifes valid`.
    * **Analisa (Dibantu AI Claude):** Ditemukan *bug* krusial: Roblox **TIDAK SUPPORT TITIK (.)** di tengah nama `ModuleScript`. File `manifest.client.lua` akan diimpor oleh Rojo sebagai `ModuleScript` bernama `manifest.client`, bukan `manifest.client.lua`. Akibatnya, `FindFirstChild("manifest.client.lua")` di `ClientBootstrapper` selalu gagal.
    * **Solusi (Dari Claude):** Ganti nama file manifest menjadi `ClientManifest.lua` (tanpa titik di tengah). Update `ClientBootstrapper` untuk mencari `"ClientManifest"`.

8.  **IMPLEMENTASI SOLUSI CLAUDE (Skrip `.sh` v1.4 + `ClientBootstrapper` v2.3):** Skrip `.sh` di-update untuk membuat file `ClientManifest.lua`. File `ClientBootstrapper.lua` di-update menjadi v2.3 untuk mencari `"ClientManifest"`.

9.  **SUB-TUGAS 6 (TESTING #3 - SUKSES! ✅):**
    * **Hasil:** Log menunjukkan **SEMUA MODUL** terdeteksi dengan benar!
        * `Ditemukan 6 folder, 5 manifes valid.` (Folder `Services` di-skip, benar).
        * `✅ AKTIF: 4` (`PDController`, `MainHUD`, `ModProtoA`, `ModProtoB`)
        * `💤 NONAKTIF: 1` (`ModProtoC`)
        * `⚠️ RUSAK: 1` (`ModProtoD` - entry file not found)
    * **Kesimpulan:** Core OS Client v2.3 Enterprise **BERHASIL** diimplementasikan.

10. **Implementasi SOP LOGGING v1.0:** Meng-upgrade `SystemMonitor`, `Bootstrapper` (Server), dan `ClientBootstrapper` untuk menggunakan *prefix log* baru (`[OVHL OS ENTERPRISE vX.X.X]` dan `[OVHL SYS MONITOR v1.0]`). Testing ulang **BERHASIL**.

#### **STATUS AKHIR:**
Operasi Upgrade OS **SELESAI** dengan sukses. `Core OS` (Server & Client) kini 100% *auto-detek*, *zero-touch*, dan siap untuk *copy-paste* ke proyek lain. Log output juga sudah sesuai SOP Logging v1.0. **Proyek siap melanjutkan ke FASE 2 (DealerModule).**

</details>


### [2025-10-22 | 11:21:00] [🧠 STRATEGI] Sesi Diskusi Blueprint v4.0 & Finalisasi "Operasi Ojol Perdana"

**Kolaborator:** Hanif Saifudin (Lead Dev) & Gemini (AI Co-Dev)
**Tujuan Log:** Mencatat proses iterasi dan kesepakatan-kesepakatan kunci dalam perancangan arsitektur gameplay Beta v1.

<details> <summary><strong>Klik untuk membuka rangkuman detail sesi...</strong></summary>

#### **BAGIAN 1: KONTEKS & VISI AWAL**
Setelah berhasil menstabilkan `Core OS` (via `feature/admin-panel-v1`), diskusi beralih dari "perbaikan prototipe" ke "pembangunan gameplay inti". Lead Dev (Hanif) memaparkan 15 poin visi "Real Life Ojol", yang menjadi dasar dari *blueprint* baru.

#### **BAGIAN 2: ITERASI BLUEPRINT & KESEPAKATAN TEKNIS**
Kami melakukan beberapa kali iterasi pada dokumen `OVHL_ROADMAP_FINAL.md (v4.0)` dan menyepakati beberapa "Filosofi Desain" kunci:
1.  **Filosofi #4 (Tag-Driven World):** Disepakati bahwa semua interaksi dunia (Dealer, Kantor, Zona Spawn NPC) **WAJIB** menggunakan `CollectionService:GetTagged()`. Ini memisahkan tugas *Builder* (yang hanya perlu memberi Tag) dari *Scripter*.
2.  **Logika Hibrid (Anti-Gagal):** Untuk fitur NPC naik motor (FASE 5), disepakati logika hibrid:
    -   **Prioritas 1:** Skrip mencari `Seat` bernama `PassengerSeat`.
    -   **Prioritas 2 (Fallback):** Jika `Seat` tidak ada, skrip akan menggunakan `WeldConstraint` (Lem) ke `JokBelakangPart`.
3.  **Ekonomi "Real Life" (Anti-Simpel):**
    -   **`CompanyModule` (FASE 3)** ditetapkan sebagai **"Otak Ekonomi Mikro"**. Modul ini akan mengatur *Config* (`tarif_dasar`, `komisi`, `sanksi`) untuk setiap player.
    -   **`ProgressionModule` (FASE 7)** disetujui sebagai **"Auditor"**. Modul ini akan menjalankan logika "Upgrade Paksa" (memberi sanksi jika player malas *upgrade* motor).
4.  **Auto-Scaling NPC (Anti-Sepi):** `NPCSpawnerModule` (FASE 4) disepakati akan memiliki logika *auto-scaling* yang *menaikkan* `spawn_rate` berdasarkan jumlah `PlayerCount` di server.
5.  **Event Dinamis (Anti-Statis):** Disetujui penambahan `WeatherModule` (FASE 8) untuk "Tarif Hujan" dan `GlobalEconomyModule` (FASE 9) untuk "Event Jam Sibuk / Berkah".

#### **BAGIAN 3: HUKUM WAJIB AI (META-WORKFLOW)**

Selama diskusi, kami juga menetapkan "Hukum Wajib" baru untuk kolaborasi AI Co-Dev di masa depan:
1.  **Aturan `.sh` (Anti-HumanError):** Jika AI perlu menyarankan penambahan fungsi baru ke *Core Service* (seperti `DataService.lua`), AI **wajib** menyediakan skrip `.sh` (menggunakan `sed` atau `awk`) yang bisa *menyuntikkan* kode tersebut secara otomatis, alih-alih meminta dev mengirim file asli.
2.  **Aturan "No Placeholder" (Anti-Bingung):** AI Co-Dev **DILARANG KERAS** menggunakan *placeholder* (seperti `[Immersive content redacted...]`) dalam *output* file, baik itu kode, dokumen, atau log. Semua *output* file harus 100% utuh.
3.  **Aturan "RAW Markdown" (Anti-Format):** Untuk dokumen `.md`, AI Co-Dev harus selalu menyajikan *output* di dalam *nested code block* (\`\`\`markdown) untuk memastikan format teks mentah 100% aman untuk di-copas.

#### **HASIL AKHIR**
Sesi ini menghasilkan dokumen kunci yang telah disetujui (`ACC`) oleh Lead Dev:
1.  `OVHL_OJOL_GAMEPLAY_BETA.md` (Gabungan dokumen di atas)

Proyek kini 100% siap untuk memulai **"OPERASI OJOL PERDANA"**, dimulai dari FASE 0 (Persiapan Git).

</details>

### [2025-10-22 | 09:55:00] [✅ MILESTONE] [🐞 BUGFIX] [CORE] [PROTOTYPE]

**Judul:** Fase 2 Selesai - Admin Panel Prototype (Config) Stabil & Server Crash Dibereskan. **Kolaborator:** Hanif Saifudin (Lead Dev) & Gemini (AI Co-Dev) **Branch:** `feature/admin-panel-v1`

<details> <summary><strong>Klik untuk membuka rangkuman detail...</strong></summary>

#### **BAGIAN 1: DIAGNOSA MASALAH (SERVER CRASH)**

##### **Masalah Awal:**

-   Saat testing Fase 2 (Admin Panel), server gagal booting.
-   Log Output menunjukkan error fatal: `[MODULE_INIT_FAIL] [ERROR] Gagal menjalankan init() pada modul 'AdminPanel' ... attempt to index nil with 'Get'`
-   Error yang sama juga terjadi pada modul `TestOrder`, menandakan ini adalah masalah sistemik pada **Core OS**, bukan cuma di AdminPanel.

##### **Akar Masalah (Root Cause):**

-   **Kesalahan Arsitektur di `ServiceManager.lua` (TAHAP 4)**.
-   `ServiceManager` versi lama salah mengimplementasikan *dependency injection*.
-   Dia mem-passing `self` (instansi `ServiceManager` itu sendiri) ke dalam fungsi `module.handler:init(self)`.
-   Padahal, semua modul (seperti `AdminPanel` dan `TestOrder`) didesain untuk menerima `context table` (sebuah tabel berisi *semua* service, contoh: `context.SystemMonitor`).
-   Akibatnya, `context.SystemMonitor` menjadi `nil` dan server *crash*.

#### **BAGIAN 2: PROSES PERBAIKAN (TAHAP 4 & 5)**

##### **Solusi TAHAP 4: Perbaikan Arsitektur `ServiceManager` (3 File)**

1.  **`Core/Server/Services/ServiceManager.lua` (4.1):**
    -   Fungsi `StartAll()` dirombak total.
    -   Sekarang dia membuat `context` *table* baru.
    -   `context` table ini diisi dengan *semua* service yang terdaftar (misal: `context.DataService = ...`, `context.EventService = ...`).
    -   `context` table inilah yang sekarang di-pass ke `module.handler:init(context)`.
2.  **`Core/Server/Modules/AdminPanel/Handler.lua` (4.2):**
    -   Fungsi `init(context)` diubah untuk membaca `context` table.
    -   Semua pengambilan service (misal: `self.SystemMonitor = context.SystemMonitor`) sekarang berjalan sukses.
3.  **`Core/Server/Modules/TestOrder/Handler.lua` (4.3):**
    -   Diberi perlakuan yang sama dengan `AdminPanel`.
    -   Fungsi `init(context)` diubah untuk membaca `context` table.
    -   **Hasil TAHAP 4:** Server nyala, `[MODULE_INIT_FAIL]` hilang.

##### **Solusi TAHAP 5: Perbaikan Masalah Keamanan (`[UNAUTHORIZED]`)**
-   **Masalah Baru:** Server sukses nyala, tapi Admin Panel ditolak akses (`[UNAUTHORIZED] [WARN] ... mencoba akses ... tanpa izin`).
-   **Akar Masalah:** Fungsi `IsAdmin()` di `AdminPanel/Handler.lua` terlalu ketat untuk testing di Studio.
-   **Solusi (5.1):**
    -   `Core/Server/Modules/AdminPanel/Handler.lua` di-update.
    -   Fungsi `IsAdmin()` ditambahi logika `if game:GetService("RunService"):IsStudio() then return true end`.
    -   Ini memberikan akses admin otomatis *hanya* saat testing di Studio.

#### **BAGIAN 3: HASIL AKHIR & STATUS**

-   **Hasil Test Final:** **NO ERROR.**
-   `AdminPanel` berhasil kebuka.
-   `AdminPanel` berhasil memanggil `AdminGetConfig` dan menampilkan data *live* (1.0 dan 0.8).
-   `AdminPanel` berhasil memanggil `AdminUpdateConfig` (mengubah ke 2.0 dan 0.5).
-   Data berhasil tersimpan di `DataService` (dibuktikan dengan *re-open* panel).
-   Gameplay loop (`TestOrder`) juga berjalan normal bersamaan.

**Catatan Prototype:**
-   Admin Panel ini masih *prototype*. Fungsinya baru sebatas membaca/menulis config `economy_multiplier` dan `ai_population_density` ke `DataService`.
-   Saat ini, **belum ada** ***logic*** **gameplay** (seperti `TestOrder`) yang *menggunakan* nilai-nilai config ini.
-   Implementasi *Hot Reload* (`Reload Module`) juga masih `TODO` (fitur Fase 3).

**Status Proyek:**
-   **Fase 2 (Implement Admin Panel Prototype - Config) SELESAI & STABIL.**
-   Server *crash* teratasi.

</details>

### [2025-10-21 | 21:55:00] [✅ MILESTONE] [GAMEPLAY]

**Judul:** Gameplay Loop Selesai Total - Misi Nyata & Sinkronisasi Real-time.

**Kolaborator:** Hanif Saifudin (Lead Dev) & Gemini (AI Co-Dev)

<details>
<summary><strong>Klik untuk membuka rangkuman detail Fase 8 & 9...</strong></summary>

---

#### **BAGIAN 1: FASE 8 - MISI JADI NYATA (TRIGGER ZONE)**

##### **Branch Fitur:**
`feature/trigger-zone-mission`

##### **Tujuan Utama:**
Mengubah misi dari sekadar UI menjadi sebuah tugas yang memiliki *win condition* (kondisi kemenangan). Pemain kini harus secara fisik pergi ke lokasi tujuan untuk menyelesaikan order.

##### **Alur Kerja Fitur yang Dicapai:**
1.  **Pembuatan Zona:** Setelah pemain menerima order, `TestOrder` (server) memerintahkan `ZoneService` (server) untuk membuat sebuah `Part` silinder hijau semi-transparan ("zona tujuan") di `Workspace`, di lokasi yang telah ditentukan.
2.  **Deteksi Pemain:** `ZoneService` memasang *listener* `.Touched` pada zona tersebut. Ketika ada sesuatu yang menyentuh, ia akan memverifikasi apakah itu adalah karakter dari pemain yang sedang menjalankan misi.
3.  **Penyelesaian Misi:** Jika verifikasi berhasil, `ZoneService` akan memicu *callback* yang memberitahu `TestOrder` bahwa misi telah selesai.
4.  **Pemberian Imbalan:** `TestOrder` kemudian memerintahkan `DataService` untuk menambahkan uang ke data pemain (`AddUang`).
5.  **Feedback ke Client:** `TestOrder` juga mengirim `RemoteEvent` ("MissionCompleted") ke client untuk memberitahu bahwa misi sudah beres, yang kemudian memicu penghapusan UI Misi Aktif.

##### **Tantangan Kritis & Solusinya:**
* **`MASALAH: Bug Kritis di Core OS`**
    * **Kasus:** Terjadi serangkaian error beruntun (`attempt to call missing method`, `Infinite yield possible`) yang disebabkan oleh kesalahan penulisan kode (minifikasi & salah panggil metode) di `StyleService` dan `EventService` saat Fase 8 diimplementasikan.
    * **Solusi:** Melakukan "operasi bedah jantung". Semua file inti yang rusak (`StyleService`, `EventService`, `UIManager`) ditulis ulang dari awal dengan kode yang rapi, jelas, dan anti-gagal, menyelesaikan semua error secara tuntas.

---

#### **BAGIAN 2: FASE 9 - SINKRONISASI DATA REAL-TIME**

##### **Branch Fitur:**
`feature/realtime-data-sync`

##### **Tujuan Utama:**
Membuat game terasa "hidup" dengan memastikan setiap perubahan data di server (khususnya uang) langsung terlihat di HUD pemain tanpa perlu menunggu atau *rejoin*.

##### **Alur Kerja Fitur yang Dicapai:**
1.  **"Jembatan" Update:** Dibuat `RemoteEvent` baru ("UpdatePlayerData") sebagai saluran berita khusus dari server ke client.
2.  **Server Proaktif:** Fungsi `DataService:AddUang` di-upgrade. Setelah berhasil menambah uang pemain di server, ia langsung mengirim event `UpdatePlayerData` ke client yang bersangkutan, berisi data baru (misal: `{Uang = 170000}`).
3.  **Client Responsif:** `PlayerDataController` di client dipasangi "antena" untuk mendengarkan event `UpdatePlayerData`. Ketika menerima update, ia memperbarui *cache* data lokalnya dan menyebarkan sinyal lokal (`OnDataUpdated`).
4.  **UI "Hidup":** Modul `MainHUD` mendengarkan sinyal `OnDataUpdated`. Begitu sinyal diterima, ia langsung memperbarui teks di `MoneyLabel` dengan angka uang terbaru.
5.  **Bonus Feedback:** Sebagai pelengkap, `UIManager` diberi kemampuan baru untuk menampilkan notifikasi sementara ("Toast Notification") yang muncul dari atas layar, yang digunakan untuk menampilkan pesan "Misi Selesai! +Rp 15000".

---

#### **STATUS PROYEK SAAT INI:**
Semua progres dari Fase 1 hingga 9 telah berhasil diimplementasikan, diuji, dan digabungkan ke dalam branch **`develop`**. Proyek kini memiliki satu gameplay loop yang berfungsi penuh dari A-Z dengan feedback visual yang responsif.

</details>

### [2025-10-21 | 20:30:00] [SUMMARY LOG] Pencapaian Awal & Pembangunan Gameplay Loop v1
**Kolaborator:** Hanif Saifudin (Lead Dev) & Gemini (AI Co-Dev)
**Tujuan Log:** Menyediakan rangkuman konteks penuh untuk onboarding cepat bagi pengembang atau AI di sesi pengembangan berikutnya.

<details>
<summary><strong>Klik untuk membuka rangkuman detail...</strong></summary>

---

#### **BAGIAN 1: PEMBANGUNAN FONDASI CORE OS (FASE 1 - 4)**

##### **Branch Fitur:**
`dev/coreos`, `feature/fase-3-ui-sync`

##### **Tujuan Utama:**
Membangun arsitektur dasar game yang modular, scalable, dan anti-gagal menggunakan sistem Core OS yang terintegrasi penuh dengan Rojo.

##### **Komponen Kunci yang Dibangun:**
* **`Core OS Services (Server)`**: `Bootstrapper`, `ServiceManager`, `SystemMonitor`, `EventService`, `DataService`, `StyleService`.
* **`Arsitektur UI (Client)`**: `ClientBootstrapper`, `UIManager` (sebagai "Arsitek UI" terpusat), `PlayerDataController`, dan modul UI modular seperti `MainHUD`.
* **`Git Workflow`**: Mengadopsi alur kerja **Git Flow** (`main` > `develop` > `feature/...`) untuk menjaga stabilitas dan kerapian kode.

##### **Tantangan Kritis & Solusinya (Case Studies):**

1.  **`MASALAH: Rojo Double Boot`**
    * **Kasus:** Konfigurasi `default.project.json` awal yang memetakan seluruh folder menyebabkan Rojo membuat skrip pembungkus, sehingga `Init.server.lua` dieksekusi dua kali.
    * **Solusi:** Mengubah strategi pemetaan menjadi **pemetaan file eksplisit**. Ini memberitahu Rojo untuk menempatkan file persis di tujuannya tanpa membuat instance perantara.

2.  **`MASALAH: Race Condition Data Client`**
    * **Kasus:** Client meminta data pemain segera setelah join, namun server masih dalam proses mengambil data dari DataStore, sehingga client menerima `nil`.
    * **Solusi:** Menerapkan **alur kerja berbasis sinyal**. `DataService` kini mengirim `RemoteEvent` ("PlayerDataReady") ke client *setelah* data berhasil dimuat. Client menunggu sinyal ini sebelum meminta data.

3.  **`MASALAH: Arsitektur UI Tidak Stabil`**
    * **Kasus:** Upaya awal menggunakan fitur Beta `StyleSheet` gagal karena harus diaktifkan manual dan tidak stabil.
    * **Solusi:** Menciptakan **`UIManager`** sebagai "arsitek" terpusat yang bertanggung jawab penuh atas pembuatan dan styling semua elemen UI, sesuai prinsip **"Minta, Jangan Bikin Sendiri"**.

---

#### **BAGIAN 2: IMPLEMENTASI GAMEPLAY LOOP v1 (FASE 5 - 7)**

##### **Branch Fitur:**
`feature/gameplay-loop-v1`

##### **Tujuan Utama:**
Mengimplementasikan alur interaksi pemain pertama yang lengkap dan fungsional, dari menerima notifikasi hingga menjalankan misi.

##### **Alur Kerja Fitur yang Dicapai:**
1.  **Fase 5 (Notifikasi):** Server mengirimkan notifikasi order baru ke client.
2.  **Fase 6 (Respon):** Client menampilkan UI interaktif (`TERIMA`/`TOLAK`) dan mengirimkan respon pemain kembali ke server.
3.  **Fase 7 (Aksi):** Server menerima respon "TERIMA" dan mengirim perintah balik ke client untuk menampilkan UI Misi Aktif.

---

#### **BAGIAN 3: STRUKTUR FINAL PROYEK (Setelah Gameplay Loop v1)**

##### **Struktur Folder `Source/`:**
```bash
Source/
├── Client
│   └── Init.client.lua
├── Core
│   ├── Client
│   │   ├── ClientBootstrapper.lua
│   │   ├── Controllers
│   │   │   ├── OrderController.lua
│   │   │   └── PlayerDataController.lua
│   │   ├── Services
│   │   │   └── UIManager.lua
│   │   └── UI
│   │       └── MainHUD.lua
│   ├── Server
│   │   ├── Kernel
│   │   │   └── Bootstrapper.lua
│   │   ├── Modules
│   │   │   └── TestOrder
│   │   │       ├── Handler.lua
│   │   │       └── manifest.lua
│   │   └── Services
│   │       ├── DataService.lua
│   │       ├── EventService.lua
│   │       ├── ServiceManager.lua
│   │       ├── StyleService.lua
│   │       └── SystemMonitor.lua
│   └── Shared
│       ├── Config.lua
│       └── Utils
│           └── Signal.lua
├── Replicated
│   └── .gitkeep
└── Server
    └── Init.server.lua
```

---

#### **STATUS PROYEK SAAT INI:**
Semua progres dari Fase 1 hingga 7 telah berhasil diimplementasikan, diuji, dan digabungkan ke dalam branch **`develop`**. Proyek kini memiliki fondasi Core OS yang stabil dan satu gameplay loop yang berfungsi penuh. Proyek siap untuk pengembangan fitur berikutnya.

</details>

### [2025-10-21 | 20:25:00] [✅ MILESTONE] [GAMEPLAY]

<details>
<summary>
Gameplay Loop v1 Selesai - Alur Notifikasi, Respon, dan Misi Aktif.
</summary>

**Deskripsi:**
Pencapaian besar! Gameplay loop pertama dari game Ojol Roleplay berhasil diimplementasikan secara penuh dari awal hingga akhir. Fitur ini mencakup seluruh alur interaksi pemain, mulai dari menerima notifikasi order hingga menjalankan misi, yang dikoordinasikan sepenuhnya oleh Core OS.

**Alur Kerja Fitur yang Dicapai:**
1.  **Fase 5 (Notifikasi):** Server, melalui modul `TestOrder`, berhasil mensimulasikan dan mengirimkan notifikasi order baru ke client secara real-time menggunakan `EventService`.
2.  **Fase 6 (Respon):** Client, melalui `OrderController`, berhasil menampilkan UI interaktif (`TERIMA`/`TOLAK`) yang dibuat oleh `UIManager` dan mengirimkan respon pemain kembali ke server.
3.  **Fase 7 (Aksi):** Server berhasil menerima respon pemain. Jika order diterima, server langsung mengirim perintah balik ke client untuk menampilkan UI Misi Aktif, menggantikan notifikasi order sebelumnya.

**Komponen Utama yang Terlibat:**
* **Server:** `TestOrder/Handler.lua`, `EventService.lua`
* **Client:** `OrderController.lua`, `UIManager.lua`
* **Komunikasi:** `RemoteEvent` ("NewOrderNotification", "RespondToOrder", "UpdateMissionUI")

**Status Akhir & Kesiapan:**
Fitur gameplay loop v1 kini telah stabil dan berfungsi penuh tanpa error. Branch `feature/gameplay-loop-v1` siap untuk digabungkan (`merge`) ke dalam branch `develop`.
</details>

### [2025-10-21 | 19:50:00] [✅ MILESTONE] [UI]
<details>
<summary>
Fase 4 Selesai - Arsitektur UI Terpusat dengan `UIManager`.
</summary>

**Deskripsi:**
Fase 4 berhasil mengimplementasikan arsitektur UI client yang terpusat dan scalable. Semua pembuatan dan styling UI kini dikendalikan oleh satu service utama, `UIManager`, sesuai dengan visi jangka panjang Core OS. Modul-modul UI kini bersifat "declarative", hanya memberi perintah tanpa mengurus detail implementasi.

---

**Struktur File & Folder Utama (Setelah Fase 4):**

```bash
Source/
├── Core/
│   ├── Client/
│   │   ├── ClientBootstrapper.lua  # (Baru) Entry point client yang terstruktur
│   │   ├── Controllers/
│   │   │   └── PlayerDataController.lua # (Dirombak)
│   │   ├── Services/
│   │   │   └── UIManager.lua         # (Baru) Si "Arsitek UI"
│   │   └── UI/
│   │       └── MainHUD.lua           # (Dirombak)
│   ├── Server/
│   │   ├── Kernel/
│   │   ├── Modules/
│   │   └── Services/
│   └── Shared/
│       └── Utils/
│           └── Signal.lua          # (Baru) Utilitas event client-side
├── Client/
│   └── Init.client.lua             # (Dirombak)
└── Server/
    └── Init.server.lua
```

---

**Analisis Masalah & Solusi (Case Studies):**

* **Kasus 1: Race Condition Data Client**
    * **Problem:** `PlayerDataController` di client meminta data ke server *sebelum* `DataService` di server selesai memuat data dari DataStore, menyebabkan client menerima `nil`.
    * **Solusi:** Diterapkan alur kerja berbasis sinyal. `DataService` kini mengirim `RemoteEvent` ("PlayerDataReady") ke client setelah data berhasil dimuat ke cache. `PlayerDataController` diubah untuk menunggu sinyal ini terlebih dahulu sebelum mengirim `RemoteFunction` untuk meminta data.

* **Kasus 2: Error Fitur Beta (`UIStyle`)**
    * **Problem:** Penggunaan `Instance.new("UIStyle")` menyebabkan error `Unable to create an Instance` karena fitur ini masih bersifat Beta dan harus diaktifkan manual di Studio.
    * **Solusi:** Untuk menjaga stabilitas dan menghindari ketergantungan pada fitur Beta, `UIManager` dirombak. Alih-alih menggunakan `StyleSheet`, `UIManager` kini menerapkan properti style (seperti `BackgroundColor3`, `Font`, `TextColor3`) secara langsung ke setiap elemen UI yang dibuatnya. Prinsip sentralisasi tetap terjaga, hanya metode eksekusinya yang diubah ke cara yang lebih stabil.

* **Kasus 3: Path `require()` Salah**
    * **Problem:** `PlayerDataController` gagal memuat modul `Signal` karena path `require`-nya salah, menyebabkan seluruh alur client berhenti.
    * **Solusi:** Path diperbaiki dari `script.Parent.Parent.Shared...` menjadi `Core.Shared.Utils.Signal` yang lebih absolut dan anti-gagal terhadap perubahan struktur folder.

---

**Status Akhir & Kesiapan:**
Dengan selesainya Fase 4, Core OS kini memiliki arsitektur UI yang solid, modular, dan siap untuk dikembangkan dengan fitur-fitur gameplay yang lebih kompleks. Semua masalah teknis yang ditemukan telah diatasi. **Proyek siap untuk melanjutkan ke Fase 5.**
</details>

---

### [2025-10-21 | 19:15:00] [🧱 INFRASTRUCTURE] [FIX]

<details>
<summary>
Stabilisasi Fondasi Core OS v1.0 dan Resolusi Masalah Sinkronisasi Rojo.
</summary>
**Deskripsi:**
Fondasi awal untuk Core OS berhasil dibangun dan diotomatisasi menggunakan skrip `Tools/deploy_all.sh`. Proses ini membangun struktur folder, membuat semua file service dan modul dasar, serta mengonfigurasi `default.project.json` untuk Rojo.

**Struktur & Fungsi Utama yang Dibangun:**

* **`Source/Core/`**: Berisi semua logika inti yang modular, termasuk `Kernel` (Bootstrapper), `Server/Services` (ServiceManager, DataService, dll), `Client`, dan `Shared`. Ini adalah jantung dari sistem.

* **`Source/Server/Init.server.lua`**: Titik masuk tunggal untuk logika server.

* **`Source/Client/Init.client.lua`**: Titik masuk tunggal untuk logika client.

* **`default.project.json`**: File manifest yang memberitahu Rojo cara memetakan struktur folder `Source/` ke dalam struktur DataModel di Roblox Studio.

---

**Analisis Masalah (Case Study): Eksekusi Ganda (Double Boot)**

* **Masalah yang Terjadi:**
    Saat `rojo serve` dijalankan, skrip `Init.server.lua` dan `Init.client.lua` dieksekusi sebanyak dua kali. Log output menunjukkan seluruh proses booting server berjalan ganda, yang menyebabkan pemborosan resource dan potensi bug state management di masa depan.

* **Akar Masalah:**
    Masalah ini berasal dari konfigurasi `default.project.json` yang ambigu. Konfigurasi awal memetakan seluruh folder `Source/Server` ke `ServerScriptService`. Rojo, secara default, membungkus konten folder ini menjadi satu `Script` baru dengan nama yang sama dengan folder sumbernya (`Server`). Hasilnya, di dalam `ServerScriptService` terbentuk struktur `Server > Init.server.lua`. Roblox kemudian mengeksekusi `Server` (yang otomatis menjalankan `Init.server.lua` di dalamnya) dan juga `Init.server.lua` itu sendiri, menyebabkan eksekusi ganda. Masalah serupa terjadi pada client.

* **Solusi yang Diterapkan:**
    Konfigurasi `default.project.json` diubah dari pemetaan folder yang luas menjadi pemetaan file yang **eksplisit dan spesifik**.

    *Mapping Lama (Penyebab Masalah):*
    ```json
    "ServerScriptService": {
      "$path": "Source/Server"
    }
    ```

    *Mapping Baru (Solusi Final):*
    ```json
    "ServerScriptService": {
      "Init": {
        "$path": "Source/Server/Init.server.lua"
      }
    }
    ```
    Dengan pemetaan baru ini, kita secara tegas memberitahu Rojo: "Ambil file `Init.server.lua` dan letakkan langsung di dalam `ServerScriptService` dengan nama `Init`." Ini menghilangkan ambiguitas dan mencegah Rojo membuat folder pembungkus yang tidak perlu.

---

**Panduan untuk Pengembang & AI di Masa Depan:**

> **Prinsip Utama:** Saat berhadapan dengan masalah eksekusi ganda atau path yang salah di Rojo, selalu curigai `default.project.json` terlebih dahulu.
>
> **Tindakan Pencegahan:** Untuk skrip *entry point* (seperti `Init`), **hindari pemetaan level folder (`$path` ke sebuah direktori)**. Selalu gunakan **pemetaan level file (`$path` langsung ke file .lua)** untuk memastikan skrip ditempatkan persis di lokasi yang diinginkan tanpa ada instance perantara yang dibuat oleh Rojo. Ini adalah praktik terbaik untuk menjaga struktur proyek tetap bersih dan prediktif.

**Status Saat Ini:**
Sistem sekarang boot dengan bersih, stabil, dan log output tunggal. **Milestone Phase 1 (Infrastruktur Inti) tercapai.**

</details>

---