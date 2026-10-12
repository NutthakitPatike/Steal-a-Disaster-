# Roblox Studio MCP + Codex

## Preferred: Roblox Studio built-in MCP (official)
Roblox Studio already includes an MCP server, capable of reading the live game tree, editing Studio objects, running Luau, inspecting errors, and playtesting. It is **not** the same thing as Rojo.

**On EACH teammate's machine:**
1. Update Roblox Studio and open a local TEST place.
2. In Roblox Studio, open Assistant → ... → Manage MCP Servers.
3. Enable **Studio as MCP server**.
4. Under **Quick connect**, enable **Codex CLI** / ChatGPT (codex), whichever is shown on that machine.
5. Restart Codex if requested; check the green connected-client indicator in Studio.
6. Ask Codex to list Studio instances and inspect (READ ONLY) the current place. Confirm the correct place before any write.
7. Test creating a disposable Part in a local test place, playtest, then delete it with the user's authorization.

Official install/quick connect reference:
- https://create.roblox.com/docs/studio/mcp
- https://github.com/Roblox/roblox-studio-agent-plugin

## If quick connect is not available
Follow the official page's Codex CLI or JSON instructions. On Windows, the bundled Studio bridge generally lives at `%LOCALAPPDATA%\Roblox\mcp.bat`. Do not blindly override existing global MCP settings or use a third-party executable when the built-in server works.

## Rojo != MCP
- **Rojo:** files in `src/` → scripts inside your local Studio test session.
- **MCP:** AI can inspect/playtest/create/edit inside the ACTIVE Studio window.
- Use Rojo + Git for long-lived scripted code. Use MCP mainly for observation, playtesting, 3D prototyping, and controlled edits.
- Never let MCP replace a Rojo-owned script while Rojo sync is active.

## Other possible MCP tools (later, only if needed)
- GitHub MCP: inspect issues/PRs and coordinate reviews (not a substitute for Git).
- Documentation MCP: lookup current Luau/Roblox APIs; verify against Creator Hub docs.
- Avoid installing multiple Studio-control MCP servers simultaneously until the built-in one has been tested.

## Access / security
Studio MCP may modify scripts, objects, and assets. Use trusted clients, test place only, no production publishing or live DataStore writes from an agent. Never put local MCP credentials or API keys in Git.
