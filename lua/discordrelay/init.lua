DiscordRelay = DiscordRelay or {}

util.AddNetworkString("DiscordRelay::Message")

include("util.lua")

DiscordRelay.json = include("jsonlua/json.lua") -- gmod json SUCKS

DiscordRelay.Util.RequireModule("gwsockets")
DiscordRelay.Util.RequireModule("chttp")

include("enums.lua")
include("config.lua")

-- If this hook is called then we're good
hook.Add("InitPostEntity", "DiscordRelay::Init", function()
	include("discordrelay/events.lua")
	include("discordrelay/socket.lua")

	DiscordRelay.Socket.Setup()
end)
