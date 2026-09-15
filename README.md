# ns8-minecraft

[NethServer 8](https://github.com/NethServer/ns8-core) module for a
**Minecraft server** (Java Edition, optional Bedrock support), built on the
[itzg/minecraft-server](https://github.com/itzg/docker-minecraft-server)
image.

- Server type **Paper** (recommended, plugins), **Vanilla** or **Fabric**
  (mods); Minecraft version `LATEST`, `SNAPSHOT` or a fixed one
- **Bedrock Edition** clients (phones, consoles, Windows app) via Geyser +
  Floodgate, latest builds from the official GeyserMC download API at every start
  (Paper only)
- World rules from the settings page: MOTD, game mode, difficulty, max players,
  PvP, online mode, seed; **whitelist** and **operators** synchronised at every
  start; free-form additional variables for everything else the image supports
- Ports chosen in the settings (default 25565/tcp, Bedrock 19132/udp),
  published on the node and opened on the node firewall
- **Server console** on the settings page (RCON), also as the `run-command`
  action for scripts
- **Backup**: the world volume with the server paused for a consistent copy
  (`save-all flush` / `save-off` … `save-on`), full restore
- Pinned image with automatic upstream-update releases

## Install

Add the repository `https://raw.githubusercontent.com/tebbiworld/ns8-repo/main/ns8/updates/`
in Software Center → Repositories, then install *Minecraft Server*. Or from
the leader node:

    add-module ghcr.io/tebbiworld/minecraft:latest 1

## Configure

Open the instance settings, accept the **Minecraft EULA** (the server refuses
to start otherwise), pick the server type, memory and ports and save. The
first start downloads the server for the requested version (internet access
required) and generates the world; with `LATEST` the newest release is
installed at every start, so the world follows Minecraft's releases —
Minecraft cannot downgrade a world, pin a version if you need to stay put.

| Setting | Notes |
| --- | --- |
| Java heap | `MEMORY` of the JVM; 2 GB for a few players, more for Paper with plugins/many players. Must leave enough memory for the node. |
| Java Edition port | TCP; published on all node addresses and opened on the node firewall as public service `<instance>` |
| Bedrock support | Downloads the latest Geyser + Floodgate Spigot builds from the official GeyserMC download API at every start (Paper only) and publishes the UDP port; Bedrock players join with their Xbox/Microsoft account, no Java account needed |
| Whitelist / operators | Written to `whitelist.json` / `ops.json` at every start, removals included (`EXISTING_*_FILE=SYNCHRONIZE`); an empty whitelist lets everybody join |
| Online mode | Off only for LAN/offline servers — anyone can then join under any name |
| Additional variables | `KEY=VALUE` lines passed to the image after the generated ones, e.g. `VIEW_DISTANCE=12`, `SPAWN_PROTECTION=0`, `MODRINTH_PROJECTS=…` (mods/plugins for Fabric/Paper), `CF_*`/`MODPACK` … — see the [image documentation](https://docker-minecraft-server.readthedocs.io/). Variables managed by the page (`EULA`, `TYPE`, `VERSION`, `MEMORY`, `RCON_*`, `SERVER_PORT`, `REMOVE_OLD_MODS*`, `PLUGINS` while Bedrock is on, …) are refused. |

`server.properties` is regenerated from the settings at every start
(`OVERRIDE_SERVER_PROPERTIES=true`): a setting changed on the page wins over a
hand-edited file; anything not covered by the page goes into the additional
variables.

### Server console

The settings page sends console commands to the running server through RCON
(`list`, `say …`, `whitelist add …`, `op …`, `time set day`, `save-all`, …).
From the leader node:

    api-cli run module/minecraft1/run-command --data '{"command":"list"}'

RCON is only reachable inside the container (password generated per
instance, stored in the module environment).

## Connecting

Java Edition: `<node IP or name>:<port>`; Bedrock: the same host with the
UDP port. For players outside the LAN forward the port(s) on the router to the
node. The settings page shows the current server status (version, players
online) and the addresses.

## Backup and restore

The NS8 backup includes the module settings and the `minecraft-data` volume
(server, worlds, plugins). Before the snapshot the module flushes the world to
disk and pauses auto-saving (`save-all flush`, `save-off`), afterwards it
resumes (`save-on`); a stopped server is backed up as is. Restore recreates the
instance from the snapshot, re-applies the settings and firewall service and
starts the server on the restored world.

## Updates

The module pins the `itzg/minecraft-server` image (Java 25 variant). A weekly
GitHub Action checks Docker Hub for a newer `YYYY.M.N-java25` tag that is at
least six weeks old and releases a new module version; the Software Center
update restarts the server. The Minecraft version itself is chosen in the
settings (`LATEST` follows the Mojang/Paper releases at every start).

## Resources

- Java heap as configured plus ~0.5 GB for the JVM and the image tooling;
  disk grows with the world (a few hundred MB to several GB)
- One instance per port pair; several instances per node with different ports

## Development

    IMAGETAG=1.0.0 bash ./build-images.sh

Runtime images are pinned in `build-images.sh`; the module image only holds
`imageroot/` and the built UI.

## License

GPL-3.0-or-later. Minecraft is a trademark of Mojang/Microsoft; the server
software is downloaded at runtime under the Minecraft EULA.
