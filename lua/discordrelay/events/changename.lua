gameevent.Listen("player_changename")
hook.Add("player_changename", "DiscordRelay::OnNameChange", function(Data)
	local UserID = Data.userid
	local Player = Player(UserID)
	local OldName = Data.oldname
	local NewName = Data.newname

	OldName = relay.util.CleanUsername(OldName)
	NewName = relay.util.CleanUsername(NewName)

	local Description = Format("%s has changed their name to %s", OldName, NewName)

	local Message = discord.messages.Begin()
		:WithEmbed()
			:WithDescription(Description)
			:WithColorRGB(255, 150, 0)

	if IsValid(Player) then
		Message = Message:WithAuthor()
					:WithName(Player:SteamID())
					:End()
				:End()

		-- TODO: This will cause the Message's name to be the Player's old name instead of their new one
		-- because this event fires before the Player's name has actually changed :/
		relay.conn.BroadcastPlayerMessage(Player, Message)

		return
	end

	Message = Message:End()

	relay.conn.BroadcastWebhookMessage(Message)
end)
