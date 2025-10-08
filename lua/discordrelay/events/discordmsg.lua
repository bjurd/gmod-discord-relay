util.AddNetworkString("DiscordRelay::ChatMessage")

hook.Add("DiscordRelay::ProcessDiscordMessage", "DEFAULT::SendToGame", function(Socket, Data)
	if player.GetCount() < 1 then return end -- :P
	if Data.webhook_id then return end -- Ignore these, they don't have a "member" property anyways

	local User = discord.oop.ConstructNew("User", Data.author)
	local Member = discord.oop.ConstructNew("Member", Data.member)

	discord.roles.GetGuildRoles(Socket, Data.guild_id, function(Roles)
		-- There's no other endpoint for Role data than this one unfortunately
		local Name = relay.util.GetMemberName(User, Member)
		local NameColor = Member:GetNameColor(Roles)

		net.Start("DiscordRelay::ChatMessage")
			net.WriteColor(NameColor, false)
			net.WriteString(Name)
			net.WriteString(Data.content)
		net.Broadcast()
	end)
end)

hook.Add("DiscordRelay::DispatchEvent", "DEFAULT::ReadDiscord", function(Event, Socket, Data)
	if Event ~= "MESSAGE_CREATE" then return end

	if not relay.conn.IsChannel(Data.channel_id, "read") then return end
	if not relay.util.IsNonEmptyStr(Data.content) then return end

	-- Don't Bot check here so Bot messages still relay, commands will be handled by discordcmd.lua
	-- local User = discord.oop.ConstructNew("User", Data.author)
	-- if User:IsBot() then return end

	hook.Run("DiscordRelay::ProcessDiscordMessage", Socket, Data)
end)
