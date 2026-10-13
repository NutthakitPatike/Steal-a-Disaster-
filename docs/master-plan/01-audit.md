# Project audit and evidence register

Snapshot date 2026-10-13, approximately 14:15–14:24 Asia/Bangkok. Baseline `main` at `e4b5f421a946e21e0e962bb6e4e3d6bbb380d875`, initially clean. Remote URL is `https://github.com/NutthakitPatike/Steal-a-Disaster-`. Remote HEAD, current branch protection and invitations were not rechecked. Local source, on-disk Place and open Studio are separate evidence sets.

## Evidence register

| ID | Evidence collected | What it establishes |
|---|---|---|
| E01 | `git status --short`, `git branch --show-current`, `git rev-parse HEAD`, `git remote -v`, `rg --files` | Local baseline and eight Luau files |
| E02 | Complete read of all eight `src/**/*.luau`, `default.project.json` and tests | Actual source behavior, not runtime success |
| E03 | `node --test tests/prototype.static.test.cjs` | Six static assertions pass, zero fail |
| E04 | `python tests/test_static_place.py` | Both saved assets contain five Zones, seven fenced plots and 1,897 Parts |
| E05 | Python XML comparison of eight saved Place Source strings with src, normalized newlines and outer whitespace | Disk Place source matches src under that normalization |
| E06 | Direct MCP `list_roblox_studios`, `get_studio_state`, read-only `execute_luau` | One connected Studio, Edit mode, identity and current hierarchy below |
| E07 | Direct `screen_capture`, without camera arguments | Grey view port with small spawn-like object; does not prove finished map visibility |
| E08 | `get_console_output` | Historical initialization messages exist; no fresh test session or timestamps tying them to current tree |
| E09 | lnwjud `mcp_list`, then read-only `mcp_call` for `Roblox_Studio/list_roblox_studios` | Configured bridge listed disconnected; child call returned `INTERNAL_ERROR: Operation failed`, recoverable true, error_code INVALID_ARGUMENT |
| E10 | Read-only Python ElementTree of reference Place, instance paths, CFrame and size | Geometric observations in reference table below; no third-party scripts executed |
| E11 | `Get-Command node,python,stylua,selene,rojo,rokit,wally -ErrorAction SilentlyContinue` | Node/Python found; named Roblox CLI tools not found in PATH |

E03 and E04 were executed by read-only audit explorers in this session. No claims of gameplay, load, save, security or rendering performance follow from those checks.

## Current source behavior

| System | Status | Evidence and remaining work |
|---|---|---|
| Initialization | VERIFIED source / UNKNOWN current runtime | `Bootstrap.server.luau:3`, `Bootstrap.client.luau:3` print readiness only |
| Five-Zone world | PARTIAL | `PrototypeWorld.luau:64` adopts existing named map or creates simplified fallback; authored disk map and fallback differ |
| Crate spawning and rarity | PARTIAL | `TornadoTownPrototype.server.luau:119,189`; one available crate/Zone, two nodes, 85/15 Common/Rare, 7 s replacement after pickup |
| Stabilize/Snatch | PARTIAL | `:135,214`; 2 s prompt vs immediate; server does not independently time the hold |
| Carry/return | PARTIAL | `:94,166,394`; welded visual, Escaping→Secured, physical return; death/disconnect deletes carry |
| Warden AI | PARTIAL | `:386`; direct movement of noncolliding sphere to nearest carrier, no obstacle routing or patrol |
| Safe exit | PARTIAL | `:396`; root Z threshold alone accepts any X/Y; no bounded exit or traversal proof |
| Base assignment/open | PARTIAL | `:236,298`; seven slots, eighth player kicked, own-base and distance checks |
| Random reward/inventory | PARTIAL | `:250`; uniform selection within pool, inventory counts keyed by name, not unique item IDs |
| Income | MISSING target behavior | `:262` grants one-time 100/300 coins at opening. No passive accrual, placement or Collect |
| Save/load/recovery | MISSING | In-memory profiles only, removed on disconnect; no DataStore/session protocol |
| Physical treadmill | MISSING target behavior | `PrototypeWorld.luau:209`, prototype `:279`; E prompt +10, 1 s cooldown |
| Zone progression | PARTIAL | Speed threshold checks capture, not entry. Zero coin costs |
| Sell/fuse/upgrades/trails/theft | MISSING | No implementation in eight files |
| Index | PARTIAL | Name-discovery table/count exists; no complete index screen/reward persistence |
| HUD/mobile | PARTIAL | Fixed 310×142 panel and notices in `TornadoTownHUD.client.luau`; no production screens/mobile verification |
| Admin/events | MISSING | No authorization, messaging, lifecycle or audit implementation |
| Art | PARTIAL disk / MISSING in inspected live Workspace | Static first-party primitives exist on disk; not five production biomes or 20 creature models |

Runtime guard in prototype `:10` and HUD `:6` exits outside Studio. Publishing existing scripts would not make this a working live game. Do not remove that guard before staging data isolation and acceptance work.

Positive source safeguards include server-owned reward rolls, one carried item, crate claim without yielding, consume-before-grant in a session, opener ownership checks, and server training cooldown. These do not provide durable exactly-once inventory. Position validation still depends on client-replicated character movement. Capture hold timing, movement history, runtime errors, concurrency and disconnect races require tests.

## Open Studio is not the disk Place

Direct MCP identified Studio `13edfad7-88fa-4667-a579-dc3789231be3`, name **Steal A Disaster!**, PlaceId `89467184271147`, GameId `10770595743`. State was **Edit**. StreamingEnabled was true. The complete script inventory returned four **ModuleScripts**:

| Path | Source bytes returned |
|---|---:|
| ReplicatedStorage.Shared.Config | 175 |
| ReplicatedStorage.Shared.PrototypeConfig | 1,759 |
| ServerScriptService.Server.ZoneMap | 9,672 |
| ServerScriptService.Server.PrototypeWorld | 7,628 |

The four executable server/client scripts were not present in that snapshot. Workspace children returned Terrain, SpawnLocation and Camera. A later bounded count returned two Workspace BaseParts. The initial all-DataModel count of 15 includes parts outside Workspace and must not be described as map size. The scene may change independently while open. This audit does **not** establish who changed it, whether anything was deleted, or whether a previous import succeeded.

Console contained repeated server/client ready and “Five-zone Studio-only original map initialized (no DataStore)” messages. They corroborate earlier initialization activity only. No current Play session was started, and no game tests were run in this planning task. Current save status, unsaved edits and the relation of this cloud Place to the saved local map remain UNKNOWN. P1-01 resolves that before any mutation.

The direct Codex bridge worked. The requested ChatGPT/lnwjud route did not complete its child discovery call. Do not represent one as proof of the other. Recovery is in [the execution plan](06-implementation.md).

## Reference measurements

The original `reference_sources/Place_107778070777162.rbxlx` now exists locally and is 130,061,288 bytes. Earlier README/MAP_ASSET statements that the original is inaccessible are stale for this session. All ten exports are present. They remain research-only; redistribution rights are UNKNOWN.

Read `Workspace/Plots` and `Workspace/World/Areas/GuardAreas`. There are seven plot models and thirteen GuardAreas. The reference progresses along **+X**, around Z=-364. The first five area `Bounds` are:

| Area | X range, approximately | Length X | Width Z | Nest markers |
|---|---|---:|---:|---:|
| Forest | 553–647 | 93.38 | 151.36 | 5 |
| Lake | 653–792 | 139.57 | 150.21 | 5 |
| Desert | 799–1003 | 204.66 | 151.09 | 5 |
| Jungle | 1010–1240 | 229.99 | 150.27 | 5 |
| Snow | 1246–1564 | 318.21 | 150.21 | 5 |

These are marker volumes, not verified navigation bounds. Seven `CenterPoint` X/Z values are `(444.74,-363.94)`, `(444.74,-282.94)`, `(444.74,-201.94)`, `(444.74,-443.59)`, `(445.66,-523.04)`, `(522.76,-203.42)`, `(521.89,-524.62)`. Five plots line one side, with two toward the progression side at the ends. They are not seven plots in a straight row.

`EggCarryBounds/SafeZone` is centered `(457.0,67.08,-364.21)`, size `(190.11,1,438.73)`; its X edge is approximately 552.06. Forest nests lie 38.4–52.8 X-studs beyond the separator; Snow nests 933.6–948.0. `ClosestExitPoint` markers are nearby but their behavior is UNKNOWN. Do not infer that a chase ends there.

Our saved map progresses toward **−Z**, has seven bases at X=`-123,-82,-41,0,41,82,123`, Z=0, each pad 36×44, and 225-stud Zone spacing. Its primitive bounding box is 310×50.5×1,333 studs. Zone 1 spawn→safe-exit straight-line distance is 163.3/178.9 studs, and spawn→central opener is 309.5/325.3. Zone 5 spawn→central opener is 1,208.4/1,224.3. These are lower bounds, not timed journeys.

Method used Python XML traversal, `CFrame` translation/rotation and `size` or `Size`. Rotated half-extent per axis is `sum(abs(R[i,j])*size[j]/2)`; aggregate minimum/maximum over relevant parts. Terrain, SpawnLocation and Baseplate were excluded from authored-map extents. Whole-reference bounds are misleading because remote interiors exist far away and high above the primary world.

Design inference: shorten first-success travel, preserve connected progression, and measure return duration before art production. The new world proposal retains our horizontal seven-base interpretation deliberately rather than claiming exact reference parity. No reference source, mesh, audio or texture is copied into the plan's implementation.

## Actual verification and limits

| Check | Result |
|---|---|
| Node static tests | PASS 6/6 |
| Python static Place/model tests | PASS both files |
| Disk Place versus eight source files | MATCH under newline/outer-whitespace normalization |
| Live Studio discovery/read-only hierarchy | VERIFIED via direct bridge |
| lnwjud child discovery | FAILED with internal tool error; cause UNKNOWN |
| StyLua/Selene | NOT RUN; not in PATH |
| Rojo build | NOT RUN; excluded by request |
| Studio solo, multiplayer, mobile, save/load, perf | NOT RUN; no runtime acceptance claims |
| Current GitHub branch rules/collaborator access | UNKNOWN; historical docs are not a fresh check |
| Reference rights and imported asset provenance | UNKNOWN beyond repository research-only restriction |

## Planning defects to track

P1-01 owns Studio/source drift and stale document routing. P1-04 owns hold validation and bounded safe exits. P1-03/P1-06 own durable identity and recovery. P1-07 owns the missing passive-income loop. P2-01 owns the treadmill mismatch. These are planned task records, not GitHub Issues created during this request.

## Planning review and verification

The source and reference explorations completed, followed by a read-only synthesis. A separate design-review agent could not run because its service returned a usage-limit error. Its review is NOT COMPLETED and is not counted as an independent approval. The author then checked the specification, dependencies and failure protocols directly. Human approval and runtime gates remain open.

The self-review added a durable discovery pointer for transferred-item Sell/Fuse recovery, bounded mutex ownership during theft, explicit physical treadmill control/cleanup, and a Warden response to nearby Stabilize holders. These close design gaps; they are not implemented fixes.

An inline Python documentation check was run with UTF-8 stdout. It verified all eight Markdown files, local links, closed code fences, twenty GDD cards with fifteen numbered fields each, thirty unique task IDs, required task fields, existing/ordered dependencies and effort arithmetic. It returned zero errors. Effort sums are P1 31–50, P2 31–50, P3 44–71, P4 17–28, total123–199 person-days. These checks establish document structure, not gameplay correctness.

Planning work created only `docs/master-plan/`. No tracked source, config, saved Place or model export was changed. No build, Play session, GitHub mutation, commit or publish was performed. Final Git/whitespace checks are recorded in the delivery message.
