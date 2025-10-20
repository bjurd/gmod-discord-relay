if not util.IsBinaryModuleInstalled("gwsockets") then
	logging.Log(LOG_WARNING, "GWSockets binary module is not installed! Sockets will be nonfunctional!")
else
	require("gwsockets")
end

module("socket", package.discord)

GWSockets.addVerifyPath("/etc/ssl/certs") -- Thank you Fredy very cool

SocketGatewayParams = "?v=%d&encoding=json"
SocketGatewayURL = "wss://gateway.discord.gg/"

--- Keys to ignore when copying a Socket for resume
NonCopyKeys = {
	["__CppUserData"] = true,
	["onConnected"] = true,
	["onDisconnected"] = true,
	["onMessage"] = true,
	["onError"] = true
}

--- @meta
--- @alias WEBSOCKET table

--- Callback for when the socket gets connected, internal use only
--- @param self WEBSOCKET A GWSockets socket instance
function SOCKET_OnConnected(self)
	if not isstring(self.Token) then
		logging.Log(LOG_ERROR, "Tried to connect socket with no token")
		self:closeNow()

		return
	end

	logging.Log(LOG_SUCCESS, "Socket connected to gateway")
end

--- Callback for when the socket gets disconnected, internal use only
--- @param self WEBSOCKET A GWSockets socket instance
function SOCKET_OnDisconnected(self)
	logging.Log(LOG_WARNING, "Socket disconnected")

	if isstring(self.HearbeatIdentifier) then
		timer.Remove(self.HearbeatIdentifier)
	end

	-- TODO: Check close code, don't know how to do that from here since there's no other arguments
	socket.Resume(self)
end

--- Callback for when the socket receives a message, internal use only
--- @param self WEBSOCKET A GWSockets socket instance
--- @param Message string The received message in JSON
function SOCKET_OnMessage(self, Message)
	local MessageData = util.JSONToTable(Message)

	-- There's some strange limitation when passing the Message directly in to Format
	-- Also LuaLS is losing its mind over the arguments I'm passing in
	logging.HighDevLog(LOG_NORMAL, "Socket message: %s", table.ToString(MessageData, nil, false))

	if not MessageData then
		logging.DevLog(LOG_ERROR, "Socket got non-JSON message: %s", tostring(Message))
		return
	end

	local Operation = tonumber(MessageData.op)

	if not isnumber(Operation) then -- tonumber returns nil on failure
		logging.DevLog(LOG_ERROR, "Socket got non-operational message: %s", tostring(Message))
		return
	end

	operations.Process(self, Operation, MessageData)
end

--- Callback for when the socket receives an error message, internal use only
--- @param self WEBSOCKET A GWSockets socket instance
--- @param Message string The error message
function SOCKET_OnError(self, Message)
	logging.Log(LOG_ERROR, "Socket error: %s", Message)
end

--- Prepares a socket for communication with the gateway
--- @param Socket WEBSOCKET A GWSockets socket instance
function Prepare(Socket)
	-- Socket:setMessageCompression(true)

	Socket.onConnected = SOCKET_OnConnected
	Socket.onDisconnected = SOCKET_OnDisconnected
	Socket.onMessage = SOCKET_OnMessage
	Socket.onError = SOCKET_OnError
end

--- Creates a socket to the Discord gateway
--- @param API number The API version, see API_ enums
--- @return WEBSOCKET|nil Socket A GWSockets socket instance, nil on failure
function Create(API)
	if not GWSockets then
		logging.Log(LOG_ERROR, "Tried to create a socket without GWSockets!")
		return nil
	end

	local Status = versioning.GetAPIStatus(API)

	if Status == API_STATUS_UNKNOWN then
		logging.Log(LOG_ERROR, "Tried to create a socket with an unknown API version!")
		return nil
	end

	if Status == API_STATUS_DISCONTINUED then
		logging.Log(LOG_ERROR, "Tried to create a socket with a discontinued API version!")
		return nil
	end

	if Status == API_STATUS_DEPRECATED then
		logging.Log(LOG_WARNING, "Creating a socket with deprecated API version %d", API)
	end

	local Gateway = SocketGatewayURL .. SocketGatewayParams
	local Socket = GWSockets.createWebSocket(Format(Gateway, API))

	if Socket then
		logging.Log(LOG_SUCCESS, "Created a socket with API version %d", API)

		Socket.API = API
		Prepare(Socket)

		return Socket
	else
		logging.Log(LOG_WARNING, "Failed to create a socket with API version %d", API)
		return nil
	end
end

--- Connects a socket to the Discord gateway
--- @param Socket WEBSOCKET A GWSockets socket instance
--- @param Token string The token to use for authentication
function Connect(Socket, Token)
	Socket.Token = Token

	Socket:open()
end

--- Sends the resume operation for a socket, this will destroy it and create a new one
--- @param Socket WEBSOCKET A GWSockets socket instance
--- @return WEBSOCKET|nil Socket The newly created socket instance, nil on failure
function Resume(Socket)
	local SocketData = {}

	for Key, Value in next, Socket do
		if NonCopyKeys[Key] then continue end
		SocketData[Key] = Value
	end

	Socket:close()

	-- Make the new friend
	local ResumeGateway = SocketData.ResumeGateway

	if not ResumeGateway or string.len(ResumeGateway) < 1 then
		logging.Log(LOG_ERROR, "Failed to resume socket session %s", SocketData.SessionID)
		return nil
	end

	local Gateway = ResumeGateway .. SocketGatewayParams
	local NewSocket = GWSockets.createWebSocket(Format(Gateway, SocketData.API))

	for Key, Value in next, SocketData do
		NewSocket[Key] = Value
	end

	Prepare(NewSocket)
	Connect(NewSocket, SocketData.Token)

	logging.Log(LOG_SUCCESS, "Starting socket resume for %s", SocketData.SessionID)

	-- Let others know about this so we can replace the socket instance
	-- because you can't change a socket's URL once it's been created
	-- Thanks GWSockets!
	hook.Run("DiscordRelay::SocketResume", Socket, NewSocket)

	return NewSocket
end

--- Writes a data table by converting it to JSON
--- @param Socket WEBSOCKET A GWSockets socket instance
--- @param Data table The JSON data to send
function WriteData(Socket, Data)
	local JSON = util.TableToJSON(Data)

	Socket:write(JSON)
end

--- Writes JSON to the socket
--- @param Socket WEBSOCKET A GWSockets socket instance
--- @param JSON string The JSON data to send
function WriteJSON(Socket, JSON)
	Socket:write(JSON)
end

--- Writes a Heartbeat operation to the socket
--- @param Socket WEBSOCKET
function WriteHeartbeat(Socket)
	local Data = {}
	Data.op = OPERATION_HEARTBEAT
	Data.d = isnumber(Socket.SequenceNumber) and Socket.SequenceNumber or 0

	logging.DevLog(LOG_NORMAL, "Writing heartbeat for session %s seq %d", Socket.SessionID, Data.d)

	WriteData(Socket, Data)
end
