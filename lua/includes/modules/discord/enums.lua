module("enums", package.discord)

--- Creates global enumerations. Prefix and Keys are automatically converted to uppercase and trimmed
--- @param Prefix string The prefix each enumeration will have (eg "LOG")
--- @param KeyValues table The names and values of each enumeration (eg `{ WARNING = 1, ERROR = 2 }`)
function Create(Prefix, KeyValues)
	Prefix = string.upper(Prefix)
	Prefix = string.Trim(Prefix)

	for Name, Value in next, KeyValues do
		Name = string.upper(Name)
		Name = string.Trim(Name)
		Name = Format("%s_%s", Prefix, Name)

		_G[Name] = Value
	end
end

--- Creates global incrementally valued enumerations starting at 0
--- @param Prefix string The prefix each enumeration will have (eg "OPERATION")
--- @param Names table The names of each enumeration (eg `{ "DISPATCH", "HEARTBEAT" }`)
function CreateIncremental(Prefix, Names)
	local KeyValues = {}

	local Count = #Names
	for i = 1, Count do
		local Name = Names[i]

		KeyValues[Name] = i - 1
	end

	Create(Prefix, KeyValues)
end

--- Creates global left shifted enumerations starting at 1
--- @param Prefix string The prefix each enumeration will have (eg "INTENT")
--- @param Names table The names of each enumeration (eg `{ "GUILDS", "MEMBERS" }`)
function CreateShifted(Prefix, Names)
	local KeyValues = {}

	local Count = #Names
	for i = 1, Count do
		local Name = Names[i]

		KeyValues[Name] = bit.lshift(1, i - 1)
	end

	Create(Prefix, KeyValues)
end
