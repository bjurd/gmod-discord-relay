local RCON = relay.commands.New()
	:WithName("rcon")
	:WithDescription("Runs a console command on the server")
	:WithPermissions(PERMISSION_ADMINISTRATOR)
	:WithCallback(function(Socket, Data, Args)
		local ChannelID = Data.channel_id
		local Writeable = relay.conn.IsChannel(ChannelID, "write")
		-- if not relay.conn.IsChannel(ChannelID, "write") then return end -- The command will still be ran, but you won't get feedback

		local Command = Args[1]

		if not relay.util.IsNonEmptyStr(Command) then
			if Writeable then
				local Description = "```\nInvalid parameters\n```"

				local Message = discord.messages.Begin()
					:WithUsername("RCON")
					:WithEmbed()
						:WithDescription(Description)
						:WithColorRGB(255, 0, 0)
						:End()

				relay.conn.SendWebhookMessage(ChannelID, Message)
			end

			return
		end

		local CommandStr = table.concat(Args, " ")

		if IsConCommandBlocked(CommandStr) then
			if Writeable then
				local Description = Format("```\n%s\n```", CommandStr)

				local Message = discord.messages.Begin()
					:WithUsername("RCON")
					:WithEmbed()
						:WithAuthor()
							:WithName("Command Blocked")
							:End()
						:WithDescription(Description)
						:WithColorRGB(255, 0, 0)
						:End()

				relay.conn.SendWebhookMessage(ChannelID, Message)
			end

			return
		end

		local CommandExec = CommandStr
		if not string.EndsWith(CommandExec, "\n") then
			-- game.ConsoleCommand wants this
			CommandExec = CommandExec .. "\n"
		end

		-- RunConsoleCommand(unpack(Args))
		game.ConsoleCommand(CommandExec)

		if Writeable then
			local Description = Format("```\n%s\n```", CommandStr)

			local Message = discord.messages.Begin()
				:WithUsername("RCON")
				:WithEmbed()
					:WithAuthor()
						:WithName("Ran Command")
						:End()
					:WithDescription(Description)
					:WithColorRGB(0, 255, 0)
					:End()

			relay.conn.SendWebhookMessage(ChannelID, Message)
		end
	end)

relay.commands.Register(RCON)
