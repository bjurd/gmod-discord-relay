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
					LuaFn
				)
			}
		})

		return
	end

	local Result, A, B, C, D, E, F = pcall(LuaFn)

	if Result ~= true then
		DiscordRelay.Util.WebhookAutoSend({
			["username"] = "Lua Error",
			["embeds"] = {
				DiscordRelay.Util.CreateEmbed(
					Color(255, 0, 0),
					"Lua Runtime Error",
					A
				)
			}
		})

		return
	end

	if A ~= nil then
		local Returns = {
			A ~= nil and tostring(A) or nil,
			B ~= nil and tostring(B) or nil,
			C ~= nil and tostring(C) or nil,
			D ~= nil and tostring(D) or nil,
			E ~= nil and tostring(E) or nil,
			F ~= nil and tostring(F) or nil
		}

		Returns = table.concat(Returns, ", ")

		DiscordRelay.Util.WebhookAutoSend({
			["username"] = "Lua Results",
			["embeds"] = {
				DiscordRelay.Util.CreateEmbed(
					Color(0, 255, 0),
					"Lua Runtime Results",

					Format("```\n%s\n```", Returns)
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

					Format("```\n%s\n```", Lua)
				)
			}
		})
	end
end)
