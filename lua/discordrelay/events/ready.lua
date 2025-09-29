hook.Add("DiscordRelay::DispatchEvent", "SendOnlineMessage", function(Event, Socket)
	if Event ~= "READY" then return end

	local Message = discord.messages.BeginMessage()
		:WithContent("testing testing 123")
		:WithEmbed()
			:WithTitle("is this thing on?")
			:WithDescription("heelllo world this is a super duper ultra crazy mega bonkers long piece of text because it's in the description it can be like that hurray")
			:WithFooter("hahawhawhahawhawhawhawhawhawhaw")
			:WithColor(color_white)
			:End()
		:WithEmbed()
			:WithDescription("more than 1 (one)?")
			:WithColorRGB(255, 0, 0)
			:End()

	discord.messages.SendToChannel(Socket, "1139040735358881923", Message)
end)
