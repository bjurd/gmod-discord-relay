net.Receive("DiscordRelay::Message", function()
	local Username = net.ReadString()
	local Content = net.ReadString()

	chat.AddText(Username, ": ", Content)
end)
