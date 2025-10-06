relay.commands.Register("help", PERMISSION_NONE, function(Socket, Data, Args)
	local ChannelID = Data.channel_id
	local _, WriteableChannels = relay.conn.FilterChannels("Write")

	if not WriteableChannels[ChannelID] then return end

	local CommandPrefix = relay.config.CommandPrefix
	local CommandList = {}

	for Name, _ in SortedPairs(relay.commands.List) do
		CommandList[#CommandList + 1] = Format("%s%s", CommandPrefix, Name)
	end

	local Compiled = table.concat(CommandList, "\n")

	local Message = discord.messages.Begin()
		:WithEmbed()
			:WithTitle("Command List")
			:WithDescription(Compiled)
			:WithColorRGB(255, 150, 0)
			:End()

	discord.messages.SendToChannel(Socket, ChannelID, Message)
end)
