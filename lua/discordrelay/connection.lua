relay.conn = relay.conn or {}
local conn = relay.conn
local config = relay.config

--- Creates and connects a websocket to Discord
function conn.Initialize()
	if not conn.Instance then
		conn.Instance = discord.socket.Create(config.API)
	end

	if not conn.Instance then
		-- The internals log this already
		return
	end

	discord.socket.Connect(conn.Instance, config.Token)
end

--- Gets the list of channels within the config that have a certain flag set
--- @param Flag string The flag to search for (eg Read, Write)
--- @return table ChannelList, table KeyedChannelList
function conn.FilterChannels(Flag)
	local MessageList = config.Messages

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

--- Broadcasts a message to all writeable channels
--- @param Message Message
function conn.BroadcastMessage(Message)
	local Socket = conn.Instance

	if not Socket or not Socket:isConnected() then
		-- There are other logs that come before this when connection drops
		-- making this one redundant
		discord.logging.DevLog(LOG_ERROR, "Can't broadcast with an unconnected socket!")
		return
	end

	local WriteableChannels = conn.FilterChannels("Write")
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
