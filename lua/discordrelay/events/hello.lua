hook.Add("DiscordRelay::RunOperation", "DiscordRelay::Hello", function(Operation, Message, Data)
	if Operation ~= DiscordRelay.Enums.Operations.HELLO then return end

	if DiscordRelay.Socket.SessionID then
		DiscordRelay.Socket.Resume()
		print("resuming")
	else
		DiscordRelay.Socket.Identify()
		print("identifying")

		timer.Create("DiscordRelay::Heartbeat", Data.heartbeat_interval / 1000, 0, DiscordRelay.Socket.SendHeartbeat)
	end
end)
