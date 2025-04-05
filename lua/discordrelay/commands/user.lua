DiscordRelay.Commands.RegisterCommand("user", "Gets information about an online user", DiscordRelay.Enums.CommandPermissionLevels.ALL_USERS, function(Author, Member, Arguments)
	local Username = Arguments[1]
	if not isstring(Username) then return end

	local Target = DiscordRelay.Util.FindPlayer(Username)

	if not IsValid(Target) then
		if DiscordRelay.Config.FilterUsernames then
			Username = DiscordRelay.Util.ASCIIFilter(Username)
		end

		DiscordRelay.Util.WebhookAutoSend({
			["username"] = "User Profile",
			["embeds"] = {
				DiscordRelay.Util.CreateEmbed(
					Color(255, 0, 0),
					"Target Not Found",
					Format("Target %s could not be found", Username)
				)
			}
		})

		return
	end

	Username = Target:GetName()
	local SteamName = Target:Name() -- TODO: Steam API
	local NickName = Target:Nick()

	if DiscordRelay.Config.FilterUsernames then
		Username = DiscordRelay.Util.ASCIIFilter(Username)

		SteamName = DiscordRelay.Util.ASCIIFilter(SteamName)
		SteamName = DiscordRelay.Util.MarkdownEscape(SteamName)
		NickName = DiscordRelay.Util.ASCIIFilter(NickName)
		NickName = DiscordRelay.Util.MarkdownEscape(NickName)
	end



	local Information = Format(
		"Steam ID: %s\nSteam ID64: %s\nProfile: %s\nConnection Time: %s\n\nUsername: %s\nSteam Name: %s\nNick Name: %s",

		Target:SteamID(),
		Target:SteamID64(),
		Format("https://steamcommunity.com/profiles/%s", Target:SteamID64()),
		string.NiceTime(Target:TimeConnected()),

		Username,
		SteamName,
		NickName
	)

	DiscordRelay.Util.WebhookAutoSend({
		["username"] = string.Left(Username, 32),
		["embeds"] = {
			DiscordRelay.Util.CreateEmbed(
				Color(0, 255, 0),
				Format("Information of %s", Username),
				Information
			)
		}
	}, Target:SteamID64())
end)
