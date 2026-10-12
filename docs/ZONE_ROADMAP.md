# Steal a Disaster! — Zone Roadmap v1 (2026-10-13)

**Decision from the Head:** **Public Launch targets exactly FIVE sequential Zones**, so the world has a complete opening progression without bloated content. Zone 6 and Zone 7 are **reserved for major updates after launch**, not part of the initial release commitment. This roadmap is a **content/scoping decision**, not evidence of working gameplay, fixed production dates, a passed playtest or guaranteed release readiness. If the three-person team cannot make all five playable and polished, review scope and release readiness rather than shipping five empty Zones.

**World ordering:** Starting hub/base → Zone 1 → Zone 2 → Zone 3 → Zone 4 → Zone 5 → (later Zone 6 → Zone 7 → ...). Zones form **one continuous long forward route**, as confirmed in [MAP_CONCEPT.md](MAP_CONCEPT.md) v2. The crate reward is revealed at the player's **own base** after escaping the relevant Warden.

## Confirmed launch roster and saved future concepts

| Zone | Name from Head's seven-Zone concept | Environment / identity | Distinctive gameplay idea (proposal, not an approved mechanic) | Release |
| --- | --- | --- | --- | --- |
| **1** | **Tornado Town** | Small town, tornado winds, debris | Learn Containment Crate capture, Stabilize/Snatch and easy Warden chase; wind direction is readable | **Launch target** |
| **2** | **Tsunami Coast** | Coastal town, water, huge waves | Route choice around shallow floods / waves without frustrating slowdown | **Launch target** |
| **3** | **Volcanic Ruins** | Ruined volcanic village, cracked ground, lava | One telegraphed ground/obstacle hazard; avoid instant random deaths | **Launch target** |
| **4** | **Thunderstorm City** | Lightning-lit city, rain, electrical hazards | Clearly warned lightning timing / cover instead of unavoidable hits | **Launch target** |
| **5** | **Inferno Forest** | Wildfire forest, smoky orange skies, spreading fire | Reading a shifting fire route; visually and mechanically distinct from Zone 3's lava | **Launch target / initial endgame** |
| **6** | **Frozen Catastrophe** | Blizzard, ice storm and frozen city | Cold/visibility theme, readable controls (no constant camera blindness) | **Future major update** |
| **7** | **Apocalypse Zone** | Multiple catastrophic events colliding | Major update/Chapter 1 finale concept; one readable signature encounter rather than all hazards at once | **Future major update** |

**Names and thematic order:** taken from the Head's supplied seven-Zone concept and retained as the current planning roster. **The Head confirmed the first FIVE as launch scope**, with 6–7 deferred. Individual Warden names, Disaster names, hazards, exact environments, boss fights, rarity pools and balance are still proposals—not separately locked as build requirements. The earlier placeholder names **Breezy Fields** and **Static Ridge** are superseded by this launch roadmap; do not silently mix both Zone naming sets.

### Content discipline for a three-person team

- **One common Zone template:** identical server-validated capture/spawn/escape/opening architecture, configured using each Zone ID and its spawn pool. Extend the long corridor by adding a new segment, not duplicating whole systems.
- **One Warden per Zone for launch** is the proposed budget, reusing one AI framework with small configuration/behavior variations. No seven bespoke NPC AI implementations.
- **Three to four Disaster variants per Zone** is a **planning ceiling/starting estimate**, **not** a mandatory count or fixed rarity ladder. Prioritize a small recognizable set that can be produced and animated well; actual counts depend on playtest and asset workload.
- **One recognizable environmental hazard/interaction per Zone** is enough. Different appearance and gamefeel matter more than piling on particle systems, simultaneous hazards, boss phases or complicated abilities.
- **No required launch boss fights**, despite boss names appearing in early concepts (e.g., Tornado Guardian, Tsunami Beast, Magma Titan, Storm Colossus, Inferno Beast). Those are parked as possible later events and **not** approved launch mechanics.
- Reuse server-authoritative **two-stage crate randomness**. Do not assume Secret is guaranteed in a higher Zone, prescribe odds, or secretly bias a reward with Stabilize/Snatch.
- **Global Event Spawn** is a later/event operations capability: authorized events may spawn their own event crates in the nominated Zone across all active servers, **not** a personal Spawn Event Boost. The live event engine, giveaways, quantities and permissions remain unimplemented and unbalanced.
- **Long-distance return is unresolved:** test running back from Zones 4–5 after the Warden escape, and consider a fair safe-return mechanic only if validated. Do not erase the challenge of the chase.

## Build and release gates (target, not status)

| Phase | Zone count | Acceptance focus |
| --- | --- | --- |
| **Prototype** | 1 — Tornado Town | A real solo + mobile Studio test: find crate → Stabilize/Snatch → readable Warden escape → bring home → open exact same-tier random Disaster; no duplicate claim |
| **Internal / Closed Beta** | 1–3 | Add Tsunami Coast and Volcanic Ruins through shared modules; compare chase, pacing, progression, performance, return-route pain and Zone Index |
| **Public Launch target** | **1–5** | Thunderstorm City and Inferno Forest added; all five must actually be playable, visually distinguishable, balanced, navigable, tested and worth exploring—not just decorative map shells |
| **Post-launch major updates** | **6–7** | Frozen Catastrophe and Apocalypse Zone when team capacity and player data justify them; weekly updates can instead add events/Crates/Disasters/fixes |

**Avoid feature bloat:** do not promise an untested number of Crates, Secret loot tables, expensive procedural disasters, dynamic physics, custom bosses or five completely different systems at launch. One stable core loop and Zone-specific readable identity beat large content counts.

## Team review questions / open decisions

1. Are the five launch themes distinct enough, especially **Volcanic Ruins vs Inferno Forest**?
2. Which single hazard, Warden variation and small Disaster set fits each Zone's production capacity?
3. How long does it actually take to unlock and return from Zone 5 with a crate? Does it remain fun on mobile?
4. Do higher Zones require a minimum Speed Power, and how are zone boundaries handled on the return?
5. Should Boss concepts stay parked? (Default proposal: **yes**, no bosses for opening release.)
6. When should Zone 6/7 release, and how will weekly events keep players engaged between major Zone updates? No dates have been approved.

**Status:** approved **five-Zone launch target and seven-Zone content roadmap**, while exact implementation scope, in-game numbers, art content and release date require team review and Studio playtests. See [GAME_VISION.md](GAME_VISION.md) and [MAP_CONCEPT.md](MAP_CONCEPT.md).
