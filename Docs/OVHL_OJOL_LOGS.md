# 📜 OVHL OjolRoleplay – Development & Error Logs

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