module("colors", package.discord)

--- Converts a Color to a decimal that can be used by Discord. No alpha support
--- @param Color Color
--- @return number
function ToDecimal(Color)
	return ToDecimalRGB(Color.r, Color.g, Color.b)
end

--- Converts RGB values to a decimal that can be used by Discord
--- @param R number
--- @param G number
--- @param B number
--- @return number
function ToDecimalRGB(R, G, B)
	return bit.lshift(R, 16) + bit.lshift(G, 8) + B
end

--- Converts a decimal value back to a Color
--- @param Value number
--- @return Color
function FromDecimal(Value)
	local R, G, B = FromDecimalRGB(Value)

	return Color(R, G, B, 255)
end

--- Converts a decimal value back to a RGB values
--- @param Value number
--- @return number R, number G, number B
function FromDecimalRGB(Value)
	local R = bit.rshift(Value, 16) % 256
	local G = bit.band(bit.rshift(Value, 8), 0xFF)
	local B = bit.band(Value, 0xFF)

	return R, G, B
end
