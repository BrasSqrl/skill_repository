---
name: agentic-workflow-runtime
description: Select, execute, gate, pause, resume, and hand off durable agent workflow runs from machine-readable manifests. Use when a software task spans multiple phases, requires evidence before transitions, needs bounded subagent roles, or must survive context loss.
---

# Agentic Workflow Runtime

## Purpose

Run a documented engineering workflow as a durable state machine instead of treating it as a loose checklist. Keep semantic work with the agent while using the bundled script to enforce phase order, evidence gates, retry limits, approval boundaries, and resumable handoffs.

## When to Use

- Use for multi-phase implementation, diagnosis, review, release, delivery, or agent-system work.
- Use when independent validation or review occurs at phase boundaries.
- Use when missing evidence must block progress.
- Use when a task may continue across turns or agents.

## When Not to Use

- Do not use for a small, known, one-step change whose validation is immediate.
- Do not use the runtime as authority for destructive or external actions.
- Do not record secrets, tokens, personal data, or private logs in run evidence.

## Required Inputs

- Task objective and target repository path.
- Selected workflow, or enough task language for routing.
- Project-specific commands and constraints from the target repository.
- Explicit authorization for any phase marked `external-mutation`.
- A durable state location outside the target repository unless the project requires otherwise.

## Permitted Actions

- List and select workflow manifests.
- Start a run, inspect its current phase, and record concise evidence.
- Advance only when all required evidence exists.
- Retry within the declared limit, escalate for input, resume with a resolution, and create a handoff.
- Perform the current phase only within its declared permission and the user's authority.

## Workflow

1. Run `scripts/run-agent-workflow.ps1 -Action Select -Task "<task>"` and inspect the ranked result.
2. Start the selected workflow with `-Action Start`; use an explicit `-Workflow` when routing is ambiguous.
3. Read `current_phase_contract` before acting. Load only the named skill or delegate only to the named subagent.
4. Perform the phase within its permission boundary.
5. Record each required evidence item with `-Action Record`.
6. Run `-Action Advance`. If the gate rejects the transition, supply evidence, retry with new information, or escalate.
7. Generate a handoff before transferring work, at context pressure, or after a blocker.
8. Stop when the state is `completed` and the final handoff is reviewable.

Read `references/runtime-command-reference.md` when operating the runner, recovering a run, or authoring a manifest. Consult `references/workflow-manifest.schema.json` when changing the manifest contract and `references/workflows.tsv` when changing routing.

## Stop Condition

- Stop successfully when every phase is complete, every gate has evidence, and the handoff names validation, risks, and the next authorized action.
- Stop for input when the run is `awaiting-input`.
- Stop and escalate when retry limits are exhausted, authorization is absent, or repository rules conflict with the manifest.

## Quality Gates

- The selected workflow matches the task or was explicitly chosen.
- Every phase transition is performed by the runner and not merely claimed in prose.
- Evidence records are concrete, concise, and free of secrets.
- Subagent work occurs only at declared phase boundaries and within declared permissions.
- External mutations have explicit authorization evidence.
- The final run state and handoff are sufficient to resume without chat history.

## Anti-Patterns

- Advancing by recording placeholders such as `done`, `looks good`, or `N/A` without justification.
- Treating a workflow match as permission to edit, merge, deploy, or modify external systems.
- Running all skills and subagents at once instead of following the current phase contract.
- Repeatedly retrying with no new evidence.
- Storing run state, credentials, or private logs in source control.

## Output Format

```markdown
Agentic Workflow Run:
- Run path:
- Workflow:
- Status:
- Current phase:
- Phase owner and permission:
- Evidence recorded:
- Missing evidence:
- Blockers:
- Exact next action:
```

## References

- `references/runtime-command-reference.md`: Use for commands, state behavior, recovery, and manifest authoring rules.
- `references/workflow-manifest.schema.json`: Use when creating or validating a workflow manifest.
- `references/workflows.tsv`: Use when reviewing or changing workflow routing metadata.
- The workflow-manifests subdirectory under references contains machine-readable contracts for supported workflows; load only the selected manifest.
