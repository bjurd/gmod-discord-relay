DiscordRelay.Socket = DiscordRelay.Socket or {}

local Socket

function DiscordRelay.Socket.SendHeartbeat()
	local Heartbeat = { ["op"] = 1, ["d"] = DiscordRelay.Socket.LastSequenceNumber }

	Socket:write(DiscordRelay.json.encode(Heartbeat))
end

function DiscordRelay.Socket.Identify()
	local Identify = {
		["op"] = 2,

		["d"] = {
			["token"] = Format("Bot %s", DiscordRelay.Config.Token),
			["intents"] = DiscordRelay.Config.Intents,

			["properties"] = {
				["os"] = "linux",
				["browser"] = "Discord iOS",
				["device"] = "Discord iOS"
			},

			["compress"] = false
		}
	}

	Socket:write(DiscordRelay.json.encode(Identify))
end

function DiscordRelay.Socket.Resume()
	local Resume = {
		["op"] = 6,

		["d"] = {
			["token"] = Format("Bot %s", DiscordRelay.Config.Token),
			["session_id"] = DiscordRelay.Socket.SessionID,
			["seq"] = DiscordRelay.Socket.LastSequenceNumber or 0
		}
	}

	Socket:write(DiscordRelay.json.encode(Resume))
end

function DiscordRelay.Socket.Setup()
	if DiscordRelay.Socket.Socket then
		DiscordRelay.Socket.Socket:close()
		DiscordRelay.Socket.Socket = nil
	end

	DiscordRelay.Socket.Socket = GWSockets.createWebSocket(Format("wss://gateway.discord.gg/?v=%d&encoding=json", DiscordRelay.Config.API))
	Socket = DiscordRelay.Socket.Socket

	function Socket:onConnected()
		DiscordRelay.Socket.Connected = true
	end

	function Socket:onDisconnected()
		DiscordRelay.Socket.Connected = false

		print("disconnected")

		timer.Remove("DiscordRelay::Heartbeat")
		timer.Simple(5, DiscordRelay.Socket.Setup)
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
end
