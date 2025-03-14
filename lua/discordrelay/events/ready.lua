hook.Add("DiscordRelay::DispatchEvent", "DiscordRelay::Ready", function(Type, Message, Data)
	if Type ~= "READY" then return end

	print("ready")

	DiscordRelay.Socket.SessionID = Message.session_id
end)
