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
function ROLE:GetID()
	return self.Snowflake
end

--- Returns the display name
--- @return string
function ROLE:GetName()
	return self.Name
end

--- Returns the high and low permissions bits
--- @return number, number
function ROLE:GetPermissions()
	return discord.bigint.Split(self.Permissions)
end

--- Returns the raw permissions bits
--- @return string
function ROLE:GetPermissionValue()
	return self.Permissions
end

--- Returns the Color as a decimal
--- @return number
function ROLE:GetColorDecimal()
	return self.Color
end

--- Returns the Color as a Garry's Mod Color
--- @return Color
function ROLE:GetColor()
	return discord.colors.FromDecimal(self:GetColorDecimal())
end

--- Returns if the role is a managed role
--- @return boolean
function ROLE:IsManaged()
	return self.Managed
end

return ROLE
