# GitHub Issue To PR Workflow

## Trigger

Use when turning a GitHub issue into implementation context, branch work, validation, pull request creation, and traceable issue updates.

## Ordered Skills

1. `github-issues-management`
2. `context-engineering`
3. `planning-and-task-breakdown`
4. `source-driven-development`
5. `incremental-implementation` or `test-driven-development`
6. `pull-request-prep`
7. `github-pr-lifecycle`
8. `github-actions-validation`
9. Subagent: `github-pr-reviewer`
10. `handoff-quality-review`

## Phase Outputs

- Issue summary with acceptance criteria, labels, constraints, and open questions.
- Branch naming and implementation plan linked to the issue.
- Code changes and validation evidence.
- PR linked to the issue with reviewer and check status.
- Issue update summary with changed fields and rationale.

## Validation Gates

- Issue requirements are specific enough to implement or blockers are recorded.
- Branch, commits, PR body, and issue links preserve traceability.
- State, assignment, labels, milestone, project, and closing references are explicitly authorized.
- PR validation passes before merge or issue closure.
- The final update distinguishes completed work from remaining acceptance criteria.

## Context Continuity

Treat this workflow as long-running when it spans multiple phases, uses subagents, runs validation, revises artifacts, changes multiple files, or may continue across turns. Create a checkpoint before starting a new phase, after major validation output, before large edits, when harness context warnings appear, or when context pressure is noticeable.

Use `handoff` when available and run `handoff-quality-review` before ending or transferring work. Save handoff artifacts outside the repository by default unless this workflow already defines generated-output artifacts or the user requests project-local state.

The checkpoint must include workflow name and current phase, objective and success criteria, completed and pending steps, files inspected or changed, commands run and validation results, decisions, assumptions, blockers, risks, exact next action, and recommended skills or subagents for continuation.

## Handoff Format

Report issue numbers, branch, PR number and URL, implementation summary, changed issue fields, validation evidence, check state, blockers, and exact next action.

## Escalation Rules

- Ask when the issue lacks acceptance criteria or conflicts with source behavior.
- Escalate before changing issue state, assignment, labels, milestone, project, or closing references without authorization.
- Do not create duplicate issues when an existing ID is supplied.
