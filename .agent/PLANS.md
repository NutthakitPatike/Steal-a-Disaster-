# Execution plan policy

The project expects work across multiple people and AI sessions. **Do not create a plan for every change.** A small bug fix, short document update, or single-file improvement uses a scoped issue or PR.

## Create a task-specific plan when
- Work spans multiple systems, owners or sessions.
- A risky change affects DataStores, remotes, gameplay economy, monetization or publishing.
- A feature requires staged delivery with independent playtest gates or rollback.
- The Head requests a multi-phase task.

Use `.agent/plans/<task-id>.md` only when needed. No active execution plan has been created yet.

## Minimum contents
- Objective and exact desired player-facing behavior.
- Verified context, affected files and owners.
- Constraints, explicit non-goals and unsafe actions to avoid.
- Implementation stages; each ends in a checkable artifact.
- Acceptance criteria and verification commands or Studio test method.
- Progress (done / pending), evidence, failures and blockers.
- Decisions and changes to scope.
- Rollback plan **only if** the change can damage data, published assets or live player state.

Keep a plan factual and short. Do not copy the full project backlog or rewrite [../CURRENT_STATE.md](../CURRENT_STATE.md). The Head approves changes to project direction and production release. Close the plan with a task handoff in [../docs/TEAM_WORKFLOW.md](../docs/TEAM_WORKFLOW.md)'s format.
