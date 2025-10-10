--- @param A Player
--- @param B Player
local function SortPlayers(A, B)
	return A:GetName() < B:GetName()
end

local function ChunkByNewline(Text, Limit)
	if not Text or Text == "" then return { "" } end
	if #Text <= Limit then return { Text } end

	local Chunks = {}
	local Current, CurrentLen = {}, 0

	for Line in string.gmatch(Text, "([^\n]*)\n?") do
		if Line ~= "" or CurrentLen > 0 then
			local AddLen = #Line + (CurrentLen == 0 and 0 or 1)

			if CurrentLen + AddLen > Limit then
				table.insert(Chunks, table.concat(Current, "\n"))
				Current, CurrentLen = { Line }, #Line
			else
				if CurrentLen == 0 then
					Current[1] = Line
				else
					table.insert(Current, Line)
				end

				CurrentLen = CurrentLen + AddLen
			end
		end
	end

	if #Current > 0 then
		table.insert(Chunks, table.concat(Current, "\n"))
	end

	if #Chunks == 0 then
		Chunks = { string.sub(Text, 1, Limit) }
	end

	return Chunks
end

local function AddChunkedField(Message, BaseName, Value)
	local Chunks = ChunkByNewline(Value, 1024)

	for i = 1, #Chunks do
		local Name = BaseName

		if i > 1 then
			Name = string.format("%s (cont.%s)", BaseName, i > 2 and (" " .. (i - 1)) or "")
		end

		Message = Message
					:WithField()
						:WithName(Name)
						:WithValue(Chunks[i] ~= "" and Chunks[i] or "\u{200B}")
					:End()
	end

	return Message
end

local Players = relay.commands.New()
	:WithName("players")
	:WithDescription("Shows the current list of players on the server")
	:WithCallback(function(Socket, Data, Args)
		local ChannelID = Data.channel_id
		if not relay.conn.IsChannel(ChannelID, "write") then return end

		local Players = player.GetHumans()
		local Bots = player.GetBots()

		table.sort(Players, SortPlayers)
		table.sort(Bots, SortPlayers)

		local Message = discord.messages.Begin()
				:WithUsername("Player List")
				:WithEmbed()

		local PlayerCount = #Players
		local BotCount = #Bots

		if PlayerCount == 0 and BotCount == 0 then
			Message = Message
						:WithDescription("There are no players online")
						:WithColorRGB(255, 150, 0)
						:End()

			relay.conn.SendWebhookMessage(ChannelID, Message)

			return
		end

		local PlayerDesc = "There are no human players online"
		local BotDesc = "There are no bot players online"

		if PlayerCount > 0 then
			local PlayerList = {}

			for i = 1, PlayerCount do
				local Player = Players[i]
				local Name = relay.util.MarkdownEscape(Player:Nick())
				local SteamID = relay.util.MarkdownEscape(Player:SteamID()) -- SteamIDs have _'s

				table.insert(PlayerList, Format("- %s (%s)", Name, SteamID))
			end

			PlayerDesc = table.concat(PlayerList, "\n")
		end

		if BotCount > 0 then
			local BotList = {}

			for i = 1, BotCount do
				local Bot = Bots[i]
				local Name = relay.util.MarkdownEscape(Bot:Nick())

				table.insert(BotList, Format("- %s", Name))
			end

			BotDesc = table.concat(BotList, "\n")
		end

		Message = AddChunkedField(Message, "Humans", PlayerDesc)
		Message = AddChunkedField(Message, "Bots", BotDesc)

		Message = Message:WithColorRGB(255, 150, 0)
					:End()

		relay.conn.SendWebhookMessage(ChannelID, Message)
	end)

relay.commands.Register(Players)
