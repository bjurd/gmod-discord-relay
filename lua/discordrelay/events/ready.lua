hook.Add("DiscordRelay::DispatchEvent", "DEFAULT::SendOnlineMessage", function(Event, Socket)
	if Event ~= "READY" then return end

	local Message = discord.messages.Begin()
		:WithUsername("Server Status")
		:WithEmbed()
			:WithTitle(GetHostName())
			:WithDescription("Server is now online!")
			:WithFooter()
				:WithText(Format("IP Address: %s", game.GetIPAddress()))
				:End()
			:WithColorRGB(0, 255, 0)
			:End()

	relay.conn.BroadcastWebhookMessage(Message)
end)
