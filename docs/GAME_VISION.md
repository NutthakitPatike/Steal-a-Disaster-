# Steal a Disaster! — Game Design v0.4 (approved core direction, prototype rules pending)

**Confirmed by the Head:** Direction A (living collectible disasters) and **Disaster Containment** as the core interaction. Players must choose between a safer, slower **Stabilize** capture and a fast, riskier **Snatch**, then escape NPC pursuit while the carried creature reacts in ways that affect play. This is an **approved design direction**, not a completed or playtested system. **Still proposed:** exact controls, effects, map, NPC tuning, balance, number of zones/creatures, title and launch scope. The Head decides these later. This is the project design source of truth; do not create a second PROJECT_SPEC.md.

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

**Player fantasy:** "Enter dangerous storm zones, choose how to contain a living Disaster, adapt to its reactions while escaping a pursuing Warden, then grow your collection and raid other bases." Start with **tiny, approachable weather creatures**; leave space for large natural and cosmic disasters in future updates.

**Approved core hook, still to validate with playtests:** Disaster Containment makes the **capture decision** matter and the **carried creature** change the escape. **Stabilize** takes longer in the danger zone but reduces instability during escape. **Snatch** is instant or short but increases an observable, manageable escape complication. Species reactions change pathing, movement or guard detection in a telegraphed and fair way; they must not randomly punish players. Rival-base theft is a secondary social loop until the PvE containment loop proves fun. No claim is made that competitors lack similar mechanics.

### Primary loop (proposed)
`Train speed → choose zone → choose Stabilize or Snatch → contain living Disaster → adapt to creature reaction + escape NPC Warden → deposit at plot → earn Chaos Coins → upgrade treadmill/trail → unlock zones and complete each Zone Index`

### Secondary social loop (later, proposed)
`View rare character in another base → attempt steal → owner alerted → escape and deposit OR be reclaimed`

### Longer-term (not MVP)
Mutations, special limited Disaster species, community events, additional zones, cosmetic customization and creator-driven short clips. Do not implement based only on competitors having them.

## 3. Progression systems that work together

| System | Player action | What it unlocks | MVP boundary |
| --- | --- | --- | --- |
| **Speed Power** | Run/train | Increased actual running speed on a controlled curve | One speed stat + clear HUD |
| **Treadmill** | Train and buy upgrade with Chaos Coins | Faster Speed Power gains | One basic treadmill, two levels |
| **Trail** | Buy/equip movement trail | Visible identity + multiplier to speed-training gains | Two trail choices |
| **Guarded Zone** | Capture a creature, outrun the Warden | Creatures from the zone; next difficulty tier | Two zones, one guard each |
| **Zone Index** | Discover all species belonging to a zone | One-time cash/speed reward and completion mark | Small 2-entry Index per zone |
| **Base Tycoon** | Place rescued characters | Cash for training upgrades | Four pedestal slots |
| **PvP Steal** | Raid other players' plots | Social drama and prestige | Stage 2/3 only if PvE is fun |

`Speed Power` is a progression score; actual `WalkSpeed` is bounded by a curve rather than equal to a huge displayed number. Trails boost training rate, not infinite movement speed. Coin prices, required powers and multipliers are tuning proposals requiring playtests.

## 4. Living Disaster creatures

Four initial **placeholder** species, two per zone, with easily distinguishable faces, silhouettes and trails. Names are original proposals; no reference-game meshes or animations are authorized for reuse.

| Zone | Creatures | Play identity |
| --- | --- | --- |
| **Breezy Fields** | Breezy (mini tornado), Drizzle (tiny rain cloud) | Easy starter capture; swirl or splash expresses panic |
| **Static Ridge** | Zappy (lightning cloud), Pebble Meteor (glowing meteor) | More valuable; spark/weight reaction on carry |

**Implementation scope:** idle expression, one collect/carry state, one personality reaction and base earning configuration per species. Reuse a single entity/animation framework rather than four separate AI systems. A captured creature has server-authoritative identity, ownership and state; cosmetic reactions can be client-rendered.

**Avoid double punishment:** the primary threat in a PvE capture is the chasing Warden. Creature reactions should be telegraphed and manageable, with clear counterplay; Stabilize and Snatch affect how disruptive those reactions become. The old v0.2 mandatory `Calm` prompt is **deferred** until testing shows it adds fun instead of input overload.

## 5. Zones, NPC chase and movement

Each capture zone contains a small selection of original Disaster creatures and **one Warden NPC** in the first test. Players are offered the two core approaches: **Stabilize** (spend more time near danger to lower escape instability) or **Snatch** (grab quickly, but carry an unstable creature). The actual timing, indicators and penalties require a Roblox Studio prototype; do not copy competitor assets or decompiled hit logic.

**Encounter:**
1. Player sees zone, recommended Speed Power and the zone Index.
2. Player selects **Stabilize** or **Snatch** and picks up the creature; its resulting instability is shown clearly.
3. Warden gives a visible/sounded wake-up warning and pursues the carrier.
4. The creature's telegraphed reaction alters one understandable escape condition, depending on species and capture method. The player chooses a route or response and races to an exit/safe lane.
5. If caught before exit, creature returns to the zone; the player retains their existing collection.
6. At the plot, deposit the captured creature for earnings and Index discovery. Disconnection restores uncaptured item to its zone safely.

**Fairness:** guard behavior should be readable and independently testable; never guarantee a catch or arbitrary instant kill. Zone 1 allows initial success with starter Speed Power. Zone 2 asks players to train and buy a modest upgrade. Guard pursuit is server-authoritative; use limited NPC count, bounded pathfinding and clear safe zone/timeout behavior. Exact speed thresholds, time windows and chase ranges: **UNKNOWN pending Studio testing**.

## 6. Map layout — proposed greybox

Six player plots around a short central plaza. Two **distinct capture zones** beyond the plaza: Breezy Fields (starter) and Static Ridge (higher speed). A visible treadmill near each base or in a common training lane, a small Trail Shop, and one Index panel that switches by zone.

```
           [BREEZY FIELDS: Zone 1]
                       |
   [Plot A]        [TRAIN/PLAZA]        [Plot B]
   [Plot C]         [TRAIL SHOP]        [Plot D]
   [Plot E]         [ZONE INDEX]        [Plot F]
                       |
            [STATIC RIDGE: Zone 2]
```

**Layout rules:** short route from spawn to first catch; direct view of a guarded zone; no giant lobby or lengthy empty corridors. Running and returning must feel exciting, not like a chore. Actual map dimensions and chase lengths must be tuned in Roblox Studio, not invented in documentation.

## 7. Onboarding and UI

Proposed first-session targets, not measured behavior. Tutorial must introduce both capture approaches without forcing a lengthy explanation:

1. **0–15 seconds:** spawn at assigned plot; see tiny Breezy and the objective "Catch your first Disaster".
2. **15–45 seconds:** enter easy zone, choose Stabilize or Snatch, trigger readable Warden chase and a small creature reaction, reach safety and deposit.
3. **45–90 seconds:** notice first Speed Power points, try treadmill, see a Trail and the Zone 1 Index.
4. **Afterward:** buy a training upgrade, complete Zone 1 Index, attempt Zone 2; PvP heists come after the player understands PvE.

Minimal HUD: Coins, Speed Power, current creature carry, Zone Index progress, clear chase alert and next unlock target. Touch and keyboard controls use the same actions.

## 8. MVP staged delivery

| Stage | Build only | Evidence before expanding |
| --- | --- | --- |
| **1 — Core playable** | Greybox plot, **1 easy Zone with tiny Disaster(s)**, 1 Warden, **Stabilize vs Snatch**, one telegraphed carry reaction, escape/deposit, basic income and treadmill speed progression | Solo player can compare both capture styles, observe a fair difference during escape, earn and improve speed without manual fixes |
| **2 — Progression** | Second zone/guard, 3 more creature variants, 2 treadmill levels, 2 trails, Index tab per zone with one-time reward | Training materially changes escape difficulty; Index reward triggers once; mobile playtest passes |
| **3 — Social/beta safety** | Controlled rival-base stealing and recovery only if Stage 1–2 tests justify it; persistence, server-side anti-duplication, mobile/performance and telemetry checks | Two-player raid/defense works; disconnect/rejoin safe; no duplication |

**Not in initial MVP:** large rarity ladder, full destructive disasters, complex disaster AI, multiple guards per zone, long scripted quests, weather simulation, trading, rebirth, premium monetization, large content events and third-party art/code imports.

## 9. Validation

- Observe real first-time players: do they understand the difference between Stabilize and Snatch, where to capture, and why an NPC chases them?
- Measure first capture attempt, successful escape, training engagement, Zone 1 Index progress, loss frustration, return for a second attempt and session length.
- Check that starter zone can be completed without a paid purchase and high-speed trails do not break chase gameplay.
- Test no-player servers, two-player servers, mobile controls, NPC stuck conditions, exit exploits, disconnect, save/load and asset licenses.
- No game popularity, retention threshold or success statistic can be guaranteed before playtests.

## 10. Open Head decisions

- **Already approved at concept level:** Direction A and the Disaster Containment loop (two capture approaches, reactive escape, collection and speed training).
- Confirm exact Stabilize/Snatch durations, instability effects, NPC counterplay, and whether to defer the extra `Calm` prompt. Test them rather than guessing.
- Confirm whether PvP stealing should ship in the first public beta; it remains part of the longer game vision.
- Confirm two capture zones and a minimal four-creature catalog for the prototype.
- Decide final visual theme, name, group ownership, publisher rights and economy balancing after actual prototypes.

The **core direction is approved**; specific feature thresholds and implementation scope remain provisional until a first playable test. This is **not working gameplay** or a claim that full competitor server code was obtained. Verified implementation status remains [CURRENT_STATE.md](../CURRENT_STATE.md).
