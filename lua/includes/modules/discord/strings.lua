module("strings", package.discord)

--- Converts a string to its plural if the amount isn't 1
--- @param String string
--- @param Amount number
--- @param Suffix string|nil The suffix to append, defaults to "s"
function Pluralize(String, Amount, Suffix)
	Suffix = Suffix or "s"

	if Amount == 1 then
		return String
	else
		return String .. Suffix
	end
end

--- Formats a string only if there are format arguments provided
--- @param String string
--- @param ... any
--- @return string
function SafeFormat(String, ...)
	if select("#", ...) > 0 then
		String = Format(String, ...)
	end

	return String
end

--- Cleans a username of invalid characters/sequences
--- @param Username string
--- @return string
function CleanUsername(Username)
	Username = string.gsub(Username, "[@#:`]", "") -- Cannot contain @, #, :, ``` - This seems to be a complete lie because it still works with these names, nice docs!
	Username = string.gsub(Username, "[dD][iI][sS][cC][oO][rR][dD]", "") -- Cannot contain "discord"
	Username = string.gsub(Username, "%s+", " ") -- Collapse repetitive whitespace
	Username = string.Trim(Username)

	local Lower = string.lower(Username)
	if Lower == "everyone" or Lower == "here" then -- Cannot be these
		return "Player"
	end

	local Length = utf8.len(Username)
	if not Length or Length < 2 then
		return "Player"
	end

	return string.Left(Username, 32)
end
