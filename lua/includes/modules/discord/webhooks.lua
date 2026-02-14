if not util.IsBinaryModuleInstalled("chttp") then
	logging.Log(LOG_WARNING, "CHTTP binary module is not installed! Webhooks may not be able to be used!")
else
	require("chttp")
end

local HTTP = CHTTP or HTTP
module("webhooks", package.discord)

CacheKey = "WebhookCache::%s"
WebhookURL = "https://discord.com/api/v%d/channels/%s/webhooks"

function WEBHOOK_GET_Success(Code, Body, ChannelID, Callback)
	if Code ~= 200 then
		logging.DevLog(LOG_ERROR, "Failed to fetch channel webhooks, code %d", Code)
		logging.DevLog(LOG_ERROR, Body)
		Callback(nil)

		return
	end

	local Data = util.JSONToTable(Body, false, true)

	if not Data then
		logging.DevLog(LOG_ERROR, "Got invalid response for channel webhooks")
		logging.DevLog(LOG_ERROR, Body)
		Callback(nil)

		return
	end

	-- See roles.lua for explanations of this stuff
	local Key = Format(CacheKey, ChannelID)
	local Cached = cache.Get(Key) or cache.CreateTimed(Key, 1800)

	table.Empty(Cached)

	local WebhookCount = #Data
	local UseableCount = 0 -- Only used for logging purposes

	for i = 1, WebhookCount do
		local WebhookData = Data[i]

		local Webhook = oop.ConstructNew("Webhook", WebhookData)
		table.insert(Cached, Webhook)

		if Webhook:IsUseable() then
			UseableCount = UseableCount + 1
		end
	end

	logging.DevLog(UseableCount > 0 and LOG_SUCCESS or LOG_WARNING, "Got %d useable %s for channel %s", UseableCount, strings.Pluralize("webhook", UseableCount), ChannelID)

	Callback(Cached)
end

function WEBHOOK_GET_Fail(Reason, Callback)
	logging.DevLog(LOG_ERROR, "Failed to fetch channel webhooks, %s", Reason)

	Callback(nil)
end

function WEBHOOK_POST_Success(Code, Body)
	if Code ~= 200 then
		if string.len(Body) > 0 then
			logging.DevLog(LOG_ERROR, "Failed to POST webhook, code %d", Code)
			logging.DevLog(LOG_ERROR, Body)

			return
		else
			-- Webhooks will return a code 204 (No Content) error code
			-- but the message will still be sent and the error returned by Discord
			-- is an empty string... /shrug
		end
	end

	logging.DevLog(LOG_SUCCESS, "Successfully POSTed webhook")
end

function WEBHOOK_POST_Fail(Reason)
	logging.DevLog(LOG_ERROR, "Failed to POST webhook, %s", Reason)
end

function WEBHOOK_CREATE_Success(Code, Body, ChannelID, Callback)
	if Code ~= 200 then
		logging.DevLog(LOG_ERROR, "Failed to create webhook, code %d", Code)
		logging.DevLog(LOG_ERROR, Body)
		return
	end

	local WebhookData = util.JSONToTable(Body, false, true)

	if not WebhookData then
		logging.DevLog(LOG_ERROR, "Got invalid response for webhook creation")
		logging.DevLog(LOG_ERROR, Body)
		Callback(nil)

		return
	end

	local Webhook = oop.ConstructNew("Webhook", WebhookData)

	local Key = Format(CacheKey, ChannelID)
	local Cached = cache.Get(Key) or cache.CreateTimed(Key, 1800)

	table.Empty(Cached)
	table.insert(Cached, Webhook) -- Our new friend is our only friend

	logging.DevLog(LOG_SUCCESS, "Successfully created and cached webhook")

	Callback(Webhook)
end

function WEBHOOK_CREATE_Fail(Reason, Callback)
	logging.DevLog(LOG_ERROR, "Failed to create webhook, %s", Reason)

	Callback(nil)
end

--- Fetches and creates the webhook cache table, used internally by GetChannelWebhooks
--- @param Socket WEBSOCKET A GWSockets socket instance
--- @param ChannelID string Channel snowflake
--- @param Callback function Only argument is the sequential Webhook table, nil on failure
function FetchChannelWebhooks(Socket, ChannelID, Callback)
	local WebhookURL = Format(WebhookURL, Socket.API, ChannelID)

	HTTP({
		["url"] = WebhookURL,
		["method"] = "GET",

		["headers"] = {
			["Accept"] = "application/json",
			["Host"] = "discord.com",
			["Authorization"] = Format("Bot %s", Socket.Token)
		},

		["success"] = function(Code, Body)
			WEBHOOK_GET_Success(Code, Body, ChannelID, Callback)
		end,

		["failed"] = function(Reason)
			WEBHOOK_GET_Fail(Reason, Callback)
		end
	})
end

--- Gets a table of Webhooks for a channel and runs the callback, cached for 30 minutes
--- @param Socket WEBSOCKET A GWSockets socket instance
--- @param ChannelID string Channel snowflake
--- @param Callback function Only argument is the sequential Webhook table, nil on failure
function GetChannelWebhooks(Socket, ChannelID, Callback)
	local Key = Format(CacheKey, ChannelID)
	local Cached = cache.Get(Key)

	if Cached then
		logging.DevLog(LOG_SUCCESS, "Using cached webhooks for channel %s", ChannelID)

		Callback(Cached)
		return
	end

	FetchChannelWebhooks(Socket, ChannelID, Callback)
end

--- Creates a new Webhook for a channel and runs the callback
--- @param Socket WEBSOCKET A GWSockets socket instance
--- @param ChannelID string Channel snowflake
--- @param Callback function Only argument is the created Webhook, nil on failure
function CreateChannelWebhook(Socket, ChannelID, Callback)
	local WebhookURL = Format(WebhookURL, Socket.API, ChannelID)

	local CreationTable = { ["name"] = "Relay" } -- TODO: Make a config option for this? Doesn't really matter though
	local CreationData = util.TableToJSON(CreationTable)

	HTTP({
		["url"] = WebhookURL,
		["method"] = "POST",

		["headers"] = {
			["Content-Type"] = "application/json",
			["Content-Length"] = tostring(utf8.len(CreationData)),
			["Host"] = "discord.com", -- This is required for webhooks, probably a misconfiguration on Discord's side
			["Authorization"] = Format("Bot %s", Socket.Token)
		},
		["type"] = "application/json",

		["body"] = CreationData,

		["success"] = function(Code, Body)
			WEBHOOK_CREATE_Success(Code, Body, ChannelID, Callback)
		end,

		["failed"] = function(Reason)
			WEBHOOK_CREATE_Fail(Reason, Callback)
		end
	})
end

--- POSTs a message to a webhook
--- @param Socket WEBSOCKET A GWSockets socket instance
--- @param WebhookURL string URL to POST to
--- @param Data table Message data
function POSTMessage(Socket, WebhookURL, Data)
	local MessageData = util.TableToJSON(Data)

	logging.DevLog(LOG_NORMAL, "POSTing webhook data %s", MessageData)

	HTTP({
		["url"] = WebhookURL,
		["method"] = "POST",

		["headers"] = {
			["Content-Type"] = "application/json",
			["Content-Length"] = tostring(utf8.len(MessageData)),
			["Host"] = "discord.com",
			["Authorization"] = Format("Bot %s", Socket.Token)
		},
		["type"] = "application/json",

		["body"] = MessageData,

		["success"] = WEBHOOK_POST_Success,
		["failed"] = WEBHOOK_POST_Fail
	})
end

--- Sends a message to a channel webhook
--- @param Socket WEBSOCKET A GWSockets socket instance
--- @param Webhook Webhook
--- @param Message Message
function SendToChannel(Socket, Webhook, Message)
	if not Webhook:IsUseable() then
		logging.Log(LOG_ERROR, "Got unusable webhook in SendToChannel")
		return
	end

	local WebhookURL = Webhook:GetURL()

	POSTMessage(Socket, WebhookURL, Message:__json())
end
