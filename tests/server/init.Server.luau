--!strict
--!optimize 2

-- serverStarter.luau
-- This script is the entry point for the server. It is responsible for setting up the server environment and starting the server scripts.

local networking = require(game.ReplicatedStorage.SharedScripts.networking)

local packet = networking.packet
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

game.ReplicatedStorage.RemoteEvent.OnServerEvent:Connect(function()

end)
