net.Receive("DiscordRelay::ChatMessage", function()
	local Color = net.ReadColor(false)
	local Username = net.ReadString()
	local Content = net.ReadString()

	chat.AddText(Color, Username, color_white, ": ", Content)
end)
