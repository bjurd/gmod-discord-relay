-- Not a normal event but 2bad2sad

gameevent.Listen("player_disconnect")
hook.Add("player_disconnect", "DiscordRelay::OnDisconnect", function(Data)
	local SteamID = Data.networkid
	local Username = Data.name
	local Reason = Data.reason

	if DiscordRelay.Config.FilterUsernames then
		Username = DiscordRelay.Util.ASCIIFilter(Username)
	end

	Reason = DiscordRelay.Util.ASCIIFilter(Reason)

	DiscordRelay.Util.GetWebhook(function(MessageURL)
		DiscordRelay.Util.SendWebhookMessage(MessageURL, {
			["username"] = string.Left(Username, 32),
			["embeds"] = {
				DiscordRelay.Util.CreateDisconnectEmbed(SteamID, Username, Reason)
			}
		})
	end)
end)
