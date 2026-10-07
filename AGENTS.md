# Rushware dev rules

- Target native SportPaper 1.8 + Minecraft Java 1.8.9; build with JDK 25 and the committed Gradle wrapper.
- Develop on `main`; `upstream` is read-only. Preserve upstream history, licenses and attribution; change gameplay only when requested.
- Keep admission in `rushware-guard`. Strict mode is default: require trusted launcher verification and deny missing verification; protocol 47, brands and client-reported versions are insufficient.
- Test modes are opt-in and disabled by default. `remote-test` requires protocol 47, online authentication, whitelist enabled and explicit player membership; `local-test` requires protocol 47, loopback bind and source. Both accept 1.8.x and cannot verify exact 1.8.9.
- Keep templates in `deployment/`; never commit binaries, maps, player data, credentials or runtime configuration. Do not accept the EULA or publish credentials for the user.
- Run relevant Gradle tests; release changes require `scripts/Build.ps1`. After successful builds, use `scripts/Sync-ServerPackage.ps1` to update existing `server-package/` plugins and `.7z`/`.zip` archives, preserving configuration and player data.
- Before ending each turn with completed changes, validate and `git commit` only that task's changes with a clear message. Leave unrelated edits intact; report the commit hash. Push only when explicitly requested. Read-only turns need no commit.
- Votes: admin 10, sponsor 5, supporter 3, default 1. Sponsor/supporter may join full teams but cannot choose teams. Titles: admin aqua bold ❑, sponsor dark purple bold ✳, supporter pink bold ✳; preserve name/team colors.
- Admin uses explicit safe permissions, never OP: no shutdown/restart, privilege or whitelist management, reload, creative/item spawning or WorldEdit editing. End/cycle are allowed while participating; other match controls, vanish and TNT defuse are observer-only. Keep `pgm.stop` separate from `pgm.restart`, and `pgm.cycle` from `pgm.start`.
