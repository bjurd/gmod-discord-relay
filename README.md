# GMod Discord Relay
A Garry's Mod Discord relay that runs entirely on the server, no thirdparty or external shenanigans.

(Except for the required binaries because this game's networking is severely handicapped)

# Features!!!1

- Relays Discord messages to in-game (duh)
- Relays in-game messages to Discord (duh)
- Mostly fully configurable
- Runs entirely on the server, no external backends or processes
- A-OK caching to make it fast like a racecar
- Modular Discord command system to interact with the server from Discord
- Hookable messages for developers to integrate into it

# Installation

1. Clone the repository to your addons folder
	<details>

	<summary>Help I'm retarded</summary>

	```bash
	cd garrysmod/addons
	git clone https://github.com/github-is-garbage/gmod-discord-relay discordrelay
	```

	</details>
2. Install [GWSockets](https://github.com/FredyH/GWSockets) and [CHTTP](https://github.com/timschumi/gmod-chttp) into your `garrysmod/lua/bin` folder
3. Configure `addons/discordrelay/lua/discordrelay/config.lua`
4. Horray!
