--- @class Member
--- @field Nickname string
--- @field Roles table
local MEMBER = {}
MEMBER.__index = MEMBER

function MEMBER:__new()
	self.Nickname = ""
	self.Roles = {}
end

function MEMBER:__constr(Data)
	self.Nickname = Data.nick
	self.Roles = Data.roles -- TODO: Construct actual Role objects
end

function MEMBER:__tostring()
	return Format("Member [%s]", self.Nickname)
end

--- Returns the nickname
--- @return string
function MEMBER:GetNickname()
	return self.Nickname
end

--- Returns the Roles table
--- @return table
function MEMBER:GetRoles()
	return self.Roles
end

--- Returns the highest Role (based on position)
--- @param Roles table The Role table from roles.GetGuildRoles
--- @return Role
function MEMBER:GetHighestRole(Roles)
	local Highest
	local MemberRoles = self:GetRoles()

	for i = 1, #Roles do
		local Role = Roles[i]

		if table.HasValue(MemberRoles, Role:GetID()) then -- HasValue is icky, but the Member role list is sequential
			if not Highest then Highest = Role end

			if Role:GetPosition() > Highest:GetPosition() then
				Highest = Role
			end
		end
	end

	if not Highest then
		-- TODO:
		-- The @everyone role isn't present in the Member role list for some reason,
		-- so this will just assume the @everyone role is the first role in the list.
		-- It should always be first, but some checks should be added to make sure
		Highest = Roles[1]
		Highest.Color = 16777215 -- TODO: @everyone has a color of 0, but it should be white
	end

	return Highest
end

--- Returns the Role color used for the member's name
--- @param Roles table The Role table from roles.GetGuildRoles
--- @return Color
function MEMBER:GetNameColor(Roles)
	local Highest
	local MemberRoles = self:GetRoles()

	for i = 1, #Roles do
		local Role = Roles[i]
		if Role:GetColorDecimal() == 0 then continue end

		if table.HasValue(MemberRoles, Role:GetID()) then -- HasValue is icky, but the Member role list is sequential
			if not Highest then Highest = Role end

			if Role:GetPosition() > Highest:GetPosition() then
				Highest = Role
			end
		end
	end

	if not Highest then
		return Color(255, 255, 255, 255)
	else
		return Highest:GetColor()
	end
end

return MEMBER
