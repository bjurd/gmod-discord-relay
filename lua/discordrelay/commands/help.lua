relay.commands.Register("help", PERMISSION_NONE, function(Socket, Data, Args)
	local ChannelID = Data.channel_id
	if not relay.conn.IsChannel(ChannelID, "Write") then return end

	local CommandPrefix = relay.config.CommandPrefix
	local CommandList = {}

	for Name, _ in SortedPairs(relay.commands.List) do
		CommandList[#CommandList + 1] = Format("%s%s", CommandPrefix, Name)
	end

	local Compiled = table.concat(CommandList, "\n")

	local Message = discord.messages.Begin()
		:WithEmbed()
			:WithAuthor()
				:WithName("Command List")
				:End()
			:WithDescription(Compiled)
			:WithColorRGB(255, 150, 0)
			:End()

	relay.conn.SendWebhookMessage(ChannelID, Message)
end)
