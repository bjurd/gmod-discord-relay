DiscordRelay.Commands.RegisterCommand("lua", DiscordRelay.Enums.CommandPermissionLevels.STAFF_ONLY, function(Author, Member, Arguments)
	local Lua = table.concat(Arguments, " ")
	if not isstring(Lua) or string.len(Lua) < 1 then return end

	RunString(Lua, "DiscordRelay")
end)
