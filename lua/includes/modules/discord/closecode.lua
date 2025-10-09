module("closecode", package.discord)

enums.Create("CLOSECODE", {
	["UNKOWN_ERROR"] = 4000,
	["UNKNOWN_OPCODE"] = 4001,
	["DECODE"] = 4002,
	["NOT_AUTHED"] = 4003,
	["AUTH_FAILED"] = 4004,
	["ALREADY_AUTHED"] = 4005,
	["INVALID_SESSION"] = 4006, -- Undocumented
	["INVALID_SEQ"] = 4007,
	["RATELIMITED"] = 4008,
	["SESSION_TIMED_OUT"] = 4009,
	["INVALID_SHARD"] = 4010,
	["SHARD_REQUIRED"] = 4011,
	["INVALID_API"] = 4012,
	["INVALID_INTENTS"] = 4013,
	["DISALLOWED_INTENTS"] = 4014
})

--- closecodes that are not able to be resumed from
Reconnectable = {
	[CLOSECODE_AUTH_FAILED] = false,
	-- [CLOSECODE_INVALID_SESSION] = false, -- Unknown if this can be resumed from or not, give it a shot!
	[CLOSECODE_INVALID_SHARD] = false,
	[CLOSECODE_SHARD_REQUIRED] = false,
	[CLOSECODE_INVALID_API] = false,
	[CLOSECODE_INVALID_INTENTS] = false,
	[CLOSECODE_DISALLOWED_INTENTS] = false
}

--- Returns whether or not a closecode is able to be reconnected from
--- @param CloseCode number See CLOSECODE_ enums
--- @return boolean
function CanReconnect(CloseCode)
	return Reconnectable[CloseCode] ~= false
end
