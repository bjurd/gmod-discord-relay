hook.Add("DiscordRelay::DispatchEvent", "DiscordRelay::Ready", function(Type, Message, Data)
	if Type ~= "READY" then return end

	DiscordRelay.Socket.SessionID = Message.session_id

	DiscordRelay.Util.WebhookAutoSend({
		["username"] = "Server Status",
		["embeds"] = {
			DiscordRelay.Util.CreateEmbed(Color(0, 255, 0), GetHostName(), "Server is now online!")
		}
	})
end)
