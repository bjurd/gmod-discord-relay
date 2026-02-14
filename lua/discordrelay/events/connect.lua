gameevent.Listen("player_connect")
hook.Add("player_connect", "DiscordRelay::OnConnect", function(Data)
	local SteamID = Data.networkid
	local SteamID64 = util.SteamIDTo64(SteamID)
	local Username = Data.name

	local Description = Format("%s connected", relay.util.CleanUsername(Username))

	local Message = discord.messages.Begin()
		:WithUsername(discord.strings.CleanUsername(Username))
		:WithEmbed()
			:WithAuthor()
				:WithName(SteamID)
				:End()
			:WithDescription(Description)
			:WithColorRGB(0, 255, 0)
			:End()

	relay.steam.GetSteamAvatar(SteamID64, function(AvatarURL) -- This has to be done manually here because we don't have a Player object
		Message = Message:WithAvatar(AvatarURL)

		relay.conn.BroadcastWebhookMessage(Message)
	end)
end)
