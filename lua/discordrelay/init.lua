relay = relay or {}

require("discord")

include("config.lua")

include("util.lua")
include("connection.lua")

include("events/ready.lua")
include("events/discordmsg.lua")

hook.Add("InitPostEntity", "DiscordRelay::InitialBroadcast", function()
	local sv_hibernate_think = GetConVar("sv_hibernate_think")

	if sv_hibernate_think and not sv_hibernate_think:GetBool() then
		-- Piss
		discord.logging.Log(LOG_WARNING, "sv_hibernate_think is disabled, relay processing will halt whilst the server is empty!")
	end

	relay.conn.Initialize()
end)
