--- @class Embed
--- @field Title string
--- @field Description string
--- @field URL string
--- @field Color number
--- @field Footer EmbedFooter
--- @field Author EmbedAuthor
local EMBED = {}
EMBED.__index = EMBED

function EMBED:__new()
	self.Title = ""
	self.Description = ""
	self.URL = ""
	self.Color = 0
	self.Footer = oop.CreateNew("EmbedFooter")
	self.Author = oop.CreateNew("EmbedAuthor")
end

function EMBED:__json()
	local SelfParse = {
		title = self.Title,
		description = self.Description,
		url = self.URL,
		color = self.Color
	}

	SelfParse.footer = self.Footer:__json()
	SelfParse.author = self.Author:__json()

	return SelfParse
end

--- Sets Embed title
--- @param Title string Title content, limited to 64 characters
--- @return Embed self
function EMBED:WithTitle(Title)
	self.Title = string.sub(tostring(Title), 1, 64)
	return self
end

--- Sets Embed description
--- @param Description string Description content, limited to 2000 characters
--- @return Embed self
function EMBED:WithDescription(Description)
	self.Description = string.sub(tostring(Description), 1, 2000)
	return self
end

--- Sets Embed color
--- @param Color Color
--- @return Embed self
function EMBED:WithColor(Color)
	self.Color = colors.ToDecimal(Color)
	return self
end

--- Sets Embed color
--- @param R number
--- @param G number
--- @param B number
--- @return Embed self
function EMBED:WithColorRGB(R, G, B)
	self.Color = colors.ToDecimalRGB(R, G, B)
	return self
end

--- Begins EmbedFooter
--- @return EmbedFooter Footer
function EMBED:WithFooter()
	self.Footer.Embed = self

	return self.Footer
end

--- Begins EmbedAuthor
--- @return EmbedAuthor Author
function EMBED:WithAuthor()
	self.Author.Embed = self

	return self.Author
end

--- Ends an embed builder, adds it to its parent, and returns to the Message stack
--- @return Message Parent
function EMBED:End()
	local Message = self.Message
	self.Message = nil

	table.insert(Message.Embeds, self)

	return Message
end

return EMBED
