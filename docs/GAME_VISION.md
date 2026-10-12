# Steal a Disaster! — Game Design v0.6 (approved feature and weekly live-ops direction, prototype pending)

**Confirmed by the Head (2026-10-13):** Direction A (living collectible Disaster characters), **Disaster Containment** (choose **Stabilize** or **Snatch**), and **Containment Crates instead of eggs**. A crate of a randomly spawned rarity is obtained in an NPC-guarded Zone, carried back through an escape, then opened **at the player's base** to randomly reveal a Disaster from that crate's rarity pool. For instance, a Secret crate can reveal different Secret Disasters, from less desirable to exceptional—not automatically the best Secret. The crate can signal instability and affect the escape before the hidden character is revealed. **Approved at concept level, not implemented or playtested.** Exact crate tiers, odds, species, timing, spawn rates, map size, title and launch scope remain to be designed and tested. This document is the project design source of truth; do not create a second PROJECT_SPEC.md.

## 1. Why this design was revised

The previous v0.2 draft overemphasized rival-base stealing and omitted important progression loops from the reference sources supplied by the Head. This is a source-informed **design proposal**, not a claim that the reference games' full server runtimes were recovered. The ten-game source registry and archive coverage limits are in [REFERENCE_SOURCES.md](REFERENCE_SOURCES.md).

### Evidence from provided Roblox place files

- `Place_114326934417838.rbxlx` (Break and Steal an Egg): `ZonesConfig` configures 10 numbered zones, Guard types, chase tuning, and required Speed Power. `ChaseState`, `GuardChaseVisualsController`, `PickaxeController`, and `EggLocalHits` support the breaking/carrying/chase gameplay.
- The same source: `SpeedConfig`, `SpeedGainController`, `TreadmillUpgradeConfig`, `TreadmillUnlockConfig` define speed growth and treadmill progression. `TrailsConfig` defines purchasable trails with multipliers; the HUD controller combines a trail multiplier with speed gain boosts.
- The same source: `IndexController.zonedPool` groups animal entries by `Zone`, and `IndexConfig.Reward` returns rewards containing `Cash` and `Speed`. `IndexBatRewards` refers to zone completion rewards.
- `Place_107778070777162.rbxlx` (Steal An Egg): `GuardChasePolicy`, `GuardComponent`, `GuardEggRetrievalComponent`, `GuardEscapeRequirement` and `GuardEscapeSignController` handle guard chase/egg recovery and a required-speed display. `TreadmillUtil`, `Trails`, `TrailShopController` and `IndexSectionType` confirm linked speed/trail and area-index systems. The precise live behavior and completeness of the index cannot be proven from client-decompiled code alone.
- The exported scripts have Potassium decompiler headers. Some original server behavior may be missing. Treat observed module/config design as evidence of components, **not** verified live gameplay results.

**Lesson:** The core competitor loop is not just buy/steal/place. It combines **train for Speed Power → attempt a guarded zone → acquire collectible → escape pursuing NPC → return/place for income → upgrade treadmill/trail → reach the next zone → complete each zone's Index**, plus social theft and events. Study these mechanics, but ship original models, names, UI, code and balancing.

## 2. Game promise and differentiation

**Working title:** Steal a Disaster! (provisional). Target experience: a mobile-friendly social Roblox collection game with meaningful action even when nobody else joins the server.

**Player fantasy:** "Spot a rare Containment Crate in a dangerous Zone, choose how to secure it, escape the Warden while the crate behaves unpredictably, and open it back at your base to discover which living Disaster you earned." Start with **tiny, approachable weather creatures**; reserve volcanic, oceanic, planetary and cosmic themes for future updates.

**Approved core hook, still to validate with playtests:** **spawned crate rarity + reveal within that rarity + reactive escape**. The player chooses **Stabilize** (slower, safer containment) or **Snatch** (faster, less stable containment) at a guarded crate. A carried crate has readable signals (shaking, light, sound or short environmental effects) that affect an escape choice without revealing the hidden reward. Effects must be telegraphed and counterable—not an unavoidable random loss. **Capture method does not change the reward odds by default**; its purpose is an escape-risk tradeoff, unless the Head explicitly revises it. Rival-base theft remains the secondary social loop. No claim is made that competing games lack similar mechanics.

### Primary loop (confirmed concept; tuning proposed)
`Train Speed Power → enter an unlocked Zone → find a randomly spawned Containment Crate of a visible tier → choose Stabilize or Snatch → carry the unstable crate and escape its NPC Warden → secure crate at own base → open it for a random Disaster within its tier → place/discover the Disaster → earn Coins, improve treadmill/trails and fill Zone Index → unlock harder Zones`

### Secondary social loop (later, proposed)
`View rare character in another base → attempt steal → owner alerted → escape and deposit OR be reclaimed`

### Longer-term and recurring content (not all MVP)
Different crate skins (Volcano, Tsunami, Cosmic), mutations, limited Disaster species, **approved Special Crate Spawns, modular Warden variants, Disaster Synergy and Duplicate Progression**, weekly updates and recurring **Admin Abuse** events/giveaways. Build rarity pools, NPC modules and event configurations as **data-driven additions**, without remaking the hub, bases or crate-opening logic. Timing, rewards and feature scope still need review; see Section 8A.

## 3. Progression systems that work together

| System | Player action | What it unlocks | MVP boundary |
| --- | --- | --- | --- |
| **Speed Power** | Run/train | Increased actual running speed on a controlled curve | One speed stat + clear HUD |
| **Treadmill** | Train and buy upgrade with Chaos Coins | Faster Speed Power gains | One basic treadmill, two levels |
| **Trail** | Buy/equip movement trail | Visible identity + multiplier to speed-training gains | Two trail choices |
| **Guarded Zone** | Secure a randomly spawned Containment Crate and outrun the Warden | Crate rarity pools associated with the Zone; next difficulty tier | One starter Zone/guard in first test; second Zone later |
| **Zone Index** | Open Zone crates and discover species in their reward pools | One-time cash/speed reward and completion mark | Starter Index with a small species pool |
| **Base Tycoon** | Bring home, open secured crates and place revealed Disasters | Cash for training upgrades and collection growth | One reliable crate-opening point + small pedestal set |
| **PvP Steal** | Raid other players' plots | Social drama and prestige | Stage 2/3 only if PvE is fun |

`Speed Power` is a progression score; actual `WalkSpeed` is bounded by a curve rather than equal to a huge displayed number. Trails boost training rate, not infinite movement speed. Coin prices, required powers and multipliers are tuning proposals requiring playtests.

## 4. Containment Crates, rarity pools and living Disasters

**Locked presentation choice:** **Containment Crates, not eggs.** These are designed as original containment devices with warning markings, visible energy leaks and rarity-specific silhouettes/VFX—not generic cardboard boxes. The crate itself must be legible in the Zone and fun to carry in an escape.

### Two-stage randomness (approved concept)

1. **Spawn stage:** a Zone spawns a crate; crate tier/rarity is determined by its Zone spawn table. High tiers may have rarer spawns. Visuals should tell players the crate tier before the risk of capture; exact rates and spawn rules are **undecided**.
2. **Reveal stage:** after safely returning the secured crate **to the player's base**, opening it randomly selects a Disaster **from that crate tier's pool**. Example: a **Secret** crate gives one of multiple **Secret** characters, including weaker/common-within-Secret and exceptional/rare-within-Secret outcomes. A Secret crate **does not guarantee the best Secret character**. Exact odds, duplicate treatment, modifiers and payouts are **undecided**.

**Fairness and trust:** publish clear rarity/loot information in game; no bait-and-switch tier promises. Spawn/reveal resolution, crate identity, ownership, opening and rewards must be **server authoritative**, with exactly-once grants and safe rejoin handling. Do not let reconnects reroll the same crate or let client requests assign contents. Stabilize/Snatch should affect escape risk, **not secretly manipulate loot odds**.

### Starter creatures (proposals, not the complete tier table)

Four initial **placeholder** species, two per Zone in the previous draft; the actual launch Zone and rarity pools are still undecided. Names are original proposals; no reference-game meshes or animations are authorized for reuse.

| Zone | Creatures | Play identity |
| --- | --- | --- |
| **Breezy Fields** | Breezy (mini tornado), Drizzle (tiny rain cloud) | Tiny, friendly starter rewards; distinctive swirl/splash **after reveal** |
| **Static Ridge** | Zappy (lightning cloud), Pebble Meteor (glowing meteor) | Higher-tier placeholder rewards; sparks/weight animation **after reveal** |

**Implementation scope:** one reusable crate spawn/carry/escape/open pipeline; one or two starter crate tiers and a small server-configured reward pool for the first prototype (tier count is a **test proposal**); revealed Disaster idle expressions and base earning configs. Hidden characters need not be spawned or visually identified during carry. Creature ownership and reveal are server authoritative; cosmetic reactions can be client rendered.

**Avoid double punishment and loot spoilers:** the Warden is the primary threat. During carry, the **crate** shows telegraphed, manageable instability (sparks, wind leaks, brief route changes), without leaking the final hidden character. Stabilize and Snatch modify this risk, not the tier/pool by default. The old v0.2 mandatory `Calm` prompt remains deferred until testing shows it is fun.

## 5. Zones, NPC chase and movement

Each capture Zone spawns **Containment Crates** with visible tiers from its data table, guarded by **one Warden NPC** in the first test. Players are offered **Stabilize** (spend more time in danger to reduce instability) or **Snatch** (grab faster, risk a more troublesome crate during escape). The final Disaster remains hidden until the crate is opened at the base. The exact timing, indicators, crate rates and penalties require a Studio prototype; do not copy competitor assets or decompiled hit logic.

**Encounter:**
1. Player sees Zone, recommended Speed Power, Zone Index and the **tier of a randomly spawned crate**.
2. Player selects **Stabilize** or **Snatch** and carries the crate; instability status appears.
3. Warden gives a visible/sounded warning and pursues the carrier.
4. The **crate's** telegraphed instability alters one understandable escape condition; player can respond with a route/movement choice without learning the hidden character.
5. If caught before the safe exit, the **unsecured crate** is lost/returned to the Zone; existing collection remains untouched.
6. After escaping, player brings the secured crate back to their **own base** and **opens** it. The server randomly reveals a Disaster **inside that crate's rarity pool** and grants that result exactly once; player places it for earnings and updates Index progress.
7. On disconnect, authoritative crate state prevents disappearance/duplicate opening. Exact persistence rules for crates secured but not yet opened are **to be designed and tested**.

**Fairness:** guard behavior should be readable and independently testable; never guarantee a catch or arbitrary instant kill. Zone 1 allows initial success with starter Speed Power and small Disaster rewards. Higher Zones scale through both Warden behavior and crate pools. Guard pursuit is server authoritative; use limited NPC count, bounded pathfinding and a clear safe zone. Spawn rates, reward odds, speed thresholds, escape times and chase ranges are **UNKNOWN pending design/playtesting**.

## 6. Map layout — [Linear Map Concept v2 for team review](MAP_CONCEPT.md)

The Head's original black-and-white sketch shows **one wide horizontal hub area with seven internal rectangular footprints** and **a narrow upward connector**. What these seven rectangles represent has **not been confirmed**. The previous "six player plots / two Zones in fixed positions" illustration was a **draft assumption, not approved map topology**.

**Head-confirmed map direction (2026-10-13):** a **single long, connected progression**: **Zone 1 → Zone 2 → Zone 3 → ...**, with future Zones appended in sequence. The previous side-branch Future Zone Junction and separate Event Plaza are **superseded**.

The revised [Map Concept v2](MAP_CONCEPT.md) and [top-down SVG](assets/map-concept-v1.svg) preserve the wide initial seven-Bay silhouette and upward corridor. Zone 1 is the first test; Zone 2 follows directly beyond it; later Zones continue **along the same physical route**. Each Zone may have its own crate pool and Warden variant. Within a Zone, alternative escape routes may be tested without branching the overall progression.

**Admin Abuse occurs inside existing Zones:** e.g. on the Zone 2 update, an authorized admin may `/spawn Secret Crate Zone 2`, announce the special crate, and run giveaways. This is an **event concept**, not finalized command syntax, spawn odds, quantity, permission model or economy.

**Still subject to Head and teammate review:** the original seven rectangles' function/base count, whether the central Bay is a hub, exact corridor distances, Safe Exit and return-to-base approach as the world grows, Zone unlock rules and event accessibility. The first greybox should still be only Zone 1. Do not invent dimensions or build permanent geometry until approved.

## 7. Onboarding and UI

Proposed first-session targets, not measured behavior. Tutorial must introduce both capture approaches without forcing a lengthy explanation:

1. **0–15 seconds:** spawn at assigned plot; see an easy crate spawn, and objective "Bring back your first Containment Crate".
2. **15–45 seconds:** enter starter Zone, identify crate tier, choose Stabilize or Snatch, trigger Warden chase and a small crate reaction, then escape.
3. **45–90 seconds:** return to the base, open the secured crate, reveal a tiny Disaster, place it and discover its Index entry.
4. **Afterward:** notice Speed Power, try treadmill/trails, compare rarities and attempt a harder Zone when ready; PvP theft comes after PvE is understood. **Times are aspirational and unmeasured**.

Minimal HUD: Coins, Speed Power, **current crate rarity + instability**, Zone Index progress, chase alert and next unlock target. Clearly distinguish **crate secured** from **opened/revealed**. Touch and keyboard controls use the same actions.

## 8. MVP staged delivery

| Stage | Build only | Evidence before expanding |
| --- | --- | --- |
| **1 — Core playable** | Greybox plot, **1 easy Zone spawning small Containment Crates**, 1 Warden, **Stabilize vs Snatch**, one telegraphed crate reaction, escape/return, **base opening + tier-based random reveal** of a tiny living Disaster, basic income and treadmill | Solo player completes both capture paths, sees fair escape-risk differences, opens a crate for one correct-tier result and cannot duplicate the reward |
| **2 — Progression** | Additional Zone/guard, more crate tiers and Disaster outcomes, treadmill upgrades, trails, and per-Zone Index rewards | Crate spawn rarity and within-tier reward sampling work as designed; Index rewards trigger once; training and mobile playtests pass |
| **3 — Social/beta safety** | Controlled rival-base stealing and recovery only if Stage 1–2 tests justify it; persistence, server-side anti-duplication, mobile/performance and telemetry checks | Two-player raid/defense works; disconnect/rejoin safe; no duplication |

**Not in initial MVP:** large rarity ladder or Secret jackpot economy, full destructive disasters, complex creature AI, multiple guards per Zone, long quests, weather simulation, trading, rebirth, premium monetization, large events and third-party art/code imports. **Secret crate with lower/higher Secret outcomes is a confirmed design example, not a requirement to launch with Secret content.**

## 8A. Approved feature direction and weekly live operations (2026-10-13)

The Head reviewed five ideas and set the following priorities. These are **design approvals**, not shipped mechanics, measured retention claims or a promise that all five belong in the first playable MVP.

| Feature | Head decision | Design/rollout boundary |
| --- | --- | --- |
| **Crate Instability** | **Try first** | Prototype one telegraphed, fair crate effect during the Warden escape; retain, revise or discard based on player tests. Stabilize/Snatch modifies escape behavior, **not hidden loot odds** by default. |
| **Warden variants** | **Should be developed and extended** | Architect Guards as modular configurations/behaviors so future weekly releases can add or change chase encounters. Avoid demanding a brand-new NPC model every week if balancing or polish would be better. |
| **Special Crate Spawn** | **Should exist** | Rare or event crates may spawn with a clear server-wide warning and a time-limited competition opportunity. Keep tier messaging, spawn control, ownership and rewards server authoritative. |
| **Disaster Synergy** | **Good direction** | Support data-defined combinations of displayed Disasters (e.g., Tornado + Lightning visual synergy) and possibly balanced effects later. Do **not** require full synergy mechanics for the first prototype. |
| **Duplicate Progression** | **Good direction** | A duplicate Disaster should remain useful (research, collection mastery or controlled progression). Exact conversion rates, fusion rules and upgrades are **not decided**. |

### Weekly update and Admin Abuse direction

**Confirmed product cadence target:** aim for **one game update per week**, with ongoing live-event/contents improvements. Each weekly release should offer a noticeable reason to return—e.g., new crate/Disaster pool, Warden encounter, new event interaction, cosmetics, collection goals or balance/quality fixes. A new Zone is **not required** every week. Actual deployment day/hour, staffing, first release date, content quantity and schedule guarantees remain **undecided**.

**Confirmed event direction:** stage lively **Admin Abuse** sessions and worthwhile giveaways/handouts as recurring live operations. The event is an **announced, controlled developer-run experience**, not permission for arbitrary moderators to change player data. Possible event activities to test: temporary special crate spawns, unusual Warden behavior, global visual/weather moments, community reward drops and time-limited cosmetic collectibles. Which rewards are claimable, their supply, eligibility, caps and odds are **not decided**.

**Technical and economy guardrails (proposal pending implementation review):**
- Use a **data-driven event calendar/config** for weekly crate tables, NPC variants and limited rewards; don't hardcode a new parallel system each week.
- Admin actions must be **server authorized and permission-gated**, with rate limits, audit logs, bounded duration, safe disable/rollback and clear separation between test/staging and production. Do not expose grant/spawn remotes to clients.
- Event giveaways should not silently devalue rare crate tiers, skip all meaningful progression or allow farming/duplication. Consider cosmetics, bounded bonuses and transparent limited rewards first; keep normal players able to participate.
- Reserve **controlled Admin Abuse spawn nodes within each relevant Zone** (e.g. Secret Crate inside Zone 2 when the new Zone is celebrated), not a separate Event Plaza. Confirm player access, permitted Zone targets and the map layout with teammates before building.
- Check mobile performance, NPC pathing, server load and save safety in staging before every public event/update.

**Release process:** Prepare content → teammate review + server validation → staging playtest → announce weekly release/event → Head approves publish → monitor errors/economy → document follow-up. This is a **target workflow**, not a deployed automation or event.

## 9. Validation

- Observe first-time players: do they understand **visible crate rarity**, Stabilize/Snatch, why a Warden chases them and that they must **open the crate at their base**?
- Measure time to acquire a crate, escape success, base opening, reward comprehension, repeated runs, training engagement, Zone Index progress and loss frustration.
- Test that the second roll returns **only a valid reward in the selected crate's tier** and parallel/open-after-reconnect requests cannot duplicate rewards.
- Check that starter zone can be completed without a paid purchase and high-speed trails do not break chase gameplay.
- Test no-player servers, two-player servers, mobile controls, NPC stuck conditions, exit exploits, disconnect, save/load and asset licenses.
- No game popularity, retention threshold or success statistic can be guaranteed before playtests.

## 10. Open Head decisions

- **Already approved at concept level:** Direction A, **Containment Crates instead of eggs**, randomly spawned crate tiers in guarded Zones, return-to-base opening, **second randomness within the crate tier**, Stabilize/Snatch, reactive crate escape, collection and speed training.
- Decide actual crate tier names, spawn tables, loot odds, sample species and duplicate handling. The **Secret crate → different Secret outcomes** is the approved example, with no probabilities defined.
- Confirm Stabilize/Snatch durations, instability effects, Warden counterplay, handling of held/unopened crates on rejoin, and whether to defer the extra `Calm` prompt. Test them rather than guessing.
- Confirm whether PvP stealing should ship in the first public beta; it remains part of the longer game vision.
- Confirm when Zone 2 is added to the **long sequential corridor** after the Zone 1 prototype; exact initial catalog and Zone counts beyond the first test remain open.
- Decide final visual theme, name, group ownership, publisher rights and economy balancing after actual prototypes.

The **core direction is approved**; specific feature thresholds and implementation scope remain provisional until a first playable test. This is **not working gameplay** or a claim that full competitor server code was obtained. Verified implementation status remains [CURRENT_STATE.md](../CURRENT_STATE.md).
