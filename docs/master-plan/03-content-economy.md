# Disaster roster, economy and progression

Status PROPOSED. All rates, prices, caps, probabilities and times are starting hypotheses. Arithmetic below is verified calculation, not a playtest, retention forecast or balance certification.

## 1. Launch content strategy

Use five Disaster families and four species per family, **20 species total**. Each Zone has two Common and two Rare entries so both rarity pools actually produce multiple outcomes. Higher tiers can use the same data format later, but do not dilute a twenty-species launch into five mostly single-species tiers. Display rarity as text, icon and silhouette, not color alone.

| Zone / factor F | ID and name | Tier / within-tier weight | Silhouette, idle and VFX | Base coins/sec |
|---|---|---|---|---:|
| Tornado Town / 1 | z1_dustling, Dustling | Common / 70 | Small inverted cone, paper flecks, bashful wobble | 1.00 |
| Tornado Town / 1 | z1_drizzle, Drizzle Cloud | Common / 30 | Rounded cloud with dangling rain beads, sneeze puff | 1.20 |
| Tornado Town / 1 | z1_gust, Gust Sprite | Rare / 70 | Three looping wind fins and broad eyes, bows into breeze | 2.00 |
| Tornado Town / 1 | z1_cyclone, Cyclone Cub | Rare / 30 | Squat spinning funnel with two ear vortices, restrained debris ring | 2.40 |
| Tsunami Coast / 2.2 | z2_ripple, Ripple | Common / 70 | Flat wave disc with face, gentle radial pulse | 2.20 |
| Tsunami Coast / 2.2 | z2_tide, Tide Bubble | Common / 30 | Teardrop bubble with foam cap, stretch and pop idle | 2.64 |
| Tsunami Coast / 2.2 | z2_wavelet, Wavelet | Rare / 70 | Curling crest with small flippers, rhythmic splash | 4.40 |
| Tsunami Coast / 2.2 | z2_undertow, Undertow Ray | Rare / 30 | Wide manta-like current, spiral belly, thin water ribbon | 5.28 |
| Volcanic Ruins / 4.8 | z3_cinder, Cinder Pebble | Common / 70 | Coal pebble, sleepy glowing fissures | 4.80 |
| Volcanic Ruins / 4.8 | z3_ash, Ash Sprite | Common / 30 | Angular ash puff with tiny mask, soot hop | 5.76 |
| Volcanic Ruins / 4.8 | z3_magma, Magma Cub | Rare / 70 | Heavy rounded rock cub, lava veins, slow stomp | 9.60 |
| Volcanic Ruins / 4.8 | z3_caldera, Caldera Crown | Rare / 30 | Bowl volcano with floating stone crown, tiny controlled eruption | 11.52 |
| Thunderstorm City / 10 | z4_spark, Spark Dot | Common / 70 | Bright dot inside dark bulb shell, quick blink | 10.00 |
| Thunderstorm City / 10 | z4_static, Rain Static | Common / 30 | Triangular cloud with zigzag antenna, faint electric ticks | 12.00 |
| Thunderstorm City / 10 | z4_zappy, Zappy | Rare / 70 | Two-pronged bolt body, springy hop, no full-screen flashes | 20.00 |
| Thunderstorm City / 10 | z4_thunder, Thunder Puff | Rare / 30 | Layered cumulonimbus mane, bass puff and rim light | 24.00 |
| Inferno Forest / 20 | z5_ember, Ember Seed | Common / 70 | Seed husk with flame sprout, opens and closes | 20.00 |
| Inferno Forest / 20 | z5_smoke, Smoke Moth | Common / 30 | Soft charcoal wings, warm rim, thin smoke curl | 24.00 |
| Inferno Forest / 20 | z5_flare, Flare Fox | Rare / 70 | Fox mask and leaf-flame tail, curious tilt | 40.00 |
| Inferno Forest / 20 | z5_wildfire, Wildfire Wisp | Rare / 30 | Tall branching flame antlers, warm heartbeat glow | 48.00 |

These are new art concepts, not existing finished assets. Preserve useful prototype names as display aliases only after assigning stable IDs. One shared rig per family is a production aid, but silhouette and idle timing must distinguish four species. Income differences reflect catalog desirability, not hidden active combat abilities.

Every production species deliverable includes original model, low-detail version, idle, carry/display pose where needed, icon, localized name/description, footprint, collision settings, audio rights record and content definition. In-base Disasters are lightweight decorative models with server-owned logical slots. Twenty autonomous NPC pets are not required.

Rare skins use two clear visual cues beyond color. Future Secret needs at least two independently desirable Secret entries before its pool is enabled. Event variant `Stormcharged` changes accent/particles and Index variant badge, **income multiplier 1.0**. Event variants are excluded from initial Fuse recipes to avoid ambiguous mixing rules. Variants do not block base Index completion.

## 2. Prototype values are not launch balance

Current `PrototypeConfig.luau` uses Common/Rare 85/15, uniform two-entry reveal pools, one-time opening payouts 100/300, speed gates 0/40/120/230/350, +10 training per prompt and a 500 cap. Expected opening payout is `0.85*100+0.15*300=130` in every Zone. There are no sinks. These values provide a test harness, not an economy.

The plan removes opening coin payouts after passive income becomes available. Players start at 0 Coins, 0 Speed Power, four empty slots and Zone 1 access. First reward is earned through a protected first-run route with ordinary pool odds, then placed. No recurring starter gift can be farmed by reconnecting.

## 3. Rarity and reveal probabilities

| Zone | Common spawn | Rare spawn | Per-spawn species probabilities C1/C2/R1/R2 | Expected base income of one opening |
|---|---:|---:|---|---:|
| 1 | 85% | 15% | 59.5 / 25.5 / 10.5 / 4.5% | 1.219 |
| 2 | 80% | 20% | 56 / 24 / 14 / 6% | 2.7984 |
| 3 | 75% | 25% | 52.5 / 22.5 / 17.5 / 7.5% | 6.36 |
| 4 | 70% | 30% | 49 / 21 / 21 / 9% | 13.78 |
| 5 | 65% | 35% | 45.5 / 19.5 / 24.5 / 10.5% | 28.62 |

Within each tier use 70/30 weights. Tier is visible before acquisition. The per-spawn probabilities describe the generator; players preferentially choosing Rare crates changes the distribution of opened rewards. Analytics must report both, and simulation must model contention rather than assume random sampling.

`E[baseRate,z] = Fz * ((1-pRare)*1.06 + pRare*2.12)`. Stabilize/Snatch, account age, spending, and near-miss animations do not change the roll. No pity system at launch. UI discloses actual tier pool odds. A saved Banked crate retains its original `lootVersion` even after a balance patch.

## 4. Income, accumulation and sinks

Store Coins as nonnegative integers and accrual in milli-Coins. Prices are whole Coins. Maximum wallet 1,000,000,000 is a design safety bound. On reaching the cap, display the limit and reject a collection that would overflow without silently discarding the pending balance.

`itemRate = baseRate(species) * 1.4^(rank-1) * (1+0.10*penLevel)`.

`R = sum(itemRate for placed, non-reserved items)`.

`newStoredMilli = min(capMilli, oldStoredMilli + floor(R*1000*elapsed + remainder))`.

Accrual uses monotonic server time during a loaded, owned session. Preserve fractional remainder between ticks. `capMilli = ceil(900*R*1000)` is a 15-minute capacity. Settle before changing R. If the new rate would reduce the cap below the existing balance, preserve the balance and pause accrual until collected; never destroy earned balance. On load, resume from zero elapsed since load, with persisted balance. **No offline income**.

Collect transfers `floor(storedMilli/1000)` to Coins and leaves the sub-Coin remainder. The same durable mutation updates both values. No coin Part per unit income. Aesthetic coin bursts are cosmetic.

| Sink | Proposed cost | Constraint and purpose |
|---|---|---|
| Treadmill levels 1/2/3 | 300 / 2,500 / 15,000 | Sequential; gains multiply by 1.8^level |
| Base slots 4→6→8 | 1,500 / 12,000 | Permanent capacity, no unlock beyond8 at launch |
| Pen levels 1/2/3 | 2,000 / 10,000 / 50,000 | +10% additive per level to placed income |
| Trails Breeze/Stormline | 1,000 / 8,000 | Training×1.15/1.30, one equipped, Free trail×1 |
| Zone unlocks | 800 / 5,000 / 24,000 / 100,000 | Combined with power and delivery condition below |
| Fuse | `ceil(120*baseRate*1.5^(inputRank-1))` | Consumes three equal-rank copies plus fee |

Sell value is `floor(60*baseRate)` with rank/variant/pen multipliers ignored. Examples: Dustling sells for60; Cyclone Cub144; Wildfire Wisp2,880. Sale destroys the item durably. No buyback. Sell must not exceed crafting inputs plus costs in any recipe. There is no coin purchase of Disaster items at launch, so the shop cannot create buy/sell arbitrage.

Fusion example: three rank1 Dustlings earn3/sec over three slots. Fuse costs120 and creates one rank2 Dustling earning1.4/sec over one slot. The player loses aggregate output but frees two slots. Three rank2 inputs plus180 produce rank3 at1.96/sec. Rank3 is the cap. UI must explain this tradeoff before confirmation. It is not a rarity-upgrade lottery.

## 5. Speed, unlocks and training

`WalkSpeed(P) = min(32, 16 + 4*log2(1+P/100))` studs/sec.

`trainingGain/sec = 1 * 1.8^treadmillLevel * trailMultiplier`.

Speed Power caps at10,000 for launch. Store a fixed-point remainder for fractional training. Carry does not impose hidden random slowdown in the baseline. Return lane speed is `min(36, WalkSpeed+8)` and applies only after durable safe-exit transition and while inside designated return volumes. Leaving the lane restores normal speed. Neither rule changes character position or deposits the crate.

| Unlock | Cost | Speed Power | Other condition | Movement at threshold |
|---|---:|---:|---|---:|
| Tornado Town | 0 | 0 | Ready profile | 16.00 |
| Tsunami Coast | 800 | 120 | One banked Zone1 crate | 20.55 |
| Volcanic Ruins | 5,000 | 450 | One banked Zone2 crate | 25.84 |
| Thunderstorm City | 24,000 | 1,200 | One banked Zone3 crate | 30.80 |
| Inferno Forest | 100,000 | 3,000 | One banked Zone4 crate | 32.00 |

Purchases require prior Zone ownership. Starting Zone never requires Coins or training, preventing a progression softlock. Upgrades are optional; example routes below include selected treadmill purchases for comparison. Full Index completion is not a Zone gate because rare drops have high variance.

## 6. Time-to-progress calculations

Do not add training time and passive earning time when they happen simultaneously. For one stage with a fixed placed income R and training fraction f:

`Tstage >= max((Cunlock + Cupgrades - availableCoins)/R, (Ptarget-Pcurrent)/(gain*f))`.

Use zero for negative requirements. Add separately the trips needed to acquire the assumed collection, collection travel, losses and deliberate purchases not included in C. Income is capped if players do not collect. Full simulation changes R whenever an item is placed or sold rather than freezing R forever.

The following calculations assume four randomly sampled rank1 items from the previous Zone, no pen/trail bonus, no starting Coins, immediate placement, perfect collection and the stated treadmill level already operating. Upgrade costs are included in the coin column, but their gain is optimistically available from the start. Thus these are **optimistic local stage bounds**, not a forecast of total playtime.

| Target | R coins/sec | Coin bill incl treadmill purchase | Power delta / assumed gain | Coin minutes | Training minutes | Concurrent bound |
|---|---:|---:|---|---:|---:|---:|
| Zone2 | 4.876 | 1,100 | 120 / 1.8 | 3.76 | 1.11 | 3.76 min |
| Zone3 | 11.1936 | 7,500 | 330 / 3.24 | 11.17 | 1.70 | 11.17 min |
| Zone4 | 25.44 | 39,000 | 750 / 5.832 | 25.55 | 2.14 | 25.55 min |
| Zone5 | 55.12 | 100,000 | 1,800 / 5.832 | 30.24 | 5.14 | 30.24 min |

Real first-session scenarios for Zone2:

- **Cautious mobile player.** Two Common1 items produce2/sec. An800 unlock without optional upgrades needs400s after placement. At1 Power/sec,120s of training can overlap income. Add approximately two successful45s runs and failures; 9–13 minutes is a test hypothesis.
- **Mixed active player.** Four expected Zone1 items produce4.876/sec. At success rate0.8 and45s attempt cycles, acquiring four takes `4*45/0.8=225s` in expectation. Income grows during those trips, so do not blindly add the full225s to the3.76min steady-state bound. Hypothesis is5–9min with one upgrade.
- **Struggling player.** At0.5 success, four items take360s expected, with large variance. With only one1/sec item the800 cost alone takes13.3min. Investigate first-run route and capture clarity before raising handouts or selling power.

For later stages, four items from Zone3 require trips before the25.55min bound is applicable. A player who buys two more slots may achieve higher R at the cost of1,500 Coins. A player who chases Rare only waits longer and competes for nodes. A player who never collects loses capped earning opportunity. Those differences are why static ROI tables cannot establish balance.

## 7. Simulation and playtest protocol

P2-07 produces a rerunnable economy model with seeded RNG and a CSV event ledger, not implementation during this request. Simulate at least1,000 agents per archetype over2hours and a24-hour equivalent progression horizon. Archetypes vary success (0.5/0.7/0.9), training fraction (0.15/0.35/0.6), collect interval (2/10/20min), target selection (random/Rare-priority), number of competing players (1/7), and purchase policy (save for Zone/upgrade-first).

Model exact nodes,4crate cap/Zone,8s respawn,90s TTL, route time by Zone, initial empty base, capacity, failures, unlock prerequisites, player departures, sale/fusion and theft interruption. Use sequential upgrade affordability, not the optimistic assumption above. Export p10/p50/p90 time to first reward, first Collect, each Zone unlock, Index completion, gross minted Coins, sink totals and wealth by cohort.

Initial playtest targets: first banked crate p50≤90s and p90≤180s; first placement/Collect p50≤150s; Zone2 median5–12min; Zone5 median90–180min across sessions. These are target bands only. Initial Zone1 success target70–90% after one explained attempt. If slow players fail, change route clarity and hazard timing before price inflation.

Track Index independently. Zone1's rarest species has4.5% unconditional per-spawn probability; its expected wait is22.22 random openings, not a guarantee. Ninety-five percent seeing it requires about66 independent random openings (`ceil(log(.05)/log(.955))`). The whole Index takes at least that tail exposure and usually more; do not promise completion in twenty runs.

## 8. Inflation and long-term goals

Mint sources are placed income, one-time Index bonus and sell conversion. Theft transfers wealth, not minting. Event variant has no income bonus. Index pays `100*Fz` once per Zone:100/220/480/1,000/2,000. No daily currency grant, offline payout or paid luck is needed for launch.

Long-term goals are20 discoveries, chosen rank3 Disasters, eight display slots, visual Trail completion and event variants. After the last Zone, content freshness comes from species/variant rotations and social play, not unbounded stat inflation. Monitor minted/sunk ratio, Coin percentiles, item ownership concentration and repeat theft victimization. Set alerts from staging baseline rather than invent production limits.

Balance revisions change definition version and preserve already-bankrolled outcomes. Never silently reduce an earned item's tier. If rates change, explain it in patch notes and run cohort projections first. Head reviews economy revisions; the developer does not tune live DataStores directly.
