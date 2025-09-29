--- @class EmbedFooter
--- @field Text string
--- @field Embed Embed
local EFOOTER = {}
EFOOTER.__index = EFOOTER

function EFOOTER:__new()
	self.Text = ""
	self.Embed = nil
end

function EFOOTER:__json()
	return {
		text = self.Text
	}
end

--- Sets EmbedFooter text
--- @param Text string
--- @return EmbedFooter self
function EFOOTER:WithText(Text)
	self.Text = Text
	return self
end

--- Ends an EmbedFooter builder and returns to the Embed stack
--- @return Embed Parent
function EFOOTER:End()
	return self.Embed
end

return EFOOTER
