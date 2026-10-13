# P1-03 Session Lifecycle — mock verification checkpoint

Date: 2026-10-13. Stacked after PR #13, #12 and #11. **Partial implementation, not production ready.**

## Added

- `src/server/SessionLifecycle.luau` opts into a supplied PlayerData coordinator. It never constructs a DataStore or starts a scheduler just by being required.
- `Join` acquires an exclusive session before returning the profile; duplicate managed joins fail.
- `IsReady` and `Transact` gate gameplay writes on Ready state and a safety margin before lease expiry. `SavePending` blocks new operations until `ResolvePending` retries the same operation identity through PlayerData.
- `Heartbeat` performs renewal at the 30-second cadence, blocks writes when renewal fails, retries after 5 seconds, and marks expiring leases unavailable.
- `Leave` retains unresolved Closing state instead of claiming a release; `Heartbeat` retries. `Shutdown` stops the scheduler, attempts to close managed sessions and reports unresolved failures.
- `StartScheduler` is explicit and server-only. No Bootstrap integration, PlayerAdded wiring, BindToClose, real player or production DataStore use has occurred.

## Actual checks

| Check | Result |
|---|---|
| Studio Edit-mode isolated fake-session lifecycle test | PASS 22 assertions |
| Studio Source parity for SessionLifecycle | PASS |
| Original Node static tests | PASS 6/6 |
| Static XML map checks | PASS both saved assets |
| Real staging DataStore, multi-server session handoff, BindToClose platform test | NOT RUN |
| Production data, Roblox publish | NOT TOUCHED |

A first mock test revealed a Shutdown API mismatch (empty error table instead of nil on success). The implementation was fixed and **fresh ModuleScript** retest passed all 22 assertions. Tests use explicit Heartbeat simulated time; they do not claim real-time scheduler timing or live DataStore guarantees.

## Open gates

Independent review of PRs #11–#14, a separately approved staging universe/data namespace, real 2-server lease/rejoin tests, actual PlayerAdded/Removing/BindToClose integration, pending-transaction recovery behavior, and verified Studio Save/backup remain necessary before launching persistent gameplay.

The launch Disaster roster and rarity tiers are still under product design review; this code does not depend on a fixed count of 20.
