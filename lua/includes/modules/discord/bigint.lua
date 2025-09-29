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
--- @param Flag number
--- @return boolean
function IsBitflagSet(BigInt, Flag)
	local hi, lo = Split(BigInt)

	if Flag < MaxValue then
		return bit.band(lo, Flag) ~= 0
	else
		local flo = Flag % MaxValue
		local fhi = (Flag - flo) / MaxValue

		return (bit.band(hi, fhi) ~= 0) or (bit.band(lo, flo) ~= 0)
	end
end
