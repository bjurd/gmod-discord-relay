-- Not a normal event but 2bad2sad

gameevent.Listen("player_say")
hook.Add("player_say", "DiscordRelay::OnChatMessage", function(Data)
	local UserID = Data.userid
	local Content = string.Trim(Data.text)

	if string.len(Content) < 1 then return end

	local Sender
	local Username = "Console"

	if UserID ~= 0 then
		Sender = Player(UserID)

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

	local Payload = {
		["content"] = string.Left(Content, 2000),
		["username"] = string.Left(Username, 32),
		["avatar_url"] = nil
	}

	if DiscordRelay.Config.ShowProfilePictures and IsValid(Sender) then
		DiscordRelay.Util.FetchAvatar(Sender:SteamID64(), function(AvatarURL)
			Payload["avatar_url"] = AvatarURL

			DiscordRelay.Util.GetWebhook(function(MessageURL)
				DiscordRelay.Util.SendWebhookMessage(MessageURL, Payload)
			end)
		end)
	else
		DiscordRelay.Util.GetWebhook(function(MessageURL)
			DiscordRelay.Util.SendWebhookMessage(MessageURL, Payload)
		end)
	end
end)
