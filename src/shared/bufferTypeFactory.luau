--!strict
--!native
--!optimize 2

-- bufferTypeFactory.luau
-- will handle creation of buffer types and namespaces. (data types that can be encoded into a buffer)

------------Dependencies-------------
--                                 --
-------------------------------------

export type encodeFunc<T> = (val: T, size : number?) -> ()
export type decodeFunc<T> = (buf: buffer, startIndex: number, size : number) -> (T, number?)

export type factory = {
	new: <T>(id: string, val: T, encode: encodeFunc<T>, decode: decodeFunc<T>, size: number?) -> T,
	getFromId: (id: string) -> bufferType<any>,
	getFromSample: <T>(val: T) -> bufferType<T>,
	getIdFromSample: <T>(val: T) -> string,
}

export type bufferType<T> = {
	value: T,
	encode: encodeFunc<T>,
	decode: decodeFunc<T>,
	size: number?,
	hash: string,
}

-- factory Constructor
return function<T>(name : string) : factory

    local bufferTypesFromHash: { [string]: bufferType<any> } = {}
    local bufferTypesFromId: { [string]: bufferType<any> } = {}
    local idFromHash: { [string]: string } = {}

	-- Converts a sample into a hash so the type can be infered from a sample
	local function hashFunction(val: any): string
		local t = typeof(val)
		if t == "string" then
			return val
		elseif t == "number" or t == "table" or t == "buffer" then
			return tostring(val) -- buffers and table will have the same memory address, so we can use tostring to get the address
		elseif t == "boolean" then
			return val and "true" or "false"
		elseif t == "Vector3" then
			return string.format("v/%f%f%f", val.X, val.Y, val.Z)
		elseif t == "Color3" then
			return string.format("c/%f%f%f", val.R, val.G, val.B)
		elseif t == "CFrame" then
			return string.format("cf/%f%f%f", val.X, val.Y, val.Z)
		elseif t == "UDim2" then
			return string.format("ud/%f%f%f%f", val.X.Scale, val.X.Offset, val.Y.Scale, val.Y.Offset)
		end
		error("Unsupported type for hashing: " .. t .. " Namespace: " .. name)
		return "null"
	end

	-- Type Constructor
	local function createBufferType<T>(id: string, val: T, encode: encodeFunc<T>, decode: decodeFunc<T>, size: number?): T
		local hash = hashFunction(val)
		if bufferTypesFromHash[hash] then
			error("Buffer type already exists for hash: " .. hash .. " Namespace: " .. name)
		end

		local bufferType: bufferType<T> = {
			value = val,
			encode = encode,
			decode = decode,
			size = size,
			hash = hash,
		}

		bufferTypesFromHash[hash] = bufferType
		bufferTypesFromId[id] = bufferType
		idFromHash[hash] = id

		return val
	end

	-- Returns the buffer type from the id
	local function getFromId(id: string): bufferType<any>
		return bufferTypesFromId[id]
	end

	-- Returns the buffer type from the sample by hashing the sample
	local function getFromSample<T>(val: T): bufferType<T>
		local hash = hashFunction(val)
		return bufferTypesFromHash[hash]
	end

	-- Returns the id from the sample by hashing the sample
	local function getIdFromSample<T>(val: T): string
		local hash = hashFunction(val)
		return idFromHash[hash]
	end

	return table.freeze({
		new = createBufferType,
		getFromId = getFromId,
		getFromSample = getFromSample,
		getIdFromSample = getIdFromSample,
	})
end
