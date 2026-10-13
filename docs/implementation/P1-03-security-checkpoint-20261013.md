# P1-03 Transaction Hardening — verification checkpoint

Date: 2026-10-13. Base: PR #12 (stacked on PR #11). **Review proposal; not launch-ready.**

## Changes

- `Transactions.Apply` now rejects gameplay callbacks that alter reserved profile metadata: session owner/token/expiry, fencing counter, revision, schema/content version, receipts or receipt order. Returns `ForbiddenMetadataMutation` without committing a mutation.
- `StagingDataStoreAdapter` is optional, explicitly enabled, and validates a separately approved staging GameId, PlaceId and namespace. It rejects main universe `10770595743`, verified in the project audit. Requiring this module does not open DataStore; Bootstrap does not call Create.
- Reproducible security regression tests: `tests/runtime/TransactionSecurity.spec.luau`, `tests/runtime/StagingDataStoreAdapter.spec.luau`.

## Verified

| Check | Result |
|---|---|
| Studio Edit contracts | 18 PASS |
| Studio fake PlayerData/UpdateAsync | 39 PASS |
| Studio Transaction Security | 26 PASS |
| Studio Staging Guard | 10 PASS |
| Total Studio assertions | **93 PASS** |
| Legacy Node static | 6/6 PASS |
| Static Place and map XML | Both fixtures PASS |
| Studio read-back of changed Lua sources | 2/2 MATCH |
| Live DataStore, two-server Session tests | **NOT RUN** |

After editing Transactions in Studio Edit mode, `require` initially returned a cached prior module and one test failed. A fresh ModuleScript clone of the revised source rejected the mutation as intended. All 93 assertions passed using fresh test module identities; temporary objects were destroyed.

## Remaining blockers

P1-03 still requires real isolated staging universe and DataStore testing, 30-second session renewal scheduling, disconnect/shutdown integration, recoverable migration and durable domain operations. Do not confuse mock confirmation with durable real-world writes. No permanent map changes, no production user data access, no Roblox Publish. PR #11 → PR #12 → this PR require team review in order.
