relay.commands = relay.commands or {}
local commands = relay.commands

commands.List = {} -- Wipe this out every time

--- Adds a command callback to the DiscordRelay::FireCommand hook group
--- @param Name string The name of the command, will be converted to lowercase and trimmed
--- @param Callback function Arguments are the Socket, Data table and arguments table
function commands.Register(Name, Callback)
	Name = string.lower(Name)
	Name = string.Trim(Name)

	hook.Add("DiscordRelay::FireCommand", Name, Callback)

	commands.List[Name] = Callback
end

--- Fires command callbacks for the given name if it exists
--- @param Name string
function commands.Process(Name, Socket, Data, Args)
	if not commands.List[Name] then
		discord.logging.DevLog(LOG_ERROR, "Tried to fire non-existent command %s", Name)
		return
	end

	discord.logging.DevLog(LOG_SUCCESS, "Firing command %s", Name)
	hook.Run("DiscordRelay::FireCommand", Socket, Data, Args)
end
