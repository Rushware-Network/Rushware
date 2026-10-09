# minehq-parent KB versus current SportPaper

Compared on 2026-10-09. No gameplay or runtime configuration was changed.

## Evidence and scope

- Reference: https://github.com/Hylist-Games/minehq-parent/tree/ea754cf44578b7a2eac5c906b23a2fa236df7c05
- This repository calls its server Katsu and describes itself as a MineHQ 1.8 port. It is the user-selected reference, not an authenticated earliest mSpigot release.
- Local target: `runtime/SportPaper.jar`, SHA-256 `27887d70b45ca038fbbdccdc3e2b090699045cbe78ce1e27894e5fc2ca394188`.
- Target behavior was inspected with CFR 0.152 and javap. Decompiled source and downloaded tooling remain under ignored `.local/kb-comparison/`; they are not committed.
- Five retrieved reference source files were checked byte-for-byte against the pinned commit. The comparison covers direct melee KB; it does not establish equivalence for every damage source, projectile, movement rule, plugin interaction or network condition.

## Findings

| Behavior | Reference Katsu | Local SportPaper |
| --- | --- | --- |
| Parameter source | Per-entity profile, falling back to current global profile | Global static `PaperConfig` fields |
| Compiled defaults: F/H/V/limit/EH/EV | 2 / .35 / .35 / .4 / .425 / .085 | 2 / .4 / .4 / .4 / .5 / .1 |
| Base KB | Divide existing XYZ velocity by F; add horizontal direction and V; cap Y at limit | Same structure, but effective F is F-r and effective H/V are H/V times (1-r), where r is the victim's Bukkit knockback reduction |
| Additional base-KB event | None in the compared method | Computes delta, restores old velocity, fires `EntityKnockbackByEntityEvent`, then adds the mutable delta unless cancelled |
| Bonus count | Knockback enchantment level plus one if sprinting | Same |
| Bonus horizontal | Attacker yaw direction times count times EH | Same structure |
| Bonus vertical | Add EV once when count > 0 | Same; not multiplied by count |
| Vertical cap order | Base cap before bonus EV | Same |
| Attacker slowdown | X/Z multiplied by .6 when count > 0 and damage succeeds | Same |
| Sprint reset | Set false in that same bonus branch | Same |
| Player velocity event input | Computed victim velocity after base and bonus KB | Saved pre-hit victim velocity |
| Event-modified velocity | Directly applies event velocity before packet | Calls Bukkit setVelocity only if event velocity differs from saved pre-hit value |
| Immediate velocity packet | Sent synchronously when event is not cancelled | Same broad timing |
| Cleanup after velocity event | Clears velocityChanged and restores pre-hit XYZ even if event was cancelled | Cleanup only in the not-cancelled branch |

The SportPaper defaults above are fallback values in its binary, not a measurement of currently loaded server configuration.

## Relevant locations

Reference paths, relative to the pinned repository:

- `Spigot/katsu-server/src/main/java/net/minecraft/server/EntityLiving.java:944`: base KB and victim profile.
- `Spigot/katsu-server/src/main/java/net/minecraft/server/EntityHuman.java:981`: bonus count; lines 1012-1048 cover saved velocity, attacker profile, bonus, slowdown, event, packet and restoration.
- `Spigot/katsu-server/src/main/java/dev/lugami/spigot/knockback/CraftKnockbackProfile.java`: defaults.
- `Spigot/katsu-server/src/main/java/net/minecraft/server/Entity.java:1127`: additive velocity helper; its structure matches SportPaper's helper.

SportPaper decompiled locations under `.local/kb-comparison/sportpaper/`:

- `net/minecraft/server/v1_8_R3/EntityLiving.java:811`: reduction and mutable delta event.
- `net/minecraft/server/v1_8_R3/EntityHuman.java:896`: attack; lines 924-953 cover velocity capture through restoration.
- `com/destroystokyo/paper/PaperConfig.java:187`: defaults and six KB config keys.
- `app/ashcon/sportpaper/server/KnockbackModificationCommand.java`: live setters for the six global fields; these setters do not save configuration.

## Numerical checks and limits

An independent formula calculation with a stationary victim and normalized direction (1,0), using reference defaults, gives base velocity (-.35,.35,0). SportPaper with matched parameters and r=0 gives the same mathematical result; r=.2 instead gives approximately (-.28,.28,0). With yaw 0 and sprint bonus count 1, the reference example becomes (-.35,.435,.425), showing that bonus EV can exceed the base .4 cap.

These are formula checks, not integration or packet tests. SportPaper's subtract-then-add delta path can introduce floating-point rounding differences even when no listener changes the delta, so mathematical agreement is not a claim of bit-for-bit equivalence. The event's different initial velocity also changes behavior for listeners that inspect or modify it.

## Plugin feasibility

For one global preset and ordinary melee with victim reduction zero and no interfering event listeners, existing SportPaper fields can reproduce the main reference formula without replacing damage processing. An adapter plugin could own configuration and persistence.

Strict equivalence requires further implementation and validation for the velocity event contract, cancellation cleanup, per-entity profile selection, existing PGM reduction kits, and floating-point execution order. The base-KB event exposes a mutable acceleration vector and can support formula replacement, but it does not itself expose the complete reference attack lifecycle. A simple damage listener followed by setVelocity is insufficient evidence of equivalence.

No plugin implementation, Gradle test, server launch or package synchronization was performed: this task only adds a comparison document. Validation consisted of pinned-source verification, binary inspection, numerical checks and documentation diff checks.
