--!strict
--!optimize 2
--!native

-- networking.luau
-- networking module. manages creation and processing of packets

------------Dependencies-------------
-- queue.luau                      --
-- scheduler.luau                  --
-- typespace.luau                  --
-- bufferTypes.luau                --
-------------------------------------

--------------Configs----------------
local CHANNEL_REMOTE_NAME = "__networking_remote"
local CLIENT_AWAIT_CHANNEL_TIMEOUT = 10

-------------------------------------

local RunService = game:GetService("RunService")
local PlayerService = game:GetService("Players")

local parentDir = script.Parent
local typespace = require(parentDir.typespace)
local bufferTypes = require(parentDir.bufferTypes)

export type ClientCallback<T> = (T) -> ()
export type ServerCallback<T> = (Player, T) -> ()

export type Packet<T> = {
	serverConnect: (callback: ServerCallback<T>) -> (),
	fire: (args: T) -> (),
	fireAllClients: (args: T) -> (),
	fireClient: (player: Player, args: T) -> (),
	clientConnect: (callback: ClientCallback<T>) -> (),
}

export type Channel = {
	process: () -> (),
	add: (packetId: number, data: any) -> (),
	kill: () -> (),
}

local networkingSpace = typespace.new("ElLuckyon.Networking", 1024)
local networkignNamespace = networkingSpace.namespace()
local writer = networkingSpace.writer
local writeu8 = writer.writeU8
local readu8 = buffer.readu8
local packetEncoders: { bufferTypes.encodeFunc<any> } = {}
local packetDecoders: { bufferTypes.decodeFunc<any> } = {}
local env: "CLIENT" | "SERVER" = (RunService:IsClient() and "CLIENT") or "SERVER"
local serverAwaitingChannels = {}
local clientCallbacks: { [number]: { ClientCallback<any> } } = {}
local serverCallbacks: { [number]: { ServerCallback<any> } } = {}
local serverChannels: { Channel } = {}
local clientChannel: Channel

--------------------------------------
--             Packets              --
--------------------------------------

-- We use closures because they have less overhead than metatables or table indexing

-- Methods blocked on server

local function illegalClientConnect<T>(_callback: ClientCallback<T>): ()
	error("You cannot use clientConnect on the server")
end

local function illegalFire<T>(_args: T): ()
	error("You cannot use fire from the server")
end

-- Method blocked on client

local function illegalServerConnect<T>(_callback: ServerCallback<T>): ()
	error("You cannot use serverConnect from the client")
end

local function illegalFireAllClients<T>(_args: T): ()
	error("You cannot use fireAllClients on the server")
end

local function illegalFireClient<T>(_args: T): ()
	error("You cannot use fireClient on the server")
end

local packetIdCounter = 0

-- Server packet constructor
local function createServerPacket<T>(struct: T): Packet<T>
	local callbacks: { ServerCallback<T> } = {}
	local packetId = packetIdCounter

	networkingSpace.struct(struct)
	local packetType = networkignNamespace.getFromSample(struct)

	local function serverConnect(callback: ServerCallback<T>): ()
		table.insert(callbacks, callback)
	end

	local function fireAllClients(args: T): ()
		for _, channel in serverChannels do
			channel.add(packetId, args)
		end
	end

	local function fireClient(player: Player, args: T): ()
		serverChannels[player.UserId].add(packetId, args)
	end

	packetEncoders[packetId] = packetType.encode
	packetDecoders[packetId] = packetType.decode
	serverCallbacks[packetId] = callbacks

	packetIdCounter += 1

	return table.freeze({
		serverConnect = serverConnect,
		fire = illegalFire,
		fireAllClients = fireAllClients,
		fireClient = fireClient,
		clientConnect = illegalClientConnect,
	})
end

-- Client packet constructor
local function createClientPacket<T>(struct: T): Packet<T>
	local callbacks: { ClientCallback<T> } = {}
	local packetId = packetIdCounter

	networkingSpace.struct(struct)
	local packetType = networkignNamespace.getFromSample(struct)

	local function clientConnect(callback: ClientCallback<T>): ()
		table.insert(callbacks, callback)
	end

	local function fire(args: T): ()
		clientChannel.add(packetId, args)
	end

	packetEncoders[packetId] = packetType.encode
	packetDecoders[packetId] = packetType.decode
	clientCallbacks[packetId] = callbacks

	packetIdCounter += 1

	return table.freeze({
		serverConnect = illegalServerConnect,
		fire = fire,
		fireAllClients = illegalFireAllClients,
		fireClient = illegalFireClient,
		clientConnect = clientConnect,
	})
end

----------------------------------------
--             Channels               --
----------------------------------------

-- We use seperate functions for server & client thought they are similar to reduce overhead from additonal function calls and table lookups.

local function createServerChannel(player: Player)
	local remote = Instance.new("RemoteEvent")
	remote.Name = CHANNEL_REMOTE_NAME
	remote.Parent = player

	local pendingPackets: { [number]: { any } } = {}
	local numOfPendingPackets = 0

	--// We clear tables instead of dropping them because the overhead from clearing is < than over head from creating new table every time we add.
	local function process(): ()
		writeu8(numOfPendingPackets)
		for packetId, collection in pendingPackets do
			local collectionSize = #collection
			if collectionSize < 1 then
				continue
			end
			local encode = packetEncoders[packetId]
			writeu8(packetId)
			writeu8(collectionSize)
			for _, data in collection do
				encode(data)
			end
			table.clear(collection)
		end
		numOfPendingPackets = 0
		local buf = writer.pop()
		remote:FireClient(player, buf)
	end

	local function add<T>(packetId: number, data: T): ()
		local packetCollection: { T } = pendingPackets[packetId]
		if not packetCollection then
			pendingPackets[packetId] = { data }
            numOfPendingPackets += 1
		else
			table.insert(packetCollection, data)
            if #packetCollection == 1 then
                numOfPendingPackets += 1
            end
		end		
		if numOfPendingPackets == 1 then
			table.insert(serverAwaitingChannels, process)
		end
	end

	local function kill(): ()
		serverChannels[player.UserId] = nil
		remote:Destroy()
		table.clear(pendingPackets)
	end

	-- Writing deocode in monolith function to minimize func call overheads and table lookups
	remote.OnServerEvent:Connect(function(sender, buf: buffer)
		if sender ~= player then
			warn("Player attempted to communicate via other players channel, player=", sender)
			return
		end
		local numOfUniquePackets = readu8(buf, 0)
		local index = 1
		for _ = 1, numOfUniquePackets do
			local packetId = readu8(buf, index) 
			index += 1

			local numOfSimilarPackets = readu8(buf, index)
			index += 1

			local decode = packetDecoders[packetId]
			if not decode then
				warn(
					"Packet did not contain a valid decode method, Payload dropped, packetId & sender =",
					packetId,
					sender
				)
				return
			end

			local callbacks = serverCallbacks[packetId]

			for _ = 1, numOfSimilarPackets do
				local data, dataSize = decode(buf, index, 0)
				if not dataSize then
					warn("Packet did not return a valid size, Payload dropped, packetId & sender =", packetId, sender)
					return
				end
                index += dataSize
				for _, callback in callbacks do
					callback(sender, data)
				end
			end
		end
	end)

	serverChannels[player.UserId] = { kill = kill, process = process, add = add }
end

local function createClientChannel(player: Player): Channel
	local remote = player:WaitForChild(CHANNEL_REMOTE_NAME, CLIENT_AWAIT_CHANNEL_TIMEOUT) :: RemoteEvent
	if not remote then
		player:Kick("Could not establish connection with server.")
	end

	local pendingPackets: { [number]: { any } } = {}
	local numOfPendingPackets = 0

	local function add<T>(packetId: number, data: T): ()
		local packetCollection: { T } = pendingPackets[packetId]
		if not packetCollection then
			pendingPackets[packetId] = { data }
            numOfPendingPackets += 1
		else
			table.insert(packetCollection, data)
            if #packetCollection == 1 then
                numOfPendingPackets += 1
            end
		end
	end

	local function process(): ()
        if numOfPendingPackets == 0 then return end
		writeu8(numOfPendingPackets)
		for packetId, collection in pendingPackets do
			local collectionSize = #collection
			if collectionSize < 1 then
				continue
			end
			local encode = packetEncoders[packetId]
			writeu8(packetId)
			writeu8(collectionSize)
			for _, data in collection do
				encode(data)
			end
			table.clear(collection)
		end
		numOfPendingPackets = 0
		local buf = writer.pop()
		remote:FireServer(buf)
	end

	local function kill(): ()
		serverChannels[player.UserId] = nil
		remote:Destroy()
		table.clear(pendingPackets)
	end

	-- Relaxed checks compared to server, cuz we can trust the server
	remote.OnClientEvent:Connect(function(buf: buffer)
		local numOfUniquePackets = readu8(buf, 0)
		local index = 1
		for _ = 1, numOfUniquePackets do
			local packetId = readu8(buf, index)
			index += 1

			local numOfSimilarPackets = readu8(buf, index)
			index += 1

			local decode = packetDecoders[packetId]
			local callbacks = clientCallbacks[packetId]

			for _ = 1, numOfSimilarPackets do
				local data, dataSize = decode(buf, index, 0)
				if not dataSize then
					warn("Packet did not return a valid size, Payload dropped, packetId =", packetId)
					return
				end
                index += dataSize
				for _, callback in callbacks do
					callback(data)
				end
			end
		end
	end)

	return { kill = kill, process = process, add = add }
end

local packetConstructor: <T>(struct: T) -> Packet<T>

if env == "CLIENT" then
	clientChannel = createClientChannel(PlayerService.LocalPlayer)
	packetConstructor = createClientPacket
    RunService.Heartbeat:Connect(function()
        clientChannel.process()
    end)
else
	PlayerService.PlayerAdded:Connect(createServerChannel)
	PlayerService.PlayerRemoving:Connect(function(player)
		serverChannels[player.UserId].kill()
	end)
	packetConstructor = createServerPacket
	RunService.Heartbeat:Connect(function()
		for _, process in serverAwaitingChannels do
			process()
		end
		table.clear(serverAwaitingChannels)
	end)
end

return table.freeze({
	packet = packetConstructor,
	types = networkingSpace,
})
