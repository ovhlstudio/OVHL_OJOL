# 🧠 OVHL Core OS — Design Spec v1

> **Tujuan:** Menyediakan fondasi Core OS (Bootstrapper + ServiceManager + EventService + DataService + SystemMonitor + StyleService) yang modular, data-driven, dan siap hot-reload.  
> **Catatan:** Semua contoh API ditulis dalam Lua-ish pseudo-code supaya langsung bisa diadaptasi ke Roblox (Luau).

---

## 1 — Ringkasan Arsitektur
- **Bootstrapper** — entry point, discovery & ordered init services & modules.  
- **ServiceManager** — registry, dependency injection, lifecycle manager (start/stop/reload).  
- **EventService** — wrapper aman untuk RemoteEvents/RemoteFunctions (client↔server).  
- **DataService** — storage layer with autosave, retry, local cache.  
- **SystemMonitor** — health, metrics, error collector, heartbeat.  
- **StyleService** — UI theme & tokens provider.  
- **AdminPanel (module)** — runtime config editor, hot-reload trigger, permissions.  
- **Config Layer** — config manifest read by Core at boot (JSON or Lua table).  
- **Logs** — unified logging format -> `OVHL_OJOL_LOGS.md` + persisted logs.

---

## 2 — Design Principles
1. **No hardcode**: semua parameter dari `ConfigService` / Admin Panel.  
2. **Data-driven modules**: every module exposes `schema`, `init`, `teardown`, and optional `hotReload` handlers.  
3. **Safe hot-reload**: reload harus idempotent & transactional.  
4. **Explicit dependencies**: modules declare required services.  
5. **Observability**: SystemMonitor collects metrics + logs to files.  
6. **Fail-safe**: On critical failure, module is disabled and logged; core remains up.

---

## 3 — Bootstrapper (Spec)

### Fungsi utama
- Baca config (OVHL_CONFIG)  
- Discover services & modules (folder convention)  
- Resolve dependency graph  
- Init services in topological order  
- Provide runtime API: `Bootstrapper:AttachModule(path)`, `Bootstrapper:ReloadModule(name)`

### Lifecycle
1. PreLoad: read config, set env  
2. LoadCoreServices: ServiceManager, EventService, DataService, SystemMonitor, StyleService  
3. DiscoverModules: read `/Server/Modules`, `/Client/Modules`  
4. RegisterModules: ServiceManager:RegisterModule(meta)  
5. InitModules: call `module:init()` (respect dependencies)  
6. Ready: set `CoreReady` flag, emit `CoreReady` event

### Example API (pseudo)
```lua
-- Init.server.lua (entry)
local Bootstrapper = require(script.Parent.Core.Kernel.Bootstrapper)
Bootstrapper:Start()

-- Bootstrapper.lua (interface)
Bootstrapper = {}

function Bootstrapper:Start()
  self.config = ConfigLoader:Load()
  ServiceManager = require(...):new()
  EventService = require(...):new(ServiceManager)
  DataService = require(...):new(ServiceManager, self.config)
  SystemMonitor = require(...):new(ServiceManager)
  StyleService = require(...):new(ServiceManager)
  ServiceManager:RegisterCoreServices({EventService, DataService, SystemMonitor, StyleService})

  self:DiscoverModules()
  self:ResolveAndInit()
  EventService:FireAll("CoreReady")
end

function Bootstrapper:AttachModule(path)
  -- dynamic attach: load, register, init
end

function Bootstrapper:ReloadModule(name)
  -- call ServiceManager:ReloadModule(name)
end
```

---

## 4 — ServiceManager (Spec)

### Tanggung jawab
- Registry service & modules  
- Menyediakan dependency injection & lookup  
- Lifecycle control: `start`, `stop`, `reload`  
- Expose safe public API untuk modules

### Public API
```lua
ServiceManager:Register(name, instance)            -- manual register
ServiceManager:RegisterModule(meta)                -- auto from module manifest
ServiceManager:Get(name) -> instance               -- lookup
ServiceManager:StartAll()
ServiceManager:StopAll()
ServiceManager:Reload(name)                        -- hot reload single service/module
ServiceManager:listServices() -> {names...}
```

### Module manifest (contoh)
```lua
-- Server/Modules/FoodDelivery/manifest.lua
return {
  name = "FoodDelivery",
  depends = {"DataService","EventService"}, -- required services
  entry = "Server/Modules/FoodDelivery/Handler.lua"
}
```

---

## 5 — Module Contract (Standard)
Setiap module wajib expose minimal API:
```lua
return {
  manifest = {
    name = "MyModule",
    depends = {"DataService"}
  },

  init = function(context) -- called on boot
    -- context.ServiceManager, context.EventService, context.DataService
  end,

  teardown = function(context) -- called on stop/reload
  end,

  hotReload = function(context) -- optional: graceful reload handler
  end,

  schema = { -- optional config schema for admin & validation
    enable = {type="boolean", default=true},
    spawn_rate = {type="number", default=1.0},
  }
}
```

---

## 6 — EventService (Spec)
- Wraps Roblox RemoteEvents/RemoteFunctions in a safe interface  
- Enforce permission checks & rate-limits for client calls  
- Provide pub/sub for server modules

API:
```lua
EventService:CreateChannel("Orders")
EventService:OnClient("Orders", handler) -- auto validates caller
EventService:FireClient(player, "Orders", payload)
EventService:FireAll("Orders", payload)
EventService:OnServer("OrderCreated", handler) -- server-side events
```

Security:
- Validate remote payload schema (module-provided schema)  
- Rate-limit per-player for sensitive API (configurable)

---

## 7 — DataService (Spec)
Features:
- Per-player data with autosave & batch commit  
- Global KV store for server config & economy data  
- Retry & backoff for datastore failures  
- Local memory cache + persistence

API:
```lua
-- player data
local pdata = DataService:GetPlayerData(player) -- returns proxy with :Get/:Set/:Save
pdata:Get("wallet")
pdata:Set("wallet", 200)
pdata:Save() -- immediate

-- global data
DataService:GetGlobal("economy") -> table
DataService:SetGlobal("economy", table)
```

Autosave:
- default interval from ConfigManifest (`autosave_interval`)  
- service must expose `DataService:ForceSave()` for manual triggers

Crash-safety:
- On fail to save, put item to queue & retry N times, log to SystemMonitor

---

## 8 — SystemMonitor (Spec)
Responsibilities:
- Centralized logging & metrics  
- Error tracking & alerts (console + log file + optional webhook)  
- Health checks & heartbeats

Log format (single-line JSON-ish for readability):
```
[2025-10-21 14:37:00] [SERVICE:DataService] [LEVEL:ERROR] [CODE:DS_SAVE_FAIL] Message: "Failed to save player X after 3 attempts"
```

API:
```lua
SystemMonitor:Log(service, level, code, message, metadata)
SystemMonitor:Metric(name, value)
SystemMonitor:HealthCheck() -> {status, issues}
```

---

## 9 — StyleService (Spec)
- Holds UI tokens, theme definitions (JSON/Lua table)  
- Syncs with Admin Panel for live theme switching  
- Provides helpers for client UI components

API:
```lua
StyleService:GetToken("button.primary.background")
StyleService:SetTheme("dark", themeTable)
StyleService:Subscribe("themeChanged", callback)
```

---

## 10 — Hot-Reload Mechanism
Goals: reload a module safely with minimal disruption.

Process:
1. Admin triggers reload (via AdminPanel or file watcher) -> `Bootstrapper:ReloadModule(name)`  
2. ServiceManager checks dependents -> if dependents exist, either:
   - Reload dependents too (cascade), OR
   - Reject reload unless `force=true` (configurable)
3. Call `module.teardown(context)` to let module cleanup (save state, unregister events)  
4. Unregister module from registries (EventService channels, DataService hooks)  
5. Re-require module file (use unique module loader to avoid Luau cache issues)  
6. Validate new module manifest/schema  
7. Call `module.init(context)`  
8. Emit `ModuleReloaded` event and log to `OVHL_OJOL_LOGS.md`

Example reload call:
```lua
ServiceManager:Reload("FoodDelivery", {force = false})
-- returns {success=true, messages={"stopped", "reloaded"}}
```

---

## 11 — Config Layer (Manifest)
Format example (JSON or Lua table):
```json
{
  "autosave_interval": 300,
  "enable_hot_reload": true,
  "ui_theme": "default",
  "economy_multiplier": 1.0,
  "ai_population_density": 0.8,
  "admin_whitelist": ["UserId123", "UserId456"]
}
```
At boot: Bootstrapper reads `OVHL_CONFIG.lua` or `.json`, validates, then loads into ConfigService (via DataService or in-memory).

---

## 12 — Admin Panel Hooks (Integration)
Admin Panel uses EventService + DataService to:
- Read/Write config (`EventService:Request("GetConfig")`)  
- Trigger module reloads (`EventService:Request("ReloadModule", {name="X"})`)  
- View SystemMonitor logs & health  
- Manage admin users & permissions

Security:
- Admin Panel accessible only by authorized users (admin whitelist + role checks).  
- All admin actions logged with `[ADMIN]` tag in `OVHL_OJOL_LOGS.md`.

---

## 13 — Logging & Audit Policy
- All module level logs must be written to `OVHL_OJOL_LOGS.md`.  
- AI actions should include `[AI]` tag in logs.  
- Any config changes must be logged.  
- Hot reload events must log old manifest hash and new manifest hash.

---

## 14 — Error Handling Policy
- Non-fatal errors: log and continue.  
- Fatal errors in a module: mark module as `disabled`; alert SystemMonitor.  
- Repeated failures auto-disable module after N attempts.

---

## 15 — Testing & Validation Checklist
- [ ] Bootstrapper loads all core services and sets `CoreReady`.  
- [ ] ServiceManager resolves dependency cycles detection test.  
- [ ] Module manifest validation.  
- [ ] DataService autosave works on interval and forced save.  
- [ ] EventService permission checks (simulate client calls).  
- [ ] Hot-reload a module with active players — ensure no crashes & state preserved.  
- [ ] SystemMonitor logs and health endpoint accessible.  
- [ ] Admin Panel actions are permission-guarded and logged.  
- [ ] Simulate DataService failure: verify retry/backoff.  
- [ ] Run stress test for event throughput & monitor metrics.

---

## 16 — Migration Plan
1. Tambahkan `Core/Kernal/Bootstrapper.lua` dan `ServiceManager.lua`.  
2. Implement minimal `EventService`, `DataService` (in-memory + stub).  
3. Convert `TestOrder` ke `manifest.lua` + `init/teardown`.  
4. Run integration tests.  
5. Tambahkan `SystemMonitor`.  
6. Buat `OVHL_CONFIG.lua` default.  
7. Tambahkan HotReload support.

---

## 17 — Minimal File / Folder Checklist
```bash
Core/
├── Kernel/
│   ├── Bootstrapper.lua
│   └── LoaderUtils.lua
├── Services/
│   ├── ServiceManager.lua
│   ├── EventService.lua
│   ├── DataService.lua
│   ├── SystemMonitor.lua
│   └── StyleService.lua
├── Server/
│   └── Modules/
│       └── TestOrder/
│           ├── manifest.lua
│           └── Handler.lua
├── Client/
│   └── Modules/
├── Shared/
│   └── Utils/
OVHL_CONFIG.lua
Init.server.lua
Init.client.lua
OVHL_OJOL_LOGS.md
OVHL_OJOL_DEVELOPMENT.md
```

---

## 18 — Example: Minimal `manifest.lua`
```lua
-- Server/Modules/TestOrder/manifest.lua
return {
  name = "TestOrder",
  version = "0.1",
  depends = {"DataService","EventService"},
  entry = "Server/Modules/TestOrder/Handler.lua",
  schema = {
    enabled = {type="boolean", default=true},
    spawn_rate = {type="number", default=1.0}
  }
}
```

---

## 19 — Example: Safe Module Loader
Gunakan loader yang bisa `require` ulang module tanpa cache Luau:  
```lua
ModuleLoader:LoadFresh(path)
```
Tips Roblox: clone ModuleScript baru sebelum require untuk reinit.

---

## 20 — Next Steps
1. Pilih jalur lanjut:
   - A — Generate skeleton code untuk Bootstrapper + ServiceManager.  
   - B — Buat module `TestOrder` dan test HotReload flow.
2. Setelah itu lanjut implementasi `DataService` dan `SystemMonitor`.

---

**End of Document**
