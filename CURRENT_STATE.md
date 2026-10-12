# Current State

Last Verified: 2026-10-12 (Asia/Bangkok), repository and local CLI inspection
Branch: `docs/minimal-agent-context`
HEAD: `9252311c55290745fc9595b8757643bbee7d9bcf` (baseline before uncommitted documentation edits)

## Completed
- Existing Rojo/Luau skeleton: `default.project.json`, `src/shared/Config.luau`, `src/server/Bootstrap.server.luau`, `src/client/Bootstrap.client.luau`.
- Local Git has initial `main` history. On 2026-10-13, `origin` was added for `https://github.com/NutthakitPatike/Steal-a-Disaster-.git`. GitHub is currently **public and empty** (no default branch contents/commits); the local history has not been pushed yet pending a visibility decision.
- Team size confirmed by the Head: three people total (Head using ChatGPT + lnwjud MCP, two teammates using Codex).
- Minimal documentation aligned with the Head's ChatGPT + MCP workflow on branch `docs/minimal-agent-context`; changes are uncommitted and await Head review.
- On the inspected machine, Git and Codex are available. `Roblox_Studio` is registered as enabled in Codex CLI configuration; this **does not confirm a live Studio connection**.
- pstack `poteto-mode`, ponytail and several Roblox domain skills were found in local skill catalogs. Other machines are unverified.
- The ten supplied reference place exports are indexed in `docs/REFERENCE_SOURCES.md`. An updated source-only ZIP with all 26,917 script instance records and 10,128 code-like Source texts was generated as a ChatGPT artifact, **not copied to D:**; failed decompiler bodies and empty bytecode are separately flagged.

## In Progress
- Head accepted the **Disaster Containment** design direction in `docs/GAME_VISION.md` v0.4: living characters, Stabilize versus Snatch capture, and creature reactions that influence Warden escape. Speed training, treadmills, trails, zones and per-zone Index support the loop. These are **design decisions**, not implemented or playtested features; timings, effects, balance and detailed map still need prototype validation. No gameplay implementation has started.
- Documentation-only changes on `docs/minimal-agent-context` describe three-person GitHub PR collaboration, AI-agnostic per-task instructions and Studio-authored modular `.rbxmx` exports. A teammate quick start and copyable AI assignment contract exist locally; **none are online until the first push**. Pending review and a future commit/push. No application behavior changed.

## Blocked
- Rokit, Rojo, Selene, StyLua and Wally were not found in PATH on the inspected Head machine.
- The GitHub repository exists but is empty and **public**. Before the first push, confirm whether to keep it public; collect both teammates' GitHub usernames and invite them with Write access. Collaborator access, reviewed PR branch rules and teammate clones are NOT yet verified.
- Head-to-Roblox-Studio control through ChatGPT + lnwjud MCP is not verified; lnwjud's discovered standalone MCP server list did not include a Roblox Studio server.
- Game Design v0.4 specific mechanics/tuning (not the approved core direction), real member assignments, Roblox Group ownership and staging place still need confirmation.

## Known Issues
- No gameplay, persistence, UI, map or formal test suite exists in tracked source.
- No tracked CI workflow or checked-in playable Roblox place. Current repository is a bootstrap only.
- External example game places and third-party assets have not been licensed for redistribution.
- In ten reference exports, 16,609 Script instances lack a Source property, predominantly in Grow a Garden (10,338), Build a Boat for Treasure (2,940), and Evade (2,408). Another 180 nonempty Source instances contain decompiler failures/empty bytecode, including all 166 DOORS Source bodies. These systems must not be represented as completely recovered.

## Current Verification
- Git branch and HEAD: PASS (inspected).
- Git remote: `origin` configured locally (2026-10-13); NOT PUSHED. GitHub repo: PUBLIC, EMPTY (verified).
- `default.project.json` JSON parsing: PASS (2026-10-12 documentation verification).
- Lint (`selene src`): NOT RUN — tool unavailable.
- Format (`stylua --check src`): NOT RUN — tool unavailable.
- Typecheck: NOT RUN — no configured standalone typecheck command.
- Tests: NOT RUN — no tests configured.
- Build (`rojo build default.project.json -o build/prototype.rbxlx`): NOT RUN — tool unavailable.
- Studio playtest / live MCP: NOT RUN — live connection not verified.
- Documentation relative links: PASS (13 Markdown files checked, 0 broken internal paths).
- Git diff whitespace check: PASS (`git diff --check`); recheck after latest edits.
- Git LFS: FOUND locally (`git-lfs/3.7.1`); teammate installation, quotas and binary snapshot workflow are not verified.

## Next Recommended Work
1. Verify or install the declared Rokit tools; run formatter, linter and Rojo build.
2. Choose public versus private visibility **before pushing local source**; seed the existing GitHub repository's `main` from local history safely, invite the two teammates, and enforce PR-based merges after initial branch setup. Verify both teammates' tools and Git access.
3. Verify Head's actual Studio access route through lnwjud, then run a local Studio smoke test and decide the vertical-slice scope.

Only edit this file after collecting new evidence. Planned features belong in [docs/TASK_BACKLOG.md](docs/TASK_BACKLOG.md), and each worker's handoff belongs in the PR/task, not here.
