net.Receive("DiscordRelay::Screenshot", function()
	hook.Add("PostRender", "DiscordRelay::Screenshot", function()
		if gui.IsGameUIVisible() then return end

		local Data = render.Capture({
			["format"] = "jpeg",
			["x"] = 0,
			["y"] = 0,
			["w"] = ScrW(),
			["h"] = ScrH(),
			["quality"] = 80
		})

		if not isstring(Data) then return end

		hook.Remove("PostRender", "DiscordRelay::Screenshot")

		DiscordRelay.NetStream.Send(nil, "DiscordRelay::Screenshot", Data)
	end)
end)
