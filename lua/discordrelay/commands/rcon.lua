DiscordRelay.Commands.RegisterCommand("rcon", DiscordRelay.Enums.CommandPermissionLevels.STAFF_ONLY, function(Author, Member, Arguments)
	local Command = Arguments[1]
	if not isstring(Command) then return end

	if IsConCommandBlocked(Command) then return end

	RunConsoleCommand(unpack(Arguments))
end)
