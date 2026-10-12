# Roblox Create

Minimal Rojo + Luau starter for a three-person Roblox development team. The game title **Steal a Disaster** is provisional. There is no playable game in the repository yet.

## Team
All three people collaborate in [NutthakitPatike/Steal-a-Disaster-](https://github.com/NutthakitPatike/Steal-a-Disaster-) through personal GitHub accounts, feature branches and reviewed pull requests. The **Head** uses **ChatGPT + lnwjud MCP** and approves releases; two teammates use **Codex**. Teammates may also edit assigned zones/models in Roblox Studio, then export the change into Git. See [docs/TEAM_WORKFLOW.md](docs/TEAM_WORKFLOW.md) and [docs/STUDIO_MCP.md](docs/STUDIO_MCP.md).

## Teammate quick start — once the Head has pushed `main`

1. Ask the Head for your **assigned task/Issue**, your own GitHub **Write** access, and edit permission for the correct Roblox **staging place** if your task involves Studio.
2. Clone the repository into **your own directory**, open it in Codex (or your preferred AI), and have the AI read `AGENTS.md`, `docs/TEAM_WORKFLOW.md`, `docs/GAME_VISION.md`, `CURRENT_STATE.md` and the actual files for your assigned task.
3. Before working, check your branch/status and make a separate feature branch:

```powershell
git clone https://github.com/NutthakitPatike/Steal-a-Disaster-.git
cd Steal-a-Disaster-
git switch main
git pull --ff-only origin main
git switch -c feat/zone1-greybox
```

Use a new task-specific branch name instead of `feat/zone1-greybox` when working on another Issue. Never have multiple AIs edit a shared checkout at once.
4. Work **only on your assigned files/Studio zone**. Test what you change; never claim a passed Studio test if no Studio session was connected. Push only your feature branch; open a Pull Request against `main`. Another human reviews it before merge.
5. After merge, update your local `main` and start a fresh feature branch for the next Issue.

**Different AIs are fine:** GitHub, source-controlled instructions, a named task owner and a verified PR are the common contract. We do not require identical Codex/ChatGPT tools, private AI chat memory or matching skill installations. See [docs/TEAM_WORKFLOW.md](docs/TEAM_WORKFLOW.md) for a copyable task brief and [docs/STUDIO_MCP.md](docs/STUDIO_MCP.md) for Studio work.

**Repository status (2026-10-13):** `main` is seeded on the **public** GitHub repository. The two teammate invitations and GitHub-enforced `main` protection still need configuring; only the Head currently has verified access. Teammates should wait for their own GitHub Write access before pushing.

## Verified structure
- `src/server/Bootstrap.server.luau`: server-side startup message.
- `src/client/Bootstrap.client.luau`: client-side startup message.
- `src/shared/Config.luau`: working title and prototype version.
- `default.project.json`: maps source folders into ServerScriptService, StarterPlayerScripts and ReplicatedStorage using Rojo.
- 3D Workspace/maps are not managed by the current Rojo configuration.
- `rokit.toml`: declares Rojo, Selene, StyLua and Wally versions. Declared does not mean installed.

## Set up each development computer
1. Install Roblox Studio and Git; Codex is needed only for teammates who use it.
2. Install [Rokit](https://github.com/rojo-rbx/rokit) from its official release instructions.
3. From the repository, run `rokit install`.
4. Run `rojo plugin install` if the Studio plugin is not already installed.
5. Run `rojo serve default.project.json` and connect the Rojo plugin in a **local test place**, not a production place.
6. Check tools with `stylua --check src`, `selene src` and `rojo build default.project.json -o build/prototype.rbxlx`.

The commands above are the intended workflow. **They have not passed on the inspected Head machine:** Rokit, Rojo, Selene and StyLua were not in PATH on 2026-10-12. Do not claim a valid game build until the commands run.

## Studio MCP and skill setup
See [docs/STUDIO_MCP.md](docs/STUDIO_MCP.md) for ChatGPT/lnwjud and Codex routes. Available local skill names include pstack's `poteto-mode`, `ponytail`, and task-specific `roblox-*`; [AGENTS.md](AGENTS.md) defines when to use them. Each contributor must check their own setup. Do not copy third-party plugin code into Git.

## Source of truth
Read [AGENTS.md](AGENTS.md) first; [CURRENT_STATE.md](CURRENT_STATE.md) holds the latest verified checkpoint. Game idea: [docs/GAME_VISION.md](docs/GAME_VISION.md). Map direction for team review: **one long connected route, Zone 1 → Zone 2 → Zone 3 → ...**, with admin event spawns inside the target Zone. See [docs/MAP_CONCEPT.md](docs/MAP_CONCEPT.md) v2 ([top-down SVG](docs/assets/map-concept-v1.svg)). The original seven starting-area boxes are **not confirmed player plots**. Unverified decisions remain open.
