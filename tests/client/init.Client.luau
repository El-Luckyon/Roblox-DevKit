--!strict
--!optimize 2

-- clientStarter.luau
-- This script is the entry point for the client. It is responsible for setting up the client environment and starting the client scripts.

if not game:IsLoaded() then
    game.Loaded:Wait()
end

local packets = require(game.ReplicatedStorage.SharedTests.packets)
local remote = game.ReplicatedStorage.RemoteEvent
local benchmarkPacket = packets.benchmarkPacket
-- 255 bytes
local data = {
    boolArray = {true, false, true, false, true, false, true, false},
    stringArray = {"Hello World", "Good Day", "Bye Friend"},
    vec3Array = {Vector3.new(1, 1, 1), Vector3.new(2, 2, 2), Vector3.new(3, 3, 3)},
    struct1 = {
        boolArray = {true, false, true, false, true, false, true, false},
        stringArray = {"Hello World", "Good Day", "Bye Friend"},
        vec3Array = {Vector3.new(1, 1, 1), Vector3.new(2, 2, 2), Vector3.new(3, 3, 3)},
    },
    struct2 = {
        boolArray = {true, false, true, false, true, false, true, false},
        stringArray = {"Hello World", "Good Day", "Bye Friend"},
        vec3Array = {Vector3.new(1, 1, 1), Vector3.new(2, 2, 2), Vector3.new(3, 3, 3)},
    }
}

while true do
    task.wait()
    for _ = 1, 200 do
        benchmarkPacket.fire(data)
        -- remote:FireServer(data)
    end
end
