DiscordRelay.Events = DiscordRelay.Events or {}

function DiscordRelay.Events.Heartbeat()
	DiscordRelay.Socket.SendHeartbeat()
end

function DiscordRelay.Events.OnConnected(Data)
	local Identify = {
		["op"] = 2,

		["d"] = {
			["token"] = Format("Bot %s", DiscordRelay.Config.Token),
			["intents"] = DiscordRelay.Config.Intents,

			["properties"] = {
				["os"] = "linux",
				["browser"] = "Discord iOS",
				["device"] = "Discord iOS"
			},

			["compress"] = false
		}
	}

	DiscordRelay.Socket.Socket:write(DiscordRelay.json.encode(Identify))

	timer.Create("DiscordRelay::Heartbeat", Data.d.heartbeat_interval / 1000, 0, DiscordRelay.Events.Heartbeat)
end

function DiscordRelay.Events.OnChatMessage(Data)
	local UserID = Data.userid
	local Content = string.Trim(Data.text)

	if string.len(Content) < 1 then return end

	local Username = "Console"

	if UserID ~= 0 then
		local Sender = Player(UserID)

		if IsValid(Sender) then
			Username = Sender:Nick()
		else
			Username = "???"
		end
	end

	if DiscordRelay.Config.FilterUsernames then
		Username = DiscordRelay.Util.ASCIIFilter(Username)
	end

	if DiscordRelay.Config.EscapeMessages then
		Content = DiscordRelay.Util.MarkdownEscape(Content)
	end

	DiscordRelay.Util.GetWebhook(function(MessageURL)
		DiscordRelay.Util.SendWebhookMessage(MessageURL, {
			["content"] = string.Left(Content, 2000),
			["username"] = string.Left(Username, 32)
		})
	end)
end

function DiscordRelay.Events.OnDiscordMessage(Data)
	Data = Data.d

	if not istable(Data) then return end

	local Content = Data.content
	if not isstring(Content) or string.len(Content) < 1 then return end

	local GuildID = Data.guild_id
	local ChannelID = Data.channel_id

	if GuildID ~= DiscordRelay.Config.GuildID then return end
	if ChannelID ~= DiscordRelay.Config.ChannelID then return end

	local Member = Data.member
	local Author = Data.author
	if not istable(Member) or not istable(Author) then return end

	local Username = isstring(Member.nick) and Member.nick or (isstring(Author.global_name) and Author.global_name or Author.username) -- Brap you

	if DiscordRelay.Config.FilterUsernames then
		Username = DiscordRelay.Util.ASCIIFilter(Username)
	end

	net.Start("DiscordRelay::Message")
	net.WriteString(Username)
	net.WriteString(Content)
	net.Broadcast()
end

function DiscordRelay.Events.OnPlayerConnected(SteamID, SteamID64)

end

-- TODO: Make this better
function DiscordRelay.Events.RunOperation(Operation, Data)
	if Operation == 10 then
		DiscordRelay.Events.OnConnected(Data)
	elseif Operation == 11 then
		-- Heartbeat ack
	elseif Operation == 0 then
		DiscordRelay.Socket.LastSequenceNumber = Data.s

		if Data.t == "MESSAGE_CREATE" then
			DiscordRelay.Events.OnDiscordMessage(Data)
		end
	end
end

gameevent.Listen("player_say")
hook.Add("player_say", "DiscordRelay::OnChatMessage", DiscordRelay.Events.OnChatMessage)
