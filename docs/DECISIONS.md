# Architectural decisions

## ADR-001 — Source of truth (2026-10-12)
Accepted: Git + Rojo manages scripted Luau code. Roblox Studio manages authored scenes and playtests. Studio MCP is a controlled adjunct, not the canonical Luau source.

## ADR-002 — Collaboration (2026-10-12)
Accepted: four human contributors with one Codex each; independent clones / per-task branches / PR review. Avoid direct concurrent edits of the same file and unsupervised publishing.

## ADR-003 — Prototype scope (2026-10-12)
Provisional: working concept `Steal a Disaster!`. Gameplay still must pass small beta testing before a larger production commitment. Do not treat the brand or mechanics as final.

## ADR-004 — Dependencies (2026-10-12)
Accepted initially: small Rojo starter project + pinned toolchain. Add Wally packages or UI frameworks only when features require them. Do not introduce a complex framework prematurely.
