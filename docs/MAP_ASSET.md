# Saved 3D map — Steal a Disaster! (Steal An Egg-inspired layout)

**Primary editable Roblox Studio Place:** `studio/places/StealADisaster_EggLayout_Static.rbxlx`
**Reusable 3D model-only export:** `studio/exports/StealADisaster_EggLayout_Map.rbxmx`

Open the Place directly in **Roblox Studio edit mode**. It contains fully saved Workspace Models/Parts: **7 fenced player pens** across a green-studded base hub, five sequential rectangular biome environments, a wide open nest field in each Zone, tall dirt boundary walls, two crate nest positions per Zone, guardian markers, a continuous forward route and small original stylized disaster landmarks. All geometry is editable as ordinary Roblox Parts/Models and does **not** require pressing Play to appear.

### Design source and limits
The owner asked for the map to **follow Steal An Egg's layout/style**, not an invented blockout. The underlying design uses visual public references to green studded floors, wooden fenced plots, canyon boundary walls, open guardian-and-nest playfields, and sequential biomes. **Original Steal An Egg place geometry, scripts, models, audio and textures were not imported**: `Place_107778070777162.rbxlx` was not available on the connected computer or accessible prior file inventory. This is an independently authored reference-inspired layout, **not a pixel-exact conversion**.

This Place shows the current **Disaster** zones:
1. Tornado Town
2. Tsunami Coast
3. Volcanic Ruins
4. Thunderstorm City
5. Inferno Forest

### Files and gameplay
The Place contains both the static Workspace map and the temporary **Studio-only** gameplay scripts: test Crate claims, Stabilize/Snatch, placeholder Wardens, Speed Power unlocks, personal-base opening. The server `PrototypeWorld.create()` detects the saved root `DisasterFiveZonePrototype` first and binds its existing parts instead of building duplicate geometry at Play time. A blank Rojo-only place still uses a code-generated fallback for developer tests.

The seven plots are test gameplay slots, not a final confirmation of all hub service placements. Unfinalized: map scale/timing, detailed models/creatures, animation, Warden pathfinding, passive income, persistent save, mobile performance, collision fairness, global event game mechanics.

### How to check
- In Roblox Studio, open `studio/places/StealADisaster_EggLayout_Static.rbxlx`, expand **Workspace → DisasterFiveZonePrototype**, and select each Zone or base to edit.
- For just the map as a modular object, import `studio/exports/StealADisaster_EggLayout_Map.rbxmx` in another *blank* Studio place, not into this Place (otherwise geometry will duplicate).
- Structural XML test: `C:\Users\natta\AppData\Local\Programs\Python\Python310\python.exe tests/test_static_place.py`.
- Gameplay code tests: `node --test tests/prototype.static.test.cjs`.
- **Real Studio Playtest remains pending.** Success opening the 3D scene in editor does not imply that the Crate/Warden economy has passed functional QA.

Do not directly publish a third-party reference map: this asset is first-party blockout geometry designed around reference-game progression and the owner's disaster concept.
