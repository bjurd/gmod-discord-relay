gameevent.Listen("player_disconnect")
hook.Add("player_disconnect", "DiscordRelay::OnDisconnect", function(Data)
	local SteamID = Data.networkid
	local SteamID64 = util.SteamIDTo64(SteamID)
	local Username = Data.name
	local Reason = Data.reason

	Reason = string.Left(Reason, 256)
	Reason = relay.util.MarkdownEscape(Reason)

	local Description = Format("%s disconnected (%s)", relay.util.MarkdownEscape(Username), Reason)

	local Message = discord.messages.Begin()
		:WithUsername(discord.strings.CleanUsername(Username))
		:WithEmbed()
			:WithAuthor()
				:WithName(SteamID)
				:End()
			:WithDescription(Description)
			:WithColorRGB(255, 0, 0)
			:End()

	relay.steam.GetSteamAvatar(SteamID64, function(AvatarURL) -- See connect.lua for the reason
		Message = Message:WithAvatar(AvatarURL)

		relay.conn.BroadcastWebhookMessage(Message)
	end)
end)
