# P1 foundation — evidence checkpoint (2026-10-13)

Status: **P1-01 PARTIAL; P1-02 IMPLEMENTATION STARTED, NOT ACCEPTED**. This record describes observed behavior, not a phase-completion assertion.

## Workspace and Studio baseline

- Git base: `main` at `72db6c8ce02bd7a9e3a101ceb8e4a9b821ff8c11`, clean before this task.
- Working branch: `feat/p1-02-foundation-contracts`.
- Open Studio: Steal A Disaster!, PlaceId `89467184271147`, Edit model, official Studio MCP instance verified in this session.
- At initial inspection, exactly four preexisting ModuleScripts matched Git. The four missing server/client executable scripts were restored **only when absent**; no existing scripts were overwritten during reconciliation.
- After P1-02 edits, read-back of **11 Script/ModuleScript sources and class names matched the corresponding `src/` files (11/11)** after line-ending and outer-whitespace normalization.
- In Edit, Workspace contained Terrain, SpawnLocation, Camera. **No authored `Workspace.DisasterWorld` and no permanent five-Zone map**. The saved on-disk static map under `studio/places/` is a separate artifact, not a verified live-scene backup.
- A Studio `Ctrl+S` hotkey was issued. Save destination/cloud durability was **not independently verified**. No Publish or DataStore write was requested.
- P1-01 remains open until the designated staging world, seven base anchors, Zone 1 entry/exit, recovery backup and per-teammate ownership are confirmed.

## P1-02 deliverables in this branch

- `src/shared/Definitions.luau`: protocol v1, five stable zone IDs, base count seven, authored-world tags and bounded public error/action identifiers; **no 20-species roster or final rarity distribution is locked**.
- `src/server/WorldRegistry.luau`: validates versioned, tagged authored anchors; rejects duplicate IDs, invalid types and missing Zone 1/base/spawn requirements. Does not generate, import or replace a world.
- `src/server/RemoteRouter.luau`: strict, capped Snapshot request validation; rejects unknown actions, invalid versions and malformed values. Throttles per player and ignores floods without reply amplification. No currency, inventory, grant, persistence or admin mutation endpoints exist.
- `src/server/Bootstrap.server.luau`: starts the new remote boundary only during Studio tests; existing prototype/game logic is preserved.
- `tests/runtime/Contracts.spec.luau`: reproducible Edit-mode contract test module (temporary world under ServerStorage, destroyed afterward). Does not touch live players or DataStore keys.

## Actual verification

| Check | Result | Meaning |
|---|---|---|
| Studio Edit Script/ModuleScript source parity | PASS 11/11 | Studio and branch source content matched at inspection |
| `tests/runtime/Contracts.spec.luau` via temporary Studio ModuleScript | PASS 18/18 | Validation and synthetic-world cases |
| Studio Client-to-Server Snapshot request | PASS | Received matching requestId and expected `NotReady`, with no profile mutation |
| `node --test tests/prototype.static.test.cjs` | PASS 6/6 | Legacy source-static assertions only |
| `python tests/test_static_place.py` | PASS both files | Static Place/map XML structural checks, not current live scene |
| Studio solo start/stop | PASS bootstrap smoke | Server/client/prototype initialized. Prototype world was temporary during Play |
| Multiplayer, DataStore, world navigation, mobile, release gates | NOT RUN | Do not infer readiness from smoke tests |

## Pending before P1-02 gate

1. Reconcile an approved, backed-up authored staging map with tagged anchors and rerun WorldRegistry on the **real world**, not just the synthetic fixture. Do not replace user scene without explicit map approval.
2. Review contracts and module ownership with Head/Dev2; add additional request action handlers only with P1-03 durable state.
3. Add automated test-runner, Luau formatter/linter and multiplayer validations when that toolchain is available and verified.
4. Confirm Studio Save backup and precise staging namespace. No production DataStore keys should be touched before isolation and fault tests.

Implementation branch is review-only until PR approval; no live publish or merge authorization is inferred.
