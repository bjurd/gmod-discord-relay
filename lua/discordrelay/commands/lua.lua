DiscordRelay.Commands.RegisterCommand("lua", DiscordRelay.Enums.CommandPermissionLevels.STAFF_ONLY, function(Author, Member, Arguments)
	local Lua = table.concat(Arguments, " ")
	if not isstring(Lua) or string.len(Lua) < 1 then return end

	local LuaFn = CompileString(Lua, "DiscordRelay", false)

	if not isfunction(LuaFn) then
		DiscordRelay.Util.WebhookAutoSend({
			["username"] = "Lua Error",
			["embeds"] = {
				DiscordRelay.Util.CreateEmbed(
					Color(255, 0, 0),
					"Lua Compilation Error",

					Format("```\n%s\n```", LuaFn)
				)
			}
		})

		return
	end

	local Results = { pcall(LuaFn) }
	local Result = table.remove(Results, 1)

	if Result ~= true then
		DiscordRelay.Util.WebhookAutoSend({
			["username"] = "Lua Error",
			["embeds"] = {
				DiscordRelay.Util.CreateEmbed(
					Color(255, 0, 0),
					"Lua Runtime Error",

					Format("```\n%s\n```", A)
				)
			}
		})

		return
	end

	if #Results > 0 then
		for i = 1, #Results do
			Results[i] = tostring(Results[i])
		end

		Results = table.concat(Results, ", ")

		DiscordRelay.Util.WebhookAutoSend({
			["username"] = "Lua Results",
			["embeds"] = {
				DiscordRelay.Util.CreateEmbed(
					Color(0, 255, 0),
					"Lua Runtime Results",

					Format("```\n%s\n```", Results)
				)
			}
		})
	else
		DiscordRelay.Util.WebhookAutoSend({
			["username"] = "Lua Results",
			["embeds"] = {
				DiscordRelay.Util.CreateEmbed(
					Color(0, 255, 0),
					"Ran Lua on Server",

					Format("```lua\n%s\n```", Lua)
				)
			}
		})
	end
end)
