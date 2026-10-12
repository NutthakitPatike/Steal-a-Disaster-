# Team workflow, ownership and handoff

## Roles (confirmed vs proposed)
- **Head — CONFIRMED:** user directs the game through ChatGPT + lnwjud MCP and approves integration, major product choices and publishing.
- **Two teammates — CONFIRMED:** each uses Codex; their real names, GitHub IDs, Roblox permissions and exact assignments are UNKNOWN.
- **Proposed assignments (not yet accepted):** Teammate 1 server/gameplay; Teammate 2 client/UI; the Head oversees integration, world/art tasks and QA, delegating work by task as needed. These are not confirmed ownership assignments.

## Source and change boundaries
- Central remote: [NutthakitPatike/Steal-a-Disaster-](https://github.com/NutthakitPatike/Steal-a-Disaster-). All three humans use **their own GitHub accounts**, local clones and feature branches. Never share a GitHub login or one writable working directory.
- One task has one human owner and named touched paths. Others review or coordinate before changing those paths.
- `src/server/`: proposed server owner. `src/client/`: proposed client owner. `src/shared/`, `default.project.json` and shared remotes: cross-team changes require Head review.
- Studio-created maps, models and animations: assign an explicit scene/zone owner before shared editing.
- **All three contributors may commit and push their own branches.** All three may merge **reviewed PRs** into `main` once the repository grants Write access and branch rules allow it. Require at least one other person's review; do not self-approve. The Head reviews changes to shared interfaces, architecture, economy/security and final releases. The Head retains publishing/release approval, but does not have to click Merge on routine reviewed PRs.
- Do not write a Rojo-owned script from Studio MCP while Rojo is syncing that script.

## Different AIs, one shared contract

Each teammate can use Codex, ChatGPT or another assistant, or work manually in Roblox Studio. **The repository and approved Issue/PR, not an AI's private conversation or personal memory, are the source of truth.** Every AI should read `AGENTS.md` on task start, discover actual tool availability, inspect the branch and current code, and follow the same boundaries.

**Task contract:** assign one human owner, one GitHub Issue or backlog ID, expected outcome, permitted files or Studio zone, acceptance tests and reviewer **before** an AI edits anything. A change to a shared module or another person's zone requires coordination in the Issue first. A second AI must not silently take over an active branch; use its own branch or explicitly hand off.

**Copyable first message to any teammate's AI:**

```text
We are one of three developers on Steal a Disaster.
Use this cloned repository as the source of truth. Read AGENTS.md,
docs/TEAM_WORKFLOW.md, docs/GAME_VISION.md and CURRENT_STATE.md.
Inspect git status, main/feature branch and relevant code BEFORE edits.
Human owner: <name>
Assigned Issue/task: <id and goal>
Allowed files/Studio zone: <paths or zone name>
Acceptance evidence: <checks and expected gameplay>

Work only within the assigned scope. Use a fresh feature branch; do
not change another owner's work or alter shared contracts unreviewed.
If Studio work is needed, confirm the staging/test place and export
reviewable models; Studio Save/Publish does not commit to Git.
Report exact tests as PASS/FAIL/NOT RUN, changes, risks and a PR link.
Push only the feature branch. Never push directly to main, force push,
publish the live Roblox game or merge an unreviewed PR.
```

Each teammate should fill the placeholders for their own assignment; do **not** store credentials or personal account tokens in the prompt, repository or Studio exports.

## Task and PR flow
1. Record one bounded task with acceptance criteria, **owner, allowed files/Studio zone and reviewer**, in a GitHub Issue once `main` is pushed (until then use [docs/TASK_BACKLOG.md](TASK_BACKLOG.md)). Mark overlapping tasks before they start; avoid two people editing the same model or shared module.
2. Work on `feat/*`, `fix/*`, or `docs/*` branch.
3. Read [../AGENTS.md](../AGENTS.md) and the relevant source. Use pstack for complex work and ponytail for minimal implementation **if installed in that runtime**.
4. Run applicable checks. Involve Roblox Studio for gameplay/runtime evidence.
5. Push the branch to `origin` and open a PR against `main` with changed files, behavior, tests, risks and Studio export/snapshot links as needed. Another person reviews. A team member with Write access may merge after the relevant approval(s) and checks pass. Use `squash` for a small feature PR unless preserving multiple commits materially helps.
6. After merge, everyone pulls the latest `main` before starting or integrating further work. Do not push directly to `main`; use the PR flow even when GitHub rules are not yet enforced.

## Handoff (one short message or PR comment)
```text
Branch / HEAD:
Owner / scope / touched paths:
Completed:
Verification run (with PASS, FAIL, NOT RUN):
Known risks / blockers / unresolved decisions:
Next action:
```

Use [../CURRENT_STATE.md](../CURRENT_STATE.md) for the verified project-wide checkpoint, not per-agent progress logs. Keep planned work in the backlog or GitHub Issues. Create a task-specific execution plan only when [.agent/PLANS.md](../.agent/PLANS.md) requires it.

## Studio safety
Team members may build **models, zones, terrain and animations in Roblox Studio directly**. Give each area a named owner and use a staging place or isolated test place before sharing. **Studio Save/Publish or Team Create is NOT a Git commit.** Export the changed scene/model to `studio/exports/<zone-or-feature>.rbxmx` (small, reviewable, text-based Roblox model export) on the owning feature branch, commit/push it and link a screenshot or short playtest note in the PR. Keep Rojo-managed scripts in `src/`; if native Studio scripts are needed, move the authored Luau into source control or explicitly review the export to avoid diverging duplicates. Do not casually commit full `.rbxlx` files: deliberate staging-place backups or binary packages need an assigned owner, size review and Git LFS plan. Reimport/reconcile approved exports into the shared staging place after merge; verify the actual result in Studio. Git does not back up unexported Studio objects. No unattended production Publish, DataStore migrations or purchases.
