--!strict
--!optimize 2

-- clientStarter.luau
-- This script is the entry point for the client. It is responsible for setting up the client environment and starting the client scripts.

if not game:IsLoaded() then
    game.Loaded:Wait()
end

local scheduler = require(game.ReplicatedStorage.SharedScripts.scheduler)
local bufferTypes = require(game.ReplicatedStorage.SharedScripts.bufferTypes)
local bufferWriter = require(game.ReplicatedStorage.SharedScripts.bufferWriter)


