local Blurple = Color(88, 101, 242, 255)

net.Receive("DiscordRelay::ChatMessage", function()
	local NameColor = net.ReadColor(false)
	local Username = net.ReadString()
	local Content = net.ReadString()

	chat.AddText(Blurple, "[Discord] ", NameColor, Username, color_white, ": ", Content)
end)
