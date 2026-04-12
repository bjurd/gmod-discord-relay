--- @type table<string, number>
local ErrorCooldowns = {}

local function ClearCooldowns()
	local Time = CurTime()

	for Message, ThrowTime in next, ErrorCooldowns do
		if Time - ThrowTime >= 1 then
			ErrorCooldowns[Message] = nil
		end
	end
end

hook.Add("OnLuaError", "DiscordRelay::ErrorLog", function(Message, Realm, Stack, Addon, AddonID)
	Addon = Addon or "ERROR"

	ClearCooldowns()

	local ErrorMessage = Format("[%s] %s\n", Addon, Message)

	for i = 1, #Stack do
		local Info = Stack[i]

		local FileName = relay.util.IsNonEmptyStr(Info.File) and Info.File or "unknown"
		local FunctionName = relay.util.IsNonEmptyStr(Info.Function) and Info.Function or "unknown"
		local LineNumber = tonumber(Info.Line) or -1

		ErrorMessage = Format("%s  %s%d. %s - %s:%s\n", ErrorMessage, string.rep(" ", i), i, FunctionName, FileName, LineNumber)
	end

	ErrorMessage = string.Trim(ErrorMessage)
	-- ErrorMessage = relay.util.MarkdownEscape(ErrorMessage) -- This will mess up since it's in a code block

	if ErrorCooldowns[ErrorMessage] then
		return
	end

	ErrorCooldowns[ErrorMessage] = CurTime()

	local Description = Format("```\n%s\n```", ErrorMessage)

	local Message = discord.messages.Begin()
		:WithUsername("Lua Error")
		:WithEmbed()
			:WithAuthor()
				:WithName("Lua Error")
				:End()
			:WithDescription(Description)
			:WithColorRGB(255, 0, 0)
			:End()

	relay.conn.BroadcastWebhookMessage(Message, "errorlog")
end)
