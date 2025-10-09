module("operations", package.discord)

enums.CreateIncremental("OPERATION", {
	"DISPATCH",
	"HEARTBEAT",
	"IDENTIFY",
	"PRESENCE_UPDATE",
	"VOICE_PING", -- No longer used as of API v5
	"VOICE_UPDATE",
	"RESUME",
	"RECONNECT",
	"REQUEST_MEMBERS",
	"INVALID_SESSION",
	"HELLO",
	"HEARTBEAT_ACK"
	-- Soundboard sounds jumps to 31 instead of 12 for some reason...
})

--- Manually (re-)fires an operation
--- @param Socket WEBSOCKET A GWSockets socket instance
--- @param Type number Operation type, see OPERATION_ enums
--- @param Data table Operation data provided by the socket message
function Fire(Socket, Type, Data)
	logging.DevLog(LOG_NORMAL, "Firing operation %d", Type)

	hook.Run("DiscordRelay::FireOperation", Type, Socket, Data)
end

--- Processes an operation by calling the related callback(s)
--- @param Socket WEBSOCKET A GWSockets socket instance
--- @param Type number Operation type, see OPERATION_ enums
--- @param Data table Operation data provided by the socket message
function Process(Socket, Type, Data)
	Fire(Socket, Type, Data)
end

--- Creates a blank data packet for an operation
--- @param Socket WEBSOCKET A GWSockets socket instance
--- @param Type number Operation type, see OPERATION_ enums
function CreateDataPacket(Socket, Type)
	return {
		["op"] = Type,

		["d"] = {
			["token"] = Socket.Token
		}
	}
end

--- Processes a dispatched event by calling the related callback(s)
--- @param Socket WEBSOCKET A GWSockets socket instance
--- @param Event string Event name, see https://discord.com/developers/docs/events/gateway-events
--- @param Data table Event data, provided by the DISPATCH operation
function DispatchEvent(Socket, Event, Data)
	logging.DevLog(LOG_NORMAL, "Dispatching event %s", Event)

	hook.Run("DiscordRelay::DispatchEvent", Event, Socket, Data)
end



--[[
	Default operation/dispatch handlers
--]]

hook.Add("DiscordRelay::DispatchEvent", "DEFAULT::READY", function(Event, Socket, Data)
	if Event ~= "READY" then return end

	Socket.SessionID = Data.session_id
	Socket.ResumeGateway = Data.resume_gateway_url

	if isnumber(Socket.HeartbeatInterval) then
		local HearbeatIdentifier = Format("DiscordRelay::Heartbeat::%s", Socket.SessionID)
		Socket.HearbeatIdentifier = HearbeatIdentifier

		timer.Create(HearbeatIdentifier, Socket.HeartbeatInterval, 0, function()
			-- You're supposed to close and reconnect if you don't get a HEARTBEAT_ACK from this
			-- but that's retarded sooooooooooooooooo
			socket.WriteHeartbeat(Socket)
		end)

		logging.DevLog(LOG_SUCCESS, "Setup heartbeat for session %s", Socket.SessionID)
	else
		logging.DevLog(LOG_ERROR, "Failed to setup heartbeat for session %s", Socket.SessionID)
	end

	logging.DevLog(LOG_SUCCESS, "Socket is ready! Session ID: %s", Socket.SessionID)
end)

hook.Add("DiscordRelay::FireOperation", "DEFAULT::HEARTBEAT", function(Operation, Socket, Data)
	if Operation ~= OPERATION_HEARTBEAT then return end -- Discord sends these occasionally

	logging.DevLog(LOG_NORMAL, "Received heartbeat request for session %s", Socket.SessionID)

	socket.WriteHeartbeat(Socket)
end)

hook.Add("DiscordRelay::FireOperation", "DEFAULT::HEARTBEAT_ACK", function(Operation, Socket, Data)
	if Operation ~= OPERATION_HEARTBEAT_ACK then return end

	logging.DevLog(LOG_SUCCESS, "Acknowledged heartbeat for session %s", Socket.SessionID)
end)

hook.Add("DiscordRelay::FireOperation", "DEFAULT::DISPATCH", function(Operation, Socket, Data)
	if Operation ~= OPERATION_DISPATCH then return end

	Socket.SequenceNumber = tonumber(Data.s) or 0

	DispatchEvent(Socket, Data.t, Data.d)
end)

hook.Add("DiscordRelay::FireOperation", "DEFAULT::INVALID_SESSION", function(Operation, Socket, Data)
	if Operation ~= OPERATION_INVALID_SESSION then return end

	logging.Log(LOG_ERROR, "Socket has an invalid session!")

	if isstring(Socket.HearbeatIdentifier) then
		timer.Remove(Socket.HearbeatIdentifier)
	end

	if Data.d == true then -- This is incredibly rare and almost never happens, but can
		local NewSocket = socket.Resume(Socket)

		if NewSocket then
			Socket = nil
		else
			-- socket.Resume already logs
			return
		end

		logging.Log(LOG_SUCCESS, "Sending session resume for %s", NewSocket.SessionID)

		local DataPacket = CreateDataPacket(NewSocket, OPERATION_RESUME)
		local PacketData = DataPacket.d

		PacketData.session_id = NewSocket.SessionID
		PacketData.seq = NewSocket.SequenceNumber or 0

		socket.WriteData(NewSocket, DataPacket)
	end
end)

hook.Add("DiscordRelay::FireOperation", "DEFAULT::HELLO", function(Operation, Socket, Data)
	if Operation ~= OPERATION_HELLO then return end

	logging.DevLog(LOG_NORMAL, "Sending IDENTIFY from HELLO")

	local DataPacket = CreateDataPacket(Socket, OPERATION_IDENTIFY)

	local PacketData = DataPacket.d
	PacketData["intents"] = INTENTS_DEFAULT -- TODO: Read this from the config
	PacketData["compress"] = false -- Discord uses zlib compression that Garry's Mod doesn't have a way to cope with

	PacketData["properties"] = { -- This is required (or else you get INVALID_SESSION), so let's make it on mobile :D!
		["os"] = "linux",
		["browser"] = "Discord iOS",
		["device"] = "Discord iOS"
	}

	socket.WriteData(Socket, DataPacket)

	-- Wait until we have a session id to start this
	-- so we can use the session id as the timer identifier
	local HeartbeatInterval = Data.d.heartbeat_interval / 1000
	Socket.HeartbeatInterval = HeartbeatInterval
end)
