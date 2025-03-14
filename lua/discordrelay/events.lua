DiscordRelay.Events = DiscordRelay.Events or {}

function DiscordRelay.Events.OnConnected()
	print("connected")
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

function DiscordRelay.Events.OnDiscordMessage(Author, Message)

end

function DiscordRelay.Events.OnPlayerConnected(SteamID, SteamID64)

end

-- TODO: Make this better
function DiscordRelay.Events.RunOperation(Operation)
	print("runop", Operation)

	if Operation == 10 then
		DiscordRelay.Events.OnConnected()
	end
end

gameevent.Listen("player_say")
hook.Add("player_say", "DiscordRelay::OnChatMessage", DiscordRelay.Events.OnChatMessage)
