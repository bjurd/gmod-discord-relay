relay.commands.Register("lua", PERMISSION_ADMINISTRATOR, function(Socket, Data, Args)
	local ChannelID = Data.channel_id
	local Writeable = relay.conn.IsChannel(ChannelID, "Write") -- See rcon.lua

	local Lua = table.concat(Args, " ")
	local LuaFn = CompileString(Lua, "DiscordRelay", false)

	if isstring(LuaFn) then
		if Writeable then
			local Description = Format("```\n%s\n```", LuaFn)

			local Message = discord.messages.Begin()
				:WithUsername("LUA")
				:WithEmbed()
					:WithAuthor()
						:WithName("Compilation Error")
						:End()
					:WithDescription(Description)
					:WithColorRGB(255, 0, 0)
					:End()

			relay.conn.SendWebhookMessage(ChannelID, Message)
		end

		return
	end

	local Results = { pcall(LuaFn) }
	if not Writeable then return end -- pcall ran it, so if we can't give feedback who cares what it's just done

	-- TODO: This could be cleaned up with more variables and gotos, but meehhhhhhhhh
	local Description = ""
	local Message = discord.messages.Begin()
		:WithUsername("LUA")
		:WithEmbed()

	local Result = table.remove(Results, 1)

	if Result ~= true then
		local ErrorMessage = #Results > 0 and table.remove(Results, 1) or "Unknown Error"
		Description = Format("```\n%s\n```", ErrorMessage)

		Message = Message:WithAuthor()
							:WithName("Runtime Error")
							:End()
						:WithDescription(Description)
						:WithColorRGB(255, 0, 0)
						:End()

		relay.conn.SendWebhookMessage(ChannelID, Message)

		return
	end

	if #Results <= 0 then
		Description = Format("```\n%s\n```", Lua)
		Message = Message:WithAuthor()
							:WithName("Ran LUA")
							:End()
						:WithDescription(Description)
						:WithColorRGB(0, 255, 0)
						:End()

		relay.conn.SendWebhookMessage(ChannelID, Message)

		return
	end

	for i = 1, #Results do
		-- LuaLS retardation moment
		Results[i] = tostring(Results[i])
	end

	local RuntimeResults = table.concat(Results, ", ")

	Description = Format("```\n%s\n```", RuntimeResults)
	Message = Message:WithAuthor()
						:WithName("Ran LUA")
						:End()
					:WithDescription(Description)
					:WithColorRGB(0, 255, 0)
					:End()

	relay.conn.SendWebhookMessage(ChannelID, Message)
end)
