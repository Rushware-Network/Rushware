# Rushware development rules

- Target gameplay: PGM on native SportPaper 1.8, Minecraft Java client 1.8.9.
- Use JDK 25 and the committed Gradle wrapper; do not downgrade Java based on the Minecraft version.
- Keep upstream PGM history, licenses and attribution. `upstream` is read-only; `main` is Rushware development.
- Keep Rushware admission code in `rushware-guard`; preserve upstream gameplay unless a task explicitly changes it.
- Never replace strict admission with a protocol-47-only check, client brand or a client-supplied version string.
- Until trusted launcher verification is implemented, missing verification must deny login.
- Do not commit server binaries, player data, maps, credentials or runtime configuration. Templates belong in `deployment/`.
- Verify relevant code with Gradle tests and run `scripts/Build.ps1` for release changes.
- Do not accept Minecraft EULA or publish credentials on the user's behalf.
