--- @class User
--- @field Snowflake string
--- @field Username string
--- @field DisplayName string
--- @field Bot boolean
local USER = {}
USER.__index = USER

function USER:__new()
	self.Snowflake = ""
	self.Username = ""
	self.DisplayName = ""
	self.Bot = false
end

function USER:__constr(Data)
	self.Snowflake = Data.id
	self.Username = Data.username
	self.DisplayName = Data.global_name
	self.Bot = tobool(Data.bot)
end

function USER:__tostring()
	return Format("User [%s][%s]", self.Username, self.Snowflake)
end

--- Returns the snowflake ID
--- @return string
function USER:GetID()
	return self.Snowflake
end

--- Returns the username
--- @return string
function USER:GetUsername()
	return self.Username
end

--- Returns the display name
--- @return string
function USER:GetDisplayName()
	return self.DisplayName
end

--- Returns if the User is a bot
--- @return boolean
function USER:IsBot()
	return self.Bot
end

return USER
