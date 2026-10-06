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
- Do not accept Minecraft EULA or publish credentials on the user's behalf.
