--- @class Message
--- @field Content string
--- @field Embeds table
local MESSAGE = {}
MESSAGE.__index = MESSAGE

function MESSAGE:__new()
	self.Content = ""
	self.Embeds = {}

	-- TODO: AllowedMentions
end

function MESSAGE:__json()
	local SelfParse = {
		content = self.Content,
		embeds = {}
	}

	local EmbedCount = #self.Embeds
	for i = 1, EmbedCount do
		local Embed = self.Embeds[i]
		table.insert(SelfParse.embeds, Embed:__json())
	end

	return SelfParse
end

--- Sets Message content
--- @param Content string Message content, limited to 2000 characters
--- @return Message self
function MESSAGE:WithContent(Content)
	self.Content = string.sub(tostring(Content), 1, 2000)
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
