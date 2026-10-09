# KB source research

## Candidate preference

On 2026-10-09, the user selected mSpigot as a promising candidate to keep on record. This is a research preference, not authorization to replace SportPaper or change gameplay.

- Patch archive: https://github.com/PluginsArchivalProject/mSpigot
- Source variants: https://github.com/dynamicg/mSpigot and https://github.com/dqyzszs/MineHQ-Minimal/tree/main/mSpigot
- These public copies have not been authenticated as the earliest or unmodified official release.
- Basic KB parameters and sprint bonus logic exist. KSS Misplace and attack Delay have not been identified. KSS Reduction means attacker movement slowdown, not the victim-side `knockbackReduction` field.
- Historical patches include changes and reversions; their features must not be treated as simultaneously active without reconstructing a specific revision.

## PotPvP

Public source candidates inspected on 2026-10-09:

- https://github.com/Hylist-Games/PotPvP
- https://github.com/PluginsArchivalProject/PotPvP-SI
- https://github.com/NeptuneCommunity/PotPvP

The first two identify the project as PotPvP Single Instance, with `net.frozenorb.potpvp.PotPvPSI` as the plugin entry point. The Hylist copy declares `net.hylist:spigot-server:1.7.10-R0.1-SNAPSHOT`, qLib and Hydrogen dependencies. This supports a MineHQ-related source lineage but does not authenticate the public copy as an unmodified production release.

The inspected Java/configuration search found match damage rules and no complete KSS KB system. Neptune's copy instead declares a SourSpigot dependency and is a modified variant. Do not infer historical MineHQ core selection from that variant.

## Lunar

No authenticated Lunar Network server core source was located in this search. The repository named `Iwanabeu/Lunar-Server-Core` describes Lunar Dominion and contains a C#/SWF project, so it is unrelated to the Minecraft target. Lunar Client APIs and projects with similar names are not evidence of Lunar Network's combat implementation.

Search coverage was limited by rate limits; absence from these results does not establish that a public source does not exist.
