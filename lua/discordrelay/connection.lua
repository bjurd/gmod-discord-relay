relay.conn = relay.conn or {}
local conn = relay.conn
local config = relay.config

--- Creates and connects a websocket to Discord
function conn.Initialize()
	if not relay.util.IsNonEmptyStr(config.token) then
		discord.logging.Log(LOG_ERROR, "No token provided in relay configuration file, the relay will be nonfunctional!")
		return
	end

	if not conn.Instance then
		local Version = tonumber(config.api)
		conn.Instance = discord.socket.Create(Version)
	end

	if not conn.Instance then
		-- The internals log this already
		return
	end

	discord.socket.Connect(conn.Instance, config.token)
end

--- Gets the list of channels within the config that have a certain flag set
--- @param Flag string The flag to search for (eg Read, Write)
--- @return table ChannelList, table KeyedChannelList
function conn.FilterChannels(Flag) -- TODO: Cache the results of this
	local MessageList = config.messages

	local ChannelList = {}
	local KeyedChannelList = {}

	for GuildID, Channels in next, MessageList do
		for ChannelID, Settings in next, Channels do
			if not Settings[Flag] then continue end

			table.insert(ChannelList, ChannelID)
			KeyedChannelList[ChannelID] = true -- Channel IDs are unique across the platform so this is fine
		end
	end

	return ChannelList, KeyedChannelList
end

--- Returns if a ChannelID is in the config with a certain flag set
--- @param ChannelID string The channel snowflake
--- @param Flag string The flag to search for (eg Read, Write)
function conn.IsChannel(ChannelID, Flag)
	local _, KeyedChannelList = conn.FilterChannels(Flag)

	return KeyedChannelList[ChannelID]
end

--- Broadcasts a message to all writeable channels
--- @param Message Message
--- @param FilterFlag string|nil The flag to filter channels for, defaults to "Write"
function conn.BroadcastMessage(Message, FilterFlag)
	local Socket = conn.Instance

	if not Socket or not Socket:isConnected() then
		-- There are other logs that come before this when connection drops
		-- making this one redundant
		discord.logging.DevLog(LOG_ERROR, "Can't broadcast with an unconnected socket!")
		return
	end

	FilterFlag = FilterFlag or "write"

	local WriteableChannels = conn.FilterChannels(FilterFlag)
	local Channels = #WriteableChannels

	if Channels < 1 then
		-- This could be seen as annoying if someone wants to only relay errors or logs for some reason
		-- but that 1% of people can frick off!!!
		discord.logging.Log(LOG_WARNING, "There are no channels to broadcast messages to")
		return
	end

	for i = 1, Channels do
		local ChannelID = WriteableChannels[i]

		discord.messages.SendToChannel(Socket, ChannelID, Message)
	end
end

--- Sends a Message through a Webhook, used internally by BroadcastWebhookMessage
--- Serves as a wrapper for creating a Webhook if a useable one doesn't already exist before sending a message
--- NOTE: This function does NOT check channel configuration status (eg Read, Write)
--- @param ChannelID string Channel snowflake
--- @param Message Message
function conn.SendWebhookMessage(ChannelID, Message)
	local Socket = conn.Instance

	if not Socket or not Socket:isConnected() then
		discord.logging.DevLog(LOG_ERROR, "Can't send messages with an unconnected socket!")
		return
	end

	discord.webhooks.GetChannelWebhooks(Socket, ChannelID, function(Webhooks)
		local WebhookCount = #Webhooks

		for i = 1, WebhookCount do
			local Webhook = Webhooks[i]
			if not Webhook:IsUseable() then continue end

			discord.webhooks.SendToChannel(Socket, Webhook, Message)

			-- Found a useable one!
			return
		end

		discord.logging.Log(LOG_NORMAL, "Creating new webhook for channel %s", ChannelID)

		-- Ah hell
		discord.webhooks.CreateChannelWebhook(Socket, ChannelID, function(Webhook)
			if not Webhook or not Webhook:IsUseable() then
				discord.logging.Log(LOG_ERROR, "Failed to create a useable webhook for channel %s", ChannelID)
				return
			end

			discord.webhooks.SendToChannel(Socket, Webhook, Message)
		end)
	end)
end

--- Broadcasts a message to all writeable channel webhooks
--- @param Message Message
--- @param FilterFlag string|nil The flag to filter channels for, defaults to "Write"
function conn.BroadcastWebhookMessage(Message, FilterFlag)
	local Socket = conn.Instance

	if not Socket or not Socket:isConnected() then
		discord.logging.DevLog(LOG_ERROR, "Can't broadcast with an unconnected socket!")
		return
	end

	FilterFlag = FilterFlag or "write"

	local WriteableChannels = conn.FilterChannels(FilterFlag)
	local Channels = #WriteableChannels

	if Channels < 1 then
		discord.logging.Log(LOG_WARNING, "There are no channels to broadcast messages to")
		return
	end

	for i = 1, Channels do
		local ChannelID = WriteableChannels[i]

		conn.SendWebhookMessage(ChannelID, Message)
	end
end

--- Broadcasts a message to all writeable channel webhooks as a Player
--- @param Player Player If the player is invalid the name will be "Console"
--- @param Message Message The Message to send, will have its Username and AvatarURL overridden with the Player's data
function conn.BroadcastPlayerMessage(Player, Message)
	if Player:IsValid() then
		Message = Message:WithUsername(relay.util.LimitUsername(Player:Nick()))

		relay.steam.GetPlayerAvatar(Player, function(AvatarURL)
			Message = Message:WithAvatar(AvatarURL) -- It's okay if this fails, they'll just have no avatar

			conn.BroadcastWebhookMessage(Message)
		end)
	else
		Message = Message:WithUsername("Console")

		conn.BroadcastWebhookMessage(Message)
	end
end
