# AI agent entry point — Roblox Create

## Mission
Help a three-person team prototype an original Roblox game that can be tested for player interest. "Steal a Disaster" is a **working hypothesis**, not a locked game design.

## Authority and evidence
Priority: (1) current explicit user instruction, (2) this file, (3) confirmed decisions in [docs/DECISIONS.md](docs/DECISIONS.md), (4) [docs/GAME_VISION.md](docs/GAME_VISION.md), (5) actual code and config contracts, (6) relevant design notes, (7) active execution plan, (8) [CURRENT_STATE.md](CURRENT_STATE.md), (9) other docs, (10) history.
When investigating **runtime behavior**, source, tests, and live Studio evidence override claims in prose. Label unsupported information UNKNOWN.

## People and ownership
- **Head:** the user, working through ChatGPT + lnwjud MCP; owns product decisions, integration and release approval. Do not assume the Head works in Codex.
- **Two teammates:** work through their own Codex sessions, separate clones and branches.
- Assign one owner, scoped paths/Studio zone, acceptance evidence and reviewer for each Issue. Follow [docs/TEAM_WORKFLOW.md](docs/TEAM_WORKFLOW.md), including its AI-agnostic task contract; never overwrite another worker's unreviewed work. Another AI's chat context is not authoritative project state.

## Work rules
- Inspect the tree, branch/HEAD, git status, relevant code, and docs before edits.
- Prefer the smallest correct change. Preserve unrelated work and existing architecture.
- Git + Rojo is the source of truth for managed Luau. Studio is for maps, models, scene editing and playtests. Never let MCP and Rojo overwrite the same managed script.
- Server must validate client requests that affect currency, ownership, item grants, saves, purchases and other authoritative outcomes.
- Keep secrets out of Git and review licenses and scripts in third-party assets.
- Do not force-push, delete data/assets, publish or modify production DataStores without Head approval. Merge to `main` only through a reviewed PR; the Head approves cross-team interfaces and releases, while teammates with Write permission may merge routine reviewed PRs according to [docs/TEAM_WORKFLOW.md](docs/TEAM_WORKFLOW.md).

## Skills — load on demand, not all at once
- Nontrivial multi-stage analysis: `poteto-mode` from pstack, **only if available in the current runtime**.
- Code and dependency choices: `ponytail` (smallest complete solution).
- Roblox Studio MCP work: `roblox-studio-mcp`; cross-boundary code: `roblox-architecture`, `roblox-networking`, `roblox-security` as relevant.
- UI/world/data/performance/growth: select the matching `roblox-gui`, `roblox-building`, `roblox-data`, `roblox-performance`, `roblox-growth-design`, or `roblox-analytics` skill only when relevant.
- PR review: `ponytail-review` or `roblox-code-review`; documentation: `technical-writing` when available.
Skills observed on one computer are **not** proof that other team members have them. Never claim a skill ran unless loaded and used. No plugin package is vendored in this repository.

## Verification and routing
- Report the commands actually run, results, and NOT RUN for unavailable tools. Use Studio playtests for Roblox runtime claims.
- Getting started and current tool commands → [README.md](README.md)
- Gameplay proposal and scope → [docs/GAME_VISION.md](docs/GAME_VISION.md)
- Actual minimal file layout → [README.md](README.md) and `default.project.json`
- Current verified checkpoint → [CURRENT_STATE.md](CURRENT_STATE.md)
- Team ownership and handoffs → [docs/TEAM_WORKFLOW.md](docs/TEAM_WORKFLOW.md)
- Multi-phase work → [.agent/PLANS.md](.agent/PLANS.md)
- Studio MCP workflow → [docs/STUDIO_MCP.md](docs/STUDIO_MCP.md)
- Test expectations → [docs/TEST_PLAN.md](docs/TEST_PLAN.md)
- Project decisions → [docs/DECISIONS.md](docs/DECISIONS.md)
- Research into the ten provided Roblox reference games → [docs/REFERENCE_SOURCES.md](docs/REFERENCE_SOURCES.md)
