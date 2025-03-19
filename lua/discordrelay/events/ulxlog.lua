if not istable(ulx) or not isfunction(ulx.logWriteln) then return end

DiscordRelay.Detours.Destroy(ulx.logWriteln)

ulx.logWriteln = DiscordRelay.Detours.Setup(ulx.logWriteln, function(Log)
	if isstring(DiscordRelay.Config.LogChannelID) and string.len(DiscordRelay.Config.LogChannelID) > 0 then
		DiscordRelay.Util.GetWebhook(DiscordRelay.Config.LogChannelID, function(MessageURL)
			DiscordRelay.Util.SendWebhookMessage(MessageURL, {
				["username"] = "ULX Log",
				["embeds"] = {
					DiscordRelay.Util.CreateEmbed(
						Color(0, 150, 255),
						nil,
						Log
					)
				}
			})
		end)
	end

	return __Original(Log)
end)
