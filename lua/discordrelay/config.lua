DiscordRelay.Config = DiscordRelay.Config or {}

local Intents = DiscordRelay.Enums.Intents

--[[
	The Discord API version the bot should use

	You should probably not change this

	https://discord.com/developers/docs/reference#api-versioning
--]]
DiscordRelay.Config.API = 9



--[[
	The token of your Discord bot

	https://discord.com/developers/applications/(bot_user_id)/bot
--]]
DiscordRelay.Config.Token = ""



--[[
	The ID of the guild (server) where the bot will send/receive messages

	Enable developer mode in Discord to find this
--]]
DiscordRelay.Config.GuildID = ""



--[[
	The ID of the channel within the guild where the bot will send/receive messages

	Enable developer mode in Discord to find this
--]]
DiscordRelay.Config.ChannelID = ""



--[[
	The ID of the channel within the guild where admin mod logs will be sent, leave empty ("") to disable

	Currenly only supports ULX
--]]
DiscordRelay.Config.LogChannelID = ""



--[[
	The ID of the channel within the guild where Lua errors will be sent, leave empty ("") to disable

	Currenly only provides serverside errors
--]]
DiscordRelay.Config.ErrorChannelID = ""



--[[
	Discord API intentions

	Make sure to give your bot Messages and Members intentions within the Privileged Gateway Intents settings
	https://discord.com/developers/applications/(bot_user_id)/bot
--]]
DiscordRelay.Config.Intents = bit.bor(Intents.GUILDS, Intents.GUILD_MEMBERS, Intents.GUILD_WEBHOOKS, Intents.GUILD_MESSAGES, Intents.MESSAGE_CONTENT)



--[[
	Whether or not the bot will filter usernames (both Discord and in-game) for non-ascii characters
--]]
DiscordRelay.Config.FilterUsernames = true



--[[
	Whether or not the bot will escape in-game messages for markdown
--]]
DiscordRelay.Config.EscapeMessages = true



--[[
	Whether or not the bot will show in-game profile pictures in Discord

	Will show the default Discord profile picture if false
--]]
DiscordRelay.Config.ShowProfilePictures = true



--[[
	Whether or not commands are useable
--]]
DiscordRelay.Config.EnableCommands = true



--[[
	The prefix for Discord commands
--]]
DiscordRelay.Config.CommandPrefix = ";"



--[[
	Role IDs for staff-only commands
--]]
DiscordRelay.Config.StaffRoles = { }



--[[
	Whether or not Discord users with administrative permissions will be considered staff
--]]
DiscordRelay.Config.AdminsAreStaff = true
