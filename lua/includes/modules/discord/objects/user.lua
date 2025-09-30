--- @class User
--- @field Snowflake string
--- @field Username string
--- @field DisplayName string
local USER = {}
USER.__index = USER

function USER:__new()
	self.Snowflake = ""
	self.Username = ""
	self.DisplayName = ""
end

function USER:__constr(Data)
	self.Snowflake = Data.id
	self.Username = Data.username
	self.DisplayName = Data.global_name
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

return USER
