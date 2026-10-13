# QA, security, risk and launch readiness

This is a future verification plan. No runtime test below is marked passed by the planning audit. Existing static results are recorded separately in [01-audit.md](01-audit.md). Unit tests alone cannot close a gameplay task or Phase.

## 1. Test environments and evidence

Use local mocks for pure math/state/fault exploration, Studio solo for interaction debugging, Studio local server with2and7clients for contention, and a separately approved private staging experience for real DataStore/cross-server behavior. Never enable Studio writes to production keys as a test shortcut. Two actual staging server jobs are required for MessagingService/session handoff evidence; two clients in one server do not test cross-server delivery.

Each result records test ID, UTC+Bangkok date/time, Git revision, PlaceId/GameId/jobId, data namespace, device/OS, graphics level, network simulation, player count, expected/actual result, console errors, state/ledger snapshots and screenshot/video/profiler path. Logs redact session tokens and avoid full personal profile dumps.

Define severity0 as exploitable currency/item creation or confirmed data loss, severity1 as core-loop block/crash/ownership break, severity2 as material usability/performance regression and severity3 as cosmetic defect. Gates require zero open severity0/1, and explicit owner/acceptance for any deferred severity2. A blocked test is NOT RUN, never PASS.

## 2. Scenario matrix

| ID / owner | Setup and stimulus | Required result / evidence | Task gate |
|---|---|---|---|
| Q01 Head | Fresh player, Zone1, touch and desktop, ordinary odds; capture→escape→walk home→open→place→collect | Full video plus server receipt sequence; no skipped return; same durable inventory after rejoin | P1-08 |
| Q02 Dev2 | Seven joins same tick, eighth join, ownerleave/rejoin, character already present | Seven distinct owners; no base overwrite; fullserver handling clear; death hooks apply to existing character | P1-01/P1-08 |
| Q03 Dev2 | Two clients claim samecrate; trigger Stabilize in0.1s; hold fromoutside10studs or behind wall | One winner; short/out-of-range hold rejected; no stuck reservation beyond3s | P1-04 |
| Q04 Head | Bait Warden behind obstacle, enter return lane, switch targets, blockpath6s | No through wall/safe-lane catch; target hysteresis; recovery/no path request storm; video+state log | P1-05 |
| Q05 Dev2 | Die/disconnect before capture, duringhold/chase, before/after secure commit, banking, opening, animation | Unsecured loss followsrule; committed crate recovers atsafe-exit; oneitem onopen; no relog home delivery | P1-06 |
| Q06 Dev2 | Replay Open/Collect/Sell/Fuse/Purchase100times, including newrequest IDs against consumed targets | No extra item/coins; exact conservation; stale/repeated targets reject or same receipt | P1-03/P1-07/P2-03 |
| Q07 Dev2 | DataStoremock throws/throttles/commitsbutlosesACK; lease expires; two serverloads; save onshutdown | No default overwrite, no stale writer; acknowledged durability preserved; pending UI truthful | P1-03/P1-08 |
| Q08 Dev3 | Inventory100 incl reserved crates; sameitem2slots; ratechange atcap; unknown species definition | No capacity overrun, no duplicate placement; balance preserved; unknown item quarantined | P1-07 |
| Q09 Dev2 | Stand onbelt5min, walkoff, jump/sit, fakeRunIntent/gain; packetdrop; run60s on all input methods | Stationaryno-intent0gain; outside/air0gain; gain bounded; cutoff≤0.5s; no retrospective lag grant | P2-01 |
| Q10 Dev2 | Insufficientcoins, stalequote, skippedzone, hidden path gate bypass, trail stacking | Atomic/no partial purchase; prerequisites upheld; one equipped multiplier; data persists | P2-02 |
| Q11 Dev3 | Fuse sameID repeated, rank3, unequalrank, placed/locked/variant inputs; concurrent sale | Rejection changes nothing; valid3→1 exactfee; no arbitrage; understandable confirmation | P2-03 |
| Q12 Dev2 | Two thieves, protected slot, 3s channel interrupt, reclaim through wall, owner/thief disconnect, deposit timeout | Only eligible items; LOS reclaim;45s timeout; one winner; precommit cancel vs committed recovery correct | P2-06 |
| Q13 Dev2 | Kill at every transfer write boundary; restart eachplayer on anotherjob; sell/fuse transferred items; cancel/depositrace | Canonicalowner/tombstone andprofiles converge; no usable duplication; no deadlock; pending state has repairpath | P2-05/P2-06 |
| Q14 Dev3 | Physical lower-end mobile and desktop, gamepad,720×1280/1280×720, notch,200%text, audiooff/reduced motion | Allcriticalactions visible;≥48px touch; danger readable without sound/color; no clipping | P3-07 |
| Q15 Dev2 | Simulate150/300ms round-trip latency and2/5%loss where supported; otherwise record actual tested conditions | No duplicate input, spurious permanent ban, lostreceipt; staleintent safely pauses; measurable response | P3-08 |
| Q16 Dev2 | Sevenplayers,5Wardens,20regular+2eventcrates,56placedmodels,100inventory perplayer;10minroute | p95device/server budgets, join time and payload metrics recorded; same workload before/afterfix | P3-08 |
| Q17 Dev2 | Two-hour soak,100join/leavecycles, repeated stream out/respawn andUIopen/close; low memory conditions | No uncapped listeners/tasks/instances; memory plateau; no lost logical carry when visual stream out | P3-08 |
| Q18 Head | Two stagingjobs; admintargetsZone2; dropnotify, duplicate20times, reorderrev, start late job, restart | Samedescriptor onhealthyjobswithin30sgoal, distinct local crates, no expired wave backfill | P4-02 |
| Q19 Dev2 | Fakeadminrole, arbitrary count/tier, simultaneous admins, audit failure, cancel midwave, service outage | Unauthorizedrequest changes nothing; caps/cooldown durable; failclosed; earneditems retained | P4-04 |
| Q20 Head | Eventclaim/rejoin/serverhop and10-claimcap; content update/rollback during event; weekly rehearsal | No extra grants; unknown build skips incompatible event; recovery/audit records complete | P4-04/P4-05 |

For fault tests, enumerate a crash immediately before and immediately after each durable write and before each client ACK. Store the operation ID and assert end-state conservation, not merely that an error was caught. Multiple successful unit runs do not substitute for the two-server staging scenarios.

## 3. Phase quality gates

| Gate | Evidence required | Blocking failures |
|---|---|---|
| P1 | Q01–Q08, static/lint when installed, source/Studio parity, full physical loop with persisted item and income | Missing save/recovery, no placement/income, initialization-only proof, ambiguous ownership |
| P2 | Q09–Q13 plus P1 regressions, exact sell/fuse/upgrade math, observed progression report | E-prompt training, unsafe transfer, duplicate receipts, coin exploit, no counterplay |
| P3 | Q14–Q17, fivebiomes/7bases/20species, original rights, screenshots≥4/5 rubric | Greybox areas, missing launchZone, poor mobile input, perf or streaming blockers |
| P4 | Q18–Q20 plus critical regression, durable admin registry/audit, release/rollback rehearsal | Clientauthority, best-effortbroadcast-only design, no catch-up, unbounded giveaways |

A gate records the exact revision, approved changes and known minor defects. Any later schema, authority, path or loot change reruns affected gates. Do not freeze a “passed” label while changing the implementation underneath it.

## 4. Security checklist

- Validate client arguments for type/size/state/ownership/distance/LOS/time/cooldown. Check finite numbers and valid UTF-8 before persistence. Prices and results come from server definitions.
- Do not rely on client prompt duration, character velocity, MoveDirection or animation as sole evidence. Movement history and bounded earning reduce risk; classic character replication cannot prove every physical input honest.
- Serialize conflicting profile operations. All irreversible mutation paths use receipts and idempotent reconciliation, including transfers and eventclaims.
- Keep raw admin code execution and arbitrary grants out of the launch admin UI. Separate EventOperator permission from Release/Publish authority.
- Rate-limit globally and peraction. Log repeated suspicious patterns; avoid permanent punishment from one malformed packet or lag event.
- Scan asset scripts and document licenses. Do not execute or redistribute decompiled reference scripts.
- Test access with each contributor's own account. Main requires reviewed PR workflow; actual enforced branch rules and invitations remain setup verification tasks.
- Separate staging/live data namespaces and place ownership. Approve migrations/releases independently of planning approval.

## 5. Risk register

Likelihood/impact are planning judgments, not measured probabilities.

| ID | Risk / likelihood / impact | Trigger / owner | Mitigation and contingency |
|---|---|---|---|
| R01 | Source/Studio drift, high/high | Source count/hash mismatch; Head | P1-01 snapshot/reconcile; one writer; stop mutation on unexpected drift |
| R02 | Data loss, medium/critical | Loaderror, stalelease, timeout; Dev2 | Fenced sessions, no default overwrite, durable receipts, mock+staging faulttests; freeze economy onlease loss |
| R03 | Cross-profile duplication, high/critical | Crash duringtheft/fuse; Dev2 | Canonicaltransfer records and reconciliation; hard P2gate, never ship best-effort transfer |
| R04 | Art bottleneck, high/high | Species/Zone assets miss acceptance; Dev3/Head | Fivefamilyrigs/modularkit,20species cap, weekly asset review; extenddate or obtain production help rather than silentlydropZones |
| R05 | Overengineering, medium/high | Frameworkwork beforefullLoop; Dev2 | Ordinary modules, directcalls, one persistence adapter; measure before adding cache/eventbus |
| R06 | Scope creep, high/high | Boss/trading/Zone6 requested midlaunch; Head | Futurebacklog and explicit cost/dependency change; preserve locked features |
| R07 | Unbalanced progression/inflation, high/high | Unlocktime tails ormint/sinkratio outside baseline; Head | Seededmodel+cohorttests; versioned caps/rates; cosmetic-only event bonus |
| R08 | Warden frustration, medium/high | Firstattempt failures/no clearroute; Head | ShortZone1, warnings, LOS,2routes; revise encounter before grants/power upsell |
| R09 | Mobile load/performance, high/high | Frame/memory gates fail; Dev2 | Profile worstcase, distanceLOD, particles budget, stream-safeUI; reduce decoration cost not warning clarity |
| R10 | Global event delivery gaps, medium/high | Messaging/registry unavailable; Dev2 | Durable registry, bootread+poll, expiry, retries, lag visibility; no false guarantee during outage |
| R11 | Reference/license dependency, medium/high | Need unlicensed meshes/scripts; Head | Originalart/code, rights manifest, research-onlyexports; replace asset before launch |
| R12 | Excessive time to launch, high/high | Throughput below plan by2sprints; Head | Re-estimate critical path, cap content variants, fixshared bottleneck; consider closed beta while keeping public launch scope |
| R13 | Theft grief/disconnect evasion, medium/high | Repeatedvictims orragequit; Head | Protectedstarter, unlock thresholds, reclaim/shields,90svictimgrace; measure frequency before punitive rules |
| R14 | Unsafe admin action, medium/critical | Arbitrarygrant/capbypass; Head | Roles/allowlist, templates/cooldown, audit before broadcast, kill-switch, separate publish permission |
| R15 | Skills/tools/access differ, high/medium | Teammate cannot runworkflow; Head | Per-machine access/tool smoke test; task contracts independent ofprivateAIcontext; documentNOT RUN honestly |
| R16 | Long return feels empty, high/medium | Zone5return exceeds45starget; Head | Testroutebudget beforeart; continuous physical return lane and bounded boost; shortenpath without auto teleport |

## 6. Future backlog with reasons

| Item | When to reconsider | Why excluded from launch |
|---|---|---|
| Frozen Catastrophe / Apocalypse Zone | Stable five-Zone retention and artcapacity | Locked post-launch expansion; extends existing route |
| Boss fights | Separate concept/cost review and explicit Headapproval | New combat/AI/animation scope not needed for collection loop |
| Disaster synergy | Base-management behavior showsdemand | Extra combos/balance/UI outside initial value proof |
| Secret rarity roster | Atleast2finishedSecret species and economytest | Avoid false multi-outcome pool and content bloat; event variant delivers special crate now |
| Trading | Ownershipledger proven and fraud/design review | Large extra cross-player transaction/fraud surface |
| Offline income | Data/economy baseline stable | Inflation and time-manipulation complexity; onlinecore first |
| Rebirth and endless stats | Existing progression exhausted by observed players | Unnecessary reset/pacing layer before first retention data |
| Paid random crates/luck | Explicit product decision + current platform policy review | Not required byrequest; adds purchase/odds/regional compliance work |
| Advanced Warden variants | Fair sharedAI and first five hazards accepted | Preserveupdatableframework withoutfivebespokeAI systems |
| Custom base building and pet care | Separate scope approval | New interaction/economy systems, not needed forUpgrade Pen |

None of these exclusions removes a locked P1–P4 system. Index, Sell, Fuse, Trails, Theft, 7bases, 5Zones and Global Admin Abuse remain required for public launch.

## 7. Launch readiness checklist

All boxes intentionally remain unchecked. Approval of the plan is not approval of release.

- [ ] Head approves D01–D08 or records reviewed alternatives with updated dependent contracts.
- [ ] Exact release Git revision, PlaceId/GameId, source/model manifest and saved rollback snapshot exist.
- [ ] P1–P4 gates each contain actual reviewed evidence, including gameplay, device and fault tests.
- [ ] Five launch Zones are connected and finished; seven bases and all required service stations are usable.
- [ ] Twenty species, all loot pools, icons, animations and rights records are complete; no missing catalog IDs.
- [ ] Physical carrying/return works on mobile; no automatic crate delivery, and safe-recovery still requires return.
- [ ] Physical treadmill passes stationary/air/outside/fake-input tests; upgrades/Trails gaincaps proven.
- [ ] Inventory, placement, income, collect, sell, fuse, Index and unlocks pass exact transaction tests.
- [ ] Two-server session/rejoin/transfer/failure tests prove no duplicated usable items or acknowledged data loss.
- [ ] Global events use serverauth, durable registry, localinstances, dedupe, catch-up, caps and auditlog.
- [ ] Event kill-switch/expiry/cancellation preserves already earned items and prevents oldwave backfill.
- [ ] Actual lower-end device and7player load meet approved budgets; profiler/captures are attached.
- [ ] Onboarding and progression timings are observed and problems acted on; no balancePASS inferred from formulas.
- [ ] Errors/loading/saving/retry messages are accurate; text localization and accessibility checks pass.
- [ ] No severity0/1 defects remain; any deferredseverity2 has owner, rationale and monitoring.
- [ ] Each teammate has verified scoped access, reviewedPR workflow and staging rights; shared credentials absent.
- [ ] Asset licenses and executable imports reviewed; research exports excluded from shipping assets.
- [ ] Current Roblox publishing/content-maturity/metadata requirements checked from official sources atrelease time; plan makes no eligibility promise.
- [ ] Production/staging data isolation, schema rollback, pending transfer recovery and backups rehearsed.
- [ ] Launch telemetry, alerts, on-call owner and rollback decision threshold documented.
- [ ] Head explicitly approves publishing this exact release candidate; no agent infers approval fromplan acceptance.

## 8. Release and early monitoring

Deploy only through a Head-approved release operation. Start with the smallest audience the team can support and inspect error/data-integrity dashboards before broader promotion. A detected currency/item duplication or acknowledged data loss stops new high-value transactions/events and triggers incident review; do not delete playerdata as a quickfix. Prefer forward repair with receipts and a tested schema-compatible rollback.

Review first-session completion and repeated visits as measured cohorts. Ten usability players identify obvious problems but do not prove statistical retention uplift. Define larger experiment size after baseline rate and minimum meaningful effect are known. Weekly updates can be a fixed event template, visual variant or quality improvement; a newZone everyweek is not promised.

## 9. Planning deliverable verification

The master package must have all15requested deliverables,20system cards with15fields each,30task IDs with complete task fields, resolvable dependencies and arithmetic-consistent effort totals. Cross-check all fixed constraints against the prompt. Review source/Studio evidence labels so static checks never become runtime claims. Record documentation/link/check results in the planning verification note when finished.
