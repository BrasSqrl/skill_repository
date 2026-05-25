# Backend Change Loop Workflow

## Trigger

Use when changing backend services, APIs, request handling, authorization hooks, background jobs, integrations, or server-side contracts.

## Ordered Skills

1. `context-engineering`
2. `api-backend-development`
3. `api-contract-testing`
4. Subagent: `api-contract-reviewer`
5. Subagent: `security-reviewer`
6. Subagent: `validation-runner`
7. Subagent: `code-reviewer`
8. `pull-request-prep`

## Phase Outputs

- Backend surface map with handlers, services, tests, schemas, and commands.
- Main-agent implementation plan and scoped code changes.
- Contract compatibility review for API-facing behavior.
- Security review for auth, input handling, data exposure, and unsafe defaults.
- Validation evidence from tests, lint, build, or contract checks.

## Validation Gates

- Contract changes are intentional and documented.
- Backward compatibility, error shapes, and status codes are reviewed.
- Security-sensitive behavior receives explicit review.
- Validation covers the modified backend path and contract boundary.

## Handoff Format

Report API or service behavior changed, contract impact, security findings, validation commands, files changed, and unresolved release risks.

## Escalation Rules

- Escalate breaking API changes without documented migration or versioning intent.
- Escalate auth, permission, secret, or sensitive-data findings.
- Escalate when validation requires unavailable services, queues, databases, or credentials.
