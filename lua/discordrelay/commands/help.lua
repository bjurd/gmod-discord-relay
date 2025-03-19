local function ConvertCommandList(List)
	local CommandListStr = ""

	for Command, Data in SortedPairs(List) do
		CommandListStr = Format(";%s - %s\n%s", Command, Data.Description or "No description.", CommandListStr)
	end

	return string.Trim(CommandListStr)
end

DiscordRelay.Commands.RegisterCommand("help", "Shows the list of Discord commands.", DiscordRelay.Enums.CommandPermissionLevels.ALL_USERS, function(Author, Member, Arguments)
	DiscordRelay.Util.WebhookAutoSend({
		["username"] = "Relay Help",
		["embeds"] = {
			DiscordRelay.Util.CreateEmbed(
				Color(255, 255, 0),
				"Command List",
				ConvertCommandList(DiscordRelay.Commands.List)
			),

			DiscordRelay.Util.CreateEmbed(
				Color(255, 255, 0),
				"Alias List",
				ConvertCommandList(DiscordRelay.Commands.AliasList)
			)
		}
	})
end)
