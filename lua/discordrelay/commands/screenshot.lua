util.AddNetworkString("DiscordRelay::Screenshot")

net.Receive("DiscordRelay::Screenshot", function(_, Sender)
	if not DiscordRelay.Util.GetFromObject(Sender, "Screenshot::Waiting") then
		return
	end

	DiscordRelay.Util.StoreOnObject(Sender, "Screenshot::Waiting", false)

	local Username = Sender:GetName()

	if DiscordRelay.Config.FilterUsernames then
		Username = DiscordRelay.Util.ASCIIFilter(Username)
		Username = DiscordRelay.Util.MarkdownEscape(Username)
	end

	local URL = net.ReadString()

	if not isstring(URL) or not string.match(URL, "^https://litter%.catbox%.moe/[%w%._-]+%.jpeg$") then -- TODO: Validate URL properly
		DiscordRelay.Util.WebhookAutoSend({
			["username"] = "Screenshot",
			["embeds"] = {
				DiscordRelay.Util.CreateEmbed(
					Color(255, 0, 0),
					"Bad Response",
					Format("Target %s replied with a bad URL", Username)
				)
			}
		})

		return
	end

	DiscordRelay.Util.WebhookAutoSend({
		["username"] = "Screenshot",
		["content"] = "",
		["embeds"] = {
			{
				["title"] = Sender:SteamID(),
				["description"] = Format("Screenshot from %s", Username),
				["image"] = { ["url"] = URL },
				["footer"] = { ["text"] = "Image only valid for the next hour" }
			}
		}
	})
end)

local function ScreenshotCmd(Author, Member, Arguments)
	local Username = Arguments[1]
	if not isstring(Username) then return end

	local Target = DiscordRelay.Util.FindPlayer(Username)

	if not IsValid(Target) then
		if DiscordRelay.Config.FilterUsernames then
			Username = DiscordRelay.Util.ASCIIFilter(Username)
		end

		DiscordRelay.Util.WebhookAutoSend({
			["username"] = "Screenshot",
			["embeds"] = {
				DiscordRelay.Util.CreateEmbed(
					Color(255, 0, 0),
					"Target Not Found",
					Format("Target %s could not be found", Username)
				)
			}
		})

		return
	end

	DiscordRelay.Util.StoreOnObject(Target, "Screenshot::Waiting", true)

	net.Start("DiscordRelay::Screenshot")
	net.Send(Target)
end

DiscordRelay.Commands.RegisterCommand("screenshot", "Takes a screenshot of a player's game.", DiscordRelay.Enums.CommandPermissionLevels.STAFF_ONLY, ScreenshotCmd)
DiscordRelay.Commands.RegisterAlias("screenshot", "ss")
