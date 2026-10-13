# Game concept and complete GDD

All mechanics below are PROPOSED implementation rules unless the master index labels them LOCKED. Values are tunable only through a reviewed config revision. No system is certified by this document.

## Concept alternatives and selected direction

| Approach | Player fantasy and identity | Strength | Weakness and production difficulty | Decision |
|---|---|---|---|---|
| A. Disaster Containment Crew | Playful salvage team carries living storms home in warning-striped devices | Strong readable contrast between danger outside and lively collection at home; reuses five families | Needs good carry feedback and character silhouettes; medium production cost | **Choose A**, extends confirmed Containment direction |
| B. Storm Smugglers | Mischievous couriers sneak unstable cargo past industrial Wardens | Strong theft theme and tense sound design | Stealth expectations add AI/visibility complexity; moral tone and dark palette reduce mobile clarity; high cost | Keep courier swagger, omit stealth simulation |
| C. Miniature Disaster Sanctuary | Rescue tiny disasters and create a lively habitat | Broad approachable art, strong collection affection | Sanctuary suggests caretaking and building systems outside locked loop; theft feels inconsistent; medium-high content cost | Keep expressive idles, omit care meters and habitat simulation |

A retains the locked gameplay. B and C are treatments of that loop, not proposals to replace carrying, Wardens or stealing. Compare three storyboard beats before implementation approval; do not build competing games.

The world is a chain of abandoned containment districts. Wardens protect dangerous salvage. Crates safely transport living disasters that power home containment pens. The player fantasy is 'I can bring something dangerous home because I learned the route.' Lore appears in signs and species descriptions, not long cutscenes. Avoid realistic disaster casualties.

Gameplay pillars are readable risk, physical earned return, expressive collection, visible progression and fair multiplayer counterplay. Emotional rhythm is anticipation → decision → pursuit → relief → reveal → pride. Short goals take one run or one upgrade. Mid goals unlock a Zone and improve placed income. Long goals complete all five Index sections and curate a rare ranked collection.

Originality comes from warning-device crates, paired capture methods with equal odds, biome-specific escape reads and living-disaster characters. This is a design claim, not an unsupported claim that no competitor has similar mechanics.

## Global rules

- Authority belongs to server state. Client sends intent and renders feedback.
- Every durable mutation has actor, operationId, expected revision, validated target IDs and a receipt. Never use presentation animation as transaction completion.
- One player carries one PvE crate or one stolen Disaster. No inventory transfer or remote delivery bypasses physical return.
- New features introduced by this plan are explicitly scoped. Return recovery/receipt protocol, protected starter slot and telemetry are necessary P1/P2 safeguards. Cosmetic event variants and deterministic fusion are low-cost P2/P4 proposals. Bosses, synergy and additional zones remain future work.
- Phase order stays P1–P4. P1 uses a training-free Zone 1 first-run test because treadmill progression belongs to P2; the complete launch loop includes training.
- A session is Ready only after profile ownership, reconciliation and base assignment. A failed save never becomes a success toast.

## Systems and acceptance contracts

Each card includes all fifteen requested design fields. Exact data and transaction contracts are in [architecture](05-architecture.md), values in [economy](03-content-economy.md), visual requirements in [world/UI](04-world-ui.md), and task ownership in [implementation](06-implementation.md).

## G01. Session readiness and base assignment

Phase P1.

| Field | Specification |
|---|---|
| 1. Purpose | ให้ผู้เล่นเริ่มอย่างปลอดภัยและมีฐานเดียว |
| 2. Player experience | โหลดข้อมูลแล้วเห็นฐานและเป้าหมายแรก ไม่เล่นด้วยข้อมูล default เมื่อ load ล้มเหลว |
| 3. Gameplay flow | Join → acquire profile session → reconcile → assign free base → spawn → Ready |
| 4. Detailed mechanics | 7 bases, capacity 7; เลือก slot ว่างต่ำสุด ฐานเป็น server-local ไม่บันทึกหมายเลข slot ข้าม server |
| 5. Rules & constraints | Profile Ready ก่อนเปลี่ยนเศรษฐกิจ; 1 base/UserId; ไม่มีฐานซ้ำ |
| 6. States / transitions | Loading → Reconciling → Ready → Closing; failure → ReadOnly/Exit |
| 7. Interactions | G09 persistence, G06 inventory, G19 onboarding |
| 8. Server responsibilities | จับ session lease, จอง plot แบบไม่ yield ใน registry, โหลด contents ตาม slot mapping, cleanup |
| 9. Client responsibilities | แสดง loading/retry และฐานตนเอง; ไม่กำหนด owner |
| 10. Edge cases | ผู้เล่นคนที่ 8, rejoin สอง server, character มีอยู่ก่อน bind, owner ออกระหว่าง thief |
| 11. Failure handling | ไม่ overwrite profile ด้วย default; เต็มให้ข้อความ server full; ตั้ง readiness timeout 30 s แล้วให้ retry ออกจาก session อย่างปลอดภัย |
| 12. Exploit risks | spoof plotId/UserId, session hijack, default-save overwrite |
| 13. User feedback / UI | กำลังโหลดฐาน; ยังไม่พร้อม; data unavailable; retry ไม่สร้าง profile ใหม่ |
| 14. Testing requirements | 7 concurrent joins, 8th join, delayed load, existing-character death hook |
| 15. Acceptance criteria | 7 users ได้ 7 owners ต่างกัน; load error ไม่มี grant/spend/save default; teardown คืน slot ครั้งเดียว |

## G02. Zone crate spawning and rarity

Phase P1.

| Field | Specification |
|---|---|
| 1. Purpose | ให้ทุกโซนมีของให้เสี่ยงเลือก |
| 2. Player experience | เห็น tier ก่อนตัดสินใจ ไม่ต้องสุ่มซื้อ |
| 3. Gameplay flow | Valid zone nodes → choose tier → spawn → available → claimed/expired → replacement |
| 4. Detailed mechanics | 4 regular crates/zone จากอย่างน้อย 5 nodes; replacement 8 s; available TTL 90 s; expiry เลื่อนถ้ามี reservation; tier weights และ pool version เก็บกับ crate |
| 5. Rules & constraints | ไม่มี pooled rarity ว่าง; ห้ามเปลี่ยน tier ระหว่าง reservation; cap normal 20 ทั้งโลก, event แยก cap |
| 6. States / transitions | Scheduled → Available → Reserved → Carried; Available→Expired; cancel Reserved→Available |
| 7. Interactions | G03 capture, G04 carry, G17 events, content tables |
| 8. Server responsibilities | เลือก node ที่เดินถึงได้, generate crateId, roll tier, enforce cap/TTL, replication |
| 9. Client responsibilities | แสดง silhouette tier/ชื่อ/expiry เฉพาะช่วงท้าย; ไม่ส่งผล RNG |
| 10. Edge cases | ทุก node ถูกบัง, restart, simultaneous replacement, player ยืนทับ |
| 11. Failure handling | ไม่ spawn ใน collision; retry bounded 5 s และ log node; ไม่ยก cap เพื่อแก้ปัญหา |
| 12. Exploit risks | client ระบุ tier/node, respawn spam, duplicate IDs |
| 13. User feedback / UI | ชื่อ Zone + Common/Rare; ไม่มีการบอก hidden species ล่วงหน้า |
| 14. Testing requirements | table weight sums, 20-cap, blocked nodes, expiry vs reserve same frame |
| 15. Acceptance criteria | ทุก crate มี unique ID + valid nonempty pool; spawn ไม่ทับทางหลัก; ไม่มี double claim |

## G03. Stabilize and Snatch

Phase P1.

| Field | Specification |
|---|---|
| 1. Purpose | สร้างทางเลือกเวลาเทียบความเสี่ยง โดยไม่เปลี่ยนรางวัล |
| 2. Player experience | Stabilize มีแถบ hold; Snatch รับทันทีแต่ส่งเสียงล่อ Warden เร็ว |
| 3. Gameplay flow | Approach → inspect odds → begin → server reserve → hold/instant → carry |
| 4. Detailed mechanics | ระยะ 10 studs และ LOS; Stabilize ต่อเนื่อง 2.0 s, server samples 10 Hz; reserve timeout 3 s; Snatch commit ทันทีเมื่อ validate; Stabilize Warden alert delay 2.5 s, Snatch 0.75 s |
| 5. Rules & constraints | method enum เท่านั้น; moving >2 studs จากจุดเริ่ม, dead, carry occupied หรือออก LOS ยกเลิก; max 1 reservation/player |
| 6. States / transitions | Idle → Holding → Complete; Holding→Cancelled; Snatch Idle→Complete |
| 7. Interactions | G02 locks, G05 Warden, G04 carry |
| 8. Server responsibilities | server monotonic elapsed time และ repeated distance checks; claim actor ก่อน yield; rollback reservation เมื่อ commit ไม่ได้ |
| 9. Client responsibilities | hold affordance, touch two actions, cancel on release; render progress from timestamps |
| 10. Edge cases | สองคนเริ่มพร้อมกัน, hold release packet หาย, network delay, expiry ระหว่าง hold |
| 11. Failure handling | server ends invalid hold; disconnect frees reservation; failed visual does not consume logical claim silently |
| 12. Exploit risks | client HoldDuration override, instant trigger, stale crateId, macro spam |
| 13. User feedback / UI | Stabilize '2s / quieter'; Snatch 'instant / early chase'; Reserved by another player |
| 14. Testing requirements | spoof prompt Triggered, hold0.1s, two players same tick, release/repress |
| 15. Acceptance criteria | Stabilize ไม่สำเร็จก่อน 2s ตาม server; 1 crate มีผู้ชนะ 1 คน; same tier yields same pool for both methods |

## G04. Carry, escape and physical return

Phase P1.

| Field | Specification |
|---|---|
| 1. Purpose | ทำให้การขนของเป็นทักษะหลักและไม่ใช้ reconnect ข้ามทางกลับ |
| 2. Player experience | ถือได้หนึ่งกล่อง เห็น Warden alert และลูกศรทางกลับ |
| 3. Gameplay flow | Captured → Escaping → cross bounded own-zone exit → commit ReturnPending → walk return lane → deposit at own base |
| 4. Detailed mechanics | กล่อง cosmetic weld massless/noncolliding; cap movement จาก economy spec; Exit volume กว้าง 12 ลึก 8 สูง 12 พร้อมตรวจเส้นทาง; การข้ามต้องมาจากด้าน Zone; return speed boost ใช้เฉพาะ painted lane |
| 5. Rules & constraints | ห้าม training/theft/second pickup ขณะถือ; other Zone Wardens ไม่ไล่ ReturnPending; ไม่เปิดก่อนถึง own base |
| 6. States / transitions | Escaping → ReturnCommitPending → ReturnPending → BankCommitPending → Banked; Escaping→Lost; ReturnPending→RecoveryPending |
| 7. Interactions | G03, G05, G07 opening, G09 saves |
| 8. Server responsibilities | authoritative carry record และ movement history; save safe-return checkpoint ก่อนบอก Secured; bank only own opener within8 studs |
| 9. Client responsibilities | carry pose, path arrows, progress, reconnect UI; ไม่ย้ายตัวละครเพื่อส่งมอบรางวัล |
| 10. Edge cases | death/disconnect ก่อนและหลัง exit, fall through void, stream-out, character replacement |
| 11. Failure handling | ก่อน durable exit สูญเสียของพร้อมคำอธิบาย; หลัง commit กู้ที่ safe-exit marker ของโซนเดิมและยังต้องเดินบ้าน; save fail ให้รอ safe staging area ไม่ grant |
| 12. Exploit risks | teleport/speedhack→exit, fake safe flag, open remote from afar |
| 13. User feedback / UI | Escaping / Securing / Bring home / Saved crate waiting at return checkpoint |
| 14. Testing requirements | death/disconnect ทุก transition, off-axis crossing, mobile route, attempted reconnect shortcut |
| 15. Acceptance criteria | ไม่มี reward ก่อน deposit; committed secured crate ไม่สูญ/ซ้ำ; กู้แล้วไม่ปรากฏที่บ้านอัตโนมัติ |

## G05. Warden AI and hazards

Phase P1 core, P3 theme.

| Field | Specification |
|---|---|
| 1. Purpose | ให้การหนีอ่านออกและฝึกชนะได้ |
| 2. Player experience | มี warning ชัด ได้เปรียบจาก route choice มากกว่ากดปุ่มเร็ว |
| 3. Gameplay flow | Patrol → Alert → Chase → Search/Return → Patrol |
| 4. Detailed mechanics | 1 Warden/zone; target nearest eligible at acquisition then hold target ≥2s; switch only invalid target or ≥30% closer after hold; chase leash to own zone; catch distance4 studs + LOS; warning ring; catch loses unsecured crate ไม่หัก owned collection |
| 5. Rules & constraints | ไม่ไล่เข้า return lane/hub; warning อย่างน้อย 0.75s; hazards ไม่ chain-stun; no unavoidable kill corridor |
| 6. States / transitions | Patrol, Alert, Chase, Search(3s), Return, Recover |
| 7. Interactions | G03 alert method, G04 capture loss, G20 zone hazards |
| 8. Server responsibilities | server decisions 5Hz, pathfinding max1 request/s/NPC, direct LOS path when clear, bounded stuck recovery |
| 9. Client responsibilities | interpolate rig, animation/audio/VFX; no target or catch authority |
| 10. Edge cases | two carriers, target death, blocked path, cliff, offmesh, seven players baiting |
| 11. Failure handling | stuck2s repath; stuck6s return home while no catch; recovery teleport only NPC to unoccupied home after cue |
| 12. Exploit risks | client owns Warden physics, forged hit, kiting to hub |
| 13. User feedback / UI | alert arc and tone; target marker readable without color; caught notification says actual loss |
| 14. Testing requirements | 7-player distraction, line-of-sight walls, all5 NPC active, blocked navigation |
| 15. Acceptance criteria | catch cannot occur through wall or inside protected lane; no pathfinding storm; reset always terminates |

## G06. Inventory and Disaster management

Phase P1.

| Field | Specification |
|---|---|
| 1. Purpose | เก็บสะสมโดยระบุตัวตนของแต่ละชิ้นได้ |
| 2. Player experience | ดู origin, income, placement และ lock ของชิ้นที่เลือก |
| 3. Gameplay flow | Open grant → inventory → inspect/lock/place/store → optional sell/fuse/theft |
| 4. Detailed mechanics | 100 total items incl placed; banked crates reserve one future inventory slot each; max3 banked crates; cannot pickup if no future slot; immutable disasterId + speciesId + originZone/tier + rank |
| 5. Rules & constraints | Locked items ห้าม sell/fuse; lock ไม่ทำให้ placed item กันขโมย ยกเว้น protected slot; no rename ตอน Launch |
| 6. States / transitions | Stored ↔ Placed; Stored→TransactionLocked→Stored/Consumed; Placed→TheftReserved→Transferred/Placed |
| 7. Interactions | G07, G08, G12 sell, G13 fuse, G15 steal |
| 8. Server responsibilities | validate ownership and version; canonical IDs; inventory slot reservations; filtered snapshots |
| 9. Client responsibilities | paged grid sort income/zone/rarity; confirm destructive actions; show theft eligibility |
| 10. Edge cases | inventory full at grant, missing contentId after patch, duplicate command, equipped item sale |
| 11. Failure handling | banked slot reservation guarantees grant capacity; unknown species quarantine read-only never delete; request resync |
| 12. Exploit risks | client invent ID/rank, negative quantity, stale UI, forging lock state |
| 13. User feedback / UI | 100-cap warning before trip; stored vs placed; reserved status |
| 14. Testing requirements | full capacity with pending rewards, stale version, unknown definition, 100-item mobile scroll |
| 15. Acceptance criteria | every grant has unique ID; capacity never exceeded; no item simultaneously placed and consumed |

## G07. Crate banking and opening

Phase P1.

| Field | Specification |
|---|---|
| 1. Purpose | ให้การเปิดบ้านเป็น payoff ที่ปลอดภัยต่อข้อมูล |
| 2. Player experience | วางกล่องที่แท่นบ้านแล้วเลือกเปิด เห็น odds ตาม rarity |
| 3. Gameplay flow | ReturnPending → durable Banked record → Open request → durable item+receipt → reveal |
| 4. Detailed mechanics | server freezes lootVersion at spawn; species roll once when bank commit prepared and store hidden outcome server-side; visual reveal only at Open; weighted pool 70/30; animation2s skippable |
| 5. Rules & constraints | minimum own-base8studs; method ไม่เปลี่ยน odds; bank capacity3; client ไม่เห็น hidden reward ใน Banked snapshot |
| 6. States / transitions | Banked → OpenCommitPending → Opened; failure remains Banked/CommitPending |
| 7. Interactions | G04, G06, G09, Index |
| 8. Server responsibilities | generate reward outside retrying transform; single profile transaction removes crate/adds item/updatesIndex/receipt; ACK after durable commit |
| 9. Client responsibilities | show crate tier/origin and disclosed odds; reveal from ACK result, skip replay does not reroll |
| 10. Edge cases | disconnect during animation, duplicate Open, failed save after response timeout, pool version removed |
| 11. Failure handling | reuse saved outcome and deterministic disasterId from crateId; query receipt on timeout; old loot version retained until crates drained |
| 12. Exploit risks | reconnect reroll, concurrentOpen, client-select species |
| 13. User feedback / UI | Saving… / Opened / Already opened; reconnect displays result history |
| 14. Testing requirements | crash before/aftercommit and ACK, 100 retries same request and new request IDs |
| 15. Acceptance criteria | one crate results in exactly one usable item; outcome stable across recovery; no one-time opening coin grant |

## G08. Placement, passive income and collect

Phase P1.

| Field | Specification |
|---|---|
| 1. Purpose | ให้ของสะสมสร้างทรัพยากรสำหรับลูปถัดไป |
| 2. Player experience | เลือก slot วางตัวโปรด เห็นรายได้/นาที และเก็บ Coins ที่ฐาน |
| 3. Gameplay flow | Stored→Place(slot)→accrue→Collect→coins→store/move |
| 4. Detailed mechanics | start4 slots, upgrade6/8; aggregate fixed-point accrual; online only; 15-minute storage cap at current earning rate; owner collects within8studs; no per-item Heartbeat |
| 5. Rules & constraints | placed only earns; transferred/locked items ไม่ earn ให้สองคน; settle before rate/slot/owner change |
| 6. States / transitions | Stored↔Placed; accumulator Accruing→CollectPending→Accruing |
| 7. Interactions | G06 inventory, G09 transaction, G11 upgrades, G15 theft |
| 8. Server responsibilities | settle timestamp using monotonic session time, fixed-point remainder; atomically move storedIncome to coins + reset; serialize |
| 9. Client responsibilities | animate counters ≤2Hz, use authoritative deltas; contextual Collect rather than many popups |
| 10. Edge cases | double collect, cap reached, full wallet, disconnect at same time asplacement |
| 11. Failure handling | rollback failed mutation; uncommitted accrual loss bounded to autosave interval, inventory/coins acknowledged as saved must persist |
| 12. Exploit risks | client time/amount, overflow, collect spam, duplicate placed IDs |
| 13. User feedback / UI | earning rate, capped meter, last saved time; no fabricated offline claim |
| 14. Testing requirements | 2 identical collect requests, freeze/unfreeze, rate change, 30min idle, rollback |
| 15. Acceptance criteria | sum ledger conserves coins; one placed item in one slot; no offline tick; cap and rounding exact |

## G09. Persistence, save/load and recovery

Phase P1.

| Field | Specification |
|---|---|
| 1. Purpose | ทำให้ผู้เล่นเชื่อว่าของที่รับและใช้ไปจะไม่หายหรือซ้ำ |
| 2. Player experience | เห็น saving state ที่ตรงกับ durability ไม่เล่นต่อด้วย profile ผิด |
| 3. Gameplay flow | Acquire lease→migrate copy→validate→reconcile receipts→Ready→periodic+critical save→release |
| 4. Detailed mechanics | schemaVersion1; 30s jittered autosave training/accrual; durable critical transactions per profile serialized; monotonic revision, session fencing; 120s lease/30s renewal candidate |
| 5. Rules & constraints | never save default after error; no nonfinite numbers/Instances/cyclic payloads; no force session stealing on normaljoin |
| 6. States / transitions | Loading, Active, SaveDegraded, LeaseLost, Closing, Closed |
| 7. Interactions | all authoritative systems |
| 8. Server responsibilities | UpdateAsync-based exclusive session, staged snapshot, retry budget/backoff, shutdown drain, migration rollback and limits |
| 9. Client responsibilities | loading/saving/read-only banners, retry requests same ID, last receipt |
| 10. Edge cases | multi-server rejoin, crash, throttle, corrupted schema, ambiguous timeout |
| 11. Failure handling | retry1/2/4/8s+jitter within budget; then freeze destructive/reward actions; session lease loss freeze immediately; reconcile nextjoin |
| 12. Exploit risks | rollback duplication, stale server overwrite, malformed UTF8, old schema write |
| 13. User feedback / UI | Data unavailable: your saved data has not been replaced; pending transaction status |
| 14. Testing requirements | mock faults at every commit boundary plus isolated staging DataStore on2servers |
| 15. Acceptance criteria | no acknowledged durable inventory loss/duplication in fault suite; old fencing token rejected; migration idempotent |

## G10. Physical treadmill and speed training

Phase P2.

| Field | Specification |
|---|---|
| 1. Purpose | ให้การฝึกเป็นกิจกรรมบนเครื่องจริง |
| 2. Player experience | ขึ้นบน belt แล้ววิ่งค้าง กราฟแสดง gain หยุดวิ่งหรือเดินลงแล้ว gain หยุด |
| 3. Gameplay flow | Enter belt→grounded+running intent→0.5s qualify→Training→exit/stop→Idle |
| 4. Detailed mechanics | Server samples at 5 Hz. Require root inside belt bounds, downward raycast onto that belt, living/grounded state, no carried item and current forward-run intent. After 0.5 s qualification, enter the run-in-place session specified in architecture section 10. Client renews held input at 10 Hz; intent expires after 0.5 s. Accumulate verified elapsed time with a 0.25 s sample cap and replicate gain at 1 Hz. |
| 5. Rules & constraints | ห้ามนับ world displacement เพียงอย่างเดียวเพราะวิ่งอยู่กับที่; no E-to-gain; one machine per player; stationary with no intent gives0 |
| 6. States / transitions | Idle → Qualifying → Training → Idle; suspend on stale intent, lag or abnormal position. Jump, lateral/back input and Stop release the training session. |
| 7. Interactions | G11 upgrades, G14 trails, zone speedgate |
| 8. Server responsibilities | own session clock, belt occupancy, speed curve; clamp rate and expire intent; no retroactive catchup |
| 9. Client responsibilities | Hold Run or forward input while physically on the belt; support touch, gamepad and keyboard. Render running animation and gain preview. Pressing Run outside the belt grants nothing. |
| 10. Edge cases | standing still, jump, sit, climb, lag, fake animation, spoof intent, multiple machines |
| 11. Failure handling | uncertain movement samples pause gain not punish; animation failure never grants; stale intent stops in0.5s |
| 12. Exploit risks | MoveDirection/velocity spoof, remote spam, teleport tobelt, speed packet amount; bounded earning remains even automated intent |
| 13. User feedback / UI | Running +n/sec, step onto belt, face forward, paused; training total distinct from WalkSpeed |
| 14. Testing requirements | Stand without input for 5 min and gain zero. Run for 60 s and gain the configured amount ±1 tick. Release/jump must stop earning within 0.5 s and restore movement. Reject a forged gain of 999999. |
| 15. Acceptance criteria | Physical belt occupancy and server accrual are necessary. No airborne or outside-belt gain. All input methods work; spoofed intent cannot exceed the server rate. No anchored character remains after stop, death, disconnect or machine removal. |

## G11. Base/treadmill upgrades and Zone unlocking

Phase P2.

| Field | Specification |
|---|---|
| 1. Purpose | ให้ Coins มีเป้าหมายระยะกลางและไม่ติด softlock |
| 2. Player experience | เห็นราคา ผลต่าง ก่อนซื้อ และโซนต่อไป |
| 3. Gameplay flow | Inspect→server quote(version)→confirm→validate prereqs→durable purchase→apply |
| 4. Detailed mechanics | treadmill levels0–3; slot count4/6/8; pen income level0–3; zones sequential coin+power+one prior zone delivery; costs in economy spec |
| 5. Rules & constraints | ซื้อได้ทีละระดับ; no refund/rebirth atlaunch; economyVersion match; shared hub machine uses personal stats |
| 6. States / transitions | Available→PurchasePending→Owned; insufficient→Available |
| 7. Interactions | G08 income, G10 training, G20 gates |
| 8. Server responsibilities | prices, balance, prerequisites, bounded transaction, ownedzone check on capture andentry |
| 9. Client responsibilities | preview effects and total cost; disable unavailable with reason; no silent purchase oninteract |
| 10. Edge cases | same upgrade concurrent, earlier zone missing, disconnect afterdebit, config version change |
| 11. Failure handling | atomic debit+upgrade; stalequote return refreshed price no autocharge |
| 12. Exploit risks | negative cost, skipped level, fakepower, client gate collision toggle |
| 13. User feedback / UI | Need120 Power / Need800 Coins / prior delivery condition; receipt |
| 14. Testing requirements | doublebuy, stale quote, run into locked gate via alternate path |
| 15. Acceptance criteria | one debit per acquired level; zone access monotonic; starterzone always accessible |

## G12. Sell system

Phase P2.

| Field | Specification |
|---|---|
| 1. Purpose | ลด inventory duplicates และเป็นทางออกเมื่อเต็ม |
| 2. Player experience | ขายของที่เก็บอยู่หลังเห็นชัดว่ากำลังเสียชิ้นใด |
| 3. Gameplay flow | SelectStored→quote→confirm→atomic consume+coins |
| 4. Detailed mechanics | sell= floor(60×baseIncomePerSecond), rank ignored to avoid refund loops; stored unlocked only; no batch sell ininitial release |
| 5. Rules & constraints | ไม่ขาย protected/placed/theft reserved/fuse inputs; no selling banked crates |
| 6. States / transitions | Stored→SellPending→Consumed |
| 7. Interactions | G06, G09, economy |
| 8. Server responsibilities | authoritative quote and exact ID/version validation, receipt |
| 9. Client responsibilities | confirmation shows name/rarity/rank and amount; hold confirm0.5s |
| 10. Edge cases | stale inventory, sameitem fuse inparallel, walletcap |
| 11. Failure handling | fail without debit/removal; replay receipt |
| 12. Exploit risks | fakeprice, duplicateIDs, sell after transfer |
| 13. User feedback / UI | Sold / item unavailable / store it first |
| 14. Testing requirements | sale/fuse race, retries, price underflow |
| 15. Acceptance criteria | consumed ID cannot earn, fuse or sell again; value matches configured formula |

## G13. Fuse machine

Phase P2.

| Field | Specification |
|---|---|
| 1. Purpose | ให้ duplicate มีประโยชน์โดยไม่บังคับไล่ rarity ใหม่ |
| 2. Player experience | เลือกตัวซ้ำ 3 ตัว เห็นผลแน่นอนก่อนจ่าย |
| 3. Gameplay flow | 3Stored same species+rank→quote→confirm→consume3+fee→newrank item |
| 4. Detailed mechanics | maxrank3; rank multiplier1,1.4,1.96; fee=120×baseIncome×1.5^(rank-1), roundedceil; no timer; no random failure; same species, same rank, base variant only atlaunch |
| 5. Rules & constraints | locked/placed/transfer items invalid; distinct3 IDs; no higher rarity; slot delta−2 |
| 6. States / transitions | Selecting→FusePending→Result |
| 7. Interactions | G06 G09 G12 Index |
| 8. Server responsibilities | single profile transaction; new ID fromoperationID; preserve species discovery; doesnot count as new wild discovery |
| 9. Client responsibilities | 3slots, before/afterrate, warnings about aggregate income tradeoff |
| 10. Edge cases | 1sameID repeated3times, insufficient coins, rank cap, disconnect |
| 11. Failure handling | all-or-nothing profile write; receipt returns same item |
| 12. Exploit risks | duplication, material reuse, fake recipe |
| 13. User feedback / UI | '3 become1; total income decreases, frees2slots' explicitly |
| 14. Testing requirements | three unique inputs, race with sell, crashcommit, variantmix |
| 15. Acceptance criteria | outputrank+1 andexactfee; no input remains; never mint coins |

## G14. Trails shop

Phase P2.

| Field | Specification |
|---|---|
| 1. Purpose | เพิ่มการแสดงตัวและเป้าหมายฝึก |
| 2. Player experience | ซื้อ Trail ถาวร เลือกใช้ทีละเส้น |
| 3. Gameplay flow | Browse→buy→own→equip/unequip |
| 4. Detailed mechanics | three coin trails total inclfree; multipliers1/1.15/1.30 training only; highest owned does not stack; no direct move speed |
| 5. Rules & constraints | cosmeticVFX capped; ownership server; noRobuxcheckout launch |
| 6. States / transitions | Unowned→Owned; Owned↔Equipped |
| 7. Interactions | G10 G11 G09 |
| 8. Server responsibilities | validate purchase/equip; replicate cosmeticID; gain uses equipped owned definition |
| 9. Client responsibilities | trail preview, low VFX mode, rate before after |
| 10. Edge cases | unequip midtick, purchase replay, invalid asset |
| 11. Failure handling | fallback visual no gameplay loss; settle training before multiplier change |
| 12. Exploit risks | client trailID injection/stacking |
| 13. User feedback / UI | bonus applies totraining notrunning speed label |
| 14. Testing requirements | multiplier switching, low graphics, duplicate buy |
| 15. Acceptance criteria | max1 equipped; no multiply stack; gain uses correct server definition |

## G15. Stealing and counterplay

Phase P2.

| Field | Specification |
|---|---|
| 1. Purpose | สร้าง socialrisk โดยไม่ทำลายของเริ่มต้นหรือข้อมูล |
| 2. Player experience | ผู้ขโมยต้อง channel และแบกกลับ เจ้าของได้รับเสียงเตือนและมีเวลาป้องกัน |
| 3. Gameplay flow | eligiblePlaced → 3s raidchannel → escrow reservation → carry ≤45s → own base deposit → durable transfer; owner recover cancels |
| 4. Detailed mechanics | PvP unlock after10successfulwilddeliveries AND20minactive; victim protection first20min or <10deliveries; slot1 permanent protected; successful raid grants victim90sprotection; victim online required; no theft from inventory; shield/manual60s duration/180scooldown cannot start during raid |
| 5. Rules & constraints | 1theft perbase,1carry perthief; placed income pauses during reservation; owner reclaim within6studs+LOS held0.75s; no damage weapon; no attacking hub byWardens |
| 6. States / transitions | Placed→Reserved→CarriedTheft→TransferPending→StoredByThief; failure→PlacedByOwner |
| 7. Interactions | G06 G08 G09 transfer ledger, G16 base protection |
| 8. Server responsibilities | server eligibility/LOS/timers/ownership; durable escrow+two-profile reconciliation; timeout restore; transfer only after physical arrival |
| 9. Client responsibilities | owner alert with target direction; raider return timer; protected slot icon; shieldtimer |
| 10. Edge cases | owner/thief disconnect,2thieves, sell/fuse duringraid, crash between profile writes |
| 11. Failure handling | disconnect before commit cancels to original owner; committed transfer reconciles even if one offline; no lossfirst thenbest-effortgrant |
| 12. Exploit risks | cross profiles not atomic, sessionhop, duplicate transfer, fakecatch; owner disconnect to evade known tradeoff logged |
| 13. User feedback / UI | attempt/defense/success; no anonymous loss with no explanation; review receipt |
| 14. Testing requirements | 2clients plus2serverfaultrejoin; crash at every saga step; 100retry operations |
| 15. Acceptance criteria | each disaster has exactly one usableowner; victimcan'tloseprotectedslot; no implementation release until ledger fault tests pass |

## G16. Base protection and Upgrade Pen

Phase P2.

| Field | Specification |
|---|---|
| 1. Purpose | กำหนดการป้องกันและการจัดฐานให้อ่านง่าย |
| 2. Player experience | เห็นพื้นที่ปลอดภัยของ starter และช่วง shield ไม่มี pay-to-protect |
| 3. Gameplay flow | baseReady→protection state→optional shield→cooldown; pen upgrade via G11 |
| 4. Detailed mechanics | Upgrade Pen is base service terminal for slot capacity+income modifier, not separate pet simulator; alwayssafe fromWardens; PvP rules onlyG15; shield activation one press near station |
| 5. Rules & constraints | no walls blocking public route; shielding cannot cancel active theft; protection expires on server time |
| 6. States / transitions | Protected→RaidEligible→Shielded→Cooldown; raids block new shield |
| 7. Interactions | G11 G15 G20 |
| 8. Server responsibilities | timestamps and eligibility; upgrade ownership; no duplicate combat framework |
| 9. Client responsibilities | baseoutline+shieldicon/timer; upgrade panel clear current level |
| 10. Edge cases | ownerrejoin, cooldown persistence, server clock change |
| 11. Failure handling | persist shield end/cooldownUTC; clamp durations; session join cannot reset protection |
| 12. Exploit risks | rejoin shield farming, client wall states |
| 13. User feedback / UI | slot1 protected, vulnerable slots individually marked |
| 14. Testing requirements | rejoin midcooldown, shield at capture time, blockedraid |
| 15. Acceptance criteria | protectionhas1authoritativestate; shield cannot permanently prevent raids without downtime |

## G17. Authorized global Admin Abuse

Phase P4.

| Field | Specification |
|---|---|
| 1. Purpose | ให้เหตุการณ์เดียวกันเกิดในแต่ละ server โดยไม่ใช้ Instance ร่วมกัน |
| 2. Player experience | เห็นชื่อ event โซนและเวลา เข้าไปรับกล่องแบบปกติ |
| 3. Gameplay flow | admin request→server authorize→durable event descriptor→notifytopic→each server reconcile→localspawns→expire→audit |
| 4. Detailed mechanics | allowlistedUserId server-side, explicit role EventOperator; template IDs only; zone1–5; descriptor id+revision+start/end+loot version; 5waves60s apart ×2crates/server; 5min event; cooldown30min globally; max10 eventclaims/user/event |
| 5. Rules & constraints | no client authoritative broadcast; max1globalactiveevent; normal caps separate eventactivecap2/zone; missed expired waves skipped |
| 6. States / transitions | Draft→Scheduled→Active→Ended/Cancelled→Archived |
| 7. Interactions | G02 G03 G09 G18; player zone eligibility unchanged |
| 8. Server responsibilities | auth, cap, descriptor persist, audit actor/time/zone/template/outcome; MessagingService notification+pollcatchup; idempotent wave instances |
| 9. Client responsibilities | eventHUD, countdown using server time, special cosmetic; adminUI only input request |
| 10. Edge cases | lost/duplicate/out-of-ordermessage, late join, serverboot, admin retries, no validnode |
| 11. Failure handling | registry read governs; retry, timeout fail closed, no grant if durable claim unavailable; cancel stops future spawns |
| 12. Exploit risks | client fakesadmin, unbounded tier/count, replayoldEventId, server hop farm |
| 13. User feedback / UI | Event delayed if services degraded; expired never claims 'active' |
| 14. Testing requirements | 2stagingservers, dropped message, duplicate20times, new server midwave |
| 15. Acceptance criteria | same event descriptor onhealthyserverswithin30sgoal; each local spawn identity unique; claimlimits durable; outage acknowledged not false 'all delivered' |

## G18. Event lifecycle, weekly LiveOps and recovery

Phase P4.

| Field | Specification |
|---|---|
| 1. Purpose | รักษาความถี่อัปเดตโดยไม่ผูกทีมกับการทำ Zone ใหม่ทุกสัปดาห์ |
| 2. Player experience | ตารางชัด ของ event ไม่ทำให้ของเดิมหมดค่า |
| 3. Gameplay flow | prepare template→staging→approve→schedule→monitor→end→review |
| 4. Detailed mechanics | weekly content rotation/cosmetic challenge; 1scheduledadminsession/week initial proposal; useconfiguredBangkoktime plusUTC storage; Eventvariantincome1.0x; hard loot allowlist |
| 5. Rules & constraints | Head release approval; no arbitrary console code/purchases/DataStoreedits; auditable event cancel; no weekly new zone requirement |
| 6. States / transitions | Prepared→QAApproved→ReleaseApproved→Running→Reviewed |
| 7. Interactions | G17 auditstore, G19analytics |
| 8. Server responsibilities | resume active valid descriptor atstartup; auditwriter append bounded records; retain30days candidate; event claims use profile receipts |
| 9. Client responsibilities | updatelog, clearstart/end and zone eligibility, completed state |
| 10. Edge cases | badconfig, obsolete place version, audit store failure, event rollbacks |
| 11. Failure handling | disable event switch; stop new spawns, honor already durable earned crates; do not mass delete earned items; old server refuses incompatible template |
| 12. Exploit risks | abusive admin, excessive giveaway, mutable config version |
| 13. User feedback / UI | cancellation reason and preserved rewards; no fake urgency |
| 14. Testing requirements | kill coordinator, update duringevent, rollback template, unauthorized role |
| 15. Acceptance criteria | event restart does not duplicate grants; audit contains actor and outcome; rollback runbook rehearsed |

## G19. Onboarding, Index and feedback

Phase P1 basic, P2 full.

| Field | Specification |
|---|---|
| 1. Purpose | ให้ผู้เล่นรู้ว่าควรทำอะไรต่อและเห็นความก้าวหน้า |
| 2. Player experience | นาทีแรกเห็นกล่องเป้าหมาย จากนั้นกลับบ้านวางและรับเงิน |
| 3. Gameplay flow | base→Zone1hint→Stabilize→escape→home→open→place→collect→train→next goal |
| 4. Detailed mechanics | P1 tutorial no treadmill dependency; P2 adds physical training after first reward; 4species/Zone Index; firstcompleteeachZone gives100×zone income factor coins once, no rank/variant requirement; hints dismissible |
| 5. Rules & constraints | no forced purchase or intrusive popup during chase; no reroll/tutorial free crate farm |
| 6. States / transitions | Step0…Step8; Index Undiscovered→Discovered→ZoneComplete→RewardClaimed |
| 7. Interactions | G06 G07 G08 G10 G17 |
| 8. Server responsibilities | derive progress from committed actions; telemetryeventIDs; once-only index bonus |
| 9. Client responsibilities | contextual single goal, silhouette cards, text+shape rarity, language keys |
| 10. Edge cases | skipstep, duplicate events, itemstolen/sold after discovery, missedACK |
| 11. Failure handling | Indexdiscoverypermanent; restores state onsnapshot; telemetry failure does not block play |
| 12. Exploit risks | reclaim bonus, client funnel grants |
| 13. User feedback / UI | goal next action, item details, uncertainty error not 'success' |
| 14. Testing requirements | first-time nohelp10playersgoal; rejoinstep; sold item still discovered |
| 15. Acceptance criteria | all steps recover from authoritative state; onebonuspereachZone; no request reward without complete |

## G20. World navigation and service interactions

Phase P1 blockout, P3 production.

| Field | Specification |
|---|---|
| 1. Purpose | ให้ Hub กับห้า Zone เป็นสถานที่ใช้งานจริงและเดินกลับได้ |
| 2. Player experience | เห็น landmark ถัดไปและทางกลับแม้จอเล็ก |
| 3. Gameplay flow | Hub→Zone1→…→Zone5; two internal escape routes/Zone; continuous return lane→own base |
| 4. Detailed mechanics | worldspec coordinates/route budgets in04; sevenbases+shop/sell/fuse/treadmill/trails/UpgradePen; public walkways≥16studs, escape≥12; services within8studs request check |
| 5. Rules & constraints | WorldContract validatesZoneId, baseid, spawnnodes, exitvolumes, service anchors; no rebuiltwholePlace; no copy reference assets |
| 6. States / transitions | Zone content Unloaded/Streamed/Ready client only; authoritative availability independent |
| 7. Interactions | G01 G02 G05 G10–18 |
| 8. Server responsibilities | validate anchors atboot; optional service fails closed; missing critical exit disablesZone safely; player access gates validate physical movement |
| 9. Client responsibilities | stream-safe labels/direction; visible blocked gate; low detail map |
| 10. Edge cases | stream out during capture, missing anchor, next zone closed, avatars large/small |
| 11. Failure handling | boundedwait/resync; prevententeringbrokenZone; preserve existing carry into validroute |
| 12. Exploit risks | gate collision bypass, clientfakeserviceanchor |
| 13. User feedback / UI | lockedZonecosts; map route home; accessibility markers |
| 14. Testing requirements | walk all routes mobile+7players; collision/raycast; missing anchor injection |
| 15. Acceptance criteria | fiveconnectedZonesandsevenbases; every service usable; no forced jump or paywall on return; authoredvisualQA passes |

## Depth without excess systems

A patrolling Warden also considers an active Stabilize reservation within 18 studs and line of sight. It gives a 0.75-second warning before approaching that player. If it reaches the holder before capture completes, cancel the reservation and leave the crate Available; do not remove an owned item. Cancelling the hold lets the player move away. This makes the two-second hold a real exposure cost when the Warden is close, so Snatch can be useful instead of merely saving time. After capture, the method-specific pursuit delay in G03 applies unless that Warden is already pursuing the holder; an existing warning/chase cannot be reset by completing or cancelling a hold. G05's eligible target set therefore includes active nearby holders as well as escaping carriers. P1-05 must test this case and never permit repeated hold/cancel to freeze the Warden.

Risk increases through distance, route visibility, the Warden's movement and the opportunity cost of a full carry slot. A Rare crate does not require a separate combat game. Stabilize's longer reservation and later alert suit cautious players; Snatch protects a contested opportunity but starts the chase sooner. The experimental random slowdown in current source is removed from the proposed baseline because it lacks a player response. One optional telegraphed crate vent can be tested after the baseline is fun, with no hidden loot effects.

A wider safe lane reduces repeat frustration after the player earns escape. It does not remove the trip. Base slots create a choice between displayed income and a favorite collection. Fusion sacrifices aggregate income to free slots and improve one individual. Theft creates a short visible contest with starter protection, a timed carry and a reclaim action rather than an unbounded combat system.

Validate capture choice with telemetry and observation. If over 85% of experienced attempts choose one method and success differs by less than 5 percentage points at equal progression, revise timings or cues before adding new mechanics. This is a tuning decision rule, not evidence collected yet.
