module("logging", package.discord)

enums.CreateIncremental("LOG", {
	"NORMAL",
	"WARNING",
	"ERROR",
	"SUCCESS",

	"DEV",
	"DEV_WARN",
	"DEV_ERROR",
	"DEV_SUCCESS"
})

--- Returns a color depending on the given LOG_ type, defaults to white
--- @param Type number The type of message, use LOG_ enums
--- @return Color Color The log message color
function GetLogColor(Type)
	if Type == LOG_WARNING or Type == LOG_DEV_WARN then
		return Color(255, 200, 100, 255)
	elseif Type == LOG_ERROR or Type == LOG_DEV_ERROR then
		return Color(255, 100, 100, 255)
	elseif Type == LOG_SUCCESS or Type == LOG_DEV_SUCCESS then
		return Color(100, 255, 100, 255)
	else
		-- Normal and invalid values get white
		return Color(255, 255, 255, 255)
	end
end

--- Returns if a value is a DEV log type or not
--- @param Type number The type of message, use LOG_ enums
--- @return boolean
function IsDevLogEqv(Type)
	return Type >= LOG_DEV
end

--- Returns the enumeration value corresponding to the DEV equivalent of a LOG_ type
--- @param Type number The type of message, use LOG_ enums
--- @return number The DEV equivalent, LOG_DEV on failure (Same as LOG_NORMAL), or the passed in value if it's already a DEV equivalent
function GetLogDevEqv(Type)
	if IsDevLogEqv(Type) then return Type end

	if Type == LOG_WARNING then
		return LOG_DEV_WARN
	elseif Type == LOG_ERROR then
		return LOG_DEV_ERROR
	elseif Type == LOG_SUCCESS then
		return LOG_DEV_SUCCESS
	else
		return LOG_DEV
	end
end

--- Writes a log line to the log file specified in the config. Appends a timestamp to the front of the log message
--- @param Type number The type of message, use LOG_ enums
--- @param Message string The message
function WriteLogLn(Type, Message)
	if not istable(relay) or not isfunction(relay.GetLogPath) then return end

	if IsDevLogEqv(Type) and Type == LOG_DEV then
		-- Don't flood the log with miscellaneous DEV messages
		-- only show DEV warning, error and success messages
		-- return
		-- On second thought, who cares :^)
	end

	local LogPath = relay.GetLogPath()
	if not LogPath then return end

	local Timestamp = os.date("%c", os.time())

	local LogLine = Format("%s - %s\n", Timestamp, Message)

	if not file.Append(LogPath, LogLine) then
		-- This will spam like hell
		Log(LOG_ERROR, "Failed to write log line - Check your config's logfile path!")
	end
end

--- Writes a log line to the log file specified in the config. Appends a timestamp to the front of the log message
--- @param Type number The type of message, use LOG_ enums
--- @param Message string The message, supports string formatting
--- @param ... any Format arguments
function WriteLog(Type, Message, ...)
	WriteLogLn(Type, strings.SafeFormat(Message, ...))
end

--- Sends a message to the console of the given type and writes it to the log file
--- @param Type number The type of message, use LOG_ enums
--- @param Message string The message, supports string formatting
--- @param ... any Format arguments
function Log(Type, Message, ...)
	local MessageColor = GetLogColor(Type)
	Message = strings.SafeFormat(Message, ...)

	MsgC(Color(88, 101, 242, 255), "[discordRelay] ", MessageColor, Message)
	MsgN()

	WriteLogLn(Type, Message)
end

--- Logs a message only if developer mode is enabled
--- @param Type number The type of message, use LOG_ enums
--- @param Message string The message, supports string formatting
--- @param ... any Format arguments
function DevLog(Type, Message, ...)
	Type = GetLogDevEqv(Type)

	if not IsDeveloper() then
		-- Still write devlogs to the log in case something important is in them
		WriteLog(Type, Message, ...)
		return
	end

	Log(Type, Message, ...)
end

--- Logs a message only if higher developer mode is enabled
--- @param Type number The type of message, use LOG_ enums
--- @param Message string The message, supports string formatting
--- @param ... any Format arguments
function HighDevLog(Type, Message, ...)
	Type = GetLogDevEqv(Type)

	if not IsHigherDeveloper() then
		WriteLog(Type, Message, ...)
		return
	end

	Log(Type, Message, ...)
end
