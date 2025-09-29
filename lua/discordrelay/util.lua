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
	local Days = math.floor(Seconds / 86400)
	local Hours = math.floor((Seconds / 3600) % 24)
	local Minutes = math.floor((Seconds / 60) % 60)
	local Seconds = math.floor(Seconds % 60)

	local Parts = {}

	if Days > 0 then Parts[#Parts + 1] = Days .. "d" end
	if Hours > 0 then Parts[#Parts + 1] = Hours .. "h" end
	if Minutes > 0 then Parts[#Parts + 1] = Minutes .. "m" end
	if Seconds > 0 then Parts[#Parts + 1] = Seconds .. "s" end

	if #Parts < 1 then
		return "0s"
	end

	return table.concat(Parts, " ")
end
