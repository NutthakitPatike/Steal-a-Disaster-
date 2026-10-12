# Roblox Create — team game prototype

Working title: **Steal a Disaster** (provisional). Goal: test an original, shareable core gameplay loop rapidly and measure whether real players return. Not an existing published game.

## Quick start (each teammate)
1. Install Roblox Studio, Git, Codex CLI, and VS Code (recommended).
2. Install [Rokit](https://github.com/rojo-rbx/rokit), then run: `rokit install`.
3. Run `rojo plugin install` (or install the Rojo Studio plugin from Creator Store).
4. Run `rojo serve default.project.json`. Open your local test place in Studio, then connect the Rojo plugin.
5. Run `selene src`, `stylua --check src`, and `rojo build default.project.json -o build/prototype.rbxlx` for basic checks.
6. Enable built-in Roblox Studio MCP for Codex using docs/STUDIO_MCP.md. This is local to each teammate.

No installs or game publishing occur by merely cloning this repository.

## What belongs where?
- `src/server` — authoritative game logic, persistence, validation.
- `src/client` — UI, input, camera, feedback.
- `src/shared` — shared types, constants, pure functions.
- `default.project.json` — Rojo-to-Studio mapping for SCRIPT folders only; Workspace/map is not managed by this config.
- `docs/` — game vision, ownership, architecture decisions, backlog.
- `build/` — generated builds, ignored by Git.

**Single source of truth for code is Git.** Team Create / Studio is used for scene work and playtesting. Do not use Studio MCP and Rojo to edit the same scripts concurrently.

## Team workflow
Everyone has Codex but every task must have ONE human owner; see docs/TEAM_WORKFLOW.md. Create a branch, implement small change, test, open PR, let another teammate review, then merge.

## Current state
- Phase 0: team foundations and a minimal Rojo skeleton, not a playable game.
- Roblox Studio MCP, tool installations, actual playtest, and GitHub remote/team permissions still need individual setup/verification.
- Avoid importing third-party decompiled scripts/assets without explicit rights.

Start reading: **AGENTS.md** → docs/GAME_VISION.md → docs/TEAM_WORKFLOW.md → docs/TASK_BACKLOG.md.
