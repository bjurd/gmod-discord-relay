# GMod Discord Relay
A Garry's Mod Discord relay that runs entirely on the server, no thirdparty or external shenanigans.

(Except for the required binaries because this game's networking is severely handicapped)

> [!WARNING]
> There's been a major overhaul of the relay's internals.
> You will almost definitely have to reconfigure and/or recode anything to do with it.

# Features!!!1

- Relays Discord messages to in-game (duh)
- Relays in-game messages to Discord (duh)
- Can read and write to multiple channels/guilds at once
- Simple configuration
- Runs entirely on the server, no external backends or processes
- A-OK caching to make it fast like a racecar
- Command system to interact with the server from Discord
- Hookable messages for developers to integrate into it
- Has some cool OOP style Discord API thingy majigs

# Installation

1. Clone the repository to your addons folder
	<details>

	<summary>Help I'm retarded</summary>

	```bash
	cd garrysmod/addons
	git clone https://github.com/bjurd/gmod-discord-relay discordrelay
	```

	</details>
2. Install [GWSockets](https://github.com/FredyH/GWSockets) and [CHTTP](https://github.com/timschumi/gmod-chttp) into your `garrysmod/lua/bin` folder
3. Configure `addons/discordrelay/data_static/relay/config.txt`
4. Horray!

# Updating
If you have [gm_shell](https://github.com/bjurd/gm_shell) installed, you can use the `rupdate` command in Discord to have the relay update itself.

1. `cd` to wherever you cloned the repo
2. stash, pull, pop
	<details>

	```bash
	git stash push
	git pull
	git stash pop
	```

	</details>

> [!CAUTION]
> If you don't stash before pulling, it's likely git will overwrite your config and other changes you've made
> with the default, blank config. Make sure to stash if you want to keep your changes and to pop the stash
> after pull completes.

> [!NOTE]
> It's very likely a server restart will be needed after fetching updates,
> because the Discord library internals won't autorefresh.
