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

-------------------------------------

local RunService = game:GetService("RunService")
local PlayerService = game:GetService("Players")

local parentDir = script.Parent
local newQueue = require(parentDir.queue)
local newJob = require(parentDir.scheduler)
local typespace = require(parentDir.typespace)
local bufferTypes = require(parentDir.bufferTypes)

export type ClientCallback<T...> = (T...) -> ()
export type ServerCallback<T...> = (Player, T...) -> ()

export type PacketData<T> = {
	args: T,
	id: number,
}

export type Packet<T> = {
	serverConnect: (packet: Packet<T>, callback: ServerCallback<T>) -> (),
	clientConnect: (packet: Packet<T>, callback: ClientCallback<T>) -> (),
	fire: (packet: Packet<T>, data: T) -> (),
	fireClient: (packet: Packet<T>, player: Player, data: T) -> (),
	fireAllClients: (packet: Packet<T>, data: T) -> (),
	__type: bufferTypes.bufferType<T>,
	__id: number,
	__serverCallbacks: { ServerCallback<T> },
	__clientCallbacks: { ClientCallback<T> },
}

export type Channel = {
	add: (data: PacketData<any>) -> (),
	kill: () -> (),
	update: () -> (),
}

local networkingTypes = typespace.new("Networking", 1024)
local namespace = networkingTypes.namespace()
local writer = networkingTypes.writer
local channels: { [number]: Channel } = {}
local packetTypes: { bufferTypes.bufferType<any> } = {}
local isClient = RunService:IsClient()
local writeu8 = writer.writeU8
local writeu16At = writer.writeu16At
local readu8 = buffer.readu8
local cursor = writer.cursor
local defaultChannel: Channel

---------------------------------------------
-- Packets
---------------------------------------------

local function serverConnect<T>(packet: Packet<T>, callback: ServerCallback<T>): ()
	table.insert(packet.__serverCallbacks, callback)
end

local function illegalServerConnect<T>(packet: Packet<T>, callback: ServerCallback<T>): ()
	error("You cannot use ServerConnect from the client")
end

local function clientConnect<T>(packet: Packet<T>, callback: ClientCallback<T>): ()
	table.insert(packet.__clientCallbacks, callback)
end

local function illegalClientConnect<T>(packet: Packet<T>, callback: ClientCallback<T>): ()
	error("You cannot use ClientConnect from the server")
end

local function fire<T>(packet: Packet<T>, data: T): ()
	defaultChannel.add({ id = packet.__id, args = data})
end

local function illegalFire<T>(_packet: Packet<T>, _data: T): ()
	error("You cannot use Fire from the server")
end

local function fireClient<T>(packet: Packet<T>, player: Player, data: T): ()
	channels[player.UserId].add({ id = packet.__id, args = data })
end

local function illegalFireClient<T>(_packet: Packet<T>, _player: Player, _data: T): ()
	error("You cannot use FireClient from the client")
end

local function fireAllClients<T>(packet: Packet<T>, data: T): ()
	for _, channel in channels do
		channel.add({ id = packet.__id, args = data})
	end
end

local function illegalFireAllClients<T>(_packet: Packet<T>, _data: T): ()
	error("You cannot use FireAllClients from the client")
end

local function createServerPacket<T>(struct: T): Packet<T>
	local id = #packetTypes + 1
	local __type = namespace.getFromSample(networkingTypes.struct(struct))
	local packet: Packet<T> = {
		serverConnect = serverConnect,
		clientConnect = illegalClientConnect,
		fire = illegalFire,
		fireAllClients = fireAllClients,
		fireClient = fireClient,
		__type = __type,
		__id = id,
		__clientCallbacks = {},
		__serverCallbacks = {},
	}
	packetTypes[id] = __type
	return table.freeze(packet)
end

local function createClientPacket<T>(struct: T): Packet<T>
	local id = #packetTypes + 1
	local __type = namespace.getFromSample(networkingTypes.struct(struct))
	local packet: Packet<T> = {
		serverConnect = illegalServerConnect,
		clientConnect = clientConnect,
		fire = fire,
		fireAllClients = illegalFireAllClients,
		fireClient = illegalFireClient,
		__type = __type,
		__id = id,
		__clientCallbacks = {},
		__serverCallbacks = {},
	}
	packetTypes[id] = __type
	return table.freeze(packet)
end

---------------------------------------------
-- Channels
---------------------------------------------

local function createChannel(player: Player): ()
	local remoteEvent = (isClient and player:WaitForChild(CHANNEL_REMOTE_NAME) :: RemoteEvent) or Instance.new("RemoteEvent")
	remoteEvent.Name = CHANNEL_REMOTE_NAME
	remoteEvent.Parent = player

	local queue = newQueue()
	local push = queue.pushBack
	local pop = queue.popFront
	local size = queue.size
    local isEmpty = queue.isEmpty

	local update: () -> ()


	if isClient then
		remoteEvent.OnClientEvent:Connect(function(buf: buffer): ()
			local len = readu8(buf, 0)
            local index = 1
            for i = 1, len do
                local packetId = readu8(buf, index)
                index += 1
                local packetType = packetTypes[packetId]
                local val, valSize = packetType.decode(buf, index, 0)
                index += valSize :: number
            end
		end)
		update = function()
            if isEmpty() then return end
            local len = size()
			writeu8(len)
			for _ = 1, len do
				local packetData = pop()
                local packetId = packetData.id
                writeu8(packetId)
				local packetType = packetTypes[packetId]
				packetType.encode(packetData.args)
			end
			local buf = writer.pop()
            remoteEvent:FireServer(buf)
		end
	else
		remoteEvent.OnServerEvent:Connect(function(player: Player, buf: buffer): ()
            local len = readu8(buf, 0)
            local index = 1
            for i = 1, len do
                local packetId = readu8(buf, index)
                index += 1
                local packetType = packetTypes[packetId]
                local val, valSize = packetType.decode(buf, index, 0)
                print(  val.arr1)
                index += valSize :: number
            end
		end)
        update = function()
            if isEmpty() then return end
			local len = size()
			writeu8(len)
			for _ = 1, len do
				local packetData = pop()
                local packetId = packetData.id
                writeu8(packetId)
				local packetType = packetTypes[packetId]
				packetType.encode(packetData.args)
			end
			local buf = writer.pop()
            remoteEvent:FireClient(player, buf)
		end
	end

	local function add(data: PacketData<any>): ()
		push(data)
	end

	local function kill(): ()
		queue.clear()
		remoteEvent:Destroy()
		channels[player.UserId] = nil
	end

	local channel = table.freeze({
		add = add,
		kill = kill,
		update = update,
	})

	channels[player.UserId] = channel

	return channel
end

RunService.Heartbeat:Connect(function()
	for _, channel in channels do
		channel.update()
	end
end)

if isClient then
	defaultChannel = createChannel(PlayerService.LocalPlayer)
else
	PlayerService.PlayerAdded:Connect(createChannel)
	PlayerService.PlayerRemoving:Connect(function(Player)
		channels[Player.UserId].kill()
	end)
end

return table.freeze({
	packet = ((isClient and createClientPacket) or createServerPacket) :: <T>(struct: T) -> Packet<T>,
	types = networkingTypes,
})
