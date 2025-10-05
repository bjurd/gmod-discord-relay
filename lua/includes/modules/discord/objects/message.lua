--- @class Message
--- @field Content string
--- @field Embeds table
--- @field Username string|nil
local MESSAGE = {}
MESSAGE.__index = MESSAGE

function MESSAGE:__new()
	self.Content = ""
	self.Embeds = {}
	self.Username = nil

	-- TODO: AllowedMentions
end

function MESSAGE:__json()
	local SelfParse = {
		content = self.Content,
		embeds = {},
		username = self.Username
	}

	local EmbedCount = #self.Embeds
	for i = 1, EmbedCount do
		local Embed = self.Embeds[i]
		table.insert(SelfParse.embeds, Embed:__json())
	end

	return SelfParse
end

--- Sets Message content
--- @param Content string Message content, will fail to send if >2000 characters
--- @return Message self
function MESSAGE:WithContent(Content)
	self.Content = Content
	return self
end

--- Sets Message username
--- Meant for use with Webhooks
--- @param Username string|nil Message username, will fail to send if >32 characterss. Set to nil to remove
--- @return Message self
function MESSAGE:WithUsername(Username)
	self.Username = Username or nil
	return self
end

--- Begins an embed builder
--- @return Embed Embed
function MESSAGE:WithEmbed()
	local Embed = oop.CreateNew("Embed")
	Embed.Message = self

	return Embed
end

return MESSAGE
