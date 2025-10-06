relay = relay or {}

require("discord")

include("config.lua")

include("util.lua")
include("connection.lua")
include("steam.lua")

include("events/ready.lua")
include("events/discordmsg.lua")
include("events/discordcmd.lua")
include("events/chatmsg.lua")
include("events/connect.lua")
include("events/disconnect.lua")
include("events/changename.lua")
include("events/error.lua")

include("commands.lua")
include("commands/help.lua")
include("commands/status.lua")

--- Gets the path of the relay's log file
--- @return string|nil Path nil if logging is disabled
function relay.GetLogPath()
	if not relay.util.IsNonEmptyStr(relay.config.LogFile) then
		return nil
	end

	return relay.config.LogFile
end

--- Resets the relay's log file to blank
function relay.ResetLog()
	local LogPath = relay.GetLogPath()

	if LogPath then
		file.Write(LogPath, "")
	end
end

hook.Add("GetGameDescription", "DiscordRelay::InitialBroadcast", function()
	-- https://github.com/Facepunch/garrysmod-issues/issues/3001
	-- Wait until the server is actually joinable to begin
	local IP = game.GetIPAddress()
	if string.StartsWith(IP, "0.0.0.0") then return end

	hook.Remove("GetGameDescription", "DiscordRelay::InitialBroadcast")



	relay.ResetLog()



	local sv_hibernate_think = GetConVar("sv_hibernate_think")
	if sv_hibernate_think and not sv_hibernate_think:GetBool() then
		-- Piss
		discord.logging.Log(LOG_WARNING, "sv_hibernate_think is disabled, relay processing will halt whilst the server is empty!")
	end



	relay.conn.Initialize()
end)
