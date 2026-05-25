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

## Validation Gates

- Required test, lint, build, and packaging commands are run or explicitly marked unavailable.
- Versioning and changelog state are checked when present.
- Migration and rollback paths are documented when relevant.
- Known risks are specific enough for a release owner to act on.

## Handoff Format

Report release scope, validation evidence, changed release artifacts, rollback notes, known risks, and final readiness state.

## Escalation Rules

- Stop when release credentials, production access, or approval is required.
- Escalate if validation cannot be completed in the current environment.
- Defer feature additions during release prep unless needed to unblock release integrity.
