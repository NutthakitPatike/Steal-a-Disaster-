# P1-03 Profile Foundation — Mock-verified checkpoint (2026-10-13)

**Status: PARTIAL IMPLEMENTATION, NOT A P1-03 ACCEPTANCE PASS.** The feature branch is stacked on open PR #11 (`feat/p1-02-foundation-contracts`), not merged to main. This is a data core suitable for review, not a production persistence deployment.

## Added

- `src/server/ProfileSchema.luau`: serializable v1 profile defaults and bounds for revision, balances, 4/6/8 slots, inventory, receipts, session fencing, indexes and event/transfer placeholders. Unknown newer schemas and invalid profiles are rejected instead of reset. `Schema.New` runs only inside a confirmed missing-key acquisition in the injected storage adapter.
- `src/server/Transactions.luau`: pure provisional mutation, bounded receipt history, rejected/stale transaction behavior, maximum serialized snapshot size and commit-before-ACK design. Existing-operation receipt is returned under an exact replay.
- `src/server/PlayerData.luau`: session acquisition/retry, monotonically increased fencing generation on owner changes, expiry, renewal, close and critical transaction serialization. Ambiguous adapter errors block unrelated operations until replay of the *same* operation ID resolves a receipt or safely executes the unchanged deterministic mutation. The session token is generated outside retried callbacks.
- `tests/runtime/PlayerData.spec.luau`: fake UpdateAsync adapter that simulates repeated callbacks, before-commit failure, after-commit ACK loss, competing sessions and corrupt data. No mock operation touches Roblox DataStore.

**Integration boundary:** These server-only modules are currently instantiated only in Studio Edit-mode tests. `Bootstrap` has **not** been wired to load or write any player data. `RemoteRouter` remains Snapshot-only and returns `NotReady` by design. No final 20-species launch roster or rarity distribution is assumed.

## Evidence captured

| Check | Result / scope |
|---|---|
| Studio Edit fake storage test module | **PASS 39 assertions**, including retry with committed-but-lost ACK, stale ownership, rejection of corrupt/future profile |
| Studio source parity | **PASS 14/14**, actual Source content/class in active Place vs working source after normalization |
| Legacy Node static tests | **PASS 6/6**, only original source tests |
| Static XML map tests | **PASS two fixtures**, disk assets only |
| Git diff whitespace | PASS |
| Roblox real DataStore, two actual jobs, profile migration, mobile, real gameplay | **NOT RUN** |

## Important known limitations and required next work

1. **No real DataStore session adapter or two-server staging test yet.** An adapter will be connected only after separate staging namespace and permissions are verified and after a reviewed P1-03 rollout plan. Never point Studio experiments at production keys.
2. **No background autosave loop / 30-second renew scheduler / BindToClose teardown / actual player lifecycle yet.** `PlayerData:Renew` and `Close` primitives are implemented but not wired to players.
3. **Receipt storage is bounded to 128 recent operations**; irreversible domain actions must also use permanently consumed resource identities and durable operation pointers/tombstones where appropriate. Do not treat a short receipt cache as perpetual replay prevention for arbitrary new expected revisions.
4. **Mutation callbacks must remain pure, deterministic and non-yielding**, must be called only after server-side validation and cannot grant items based on client-supplied amounts. The injected adapter is a testing seam, not a gameplay-authority Remote.
5. **Current live Studio Edit Workspace does not have the approved, tagged production map.** P1-01/02 gates remain pending. The disk static Place is not proof of current Studio scene state.
6. **No team review yet.** Submit code as a stacked PR against `feat/p1-02-foundation-contracts` while PR #11 remains open; merge only in dependency order after independent review.

No map replacement, live Roblox publishing, actual PlayerData key access or game-wide launch readiness is implied by this checkpoint.
