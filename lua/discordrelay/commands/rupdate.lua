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

--- @param Path string
--- @param Old string|nil
--- @param New string|nil
--- @return string|nil
local function GitChangelog(Path, Old, New)
	if not Old or not New then return nil end

	Old = string.Trim(Old)
	New = string.Trim(New)

	if Old == New then return nil end

	local Command = Format(
		"git -c core.pager=cat log --first-parent --no-merges --reverse --pretty=format:'%%h %%s' %s..%s",

		Old,
		New
	)

	local Changelog = UpdateShell(Path, Command)

	if not Changelog then
		print("no changelog")
		return nil
	end

	Changelog = string.Trim(Changelog)
	print("raw", Changelog)

	local Header = Format(
		"Updated %s -> %s\n",

		string.sub(Old, 1, 7),
		string.sub(New, 1, 7)
	)

	local Max = 1900 - string.len(Header)

	if string.len(Changelog) > Max then
		Changelog = string.sub(Changelog, 1, Max) .. "\n…"
	end

	return Format("```%s%s```", Header, Changelog)
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

		discord.logging.DevLog(LOG_NORMAL, "Starting relay update via git")

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

		discord.logging.DevLog(LOG_SUCCESS, "Found relay install at %s", RelayPath)

		discord.logging.DevLog(LOG_NORMAL, "Stashing relay")
		local StashStatus = UpdateShell(RelayPath, "git stash push")

		if not StashStatus then
			discord.logging.Log(LOG_ERROR, "RelayUpdate failed to stash with git. Either the addon is not a repository or git is missing.")
			return EarlyReturn(ChannelID, Message)
		end

		local OldGitVersion = UpdateShell(RelayPath, "git rev-parse head")

		discord.logging.DevLog(LOG_NORMAL, "Pulling relay")
		local PullStatus = UpdateShell(RelayPath, "git pull --ff-only")

		if not PullStatus then
			discord.logging.Log(LOG_ERROR, "RelayUpdate failed to pull with git. Check for conflicts.")
			UpdateShell(RelayPath, "git stash pop")

			return EarlyReturn(ChannelID, Message)
		end

		local NewGitVersion = UpdateShell(RelayPath, "git rev-parse head")
		print("ver", OldGitVersion, NewGitVersion)
		local Changelog = GitChangelog(RelayPath, OldGitVersion, NewGitVersion)

		discord.logging.DevLog(LOG_NORMAL, "Popping relay")
		local PopStatus = UpdateShell(RelayPath, "git stash pop")

		if not PopStatus then
			discord.logging.Log(LOG_ERROR, "RelayUpdate failed to pop stash, but the update completed. Make sure to pop the stash manually before updating again.")
		end

		local Description = ""
		if not Changelog or string.len(Changelog) == 0 then
			print("Changelog up to date", Changelog, isstring(Changelog) and string.len(Changelog) or -1)
			Description = "```Relay is up to date"

			if not PopStatus then
				Description = Description .. ", check server console for details.```"
				Message = Message:WithColorRGB(255, 150, 0)
			else
				Description = Description .. "```"
				Message = Message:WithColorRGB(0, 255, 0)
			end

			Message = Message:WithDescription(Description)
						:End()
		else
			Description = "```Successfully updated relay"

			if not PopStatus then
				Description = Description .. ", check server console for details.```"
				Message = Message:WithColorRGB(255, 150, 0)
			else
				Description = Description .. "```"
				Message = Message:WithColorRGB(0, 255, 0)
			end

			Message = Message:WithDescription(Description)
						:End()

			Message = Message:WithEmbed()
				:WithDescription(Changelog)
				:WithColorRGB(255, 150, 0)
				:End()
		end

		discord.logging.DevLog(LOG_SUCCESS, "Relay update concluded")

		relay.conn.SendWebhookMessage(ChannelID, Message)
	end)

relay.commands.Register(RelayUpdate)
