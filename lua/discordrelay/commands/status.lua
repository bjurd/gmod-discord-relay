relay.commands.Register("status", PERMISSION_NONE, function(Socket, Data, Args)
	local ChannelID = Data.channel_id
	if not relay.conn.IsChannel(ChannelID, "write") then return end

	local Hostname = GetHostName()
	local IP = game.GetIPAddress()
	local Gamemode = gmod.GetGamemode().Name
	local Map = game.GetMap()
	local MapVer = game.GetMapVersion()
	local PlayerCount = player.GetCount()
	local MaxPlayers = game.MaxPlayers()
	local OnlineTime = relay.util.FormatTime(RealTime())
	local MapTime = relay.util.FormatTime(CurTime())

	local Description = Format(
		"**IP**: %s\n**Gamemode**: %s\n**Map**: %s (v%d)\n**Player Count**: %d / %d\n**Uptime**: %s\n**Map Time**: %s",

		IP,
		Gamemode,
		Map,
		MapVer,
		PlayerCount,
		MaxPlayers,
		OnlineTime,
		MapTime
	)

	local Message = discord.messages.Begin()
		:WithUsername("Server Status")
		:WithEmbed()
			:WithAuthor()
				:WithName(Hostname)
				:End()
			:WithDescription(Description)
			:WithColorRGB(255, 150, 0)
			:End()

	relay.conn.SendWebhookMessage(ChannelID, Message)
end)
