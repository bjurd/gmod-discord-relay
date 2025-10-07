if not istable(ulx) then return end

ulx.logWriteln = relay.detours.Destroy(ulx.logWriteln)

ulx.logWriteln = relay.detours.Create(ulx.logWriteln, function(Log)
	__original(Log)

	-- Relay dat shi
	local CleanLog = relay.util.MarkdownEscape(Log)

	local Message = discord.messages.Begin()
		:WithUsername("Admin Log")
		:WithEmbed()
			:WithDescription(CleanLog)
			:WithColorRGB(255, 150, 0)
			:End()

	relay.conn.BroadcastWebhookMessage(Message, "AdminLog")
end)
