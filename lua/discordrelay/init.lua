require("discord")

local Socket = discord.socket.Create(discord.versioning.GetLatestAPI())

if Socket then
	discord.socket.Connect(Socket, "NzgxNzE0NzkyMTM3NDkwNDUz.GcOESu.ymP-FW0VBnmkQ0Vb--T4rT3CfWJbIa14pEuE8o")

	include("events/ready.lua")
end
