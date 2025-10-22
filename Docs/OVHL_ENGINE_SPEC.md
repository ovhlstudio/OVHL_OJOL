# ⚙️ OVHL ENGINE SPEC – Dokumen Teknis Resmi Core OS

> **Project:** Omniverse Highland – Ojol Roleplay  
> **Engine:** OVHL Core OS  
> **Versi:** v2.3 Enterprise (Client Auto-Detek)  
> **Status:** STABIL  
> **Author:** Hanif Saifudin (Lead Dev) + AI Co-Dev System  
> **Last Update:** 2025-10-22 - 14:54:55

---

## 🧠 TUJUAN DOKUMEN

Dokumen ini berfungsi sebagai **kitab teknis utama** dari sistem **OVHL Core OS**.  
Semua AI dan developer wajib membaca dan memahami file ini **sebelum membuat modul baru atau melakukan integrasi.**

---

## 🔩 DESKRIPSI UMUM ENGINE

`OVHL Core OS` adalah **mesin modular generasi kedua** yang dirancang untuk game “Ojol Roleplay” di Roblox.  
Tujuan utamanya adalah menjadikan sistem **stabil, auto-detek, dan zero-touch**, di mana modul baru bisa ditambahkan tanpa perlu menyentuh kode inti.

### 🎯 Tujuan Arsitektur
- ♻️ **Reusable Engine:** Bisa dicopy ke proyek lain tanpa konflik.  
- 🧩 **Modular:** Setiap fitur berdiri sendiri (Dealer, NPC, Perusahaan).  
- 🧱 **Data-Driven:** Semua angka dan logika dikontrol dari konfigurasi, bukan hardcode.  
- ⚡ **Auto-Discovery:** Engine otomatis mendeteksi semua modul client/server.  
- 🔒 **Zero-Touch Core:** Developer dilarang ubah file inti OS. Semua logika ada di `Modules/`.  
- 🤖 **AI-Ready:** Format dokumentasi dan log bisa dibaca & dilanjutkan AI lain tanpa kebingungan.

---

## 🏗️ STRUKTUR FOLDER STANDAR
```
Source/
├── Core/
│ ├── Kernel/ # Loader utama
│ ├── Server/
│ │ ├── Services/ # Layanan global server (Data, Event, Zone, dll)
│ │ └── Modules/ # Modul gameplay server
│ ├── Client/
│ │ ├── Services/ # UIManager & service client lainnya
│ │ └── Modules/ # Modul client (UI, HUD, Controller)
│ └── Shared/
│ ├── Config.lua # Konfigurasi statis
│ └── Utils/ # Fungsi umum (Signal, Math, dsb.)
├── Client/
│ └── Init.client.lua # Entry bootstrap client
└── Server/
└── Init.server.lua # Entry bootstrap server
```
## 🏗️ ROJO CONFIG
```json
{
  "name": "OVHL_OJOL",
  "tree": {
    "$className": "DataModel",

    "ReplicatedStorage": {
      "Core": {
        "$path": "Source/Core"
      },
      "Replicated": {
        "$path": "Source/Replicated"
      }
    },

    "ServerScriptService": {
      "Init": {
        "$path": "Source/Server/Init.server.lua"
      }
    },

    "StarterPlayer": {
      "StarterPlayerScripts": {
        "Init": {
          "$path": "Source/Client/Init.client.lua"
        }
      }
    }
  }
}

```

---

## 🧩 KOMPONEN UTAMA OVHL CORE

| Service / Komponen | Peran | Deskripsi |
|--------------------|-------|------------|
| **Bootstrapper** | Loader Utama | Melakukan inisialisasi seluruh service & modul server. |
| **ServiceManager** | Registry | Menyimpan, mengatur, dan menyebarkan dependency antar service. |
| **EventService** | Jembatan | Menyediakan komunikasi Client ↔ Server secara aman. |
| **DataService** | Brankas Data | Menyimpan data player & konfigurasi global. |
| **SystemMonitor** | Health Tracker | Melacak performa, error, dan log SOP OS. |
| **StyleService** | UI Skinner | Menyediakan tema & style token untuk UI. |
| **ZoneService** | Satpam Dunia | Deteksi zona berbasis Tag (DealerZone, CompanyZone, dll). |
| **ClientBootstrapper** | Loader Client | Auto-discovery modul client (v2.3 Enterprise). |

---

## ⚙️ ARSITEKTUR BOOTSTRAP

### 🧱 Server Bootstrapper
1. Melakukan *scan* semua folder di `Server/Modules/`.  
2. Mendeteksi `manifest.lua` di setiap modul.  
3. Meregistrasi modul ke `ServiceManager`.  
4. `ServiceManager:StartAll()` akan memanggil `handler:init(context)` untuk setiap modul valid.  
5. Context berisi seluruh service global (DataService, EventService, dsb).

### 📘 Contoh manifest server:
```lua
return {
  name = "DealerModule",
  depends = {"DataService", "ZoneService"},
  entry = "Handler"
}
```
---

### 📘 Contoh Handler Server :
```lua
local DealerModule = {}
function DealerModule:init(context)
  local DataService = context.DataService
  print("[DealerModule] Init jalan. Akses DataService:", DataService)
end
return DealerModule
```

---

### 💻 Client Bootstrapper v2.3

1.  Melakukan *scan* semua folder di `Client/Modules/`.
2.  Mendeteksi `ClientManifest.lua` di setiap modul.
3.  Menyortir modul berdasarkan `loadOrder`.
4.  Menjalankan modul dengan `autoInit = true`.
5.  Memberikan akses ke `DI_Container` (Dependency Injection).

### 📘 Contoh manifest client:
``` lua
return {
  name = "MainHUD",
  autoInit = true,
  loadOrder = 10,
  entry = "Main"
}

```

### 📘 Contoh modul client:
```lua
local MainHUD = {}
functionMainHUD:Init(DI)local UIManager = DI.UIManager
  print("[MainHUD] Aktif. UIManager siap:", UIManager)
endreturn MainHUD
```

---

### 🔗 SISTEM KOMUNIKASI MODUL
--------------------------

### 🧩 Server-Side
-   Komunikasi antar modul dilakukan melalui `context` dari `ServiceManager`.
-   Modul bisa mengakses service lain:
    ```lua
    local DataService = context.DataService
    local EventService = context.EventService
    ```

### 💻 Client-Side
-   Menggunakan `DI_Container` bawaan `ClientBootstrapper`.
-   Setiap modul aktif bisa akses modul lain melalui `DI`.
📘 Contoh:

```lua
functionHUD:Init(DI)local PlayerDataController = DI.PlayerDataController
  PlayerDataController.OnDataUpdated:Connect(function(data)print("Uang player berubah:", data.Uang)
  end)
end`
```

---

### 🚨 PRINSIP ZERO-TOUCH CORE
--------------------------
Semua kode di `Core/` adalah **"sistem tertutup"** (read-only).
Modul baru **hanya boleh ditambahkan di folder `Modules/`**.

Aturan Wajib:
-   ❌ Dilarang ubah isi `Core/Kernel`, `Core/Server/Services`, atau `Core/Client/Services`.
-   ✅ Gunakan `manifest.lua` / `ClientManifest.lua` untuk registrasi modul.
-   ✅ Semua event, data, dan komunikasi harus melalui service resmi (`EventService`, `DataService`).
-   ✅ Semua error dan hasil uji dicatat di `OVHL_OJOL_LOGS.md`.

---

### 📡 SISTEM LOGGING (SOP v1.0)
----------------------------

Setiap event penting di Core OS memiliki prefix log:
```text
[OVHL OS ENTERPRISE v2.3]
[OVHL SYS MONITOR v1.0]
```

Contoh log:
```text
[OVHLOSENTERPRISEv2.3] [ClientBootstrapper] 
Ditemukan 6folder, 5 manifesvalid. 
✅Aktif: 4 | 💤 Nonaktif: 1 | ⚠️Rusak:1
```

---

### 🧠 FILOSOFI TEKNIS
------------------
| Prinsip | Deskripsi |
| --- |  --- |
| **Modular by Design** | Setiap fitur terpisah sepenuhnya dari Core. |
| --- |  --- |
| **Data-Driven** | Semua nilai berasal dari `DataService` atau `Config`. |
| **Tag-Driven World** | Dunia diatur lewat Tag (`DealerZone`, `SpawnZone`, dll). |
| **AI-Assisted** | Struktur dibuat agar AI bisa membaca & meneruskan development. |
| **Self-Healing** | Error tidak boleh membuat server crash -- SystemMonitor menangani. |
| **Auto-Discovery** | Engine mencari modul sendiri tanpa manual require. |

---

### 🧩 TEMPLATE PEMBUATAN MODUL BARU
--------------------------------

### 📁 Struktur Folder
```
Source/Core/Server/Modules/NamaModul/├─ manifest.lua
  ├─Handler.lua
```
```
Source/Core/Client/Modules/NamaModul/├─ClientManifest.lua
  ├─Main.lua
```

### 🔧 Template Cepat (Server)

```lua
-- manifest.lua
return {
  name = "NamaModul",
  depends = {"DataService"},
  entry = "Handler"
}

-- Handler.lua
local M = {}
function M:init(context)
  local DataService = context.DataService
  print("[NamaModul] aktif. Akses DataService:", DataService)
end
return M
```

### 🖥️ Template Cepat (Client)

```lua
-- ClientManifest.lua
return {
  name = "NamaModulClient",
  autoInit = true,
  loadOrder = 10,
  entry = "Main"
}

-- Main.lua
local M = {}
function M:Init(DI)
  print("[NamaModulClient] aktif. Akses ke:", DI)
end
return M
```

---

🔒 PENUTUP
----------

`OVHL Core OS v2.3 Enterprise` adalah pondasi untuk seluruh game di ekosistem **Omniverse Highland**.
Dengan sistem auto-discovery dan dependency injection, engine ini siap digunakan ulang tanpa modifikasi manual.

> 💬 "Zero Touch. Infinite Expansion." -- Hanif Saifudin, 2025
