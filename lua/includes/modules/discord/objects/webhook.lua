--- @class Webhook
--- @field Snowflake string
--- @field ChannelID string
--- @field GuildID string
--- @field URL string
--- @field Token string
local WEBHOOK = {}
WEBHOOK.__index = WEBHOOK

function WEBHOOK:__new()
	self.Snowflake = ""
	self.ChannelID = ""
	self.GuildID = ""
	self.URL = ""
	self.Token = ""
end

function WEBHOOK:__constr(Data)
	self.Snowflake = Data.id
	self.ChannelID = Data.channel_id
	self.GuildID = Data.guild_id
	self.URL = Data.url or "" -- These can be empty if the webhook is application owned
	self.Token = Data.token or ""
end

function WEBHOOK:__tostring()
	return Format("Webhook [%s][%s][%s]", self.GuildID, self.ChannelID, self.Snowflake)
end

--- Returns the URL
--- @return string
function WEBHOOK:GetURL()
	return self.URL
end

--- Returns if the Webhook is able to be POSTed to (Whether or not URL is valid)
--- @return boolean
function WEBHOOK:IsUseable()
	local URL = self:GetURL()
	if string.len(URL) < 1 then return false end

	local ConstructedURL = Format("https://discord.com/api/webhooks/%s/%s", self.Snowflake, self.Token)

	return URL == ConstructedURL
end

return WEBHOOK
