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
		:WithUsername(NewName)
		:WithEmbed()

	if IsValid(Player) then
		Message = Message:WithAuthor()
					:WithName(Player:SteamID())
					:End()
	end

	Message = Message:WithDescription(Description)
				:WithColorRGB(255, 150, 0)
				:End()

	relay.conn.BroadcastWebhookMessage(Message)
end)
