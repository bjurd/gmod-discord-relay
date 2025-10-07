local MaxFieldValue = 1024 - 11 -- See EmbedField.lua, -11 for the ```lua\n\n```

relay.commands.Register("lua", PERMISSION_ADMINISTRATOR, function(Socket, Data, Args)
	local ChannelID = Data.channel_id
	local Writeable = relay.conn.IsChannel(ChannelID, "Write") -- See rcon.lua

	local Lua = table.concat(Args, " ")
	local LuaFn = CompileString(Lua, "DiscordRelay", false)

	local LuaDesc = Format("```lua\n%s\n```", string.Left(Lua, MaxFieldValue))
	local ResultDesc = "```lua\n%s\n```"

	local Message = discord.messages.Begin()
		:WithUsername("LUA")

	local Embed = Message:WithEmbed()
	local EmbedAuthor = Embed:WithAuthor()

	local LuaField = Embed:WithField()
						:WithName("Lua")
						:WithValue(LuaDesc)

	local ResultField = Embed:WithField()
						:WithName("Results")

	if isstring(LuaFn) then
		if Writeable then
			ResultDesc = Format(ResultDesc, string.Left(LuaFn, MaxFieldValue)) -- LuaLS sucks :/

			Embed = Embed:WithColorRGB(255, 0, 0)
			EmbedAuthor = EmbedAuthor:WithName("Compilation Error")

			ResultField = ResultField:WithValue(ResultDesc)
			Embed:End()

			relay.conn.SendWebhookMessage(ChannelID, Message)
		end

		return
	end

	local Results = { pcall(LuaFn) }
	if not Writeable then return end -- pcall ran it, so if we can't give feedback who cares what it's just done

	local Status = table.remove(Results, 1)

	if Status ~= true then
		local ErrorMessage = (#Results > 0) and table.remove(Results, 1) or "Unknown Error"
		ResultDesc = Format(ResultDesc, string.Left(ErrorMessage, MaxFieldValue))

		Embed = Embed:WithColorRGB(255, 0, 0)
		EmbedAuthor = EmbedAuthor:WithName("Runtime Error")
	else
		Embed = Embed:WithColorRGB(0, 255, 0)
		EmbedAuthor = EmbedAuthor:WithName("Ran LUA")

		if #Results > 0 then
			for i = 1, #Results do
				-- LuaLS retardation moment
				Results[i] = tostring(Results[i])
			end

			local RuntimeResults = table.concat(Results, ", ")
			ResultDesc = Format(ResultDesc, string.Left(RuntimeResults, MaxFieldValue))
		else
			ResultDesc = Format(ResultDesc, "No values returned")
		end
	end

	ResultField = ResultField:WithValue(ResultDesc)
	Embed:End()

	relay.conn.SendWebhookMessage(ChannelID, Message)
end)
