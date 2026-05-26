# Azure DevOps PR Lifecycle Workflow

## Trigger

Use when creating, updating, submitting, validating, auto-completing, or completing an Azure Repos pull request through Azure DevOps.

## Ordered Skills

1. `context-engineering`
2. `source-driven-development`
3. `incremental-implementation` when code changes are needed
4. `azure-devops-pr-lifecycle`
5. `azure-boards-work-item-management` when work items must be created, updated, or linked
6. `azure-pipelines-validation`
7. Subagent: `azure-devops-pr-reviewer`
8. `release-readiness` before completion or auto-complete
9. `handoff-quality-review`

## Phase Outputs

- PR scope, source branch, target branch, linked work items, and allowed PR actions.
- Commit and push summary for intended changes only.
- PR title, description, reviewers, work item links, and policy status.
- Validation evidence from local commands and Azure policy or pipeline checks.
- Completion decision with blockers, accepted risks, and manual follow-up.

## Validation Gates

- Working tree and branch state are understood before commit or push.
- PR title, description, target branch, reviewers, and linked work items match repo instructions.
- Required local validation and Azure branch policies pass before completion or auto-complete.
- `--bypass-policy` is not used unless explicitly authorized for the current task.
- Work item state transitions and source-branch deletion match target repo policy.

## Context Continuity

Treat this workflow as long-running when it spans multiple phases, uses subagents, runs validation, revises artifacts, changes multiple files, or may continue across turns. Create a checkpoint before starting a new phase, after major validation output, before large edits, when harness context warnings appear, or when context pressure is noticeable.

Use `handoff` when available and run `handoff-quality-review` before ending or transferring work. Save handoff artifacts outside the repository by default unless this workflow already defines generated-output artifacts or the user requests project-local state.

The checkpoint must include workflow name and current phase, objective and success criteria, completed and pending steps, files inspected or changed, commands run and validation results, decisions, assumptions, blockers, risks, exact next action, and recommended skills or subagents for continuation.

## Handoff Format

Report PR ID and URL, branch pair, commits pushed, work items changed or linked, reviewers, validation commands, policy state, completion state, blockers, and exact next action.

## Escalation Rules

- Ask before completing, auto-completing, voting, bypassing policy, deleting source branches, or transitioning work items unless target repo instructions explicitly authorize the action.
- Escalate missing Azure DevOps credentials, protected logs, unresolved comments, merge conflicts, failed policies, or ambiguous reviewer authority.
- Do not proceed with completion when security, data, release, or compliance risks remain unresolved.
