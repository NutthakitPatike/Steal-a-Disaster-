# Current State

Last Verified: 2026-10-13 (Asia/Bangkok), initial GitHub bootstrap and local CLI inspection
Branch: `main`
Initial GitHub seed HEAD: `c008cbfaab5539a5e29d91af87d4eac646092cf2` (initial push; use `git log` for later commits)

## Completed
- Existing Rojo/Luau skeleton: `default.project.json`, `src/shared/Config.luau`, `src/server/Bootstrap.server.luau`, `src/client/Bootstrap.client.luau`.
- The Head explicitly chose **Public**. On 2026-10-13, `origin` was configured and local `main` was seeded successfully on `https://github.com/NutthakitPatike/Steal-a-Disaster-` (initial commit `c008cbf`). This initial seed was a one-time bootstrap operation; ongoing collaboration uses feature branches and reviewed pull requests.
- Team size confirmed by the Head: three people total (Head using ChatGPT + lnwjud MCP, two teammates using Codex).
- Documentation was integrated from `docs/minimal-agent-context` into local `main` and published as the first GitHub seed on 2026-10-13.
- On the inspected machine, Git and Codex are available. `Roblox_Studio` is registered as enabled in Codex CLI configuration; this **does not confirm a live Studio connection**.
- pstack `poteto-mode`, ponytail and several Roblox domain skills were found in local skill catalogs. Other machines are unverified.
- The ten supplied reference place exports are indexed in `docs/REFERENCE_SOURCES.md`. An updated source-only ZIP with all 26,917 script instance records and 10,128 code-like Source texts was generated as a ChatGPT artifact, **not copied to D:**; failed decompiler bodies and empty bytecode are separately flagged.

## In Progress
- Head accepted **Containment Crates (not eggs)** for `docs/GAME_VISION.md` v0.6: crates of varying rarity spawn in NPC-guarded Zones; Stabilize/Snatch changes escape risk; players carry crates home and open them at their base for a second randomized Disaster result within the crate tier (e.g., different quality Secret Disasters). Tiny weather creatures start the progression; later Zones may have themed crates. This is **approved concept**, not coded, balanced or playtested. No gameplay implementation has started.
- Documentation and bootstrap files are now live on GitHub `main`: three-person PR collaboration, AI-agnostic task instructions, an onboarding quick start, and Studio-authored modular `.rbxmx` exports. No application behavior or playable gameplay was added.
- **Global Event Spawn design direction (2026-10-13):** admin-triggered special crate spawns target a selected Zone across **all active game servers** (e.g. a Secret Crate in Zone 2), with each server spawning its own instance. This replaces the suggestion of a personal Spawn Event Boost. Cross-server propagation, event ID/deduplication, limits and new-server catch-up are **proposed, not implemented or tested**.
- **Launch Zone scope confirmed by Head as a design target:** **five playable connected Zones at public launch** (1 Tornado Town, 2 Tsunami Coast, 3 Volcanic Ruins, 4 Thunderstorm City, 5 Inferno Forest), with Frozen Catastrophe (6) and Apocalypse Zone (7) for later major updates. [docs/ZONE_ROADMAP.md](docs/ZONE_ROADMAP.md) defines scope; first prototype remains Zone 1 only, then build 1–3 for beta. **None of these Zones is yet implemented or playtested.**
- **Map Concept v2 revised by Head direction on a docs branch for team review:** `docs/MAP_CONCEPT.md` + top-down SVG. **Confirmed world progression: Zone 1 → Zone 2 → Zone 3 → ... in one long physical sequence.** Admin Abuse spawns may target an existing Zone (example Secret Crate in Zone 2 on update), rather than a separate event plaza. Retains the original horizontal seven-Bay starting footprint and upward connector, but Bay uses/number of plots, safe return and dimensions remain **unconfirmed**. This is **not an approved full Studio map or implemented game**.

## Blocked
- Rokit, Rojo, Selene, StyLua and Wally were not found in PATH on the inspected Head machine.
- The GitHub repository is **public and seeded**, but main is **not protected** (`protected: false` confirmed from the GitHub branch API). Branch-protection endpoint access returned HTTP 403 to the connected GitHub integration, and the local Chrome profile is not signed into GitHub; mandatory PR/review protections cannot yet be configured by the available tools. Collect two GitHub usernames, invite them with Write access and configure rules in repository Settings. Teammate clones and Roblox Studio rights are not yet verified.
- Head-to-Roblox-Studio control through ChatGPT + lnwjud MCP is not verified; lnwjud's discovered standalone MCP server list did not include a Roblox Studio server.
- Game Design v0.6 specific crate spawn/loot odds, prototype balance, hidden reward persistence, live-event administrator privileges/reward limits, weekly release logistics, real member assignments, Roblox Group ownership and staging place still need confirmation. The original sketch's **seven rectangles are unlabeled**: base count and central Hub use are **pending Head/team review**. The **single long connected Zone sequence** is confirmed; safe return travel and release/event access are not.

## Known Issues
- No gameplay, persistence, UI, map or formal test suite exists in tracked source.
- No tracked CI workflow or checked-in playable Roblox place. Current repository is a bootstrap only.
- External example game places and third-party assets have not been licensed for redistribution.
- In ten reference exports, 16,609 Script instances lack a Source property, predominantly in Grow a Garden (10,338), Build a Boat for Treasure (2,940), and Evade (2,408). Another 180 nonempty Source instances contain decompiler failures/empty bytecode, including all 166 DOORS Source bodies. These systems must not be represented as completely recovered.

## Current Verification
- Git branch and HEAD: PASS (inspected).
- Git remote: `origin` tracking `origin/main`; initial push `main` PASS, independently verified from the GitHub branch API. Repo: PUBLIC, SEEDED; branch protected: FALSE.
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
2. Invite the two teammates with Write permission (usernames pending), configure `main` branch protection / ruleset to require PR + one approval (GitHub integration cannot modify protection here), and test a real teammate PR. Verify both teammates' tools, Studio access and separate clones.
3. Verify Head's actual Studio access route through lnwjud, then run a local Studio smoke test and decide the vertical-slice scope.

Only edit this file after collecting new evidence. Planned features belong in [docs/TASK_BACKLOG.md](docs/TASK_BACKLOG.md), and each worker's handoff belongs in the PR/task, not here.
