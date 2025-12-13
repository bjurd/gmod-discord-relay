util.AddNetworkString("DiscordRelay::ChatMessage")

local Blurple = Color(88, 101, 242, 255)

--- Reads message_reference and referenced_message
--- @param Data table
--- @param SendMessageData table
local function ProcessReference(Data, SendMessageData)
	if not istable(Data.message_reference) then
		return
	end

	if Data.message_reference.type == REFERENCE_REPLY then
		local Referenced = Data.referenced_message
		local ReferencedUser = discord.oop.ConstructNew("User", Referenced.author)
		-- There is no Referenced.member, so we can't color their name too unfortunately

		local Name = relay.util.GetUserName(ReferencedUser)

		table.insert(SendMessageData, 3, Color(175, 175, 175, 255)) -- TODO: This is kind of cursed
		table.insert(SendMessageData, 4, " replying to ")
		table.insert(SendMessageData, 5, Blurple)
		table.insert(SendMessageData, 6, Name)

		return
	end

	-- TODO: REFERENCE_FORWARD
end

hook.Add("DiscordRelay::ProcessDiscordMessage", "DEFAULT::SendToGame", function(Socket, Data)
	if player.GetCount() < 1 then return end -- :P

	local User = discord.oop.ConstructNew("User", Data.author)
	local Member = discord.oop.ConstructNew("Member", Data.member)

	discord.roles.GetGuildRoles(Socket, Data.guild_id, function(Roles)
		-- There's no other endpoint for Role data than this one unfortunately

		local Name = relay.util.GetMemberName(User, Member)
		local NameColor = Color(255, 255, 255, 255)

		if Roles then
			NameColor = Member:GetNameColor(Roles)
		end

		local SendMessageData = { NameColor, Name, Color(255, 255, 255, 255), ": ", Data.content }
		ProcessReference(Data, SendMessageData)

		net.Start("DiscordRelay::ChatMessage")
			net.WriteTable(SendMessageData, true)
		net.Broadcast()
	end)
end)

hook.Add("DiscordRelay::DispatchEvent", "DEFAULT::ReadDiscord", function(Event, Socket, Data)
	if Event ~= "MESSAGE_CREATE" then return end

	if Data.webhook_id then return end -- Ignore these, they don't have a "member" property anyways
	if not relay.conn.IsChannel(Data.channel_id, "read") then return end
	if not relay.util.IsNonEmptyStr(Data.content) then return end

	-- Don't Bot check here so Bot messages still relay, commands will be handled by discordcmd.lua
	-- local User = discord.oop.ConstructNew("User", Data.author)
	-- if User:IsBot() then return end

	hook.Run("DiscordRelay::ProcessDiscordMessage", Socket, Data)
end)
