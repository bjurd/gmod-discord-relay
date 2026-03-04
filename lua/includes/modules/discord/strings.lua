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

--- @param Code number
--- @return boolean
function IsCombiningCode(Code)
	if Code >= 0x0300 and Code <= 0x036F then return true end

	if Code >= 0x0591 and Code <= 0x05BD then return true end
	if Code == 0x05BF then return true end
	if Code >= 0x05C1 and Code <= 0x05C2 then return true end
	if Code >= 0x05C4 and Code <= 0x05C7 then return true end

	if Code == 0x200B or Code == 0x200C or Code == 0x200D or Code == 0x2060 or (Code >= 0x200E and Code <= 0x200F) or (Code >= 0x202A and Code <= 0x202E) then
		return true
	end

	return false
end

--- Cleans a username of invalid characters/sequences
--- @param Username string
--- @return string
function CleanUsername(Username)
	local Cleaned = {}

	for _, Code in utf8.codes(Username) do
		if Code >= 32 and Code ~= 127 then
			if not IsCombiningCode(Code) then
				table.insert(Cleaned, utf8.char(Code))
			end
		end
	end

	Username = table.concat(Cleaned)

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
