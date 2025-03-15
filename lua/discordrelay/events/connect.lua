-- Not a normal event but 2bad2sad

gameevent.Listen("player_connect")
hook.Add("player_connect", "DiscordRelay::OnConnect", function(Data)
	local SteamID = Data.networkid
	local Username = Data.name

	if DiscordRelay.Config.FilterUsernames then
		Username = DiscordRelay.Util.ASCIIFilter(Username)
	end

	DiscordRelay.Util.WebhookAutoSend({
		["username"] = string.Left(Username, 32),
		["embeds"] = {
			DiscordRelay.Util.CreateConnectEmbed(SteamID, Username)
		}
	}, util.SteamIDTo64(SteamID))
end)
