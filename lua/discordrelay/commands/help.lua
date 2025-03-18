DiscordRelay.Commands.RegisterCommand("help", "Shows the list of Discord commands.", DiscordRelay.Enums.CommandPermissionLevels.ALL_USERS, function(Author, Member, Arguments)
	local CommandListStr = ""

	for Command, Data in SortedPairs(DiscordRelay.Commands.List) do
		CommandListStr = Format(";%s - %s\n%s", Command, Data.Description or "No description.", CommandListStr)
	end

	CommandListStr = string.Trim(CommandListStr)

	DiscordRelay.Util.WebhookAutoSend({
		["username"] = "Relay Help",
		["embeds"] = {
			DiscordRelay.Util.CreateEmbed(
				Color(255, 255, 0),
				"Command List",
				CommandListStr
			)
		}
	})
end)
