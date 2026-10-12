# Studio test — saved editable five-Zone map

**Open the file studio/places/StealADisaster_EggLayout_Static.rbxlx directly in Roblox Studio.** This is a permanent 3D scene visible and editable in Workspace **without Play**. Seven fenced test bases, five sequential Zones, grassy/checkered ground, canyon boundary walls, crate-nest positions, zone guardian markers and props are saved as Parts/Models. The original third-party Steal An Egg place was not imported. See MAP_ASSET.md.

## Visual inspection

1. Open the saved Place, and stay in Edit mode. In Explorer expand Workspace → DisasterFiveZonePrototype.
2. Expand Hub_Original and the seven TestBase models. Expand Zone01_TornadoTown through Zone05_InfernoForest. Select any wall, fence, nest or prop and check that it is an editable anchored Part.
3. The map-only modular export is studio/exports/StealADisaster_EggLayout_Map.rbxmx. Import this only into a blank Place, not over the saved Place.

## Actual Playtest — NOT YET RUN

1. Press Play. Train Speed and go to Zone 1; capture with Stabilize or Snatch, escape the placeholder Warden and open a Crate at your own base.
2. Train to 40, 120, 230, 350 Speed Power and repeat Zones 2–5; verify return-route geometry and same-tier Zone-specific rewards.
3. Test with at least 2 players for single-claim ownership, wrong-base openings, repeated prompts, respawns and travel time; later test 7 players.
4. Check mobile prompts, camera, FPS and Script Output. Do not publish the Place before runtime QA.

## Automated checks

- Run Python 3.10 tests/test_static_place.py to verify both 3D XML assets have five Zones, seven fenced pens and more than 1,800 saved Parts.
- Run node --test tests/prototype.static.test.cjs to check the server-side source contracts.
- Run stylua --check src and a disposable Rojo build to verify Luau source formatting/export. These checks are not Studio runtime evidence.

Limitations: Warden is a placeholder direct chase with no real pathfinding; earnings are memory-only; persistent save, finalized UI and global LiveOps remain unimplemented.
