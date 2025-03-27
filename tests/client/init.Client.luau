--!strict
--!optimize 2

-- clientStarter.luau
-- This script is the entry point for the client. It is responsible for setting up the client environment and starting the client scripts.

local RunService = game:GetService("RunService")

RunService.Heartbeat:Connect(function()
    print("Hello, world!")
end)

RunService.RenderStepped:Connect(function()
    warn("Hello world!")
end)