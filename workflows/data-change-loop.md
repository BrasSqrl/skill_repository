# Data Change Loop Workflow

## Trigger

Use when changing schemas, migrations, indexes, data access, ETL, seeds, fixtures, analytics queries, or data backfills.

## Ordered Skills

1. `database-data-workflow-development`
2. `source-driven-development`
3. Subagent: `database-migration-reviewer`
4. Subagent: `security-reviewer`
5. Subagent: `validation-runner`
6. Subagent: `release-reviewer`
7. `pull-request-prep`

## Phase Outputs

- Data surface summary with affected schemas, migrations, queries, and workflow commands.
- Main-agent migration or data workflow implementation.
- Independent migration review covering rollback, destructive operations, deploy ordering, and indexes.
- Security review for sensitive fields, retention, access, and logging risks.
- Release notes for migration order, rollback, and manual checks.

## Phase Transitions

- Entry condition: start after the trigger applies and required inputs are available or blockers are recorded.
- Phase completion signal: each ordered phase produces its listed phase output or a documented blocker.
- Next phase trigger: move forward only after the previous phase output is reviewed and required gates for that point are satisfied.
- Stop condition: stop when the final handoff output is complete, validation gates pass or are explicitly blocked, and escalation rules have been checked.
- Retry limit: revise a failed phase only while new evidence, a narrower scope, or an approved direction change can alter the result; otherwise escalate.
- Escalation condition: escalate when required inputs, permissions, validation evidence, or approval boundaries are missing or contradictory.

## Validation Gates

- Migration ordering and rollback expectations are explicit.
- Destructive data changes require documented approval.
- Query and index changes have targeted validation or a stated manual check.
- Release readiness includes data migration and rollback notes.

## Context Continuity

Treat this workflow as long-running when it spans multiple phases, uses subagents, runs validation, revises artifacts, changes multiple files, or may continue across turns. Create a checkpoint before starting a new phase, after major validation output, before large edits, when harness context warnings appear, or when context pressure is noticeable.

Use `handoff` when available and run `handoff-quality-review` before ending or transferring work. Save handoff artifacts outside the repository by default unless this workflow already defines generated-output artifacts or the user requests project-local state.

The checkpoint must include workflow name and current phase, objective and success criteria, completed and pending steps, files inspected or changed, commands run and validation results, decisions, assumptions, blockers, risks, exact next action, and recommended skills or subagents for continuation.

## Handoff Format

Report data surface changed, migrations added, rollback path, validation commands, review findings, deployment order, and remaining operational risks.

## Escalation Rules

- Escalate irreversible migrations, backfills, or data loss risk.
- Escalate when deploy sequencing depends on infrastructure, manual operations, or unavailable credentials.
- Escalate when sensitive data exposure or retention behavior changes.
