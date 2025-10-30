--- @param Command string
--- @return string|nil
local function SafeShell(Command)
	--- @type string
	local stdout = ShellRun(Command)

	if string.find(stdout, "fatal") or string.find(stdout, "error:") or string.find(stdout, "command not found") then
		return nil
	end

	return stdout
end

--- @param Path string
--- @param Command string
--- @return string|nil
local function UpdateShell(Path, Command)
	local stdout = SafeShell(Format("cd %s && %s", Path, Command))
	return stdout
end

--- @param ChannelID string
--- @param EmbedBuilder Embed
local function EarlyReturn(ChannelID, EmbedBuilder)
	local Message = EmbedBuilder:End()
	relay.conn.SendWebhookMessage(ChannelID, Message)
end

local RelayUpdate = relay.commands.New()
	:WithName("rupdate")
	:WithDescription("Attempts to self-update the relay, a server restart may be required afterwards")
	:WithPermissions(PERMISSION_ADMINISTRATOR)
	:WithPermissionsExplicit(true)
	:WithCallback(function(Socket, Data, Args)
		local ChannelID = Data.channel_id
		if not relay.conn.IsChannel(ChannelID, "write") then return end

		local Message = discord.messages.Begin()
			:WithUsername("Relay Update")
			:WithEmbed()
				:WithDescription("```Error during update, check server console for details.```")
				:WithColorRGB(255, 0, 0)

		if not util.IsBinaryModuleInstalled("shell") then
			discord.logging.Log(LOG_ERROR, "Missing gmsv_shell module")
			return EarlyReturn(ChannelID, Message) -- goto's crying about scope jumps is annoying
		end

		require("shell")

		if not isfunction(ShellRun) then
			discord.logging.Log(LOG_ERROR, "Improper gmsv_shell module")
			return EarlyReturn(ChannelID, Message)
		end

		local RelayPath = SafeShell("find -L ./garrysmod/addons -mindepth 3 -maxdepth 5 -type f -path '*/lua/autorun/server/discordrelay.lua' -printf '%h\n' | sed 's|/lua/autorun/server$||'")

		if isstring(RelayPath) then
			-- LuaLS fail #43205
			RelayPath = string.Trim(RelayPath)
		end

		if not RelayPath or string.len(RelayPath) < 1 then
			discord.logging.Log(LOG_ERROR, "RelayUpdate failed to find relay install")
			return EarlyReturn(ChannelID, Message)
		end

		local StashStatus = UpdateShell(RelayPath, "git stash push")

		if not StashStatus then
			discord.logging.Log(LOG_ERROR, "RelayUpdate failed to stash with git. Either the addon is not a repository or git is missing.")
			return EarlyReturn(ChannelID, Message)
		end

		local PullStatus = UpdateShell(RelayPath, "git pull")

		if not PullStatus then
			discord.logging.Log(LOG_ERROR, "RelayUpdate failed to pull with git. Check for conflicts.")
			UpdateShell(RelayPath, "git stash pop")

			return EarlyReturn(ChannelID, Message)
		end

		local PopStatus = UpdateShell(RelayPath, "git stash pop")

		if not PopStatus then
			Message = Message:WithColorRGB(255, 150, 0)

			discord.logging.Log(LOG_ERROR, "RelayUpdate failed to pop stash, but the update completed. Make sure to pop the stash manually before updating again.")
			return EarlyReturn(ChannelID, Message)
		else
			Message = Message:WithColorRGB(0, 255, 0)
		end

		Message = Message:WithDescription("```Successfully updated relay```")
					:End()

		relay.conn.SendWebhookMessage(ChannelID, Message)
	end)

relay.commands.Register(RelayUpdate)
