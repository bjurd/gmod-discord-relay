DiscordRelay = DiscordRelay or {}

include("util.lua")

DiscordRelay.Util.RequireModule("gwsockets")
DiscordRelay.Util.RequireModule("chttp")

include("enums.lua")
include("config.lua")

-- If this hook is called then we're good
hook.Add("InitPostEntity", "DiscordRelay::Init", function()
	include("discordrelay/events.lua")
	include("discordrelay/socket.lua")
end)
