# GMod Discord Relay
A Garry's Mod Discord relay that runs entirely on the server, no thirdparty or external shenanigans.

(Except for the required binaries because this game's networking is severely handicapped)

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
