--- @class Role
--- @field Snowflake string
--- @field Name string
--- @field Permissions string
--- @field Color number
--- @field Managed boolean
local ROLE = {}
ROLE.__index = ROLE

function ROLE:__new()
	self.Snowflake = ""
	self.Name = ""
	self.Permissions = ""
	self.Color = 0
	self.Managed = false
end

function ROLE:__constr(Data)
	self.Snowflake = Data.id
	self.Name = Data.name
	self.Permissions = Data.permissions
	self.Color = Data.color
	self.Managed = Data.managed
end

function ROLE:__tostring()
	return Format("Role [%s][%s]", self.Name, self.Snowflake)
end

--- Returns the snowflake ID
--- @return string
function GetID()
	return self.Snowflake
end

--- Returns the display name
--- @return string
function GetName()
	return self.Name
end

--- Returns the high and low permissions bits
--- @return number, number
function GetPermissions()
	return discord.bigint.Split(self.Permissions)
end

--- Returns the Color as a decimal
--- @return number
function GetColorDecimal()
	return self.Color
end

--- Returns the Color as a Garry's Mod Color
--- @return Color
function GetColor()
	return discord.colors.FromDecimal(self:GetColorDecimal())
end

--- Returns if the role is a managed role
--- @return boolean
function IsManaged()
	return self.Managed
end

return ROLE
