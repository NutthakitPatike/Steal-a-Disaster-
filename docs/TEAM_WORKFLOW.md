# Four-person team + Codex workflow

Assumption: one founder and three friends = four humans. Assign actual names later. Everyone can run Codex, but an AI is a helper, not a shared source of truth.

## Suggested responsibilities (initial)
- **Owner A — Producer / Integrator:** game design decisions, architecture, merges, releases, metrics, and conflict resolution.
- **Owner B — Server gameplay:** plot ownership, server-side steal rules, rewards, secure RemoteEvents, persistence.
- **Owner C — Client/UI:** onboarding, HUD, mobile controls, audio/visual feedback, UX tests.
- **Owner D — World/art & QA:** map greybox, models/animations, performance and multiplayer test cases, media captures.

Ownership is about review responsibility, not forbidding help from other teammates. Each task identifies an owner, reviewers, and touched paths.

## Pull request flow
1. Take one small task from docs/TASK_BACKLOG.md or GitHub Issues.
2. Make a feature branch: `feat/short-name`, `fix/short-name`, or `docs/short-name`.
3. Send Codex task prompt with acceptance criteria and affected paths.
4. Agent inspects AGENTS.md + docs, then implements only agreed scope.
5. Local check: format, lint, Rojo build, Studio playtest when necessary.
6. Open a PR describing What/Why/Tests/Risks; request at least one human review.
7. Integrator merges after conflicts and blocked tests are resolved.

Only the designated integrator may push deployment/publish changes. Branch protection is configured in GitHub after the remote is created.

## Avoiding collision
- Do not share a physical local folder among four independent agents.
- Each person clones the same GitHub repository to their own computer.
- One feature branch per active task. On one machine, use separate Git worktrees if running multiple agents.
- Code: Git + Rojo is authoritative. Scene/3D: Studio Team Create is authoritative for approved art edits, with explicit ownership per zone/model.
- **Never use two writers** on the same Rojo-managed script (Studio MCP + external editor) at the same time.
- For large world changes, coordinate one person per scene/zone and export a place backup before merging updates.

## Coordination rhythm (lightweight)
- 10-minute asynchronous check-in daily: Yesterday / Today / Blocker.
- Weekly: latest playable demo, retention/performance discussion, next 3 priorities.
- Stop adding features when the first minute of the game is not yet fun.

## Studio + shared place
- Use a private test place / staging experience. Do not connect experimental AI changes to production.
- Enable group collaboration, assign permissions, and confirm age-check requirements with Roblox Creator Hub.
- Back up a downloadable place copy before changing many objects. A Git PR does NOT back up untracked Studio-only assets.

## Code review: minimum acceptance
- Server validates requests and prevents free currency/items.
- UI works with touch input, not only keyboard/mouse.
- No undisclosed Toolbox scripts or unlicensed copied assets.
- No unexplained data migration or broad directory rewrite.
