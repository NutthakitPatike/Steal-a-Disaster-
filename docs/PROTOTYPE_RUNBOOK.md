# Tornado Town — Studio-only First Playable

**Safety:** This is a generated **greybox** for a new local Roblox Studio test place, never for production publishing. Coins, Speed Power, Disaster inventory and Index are **memory-only** and reset on leave. The red Warden is an anchored visual that **chases directly**, not a real pathfinding NPC. The six prototype plots are **temporary test bases**, not a decision about the seven unlabeled rectangles in the approved map draft. No purchases, DataStores or Global Admin Abuse run.

## Run it
1. Check out feature branch `feat/tornado-town-vertical-slice`. Install Rojo 7.6.1 (or the pinned project Rokit toolchain).
2. Build `rojo build default.project.json -o build/tornado-town-test.rbxlx` and open the generated `.rbxlx` in Roblox Studio. **Use a new local test place, not an existing production experience.** Alternatively serve the scripts via Rojo to a blank test place.
3. Press **Play**. Use the blue Speed trainer in the Hub, follow the middle lane into Zone 1.
4. At the bright crate, choose **Stabilize** (hold prompt) or **Snatch** (instant prompt). Carry the visible-tier crate and escape the Warden through the green safe exit.
5. At the plot labelled with your username, activate **Open Crate**. You should receive exactly one random Disaster from the **same tier** and some test Chaos Coins.
6. Test Snatch's warned brief slowdown, both capture options, catch/loss, repeat pickups and base opening.
7. Studio → Test → Start with **2 players**: race for the same crate; try opening another user's base; try opening twice; respawn while holding a crate; leave and rejoin. No duplicate grants should occur; progression intentionally resets on reconnect.

## Test evidence to record
- [ ] Solo: spawn/capture/Warden/escape/base reveal loop actually succeeds
- [ ] Both prompts usable and understandable; crate reward matches its visible tier
- [ ] NPC warning and fair chase; caught player loses only unsecured crate
- [ ] Two players cannot both claim the same crate or open each other's base
- [ ] Mobile ProximityPrompts and HUD fit screen; no floor gaps or unreachable pads
- [ ] Studio output has no unexpected script errors; attach screenshot/video evidence
- [ ] Disconnect/respawn does not yield duplicate rewards

## Command-line verification (does NOT replace Studio)
- `node --test tests/prototype.static.test.cjs` — static source contracts
- `stylua --check src` — Luau parse and format
- `rojo build default.project.json -o <temporary-path>.rbxlx` — build/export mapping only

**Do not merge or publish** until another team member reviews the PR, a Studio playtest passes, and the Head accepts shared server/gameplay contracts. Future Zone 2–5, persistent saves, pathfinding Warden, production UI and weekly Global Event Spawn are separate work.
