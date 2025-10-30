relay = relay or {}

require("discord")

relay.config = relay.config or include("config.lua")
if not relay.config then return end

include("util.lua")
include("connection.lua")
include("steam.lua")
include("detours.lua")

--- Gets the path of the relay's log file
--- @return string|nil Path nil if logging is disabled, empty string if the configured path is invalid
function relay.GetLogPath()
	local LogFile = relay.config.logfile

	if not relay.util.IsNonEmptyStr(LogFile) then
		return nil
	end

	local LogFileName = string.GetFileFromFilename(LogFile)
	local LogFileExt = string.GetExtensionFromFilename(LogFileName)

	if LogFileName == "." .. LogFileExt then
		-- The fuck are you doing
		-- This will force an error in WriteLogLn to let you know
		return ""
	end

	if not LogFileExt or string.len(LogFileExt) < 1 then
		-- Fix your config, nooben
		return ""
	end

	local Path = string.GetPathFromFilename(LogFile)
	if Path == LogFile then return "" end
	if string.len(Path) < 1 then return LogFileName end

	local Blocks = string.Split(Path, "/")
	if string.len(Blocks[#Blocks]) < 1 then table.remove(Blocks, #Blocks) end -- The final character is a / so we get a blank entry

	-- Create folders so file.Write/Append doesn't fail
	-- because it doesn't automatically create folders
	for i = 1, #Blocks do
		local Combined = {}

		for j = 1, i do
			table.insert(Combined, Blocks[j])
		end

		local CurrentPath = table.concat(Combined, "/")

		if file.Exists(CurrentPath, "DATA") then
			if not file.IsDir(CurrentPath, "DATA") then
				discord.logging.Log(LOG_ERROR, "Something has gone wrong with the creation of relay log path! This should never happen!")
				return ""
			end

			continue
		end

		file.CreateDir(CurrentPath)
	end

	return LogFile
end

--- Resets the relay's log file to blank
function relay.ResetLog()
	local LogPath = relay.GetLogPath()

	if LogPath then
		file.Write(LogPath, "")
	end
end

--- Loads event files
function relay.LoadEvents()
	include("discordrelay/events/ready.lua")
	include("discordrelay/events/discordmsg.lua")
	include("discordrelay/events/discordcmd.lua")
	include("discordrelay/events/chatmsg.lua")
	include("discordrelay/events/connect.lua")
	include("discordrelay/events/disconnect.lua")
	include("discordrelay/events/changename.lua")
	include("discordrelay/events/error.lua")
	include("discordrelay/events/adminlog.lua") -- Not really an event but shush
end

--- Loads command files
function relay.LoadCommands()
	include("discordrelay/commands.lua")
	include("discordrelay/commands/help.lua")
	include("discordrelay/commands/status.lua")
	include("discordrelay/commands/rcon.lua")
	include("discordrelay/commands/lua.lua")
	include("discordrelay/commands/players.lua")
	include("discordrelay/commands/user.lua")
	include("discordrelay/commands/rupdate.lua")
end

--- Begins the initial connection
function relay.Init()
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
end

--- The launcher for the relay
function relay.Launch()
	relay.LoadEvents()
	relay.LoadCommands()

	hook.Add("GetGameDescription", "DiscordRelay::InitialBroadcast", relay.Init)
end

-- Let's go!
hook.Add("InitPostEntity", "DiscordRelay::Launch", relay.Launch)
