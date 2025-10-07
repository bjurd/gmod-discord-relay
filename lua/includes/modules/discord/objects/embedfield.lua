--- @class EmbedField
--- @field Name string
--- @field Value string
--- @field Embed Embed
local EFIELD = {}
EFIELD.__index = EFIELD

function EFIELD:__new()
	self.Name = ""
	self.Value = ""
	self.Embed = nil

	-- TODO: Inline
end

function EFIELD:__json()
	return {
		name = self.Name,
		value = self.Value
	}
end

--- Sets EmbedField name
--- @param Name string Name, will fail to send if >256 characters
--- @return EmbedField self
function EFIELD:WithName(Name)
	self.Name = Name
	return self
end

--- Sets EmbedField Value
--- @param Value string Value, will fail to send if >1024 characters
--- @return EmbedField self
function EFIELD:WithValue(Value)
	self.Value = Value
	return self
end

--- Ends an EmbedField builder and returns to the Embed stack
--- @return Embed Parent
function EFIELD:End()
	return self.Embed
end

return EFIELD
