util.AddNetworkString("DiscordRelay::ChatMessage")

hook.Add("DiscordRelay::DispatchEvent", "ReadDiscord", function(Event, Socket, Data)
	if Event ~= "MESSAGE_CREATE" then return end

	local _, ReadableChannels = relay.conn.FilterChannels("Read")
	if not ReadableChannels[Data.channel_id] then return end

	local Content = tostring(Data.content)
	if string.len(Content) < 1 then return end

	local User = discord.oop.ConstructNew("User", Data.author)
	local Member = discord.oop.ConstructNew("Member", Data.member)

	discord.roles.GetGuildRoles(relay.conn.Instance, Data.guild_id, function(Roles)
		-- There's no other endpoint for Role data than this one unfortunately
		local Highest = Member:GetHighestRole(Roles)

		local Name = relay.util.GetMemberName(User, Member)
		local NameColor = Highest:GetColor()

		net.Start("DiscordRelay::ChatMessage")
			net.WriteColor(NameColor, false)
			net.WriteString(Name)
			net.WriteString(Content)
		net.Broadcast()
	end)
end)
