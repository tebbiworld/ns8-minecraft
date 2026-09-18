<!--
First community post for the NS8 Minecraft module, written in the style
of https://community.nethserver.org/t/ns8-forgejo-testing/28554 (first post).
Paste into a new topic on community.nethserver.org, category "App", tag "ns8".
Fill in the wiki link once the page is published.
-->

# NS8 Minecraft (testing)

Hi all,

I've built an NS8 module for a [Minecraft server](https://github.com/itzg/docker-minecraft-server) — Java Edition with optional Bedrock support, built on the well-known itzg/minecraft-server image.

It's in my community repository. To try it, add the repo once:

```
api-cli run add-repository --data '{"name":"tebbiworld","url":"https://raw.githubusercontent.com/tebbiworld/ns8-repo/main/ns8/updates/","status":true,"testing":false}'
```

then install **Minecraft Server** from the Software Center. (Or straight from the image: `add-module ghcr.io/tebbiworld/minecraft:latest 1`.)

What it does:

* Runs a Paper (plugins), Vanilla or Fabric (mods) server on the Minecraft version you pick — `LATEST`, `SNAPSHOT` or a fixed one
* **Bedrock Edition** clients (phones, consoles, Windows app) can join too via Geyser + Floodgate, fetched fresh from the official GeyserMC download API (Paper only)
* World rules from the settings page — MOTD, game mode, difficulty, max players, PvP, online mode, seed — plus whitelist and operators synchronised at every start
* A **server console** on the settings page (RCON), also as a `run-command` action for scripts
* Opens the game port(s) on the node firewall (default 25565/tcp, Bedrock 19132/udp); free-form extra variables cover anything else the image supports
* Consistent world **backup** (`save-all flush` / `save-off` … `save-on`) with full restore

A few things to know:

* You must **accept the Minecraft EULA** in the settings or the server refuses to start
* With `LATEST` the newest release is installed at every start and the world follows Minecraft's releases — Minecraft can't downgrade a world, so pin a version if you need to stay put
* Budget the Java heap you configure plus ~0.5 GB for the JVM and tooling; disk grows with the world
* Players outside the LAN need the port(s) forwarded on the router to the node
* Still testing — running fine here, but more players hammering it would help

If you host a server for friends or a class, I'd love to hear how it holds up — bug reports and ideas welcome.

Docs: NethServer wiki (tebbiworld repository) · Source: [github.com/tebbiworld/ns8-minecraft](https://github.com/tebbiworld/ns8-minecraft)

Thanks!

*Category: App · Tags: ns8*
