return {
    name = "DevUITester",
    version = "1.0.0", 
    depends = {"EventService"},
    entry = "Source/Core/Server/Modules/DevUITester/Handler.lua",
    schema = {
        enabled = {type = "boolean", default = true}
    }
}
