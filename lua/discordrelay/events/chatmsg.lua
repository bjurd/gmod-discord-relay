gameevent.Listen("player_say")
hook.Add("player_say", "DiscordRelay::ReadChat", function(Data)
	local Content = Data.text
	if string.len(Content) < 1 then return end -- Should never happen unless someone's doing something dumb

	local UserID = Data.userid
	local Username = "Console"

	if UserID ~= 0 then
		local Player = Player(UserID)

		if Player:IsValid() then
			Username = Player:Nick()
		else
			-- Should never happen
			Username = "Unknown Player"

			discord.logging.Log(LOG_ERROR, "Got an unkown player in player_say - uid %d", UserID)
		end
	end

	Username = relay.util.LimitUsername(Username)
	Content = relay.util.MarkdownEscape(Content)

	-- TODO: Webhook
	local Message = discord.messages.Begin()
		:WithUsername(Username)
		:WithContent(Content)

	relay.conn.BroadcastWebhookMessage(Message)
end)
