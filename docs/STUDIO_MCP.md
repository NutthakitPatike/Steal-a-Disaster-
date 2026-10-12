# Roblox Studio MCP — Head and teammates

Two supported working paths; do not assume the Head uses Codex.

## Head: ChatGPT + lnwjud MCP
- Project workspace: `D:\Roblox\Create`.
- Use lnwjud workspace/Git tools for files and Git; do not edit repository text through shell commands.
- lnwjud can inspect/discover local MCP servers. The last observed lnwjud server list did **not** include a standalone Roblox Studio server. This does not prove Studio MCP is unavailable to another client.
- For Studio operations, first discover a supported Studio bridge. Confirm connection, identify exact Studio place/instance, inspect its state, then edit only a test place.
- If there is no usable Studio bridge through lnwjud, report the block. Do not describe Codex MCP registration as a successful ChatGPT–Studio connection.

## Teammates: Codex + official Roblox Studio MCP
1. Open a local TEST place in Roblox Studio.
2. In Studio Assistant's MCP management panel, enable **Studio as MCP server** and use the Codex quick-connect flow, if available.
3. In Codex, confirm the MCP entry and then list/inspect Studio instances. **Enabled configuration alone does not prove a live connection**.
4. Perform a reversible test in a throwaway place, read it back and check playtest/errors.

Official documentation: https://create.roblox.com/docs/studio/mcp

## Rojo vs MCP
- Rojo synchronizes Git-managed `src/` scripts to Studio.
- Studio MCP can inspect or change live scenes and run playtests.
- Do not allow both to write the same script concurrently.
- Before a destructive Studio edit, confirm target place and take a backup.
- Studio's Team Create and cloud publishing are **separate from GitHub**. A collaborator needs Roblox Studio edit permissions **as well as** GitHub repository access.
- Scene workflow: edit an assigned zone/model in Studio → export its source as `studio/exports/<feature>.rbxmx` → commit/push a feature branch → review PR → merge → import/reconcile into a shared staging place and playtest. Export only material you own or are licensed to redistribute.
- A Studio-authored Script that is meant to be Rojo-managed must be transferred into `src/` and tested through Rojo; do not let Studio and Rojo overwrite each other.
- For a full `.rbxlx` backup or binary `.rbxm` export, plan a controlled snapshot and Git LFS with the whole team rather than committing uncontrolled binary files.
- Never publish a live experience or modify a production DataStore through an unattended agent.
