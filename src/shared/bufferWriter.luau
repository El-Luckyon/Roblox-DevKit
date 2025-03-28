--!strict
--!native
--!optimize 2

-- bufferWriter.luau
-- functions to write to buffer

local defaultWriteString = buffer.writestring
local defaultWriteU8 = buffer.writeu8
local defaultWriteU16 = buffer.writeu16
local defaultWriteU32 = buffer.writeu32

local defaultWriteI8 = buffer.writei8
local defaultWriteI16 = buffer.writei16
local defaultWriteI32 = buffer.writei32

local defaultWriteFloat32 = buffer.writef32 
local defaultWriteFloat16 = buffer.writef64

local copy = buffer.copy
local create = buffer.create
local len = buffer.len

local stringHeaderWriter = defaultWriteU16
local stringHeaderWriterSize = 2

-- Writer Constructor
local function createBufferWriter(DEFAULT_SIZE : number)
    local buf = buffer.create(DEFAULT_SIZE)
    local cursor = 0
    local size = DEFAULT_SIZE

    -- Allocates more space in the buffer if needed
    local function alloc(sizeToWrite : number)
        local neededSize = cursor + sizeToWrite
        if neededSize > size then
            size = math.max(size * 2, neededSize)
            local newBuffer = create(size)
            copy(newBuffer, 0, buf, 0, cursor)
            buf = newBuffer
        end
    end

    -- Write Methods for different types

    local function writeString(val : string) : ()
        local stringSize = #val
        local sizeToWrite = stringSize + 1
        alloc(sizeToWrite)
        stringHeaderWriter(buf, cursor, stringSize)
        defaultWriteString(buf, cursor + stringHeaderWriterSize, val, sizeToWrite)
        cursor += sizeToWrite
    end

    local function writeU8(val : number) : ()
        alloc(1)
        defaultWriteU8(buf, cursor, val)
        cursor += 1
    end

    local function writeU16(val : number) : ()
        alloc(2)
        defaultWriteU16(buf, cursor, val)
        cursor += 2
    end

    local function writeU32(val : number) : ()
        alloc(4)
        defaultWriteU32(buf, cursor, val)
        cursor += 4
    end

    local function writeI8(val : number) : ()
        alloc(1)
        defaultWriteI8(buf, cursor, val)
        cursor += 1
    end

    local function writeI16(val : number) : ()
        alloc(2)
        defaultWriteI16(buf, cursor, val)
        cursor += 2
    end

    local function writeI32(val : number) : ()
        alloc(4)
        defaultWriteI32(buf, cursor, val)
        cursor += 4
    end

    local function writeF32(val : number) : ()
        alloc(4)
        defaultWriteFloat32(buf, cursor, val)
        cursor += 4
    end

    local function writeF64(val : number) : ()
        alloc(8)
        defaultWriteFloat16(buf, cursor, val)
        cursor += 8
    end

    local function writeBuffer(val : buffer) : ()
        local sizeToWrite = len(val)
        alloc(sizeToWrite)
        copy(buf, cursor, val, 0, sizeToWrite)
        cursor += sizeToWrite
    end

    -- Returns a buffer with the data written so far
    local function pop() : buffer
        local newBuffer = buffer.create(cursor)
        copy(newBuffer, 0, buf, 0, cursor)
        cursor = 0
        return newBuffer
    end

    -- Resets the buffer to its initial state
    local function reset() : ()
        cursor = 0
        size = DEFAULT_SIZE
        buf = buffer.create(size)
    end

    return table.freeze{
        writeString = writeString,
        writeU8 = writeU8,
        writeU16 = writeU16,
        writeU32 = writeU32,
        writeI8 = writeI8,
        writeI16 = writeI16,
        writeI32 = writeI32,
        writeF32 = writeF32,
        writeF64 = writeF64,
        writeBuf = writeBuffer,
        pop = pop,
        reset = reset,
    }
end

return createBufferWriter
