if not util.IsBinaryModuleInstalled("chttp") then
	logging.Log(LOG_WARNING, "CHTTP binary module is not installed! Roles may not be able to be fetched!")
else
	require("chttp")
end

local HTTP = CHTTP or HTTP
module("roles", package.discord)

CacheKey = "RoleCache::%s"
RoleURL = "https://discord.com/api/v%d/guilds/%s/roles"

function ROLE_Success(Code, Body, GuildID, Callback)
	if Code ~= 200 then
		logging.DevLog(LOG_ERROR, "Failed to fetch guild roles, code %d", Code)
		Callback(nil)

		return
	end

	local Data = util.JSONToTable(Body, false, true)

	if not Data then
		logging.DevLog(LOG_ERROR, "Got invalid response for guild roles")
		Callback(nil)

		return
	end

	-- Try to Get first in case requests build up
	-- TODO: Some kind of request handling system?
	local Key = Format(CacheKey, GuildID)
	local Cached = cache.Get(Key) or cache.CreateTimed(Key, 300)

	-- This is better than running the callback early because requests are async and could get ran with an empty table
	-- it's better to recompile the list than to risk running dry
	table.Empty(Cached)

	local RoleCount = #Data

	for i = 1, RoleCount do
		local RoleData = Data[i]

		local Role = oop.ConstructNew("Role", RoleData)
		table.insert(Cached, Role)
	end

	Callback(Cached)
end

function ROLE_Fail(Reason, Callback)
	logging.DevLog(LOG_ERROR, "Failed to fetch guild roles, %s", Reason)

	Callback(nil)
end

--- Fetches and creates the role cache table, used internally by GetGuildRoles
--- @param Socket WEBSOCKET
--- @param GuildID string
--- @param Callback function Only argument is the sequential Role table
function FetchGuildRoles(Socket, GuildID, Callback)
	local RoleURL = Format(RoleURL, Socket.API, GuildID)

	HTTP({
		["url"] = RoleURL,
		["method"] = "GET",

		["headers"] = {
			["Accept"] = "application/json",
			["Host"] = "discord.com",
			["Authorization"] = Format("Bot %s", Socket.Token)
		},

		["success"] = function(Code, Body)
			ROLE_Success(Code, Body, GuildID, Callback)
		end,

		["failed"] = function(Reason)
			ROLE_Fail(Reason, Callback)
		end
	})
end

--- Gets a table of Roles for a guild and runs the Callback, cached for 5 minutes
--- @param Socket WEBSOCKET
--- @param GuildID string
--- @param Callback function Only argument is the sequential Role table, nil on failure
function GetGuildRoles(Socket, GuildID, Callback)
	local Key = Format(CacheKey, GuildID)
	local Cached = cache.Get(Key)

	if Cached then
		logging.DevLog(LOG_SUCCESS, "Using cached roles for guild %s", GuildID)

		Callback(Cached)
		return
	end

	FetchGuildRoles(Socket, GuildID, Callback)
end
