# Dependency Upgrade Loop Workflow

## Trigger

Use when upgrading dependencies, changing package managers, resolving install failures, updating runtimes, or fixing environment drift.

## Ordered Skills

1. `dependency-environment-management`
2. Subagent: `dependency-auditor`
3. `source-driven-development`
4. Subagent: `ci-pipeline-reviewer`
5. Subagent: `validation-runner`
6. Subagent: `security-reviewer`
7. `pull-request-prep`

## Phase Outputs

- Dependency surface map with manifests, lockfiles, runtime pins, and CI setup.
- Upgrade or environment plan with compatibility risks.
- Main-agent dependency change, if approved and scoped.
- CI pipeline review for cache, matrix, and install behavior.
- Validation and security findings for upgraded packages or runtime changes.

## Validation Gates

- Manifest and lockfile changes are consistent.
- Runtime versions match setup docs and CI config.
- Install, test, lint, and build commands are validated or explicitly deferred.
- Security-sensitive upgrades or new packages receive review.

## Handoff Format

Report dependency changes, runtime changes, lockfile impact, validation commands, CI implications, security findings, and rollback plan.

## Escalation Rules

- Escalate when dependency changes require license, security, or product approval.
- Escalate when private registries, credentials, or unavailable platforms block validation.
- Escalate when forceful cache clearing or environment mutation is required.
