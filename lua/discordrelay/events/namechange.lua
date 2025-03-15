-- Not a normal event but 2bad2sad

gameevent.Listen("player_changename")
hook.Add("player_changename", "DiscordRelay::OnNameChange", function(Data)
	local Player = Player(Data.userid)
	if not IsValid(Player) then return end

	local OldName = Data.oldname
	local NewName = Data.newname

	if DiscordRelay.Config.FilterUsernames then
		OldName = DiscordRelay.Util.ASCIIFilter(OldName)
		OldName = DiscordRelay.Util.MarkdownEscape(OldName)

		NewName = DiscordRelay.Util.ASCIIFilter(NewName)
		NewName = DiscordRelay.Util.MarkdownEscape(NewName)
	end

	local Description = Format("%s has changed their name to %s", OldName, NewName)

	DiscordRelay.Util.WebhookAutoSend({
		["username"] = string.Left(NewName, 32),
		["embeds"] = {
			DiscordRelay.Util.CreateEmbed(Color(0, 0, 255), Player:SteamID(), Description)
		}
	}, Player:SteamID64())
end)
