hook.Add("DiscordRelay::DispatchEvent", "DiscordRelay::OnDiscordMessage", function(Type, Message, Data)
	if Type ~= "MESSAGE_CREATE" then return end

	local Content = Data.content
	if not isstring(Content) or string.len(Content) < 1 then return end

	if Data.guild_id ~= DiscordRelay.Config.GuildID then return end
	if Data.channel_id ~= DiscordRelay.Config.ChannelID then return end

	local Member = Data.member
	local Author = Data.author
	if not istable(Member) or not istable(Author) then return end

	local Username = isstring(Member.nick) and Member.nick or (isstring(Author.global_name) and Author.global_name or Author.username) -- Brap you

	if DiscordRelay.Config.FilterUsernames then
		Username = DiscordRelay.Util.ASCIIFilter(Username)
	end

	net.Start("DiscordRelay::Message")
		net.WriteString(Username)
		net.WriteString(Content)
	net.Broadcast()
end)
