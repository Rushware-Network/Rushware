# Small map pool

On 2026-10-09 the user selected removal of all voting-pool maps whose default ordinary capacity exceeds 24 players. Team capacity is the sum of team `max` values; FFA uses the `players max` value (or the server limit of 24 when omitted). Overfill is not included. Only the `default` variant is used by this pool.

The audited pool contains 375 maps totaling approximately 380.3 MiB of uncompressed map files. The policy removes 265 maps (approximately 280.9 MiB) and retains 110 (approximately 99.3 MiB):

| Mode | Retained maps |
| --- | ---: |
| FFA | 34 |
| KOTH | 21 |
| KOTF | 9 |
| TDM | 10 |
| Touchdown | 17 |
| Arcade | 19 |

`deployment/map-capacity-policy.json` records the audited removal list, default capacities, relative directories, map XML hashes and shared-include hashes. The inventory expanded conditional default-variant definitions, includes and capacity constants. This is a policy for the existing pinned map sources, not a generic capacity parser for future map revisions. If XML or includes change, re-audit rather than bypassing the hash checks.

Run `scripts/Prune-LargeMaps.ps1` to preview; use `-Apply` to delete the audited directories and remove their voting entries. The script updates installed-map manifests and existing 7z/ZIP packages, retaining shared includes, licenses, configuration, saved worlds and player data. It backs up only the changed pool/manifests, not removed maps; full pinned source copies remain under `.local/`. The original five example maps and other already-excluded maps are outside this voting-pool cleanup.

The deployment vote template is also filtered. PublicMaps and Touchdown import scripts reapply the audited pruning policy with archive updates deferred until packaging. For manually imported Arcade maps, rerun the pruning script before packaging. Repeated pruning is safe when the audited source files have not changed.

Map capacity is not a minimum player requirement and is not proportional to file size. This cleanup reduces distribution/storage size; it does not imply a proportional reduction in server CPU or memory. ZIP and 7z savings depend on compression.
