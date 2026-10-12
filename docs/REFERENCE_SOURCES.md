# Reference game source registry

**Purpose:** Find and evaluate systems in the ten Roblox place exports supplied by the Head without confusing decompiled client-side observations with working server gameplay.

**Original files supplied (not copied to Git):**

| Game | Original export | Script instances indexed | With Source | Missing Source |
| --- | --- | ---: | ---: | ---: |
| Steal An Egg | `Place_107778070777162.rbxlx` | 1,956 | 1,920 | 36 |
| Break and Steal an Egg | `Place_114326934417838.rbxlx` | 615 | 609 | 6 |
| Drop a Fruit | `Place_82132121666307.rbxlx` | 1,268 | 1,261 | 7 |
| Build a Boat for Treasure | `Place_537413528.rbxlx` | 3,118 | 178 | 2,940 |
| Natural Disaster Survival | `Place_189707.rbxlx` | 535 | 519 | 16 |
| Grow a Garden | `Place_126884695634066.rbxlx` | 12,388 | 2,050 | 10,338 |
| Grow a Garden 2 | `Place_97598239454123.rbxlx` | 1,753 | 1,358 | 395 |
| Steal a Brainrot | `Place_109983668079237.rbxlx` | 1,336 | 910 | 426 |
| DOORS (run place) | `Place_6839171747.rbxlx` | 203 | 166 | 37 |
| Evade | `Place_9872472334.rbxlx` | 3,745 | 1,337 | 2,408 |
| **Total** | **Ten exports** | **26,917** | **10,308** | **16,609** |

The latest extracted **source-only** archive is named `roblox_reference_sources_10_maps.zip` and was generated in the ChatGPT conversation. It contains 9,497 distinct source-text hashes (deduplicated **within each game**, including failed decompiler placeholders), plus records for all 26,917 script instances. **10,308** instances have nonempty Source text, but only **10,128** contain potentially readable code-like text: 165 contain `Decompilation failed` and 15 contain `Empty bytecode`. Code-like text is not proof of correct or complete runtime logic. See the `source_quality` column in the generated index. The archive is **not currently present on the Head's D: drive**; download it from the ChatGPT artifact and unpack it under `reference_sources/` if local browsing is needed. This folder is ignored by Git. Raw maps, models, meshes, binary assets and complete place instance structures remain in the original `.rbxlx` exports rather than the source-only ZIP.

## What's saved in the archive
- `SYSTEM_CATALOG.md` and `SYSTEMS.json`: candidate system groups, counts and representative script names.
- `all_scripts_index.csv`: full per-instance lookup by game, class, in-game path, Source status, **Source quality**, content hash and tags.
- `<game>/manifest.json`: all Script, LocalScript and ModuleScript instances, including those with missing Source.
- `<game>/scripts/*.luau`: decompiled/readable source text, deduplicated by SHA-256.
- `<game>/interface_instances.json`: RemoteEvent, RemoteFunction, bindables, prompts, tools and other specified class locations.
- `OVERVIEW.json`: provenance, SHA-256 of each original place export and extraction counts.

No script instance is omitted from the manifest; **missing Source is not reconstructed**. The original export is still needed to study non-script assets and geometry.

## Systems worth studying first for Steal a Disaster

| Reference | Verified named modules in supplied source | Research question |
| --- | --- | --- |
| Break and Steal an Egg | `ZonesConfig`, `ChaseState`, `GuardChaseVisualsController` | NPC pursuit and Zone difficulty |
| Break and Steal an Egg | `SpeedGainController`, `TreadmillUpgradeConfig`, `TreadmillUnlockConfig`, `TrailsConfig` | Speed gain and equipment progression |
| Break and Steal an Egg | `IndexController`, `IndexConfig`, `IndexBatRewards` | Per-Zone Index and one-time rewards |
| Steal An Egg | `GuardChasePolicy`, `GuardEggRetrievalComponent`, `GuardEscapeRequirement` | Guard chase, retrieval and escape requirements |
| Steal An Egg | `TreadmillUtil`, `TrailShopController`, `AreaIndexProgressComponent` | Training, trails and collection progress |
| Drop a Fruit | `FruitController`, `IndexRewardUtil`, `Weather` | Collection, rewards and weather variation |
| Build a Boat for Treasure | `ZoneLockLS`, `VehicleController`, `QuestConditions` | Zone locks, vehicles and quests — **server bodies largely unavailable** |
| Natural Disaster Survival | `Disaster Warning`, `NPC Dialog` | Disaster warning/feedback and player interaction UI |
| Grow a Garden | `MutationVFXVisibilityController`, `SeedShopDataProvider`, `WeatherDynamicFXHandler`, `StealAPetController` | Mutations, weather, seed-stock systems, pet theft; **10,338 instances lack Source** |
| Grow a Garden 2 | `GuildShopController`, `ViewGuildProgressController`, `StealReturnArrowController`, `WeatherStaffController` | Guild/social progression, theft recovery and weather |
| Steal a Brainrot | `StealController`, `WorldBrainrotController`, `BrainrotPreloadingController`, `Mutations` | Rival base theft, collection presentation and rarity/mutation |
| Evade | `3DNextbot`, `3DNextbotSimple`, `CharacterService`, `InteractionTypes`, `NextbotEffects`, `SprintCamOffset` | NPC/Nextbot movement tuning, client-facing character and interaction systems, chase presentation; **server implementation is not fully visible** |
| DOORS (run place) | Scene/interfaces only; **0 usable Script bodies** | 165 source texts are decompilation failures, 1 is empty bytecode, 37 missing; **cannot validate warning/hiding/AI logic from this export** |

The above entries are pointers to code and **not proof of full server runtime behavior**. Other systems (economy, raids, items, UI, animation, assets, persistence, admin, events, social, monetization and supporting libraries) are indexed in the complete CSV and manifests, rather than selectively discarded.

## How an AI must use this
1. Begin with the original place name and archive `all_scripts_index.csv`.
2. Open the matching manifest and actual source by its `file` key, and record precise evidence.
3. Follow references to dependencies, config and Remote instances; mark missing server logic or decompiler errors as UNKNOWN.
4. Separate **Observed from Source**, **Inferred Design**, and **Tested in Runtime** in every recommendation.
5. Create original Roblox Luau and assets for our own game; do not copy third-party scripts, copyrighted artwork, audio or game assets without rights.

The source archive is **research-only**, not a runtime dependency. There is no need to add entire decompiled games to GitHub or `src/`. If more evidence is requested, prefer the smallest missing module or an authorized source over another massive place export.
