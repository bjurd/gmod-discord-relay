hook.Add("DiscordRelay::DispatchEvent", "SendOnlineMessage", function(Event, Socket)
	if Event ~= "READY" then return end

	local Message = discord.messages.BeginMessage()
		:WithEmbed()
			:WithTitle(GetHostName())
			:WithDescription("Server is now online!")
			:WithFooter(Format("IP Address: %s", game.GetIPAddress()))
			:WithColorRGB(0, 255, 0)
			:End()

	relay.conn.BroadcastMessage(Message)
end)
