DiscordRelay.Events = DiscordRelay.Events or {}

function DiscordRelay.Events.RunOperation(Operation, Message)
	hook.Run("DiscordRelay::RunOperation", Operation, Message, Message.d)
end

include("events/chatmsg.lua")
include("events/connect.lua")
include("events/disconnect.lua")
include("events/discordmsg.lua")
include("events/dispatch.lua")
include("events/hello.lua")
include("events/namechange.lua")
include("events/ready.lua")
include("events/resume.lua")
