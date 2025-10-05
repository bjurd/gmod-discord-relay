relay.steam = relay.steam or {}
local rsteam = relay.steam

local HTTP = CHTTP or HTTP -- CHTTP not required for this

rsteam.CacheKey = "AvatarCache"
rsteam.ProfileURL = "https://steamcommunity.com/profiles/%s?xml=1"

function rsteam.AVATAR_GET_Success(Code, Body, Callback) --  These functions don't match the usual format, but that's okay :^)
	if Code ~= 200 then
		discord.logging.DevLog(LOG_ERROR, "Failed to fetch player avatar, code %d", Code)
		discord.logging.DevLog(LOG_ERROR, Body)
		Callback(nil)

		return
	end

	logging.DevLog(LOG_SUCCESS, "Fetched Player avatar")

	Callback(Body)
end

function rsteam.AVATAR_GET_Fail(Reason, Callback)
	discord.logging.DevLog(LOG_ERROR, "Failed to fetch Player avatar, %s", Reason)

	Callback(nil)
end

--- Fetches a Player's profile XML
--- @param SteamID64 string
--- @param Callback function Only argument is the Player's profile data string, nil on failure
function rsteam.FetchPlayerProfile(SteamID64, Callback)
	local ProfileURL = Format(rsteam.ProfileURL, SteamID64)

	HTTP({
		["url"] = ProfileURL,
		["method"] = "GET",

		["headers"] = {
			["Accept"] = "text/xml",
			["Host"] = "steamcommunity.com"
		},

		["success"] = function(Code, Body)
			if Code ~= 200 then
				discord.logging.DevLog(LOG_ERROR, "Failed to fetch Player profile, code %d", Code)
				discord.logging.DevLog(LOG_ERROR, Body)
				Callback(nil)

				return
			end

			logging.DevLog(LOG_SUCCESS, "Fetched profile for %s", SteamID64)

			Callback(Body)
		end,

		["failed"] = function(Reason)
			discord.logging.DevLog(LOG_ERROR, "Failed to fetch Player profile, %s", Reason)

			Callback(nil)
		end
	})
end

--- Fetches and creates the Player Steam avatar cache table, used internally by GetPlayerAvatar
--- @param SteamID64 string
--- @param Callback function Only argument is the Player's avatar URL string, nil on failure
function rsteam.FetchPlayerAvatar(SteamID64, Callback)
	rsteam.FetchPlayerProfile(SteamID64, function(Data)
		if not Data then
			rsteam.AVATAR_GET_Fail("Bad profile data", Callback)
			return
		end

		local AvatarURL = string.match(Data, "<avatarMedium>%s*<!%[CDATA%[(.-)%]%]>%s*</avatarMedium>")

		if not AvatarURL then
			rsteam.AVATAR_GET_Fail("Profile has no avatar data", Callback)
			return
		end

		local Cached = discord.cache.Get(rsteam.CacheKey) or discord.cache.CreateTimed(rsteam.CacheKey, 300)
		Cached[SteamID64] = AvatarURL

		rsteam.AVATAR_GET_Success(200, AvatarURL, Callback)
	end)
end

--- Gets the Steam avatar (profile picture) of a SteamID64 and runs the callback, globally cached for 5 minutes
--- @param SteamID64 string
--- @param Callback function Only argument is the avatar URL string, nil on failure
function rsteam.GetSteamAvatar(SteamID64, Callback)
	local AvatarCache = discord.cache.Get(rsteam.CacheKey)

	if AvatarCache and AvatarCache[SteamID64] then
		Callback(AvatarCache[SteamID64])
		return
	end

	rsteam.FetchPlayerAvatar(SteamID64, Callback)
end

--- Gets a Player's Steam avatar (profile picture) and runs the callback, globally cached for 5 minutes
--- @param Player Player
--- @param Callback function Only argument is the Player's avatar URL string, nil on failure
function rsteam.GetPlayerAvatar(Player, Callback)
	rsteam.GetSteamAvatar(Player:SteamID64(), Callback)
end
