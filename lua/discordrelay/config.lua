local ConfigData = file.Read("data_static/relay/config.txt", "GAME")

if not isstring(ConfigData) then
	discord.logging.Log(LOG_ERROR, "Couldn't find relay config file! Bailing!")
	return nil
end

local vdf = include("includes/modules/vdf.lua") -- include because require can't return
local Parsed = vdf.parse(ConfigData)

return Parsed.config
