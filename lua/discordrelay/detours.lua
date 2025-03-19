-- TODO: This is really basic and needs some upgrades
DiscordRelay.Detours = DiscordRelay.Detours or {}

DiscordRelay.Detours.Originals = DiscordRelay.Detours.Originals or {}

DiscordRelay.Detours.New = DiscordRelay.Detours.New or {}

DiscordRelay.Detours.Meta = { ["__index"] = _G }

function DiscordRelay.Detours.Setup(Original, New)
	local Env = setmetatable({ ["__Original"] = Original }, DiscordRelay.Detours.Meta)

	DiscordRelay.Detours.Originals[Original] = New
	DiscordRelay.Detours.New[New] = Original

	return setfenv(New, Env)
end

function DiscordRelay.Detours.Destroy(New)
	local Original = DiscordRelay.Detours.New[New]
	if not isfunction(Original) then return false end

	return Original
end
