local Help = relay.commands.New()
	:WithName("help")
	:WithDescription("Shows the command list")
	:WithCallback(function(Socket, Data, Args)
		local ChannelID = Data.channel_id
		if not relay.conn.IsChannel(ChannelID, "write") then return end

		local CommandPrefix = relay.config.commands.prefix
		local CommandList = {}

		for Name, Command in SortedPairs(relay.commands.List) do
			CommandList[#CommandList + 1] = Format("%s%s - %s", CommandPrefix, Name, Command.Description)
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

relay.commands.Register(Help)
