hook.Add("OnLuaError", "DiscordRelay::OnLuaError", function(Message, Realm, Stack, Addon, AddonID)
	if isstring(DiscordRelay.Config.ErrorChannelID) and string.len(DiscordRelay.Config.ErrorChannelID) > 0 then
		local ErrorMessage = Format("[%s] %s", Addon or "ERROR", Message)

		if #Stack > 1 then
			ErrorMessage = ErrorMessage .. "\n"
		end

		for i = 1, #Stack do
			local Info = Stack[i]

			local FileName = isstring(Info.File) and (string.len(Info.File) > 0 and Info.File or "unknown") or "unknown"
			local FunctionName = isstring(Info.Function) and (string.len(Info.Function) > 0 and Info.Function or "unknown") or "unknown"
			local LineNumber = tonumber(Info.Line) or -1

			ErrorMessage = Format("%s  %s%d. %s - %s:%s\n", ErrorMessage, string.rep(" ", i), i, FunctionName, FileName, LineNumber)
		end

		ErrorMessage = string.Trim(ErrorMessage)

		DiscordRelay.Util.GetWebhook(DiscordRelay.Config.ErrorChannelID, function(MessageURL)
			DiscordRelay.Util.SendWebhookMessage(MessageURL, {
				["username"] = "Lua Error",
				["embeds"] = {
					DiscordRelay.Util.CreateEmbed(
						Color(255, 0, 0),
						"Lua Error",
						Format("```\n%s\n```", ErrorMessage)
					)
				}
			})
		end)
	end
end)
