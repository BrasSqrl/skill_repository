# GitHub PR Lifecycle Workflow

## Trigger

Use when creating, updating, reviewing, submitting, validating, enabling auto-merge, or merging a GitHub pull request through GitHub CLI.

## Ordered Skills

1. `context-engineering`
2. `source-driven-development`
3. `incremental-implementation` when code changes are needed
4. `github-pr-lifecycle`
5. `github-issues-management` when issues must be created, updated, linked, or closed by merge
6. `github-actions-validation`
7. Subagent: `github-pr-reviewer`
8. `release-readiness` before merge or auto-merge
9. `handoff-quality-review`

## Phase Outputs

- PR scope, source branch, target branch, linked issues, and allowed PR actions.
- Commit and push summary for intended changes only.
- PR title, body, reviewers, labels, projects, issue links, and check status.
- Validation evidence from local commands and GitHub Actions or status checks.
- Merge decision with blockers, accepted risks, and manual follow-up.

## Validation Gates

- Working tree and branch state are understood before commit or push.
- PR title, body, target branch, reviewers, labels, projects, and linked issues match repo instructions.
- Required local validation and GitHub checks pass before merge or auto-merge.
- Admin bypass, force pushes, and destructive branch actions are not used unless explicitly authorized for the current task.
- Merge method, source-branch deletion, and issue-closing behavior match target repo policy.

## Context Continuity

Treat this workflow as long-running when it spans multiple phases, uses subagents, runs validation, revises artifacts, changes multiple files, or may continue across turns. Create a checkpoint before starting a new phase, after major validation output, before large edits, when harness context warnings appear, or when context pressure is noticeable.

Use `handoff` when available and run `handoff-quality-review` before ending or transferring work. Save handoff artifacts outside the repository by default unless this workflow already defines generated-output artifacts or the user requests project-local state.

The checkpoint must include workflow name and current phase, objective and success criteria, completed and pending steps, files inspected or changed, commands run and validation results, decisions, assumptions, blockers, risks, exact next action, and recommended skills or subagents for continuation.

## Handoff Format

Report PR number and URL, branch pair, commits pushed, issues changed or linked, reviewers, validation commands, check state, merge state, blockers, and exact next action.

## Escalation Rules

- Ask before merging, enabling auto-merge, approving, requesting changes, deleting source branches, or closing issues unless target repo instructions explicitly authorize the action.
- Escalate missing GitHub credentials, protected logs, unresolved comments, merge conflicts, failed checks, or ambiguous reviewer authority.
- Do not proceed with merge when security, data, release, or compliance risks remain unresolved.
