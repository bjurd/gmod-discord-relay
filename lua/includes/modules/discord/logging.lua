module("logging", package.discord)

enums.CreateIncremental("LOG", {
	"NORMAL",
	"WARNING",
	"ERROR",
	"SUCCESS"
})

--- Returns a color depending on the given LOG_ type, defaults to white
--- @param Type number The type of message, use LOG_ enums
--- @return Color Color The log message color
function GetLogColor(Type)
	if Type == LOG_WARNING then
		return Color(255, 200, 100, 255)
	elseif Type == LOG_ERROR then
		return Color(255, 100, 100, 255)
	elseif Type == LOG_SUCCESS then
		return Color(100, 255, 100, 255)
	else
		-- DEV and invalid values get white
		return Color(255, 255, 255, 255)
	end
end

--- Sends a message to the console of the given type
--- @param Type number The type of message, use LOG_ enums
--- @param Message string The message, supports string formatting
--- @param ... any Format arguments
function Log(Type, Message, ...)
	if Type == LOG_DEV and not IsDeveloper() then return end

	local MessageColor = GetLogColor(Type)
	Message = Format(Message, ...)

	MsgC(Color(88, 101, 242, 255), "[discordRelay] ", MessageColor, Message)
	MsgN()
end

--- Sends a message to the console of the given type only if developer mode is enabled
--- @param Type number The type of message, use LOG_ enums
--- @param Message string The message, supports string formatting
--- @param ... any Format arguments
function DevLog(Type, Message, ...)
	if not IsDeveloper() then return end

	Log(Type, Message, ...)
end

--- Sends a message to the console of the given type only if higher developer mode is enabled
--- @param Type number The type of message, use LOG_ enums
--- @param Message string The message, supports string formatting
--- @param ... any Format arguments
function HighDevLog(Type, Message, ...)
	if not IsHigherDeveloper() then return end

	Log(Type, Message, ...)
end
