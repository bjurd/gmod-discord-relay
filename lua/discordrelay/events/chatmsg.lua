gameevent.Listen("player_say")
hook.Add("player_say", "DiscordRelay::ReadChat", function(Data)
	local Content = Data.text
	if string.len(Content) < 1 then return end -- Should never happen unless someone's doing something dumb

	local UserID = Data.userid
	local Player = Player(UserID)

	Content = relay.util.MarkdownEscape(Content)

	local Message = discord.messages.Begin()
		:WithContent(Content)

	relay.conn.BroadcastPlayerMessage(Player, Message)
end)
