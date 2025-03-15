-- Not a normal event but 2bad2sad

gameevent.Listen("player_connect")
hook.Add("player_connect", "DiscordRelay::OnConnect", function(Data)
	local SteamID = Data.networkid
	local Username = Data.name

	if DiscordRelay.Config.FilterUsernames then
		Username = DiscordRelay.Util.ASCIIFilter(Username)
		Username = DiscordRelay.Util.MarkdownEscape(Username)
	end

	local Description = Format("%s connected", Username)

	DiscordRelay.Util.WebhookAutoSend({
		["username"] = string.Left(Username, 32),
		["embeds"] = {
			DiscordRelay.Util.CreateEmbed(Color(0, 255, 0), SteamID, Description)
		}
	}, util.SteamIDTo64(SteamID))
end)
