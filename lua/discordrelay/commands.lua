DiscordRelay.Commands = DiscordRelay.Commands or {}

DiscordRelay.Commands.List = DiscordRelay.Commands.List or {}

DiscordRelay.Commands.AliasList = DiscordRelay.Commands.AliasList or {}

function DiscordRelay.Commands.RegisterCommand(Name, Description, PermissionLevel, Callback)
	if istable(DiscordRelay.Commands.List[Name]) then
		ErrorNoHaltWithStack(Format("Overwriting relay command %s!", Name))
	end

	DiscordRelay.Commands.List[Name] = {}
	DiscordRelay.Commands.List[Name].Description = string.Trim(Description)
	DiscordRelay.Commands.List[Name].PermissionLevel = PermissionLevel
	DiscordRelay.Commands.List[Name].Callback = Callback
end

function DiscordRelay.Commands.RegisterAlias(Name, Alias)
	if not istable(DiscordRelay.Commands.List[Name]) then
		error(Format("Tried to alias non-existence command %s as %s", Name, Alias))
		return
	end

	DiscordRelay.Commands.AliasList[Alias] = DiscordRelay.Commands.List[Name]
end

function DiscordRelay.Commands.MemberIsStaff(Member)
	if not istable(Member.roles) then return false end

	local StaffRoleCount = #DiscordRelay.Config.StaffRoles
	local MemberRoleCount = #Member.roles

	for i = 1, StaffRoleCount do -- -rep
		for j = 1, MemberRoleCount do
			if Member.roles[j] == DiscordRelay.Config.StaffRoles[i] then
				return true
			end
		end
	end

	-- TODO: DiscordRelay.Config.AdminsAreStaff

	return false
end

function DiscordRelay.Commands.TryRunCommand(Author, Member, Content)
	if not DiscordRelay.Config.EnableCommands then return end
	if not string.StartsWith(Content, DiscordRelay.Config.CommandPrefix) then return end

	local CommandStr = string.sub(Content, string.len(DiscordRelay.Config.CommandPrefix) + 1)

	local Arguments = string.Split(CommandStr, " ")
	local CommandName = table.remove(Arguments, 1)
	if not isstring(CommandName) or string.len(CommandName) < 1 then return end

	local CommandData = DiscordRelay.Commands.List[CommandName] or DiscordRelay.Commands.AliasList[CommandName]
	if not istable(CommandData) then return end

	local PermissionLevel = CommandData.PermissionLevel
	local Callback = CommandData.Callback
	if not isnumber(PermissionLevel) or not isfunction(Callback) then return end

	if PermissionLevel == DiscordRelay.Enums.CommandPermissionLevels.STAFF_ONLY then
		if DiscordRelay.Commands.MemberIsStaff(Member) then
			goto RunCommand
		else
			return
		end
	end

	::RunCommand::
	Callback(Author, Member, Arguments)
end

DiscordRelay.Util.IncludeFromFolder("commands")
