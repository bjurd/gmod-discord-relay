local Status = relay.commands.New()
	:WithName("status")
	:WithDescription("Shows information about the server")
	:WithCallback(function(Socket, Data, Args)
		local ChannelID = Data.channel_id
		if not relay.conn.IsChannel(ChannelID, "write") then return end

		local Hostname = GetHostName()
		local IP = game.GetIPAddress()
		local Gamemode = gmod.GetGamemode().Name
		local Map = game.GetMap()
		local MapRevision, MapFormat = game.GetMapVersion()
		local PlayerCount = player.GetCount() + player.GetCountConnecting()
		local MaxPlayers = game.MaxPlayers()
		local OnlineTime = relay.util.FormatTime(RealTime())
		local MapTime = relay.util.FormatTime(CurTime())

		local Version = tostring(VERSION)
		local VersionStr = VERSIONSTR

		local Branch = BRANCH or "Unknown"
		if Branch == "unknown" then
			Branch = "main"
		end

		local Description = Format(
			"**IP**: %s\n**Gamemode**: %s\n**Map**: %s (v%d, f%d)\n**Player Count**: %d / %d\n\n**Uptime**: %s\n**Map Time**: %s\n\n**Version**: %s (%s)\n**Branch**: %s\n",

			IP,
			Gamemode,
			Map,
			MapRevision or 0,
			MapFormat or 0,
			PlayerCount,
			MaxPlayers,

			OnlineTime,
			MapTime,

			VersionStr,
			Version,
			Branch
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

relay.commands.Register(Status)
