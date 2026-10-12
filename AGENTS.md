# AGENTS.md — Roblox Create

This repository is a collaborative Roblox Luau game prototype. Every Codex agent must follow this file before editing.

## Context and priority
1. Read README.md, docs/GAME_VISION.md, docs/TEAM_WORKFLOW.md, and docs/DECISIONS.md.
2. Working title: Steal a Disaster. The concept is provisional and must be validated with players before scaling scope.
3. Optimize for a fun, stable, mobile-friendly core loop; do not build speculative large systems.

## Authoritative ownership
- Luau source code and Rojo project configuration: files in Git are the source of truth.
- Roblox Studio: 3D map, visual assets, playtesting, and publishing. Studio MCP edits must not silently override Rojo-managed scripts.
- Only a designated integrator manages the shared Studio place and publish operation.
- The original imported/example Roblox place files are references, NOT licensed code/assets to ship without verified permission.

## Architecture and security
- Use Luau, prefer --!strict, small modules, clear typed interfaces.
- Server owns currency, item ownership, rarity rolls, damage, purchase outcomes, and saves.
- Validate all client input, RemoteEvents and RemoteFunctions on the server. Rate-limit repeatable actions. Never trust client-reported prices/rewards.
- Shared modules in src/shared must not depend on server-only services.
- No hardcoded credentials, Roblox API keys, webhook tokens, or personal data in Git.
- Don't insert arbitrary toolbox/free models without reviewing scripts and asset rights.
- No new dependency/framework unless task scope justifies it and the team agrees.

## Collaboration rules
- First inspect git status and the relevant files. Never overwrite unrelated work.
- One agent per focused task and feature branch. Assign file ownership/area in the task description.
- Don't edit main directly, force-push, merge or publish without explicit authorization.
- Keep changes small and reviewable. Document API/event changes and migration needs.
- For overlapping edits, coordinate through GitHub PRs; do not silently resolve conflicts by replacing another teammate's work.
- Avoid destructive filesystem operations, deleting Studio instances, mass asset insertion, or live DataStore writes without explicit authorization and backup.

## Studio MCP / Rojo guardrails
- Confirm the active Studio instance and place before ANY Studio mutation.
- Prefer a local test copy for MCP mutations; back up the place first.
- Use Studio MCP for inspecting, creating art/prototypes, and playtesting; use Git + Rojo for permanent Luau edits.
- Never modify the same managed script simultaneously through MCP/Studio and Rojo.
- Never publish to the production Roblox experience autonomously.

## Definition of done
- Requirements and affected files are summarized.
- Luau formatted/linted; Rojo project builds if tools are installed.
- Test relevant gameplay in Studio for real Roblox APIs (headless tests alone are insufficient).
- Check keyboard/mouse, touch, 2-player abuse paths when relevant.
- Report test results honestly; say NOT RUN if a tool is missing.
- Update docs/TASK_BACKLOG.md and docs/DECISIONS.md for meaningful changes.
- Handoff: changed files, behavior, tests, remaining risks, and next step.
