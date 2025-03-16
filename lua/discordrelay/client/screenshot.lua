net.Receive("DiscordRelay::Screenshot", function()
	hook.Add("PostRender", "DiscordRelay::Screenshot", function()
		local CaptureData = {
			["format"] = "jpeg",
			["x"] = 0,
			["y"] = 0,
			["w"] = ScrW(),
			["h"] = ScrH()
		}

		local function Capture(Quality)
			if Quality < 1 then -- Can't get a good capture
				return false
			end

			CaptureData.quality = Quality

			local Data = render.Capture(CaptureData)
			if not isstring(Data) then return false end

			Data = util.Compress(Data)
			local Length = string.len(Data)

			if Length > 65 * 1024 then
				return Capture(Quality - 10)
			else
				return Data, Length
			end
		end

		local Data, Length = Capture(80)
		if not Data then return end

		hook.Remove("PostRender", "DiscordRelay::Screenshot")

		net.Start("DiscordRelay::Screenshot")
			net.WriteData(Data, Length)
		net.SendToServer()
	end)
end)
