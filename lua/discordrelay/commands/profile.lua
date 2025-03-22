DiscordRelay.Commands.RegisterCommand("profile", "Links to a user's steam profile", DiscordRelay.Enums.CommandPermissionLevels.ALL_USERS, function(Author, Member, Arguments)
	local Username = Arguments[1]
	if not isstring(Username) then return end

	local Target = DiscordRelay.Util.FindPlayer(Username)

	if not IsValid(Target) then
		DiscordRelay.Util.WebhookAutoSend({
			["username"] = "User Profile",
			["content"] = "No target found!"
		})

		return
	end

	Username = Target:GetName()

	if DiscordRelay.Config.FilterUsernames then
		Username = DiscordRelay.Util.ASCIIFilter(Username)
	end

	DiscordRelay.Util.WebhookAutoSend({
		["username"] = string.Left(Username, 32),
		["embeds"] = {
			DiscordRelay.Util.CreateEmbed(
				Color(0, 255, 0),
				Format("Profile of %s", Username),
				Format("https://steamcommunity.com/profiles/%s", Target:SteamID64())
			)
		}
	}, Target:SteamID64())
end)
