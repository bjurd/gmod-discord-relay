DiscordRelay.Socket = DiscordRelay.Socket or {}

if DiscordRelay.Socket.Socket then
	DiscordRelay.Socket.Socket:close()
end

-- Incredible variable names
DiscordRelay.Socket.Socket = GWSockets.createWebSocket(Format("wss://gateway.discord.gg/?v=%d&encoding=json", DiscordRelay.Config.API))
local Socket = DiscordRelay.Socket.Socket

function DiscordRelay.Socket.SendHeartbeat()
	local Heartbeat = { ["op"] = 1, ["d"] = DiscordRelay.Socket.LastSequenceNumber }

	Socket:write(DiscordRelay.json.encode(Heartbeat))
end

function Socket:onConnected()
	DiscordRelay.Socket.Connected = true
end

function Socket:onDisconnected()
	DiscordRelay.Socket.Connected = false

	print("disconnected")
end

function Socket:onMessage(Message)
	local Data = DiscordRelay.json.decode(Message)

	if not Data then
		error("Relay failed to read response message")
		return
	end

	local Operation = tonumber(Data.op)

	if not isnumber(Operation) then
		error("Relay got no operation")
		return
	end

	DiscordRelay.Events.RunOperation(Operation, Data)
end

function Socket:onError(Message)
	print("error", Message)
end

Socket:open()
