# Five-zone original map — Studio-only test

This branch replaces the **one-Zone greybox map** with five **newly generated** themed Zone layouts, *inspired by the continuous progression structure* of Steal An Egg but **not a copy of its geometry, models, code or visuals**. The original `Place_107778070777162.rbxlx` map was **not available in this project**, so no claim of pixel/geometry fidelity is made. All art is authored as original low-cost geometric placeholders from Roblox Parts.

### Single connected map
Hub / temporary six test bases → **Tornado Town** → **Tsunami Coast** → **Volcanic Ruins** → **Thunderstorm City** → **Inferno Forest**. No Zone portals or detached event plaza. A pale return shoulder on the right is continuous to the hub; secured crate carriers get **30 WalkSpeed (temporary test balance)** to shorten the return while keeping physical travel. Future Zones 6/7 are not built.

### Each Zone in the test
- One distinct environment: pastel buildings/tornado, water/lighthouse, basalt/lava, dark city/electric signs, forest/embers. **Visual sculptures only**, not damaging weather simulations.
- One separately spawning Common/Rare Containment Crate with **Stabilize** or **Snatch** capture choice and its **own** placeholder Warden.
- Server checks required **Speed Power: 0, 40, 120, 230, 350**, respectively (test thresholds, not finalized economics).
- Run past that Zone's green exit, carry a **Secured** crate back to the player's assigned base, and reveal a Disaster from **that Zone's tier pool** (2 Common / 2 Rare placeholder rewards per Zone).
- Server-owned claims, inventory/Coins/Index are **memory-only**. All progress resets on rejoin; no production DataStore writes.

### Build and test
1. At repo root, run `rojo build default.project.json -o build/five-zone-test.rbxlx` with Rojo 7.6.1 (or pinned Rokit).
2. Open the generated file in a **new local test Roblox Studio**, not a live game. Press **Play**.
3. Train Speed at the blue stand in hub, travel *straight* to Zone 1, choose Stabilize or Snatch at the glowing crate, outrun Warden past green line, and use your own base station to open it.
4. Train to 40/120/230/350 Speed Power, repeat in Zone 2/3/4/5. Compare readability and return times along pale shoulder; do not skip long-distance route verification.
5. Studio Test → **2 Players** to attempt simultaneous claim in the same Zone, different Zone claims at the same time, wrong-base opens, repeated prompt spamming, respawn while carrying, and reconnects.
6. Check mobile (touch prompts and HUD), actual Warden collision/route quality, Script Output, and performance (FPS/instance count). Attach screenshots and actual results.

### Validation contract
- `node --test tests/prototype.static.test.cjs`: code contracts only, **not a physics/play simulation**.
- `stylua --check src`: format and parse; record any nonzero exit as pending.
- `rojo build ...`: Luau source packaging; does **not** prove Roblox Studio can execute the entire game.

**Known limitations:** The Wardens are anchored spheres with direct chase rather than pathfinding humanoids. The 5 environments are visual blockouts, **not finalized map assets** or gameplay hazards. The six hub plots do **not** settle the owner's seven unlabeled bays. No production-ready save/load, UI polish, monetization, global event engine, or published game. Studio solo/multi/mobile Playtests are mandatory before saying the five-Zone map is release-ready.
