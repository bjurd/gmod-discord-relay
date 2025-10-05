hook.Add("OnLuaError", "DiscordRelay::ErrorLog", function(Message, Realm, Stack, Addon, AddonID)
	Addon = Addon or "ERROR"

	local ErrorMessage = Format("[%s] %s\n", Addon, Message)

	for i = 1, #Stack do
		local Info = Stack[i]

		local FileName = relay.util.IsNonEmptyStr(Info.File) and Info.File or "unknown"
		local FunctionName = relay.util.IsNonEmptyStr(Info.Function) and Info.Function or "unknown"
		local LineNumber = tonumber(Info.Line) or -1

		ErrorMessage = Format("%s  %s%d. %s - %s:%s\n", ErrorMessage, string.rep(" ", i), i, FunctionName, FileName, LineNumber)
	end

	ErrorMessage = string.Trim(ErrorMessage)
	-- ErrorMessage = relay.util.MarkdownEscape(ErrorMessage) -- This will mess up since it's in a code block

	local Description = Format("```\n%s\n```", ErrorMessage)

	local Message = discord.messages.Begin()
		:WithUsername("Lua Error")
		:WithEmbed()
			:WithAuthor()
				:WithName("Lua Error")
				:End()
			:WithDescription(Description)
			:WithColorRGB(255, 0, 0)
			:End()

	relay.conn.BroadcastWebhookMessage(Message, "ErrorLog")
end)
