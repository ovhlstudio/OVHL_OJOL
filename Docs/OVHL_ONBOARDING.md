# 🧱 OVHL_OJOL PROJECT — AI ONBOARDING BRIEF

Halo! 👋  
Aku sedang mengembangkan game **OVHL_OJOL**, yaitu sistem roleplay "ojol" (ojek online) di Roblox.  
Tujuan utamaku adalah membuat **Core OS / Bootstrap Modular System** yang bisa:
1. Load semua fitur dan service secara dinamis (modular, bukan hardcoded).  
2. Punya admin panel (server–client UI) untuk mengatur gameplay & konfigurasi real-time.  
3. Mendukung **hot reload**, jadi perubahan konfigurasi langsung aktif tanpa restart server.
4. Semua fitur termasuk core dan aplikasi selanjutnya yang akan di develop memiliki Root folder nya sendiri tanpa tercampur ke folder lain. dan bakalan bisa di atur semuanya di dalam ui admin panel.
6. Pastikan semuanya ada domain masing-masing. adaptasi konspe MVC dan css seperti di website. pake UI Style Beta roblox yang baru rilis.
7. Semua Pcall, Echo dll harap menggunakan bahasa indonesia agar mudah dipahami developer.
8. Wajib membuat file .gitkeep pada folder yang masih kosong.
9. AI wajib pro aktif untuk memikirkan skalabilitas game untuk bisa di kembangkan 10 tahun kedepan dan siap menghadapi apapun yang akan terjadi di dunia tech and constructure.

---

## 🎯 TUJUAN UTAMA
Sekarang aku ingin kamu bantu **membangun ulang pondasi Bootstrap (Core OS)**  
dalam **1 file `.sh` lengkap** — yang bisa dijalankan di terminal (Git Bash / VS Code)  
untuk otomatis membuat semua struktur folder dan file yang diperlukan.

Aku ingin hasil akhir cukup dengan:
```bash
bash Tools/deploy_all.sh
```
➡️ langsung menghasilkan seluruh struktur `Source/`, `Core/`, `Services/`, `Client/`, `Server/`, `Replicated/`,  
beserta semua file `.lua` dengan isi kode lengkap (bukan kosong).

---

## 📦 KONDISI SEKARANG
Folder proyek saat ini bersih dan minimal:
```
OVHL_OJOL/
├── Docs/
│   ├── OVHL_OJOL_DEVELOPMENT.md
│   └── OVHL_OJOL_LOGS.md
├── Source/        ← kosong
├── Tools/         ← kosong
└── (default.project.json sudah dihapus)
```

Jadi semua konfigurasi dan struktur kerja akan **dibentuk ulang sepenuhnya oleh file .sh baru**.

---

## ⚙️ TARGET OUTPUT
Aku ingin 1 file:  
```
Tools/deploy_all.sh
```
yang akan:
- Membuat semua folder `Source/Core/...` hingga `Replicated` dan `Client`.
- Mengisi setiap file `.lua` dengan script lengkap (Bootstrapper, ConfigService, ServiceManager, dsb).
- Membuat file `default.project.json` untuk sinkronisasi Rojo (tidak duplikat mapping!).
- Auto-open file utama di VS Code setelah selesai.
- Tidak ada error atau duplikasi saat dijalankan di Roblox Studio (`Play → Start Server` harus 1x boot log).

---

## 🧩 PETUNJUK UNTUK KAMU (AI)
1. Gunakan dua dokumen yang kuunggah di folder `Docs/` sebagai referensi gaya penulisan dan arsitektur sistem.  
2. Buat file `.sh` yang bisa dijalankan langsung tanpa perlu edit manual.  
3. Pastikan hasil akhir bisa disinkronkan dengan **Rojo** dan langsung berfungsi di Roblox Studio tanpa error atau duplikat eksekusi.
4. Output yang kuharapkan: **Markdown codeblock dengan nested 4 backtick**, agar mudah di-copy.

---

## 🧠 BONUS TUJUAN
Kalau bisa, susun struktur dan nama service-nya secara profesional seperti developer besar (mirip modular OS):
- Core
- Kernel
- Config
- Services
- Client
- Server
- Replicated
- Shared Utils

---

Setelah itu, aku akan langsung menjalankan file `.sh` di terminal dan melaporkan hasil build ke kamu untuk debugging lanjutannya.

Terima kasih 🙌🔥
