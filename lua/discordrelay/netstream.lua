AddCSLuaFile()

if SERVER then
	util.AddNetworkString("DiscordRelay::NetStreamChunk")
end

DiscordRelay.NetStream = DiscordRelay.NetStream or {}
local NetStream = DiscordRelay.NetStream

NetStream.Streams = NetStream.Streams or {}
NetStream.ReceivedCallbacks = NetStream.ReceivedCallbacks or {}
NetStream.MaxChunkSize = 8192
NetStream.BytesQueued = NetStream.BytesQueued or 0
NetStream.LastSendTime = NetStream.LastSendTime or CurTime()

function NetStream.Send(Receiver, MessageName, Data)
	local DataLength = string.len(Data)
	local NumChunks = math.ceil(DataLength / NetStream.MaxChunkSize)
	local StreamID = tostring(os.time()) .. "-" .. tostring(math.random(1000, 9999))
	local ChunkIndex = 1

	local function SendNextChunk()
		if ChunkIndex > NumChunks then
			return
		end

		if CurTime() - NetStream.LastSendTime < 1 and NetStream.BytesQueued > 50000 then
			timer.Simple(0.25, SendNextChunk)
			return
		end

		local ChunkData = string.sub(Data, (ChunkIndex - 1) * NetStream.MaxChunkSize + 1, ChunkIndex * NetStream.MaxChunkSize)
		local ChunkLength = string.len(ChunkData)

		net.Start("DiscordRelay::NetStreamChunk")
			net.WriteString(MessageName)
			net.WriteString(StreamID)
			net.WriteUInt(NumChunks, 16)
			net.WriteUInt(ChunkIndex, 16)
			net.WriteUInt(ChunkLength, 16)
			net.WriteData(ChunkData, ChunkLength)
		if SERVER then
			net.Send(Receiver)
		else
			net.SendToServer()
		end

		NetStream.BytesQueued = NetStream.BytesQueued + ChunkLength

		if CurTime() - NetStream.LastSendTime >= 1 then
			NetStream.BytesQueued = 0
			NetStream.LastSendTime = CurTime()
		end

		ChunkIndex = ChunkIndex + 1

		timer.Simple(0.15, SendNextChunk)
	end

	SendNextChunk()
end

function NetStream.Receive(MessageName, Callback)
	NetStream.ReceivedCallbacks[MessageName] = Callback
end

if SERVER then
	net.Receive("DiscordRelay::NetStreamChunk", function(Length, Player)
		local MessageName = net.ReadString()
		local StreamID = net.ReadString()
		local NumChunks = net.ReadUInt(16)
		local ChunkIndex = net.ReadUInt(16)
		local ChunkLength = net.ReadUInt(16)
		local ChunkData = net.ReadData(ChunkLength)

		NetStream.Streams[StreamID] = NetStream.Streams[StreamID] or { ["Chunks"] = {}, ["NumChunks"] = NumChunks, ["Received"] = 0, ["MessageName"] = MessageName, ["Sender"] = Player }

		local Stream = NetStream.Streams[StreamID]
		Stream.Chunks[ChunkIndex] = ChunkData
		Stream.Received = Stream.Received + 1

		if Stream.Received == Stream.NumChunks then
			local FullData = table.concat(Stream.Chunks)

			if NetStream.ReceivedCallbacks[MessageName] then
				NetStream.ReceivedCallbacks[MessageName](FullData, Stream.Sender)
			end

			NetStream.Streams[StreamID] = nil
		end
	end)
else
	net.Receive("DiscordRelay::NetStreamChunk", function()
		local MessageName = net.ReadString()
		local StreamID = net.ReadString()
		local NumChunks = net.ReadUInt(16)
		local ChunkIndex = net.ReadUInt(16)
		local ChunkLength = net.ReadUInt(16)
		local ChunkData = net.ReadData(ChunkLength)

		NetStream.Streams[StreamID] = NetStream.Streams[StreamID] or { ["Chunks"] = {}, ["NumChunks"] = NumChunks, ["Received"] = 0, ["MessageName"] = MessageName }

		local Stream = NetStream.Streams[StreamID]
		Stream.Chunks[ChunkIndex] = ChunkData
		Stream.Received = Stream.Received + 1

		if Stream.Received == Stream.NumChunks then
			local FullData = table.concat(Stream.Chunks)

			if NetStream.ReceivedCallbacks[MessageName] then
				NetStream.ReceivedCallbacks[MessageName](FullData)
			end

			NetStream.Streams[StreamID] = nil
		end
	end)
end
