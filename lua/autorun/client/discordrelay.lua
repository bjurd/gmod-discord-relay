local Blurple = Color(88, 101, 242, 255)

net.Receive("DiscordRelay::ChatMessage", function()
	local MessageData = net.ReadTable(true)

	if #MessageData < 1 then
		-- Should never happen
		ErrorNoHaltWithStack("Got a bad message from the Discord Relay, tell the server admens to get it together!")
		return
	end

	chat.AddText(Blurple, "[Discord] ", unpack(MessageData))
end)
