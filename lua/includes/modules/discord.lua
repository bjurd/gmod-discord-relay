module("discord", package.seeall)

PackageMeta = { __index = function(self, Key) return discord[Key] or _G[Key] end } -- package.seeall + discord

--- Puts a module as a submodule of discord
--- @param Module table The module table
function package.discord(Module)
	if not discord then
		error("discord module not located!")
		return
	end

	discord[Module._NAME] = Module

	setmetatable(Module, PackageMeta)
end

--- Checks if developer mode is enabled
--- @return boolean IsDeveloper Whether or not the developer ConVar value is nonzero
function IsDeveloper()
	local developer = GetConVar("developer")

	return developer and developer:GetBool()
end

--- Loads a discord module within the discord fenv
--- @param Name string The file name with no extension
--- @return ... Whatever the included file returns
function LoadFile(Name)
	Name = string.lower(Name)
	Name = string.GetFileFromFilename(Name)

	local Extension = string.GetExtensionFromFilename(Name)

	if Extension then -- GetExtensionFromFilename returns nil on failure
		if IsDeveloper() then
			ErrorNoHaltWithStack("Do not pass file extensions into LoadFile!") -- This because logging may not exist yet
		end

		local ExtensionLength = string.len(Extension)
		local ExtensionOffset = -(ExtensionLength + 2)
		Name = string.sub(Name, 1, ExtensionOffset)
	end

	local FilePath = Format("includes/modules/discord/%s.lua", Name)
	local Loader = CompileFile(FilePath, true)

	if not Loader then
		error(Format("Tried to LoadFile a non-existant file '%s'", FilePath))
		return
	end

	setfenv(Loader, discord)
	return Loader()
end

-- Load our friends
LoadFile("Enums")
LoadFile("Logging")
LoadFile("Versioning")
LoadFile("Intents")
LoadFile("Colors")

LoadFile("Operations")
LoadFile("Socket")
LoadFile("Messages")

logging.Log(LOG_SUCCESS, "Loaded Discord module")
