DiscordRelay.Util = DiscordRelay.Util or {}

DiscordRelay.Util.NoOp = function() return end

DiscordRelay.Util.WebhookCache = DiscordRelay.Util.WebhookCache or {}

DiscordRelay.Util.AvatarCache = DiscordRelay.Util.AvatarCache or {}

DiscordRelay.Util.RoleCache = DiscordRelay.Util.RoleCache or {}

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

function DiscordRelay.Util.GetWebhookID(WebhookURL)
	return string.match(WebhookURL, "webhooks/(%d+)/")
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

			local MessageURL = Format("https://discord.com/api/webhooks/%s/%s", WebhookID, WebhookToken)

			DiscordRelay.Util.WebhookCache[WebhookID] = {
				["MessageURL"] = MessageURL,
				["Data"] = Data
			}

			Callback(MessageURL)
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

			local MessageURL = Format("https://discord.com/api/webhooks/%s/%s", WebhookID, WebhookToken)

			DiscordRelay.Util.WebhookCache[WebhookID] = {
				["MessageURL"] = MessageURL,
				["Data"] = Data[i]
			}

			Callback(MessageURL)

			return
		end

		DiscordRelay.Util.CreateWebhook(WebhookURL, Callback)
	end
end

function DiscordRelay.Util.GetWebhook(ChannelID, Callback)
	if DiscordRelay.Util.WebhookCache[ChannelID] then
		Callback(DiscordRelay.Util.WebhookCache[ChannelID].MessageURL)
		return
	end

	local WebhookURL = Format("https://discord.com/api/v%d/channels/%s/webhooks", DiscordRelay.Config.API, ChannelID)

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

function DiscordRelay.Util.CheckWebhookMessage(OriginalMessageURL, MessageData)
	return function(Code)
		-- Webhook cache went invalid, reobtain
		if Code == 404 then
			local WebhookID = DiscordRelay.Util.GetWebhookID(OriginalMessageURL)

			if WebhookID then
				DiscordRelay.Util.WebhookCache[WebhookID] = nil
			end

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

		["success"] = NoRetry and DiscordRelay.Util.NoOp or DiscordRelay.Util.CheckWebhookMessage(MessageURL, MessageData),
		["failed"] = DiscordRelay.Util.NoOp
	})
end

function DiscordRelay.Util.WebhookAutoSend(MessageData, SteamID64)
	if DiscordRelay.Config.ShowProfilePictures and isstring(SteamID64) then
		DiscordRelay.Util.FetchAvatar(SteamID64, function(AvatarURL)
			MessageData["avatar_url"] = AvatarURL

			DiscordRelay.Util.GetWebhook(DiscordRelay.Config.ChannelID, function(MessageURL)
				DiscordRelay.Util.SendWebhookMessage(MessageURL, MessageData)
			end)
		end)
	else
		DiscordRelay.Util.GetWebhook(DiscordRelay.Config.ChannelID, function(MessageURL)
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

function DiscordRelay.Util.FetchGuildRoles(Callback, Force)
	if not Force and next(DiscordRelay.Util.RoleCache) then
		Callback(DiscordRelay.Util.RoleCache)
		return
	end

	local RoleURL = Format("https://discord.com/api/v%d/guilds/%s/roles", DiscordRelay.Config.API, DiscordRelay.Config.GuildID)

	CHTTP({
		["url"] = RoleURL,
		["method"] = "GET",

		["headers"] = {
			["Authorization"] = Format("Bot %s", DiscordRelay.Config.Token)
		},

		["success"] = function(Code, Body)
			local Roles = util.JSONToTable(Body) or {}
			local Dict = {}

			for i = 1, #Roles do
				Dict[Roles[i].id] = Roles[i]
			end

			DiscordRelay.Util.RoleCache = Dict

			Callback(Dict)
		end,

		["failed"] = function(err)
			Callback(nil)
		end
	})
end

function DiscordRelay.Util.MemberRolesCached(Member, Dict)
	if not Member.roles then return true end

	for i = 1, #Member.roles do
		local ID = Member.roles[i]

		if not Dict[ID] then
			return false
		end
	end

	return true
end

function DiscordRelay.Util.GetUserRoleColor(Member, Callback)
	if not Member.roles or #Member.roles < 1 then
		Callback(nil)
		return
	end

	local function ProcessRoles(Dict)
		local BestRole = nil

		for i = 1, #Member.roles do
			local RoleID = Member.roles[i]
			local Role = Dict[RoleID]

			if Role and Role.color and Role.color > 0 then
				if not BestRole or (Role.position and BestRole.position and Role.position > BestRole.position) then
					BestRole = Role
				end
			end
		end

		if BestRole then
			Callback(DiscordRelay.Util.DecimalToColor(BestRole.color))
		else
			Callback(nil)
		end
	end

	if next(DiscordRelay.Util.RoleCache) and DiscordRelay.Util.MemberRolesCached(Member, DiscordRelay.Util.RoleCache) then
		ProcessRoles(DiscordRelay.Util.RoleCache)
	else
		DiscordRelay.Util.FetchGuildRoles(function(Dict)
			if Dict then
				ProcessRoles(Dict)
			else
				Callback(nil)
			end
		end, true)
	end
end

function DiscordRelay.Util.GetDiscordUserName(Author, Member)
	return isstring(Member.nick) and Member.nick or (isstring(Author.global_name) and Author.global_name or Author.username)
end

function DiscordRelay.Util.ColorToDecimal(Color)
	return bit.lshift(Color.r, 16) + bit.lshift(Color.g, 8) + Color.b
end

function DiscordRelay.Util.DecimalToColor(Decimal)
	local R = bit.rshift(Decimal, 16) % 256
	local G = bit.band(bit.rshift(Decimal, 8), 0xFF)
	local B = bit.band(Decimal, 0xFF)

	return Color(R, G, B)
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
