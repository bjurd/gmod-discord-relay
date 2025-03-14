hook.Add("DiscordRelay::DispatchEvent", "DiscordRelay::Resume", function(Type, Message, Data)
	if Type ~= "RESUME" then return end

	print("resumed")
end)
