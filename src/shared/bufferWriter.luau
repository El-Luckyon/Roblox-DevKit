--!strict
--!native
--!optimize 2

-- bufferWriter.luau
-- functions to write to buffer

------------Dependencies-------------
--                                 --
-------------------------------------

export type writer = {
    writeString: (val: string) -> (),
    writeU8: (val: number) -> (),
    writeU16: (val: number) -> (),
    writeU32: (val: number) -> (),
    writeI8: (val: number) -> (),
    writeI16: (val: number) -> (),
    writeI32: (val: number) -> (),
    writeF32: (val: number) -> (),
    writeF64: (val: number) -> (),
    writeBuf: (val: buffer) -> (),
    writeBool: (val: boolean) -> (),
    writeFixedString: (val: string) -> (),
    writeFixedBuffer: (val: buffer) -> (),
    pop: () -> buffer,
    reset: () -> (),
    move: (val : number) -> (),
    cursor : () -> number,
    writeu16At : (val : number, cursor : number) -> (),
}

local defaultWriteString = buffer.writestring
local defaultWriteU8 = buffer.writeu8
local defaultWriteU16 = buffer.writeu16
local defaultWriteU32 = buffer.writeu32

local defaultWriteI8 = buffer.writei8
local defaultWriteI16 = buffer.writei16
local defaultWriteI32 = buffer.writei32

local defaultWriteF32 = buffer.writef32 
local defaultWriteF64 = buffer.writef64

local copy = buffer.copy
local create = buffer.create
local len = buffer.len

local stringHeaderWriter = defaultWriteU16
local stringHeaderWriterSize = 2

-- Writer Constructor
local function createBufferWriter(DEFAULT_SIZE : number) : writer
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
        local sizeToWrite = stringSize + stringHeaderWriterSize
        alloc(sizeToWrite)
        stringHeaderWriter(buf, cursor, stringSize)
        defaultWriteString(buf, cursor + stringHeaderWriterSize, val, stringSize)
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
        defaultWriteF32(buf, cursor, val)
        cursor += 4
    end

    local function writeF64(val : number) : ()
        alloc(8)
        defaultWriteF64(buf, cursor, val)
        cursor += 8
    end

    local function writeBuffer(val : buffer) : ()
        local bufferSize = len(val)
        local sizeToWrite = bufferSize + stringHeaderWriterSize
        alloc(sizeToWrite)
        stringHeaderWriter(buf, cursor, bufferSize)
        copy(buf, cursor, val, 0, bufferSize)
        cursor += sizeToWrite
    end

    local function writeFixedBuffer(val : buffer) : ()
        local bufferSize = len(val)
        alloc(bufferSize)
        copy(buf, cursor, val, 0, bufferSize)
        cursor += bufferSize
    end

    local function writeFixedString(val : string) : ()
        local stringSize = #val
        alloc(stringSize)
        defaultWriteString(buf, cursor, val, stringSize)
        cursor += stringSize
    end

    local function writeBoolean(val : boolean) : ()
        alloc(1)
        defaultWriteU8(buf, cursor, val and 1 or 0)
        cursor += 1
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

    -- Moves the cursor to designated position
    local function moveCursor(val : number) : ()
        cursor = val
    end

    local function writeu16At(val : number, newCursor : number) : ()
        alloc(2)
        defaultWriteU16(buf, newCursor, val)
    end

    local function getCursor() : number
        return cursor
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
        writeBool = writeBoolean,
        writeFixedString = writeFixedString,
        writeFixedBuffer = writeFixedBuffer,
        pop = pop,
        reset = reset,
        move = moveCursor,
        cursor = getCursor,
        writeu16At = writeu16At,
    }
end

return createBufferWriter
