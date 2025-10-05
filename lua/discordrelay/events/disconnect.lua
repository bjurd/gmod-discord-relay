gameevent.Listen("player_disconnect")
hook.Add("player_disconnect", "DiscordRelay::OnDisconnect", function(Data)
	local SteamID = Data.networkid
	local Username = Data.name
	local Reason = Data.reason

	-- Footers are technically limited to 2048 characters,
	-- but 32 is more than enough for normal disconnect messages
	Reason = string.Left(Reason, 32)
	Reason = relay.util.MarkdownEscape(Reason)
	-- Reason cleansing process is the same as relay.util.CleanUsername's

	local Description = Format("%s disconnected (%s)", relay.util.CleanUsername(Username), Reason)

	local Message = discord.messages.Begin()
		:WithUsername(relay.util.LimitUsername(Username))
		:WithEmbed()
			:WithTitle(SteamID)
			:WithDescription(Description)
			:WithColorRGB(255, 0, 0)
			:End()

	relay.conn.BroadcastWebhookMessage(Message)
end)
