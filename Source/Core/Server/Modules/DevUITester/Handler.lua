--!strict
local DevUITester = {}

function DevUITester:init(context)
    self.ServiceManager = context.ServiceManager
    self.EventService = context.EventService
    print("🎨 DevUITester initialized - Ready for UI testing")
end

function DevUITester:teardown()
    print("🎨 DevUITester shutdown")
end

return DevUITester
