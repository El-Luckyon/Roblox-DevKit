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

local writer = bufferWriter(256)

local namespace = bufferTypes("Test-Space")
local u32 = namespace.new("U32", 32, writer.writeU32, buffer.readu32, 4)

print(namespace.getFromSample(u32).size)

