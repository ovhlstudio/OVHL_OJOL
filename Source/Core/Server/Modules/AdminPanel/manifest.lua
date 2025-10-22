return {
    name = "AdminPanel",
    version = "1.0.0",
    depends = {"DataService", "EventService", "ServiceManager"},
    entry = "Source/Core/Server/Modules/AdminPanel/Handler.lua",
    schema = {
        enabled = {type = "boolean", default = true},
        admin_whitelist = {type = "table", default = {}}
    }
}
