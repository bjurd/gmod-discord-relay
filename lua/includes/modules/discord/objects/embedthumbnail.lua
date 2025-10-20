--- @class EmbedThumbnail
--- @field URL string
--- @field Width number
--- @field Height number
--- @field Embed Embed
local ETHUMB = {}
ETHUMB.__index = ETHUMB

function ETHUMB:__new()
	self.URL = ""
	self.With = 64 -- TODO: Setters for these (Even though they don't seem to work)
	self.Height = 64
end

function ETHUMB:__json()
	return {
		url = self.URL,
		width = self.Width,
		height = self.Height
	}
end

--- Sets image URL
--- @param URL string
--- @return EmbedThumbnail self
function ETHUMB:WithURL(URL)
	self.URL = URL
	return self
end

--- Ends an EmbedThumbnail builder and returns to the Embed stack
--- @return Embed Parent
function ETHUMB:End()
	return self.Embed
end

return ETHUMB
