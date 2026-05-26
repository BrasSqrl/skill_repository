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

## Phase Transitions

- Entry condition: start after the trigger applies and required inputs are available or blockers are recorded.
- Phase completion signal: each ordered phase produces its listed phase output or a documented blocker.
- Next phase trigger: move forward only after the previous phase output is reviewed and required gates for that point are satisfied.
- Stop condition: stop when the final handoff output is complete, validation gates pass or are explicitly blocked, and escalation rules have been checked.
- Retry limit: revise a failed phase only while new evidence, a narrower scope, or an approved direction change can alter the result; otherwise escalate.
- Escalation condition: escalate when required inputs, permissions, validation evidence, or approval boundaries are missing or contradictory.

## Validation Gates

- Manifest and lockfile changes are consistent.
- Runtime versions match setup docs and CI config.
- Install, test, lint, and build commands are validated or explicitly deferred.
- Security-sensitive upgrades or new packages receive review.

## Context Continuity

Treat this workflow as long-running when it spans multiple phases, uses subagents, runs validation, revises artifacts, changes multiple files, or may continue across turns. Create a checkpoint before starting a new phase, after major validation output, before large edits, when harness context warnings appear, or when context pressure is noticeable.

Use `handoff` when available and run `handoff-quality-review` before ending or transferring work. Save handoff artifacts outside the repository by default unless this workflow already defines generated-output artifacts or the user requests project-local state.

The checkpoint must include workflow name and current phase, objective and success criteria, completed and pending steps, files inspected or changed, commands run and validation results, decisions, assumptions, blockers, risks, exact next action, and recommended skills or subagents for continuation.

## Handoff Format

Report dependency changes, runtime changes, lockfile impact, validation commands, CI implications, security findings, and rollback plan.

## Escalation Rules

- Escalate when dependency changes require license, security, or product approval.
- Escalate when private registries, credentials, or unavailable platforms block validation.
- Escalate when forceful cache clearing or environment mutation is required.
