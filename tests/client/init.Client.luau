--!strict
--!optimize 2

-- clientStarter.luau
-- This script is the entry point for the client. It is responsible for setting up the client environment and starting the client scripts.

if not game:IsLoaded() then
    game.Loaded:Wait()
end

local networking = require(game.ReplicatedStorage.SharedScripts.networking)
local types = networking.types

local packet = networking.packet{
    arr1 = types.array(types.bool),
    arr2 = types.array(types.bool),
    arr3 = types.array(types.bool),
    arr4 = types.array(types.string),
    arr5 = types.array(types.string),
    arr6 = types.array(types.string),
    arr7 = types.array(types.string),
}

local data = {
    arr1 = {
        true, false, true, false,
        true, false, true, false,
        true, false, true, false,
        true, false, true, false,
        true, false, true, false,
        true, false, true, false,
        true, false, true, false,
        true, false, true, false,
        true, false, true, false,
        true, false, true, false,
        true, false, true, false,
        true, false, true, false,
        true, false, true, false,
        true, false, true, false,
        true, false, true, false,
        true, false, true, false,
        true, false, true, false,
        true, false, true, false,
        true, false, true, false,
        true, false, true, false,
        true, false, true, false,
        true, false, true, false,
        true, false, true, false,
        true, false, true, false,
        true, false, true, false,
        true, false, true, false,
        true, false, true, false,
        true, false, true, false,
        true, false, true, false,
        true, false, true, false,
        true, false, true, false,
        true, false, true, false,
        true, false, true, false,
        true, false, true, false,
        true, false, true, false,
        true, false, true, false,
        true, false, true, false,
        true, false, true, false,
        true, false, true, false,
        true, false, true, false,
        true, false, true, false,
        true, false, true, false,
        true, false, true, false,
        true, false, true, false,
        true, false, true, false,
        true, false, true, false,
        true, false, true, false,
        true, false, true, false,
        true, false, true, false,
        true, false, true, false,
        true, false, true, false,
        true, false, true, false,
        true, false, true, false,
        true, false, true, false,
        true, false, true, false,
        true, false, true, false,
        true, false, true, false,
        true, false, true, false,
        true, false, true, false,
        true, false, true, false,
    },
    arr2 = {true, false, true, false},
    arr3 = {true, false, true, false},
    arr4 = {"x'x''x", "bruh", "skibibkb", "coolaid"},
    arr5 = {"x'x''x", "bruh", "skibibkb", "coolaid"},
    arr6 = {"x'x''x", "bruh", "skibibkb", "coolaid"},
    arr7 = {
        "x'x''x", "bruh", "skibibkb", "coolaid",
        "x'x''x", "bruh", "skibibkb", "coolaid",
        "x'x''x", "bruh", "skibibkb", "coolaid",
        "x'x''x", "bruh", "skibibkb", "coolaid",
        "x'x''x", "bruh", "skibibkb", "coolaid",
        "x'x''x", "bruh", "skibibkb", "coolaid",
        "x'x''x", "bruh", "skibibkb", "coolaid",
        "x'x''x", "bruh", "skibibkb", "coolaid",
        "x'x''x", "bruh", "skibibkb", "coolaid",
        "x'x''x", "bruh", "skibibkb", "coolaid",
        "x'x''x", "bruh", "skibibkb", "coolaid",
    },
}

local remote = game.ReplicatedStorage.RemoteEvent

while true do
    task.wait()
    for i = 1, 200 do
        packet:fire(data)
    end
end

