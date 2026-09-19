# Changelog

## 1.1.0 — 2026-09-19

Alignment with the NethServer module conventions (NethServer/agents skills).

### Changed

- **Secrets moved out of the module environment.** The RCON password is now kept in `state/passwords.env` (mode 0600) instead of `state/environment`, which NS8 mirrors to Redis in plain text. Existing installations are migrated on update; the value does not change. The generated `minecraft.env` is private (0600).
- The module backup includes `state/passwords.env`; restore reads the password from it (backups taken with 1.0.0 are still restorable).
- `update-module` only restarts a running instance.

### Added

- Robot Framework tests (install, update from the previous release, backup and restore, each with a console command over RCON) run on real NS8 nodes through `stephdl/ns8-ci-actions`.

### Platform integration

- **Clone and move.** New `clone-module` step (a link to the restore step): a cloned or moved instance gets its route and settings back instead of coming up unconfigured.
- `org.nethserver.volumes`: the bulk-data volume(s) `minecraft-data` can be placed on an additional disk when the module is installed.
- The software centre shows the upstream terms before installation (`terms_url`); release notes are linked (`relnotes_url`).

## 1.0.0 — 2026-09-15

- Initial release: itzg/minecraft-server (pinned, Java 25 — Minecraft 26.1+ requires it) with Paper /
  Vanilla / Fabric, Bedrock support via Geyser + Floodgate, world rules,
  whitelist/operators, additional variables, firewall service, RCON console
  action, backup with paused auto-save, restore, settings UI (EN/DE),
  automatic upstream-update releases.
