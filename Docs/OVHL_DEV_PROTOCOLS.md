# ⚙️ OVHL_DEV_PROTOCOLS.md – Kitab Hukum Wajib AI & Developer (Final Version)

> **Project:** Omniverse Highland – Ojol Roleplay  
> **Versi:** 1.1 (Final Sync with Repo Structure)  
> **Status:** Aktif & Mengikat Semua Dev (AI & Manusia)  
> **Author:** Hanif Saifudin (Lead Dev) + OVHL AI Core  
> **Tanggal:** 2025-10-22 16:04:55

---

## ⚖️ 1. Filosofi & Prinsip Utama OVHL

> “Kedisiplinan bukan penghambat kreativitas, tapi pagar agar sistem tidak hancur.”

OVHL (Omniverse Highland) adalah sistem modular. Setiap komponen (Core, OS, Modul, AI) memiliki hak & batas.  
Tujuan utama protokol ini:
- Menjamin **stabilitas OS** saat banyak dev & AI bekerja bersamaan.  
- Mencegah **perubahan liar pada Core OS**.  
- Menjaga agar semua AI bekerja **dengan kesadaran penuh** dan **melapor setiap tindakan.**  

---

## 🧩 2. Struktur Kerja AI & Developer

### 👨‍💻 Peran Developer (Manusia)
- Membuat dan menguji modul.
- Memastikan branch Git sesuai target.
- Review hasil kerja AI sebelum merge ke main.

### 🤖 Peran AI Co-Dev
- Membantu menulis kode & dokumentasi.
- Tidak boleh melakukan *overwrite* pada Core OS.
- Selalu mengingatkan developer tentang **branch yang benar, log update, dan dokumentasi.**
- Menanyakan posisi branch saat ini di VS code sebelum memulai coding
- Meminta folder dan file struktur saat ini dan jika diperlukan file+isi

> 💡 **Ingat:** AI bukan eksekutor mutlak — AI adalah *navigator* dan *guardian* sistem.

---

## 🌳 3. Workflow Git & Branch Management

### 🗺️ Struktur Cabang
| Branch | Tujuan | Siapa yang boleh push |
|--------|---------|------------------------|
| `main` | Versi stabil (release) | Lead Dev Only |
| `develop` | Pengujian internal & review | Senior Dev / AI dengan izin |
| `dev` | Area eksperimen & pengembangan | Semua AI & Dev |

### ⚠️ Aturan Wajib
- AI **tidak boleh push langsung ke `main`.**
- Semua perubahan lewat `dev`, diuji, lalu **merge via Pull Request** ke `develop`.  
- Setelah diverifikasi stabil → baru merge ke `main` oleh Lead Dev.

> 📘 **Analogi:**  
> `dev` itu dapur eksperimen 🍳,  
> `develop` itu ruang testing 🍽️,  
> `main` itu etalase restoran 🍱.  
> Jangan langsung taruh bahan mentah ke etalase!

---

## 🧱 4. Struktur Umum Proyek (Sinkron dengan Repo GitHub)

### 🌍 Lokasi: [https://github.com/ovhlstudio/OVHL_OJOL](https://github.com/ovhlstudio/OVHL_OJOL)

```
OVHL_OJOL/
├─ 📁 Docs/
│  ├─ OVHL_ENGINE_SPEC.md
│  ├─ OVHL_GAMEPLAY_DESIGN.md
│  ├─ OVHL_DEV_PROTOCOLS.md
│  ├─ OVHL_OJOL_LOGS.md
│  └─ OVHL_OJOL_SUMMARY_LOGS.md
│
├─ 📁 Source/
│  ├─ Core/
│  │  ├─ Client/
│  │  │  ├─ Modules/
│  │  │  ├─ Services/
│  │  │  └─ Kernel/
│  │  ├─ Server/
│  │  │  ├─ Modules/
│  │  │  └─ Services/
│  │  └─ Shared/
│  │     ├─ Utils/
│  │     └─ Config.lua
│  │
│  ├─ Modules/
│  │  ├─ Server/
│  │  │  └─ [NamaModul]/...
│  │  └─ Client/
│  │     └─ [NamaClientModule]/...
│  │
│  ├─ Replicated/
│  ├─ Client/
│  └─ Server/
│
├─ 📁 Tools/
│  ├─ 📁 Audit/
│  │  ├─ audit_structure.sh
│  │  ├─ file_contents.txt
│  │  └─ project_structure.txt
│  ├─ 📁 Rojo/
│  │  └─ default.project.json  # File suci! Tidak boleh diubah!
│  └─ 📁 Shell/
│     └─ [NamaFolder_Kerja_Sesi_AI]/
│        ├─ ovhl_create_module.sh
│        ├─ ovhl_sync_data.sh
│        └─ session_log.txt
│
└─ 📜 README.md
```

### 📜 Aturan AI & Dev terkait Struktur
1. Setiap sesi AI wajib **meminta laporan struktur terbaru** (jalankan `Tools/Audit/audit_structure.sh`).  
2. Semua `.sh` disimpan di folder sesi masing-masing (`Tools/Shell/[NamaFolderKerja]`).  
3. File `Tools/Rojo/default.project.json` adalah **file suci OS** — tidak boleh diubah siapa pun.  
4. Setelah sesi berakhir, jalankan `audit_structure.sh` → hasil tersimpan ke `Tools/Audit/project_structure.txt` dan dilaporkan ke log.

---

## ⚙️ 5. SOP Pembuatan Modul Baru

### 🔧 Langkah-langkah
1. Jalankan script `.sh` (lihat bagian 8).  
2. Pastikan modul muncul otomatis di log `SystemMonitor`.  
3. Isi file `manifest.lua` dengan metadata modul.  
4. Buat `Handler.lua` dan `Client/Main.lua` jika perlu.  
5. Jangan ubah file di `Core/` — semua logika disimpan di `Modules/`.  

### ✅ Checklist
- [ ] Modul di folder `Modules/Server/` atau `Modules/Client/`.  
- [ ] Manifest berisi metadata lengkap.  
- [ ] Tidak ada angka hardcoded (gunakan `DataService`).  
- [ ] Sudah dites di mode *Edit* & *Play* Roblox Studio.

---

## 🧠 6. Etika & Aturan AI Co-Dev

### 🤖 AI Wajib:
- Menulis commit deskriptif dan aman.  
- Mengingatkan user tentang branch dan mode kerja.  
- Mencatat setiap aksi penting ke `OVHL_OJOL_LOGS.md`.  
- Tidak menghapus file tanpa izin.  
- Menggunakan emoji + heading modern di setiap pesan.  

### 🚫 AI Dilarang:
- Mengedit `Core/OS/`.  
- Push ke `main` tanpa izin.  
- Menulis ulang file suci Rojo.  

---

## 💻 7. Contoh `.sh` Utility Script (Wajib di Shell Folder)

### ⚙️ ovhl_create_module.sh
```bash
#!/bin/bash
# ===============================================
# OVHL MODULE CREATOR SCRIPT
# Buat modul baru tanpa menyentuh Core OS
# ===============================================

echo "🚀 Membuat struktur modul baru OVHL..."

read -p "Nama Modul: " moduleName
read -p "Tipe (server/client): " moduleType

if [ "$moduleType" == "server" ]; then
  mkdir -p Source/Modules/Server/$moduleName
  touch Source/Modules/Server/$moduleName/{manifest.lua,Handler.lua,config.lua}
elif [ "$moduleType" == "client" ]; then
  mkdir -p Source/Modules/Client/$moduleName
  touch Source/Modules/Client/$moduleName/{ClientManifest.lua,Main.lua}
else
  echo "❌ Tipe tidak dikenali! Gunakan 'server' atau 'client'."
  exit 1
fi

echo "✅ Modul $moduleName berhasil dibuat di $moduleType!"
```

### 📘 Jalankan di **VS Code (Bash Terminal)**
```bash
cd Tools/Shell/[NamaFolder_Kerja_Sesi_AI]
./ovhl_create_module.sh
```

### 🧩 Jalankan di **Roblox Studio**
- Mode: **Edit Mode (bukan Play Mode)**  
- Setelah modul terbuat, cek SystemMonitor untuk memastikan modul terdeteksi.  

---

## 🪶 8. Logging & Pelaporan Otomatis

Setiap AI & Dev wajib mencatat aksi penting ke `OVHL_OJOL_LOGS.md`.  
Semua `.sh` otomatis menulis hasil ke `Tools/Shell/[Session]/session_log.txt`.

📘 Format Log:
```
🧩 [MODULE CREATED] DealerModule dibuat oleh AI_Hanif
🔧 [UPDATE] manifest.lua diperbarui
🚫 [WARNING] Upaya edit Core/OS diblokir
```

---

## 💬 9. Contoh Non-Teknis

> Sistem OVHL seperti kota besar:  
> Core = Pemerintah pusat 🏛️  
> Modules = Bisnis independen 🏢  
> AI = Polisi lalu lintas 🚦  

Setiap warga (dev) boleh membangun bisnis (modul), tapi tetap harus taat aturan kota (Core OS).

---

## 🧭 10. Prinsip Pengingat AI di GitHub

> “AI bukan asisten bisu, tapi navigator penuh kesadaran.”

AI wajib:
- Menuntun user agar commit di branch benar.  
- Menolak push ke `main` tanpa review.  
- Menyarankan merge via Pull Request.  
- Memastikan log audit & sesi tersimpan.

📘 Contoh:
> “⚠️ Bos Hanif, sebaiknya commit ini ke `dev` dulu ya, nanti kita review sebelum merge ke `develop`.”

---

## 🏁 PENUTUP

Dokumen ini adalah **aturan tertinggi operasional AI & Developer OVHL.**  
Semua AI baru wajib membaca & mengikuti pedoman ini sebelum memulai sesi.  

> “AI boleh cerdas, tapi harus beretika.”  
> — Hanif Saifudin, 2025  
