# Steal a Disaster! — Map Concept v1 (TEAM REVIEW DRAFT)

**Status:** PROPOSAL ONLY. Top-down layout for the 3-person team's review; no Studio greybox, implementation, plot count, distances or art style approved by the Head yet. [Game Design v0.6](GAME_VISION.md) remains the approved mechanic source of truth.

![Map Concept v1 — top-down](assets/map-concept-v1.svg)

[Open the map as an SVG](assets/map-concept-v1.svg) · SVG labels are **English for easy team review**, but player-facing language/UI are undecided. Diagram is **not to scale**.

## 1. Preserve the Head's original sketch without inventing its labels

The original sketch shows a **wide horizontal main footprint divided into seven internal rectangles** and a **long narrow connection going upward from around its center**. Its rectangles were **not confirmed to be seven player bases**. This draft **preserves the silhouette only** and labels seven footprints **Bay 1–7 as unassigned placeholders**. The **middle Bay 4 as Central Hub** is a **design proposal**, not an interpretation confirmed by the Head. Other bay roles, size and number of player plots remain open. Earlier prose suggesting exactly six plots is **superseded as an unapproved illustration**.

The upward connection is a clear **return/access lane** to the Zone. A **separate Event Plaza** and a **Future Zone Junction** branch sideways off this connection so events, future content and portal updates do **not** block the core route. A future Zone does not have to be entered via the dangerous Zone 1.

## 2. Proposed spatial contracts

| Area | Spatial role | Why it belongs here | Ownership/status |
| --- | --- | --- | --- |
| **Seven horizontal Bays** | Reserved footprints in the original wide hub silhouette | Hold candidate base plots, services or future space *after* review | **Unassigned**. Never assume six/seven bases; prototype one test plot only. |
| **Central Hub (proposed Bay 4)** | Spawn navigation, training, Trail Shop, Index, next goal/Zone indicators | Player can see a clear way to the first crate and return without walking a giant lobby | **Proposed**; choose actual kiosk locations after greybox. |
| **Own-plot Crate Opening** | Station **inside the assigned player's own base** | Explicitly preserves approved two-stage random reward loop | **Approved functional requirement**; exact physical plot locations open. |
| **Upward Access Lane** | Connect hub to Zone access/safe return; signposted travel | Follows the original vertical path and makes orientation obvious | Shape proposed; width/length not measured. |
| **Zone 1: Tiny Weather** | First crate Zone with visible spawn rarity and **one Warden** | Test the approved capture/escape/reveal loop without shipping an entire world | First **playable** scope; specific styling provisional. |
| **Escape Routes A + B** | Two understandable routes around Warden cover/patrol toward Safe Exit | Make Stabilize/Snatch and unstable crates produce readable choices, not automatic failure | Proposed for greybox; check actual line-of-sight and fairness. |
| **Safe Exit** | Clear checkpoint where Warden pursuit ends and crate is secured for return | Avoid unfair pursuit into bases; reset NPC cleanly | Functional boundary proposed; exact server rules require test. |
| **Event Plaza** | Reusable Admin Abuse stage, broadcast/giveaway visuals, possible special crate events | Weekly content can rotate without demolishing the hub or interfering with ordinary training/escape | Space reservation only; admin actions/rewards not coded. |
| **Future Zone Junction + wings** | Independent portal/gate slots for branching later Zones | Weekly updates and future expansions attach as modules, not a forever-long straight corridor | **Reserved footprint only**; no premature Zone content. |

**Base access and PvP (not first playable):** once Bays are assigned, a player's return path must reach their **own** base opening station without walking through another player's plot. Base stealing/protection mechanics remain later-stage decisions.

## 3. Zone 1: moment-to-moment route

1. **Spawn and orient:** a new player starts near the chosen base/test plot, sees the Hub objective, trains minimally if necessary and follows clear navigation toward Zone 1.
2. **Find a crate:** a server-configured spawn node selects a **visibly identified crate tier**; multiple *candidate nodes* may exist, but actual simultaneously active spawn count is undecided. The first experience should not require long wandering or random waiting.
3. **Capture:** player approaches the guarded crate and chooses **Stabilize** or **Snatch**. Avoid making a cramped choke point the only place to interact.
4. **Escape:** the Warden warns/chases. Routes **A** and **B** provide navigable cover/options; a single experimental crate-instability cue can alter route planning with a readable counterplay.
5. **Secure:** crossing the Safe Exit stops/resets the Warden using server-validated state. A crate that is not yet secured can be lost when legitimately caught; exact loss/recovery rules remain to test.
6. **Return and reveal:** player takes the **secured crate into their own base** (not an Event Plaza opening), opens it **exactly once** and receives one random Disaster from the **same tier pool**. Assign/discover and place for progression.

**Travel feel to test, not invented timings:** first-time orientation, time to first crate, escape duration, safe return, and base-opening time. Keep zone-1 starter path accessible without paid upgrades. The previous onboarding 0–90s guidance in Game Vision is aspirational, not a geometric measurement.

## 4. Fairness, access and map boundaries

- **No forced Warden trap:** routes must be meaningfully different and give escape counterplay. The Safe Exit must not be a one-person bottleneck that the Warden can camp. Test mobile camera/readability, movement speeds and line of sight.
- **No reward-spoil during escape:** crate rarity is visible but the actual Disaster is hidden until opened **at base**. Escape effects communicate instability without giving away the final rolled creature.
- **Event safety:** special crate announcements/spawns should be clear and optional; ordinary players must retain access to base, training and Zone 1 while Admin Abuse runs. Event rewards and admin authority are separate gameplay/server design decisions.
- **Performance:** use one Warden in first prototype; cap active NPCs/FX and event decorations. Streaming, navmesh/pathfinding and mobile-device draw costs must be evaluated in Studio.
- **Expandable ownership:** plan module folders/IDs per Zone, Gate, Bay and Event area. Do not hard-wire all world destinations into one Script or physically extend the only narrow corridor on each weekly update.
- **No exact map metrics invented:** lengths, widths, heights, spawn chances, Warden speed/detection, escape duration, number of players/bases, portal destinations and lighting/art budget remain **TBD**.

## 5. Suggested Roblox Studio greybox slices (NOT APPROVED FOR BUILD)

| Slice | Blockout only | Evidence required before proceeding |
| --- | --- | --- |
| **A — First playtest** | Central navigation hub, **one temporary player plot with base crate opener**, vertical access, Zone 1, candidate crate spawn, Warden, two escape paths, Safe Exit | First-time solo player can complete an actual secured-crate return/open cycle; NPC doesn't get stuck; both routes and both capture modes are usable on keyboard and mobile. |
| **B — Confirm the horizontal Bays** | Assign final plot/service count *only after Head interprets seven sketch rectangles*; refine entry distances and plot openings | Team accepts plot ownership, unobstructed access and adequate social space. |
| **C — Release expansion interfaces** | Add inactive Event Plaza and Future Zone Junction/portal anchors; only then build approved event mechanics/content | Event navigation never blocks base or Zone return, performance budget measured, authorized Admin Abuse remains controlled. |

**No Roblox Studio changes** or assets are included in this Map Concept PR. The illustration and text are design references only, **not** exact 3D models or geometry.

## 6. Questions for three-person review

1. **Head:** What do the original sketch's **seven rectangles** represent? Are they player plots, mixed spaces, or another plan? Is **Bay 4 as Central Hub** acceptable?
2. **All three:** Is the main access/return lane too long or restrictive? Should it branch nearer the Hub or use direct portal/shortcuts as the game expands?
3. **All three:** Are two escape choices in Zone 1 meaningful, and can the Warden pursue fairly without camping the Safe Exit?
4. **All three:** Is the Event Plaza sufficiently independent for weekly Admin Abuse and special crate spawns, without reducing ordinary players' access?
5. **Studio/map owner:** What is the minimum performance-safe greybox and where should Zone, paths and bay anchors live? Record test evidence, not guessed map units.
6. **Head:** After the team reviews this plan, approve/revise the map **before** assigning Issue #3 as a Roblox Studio implementation task.

## 7. Related work

- **Approved gameplay direction:** [GAME_VISION.md](GAME_VISION.md), v0.6.
- **Prototype implementation planning:** [GitHub Issue #4](https://github.com/NutthakitPatike/Steal-a-Disaster-/issues/4).
- **Zone 1 design/greybox ownership:** [GitHub Issue #3](https://github.com/NutthakitPatike/Steal-a-Disaster-/issues/3).
- **Weekly events and Admin Abuse:** [GitHub Issue #7](https://github.com/NutthakitPatike/Steal-a-Disaster-/issues/7).

**Change policy:** this file is a map-review proposal, not an accepted production map. The Head confirms or revises layout decisions after teammate review; gameplay implementation and Roblox live publishing require separate approval.
