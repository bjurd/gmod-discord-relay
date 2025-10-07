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
