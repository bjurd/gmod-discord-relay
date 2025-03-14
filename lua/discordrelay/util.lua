DiscordRelay.Util = DiscordRelay.Util or {}

DiscordRelay.Util.NoOp = function() return end

function DiscordRelay.Util.RequireModule(Name)
	if not util.IsBinaryModuleInstalled(Name) then
		error(Format("Binary module %s is not installed for Discord Relay!", Name))
	else
		require(Name)
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

function DiscordRelay.Util.CheckWebhookMessage(MessageURL, MessageData)
	return function(Code)
		-- Webhook cache went invalid, reobtain
		if Code == 404 then
			DiscordRelay.Socket.WebhookMessageURL = nil

			DiscordRelay.Util.GetWebhook(function()
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

		["success"] = NoRetry and DiscordRelay.Util.NoOp or DiscordRelay.Util.CheckWebhookMessage(MessageURL, MessageData),
		["failed"] = DiscordRelay.Util.NoOp
	})
end

function DiscordRelay.Util.ColorToDecimal(Color)
	return bit.lshift(Color.r, 16) + bit.lshift(Color.g, 8) + Color.b
end

function DiscordRelay.Util.CreateEmbed(Color, Content)
	return {
		["color"] = DiscordRelay.Util.ColorToDecimal(Color),
		["description"] = Content
	}
end

function DiscordRelay.Util.CreateConnectEmbed(SteamID, Username)
	if DiscordRelay.Config.FilterUsernames then
		Username = DiscordRelay.Util.ASCIIFilter(Username)
	end

	local Description = Format("| %s | %s connected", SteamID, Username)

	if DiscordRelay.Config.EscapeMessages then
		Description = DiscordRelay.Util.MarkdownEscape(Description)
	end

	return DiscordRelay.Util.CreateEmbed(Color(0, 255, 0), Description)
end

function DiscordRelay.Util.CreateDisconnectEmbed(SteamID, Username, Reason)
	if DiscordRelay.Config.FilterUsernames then
		Username = DiscordRelay.Util.ASCIIFilter(Username)
	end

	local Description = Format("| %s | %s disconnected (%s)", SteamID, Username, Reason)

	if DiscordRelay.Config.EscapeMessages then
		Description = DiscordRelay.Util.MarkdownEscape(Description)
	end

	return DiscordRelay.Util.CreateEmbed(Color(255, 0, 0), Description)
end
