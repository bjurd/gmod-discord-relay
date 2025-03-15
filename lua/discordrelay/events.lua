DiscordRelay.Events = DiscordRelay.Events or {}

function DiscordRelay.Events.RunOperation(Operation, Message)
	hook.Run("DiscordRelay::RunOperation", Operation, Message, Message.d)
end

DiscordRelay.Util.IncludeFromFolder("events")
