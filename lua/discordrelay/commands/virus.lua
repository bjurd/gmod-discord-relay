local Virus = relay.commands.New()
	:WithName("virus")
	:WithDescription("Only REAL admins can run this one!")
	:WithPermissions(PERMISSION_ADMINISTRATOR)
	:WithPermissionsExplicit(true)
	:WithCallback(function(Socket, Data, Args)
		local ChannelID = Data.channel_id
		if not relay.conn.IsChannel(ChannelID, "write") then return end

		local Message = discord.messages.Begin()
			:WithContent("hello world")

		discord.messages.SendToChannel(Socket, ChannelID, Message)
	end)

relay.commands.Register(Virus)
