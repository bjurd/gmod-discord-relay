net.Receive("DiscordRelay::Screenshot", function()
	local Quality = 60

	hook.Add("PostRender", "DiscordRelay::Screenshot", function()
		if gui.IsGameUIVisible() then return end

		local CaptureData = {
			["format"] = "jpeg",
			["x"] = 0,
			["y"] = 0,
			["w"] = ScrW(),
			["h"] = ScrH(),
			["quality"] = Quality
		}

		local Data = render.Capture(CaptureData)
		if not isstring(Data) then return end

		Data = util.Compress(Data)
		local Length = string.len(Data)

		if Length > 64 * 1024 then
			Quality = Quality - 10

			if Quality < 1 then -- Can't get a good capture
				hook.Remove("PostRender", "DiscordRelay::Screenshot")
			end

			return
		end

		hook.Remove("PostRender", "DiscordRelay::Screenshot")

		net.Start("DiscordRelay::Screenshot")
			net.WriteData(Data, Length)
		net.SendToServer()
	end)
end)
