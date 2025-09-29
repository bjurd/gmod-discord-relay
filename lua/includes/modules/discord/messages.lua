if not util.IsBinaryModuleInstalled("chttp") then
	logging.Log(LOG_WARNING, "CHTTP binary module is not installed! Messages may not be able to be sent!")
else
	require("chttp")
end

local HTTP = CHTTP or HTTP
module("messages", package.discord)

--- @meta
--- @alias Message table
--- @alias Embed table

MessageURL = "https://discord.com/api/v%d/channels/%s/messages"

function MESSAGE_Success(Code)
	if Code == 200 then
		logging.DevLog(LOG_SUCCESS, "Successfully POSTed message")
	else
		-- HTTP is strange...
		MESSAGE_Fail(Code)
	end
end

function MESSAGE_Fail(Code)
	logging.DevLog(LOG_ERROR, "Failed to POST message, code %d", Code)
end

--- POSTs a message
--- @param Socket WEBSOCKET A GWSockets socket instance
--- @param MessageURL string URL to POST to
--- @param Data table Message data
function POSTMessage(Socket, MessageURL, Data)
	local MessageData = util.TableToJSON(Data)

	HTTP({
		["url"] = MessageURL,
		["method"] = "POST",

		["headers"] = {
			["Content-Type"] = "application/json",
			["Content-Length"] = tostring(string.len(MessageData)),
			["Host"] = "discord.com", -- This is required for webhooks, probably a misconfiguration on Discord's side
			["Authorization"] = Format("Bot %s", Socket.Token)
		},
		["type"] = "application/json",

		["body"] = MessageData,

		["success"] = MESSAGE_Success,
		["failed"] = MESSAGE_Fail
	})
end

--- Sends a message to a channel
--- @param Socket WEBSOCKET A GWSockets socket instance
--- @param Channel string Channel snowflake
--- @param Data table Message data
function SendToChannel(Socket, Channel, Data)
	local MessageURL = Format(MessageURL, Socket.API, Channel)

	POSTMessage(Socket, MessageURL, Data)
end


--[[
	Message and Embed builders
--]]

MessageMetatable = {}
MessageMetatable.__index = MessageMetatable

EmbedMetatable = {}
EmbedMetatable.__index = EmbedMetatable

--- Begins a message builder
--- @return Message Message The created Message object. Only default field is allowed_mentions, set to none
function BeginMessage()
	local Message = { ["allowed_mentions"] = { ["parse"] = {} } }
	setmetatable(Message, MessageMetatable)

	return Message
end

--- Sets Message content
--- @param Content string Message content, limited to 2000 characters
--- @return Message self
function MessageMetatable:WithContent(Content)
	self.content = string.sub(tostring(Content), 1, 2000)
	return self
end

--- Begins an embed builder
--- @return Embed Embed
function MessageMetatable:WithEmbed()
	local Embed = {}
	setmetatable(Embed, EmbedMetatable)

	Embed.Message = self

	return Embed
end

--- Ends an embed builder, adds it to its parent, and returns to the Message stack
--- @return Message Parent
function EmbedMetatable:End()
	local Message = self.Message
	self.Message = nil

	if not Message.embeds then
		Message.embeds = {}
	end

	table.insert(Message.embeds, self)

	return Message
end

--- Sets Embed title
--- @param Title string Title content, limited to 64 characters
--- @return Embed self
function EmbedMetatable:WithTitle(Title)
	self.title = string.sub(tostring(Title), 1, 64)
	return self
end

--- Sets Embed description
--- @param Description string Description content, limited to 2000 characters
--- @return Embed self
function EmbedMetatable:WithDescription(Description)
	self.description = string.sub(tostring(Description), 1, 2000)
	return self
end

--- Sets Embed author
--- @param Author table Author data. Name is limited to 32 characters
--- @return Embed self
function EmbedMetatable:WithAuthor(Author)
	self.author = table.Copy(Author)

	if isstring(self.author.Name) then
		self.author.Name = string.sub(self.author.Name, 1, 32)
	end

	return self
end

--- Sets Embed footer
--- @param Footer string Footer content, limited to 128 characters
--- @return Embed self
function EmbedMetatable:WithFooter(Footer)
	self.footer = { ["text"] = string.sub(tostring(Footer), 1, 128) } -- Who tf uses icons in the footer?
	return self
end

--- Sets Embed color
--- @param Color Color
--- @return Embed self
function EmbedMetatable:WithColor(Color)
	self.color = colors.ToDecimal(Color)
	return self
end

--- Sets Embed color
--- @param R number
--- @param G number
--- @param B number
--- @return Embed self
function EmbedMetatable:WithColorRGB(R, G, B)
	self.color = colors.ToDecimalRGB(R, G, B)
	return self
end
