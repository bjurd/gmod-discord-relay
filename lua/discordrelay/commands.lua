relay.commands = relay.commands or {}
local commands = relay.commands

commands.List = {} -- Wipe this out every time

--- Adds a command callback to the DiscordRelay::FireCommand hook group
--- @param Name string The name of the command, will be converted to lowercase and trimmed
--- @param Callback function Arguments are the Socket, Data table and arguments table
function commands.Register(Name, Permissions, Callback)
	Name = string.lower(Name)
	Name = string.Trim(Name)

	commands.List[Name] = {
		Name = Name,
		Permissions = Permissions,
		Callback = Callback
	}

	discord.logging.DevLog(LOG_SUCCESS, "Registered command %s", Name)
end

--- Fires command callbacks for the given name if it exists
--- @param Name string
function commands.Process(Name, Socket, Data, Args)
	local CommandData = commands.List[Name]

	if not CommandData then
		discord.logging.DevLog(LOG_ERROR, "Tried to fire non-existent command %s", Name)
		return
	end

	local User = discord.oop.ConstructNew("User", Data.author)

	if User:IsBot() then
		discord.logging.DevLog(LOG_ERROR, "Bot user tried to run command %s", Name)
		return
	end

	local Member = discord.oop.ConstructNew("Member", Data.member)

	discord.roles.GetGuildRoles(Socket, Data.guild_id, function(Roles)
		local MemberRoles = Member:GetRoles()

		for i = 1, #Roles do
			local Role = Roles[i]

			if table.HasValue(MemberRoles, Role:GetID()) and commands.RoleCanRun(Role, CommandData) then
				discord.logging.DevLog(LOG_SUCCESS, "Firing command %s", Name)
				CommandData.Callback(Socket, Data, Args)

				return
			end
		end

		-- TODO: Tell the user they don't have permission? May be a bad idea for rate limiting reasons
		discord.logging.DevLog(LOG_WARNING, "Tried to run command %s with no permission", Name)
	end)
end

--- Tests if a Role is allowed to run a command
--- @param Role Role
--- @param CommandData table
--- @return boolean
function commands.RoleCanRun(Role, CommandData)
	local CommandPermissions = CommandData.Permissions
	if CommandPermissions <= PERMISSION_NONE then return true end -- Command has no restrictions

	local RolePermissions = Role:GetPermissionValue()
	if discord.bigint.IsBitflagSet(RolePermissions, PERMISSION_ADMINISTRATOR) then return true end -- Admins bypass
	if discord.bigint.IsBitflagSet(RolePermissions, CommandPermissions) then return true end -- Base check

	local ExtraPermissions = relay.config.CommandPermissions[Role:GetID()]
	if not ExtraPermissions then return false end -- Nothing added from the config

	local AddHi, AddLo = discord.bigint.AddBitflag(RolePermissions, ExtraPermissions)
	RolePermissions = discord.bigint.Combine(AddHi, AddLo)

	if discord.bigint.IsBitflagSet(RolePermissions, CommandPermissions) then return true end -- Extra stuff from the config

	-- Own
	return false
end
