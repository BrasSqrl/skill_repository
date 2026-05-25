# Feature Development Workflow

## Trigger

Use when implementing a scoped feature, behavior change, endpoint, UI flow, data workflow, or tool capability.

## Ordered Skills

1. `context-engineering`
2. `source-driven-development`
3. `planning-and-task-breakdown`
4. `test-driven-development` or `incremental-implementation`
5. Domain skill such as `api-backend-development`, `frontend-ui-development`, or `database-data-workflow-development`
6. `pull-request-prep`

## Phase Outputs

- Context summary with relevant files, commands, constraints, assumptions, and open questions.
- Implementation plan with small verifiable slices.
- Code changes scoped to the requested feature.
- Validation evidence from tests, lint, build, or targeted manual checks.
- Review-ready summary with risks and follow-up work.

## Validation Gates

- Existing behavior is preserved unless the request explicitly changes it.
- New behavior is covered by focused tests when the repo has a test path for it.
- Commands are Windows-first with Linux alternatives when documented.
- The final diff excludes unrelated formatting, generated churn, and speculative refactors.

## Handoff Format

Report changed files, behavior implemented, validation commands and results, risks, and remaining manual checks.

## Escalation Rules

- Stop and ask when product behavior is ambiguous and multiple incompatible implementations are plausible.
- Escalate when the required source of truth is missing or contradictory.
- Defer large architecture changes unless needed to deliver the requested feature safely.
