--!strict
--!optimize 2

-- packets.luau
-- creation of packets using networking module

local networking = require(script.Parent.Parent.SharedScripts.networking)
local types = networking.types

return table.freeze{
    benchmarkPacket = networking.packet{
        boolArray = types.array(types.bool),
        stringArray = types.array(types.string),
        vec3Array = types.array(types.vec3),
        struct1 = types.struct{
            boolArray = types.array(types.bool),
            stringArray = types.array(types.string),
            vec3Array = types.array(types.vec3),
        },
        struct2 = types.struct{
            boolArray = types.array(types.bool),
            stringArray = types.array(types.string),
            vec3Array = types.array(types.vec3),
        },
    }
}