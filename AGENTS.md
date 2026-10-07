# Rushware development rules

- Target gameplay: PGM on native SportPaper 1.8, Minecraft Java client 1.8.9.
- Use JDK 25 and the committed Gradle wrapper; do not downgrade Java based on the Minecraft version.
- Keep upstream PGM history, licenses and attribution. `upstream` is read-only; `main` is Rushware development.
- Keep Rushware admission code in `rushware-guard`; preserve upstream gameplay unless a task explicitly changes it.
- Never replace strict admission with a protocol-47-only check, client brand or a client-supplied version string.
- Until trusted launcher verification is implemented, missing verification must deny login.
- The user also authorized explicit remote gameplay testing: `remote-test` may admit protocol 47 only with online authentication, an enabled whitelist and explicit player membership. It accepts all 1.8.x releases. Keep this exception disabled by default.
- The user authorized a standalone local gameplay test package. Its explicit `local-test` mode may admit protocol 47 only with loopback bind and loopback source. Keep strict mode as the default and label the test mode as unable to distinguish 1.8.x releases.
- Do not commit server binaries, player data, maps, credentials or runtime configuration. Templates belong in `deployment/`.
- Verify relevant code with Gradle tests and run `scripts/Build.ps1` for release changes.
- After every successful build, sync the latest plugin artifacts to the existing `server-package/` and refresh its existing `.7z` and `.zip` archives with `scripts/Sync-ServerPackage.ps1`. Preserve server configuration and player data.
- Do not accept Minecraft EULA or publish credentials on the user's behalf.
- Approved groups: admin 10 votes, sponsor 5, supporter 3, default 1. Sponsor/supporter may join full teams but cannot choose teams. Titles: admin aqua bold ❑, sponsor dark purple bold ✳, supporter light purple/pink bold ✳. Preserve name/team coloring separately.
- Admin is not OP: explicit safe permissions only, no shutdown/restart, privilege management, whitelist changes, reload, creative/item spawning or WorldEdit editing. Admin may end matches and cycle maps while participating; other match controls, vanish and TNT defuse are observer-only. Keep pgm.stop separate from pgm.restart, and pgm.cycle separate from pgm.start.
