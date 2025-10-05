--- @class EmbedAuthor
--- @field Name string
--- @field Embed Embed
local EAUTHOR = {}
EAUTHOR.__index = EAUTHOR

function EAUTHOR:__new()
	self.Name = ""
	self.Embed = nil
end

function EAUTHOR:__json()
	return {
		name = self.Name
	}
end

--- Sets EmbedAuthor name
--- @param Name string Name, will fail to send if >256 characters
--- @return EmbedAuthor self
function EAUTHOR:WithName(Name)
	self.Name = Name
	return self
end

--- Ends an EmbedAuhtor builder and returns to the Embed stack
--- @return Embed Parent
function EAUTHOR:End()
	return self.Embed
end

return EAUTHOR
