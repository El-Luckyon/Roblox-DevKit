--
--!optimize 2

-- serverStarter.luau
-- This script is the entry point for the server. It is responsible for setting up the server environment and starting the server scripts.

local packets = require(game.ReplicatedStorage.SharedTests.packets)
local remote = game.ReplicatedStorage.RemoteEvent

local EPSILON = 0.0001

-- Helper: deep equality comparison for tables
local function deepEqual(a, b)
	-- if both are tables, compare their contents recursively
	if type(a) == "table" and type(b) == "table" then
		-- compare keys in a
		for key, aValue in pairs(a) do
			local bValue = b[key]
			if bValue == nil then
				return false, "Missing key: " .. tostring(key)
			end
			local eq, msg = deepEqual(aValue, bValue)
			if not eq then
				return false, string.format("Key %s mismatch: %s", tostring(key), msg)
			end
		end
		-- also check b has no extra keys
		for key, _ in pairs(b) do
			if a[key] == nil then
				return false, "Extra key in b: " .. tostring(key)
			end
		end

		return true
	elseif typeof(a) == "Vector3" and typeof(b) == "Vector3" then
		-- compare vector components with tolerance
		local diff = a - b
		return diff.Magnitude < EPSILON, string.format("Vectors differ: %s vs %s", tostring(a), tostring(b))
	else
		-- use simple equality
		return a == b, string.format("Values differ: %s vs %s", tostring(a), tostring(b))
	end
end

-- Expected data structure (from your description)
local expectedData = {
	boolArray = {true, false, true, false, true, false, true, false},
	stringArray = {"Hello World", "Good Day", "Bye Friend"},
	vec3Array = {Vector3.new(1,1,1), Vector3.new(2,2,2), Vector3.new(3,3,3)},
	struct1 = {
		boolArray = {true, false, true, false, true, false, true, false},
		stringArray = {"Hello World", "Good Day", "Bye Friend"},
		vec3Array = {Vector3.new(1,1,1), Vector3.new(2,2,2), Vector3.new(3,3,3)},
	},
	struct2 = {
		boolArray = {true, false, true, false, true, false, true, false},
		stringArray = {"Hello World", "Good Day", "Bye Friend"},
		vec3Array = {Vector3.new(1,1,1), Vector3.new(2,2,2), Vector3.new(3,3,3)},
	}
}

-- Global counters for callback statistics
local callbackCount = 0
local lastPrintTime = os.clock()

-- This function is called every time a remote event is received from a client.
local function onDataReceived(player: Player, data: any)
	-- Assume data is a table (already decoded)
	local ok, errMsg = deepEqual(data, expectedData)
	if not ok then
		warn(string.format("Data verification failed for player %s: %s", player.Name, errMsg))
	else
		callbackCount += 1
	end

	-- Every second, print how many times the callback was called.
	local now = os.clock()
	if now - lastPrintTime >= 1 then
		print(string.format("Player %s: Callback successful count in last second: %d", player.Name, callbackCount))
		callbackCount = 0
		lastPrintTime = now
	end
end

-- Example usage:
-- You would connect this function to your RemoteEvent's OnServerEvent:
-- remoteEvent.OnServerEvent:Connect(onDataReceived)

packets.benchmarkPacket.serverConnect(onDataReceived)
-- remote.OnServerEvent:Connect(onDataReceived)