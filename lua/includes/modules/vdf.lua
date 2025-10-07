--[[


	yoinked from this: https://github.com/qwreey/vdf-lua
	with some fixes because it's a bit bunk

	this won't be needed if https://github.com/Facepunch/garrysmod-requests/issues/2936 happens


--]]

local module = {}
local find = string.find
local insert = table.insert
local concat = table.concat
local remove = table.remove
local format = string.format
local rep = string.rep
local gsub = string.gsub
local sub = string.sub

do
	local escapeMap = {
		n = "\n",
		t = "\t",
		["\\"] = "\\",
		["\""] = "\""
	}
	local stringUnicode = "^([%z\1-\127\194-\244][\128-\191]+)" -- op0
	local stringEscape = "^\\(.)"                             -- op1
	local stringClose = "^\""                                 -- op2 "^\""
	local stringChars = "^([^\\\"]+)"
	local stringCloseWithoutQuotes = "^%s+"
	local stringCharsWithoutQuotes = "^([^\\%s]+)"                   -- op3 "^([^\\\"]+)"
	function module.parseString(str,stringStart,quotes)
		local pos = stringStart+1
		local buffer = {}
		local lastPos = pos

		local strClose = quotes and stringClose or stringCloseWithoutQuotes
		local strChars = quotes and stringChars or stringCharsWithoutQuotes

		while true do
			local startAt,endAt,catch
			startAt,endAt,catch = find(str,stringUnicode,pos)
			local op = -1
			if not startAt then
				startAt,endAt,catch = find(str,stringEscape,pos)
			elseif op == -1 then
				op = 0
			end
			if not startAt then
				startAt,endAt,catch = find(str,strClose,pos)
			elseif op == -1 then
				op = 1
			end
			if not startAt then
				startAt,endAt,catch = find(str,strChars,pos)
			elseif op == -1 then
				op = 2
			end
			if startAt and op == -1 then op = 3 end

			if op == 0 then -- unicode char
				insert(buffer,catch)
				pos = endAt + 1
			elseif op == 1 then -- escape
				local char = escapeMap[catch]
				if not char then
					error(("String Escape '%s' is not expected at position %d"):format(catch,pos))
				end
				insert(buffer,char)
				pos = endAt + 1
			elseif op == 2 then -- close
				return concat(buffer),endAt
			elseif op == 3 then -- ascii str
				insert(buffer,catch)
				pos = endAt + 1
				if sub(str,pos,pos) == "" then
					return concat(buffer),endAt-1
				end
			elseif op == -1 then
				error(("Unexpected token got at position %d"):format(pos))
			end

			if lastPos == pos then
				error("Infinity loop detected")
			end
			lastPos = pos
		end
	end
end

do
	local booleanMap = {
		["true"] = true,
		["false"] = false
	}

	local lineCommentRegex = "[ \t]*//[^\n]*"
	local stackStart = "^[ \t\n]*{"
	local stackEnd   = "^[ \t\n]*}"
	local stringStart = "^[ \t\n]*\""
	local stringStartWithoutQuotes = "^[ \t\n]*([^ \t\n{}]+)"

	local function skipComments(str, pos)
		while true do
			local wsStart, wsEnd = string.find(str, "^[ \t\n\r]+", pos)
			if wsStart then pos = wsEnd + 1 end

			local cStart, cEnd = string.find(str, lineCommentRegex, pos)
			if cStart == pos then
				local nl = string.find(str, "\n", cEnd + 1) or (#str + 1)
				pos = nl
			else
				break
			end
		end
		return pos
	end

	function module.parse(str, config)
		str = str:gsub("\r\n", "\n")

		local keyName
		local keyToggle = false
		local global = {}
		local blockStack = {}
		local current = global
		local currentKey
		local pos = 1
		local length = #str
		local lastPos = pos
		local includes = {}

		while true do
			pos = skipComments(str, pos)
			if pos > length then
				global["#include"] = nil
				global["#base"] = nil
				return global
			end

			local startAt, endAt

			-- stack open {
			startAt, endAt = string.find(str, stackStart, pos)
			if startAt == pos then
				if not keyToggle then error("Unnamed stack is not supported") end
				keyToggle = false
				local lastCurrent = current
				current = {}
				currentKey = keyName
				lastCurrent[keyName] = current
				local header = includes[keyName]
				if header then
					for k,v in pairs(header) do current[k] = v end
				end
				table.insert(blockStack, current)
				pos = endAt + 1
				goto next
			end

			-- stack close }
			startAt, endAt = string.find(str, stackEnd, pos)
			if startAt == pos then
				table.remove(blockStack)
				current = blockStack[#blockStack] or global
				pos = endAt + 1
				goto next
			end

			-- quoted string
			startAt, endAt = string.find(str, stringStart, pos)
			if startAt == pos then
				local parsedStr, parseEndAt = module.parseString(str, endAt, true)
				pos = parseEndAt + 1
				if keyToggle then
					local value = parsedStr
					if config and config.autoType then
						local num = tonumber(parsedStr)
						if num then value = num end
						local bool = booleanMap[value]
						if bool ~= nil then value = bool end
					end
					current[keyName] = value
					keyToggle = false
				else
					keyName = parsedStr
					keyToggle = true
				end
				goto next
			end

			-- unquoted string
			startAt, endAt, parsedStr = string.find(str, stringStartWithoutQuotes, pos)
			if startAt == pos and parsedStr and #parsedStr > 0 then
				pos = endAt + 1
				if keyToggle then
					local value = parsedStr
					if config and config.autoType then
						local num = tonumber(parsedStr)
						if num then value = num end
						local bool = booleanMap[value]
						if bool ~= nil then value = bool end
					end
					current[keyName] = value
					keyToggle = false
				else
					keyName = parsedStr
					keyToggle = true
				end
				goto next
			end

			error(("Unexpected token got at position %d"):format(pos))

			::next::
			if lastPos == pos then error("Infinite loop detected") end
			lastPos = pos
		end
	end
end

local function escapeString(str)
	str = gsub(str,"\\","\\\\")
	str = gsub(str,"\n","\\n")
	str = gsub(str,"\t","\\t")
	str = gsub(str,'"','\\"')
	return str
end

local function stringify(data,usingIndent,newline,depth,buffer)
	local indent = usingIndent and (rep(usingIndent,depth)) or ""
	for key,value in pairs(data) do
		local valueType = type(value)
		if valueType == "string" then
			insert(buffer,
				format('%s"%s" "%s"%s',
					indent,
					escapeString(key),
					escapeString(value),
					newline
				)
			)
		elseif valueType == "table" then
			insert(buffer,format('%s"%s"%s{%s',indent,escapeString(key),newline,newline))
			stringify(value,usingIndent,newline,depth+1,buffer)
			insert(buffer,format("%s}%s",indent,newline))
		else
			error(("Unsupported value type '%s'"):format(valueType))
		end
	end
end

function module.stringify(data,indent,disableNewline)
	if indent == nil or indent == true then
		indent = "  "
	end
	local newline = disableNewline and "" or "\n"
	local buffer = {}
	stringify(data,indent,newline,0,buffer)
	return concat(buffer)
end

return module
