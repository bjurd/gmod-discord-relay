if DiscordRelay.Socket then
	DiscordRelay.Socket:close()
end

DiscordRelay.Socket = GWSockets.createWebSocket(Format("wss://gateway.discord.gg/?v=%d&encoding=json", DiscordRelay.Config.API))
local Socket = DiscordRelay.Socket

function Socket:onConnected()
	print("connected, identifying")

	local Identify = {
		op = 2,
		d = {
			token = DiscordRelay.Config.Token,
			intents = DiscordRelay.Config.Intents
		}
	}

	Socket:write(util.TableToJSON(Identify))
end

function Socket:onDisconnected()
	print("disconnected")
end

function Socket:onMessage(Message)
	local Data = util.JSONToTable(Message)

	if not Data then
		error("Relay failed to read response message")
		return
	end

	local Operation = tonumber(Data.op)

	if not isnumber(Operation) then
		error("Relay got no operation")
		return
	end

	PrintTable(Data)

	DiscordRelay.Events.RunOperation(Operation)
end

function Socket:onError(Message)
	print("error", Message)
end

Socket:open()
