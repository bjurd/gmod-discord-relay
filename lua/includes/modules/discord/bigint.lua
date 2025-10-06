module("bigint", package.discord)

local MaxBit = 32
local MaxValue = math.pow(2, MaxBit)

--- Multiplies hi and lo by 10 and adds d
--- @param hi number
--- @param lo number
--- @param d number
--- @return number, number
function Mul10(hi, lo, d)
	local lo_p = (lo * 10) + d
	local lo_n = lo_p % MaxValue
	local Carry = (lo_p - lo_n) / MaxValue

	local hi_p = (hi * 10) + Carry
	local hi_n = hi_p % MaxValue

	return hi_n, lo_n
end

--- Splits a bigint into hi and lo
--- @param BigInt string
--- @return number, number
function Split(BigInt)
	local hi, lo = 0, 0

	local Length = string.len(BigInt)
	for i = 1, Length do
		local Byte = string.byte(BigInt, i)
		local Decimal = Byte - 48

		hi, lo = Mul10(hi, lo, Decimal)
	end

	return hi, lo
end

--- Combines hi and lo back into a bigint
--- @param hi number
--- @param lo number
--- @return string
function Combine(hi, lo)
	if hi == 0 then return tostring(lo) end
	if lo == 0 then return tostring(hi * MaxValue) end

	local Parts = {}

	while hi > 0 do
		local rem = (hi % 1e9) * MaxValue + lo
		local rem_lo = rem % 1e9

		lo = rem_lo
		hi = math.floor(hi / 1e9)

		table.insert(Parts, string.format("%09d", rem_lo))
	end

	if hi > 0 then
		table.insert(Parts, tostring(hi))
	end

	local is = math.floor(#Parts * 0.5)
	for i = 1, is do
		local j = #Parts - i + 1
		Parts[i], Parts[j] = Parts[j], Parts[i]
	end

	local BigInt = table.concat(Parts)
	return (string.gsub(BigInt, "^0+", "")) ~= "" and (string.gsub(BigInt, "^0+", "")) or "0" -- Remove leading 0's
end

--- Splits a bigint bitflag into hi and lo
--- @param Flag string|number
--- @return number, number
function SplitFlag(Flag)
	if isnumber(Flag) then
		local flo = Flag % MaxValue
		local fhi = (Flag - flo) / MaxValue

		return fhi, flo
	else
		Flag = tostring(Flag) -- LuaLS crying again
		return Split(Flag)
	end
end

--- Tests if a bit is set
--- @param BigInt string
--- @param Bit number
--- @return boolean
function IsBitSet(BigInt, Bit)
	local hi, lo = Split(BigInt)

	if Bit < MaxBit then
		return bit.band(lo, bit.lshift(1, Bit)) ~= 0
	else
		return bit.band(hi, bit.lshift(1, Bit - MaxBit)) ~= 0
	end
end

--- Tests if a bitflag is set
--- @param BigInt string
--- @param Flag number|string
--- @return boolean
function IsBitflagSet(BigInt, Flag)
	local hi, lo = Split(BigInt)

	if isnumber(Flag) and Flag < MaxValue then
		return bit.band(lo, Flag) ~= 0
	else
		local fhi, flo = SplitFlag(Flag)

		return (bit.band(hi, fhi) == fhi) and (bit.band(lo, flo) == flo)
	end
end

--- Adds a bitflag
--- @param BigInt string
--- @param Flag number|string
--- @return number, number
function AddBitflag(BigInt, Flag)
    local hi, lo = Split(BigInt)
    local fhi, flo = SplitFlag(Flag)

    return bit.bor(hi, fhi), bit.bor(lo, flo)
end
