hook.Add("DiscordRelay::DispatchEvent", "SendOnlineMessage", function(Event, Socket)
	if Event ~= "READY" then return end

	local Message = discord.messages.Begin()
		:WithEmbed()
			:WithTitle(GetHostName())
			:WithDescription("Server is now online!")
			:WithFooter()
				:WithText(Format("IP Address: %s", game.GetIPAddress()))
				:End()
			:WithColorRGB(0, 255, 0)
			:End()

	relay.conn.BroadcastMessage(Message)

	discord.roles.GetGuildRoles(relay.conn.Instance, "1138420436397473852", function(Roles)
		for i = 1, #Roles do
			local Role = Roles[i]
			print(i, Role, Role:HasPermission(PERMISSION_ADMINISTRATOR))
		end
	end)
end)
