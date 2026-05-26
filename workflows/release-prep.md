# Release Prep Workflow

## Trigger

Use before publishing, deploying, tagging, packaging, or handing off a release candidate.

## Ordered Skills

1. `context-engineering`
2. `release-readiness`
3. `dependency-environment-management`
4. `ci-cd-pipeline-maintenance`
5. `documentation-and-adrs`
6. `pull-request-prep`

## Phase Outputs

- Release scope and included changes.
- Validation checklist with command results.
- Dependency, migration, compatibility, and rollback notes.
- Documentation or changelog updates.
- Release decision: ready, ready with risks, or blocked.

## Phase Transitions

- Entry condition: start after the trigger applies and required inputs are available or blockers are recorded.
- Phase completion signal: each ordered phase produces its listed phase output or a documented blocker.
- Next phase trigger: move forward only after the previous phase output is reviewed and required gates for that point are satisfied.
- Stop condition: stop when the final handoff output is complete, validation gates pass or are explicitly blocked, and escalation rules have been checked.
- Retry limit: revise a failed phase only while new evidence, a narrower scope, or an approved direction change can alter the result; otherwise escalate.
- Escalation condition: escalate when required inputs, permissions, validation evidence, or approval boundaries are missing or contradictory.

## Validation Gates

- Required test, lint, build, and packaging commands are run or explicitly marked not available.
- Versioning and changelog state are checked when present.
- Migration and rollback paths are documented when relevant.
- Known risks are specific enough for a release owner to act on.

## Context Continuity

Treat this workflow as long-running when it spans multiple phases, uses subagents, runs validation, revises artifacts, changes multiple files, or may continue across turns. Create a checkpoint before starting a new phase, after major validation output, before large edits, when harness context warnings appear, or when context pressure is noticeable.

Use `handoff` when available and run `handoff-quality-review` before ending or transferring work. Save handoff artifacts outside the repository by default unless this workflow already defines generated-output artifacts or the user requests project-local state.

The checkpoint must include workflow name and current phase, objective and success criteria, completed and pending steps, files inspected or changed, commands run and validation results, decisions, assumptions, blockers, risks, exact next action, and recommended skills or subagents for continuation.

## Handoff Format

Report release scope, validation evidence, changed release artifacts, rollback notes, known risks, and final readiness state.

## Escalation Rules

- Stop when release credentials, production access, or approval is required.
- Escalate if validation cannot be completed in the current environment.
- Defer feature additions during release prep unless needed to unblock release integrity.
