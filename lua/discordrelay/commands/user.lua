relay.commands.Register("user", PERMISSION_NONE, function(Socket, Data, Args)
	local ChannelID = Data.channel_id
	if not relay.conn.IsChannel(ChannelID, "write") then return end

	local SearchToken = Args[1]

	if not relay.util.IsNonEmptyStr(SearchToken) then
		local Description = "```\nInvalid parameters\n```"

		local Message = discord.messages.Begin()
			:WithUsername("Player Info")
			:WithEmbed()
				:WithDescription(Description)
				:WithColorRGB(255, 0, 0)
				:End()

		relay.conn.SendWebhookMessage(ChannelID, Message)

		return
	end

	local FoundPlayer = relay.util.FindPlayer(SearchToken)

	if not FoundPlayer then
		local Description = "```\nPlayer not found\n```"

		local Message = discord.messages.Begin()
			:WithUsername("Player Info")
			:WithEmbed()
				:WithDescription(Description)
				:WithColorRGB(255, 0, 0)
				:End()

		relay.conn.SendWebhookMessage(ChannelID, Message)

		return
	end

	local SteamID = relay.util.MarkdownEscape(FoundPlayer:SteamID())
	local SteamID64 = FoundPlayer:SteamID64()
	local ProfileURL = Format("https://steamcommunity.com/profiles/%s", SteamID64)

	local UserID = FoundPlayer:UserID()
	local UniqueID = FoundPlayer:UniqueID()
	local ConnectionTime = relay.util.FormatTime(FoundPlayer:TimeConnected())

	local Username = relay.util.CleanUsername(FoundPlayer:GetName())
	local Nickname = relay.util.CleanUsername(FoundPlayer:Nick())
	local UserGroup = relay.util.MarkdownEscape(FoundPlayer:GetUserGroup())
	local Team = team.GetName(FoundPlayer:Team()) or "No Team"
	Team = relay.util.MarkdownEscape(Team)

	local Description = Format(
		"**SteamID**: %s\n**SteamID64**: %s\n**Profile**: %s\n\n**UserID**: %s\n**UniqueID**: %s\n**Connection Time**: %s\n\n**Username**: %s\n**Nickname**: %s\n**User Group**: %s\n**Team**: %s",

		SteamID,
		SteamID64,
		ProfileURL,

		UserID,
		UniqueID,
		ConnectionTime,

		Username,
		Nickname,
		UserGroup,
		Team
	)

	local Message = discord.messages.Begin()
		:WithUsername("Player Info")
		:WithEmbed()
			:WithDescription(Description)
			:WithColorRGB(255, 150, 0)
			:End()

	relay.conn.SendWebhookMessage(ChannelID, Message)
end)
