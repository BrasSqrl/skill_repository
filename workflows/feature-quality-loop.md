# Feature Quality Loop Workflow

## Trigger

Use when a scoped feature or behavior change needs test strategy, implementation, validation, and independent review without launching a broad redesign.

## Ordered Skills

1. `source-driven-development`
2. `planning-and-task-breakdown`
3. Subagent: `test-strategist`
4. `incremental-implementation`
5. `test-driven-development`
6. Subagent: `validation-runner`
7. Subagent: `code-reviewer`
8. `pull-request-prep`

## Phase Outputs

- Source-backed requirements and acceptance criteria.
- Small implementation plan with explicit test targets.
- Focused test strategy from `test-strategist`.
- Main-agent implementation and test changes.
- Validation evidence and independent code review findings.

## Validation Gates

- Tests target the changed behavior and are not broader than necessary.
- Implementation stays within planned scope unless new source evidence justifies a change.
- Independent validation runs after implementation.
- Code review findings are resolved, documented as accepted risk, or escalated.

## Context Continuity

Treat this workflow as long-running when it spans multiple phases, uses subagents, runs validation, revises artifacts, changes multiple files, or may continue across turns. Create a checkpoint before starting a new phase, after major validation output, before large edits, when harness context warnings appear, or when context pressure is noticeable.

Use `handoff` when available and run `handoff-quality-review` before ending or transferring work. Save handoff artifacts outside the repository by default unless this workflow already defines generated-output artifacts or the user requests project-local state.

The checkpoint must include workflow name and current phase, objective and success criteria, completed and pending steps, files inspected or changed, commands run and validation results, decisions, assumptions, blockers, risks, exact next action, and recommended skills or subagents for continuation.

## Handoff Format

Report feature behavior, tests added or changed, files changed, validation results, review findings, accepted risks, and follow-up work.

## Escalation Rules

- Escalate when requirements are ambiguous or conflict with existing behavior.
- Escalate when the test strategy requires unavailable systems or disproportionate cost.
- Defer architecture changes that are not required for the requested feature.
