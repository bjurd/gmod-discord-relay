relay.config = relay.config or {}
local config = relay.config

--- Discord API version to use
--- https://discord.com/developers/docs/reference#api-versioning
---
--- See API_ enumerations
config.API = discord.versioning.GetLatestAPI()



--- The token of your Discord bot
--- https://discord.com/developers/applications/(Bot_User_ID)/bot
config.Token = ""



--- Guilds (servers) and Channels where the bot will interact with messages
--- Enable developer mode in Discord to find IDs
--- https://discord.com/developers/docs/activities/building-an-activity#step-0-enable-developer-mode
config.Messages = {
	--[[
	Any number of Guilds and Channels are supported, but note that more guilds and channels and more actions within those Guilds and Channels
	WILL slow the bot down overall due to Discord API ratelimiting

	Format:

	["Guild ID"] = {
		["Channel ID"] = {
			-- Whether or not the bot will relay Discord messages to in-game chat
			-- Default is false
			Read = true/false,

			-- Whether or not the bot will relay in-game messages to this channel
			-- Default is false
			Write = true/false,

			-- Whether or not this channel should be used to relay server log messages to Discord
			-- Default is false
			-- If true this will ignore the "Write" parameter
			AdminLog = true/false,

			-- Whether or not this channel should be used to relay server Lua error messages to Discord
			-- Default is false
			-- If true this will ignore the "Write" parameter
			ErrorLog = true/false
		}
	}

	Example:

	["1138420436397473852"] = {
		["1138420509491605534"] = {
			Read = true,
			Write = true,
			AdminLog = false,
			ErrorLog = false
		},

		["1142410886305288252"] = {
			Read = false,
			Write = false,
			AdminLog = true,
			ErrorLog = false
		},

		["1352481876350079088"] = {
			Read = false,
			Write = false,
			AdminLog = false,
			ErrorLog = true
		}
	}
	--]]
}



--- Prefix to be used for Discord commands. Set to an empty string ("") to disable commands
--- Note that this is NOT case sensitive, it will be convered to lowercase during comparison
config.CommandPrefix = ";"



--- Permission levels for Discord commands and Roles
--- See PERMISSION_ enumerations
config.CommandPermissions = { -- TODO: Extend this out to all Role spots instead of just commands (Maybe)
	--[[
	Permission levels default to their Discord values, values in this table are added on to the Discord permissions
	so you can extend a Role's privilege in the server without extending it in Discord

	If you want a Role to have access to all commands, you can give it the ADMINISTRATOR permission

	Each command has its own permission checks that's performed when the command is attempted to be ran,
	with permission levels being defined when the command is registered

	Format:

	["Role ID"] = (PERMISSION_XYZ)

	Example:

	["1142554498842251366"] = PERMISSION_ADMINISTRATOR,
	["1142386810761265162"] = bit.bor(PERMISSION_MANAGE_CHANNELS, PERMISSION_USE_APPLICATION_COMMANDS) -- Gives both PERMISSION_MANAGE_CHANNELS and PERMISSION_USE_APPLICATION_COMMANDS
	--]]
}

--- The file name/path of the log file. Only certain extensions are supported, see https://wiki.facepunch.com/gmod/file.Write
--- Set to an empty string ("") to disable the log file
config.LogFile = "discord_relay.txt"
