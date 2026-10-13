# World, art and UI specification

Status PROPOSED. This is an original production direction informed by reference measurements in [the audit](01-audit.md). It is not a screenshot of a built game. All dimensions are candidate blockout values pending physical travel tests.

## 1. Full world layout

Keep the familiar broad starting hub, seven visible bases and a forward sequence of biomes. Retain the project's −Z direction to minimize integration churn. Do not claim the horizontal base row matches the reference's five-plus-two arrangement.

```text
                    FUTURE Z6 / Z7 connection, closed at launch
                                  |
                 Z5 Inferno Forest [safe return lane east]
                                  |
               Z4 Thunderstorm City [safe return lane east]
                                  |
                 Z3 Volcanic Ruins [safe return lane east]
                                  |
                  Z2 Tsunami Coast [safe return lane east]
                                  |
                   Z1 Tornado Town [safe return lane east]
                                  |
                  Zone gate / instructions / route sign
            Shop      Sell      Fuse      Trails shop
                        Physical treadmills
             B1   B2   B3   B4   B5   B6   B7
                         Spawn / town square
```

All seven bases are dedicated player bases. Services are in a separate band, not substituted for B4. Each base contains its own Crate opening station, Collect terminal, Upgrade Pen terminal and four expandable Disaster pads. “Upgrade Pen” refers to this base upgrade function, not an eighth base.

| Region | Candidate bounds / placement | Acceptance purpose |
|---|---|---|
| Hub | X −200…200, Z −105…125 | Seven bases and service band without overlapping signs |
| Base centers | X −162,−108,−54,0,54,108,162; Z55 | Seven36×44 pads,18stud between pad edges |
| Opening stations | Same X, Z45 | One interact point at each own base, accessible from front |
| Collect / Upgrade Pen | Rear-side of each base, no opposing prompt overlap | Returning player can open, place, collect and upgrade without leaving plot |
| Services | X −120…120, Z−25 | Shop/Sell/Fuse/Trails, distinct icons and architectural shapes |
| Treadmills | Seven belts in a visible shared pavilion at Z−65 | One user per belt, individual upgrade settings; queue not required for7users |
| Zone1 | Z−130…−250, width144 | Starter acquisition about60–90stud past entrance |
| Zone2 | Z−270…−430, width144 | First alternate escape line |
| Zone3 | Z−450…−630, width160 | Broad corners, magma chasm sightline |
| Zone4 | Z−650…−850, width160 | Vertical skyline but ground-level escape path |
| Zone5 | Z−870…−1090, width176 | Strong long-range landmark, no full-screen fire wall |
| Return lane | East side, X≈60…76 in early zones, widen with biome | Continuous floor and marker chain through every connector toHub |

Candidate layout shortens Zone1 before committing to high-detail art. Do not blindly resize the existing Place. P3-01 first measures both the saved map and candidate blockout in an isolated copy, then selects the layout that meets time budgets. Moving scene anchors requires a versioned WorldContract migration.

Budget at starter speed is first acquisition≤30s from spawn, escape after capture5–15s, and first home return≤25s after safe exit. Later Zone5 safe-exit→home target≤45s at unlocked speed/return boost. Existing geometric lower bounds are not proof that these budgets pass. Record actual path length and p50/p90 journeys, with seven players and mobile movement. If return exceeds the budget, shorten connectors or adjust return lane speed within a reviewed cap. Do not add automatic transport.

Forward progression remains linear. Each Zone has two internal routes, a readable main lane and a narrower cover route, joining before its backward safe exit. Crate nodes lie inside the guarded area. The safe lane cannot be reached from the middle of the encounter through an unguarded gap. Physical ramps/barriers guide the exit, and the server validates the bounded crossing. A player must not unlock safety by jumping outside the map.

## 2. Zone art and gameplay language

| Zone | Landmark / shape language | Signature route hazard | Warden treatment | Props and audio |
|---|---|---|---|---|
| Tornado Town | Tilted water tower and pinwheel roofs; soft rounded houses | Telegraph1.5s wind gust across one fork for2s, alternate fork remains open | Wind inspector with spinning hat; shortest chase | Bent fences, mailboxes, loose paper, gentle wind and warning whistle |
| Tsunami Coast | Lighthouse and enormous distant curled wave | Marked shallow surge on lower boardwalk; dry upperroute always available | Buoy keeper, broad readable turn | Dock posts, rope coils, foam clusters, gulls and muted surf |
| Volcanic Ruins | Broken caldera gate, angular basalt | Vented tile glows2s before active1s; bypass always wide enough | Basalt sentinel, slower turn and clear footsteps | Broken arches, cooling lava, ash in background only |
| Thunderstorm City | Lightning rod tower, stepped rooftops | Small ground strike marker2s beforeflash; shelter route | Circuit marshal, short telegraphed straight burst then recovery | Cable channels, street signs, neon accents not walls ofglow |
| Inferno Forest | Giant hollow ember tree, branching silhouette | Smoldering bramble segment changes which fork is shorter | Firebreak ranger, one announced route interception | Charred stumps, regrowth, amberleaf canopy, crackle without constant roar |

Hazards primarily change route choice. They do not remove banked or owned items, and they cannot stack into an unavoidable stun/catch. P1 uses ordinary pathfinding first. P3 adds one signature hazard and visual/audio Warden variation per Zone within the same state framework. Advanced enemy variants remain update work.

## 3. Environment art bible

Tone is cheerful industrial containment with living natural energy. Forms use broad readable silhouettes, thick rims, rounded safety housings and hazard stripes. Houses, pens and equipment share a small trim/material kit. Foreground is calm enough to read danger cues. No realistic injury imagery.

Palette primitives are ink `#182A36`, cream `#F3EDDC`, containment teal `#2BC7BC`, warning amber `#FFBF47`, danger coral `#E66C60`. Zone accents are turquoise, oceanblue, lavaorange, stormviolet and emberyellow. Teal always means safe route or containment, amber means attention, coral means immediate risk. Rare uses an extra double-chevron icon so storm-purple scenery cannot hide it.

Use SmoothPlastic/painted metal for devices, restrained rock/wood materials for environment, and Neon only in small emissive accents. Lighting has a neutral readable base with localized Zone grading. Preserve face and crate readability in shadow. Avoid global darkness as the main source of difficulty. Atmosphere transitions over connectors rather than switching the whole server's Lighting for each player.

Prop density guideline per20×20stud scenic cell: one primary silhouette, two medium props, up to four small accents. This is an art planning unit, not a target Part count. Keep central16stud travel strips free of collision clutter and12stud escape forks clear. Small debris should be noncolliding, non-touching and non-querying unless it supports a mechanic. Frame landmarks behind the route rather than burying arrows under billboards.

VFX prioritize a single visible warning per player. Limit high-opacity transparent layers, full-screen bloom and simultaneous particle emitters. Start with≤12 nearby active decorative emitters and≤150 visible particles on low quality, then profile. Reduce-motion mode removes shake and flash, retains a static warning ring and sound-independent timer. Audio mix separates ambient, music, warnings and UI. Warden alert overrides ambient at the player's location, not across the whole server.

## 4. Production stages and reusable assets

| Stage | Output | Exit gate |
|---|---|---|
| Art blockout | Anchors, lane widths, sightlines, gray materials, rough landmarks | Full route and 7-player chase test; timing within budgets |
| Production assets | Original modular buildings/trees/rocks/device kit,20creatures, fiveWarden treatments, icons | Asset rights manifest, collision/LOD review, recognizable silhouettes |
| Final visual polish | Lighting, color transitions, prop composition, animation/audio/VFX, signage | Real Studio screenshots and mobile performance capture; no placeholders in launch paths |

Create one containment kit, one base kit, one road/bridge kit, five biome prop sets and five creature-family rigs. Reuse geometry and atlases where visually appropriate, not an entire Zone recolored. Every Zone gets a distinct horizon shape, material contrast and route hazard. Decorative motion comes from windmills, water strips, lights and idles; it should not require physics on every prop.

Asset ownership manifest records creator, source, license, permitted uses, import date, assetId if uploaded, dependencies and review status. Strip or review executable content from third-party models. Reference exports remain outside distributable content. New licensed assets are optional production choices, never presumed cleared.

## 5. Streaming and performance

Roblox streaming can load/unload Workspace models. Client bindings must tolerate stream-out and reattachment. Use atomic models for small interactables whose children must arrive together; do not mark entire biome worlds Persistent. Server logical IDs and state outlive streamed visuals. Keep far-zone content in Workspace with appropriate streaming configuration rather than preloading it all from ReplicatedStorage. These choices follow [Roblox instance streaming documentation](https://create.roblox.com/docs/workspace/streaming); actual settings require device tests.

Initial acceptance budgets at7players/5Wardens/20regular+2eventcrates/56placedmodels:

- Lower-end physical mobile selected in P1-01: p95 frame time≤33.3ms during a10min route, no repeated>100ms stalls afterwarmup.
- Desktop target p95≤16.7ms on the recorded test machine.
- Gameplay script server frame time p95≤5ms and no unbounded pathfinding/task growth.
- Client memory goal≤700MB total and no upward trend>10% between steady minutes30 and120. Calibrate to actual device; absolute memory is a project target, not a Roblox guarantee.
- Join to control p95≤15s on the recorded connection; no full-world blocking asset preload.

Measure with device/model/OS, Studio or published staging build revision, graphics level, player count, network conditions and profiler evidence. Start budgets are not observed performance. Degrade particles/shadows/distant idles before reducing warning visibility.

## 6. Screenshot review protocol

After implementation, capture from fixed bookmarks for Hub overview, all seven bases, each Zone entry/landmark, both escapeforks, carry close-up, opener reveal and mobile HUD. Save screenshots with build SHA, PlaceId, coordinates, quality setting and date. Use actual Studio view port captures; concept diagrams never serve as production evidence.

Two teammates independently score silhouette/readability, composition, route clarity, material coherence, prop detail, character quality and UI fit from1–5. Release requires all≥4 and zero navigation/readability blocker. Review grayscale captures and low graphics too. Pair stills with30–60s route video so polished viewpoints cannot hide bad traversal.

## 7. UI design system

Use a containment field-terminal style: cream labels on ink panels, teal safe actions, amber Snatch, compact hazard-stripe edges and large species silhouettes. The player should remember the dual capture choices and the crate-status strip, not a wall of shop icons.

Three token layers translate directly to Luau tables in proposed `src/shared/UIDefinitions.luau`: primitive colors/spacing/type; semantic `Safe`, `Danger`, `Panel`, `Text`, `Muted`; component tokens for `CaptureAction`, `ItemCard`, `Toast` and `Modal`. This applies `ckm:design-system` and `frontend-design` to Roblox-native UI; no web UI framework is required.

| Token group | Proposed values / rules |
|---|---|
| Typography | Fredoka One for short Latin display headings if available, GothamMedium/Bold for body and numbers; tested Thai-capable fallback per locale, never force Latin font for Thai glyphs |
| Sizes | Body18px target, caption16, button20, heading28; use constraints rather than unlimited TextScaled |
| Spacing | 4/8/12/16/24/32px; cardradius12, panel16 |
| Touch | Action target≥48×48px with8px separation; reserve default thumbstick/jump areas |
| Contrast | Text≥4.5:1 against actual composited background; large text≥3:1; verify rendered token pairs |
| Motion | Button0.12s, panel0.2s, reveal≤2s skip; no screen shake bydefault |
| Focus | Explicit selected entry and directional navigation; visible focusring; Back closes one layer |

Native `ScreenGui`, `UIListLayout`, `UIGridLayout`, constraints and reusable modules suffice. Do not add React or a global UI state framework for this scope. Scale controls overall placement, offsets control padding. Bound `WaitForChild`, separate UI state from authoritative data, and localize string keys including error messages.

## 8. HUD and screen contracts

```text
┌ Coins / stored-income cue ───── Zone / next goal ───── Event icon ┐
│ Speed Power + actual speed preview                               │
│                                                                 │
│                       World remains visible                     │
│                                                                 │
│             Crate: Rare · Escaping · safe-exit arrow              │
│                                                                 │
│ thumbstick safe area         Stabilize | Snatch     jump safe area│
└ Inventory · Index · Upgrades               contextual action only┘
```

On mobile landscape, collapse stats to two short rows, put capture actions above the jump safe area, and use a bottom-sheet inventory with a two-column grid on narrow widths. At720×1280 portrait, use a full-height sheet and one primary action row; do not overlap topbar/notch or hide the world exit cue behind a modal. A desktop1280×720 uses centered max-width panels; neither resolution is proof of device support.

| Screen | Contents and actions | Empty / loading / error / success |
|---|---|---|
| HUD | Coins, stored income cue, Power, nextZone, carrying status, one goal | PendingData hides balances rather than showing falsezero; resync banner |
| Capture | Tier, two methods, holdtimer, odds link | Reserved, out of range, interrupted; success switches tocarry strip |
| Inventory | FilterZone/tier, sortincome,100cap, stored/placed/locked flags, view port icon | Empty points toZone1; paged loading; staleitem refresh |
| Disaster details | Name/tier/origin/rank/base+effective income, Place/Store/Lock/Sell availability | Unknowncontent shown as preserved unavailable item, never delete button |
| Crate/open | Banked3slots, origin/tier, odds, Open | Saving pending, received result receipt; replay skipped safely |
| Upgrade Pen | Current slots/incomelevel, next cost anddelta | InsufficientCoins reason, pending purchase disables duplicate button |
| Treadmill | Currentrunstate, gain/sec, level, upgrade price | Faceforward/step onto belt/paused; no E-to-gainlabel |
| Shop | Base/training upgrades and Trails navigation | Coin-only atlaunch; no fakeRobux checkout |
| Sell | Exactselected ID, name andvalue, irreversible confirm | Itemlocked/placed warning; success viareceipt |
| Fuse | Three inputs, resulting rank,fee, loss of aggregate income | Missingmaterial, wrong rank, pending/receipt result |
| Trails | Ownership,equip,training multiplier, cosmetic preview | Assetfailure fallback icon; purchase remains owned |
| Index | FiveZonetabs,four silhouettes each, foundcount,one-timebonus | Discoverypersistsaftersale; no claim before completion |
| Event | Zone,timer,eligibility,variant preview,active/delayed/ended | Timeouts never imply event cancel unless registry saysso |
| Notifications | ≤3stacked,5sordinaryduration; errors remain actionable | Merge repeated not enough coins; do nottoast every income tick |

All transactional buttons have Idle→Pending→Success/Error. Pending means acknowledgement outstanding, not automatically failed. A timeout offers status refresh using the same operationId. Do not invite a new charge as the only retry option. Save status is a small persistent indicator, never a modal on every autosave.

Use shape labels and captions for all danger sounds. Add reduced VFX, reduced motion and audio channel sliders. Preserve a visible return direction when menus close. Test localization at200% string length, touch-only, gamepad focus, notch/safeareas and stream-out. UI updates use state deltas, event-driven layout and≤2Hz earning display; no view port render camera per unseen inventory card.
