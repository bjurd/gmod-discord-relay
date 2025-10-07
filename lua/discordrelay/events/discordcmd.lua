hook.Add("DiscordRelay::ProcessDiscordMessage", "DEFAULT::ProcessCommand", function(Socket, Data)
	local Prefix = string.lower(relay.config.commands.prefix)

	if not relay.util.IsNonEmptyStr(Prefix) then
		-- Commands have been disabled
		return
	end

	local Blocks = string.Split(Data.content, " ")
	local CommandBlock = string.lower(Blocks[1])

	if not string.StartsWith(CommandBlock, Prefix) then
		return
	else
		table.remove(Blocks, 1) -- This is now Args
	end

	local CommandName = string.sub(CommandBlock, string.len(Prefix) + 1)

	relay.commands.Process(CommandName, Socket, Data, Blocks)
end)
