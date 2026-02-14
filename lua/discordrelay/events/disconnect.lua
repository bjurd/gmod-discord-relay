gameevent.Listen("player_disconnect")
hook.Add("player_disconnect", "DiscordRelay::OnDisconnect", function(Data)
	local SteamID = Data.networkid
	local SteamID64 = util.SteamIDTo64(SteamID)
	local Username = Data.name
	local Reason = Data.reason

	-- Footers are technically limited to 2048 characters,
	-- but 256 is more than enough for normal disconnect messages
	Reason = string.Left(Reason, 256)
	Reason = relay.util.MarkdownEscape(Reason)
	-- Reason cleansing process is the same as relay.util.CleanUsername's

	local Description = Format("%s disconnected (%s)", relay.util.CleanUsername(Username), Reason)

	local Message = discord.messages.Begin()
		:WithUsername(relay.util.CleanUsername(Username))
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
