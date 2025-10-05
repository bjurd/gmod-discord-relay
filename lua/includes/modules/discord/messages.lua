if not util.IsBinaryModuleInstalled("chttp") then
	logging.Log(LOG_WARNING, "CHTTP binary module is not installed! Messages may not be able to be sent!")
else
	require("chttp")
end

local HTTP = CHTTP or HTTP
module("messages", package.discord)

MessageURL = "https://discord.com/api/v%d/channels/%s/messages"

function MESSAGE_Success(Code, Body)
	if Code ~= 200 then
		logging.DevLog(LOG_ERROR, "Failed to POST message, code %d", Code)
		logging.DevLog(LOG_ERROR, Body)
		return
	end

	logging.DevLog(LOG_SUCCESS, "Successfully POSTed message")
end

function MESSAGE_Fail(Reason)
	logging.DevLog(LOG_ERROR, "Failed to POST message, %s", Reason)
end

--- POSTs a message
--- @param Socket WEBSOCKET A GWSockets socket instance
--- @param MessageURL string URL to POST to
--- @param Data table Message data
function POSTMessage(Socket, MessageURL, Data)
	local MessageData = util.TableToJSON(Data)

	HTTP({
		["url"] = MessageURL,
		["method"] = "POST",

		["headers"] = {
			["Content-Type"] = "application/json",
			["Content-Length"] = tostring(string.len(MessageData)),
			["Host"] = "discord.com", -- This is required for webhooks, probably a misconfiguration on Discord's side
			["Authorization"] = Format("Bot %s", Socket.Token)
		},
		["type"] = "application/json", -- There was some bunk ass change in HTTP that made this needed :/

		["body"] = MessageData,

		["success"] = MESSAGE_Success,
		["failed"] = MESSAGE_Fail
	})
end

--- Sends a message to a channel
--- @param Socket WEBSOCKET A GWSockets socket instance
--- @param Channel string Channel snowflake
--- @param Message Message
function SendToChannel(Socket, Channel, Message)
	local MessageURL = Format(MessageURL, Socket.API, Channel)

	POSTMessage(Socket, MessageURL, Message:__json())
end

--- Begins a message builder
--- @return Message Message The created Message object
function Begin()
	return oop.CreateNew("Message")
end
