local function SortPlayers(A, B)
	return A:SteamID() < B:SteamID()
end

DiscordRelay.Commands.RegisterCommand("players", "Shows the currently connected players.", DiscordRelay.Enums.CommandPermissionLevels.ALL_USERS, function(Author, Member, Arguments)
	local Players = player.GetAll()

	if #Players < 1 then
		DiscordRelay.Util.WebhookAutoSend({
			["username"] = "Player List",
			["embeds"] = {
				DiscordRelay.Util.CreateEmbed(
					Color(255, 0, 0),
					"Player List",
					"There are no players online!"
				)
			}
		})

		return
	end

	table.sort(Players, SortPlayers)

	for i = 1, #Players do
		local Player = Players[i]

		local Username = Player:GetName()
		local SteamID = Player:SteamID()

		if DiscordRelay.Config.FilterUsernames then
			Username = DiscordRelay.Util.ASCIIFilter(Username)
		end

		Username = DiscordRelay.Util.MarkdownEscape(Username)
		SteamID = DiscordRelay.Util.MarkdownEscape(SteamID)

		Players[i] = Format("- %s (%s)", Username, SteamID)
	end

	DiscordRelay.Util.WebhookAutoSend({
		["username"] = "Player List",
		["embeds"] = {
			DiscordRelay.Util.CreateEmbed(
				Color(255, 255, 0),
				"Player List",
				table.concat(Players, "\n")
			)
		}
	})
end)
