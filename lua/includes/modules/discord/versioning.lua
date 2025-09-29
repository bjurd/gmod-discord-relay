module("versioning", package.discord)

enums.CreateIncremental("API_STATUS", {
	"AVAILABLE",
	"DEPRECATED",
	"DISCONTINUED",
	"UNKNOWN"
})

enums.Create("API", {
	["V3"] = 3,
	["V4"] = 4,
	["V5"] = 5,
	["V6"] = 6,
	["V7"] = 7,
	["V8"] = 8,
	["V9"] = 9,
	["V10"] = 10
})

Availibility = {
	[API_V3] = API_STATUS_DISCONTINUED,
	[API_V4] = API_STATUS_DISCONTINUED,
	[API_V5] = API_STATUS_DISCONTINUED,
	[API_V6] = API_STATUS_DEPRECATED,
	[API_V7] = API_STATUS_DEPRECATED,
	[API_V8] = API_STATUS_DEPRECATED,
	[API_V9] = API_STATUS_AVAILABLE,
	[API_V10] = API_STATUS_AVAILABLE
}

Statueses = {
	[API_STATUS_AVAILABLE] = "available",
	[API_STATUS_DEPRECATED] = "deprecated",
	[API_STATUS_DISCONTINUED] = "discontinued",
	[API_STATUS_UNKNOWN] = "unknown"
}

--- Gets the availability status of an API version
--- @param Version number The version number of the API, see API_V enums
--- @return number Status A number representing the availability of an API, see API_STATUS enums
function GetAPIStatus(Version)
	return Availibility[Version] or API_STATUS_UNKNOWN
end

--- Gets the availability status of an API version as a string
--- @param Version number The version number of the API, see API_V enums
--- @return string Status The API availability status
function GetAPIStatusStr(Version)
	return Statueses[GetAPIStatus(Version)]
end

--- Returns the latest API version
--- @return number Version
function GetLatestAPI()
	return API_V10
end
