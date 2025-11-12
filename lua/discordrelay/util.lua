relay.util = relay.util or {}
local rutil = relay.util

--- Finds a player by the provided token
--- @param Token string Username, SteamID or SteamID64
--- @return Player|false
function rutil.FindPlayer(Token)
	local Found = player.GetBySteamID(Token) or player.GetBySteamID64(Token)
	if Found then return Found end

	Token = string.lower(Token)

	for _, Player in player.Iterator() do
		if string.find(string.lower(Player:GetName()), Token) then
			Found = Player
			break
		end
	end

	return Found
end

--- Formats seconds into a time format, similar to string.NiceTime
--- @param Seconds number The time in seconds
--- @return string
function rutil.FormatTime(Seconds)
	local Weeks = math.floor(Seconds / 604800)
	local Days = math.floor((Seconds / 86400) % 7)
	local Hours = math.floor((Seconds / 3600) % 24)
	local Minutes = math.floor((Seconds / 60) % 60)
	local Seconds = math.floor(Seconds % 60)

	local Parts = {}

	if Weeks > 0 then Parts[#Parts + 1] = Weeks .. "w" end
	if Days > 0 then Parts[#Parts + 1] = Days .. "d" end
	if Hours > 0 then Parts[#Parts + 1] = Hours .. "h" end
	if Minutes > 0 then Parts[#Parts + 1] = Minutes .. "m" end
	if Seconds > 0 then Parts[#Parts + 1] = Seconds .. "s" end

	if #Parts < 1 then
		return "0s"
	end

	return table.concat(Parts, " ")
end

--- Returns if something is a string and is not empty (0 length)
--- @param Object any
--- @return boolean
function rutil.IsNonEmptyStr(Object)
	return isstring(Object) and string.len(Object) > 0
end

--- Return's a User's name
--- Goes in order of Display Name and Username. Will return the User Snowflake as a final fallback if the username is blank
--- @param User User
--- @return string
function rutil.GetUserName(User)
	local DisplayName = User:GetDisplayName()
	local Username = User:GetUsername()

	if rutil.IsNonEmptyStr(DisplayName) then return DisplayName end
	if rutil.IsNonEmptyStr(Username) then return Username end

	return User:GetID()
end

--- Returns a Member's name
--- Goes in order of Nickname, Display Name and Username. Will return the User Snowflake as a final fallback if the username is blank
--- @param User User
--- @param Member Member
--- @return string
function rutil.GetMemberName(User, Member)
	local Nickname = Member:GetNickname()

	if rutil.IsNonEmptyStr(Nickname) then
		return Nickname
	else
		return rutil.GetUserName(User)
	end
end

--- Cleans a string of any markdown sequences it may possess
--- @param String string
--- @return string
function rutil.MarkdownEscape(String)
	String = string.gsub(String, "([\\%*_%`~>|#])", "\\%1")

	-- Lists
	String = string.gsub(String, "(\r?\n)%s*([-+*])%s", "%1\\%2 ")
	if string.match(String, "^[%s]*[-+*]%s") then
		String = string.gsub(String, "^%s*([-+*])%s", "\\%1 ")
	end

	-- Numbered lists
	String = string.gsub(String, "(\r?\n)%s*(%d+)%.%s", "%1%2\\. ")
	if string.match(String, "^[%s]*%d+%.%s") then
		String = string.gsub(String, "^%s*(%d+)%.%s", "%1\\. ")
	end

	return String -- LuaLS crying about multiple returns
end

--- Limits a username (or any string really) to 32 characters
--- @param Username string
--- @return string
function rutil.LimitUsername(Username)
	Username = string.Left(Username, 32)

	if string.len(Username) < 2 then
		Username = "Player"
	end

	return Username
end

--- Fixes up an in-game username for display in a Discord message
--- @param Username string
--- @return string
function rutil.CleanUsername(Username)
	Username = rutil.LimitUsername(Username)
	Username = rutil.MarkdownEscape(Username)

	return Username
end

--- Returns (or attempts to) a Player's Steam name
--- TODO: Make this use the Steam API
--- @param Player Player
--- @return string
function rutil.GetPlayerName(Player)
	--- @diagnostic disable: undefined-field
	if isfunction(Player.RealName) then -- Player SetName For ULX
		return Player:RealName()
	end
	--- @diagnostic enable: undefined-field

	return Player:GetName()
end
