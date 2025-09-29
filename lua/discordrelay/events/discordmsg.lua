hook.Add("DiscordRelay::DispatchEvent", "ReadDiscord", function(Event, Socket, Data)
	if Event ~= "MESSAGE_CREATE" then return end

	local _, ReadableChannels = relay.conn.FilterChannels("Read")
	if not ReadableChannels[Data.channel_id] then return end

	local Content = tostring(Data.content)
	if string.len(Content) < 1 then return end

	MsgAll(Data.author.username, " - ", Content, "\n")
end)
