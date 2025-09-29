module("discord", package.seeall)

PackageMeta = { __index = function(self, Key) return discord[Key] or _G[Key] end } -- package.seeall + discord

--- Puts a module as a submodule of discord
--- @param Module table The module table
function package.discord(Module)
	if not discord then
		error("Discord module not located!")
		return
	end

	discord[Module._NAME] = Module

	setmetatable(Module, PackageMeta)
end

local developer = GetConVar("developer")

--- Checks if developer mode is enabled
--- @return boolean IsDeveloper Whether or not the developer ConVar value is nonzero
function IsDeveloper()
	return developer and developer:GetBool() or false
end

--- Checks if higher developer mode is enabled, used for more spammy events
--- @return boolean IsDeveloper Whether or not the developer ConVar value is >1
function IsHigherDeveloper()
	return developer and developer:GetInt() > 1 or false
end

--- Returns a filename from a string without the extension (because string.GetFileFromFilename includes the extension)
--- @param FileName string The file name
--- @return string
function GetFilenameNoExtension(FileName)
	FileName = string.GetFileFromFilename(FileName)

	local Extension = string.GetExtensionFromFilename(FileName)

	if Extension then
		local ExtensionLength = string.len(Extension)
		local ExtensionOffset = -(ExtensionLength + 2)
		FileName = string.sub(FileName, 1, ExtensionOffset)
	end

	return FileName
end

--- Loads a Discord module within the Discord fenv
--- @param Path string The file path with no extension
--- @return ... Whatever the included file returns
function LoadFile(Path)
	Path = string.lower(Path)

	local File = string.GetFileFromFilename(Path)
	local CleanFile = GetFilenameNoExtension(File)
	Path = string.GetPathFromFilename(Path)

	if File ~= CleanFile and IsDeveloper() then
		ErrorNoHaltWithStack("Do not pass file extensions into LoadFile!") -- This because logging may not exist yet

		File = CleanFile
	end

	local FullPath = Format("includes/modules/discord/%s%s.lua", Path, File)
	local Loader = CompileFile(FullPath, true)

	if not Loader then
		error(Format("Tried to LoadFile a non-existant file '%s'", FullPath))
		return
	end

	if logging then
		logging.Log(LOG_SUCCESS, "Loaded Discord module %s", CleanFile)
	else
		MsgN("[discordRelay] Loaded early module ", CleanFile)
	end

	setfenv(Loader, discord)
	return Loader()
end

--- Loads a Discord module as a metatable and registers it
--- @param Name string The file name with no extension
function LoadObjectFile(Name)
	local Metatable = LoadFile(Format("objects/%s", Name))

	if not istable(Metatable) then
		error(Format("Got non-metatable file '%s'", Name))
		return
	end

	local MetaName = GetFilenameNoExtension(Name)

	RegisterMetaTable(Format("Discord::%s", MetaName), Metatable)

	logging.Log(LOG_SUCCESS, "Registered OOP object type %s", MetaName)
end

-- Load our friends
LoadFile("Enums")
LoadFile("Logging")
LoadFile("Versioning")
LoadFile("Intents")
LoadFile("Permissions")
LoadFile("Colors")
LoadFile("BigInt")
LoadFile("Cache")

LoadFile("OOP")
LoadObjectFile("Role")
LoadObjectFile("Message")
LoadObjectFile("EmbedAuthor")
LoadObjectFile("EmbedFooter")
LoadObjectFile("Embed")

LoadFile("Socket")
LoadFile("Operations")
LoadFile("Messages")
LoadFile("Roles")

logging.Log(LOG_SUCCESS, "Loaded all Discord modules!")
