local PrefixColor = Color(114, 137, 218, 255)

net.Receive("DiscordRelay::Message", function()
	local Color = net.ReadColor(false)
	local Username = net.ReadString()
	local Content = net.ReadString()

	chat.AddText(PrefixColor, "[Discord] ", Color, Username, color_white, ": ", Content)
end)
