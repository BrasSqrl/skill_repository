# Azure DevOps Work Item To PR Workflow

## Trigger

Use when turning an Azure Boards work item into implementation context, branch work, validation, pull request creation, and traceable work item updates.

## Ordered Skills

1. `azure-boards-work-item-management`
2. `context-engineering`
3. `planning-and-task-breakdown`
4. `source-driven-development`
5. `incremental-implementation` or `test-driven-development`
6. `pull-request-prep`
7. `azure-devops-pr-lifecycle`
8. `azure-pipelines-validation`
9. Subagent: `azure-devops-pr-reviewer`
10. `handoff-quality-review`

## Phase Outputs

- Work item summary with acceptance criteria, constraints, and open questions.
- Branch naming and implementation plan linked to the work item.
- Code changes and validation evidence.
- PR linked to the work item with reviewer and policy status.
- Work item update summary with changed fields and rationale.

## Phase Transitions

- Entry condition: start after the trigger applies and required inputs are available or blockers are recorded.
- Phase completion signal: each ordered phase produces its listed phase output or a documented blocker.
- Next phase trigger: move forward only after the previous phase output is reviewed and required gates for that point are satisfied.
- Stop condition: stop when the final handoff output is complete, validation gates pass or are explicitly blocked, and escalation rules have been checked.
- Retry limit: revise a failed phase only while new evidence, a narrower scope, or an approved direction change can alter the result; otherwise escalate.
- Escalation condition: escalate when required inputs, permissions, validation evidence, or approval boundaries are missing or contradictory.

## Validation Gates

- Work item requirements are specific enough to implement or blockers are recorded.
- Branch, commits, PR description, and work item links preserve traceability.
- State, assignment, priority, area, iteration, and completion changes are explicitly authorized.
- PR validation passes before completion or work item transition.
- The final update distinguishes completed work from remaining acceptance criteria.

## Context Continuity

Treat this workflow as long-running when it spans multiple phases, uses subagents, runs validation, revises artifacts, changes multiple files, or may continue across turns. Create a checkpoint before starting a new phase, after major validation output, before large edits, when harness context warnings appear, or when context pressure is noticeable.

Use `handoff` when available and run `handoff-quality-review` before ending or transferring work. Save handoff artifacts outside the repository by default unless this workflow already defines generated-output artifacts or the user requests project-local state.

The checkpoint must include workflow name and current phase, objective and success criteria, completed and pending steps, files inspected or changed, commands run and validation results, decisions, assumptions, blockers, risks, exact next action, and recommended skills or subagents for continuation.

## Handoff Format

Report work item IDs, branch, PR ID and URL, implementation summary, changed work item fields, validation evidence, policy state, blockers, and exact next action.

## Escalation Rules

- Ask when the work item lacks acceptance criteria or conflicts with source behavior.
- Escalate before changing backlog state, assignment, priority, area, iteration, or completion fields without authorization.
- Do not create duplicate work items when an existing ID is supplied.
