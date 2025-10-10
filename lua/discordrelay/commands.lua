relay.commands = relay.commands or {}
local commands = relay.commands

commands.List = commands.List or {}



commands.Meta = commands.Meta or {}
--- @class Command
--- @field Name string
--- @field Description string
--- @field Permissions number
--- @field PermissionExplicit boolean
--- @field Callback function|nil
local COMMAND = commands.Meta
COMMAND.__index = COMMAND

function COMMAND:__new()
	self.Name = ""
	self.Description = ""
	self.Permissions = PERMISSION_NONE
	self.PermissionExplicit = false
	self.Callback = nil
end

--- @param Name string Converted to lowercase and trimmed
--- @return Command self
function COMMAND:WithName(Name)
	Name = string.lower(Name)
	Name = string.Trim(Name)

	self.Name = Name

	return self
end

--- @param Description string Trimmed
--- @return Command self
function COMMAND:WithDescription(Description)
	Description = string.Trim(Description)

	self.Description = Description
	return self
end

--- @param Permissions number
--- @return Command self
function COMMAND:WithPermissions(Permissions)
	self.Permissions = Permissions
	return self
end

--- @param State boolean
--- @return Command self
function COMMAND:WithPermissionsExplicit(State)
	self.PermissionExplicit = State
	return self
end

--- @param Callback function
--- @return Command self
function COMMAND:WithCallback(Callback)
	self.Callback = Callback
	return self
end

--- @param Socket WEBSOCKET
--- @param Data table
--- @param Args table
function COMMAND:Fire(Socket, Data, Args)
	discord.logging.DevLog(LOG_SUCCESS, "Firing command %s", self.Name)

	-- TODO: Pass self?
	self.Callback(Socket, Data, Args)
end

--- @param Role Role
--- @return boolean
function COMMAND:RolePermitted(Role)
	local Permissions = self.Permissions
	if Permissions <= PERMISSION_NONE then return true end -- Command has no restrictions

	local RolePermissions = Role:GetPermissionValue()
	if discord.bigint.IsBitflagSet(RolePermissions, PERMISSION_ADMINISTRATOR) then return true end -- Admins bypass
	if discord.bigint.IsBitflagSet(RolePermissions, Permissions) then return true end -- Base check
	if self.PermissionExplicit then return false end -- Command's permissions can't be extended

	local ExtraPermissions = relay.config.commands.permissions[Role:GetID()]
	if not ExtraPermissions then return false end -- Nothing added from the config

	local AddHi, AddLo = discord.bigint.AddBitflag(RolePermissions, ExtraPermissions)
	RolePermissions = discord.bigint.Combine(AddHi, AddLo)

	if discord.bigint.IsBitflagSet(RolePermissions, Permissions) then return true end -- Extra stuff from the config

	return false -- Not allowed!
end





--- Begins a new command number
--- @return Command
function commands.New()
	return discord.oop.CreateFrom(COMMAND)
end

--- Adds a command to the DiscordRelay::FireCommand hook group
--- @param Command Command
function commands.Register(Command)
	-- Who needs getters when you have swag B-)
	local Name = Command.Name
	commands.List[Name] = Command

	discord.logging.DevLog(LOG_SUCCESS, "Registered command %s", Name)
end

--- Fires command callbacks, used internally by commands.Process
--- @param Command Command
--- @param Socket WEBSOCKET
--- @param Data table
--- @param Args table
function commands.Fire(Command, Socket, Data, Args)
	discord.logging.DevLog(LOG_SUCCESS, "Firing command %s", Name)
	Command:Fire(Socket, Data, Args)
end

--- Processes and fires command callbacks for the given name if it exists
--- @param Name string
--- @param Socket WEBSOCKET
--- @param Data table
--- @param Args table
function commands.Process(Name, Socket, Data, Args)
	local Command = commands.List[Name]

	if not Command then
		discord.logging.DevLog(LOG_ERROR, "Tried to fire non-existent command %s", Name)
		return
	end

	local User = discord.oop.ConstructNew("User", Data.author)

	if User:IsBot() then
		discord.logging.DevLog(LOG_ERROR, "Bot user tried to run command %s", Name)
		return
	end

	if Command.Permissions <= PERMISSION_NONE then
		-- Don't bother checking role information if the command is unrestricted
		Command:Fire(Socket, Data, Args)
		return
	end

	local Member = discord.oop.ConstructNew("Member", Data.member)

	discord.roles.GetGuildRoles(Socket, Data.guild_id, function(Roles)
		local MemberRoles = Member:GetRoles()

		for i = 1, #Roles do
			local Role = Roles[i]

			if table.HasValue(MemberRoles, Role:GetID()) and Command:RolePermitted(Role) then
				Command:Fire(Socket, Data, Args)
				return
			end
		end

		-- TODO: Tell the user they don't have permission? May be a bad idea for rate limiting reasons
		discord.logging.DevLog(LOG_WARNING, "Tried to run command %s with no permission", Name)
	end)
end
