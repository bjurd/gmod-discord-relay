DiscordRelay = DiscordRelay or {}

util.AddNetworkString("DiscordRelay::Message")

include("clientfiles.lua")
include("util.lua")

DiscordRelay.Util.RequireModule("gwsockets")
DiscordRelay.Util.RequireModule("chttp")

include("enums.lua")
include("config.lua")

-- If this hook is called then we're good
hook.Add("InitPostEntity", "DiscordRelay::Init", function()
	include("discordrelay/netstream.lua")
	include("discordrelay/events.lua")
	include("discordrelay/commands.lua")
	include("discordrelay/socket.lua")

	DiscordRelay.Socket.Setup()
end)
