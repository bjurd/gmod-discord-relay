relay.config = relay.config or {}
local config = relay.config

--- Discord API version to use
--- https://discord.com/developers/docs/reference#api-versioning
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
			-- Whether or not the bot will relay Discord messages to in-game chat. Default is false
			Read = true/false,

			-- Whether or not the bot will relay in-game messages to this channel. Default is false
			Write = true/false,

			-- Whether or not this channel should be used to relay server log messages to Discord. Default is false
			AdminLog = true/false,

			-- Whether or not this channel should be used to relay server Lua error messages to Discord. Default is false
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
