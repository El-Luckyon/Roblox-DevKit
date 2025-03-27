--!strict
--!optimize 2

-- clientStarter.luau
-- This script is the entry point for the client. It is responsible for setting up the client environment and starting the client scripts.

if not game:IsLoaded() then
    game.Loaded:Wait()
end

local scheduler = require(game.ReplicatedStorage.SharedScripts.scheduler)

local function printHello()
    warn("Hello from the client!")
end

local t = {}

for i = 1, 10000 do
    -- task.spawn(function()
    --     task.wait(math.random(1, 5))
    --     local r = math.random(1, 5)
    --     while true do
    --         printHello()
    --         task.wait(r)
    --     end
    -- end)
    t[i] = scheduler(printHello).after(5)
end
