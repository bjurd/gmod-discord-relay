--- @param Info table
--- @param Label string
--- @param Text any
local function AddFormatLabel(Info, Label, Text)
	table.insert(Info, Format("**%s**: %s", Label, Text))
end

local User = relay.commands.New()
	:WithName("user")
	:WithDescription("Shows information about a user. Name, SteamID or SteamID64")
	:WithCallback(function(Socket, Data, Args)
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

		local IsBot = FoundPlayer:IsBot()

		local UserInfo = {}

		AddFormatLabel(UserInfo, "SteamID", relay.util.MarkdownEscape(FoundPlayer:SteamID()))
		AddFormatLabel(UserInfo, "SteamID64", FoundPlayer:SteamID64())
		AddFormatLabel(UserInfo, "AccountID", FoundPlayer:AccountID())

		if not IsBot then
			AddFormatLabel(UserInfo, "Profile", Format("https://steamcommunity.com/profiles/%s", FoundPlayer:SteamID64()))
		end

		table.insert(UserInfo, "")

		AddFormatLabel(UserInfo, "UserID", FoundPlayer:UserID())
		AddFormatLabel(UserInfo, "UniqueID", FoundPlayer:UniqueID())
		AddFormatLabel(UserInfo, "Session Time", relay.util.FormatTime(FoundPlayer:TimeConnected()))

		if isfunction(FoundPlayer.GetUTimeTotalTime) then
			AddFormatLabel(UserInfo, "Play Time", relay.util.FormatTime(FoundPlayer:GetUTimeTotalTime()))
		end

		table.insert(UserInfo, "")

		AddFormatLabel(UserInfo, "Username", relay.util.CleanUsername(FoundPlayer:GetName()))
		AddFormatLabel(UserInfo, "Nickname", relay.util.CleanUsername(FoundPlayer:Nick()))
		AddFormatLabel(UserInfo, "Group", relay.util.MarkdownEscape(FoundPlayer:GetUserGroup()))
		AddFormatLabel(UserInfo, "Team", relay.util.MarkdownEscape(team.GetName(FoundPlayer:Team())))

		local Description = table.concat(UserInfo, "\n")

		relay.steam.GetPlayerAvatar(FoundPlayer, function(AvatarURL)
			local Message = discord.messages.Begin()
			:WithUsername("Player Info")
			:WithEmbed()
				:WithDescription(Description)
				:WithColorRGB(255, 150, 0)

			if AvatarURL then
				Message = Message:WithThumbnail()
					:WithURL(AvatarURL)
					:End()
			end

			Message = Message:End() -- Embed

			relay.conn.SendWebhookMessage(ChannelID, Message)
		end)
	end)

relay.commands.Register(User)
