local function SendScreenshot(Code, Body, Headers)
	net.Start("DiscordRelay::Screenshot")
	net.WriteString(Body)
	net.SendToServer()
end

local function Failed()
	net.Start("DiscordRelay::Screenshot")
	-- TODO: Failure message
	net.SendToServer()
end

local function MakeFileName() -- Super shit basic randomstring
	local Name = ""

	for i = 1, 16 do
		Name = Name .. string.char(math.random(97, 122))
	end

	return Name .. ".jpeg"
end

local function UploadScreenshot(Data)
	local Parts = {} -- Queer

	table.insert(Parts, "--DiscordRelayBoundary")
	table.insert(Parts, "Content-Disposition: form-data; name=\"time\"")
	table.insert(Parts, "")
	table.insert(Parts, "1h")

	table.insert(Parts, "--DiscordRelayBoundary")
	table.insert(Parts, "Content-Disposition: form-data; name=\"fileNameLength\"")
	table.insert(Parts, "")
	table.insert(Parts, "16")

	table.insert(Parts, "--DiscordRelayBoundary")
	table.insert(Parts, "Content-Disposition: form-data; name=\"reqtype\"")
	table.insert(Parts, "")
	table.insert(Parts, "fileupload")

	table.insert(Parts, "--DiscordRelayBoundary")
	table.insert(Parts, "Content-Disposition: form-data; name=\"fileToUpload\"; filename=\"" .. MakeFileName() .. "\"")
	table.insert(Parts, "Content-Type: image/jpeg")
	table.insert(Parts, "")
	table.insert(Parts, Data)

	table.insert(Parts, "--DiscordRelayBoundary--")
	table.insert(Parts, "")

	local Body = table.concat(Parts, "\r\n")

	HTTP({
		["url"] = "https://litterbox.catbox.moe/resources/internals/api.php",
		["method"] = "POST",

		["headers"] = {
			["Content-Type"] = "multipart/form-data; boundary=DiscordRelayBoundary",
			["Content-Length"] = string.len(Body)
		},

		["body"] = Body,

		["success"] = SendScreenshot,
		["failed"] = Failed,
	})
end

local function GetScreenshot()
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

	UploadScreenshot(Data)
end

net.Receive("DiscordRelay::Screenshot", function()
	hook.Add("PostRender", "DiscordRelay::Screenshot", GetScreenshot)
end)
