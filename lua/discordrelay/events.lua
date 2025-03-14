DiscordRelay.Events = DiscordRelay.Events or {}

function DiscordRelay.Events.RunOperation(Operation, Message)
	hook.Run("DiscordRelay::RunOperation", Operation, Message, Message.d)
end

include("events/chatmsg.lua")
include("events/discordmsg.lua")
include("events/dispatch.lua")
include("events/hello.lua")
include("events/ready.lua")
include("events/resume.lua")
