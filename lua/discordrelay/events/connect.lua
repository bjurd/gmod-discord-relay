gameevent.Listen("player_connect")
hook.Add("player_connect", "DiscordRelay::OnConnect", function(Data)
	local SteamID = Data.networkid
	local Username = Data.name

	local Description = Format("%s connected", relay.util.CleanUsername(Username))

	local Message = discord.messages.Begin()
		:WithUsername(relay.util.LimitUsername(Username)) -- Usernames don't need filtered here
		:WithEmbed()
			:WithAuthor()
				:WithName(SteamID)
				:End()
			:WithDescription(Description)
			:WithColorRGB(0, 255, 0)
			:End()

	relay.conn.BroadcastWebhookMessage(Message)
end)
