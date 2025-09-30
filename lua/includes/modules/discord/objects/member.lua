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
	local Highest -- This is garunteed to become a Role because of the @everyone role
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
		logging.Log(LOG_ERROR, "Somehow had a Member with no roles? This should never happen!")
	end

	return Highest
end

return MEMBER
