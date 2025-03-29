--!strict
--!optimize 2

-- clientStarter.luau
-- This script is the entry point for the client. It is responsible for setting up the client environment and starting the client scripts.

if not game:IsLoaded() then
    game.Loaded:Wait()
end

local httpService = game:GetService("HttpService")
local typespaces = require(game.ReplicatedStorage.SharedScripts.typespace)

local test = typespaces.new("TEST", 256)
local namespace = test.namespace()
local writer = test.writer

local structSample= test.struct{
    key1 = test.bool, 
    key2 = test.vec3,
    key3 = test.struct{
        key1 = test.bool, 
        key2 = test.vec3,
        key3 = test.f32color3
    }
}

local structType = namespace.getFromSample(structSample)

local val = {
    key1 = true,
    key2 = Vector3.new(204, 302, 340),
    key3 = {
        key1 = true,
        key2 = Vector3.new(3900, 300, 222),
        key3 = Color3.new(0.368627, 0.090196, 0.392157),
    }
}

structType.encode(val)

local buf = writer.pop()

print(#buffer.tostring(buf))
print(#httpService:JSONEncode(val))

local result = structType.decode(buf, 0, 0)
workspace:WaitForChild("Part").Color = result.key3.key3
