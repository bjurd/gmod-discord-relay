DiscordRelay.Commands = DiscordRelay.Commands or {}

DiscordRelay.Commands.List = DiscordRelay.Commands.List or {}

function DiscordRelay.Commands.RegisterCommand(Name, Callback)
	DiscordRelay.Commands.List[Name] = Callback
end

function DiscordRelay.Commands.TryRunCommand(Author, Member, Content)
	if not DiscordRelay.Config.EnableCommands then return false end
	if not string.StartsWith(Content, DiscordRelay.Config.CommandPrefix) then return false end

	-- TODO: DiscordRelay.Config.StaffRoles
	-- TODO: DiscordRelay.Config.AdminsAreStaff

	local CommandStr = string.sub(Content, string.len(DiscordRelay.Config.CommandPrefix) + 1)

	local Arguments = string.Split(CommandStr, " ")
	local CommandName = table.remove(Arguments, 1)
	if not isstring(CommandName) or string.len(CommandName) < 1 then return false end

	local CommandCallback = DiscordRelay.Commands.List[CommandName]
	if not isfunction(CommandCallback) then return false end

	CommandCallback(Author, Member, Arguments)
end

DiscordRelay.Util.IncludeFromFolder("commands")
