hook.Add("DiscordRelay::RunOperation", "DiscordRelay::DispatchEvent", function(Operation, Message, Data)
	if Operation ~= DiscordRelay.Enums.Operations.DISPATCH then return end

	DiscordRelay.Socket.LastSequenceNumber = Message.s

	hook.Run("DiscordRelay::DispatchEvent", Message.t, Message, Data)
end)
