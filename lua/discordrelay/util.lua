DiscordRelay.Util = DiscordRelay.Util or {}

DiscordRelay.Util.NoOp = function() return end

DiscordRelay.Util.AvatarCache = DiscordRelay.Util.AvatarCache or {}

function DiscordRelay.Util.RequireModule(Name)
	if not util.IsBinaryModuleInstalled(Name) then
		error(Format("Binary module %s is not installed for Discord Relay!", Name))
	else
		require(Name)
	end
end

function DiscordRelay.Util.IncludeFromFolder(Path)
	local Source = debug.getinfo(2).short_src
	local SourceDir = string.GetPathFromFilename(Source)

	local SearchDir = Format("lua/%s", Path)
	local Files = file.Find(Format("%s/*.lua", SearchDir), "GAME")

	if #Files < 1 then
		SearchDir = Format("%s/%s", SourceDir, Path)
		Files = file.Find(Format("%s/*.lua", SearchDir), "GAME")
	end

	for i = 1, #Files do
		-- include() doesn't like it when it starts with "addons/x" so it has to be done this way :c
		local FilePath = Format("%s/%s", SearchDir, Files[i])
		local FileContent = file.Read(FilePath, "GAME")

		RunString(FileContent, FilePath)
	end
end

function DiscordRelay.Util.ASCIIFilter(String)
	return string.gsub(String, "[^\32-\126]", "?")
end

function DiscordRelay.Util.MarkdownEscape(String)
	return string.gsub(String, "([\\%*_%`~>|#])", "\\%1")
end

function DiscordRelay.Util.CreateWebhook(WebhookURL, Callback)
	local WebhookCreationContent = util.TableToJSON({ ["name"] = "Relay" })

	CHTTP({
		["url"] = WebhookURL,
		["method"] = "POST",

		["headers"] = {
			["Content-Type"] = "application/json",
			["Content-Length"] = string.len(WebhookCreationContent),
			["Host"] = "discord.com", -- Required for this for some reason /shrug
			["Authorization"] = Format("Bot %s", DiscordRelay.Config.Token)
		},

		["body"] = WebhookCreationContent,

		["success"] = function(Code, Body)
			if Code ~= 200 then return end

			local Data = util.JSONToTable(Body)
			if not istable(Data) then return end

			local WebhookID = Data.id
			local WebhookToken = Data.token
			if not isstring(WebhookID) or not isstring(WebhookToken) then return end

			DiscordRelay.Socket.WebhookMessageURL = Format("https://discord.com/api/webhooks/%s/%s", WebhookID, WebhookToken)

			Callback(DiscordRelay.Socket.WebhookMessageURL)
		end,

		["failed"] = DiscordRelay.Util.NoOp
	})
end

function DiscordRelay.Util.ParseWebhooks(WebhookURL, Callback)
	return function(Code, Body)
		if Code ~= 200 then return end

		local Data = util.JSONToTable(Body)
		if not istable(Data) then return end

		if #Data < 1 then -- None there
			DiscordRelay.Util.CreateWebhook(WebhookURL, Callback)
			return
		end

		for i = 1, #Data do
			local WebhookID = Data[i].id
			local WebhookToken = Data[i].token

			if not isstring(WebhookID) or not isstring(WebhookToken) then -- Bad here
				continue
			end

			DiscordRelay.Socket.WebhookMessageURL = Format("https://discord.com/api/webhooks/%s/%s", WebhookID, WebhookToken)

			Callback(DiscordRelay.Socket.WebhookMessageURL)

			return
		end

		DiscordRelay.Util.CreateWebhook(WebhookURL, Callback)
	end
end

function DiscordRelay.Util.GetWebhook(Callback)
	if DiscordRelay.Socket.WebhookMessageURL then
		Callback(DiscordRelay.Socket.WebhookMessageURL)
		return
	end

	local WebhookURL = Format("https://discord.com/api/v%d/channels/%s/webhooks", DiscordRelay.Config.API, DiscordRelay.Config.ChannelID)

	CHTTP({
		["url"] = WebhookURL,
		["method"] = "GET",

		["headers"] = {
			["Authorization"] = Format("Bot %s", DiscordRelay.Config.Token)
		},

		["success"] = DiscordRelay.Util.ParseWebhooks(WebhookURL, Callback),
		["failed"] = DiscordRelay.Util.NoOp
	})
end

function DiscordRelay.Util.CheckWebhookMessage(MessageData)
	return function(Code)
		-- Webhook cache went invalid, reobtain
		if Code == 404 then
			DiscordRelay.Socket.WebhookMessageURL = nil

			DiscordRelay.Util.GetWebhook(function(MessageURL)
				DiscordRelay.Util.SendWebhookMessage(MessageURL, MessageData, true)
			end)
		end
	end
end

function DiscordRelay.Util.SendWebhookMessage(MessageURL, MessageData, NoRetry)
	MessageData["allowed_mentions"] = { ["parse"] = {} } -- Nuh uh

	local MessageBody = util.TableToJSON(MessageData)

	CHTTP({
		["url"] = MessageURL,
		["method"] = "POST",

		["headers"] = {
			["Content-Type"] = "application/json",
			["Content-Length"] = string.len(MessageBody),
			["Authorization"] = Format("Bot %s", DiscordRelay.Config.Token)
		},

		["body"] = MessageBody,

		["success"] = NoRetry and DiscordRelay.Util.NoOp or DiscordRelay.Util.CheckWebhookMessage(MessageData),
		["failed"] = DiscordRelay.Util.NoOp
	})
end

function DiscordRelay.Util.WebhookAutoSend(MessageData, SteamID64)
	if DiscordRelay.Config.ShowProfilePictures and isstring(SteamID64) then
		DiscordRelay.Util.FetchAvatar(SteamID64, function(AvatarURL)
			MessageData["avatar_url"] = AvatarURL

			DiscordRelay.Util.GetWebhook(function(MessageURL)
				DiscordRelay.Util.SendWebhookMessage(MessageURL, MessageData)
			end)
		end)
	else
		DiscordRelay.Util.GetWebhook(function(MessageURL)
			DiscordRelay.Util.SendWebhookMessage(MessageURL, MessageData)
		end)
	end
end

function DiscordRelay.Util.FetchAvatar(SteamID64, Callback)
	if DiscordRelay.Util.AvatarCache[SteamID64] then
		Callback(DiscordRelay.Util.AvatarCache[SteamID64])
		return
	end

	local XMLURL = Format("https://steamcommunity.com/profiles/%s?xml=1", SteamID64)

	http.Fetch(XMLURL, function(Body)
		local AvatarURL = string.match(Body, "<avatarMedium>%s*<!%[CDATA%[(.-)%]%]>%s*</avatarMedium>")

		if AvatarURL then
			DiscordRelay.Util.AvatarCache[SteamID64] = AvatarURL
		end

		Callback(AvatarURL)
	end, function()
		Callback()
	end)
end

function DiscordRelay.Util.GetDiscordUserName(Author, Member)
	return isstring(Member.nick) and Member.nick or (isstring(Author.global_name) and Author.global_name or Author.username)
end

function DiscordRelay.Util.ColorToDecimal(Color)
	return bit.lshift(Color.r, 16) + bit.lshift(Color.g, 8) + Color.b
end

function DiscordRelay.Util.CreateEmbed(Color, Author, Content)
	return {
		["color"] = DiscordRelay.Util.ColorToDecimal(Color),
		["author"] = Author and { ["name"] = Author } or nil,
		["description"] = Content
	}
end

function DiscordRelay.Util.StoreOnObject(Object, Key, Value)
	if not Object.DiscordRelay then
		Object.DiscordRelay = {}
	end

	Object.DiscordRelay[Key] = Value
end

function DiscordRelay.Util.GetFromObject(Object, Key)
	if not Object.DiscordRelay then
		return nil
	end

	return Object.DiscordRelay[Key]
end
