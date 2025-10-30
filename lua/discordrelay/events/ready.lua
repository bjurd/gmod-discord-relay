local Readied = false

hook.Add("DiscordRelay::DispatchEvent", "DEFAULT::SendOnlineMessage", function(Event, Socket)
	if Event ~= "READY" then return end

	if Readied then
		return
	else
		Readied = true
	end

	local Footer = Format("IP Address: %s", game.GetIPAddress())

	local Message = discord.messages.Begin()
		:WithUsername("Server Status")
		:WithEmbed()
			:WithTitle(GetHostName())
			:WithDescription("Server is now online!")
			:WithFooter()
				:WithText(Footer)
				:End()
			:WithColorRGB(0, 255, 0)
			:End()

	relay.conn.BroadcastWebhookMessage(Message)
end)
