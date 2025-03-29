--!strict
--!native
--!optimize 2

-- typespace.luau
-- an extension to namespace from buffertypes. allows creation of same types with different writers.

------------Dependencies-------------
-- bufferTypes.luau                --
-- bufferWriter.luau               --
-------------------------------------

local bufferWriter = require(script.Parent.bufferWriter)
local bufferTypes  = require(script.Parent.bufferTypes)

----------------------------------
-- Cached Read Methods (Global)
----------------------------------
local readu8   = buffer.readu8
local readf32  = buffer.readf32
local readf64  = buffer.readf64
local readi8   = buffer.readi8
local readi16  = buffer.readi16
local readi32  = buffer.readi32
local readu16  = buffer.readu16
local readu32  = buffer.readu32
local defaultReadString = buffer.readstring

local readStringHeader = readu16
local readArrayHeader  = readu16

local stringHeaderSize = 2
local arrayHeaderSize  = 2

----------------------------------
-- Read Methods Group
----------------------------------
local function readBool(buf: buffer, startIndex: number): boolean
	return readu8(buf, startIndex) ~= 0
end

-- vec3 variants
local function readVec3F32(buf: buffer, startIndex: number): Vector3
	local x = readf32(buf, startIndex)
	local y = readf32(buf, startIndex + 4)
	local z = readf32(buf, startIndex + 8)
	return Vector3.new(x, y, z)
end

local function readVec3F64(buf: buffer, startIndex: number): Vector3
	local x = readf64(buf, startIndex)
	local y = readf64(buf, startIndex + 8)
	local z = readf64(buf, startIndex + 16)
	return Vector3.new(x, y, z)
end

local function readVec3I16(buf: buffer, startIndex: number): Vector3
	local x = readi16(buf, startIndex)
	local y = readi16(buf, startIndex + 2)
	local z = readi16(buf, startIndex + 4)
	return Vector3.new(x, y, z)
end

local function readVec3I8(buf: buffer, startIndex: number): Vector3
	local x = readi8(buf, startIndex)
	local y = readi8(buf, startIndex + 1)
	local z = readi8(buf, startIndex + 2)
	return Vector3.new(x, y, z)
end

local function readVec3I32(buf: buffer, startIndex: number): Vector3
	local x = readi32(buf, startIndex)
	local y = readi32(buf, startIndex + 4)
	local z = readi32(buf, startIndex + 8)
	return Vector3.new(x, y, z)
end

local function readVec3U8(buf: buffer, startIndex: number): Vector3
	local x = readu8(buf, startIndex)
	local y = readu8(buf, startIndex + 1)
	local z = readu8(buf, startIndex + 2)
	return Vector3.new(x, y, z)
end

local function readVec3U16(buf: buffer, startIndex: number): Vector3
	local x = readu16(buf, startIndex)
	local y = readu16(buf, startIndex + 2)
	local z = readu16(buf, startIndex + 4)
	return Vector3.new(x, y, z)
end

local function readVec3U32(buf: buffer, startIndex: number): Vector3
	local x = readu32(buf, startIndex)
	local y = readu32(buf, startIndex + 4)
	local z = readu32(buf, startIndex + 8)
	return Vector3.new(x, y, z)
end

-- cframe variants
local function readCFrameF32(buf: buffer, startIndex: number): CFrame
	local x = readf32(buf, startIndex)
	local y = readf32(buf, startIndex + 4)
	local z = readf32(buf, startIndex + 8)
	local r00 = readf32(buf, startIndex + 12)
	local r01 = readf32(buf, startIndex + 16)
	local r02 = readf32(buf, startIndex + 20)
	local r10 = readf32(buf, startIndex + 24)
	local r11 = readf32(buf, startIndex + 28)
	local r12 = readf32(buf, startIndex + 32)
	local r20 = readf32(buf, startIndex + 36)
	local r21 = readf32(buf, startIndex + 40)
	local r22 = readf32(buf, startIndex + 44)
	return CFrame.new(x, y, z, r00, r01, r02, r10, r11, r12, r20, r21, r22)
end

-- color3 variants
local function readColor3F32(buf: buffer, startIndex: number): Color3
	local r = readf32(buf, startIndex)
	local g = readf32(buf, startIndex + 4)
	local b = readf32(buf, startIndex + 8)
	return Color3.new(r, g, b)
end

-- udim2 variant
local function readUDim2Variant(buf: buffer, startIndex: number): UDim2
	local xScale = readf32(buf, startIndex)
	local xOffset = readi16(buf, startIndex + 4)
	local yScale = readf32(buf, startIndex + 6)
	local yOffset = readi16(buf, startIndex + 10)
	return UDim2.new(xScale, xOffset, yScale, yOffset)
end

-- readHeaderString
local function readHeaderString(buf: buffer, startIndex: number): (string, number)
    local size = readStringHeader(buf, startIndex)
    return defaultReadString(buf, startIndex + stringHeaderSize, size), size + stringHeaderSize
end

----------------------------------
-- createTypespace (Write methods inside)
----------------------------------
local typespaces = {}

local function createTypespace(name: string, writerSize: number)
    if typespaces[name] then
        error("Type-space with name already exists, name: " .. name)
    end

    local writer = bufferWriter(writerSize)
    local namespace = bufferTypes(name)

    -- Cache writer functions for optimization
    local localWriteF32 = writer.writeF32
    local localWriteF64 = writer.writeF64
    local localWriteI8  = writer.writeI8
    local localWriteI16 = writer.writeI16
    local localWriteI32 = writer.writeI32
    local localWriteU8  = writer.writeU8
    local localWriteU16 = writer.writeU16
    local localWriteU32 = writer.writeU32

    -- Write methods for vec3 variants
    local function writeVec3F32(val: Vector3): ()
        localWriteF32(val.X)
        localWriteF32(val.Y)
        localWriteF32(val.Z)
    end

    local function writeVec3F64(val: Vector3): ()
        localWriteF64(val.X)
        localWriteF64(val.Y)
        localWriteF64(val.Z)
    end

    local function writeVec3I16(val: Vector3): ()
        localWriteI16(val.X)
        localWriteI16(val.Y)
        localWriteI16(val.Z)
    end

    local function writeVec3I8(val: Vector3): ()
        localWriteI8(val.X)
        localWriteI8(val.Y)
        localWriteI8(val.Z)
    end

    local function writeVec3I32(val: Vector3): ()
        localWriteI32(val.X)
        localWriteI32(val.Y)
        localWriteI32(val.Z)
    end

    local function writeVec3U8(val: Vector3): ()
        localWriteU8(val.X)
        localWriteU8(val.Y)
        localWriteU8(val.Z)
    end

    local function writeVec3U16(val: Vector3): ()
        localWriteU16(val.X)
        localWriteU16(val.Y)
        localWriteU16(val.Z)
    end

    local function writeVec3U32(val: Vector3): ()
        localWriteU32(val.X)
        localWriteU32(val.Y)
        localWriteU32(val.Z)
    end

    -- Write methods for cframe variants (only float variants kept)
    local function writeCFrameF32(val: CFrame): ()
        local x, y, z, r00, r01, r02, r10, r11, r12, r20, r21, r22 = val:GetComponents()
        localWriteF32(x)
        localWriteF32(y)
        localWriteF32(z)
        localWriteF32(r00)
        localWriteF32(r01)
        localWriteF32(r02)
        localWriteF32(r10)
        localWriteF32(r11)
        localWriteF32(r12)
        localWriteF32(r20)
        localWriteF32(r21)
        localWriteF32(r22)
    end

    -- Write methods for color3 variants (only float variants kept)
    local function writeColor3F32(val: Color3): ()
        localWriteF32(val.R)
        localWriteF32(val.G)
        localWriteF32(val.B)
    end

    -- Write method for udim2 variant: float32 scale and int16 offset (total 12 bytes)
    local function writeUDim2Variant(val: UDim2): ()
        localWriteF32(val.X.Scale)
        localWriteI16(val.X.Offset)
        localWriteF32(val.Y.Scale)
        localWriteI16(val.Y.Offset)
    end

    ----------------------------------
    -- Arrays
    ----------------------------------
    local arrays = {}

    local function createArray<T>(sample : T) : {T}
        local t = namespace.getFromSample(sample)
        local tId = namespace.getIdFromSample(sample)
        local aId = "A" .. tId
        local prevVal = arrays[aId]
        if prevVal then return prevVal end

        local tEncode = t.encode
        local tDecode = t.decode
        local size = t.size

        local function encodeArray(val : {T}) : ()
            local len = #val
            localWriteU16(len)
            for i = 1, len do
                tEncode(val[i], size)
            end
        end

        local decodeArray = nil

        if not size then
            size = 0
            decodeArray = function(buf : buffer, startIndex : number) : ({T}, number)
                local arrayStart = startIndex
                local len = readArrayHeader(buf, startIndex)
                startIndex += arrayHeaderSize
                local array = table.create(len)           
                for i = 1, len do
                    local val, valSize = tDecode(buf, startIndex, 0)
                    if not valSize then
                        error("Invalid type-size returned while decoding array")
                    end
                    startIndex += valSize
                    array[i] = val
                end
                return array, startIndex - arrayStart
            end
        else
            decodeArray = function(buf : buffer, startIndex : number) : ({T}, number)
                local len = readArrayHeader(buf, startIndex)
                local arrayStart = startIndex
                startIndex += arrayHeaderSize
                local array = table.create(len)
                for i = 1, len do
                    array[i] = tDecode(buf, startIndex, size)
                    startIndex += size
                end
                return array, startIndex - arrayStart
            end
        end
        
        local arrayType = namespace.new("aId" .. tId, { sample }, encodeArray, decodeArray)
        arrays[aId] = arrayType
        return arrayType
    end

    local fixedArrays = {}
    local function createFixedArray<T>(sample : T, size : number) : {T}
        local t = namespace.getFromSample(sample)
        local tId = namespace.getIdFromSample(sample)
        local aId = tId .. size

        local prevVal = fixedArrays[aId]
        if prevVal then return prevVal end

        local tEncode = t.encode
        local tDecode = t.decode
        local tSize = t.size
        
        if not tSize then
            error("You cannot create fixed-array with non fixed primitive, arrayId=" .. aId)
        end

        local count = size // tSize

        local function encodeArray(val : {T}) : ()
            for i = 1, count do
                tEncode(val[i], tSize)
            end
            if #val > count then
                warn("Array has more elements than expected; later elements dropped. Expected count=" .. count)
            end
        end

        local function decodeArray(buf, startIndex) : {T}
            local array = {}
            for i = 1, count do
                array[i] = tDecode(buf, startIndex, tSize)
                startIndex += tSize
            end
            return array
        end

        local arrayType = namespace.new("aId" .. tId, { sample }, encodeArray, decodeArray, size)
        fixedArrays[aId] = arrayType
        return arrayType
    end

    ----------------------------------
    -- Strings
    ----------------------------------

    local staticStrings = {}
    local function createFixedString(sample: string): string
        local size = #sample
        local val = staticStrings[size]
        if val then return val end
        val = namespace.new(string.format("fs%d", size), sample, writer.writeFixedString, defaultReadString, size)
        staticStrings[size] = val
        return val
    end

    ----------------------------------
    -- Structs
    ----------------------------------

    local structId = 0

    local function createStruct<T>(sample : T) : T
        local keys = {}

        if typeof(sample) ~= "table" then
            error("You cannot create a struct with type other than table.")
        end

        for key, _ in sample do
            table.insert(keys, key)
        end
        table.sort(keys)        

        local encoders = {}
        local decoders = {}
        local sizes = {}

        for i, key in keys do
            local t = namespace.getFromSample(sample[key])
            encoders[i] = t.encode
            decoders[i] = t.decode
            sizes[i] = t.size
        end

        local numKeys = #keys

        local function encode(val : T) : ()
            if typeof(val) ~= "table" then
                error("Struct encode failed, passed value is not a table.")
            end
            for i = 1, numKeys do
                local key = keys[i]
                local valToWrite = val[key]
                encoders[i](valToWrite)
            end
        end

        local function decode(buf : buffer, startIndex : number) : T
            local structStart = startIndex
            local struct = {} :: any
            for i = 1, numKeys do
                local key = keys[i]
                local size = sizes[i]
                if size then
                    struct[key] = decoders[i](buf, startIndex, size)
                    startIndex += size
                else
                    struct[key], size = decoders[i](buf, startIndex, 0)
                    if not size then
                        error("Invalid type-size returned while decoding struct")
                    end
                    startIndex += size
                end
            end
            return struct :: T, startIndex - structStart
        end

        structId += 1
        return namespace.new("St"..tostring(structId), sample, encode, decode)
    end

    ----------------------------------
    -- Assemble Typespace Table
    ----------------------------------
    local typespace = table.freeze({
        bool    = namespace.new("b", false, writer.writeBool, readBool, 1),
        u8      = namespace.new("u8", 8, writer.writeU8, buffer.readu8, 1),
        u16     = namespace.new("u16", 16, writer.writeU16, buffer.readu16, 2),
        u32     = namespace.new("u32", 32, writer.writeU32, buffer.readu32, 4),
        i8      = namespace.new("i8", 7, writer.writeI8, buffer.readi8, 1),
        i16     = namespace.new("i16", 15, writer.writeI16, buffer.readi16, 2),
        i32     = namespace.new("i32", 31, writer.writeI32, buffer.readi32, 4),
        f32     = namespace.new("f32", 33, writer.writeF32, buffer.readf32, 4),
        f64     = namespace.new("f64", 64, writer.writeF64, buffer.readf64, 8),
        vec3    = namespace.new("v3", Vector3.new(), writeVec3F32, readVec3F32, 12),
        f32vec3 = namespace.new("f32v3", Vector3.new(1), writeVec3F32, readVec3F32, 12),
        f64vec3 = namespace.new("f64v3", Vector3.new(2), writeVec3F64, readVec3F64, 24),
        int16vec3 = namespace.new("i16v3", Vector3.new(3), writeVec3I16, readVec3I16, 6),
        int8vec3  = namespace.new("i8v3", Vector3.new(4), writeVec3I8, readVec3I8, 3),
        int32vec3 = namespace.new("i32v3", Vector3.new(5), writeVec3I32, readVec3I32, 12),
        uint8vec3 = namespace.new("u8v3", Vector3.new(6), writeVec3U8, readVec3U8, 3),
        uint16vec3 = namespace.new("u16v3", Vector3.new(7), writeVec3U16, readVec3U16, 6),
        uint32vec3 = namespace.new("u32v3", Vector3.new(8), writeVec3U32, readVec3U32, 12),
        f32cframe  = namespace.new("cf", CFrame.new(), writeCFrameF32, readCFrameF32, 48),
        f32color3  = namespace.new("c3", Color3.new(), writeColor3F32, readColor3F32, 12),
        f32udim2 = namespace.new("f32udim2", UDim2.new(), writeUDim2Variant, readUDim2Variant, 12),
        string  = namespace.new("s", "", writer.writeString, readHeaderString),
        array   = createArray,
        fixedArray = createFixedArray,  
        fixedString = createFixedString,
        struct = createStruct,
        namespace = function() return namespace end,
        writer = writer,
    })
    
    typespaces[name] = typespace
    return typespace
end

local function getTypespace(name: string)
    return typespaces[name]
end

return table.freeze({
    new = createTypespace,
    get = getTypespace,
})
