# Release Gate Loop Workflow

## Trigger

Use before tagging, publishing, deploying, or handing off a release candidate that includes code, data, dependency, documentation, or automation changes.

## Ordered Skills

1. `release-readiness`
2. Subagent: `validation-runner`
3. Subagent: `ci-pipeline-reviewer`
4. Subagent: `documentation-reviewer`
5. Subagent: `security-reviewer`
6. Subagent: `release-reviewer`
7. `handoff-quality-review`

## Phase Outputs

- Release scope, included changes, and excluded work.
- Validation evidence from local and CI-equivalent checks.
- CI, documentation, security, migration, rollback, and known-risk review notes.
- Release decision record with blockers, accepted risks, and follow-up work.
- Handoff that another agent can use to continue or publish.

## Validation Gates

- Required checks pass or are explicitly documented with accepted risk.
- Release notes, setup docs, examples, and migration notes match the release scope.
- Rollback or recovery path is documented for risky changes.
- Security, data, and CI findings are resolved or escalated before release approval.

## Context Continuity

Treat this workflow as long-running when it spans multiple phases, uses subagents, runs validation, revises artifacts, changes multiple files, or may continue across turns. Create a checkpoint before starting a new phase, after major validation output, before large edits, when harness context warnings appear, or when context pressure is noticeable.

Use `handoff` when available and run `handoff-quality-review` before ending or transferring work. Save handoff artifacts outside the repository by default unless this workflow already defines generated-output artifacts or the user requests project-local state.

The checkpoint must include workflow name and current phase, objective and success criteria, completed and pending steps, files inspected or changed, commands run and validation results, decisions, assumptions, blockers, risks, exact next action, and recommended skills or subagents for continuation.

## Handoff Format

Report release candidate, version or tag target, validation matrix, blockers, accepted risks, rollback notes, documentation status, and final recommendation.

## Escalation Rules

- Escalate any blocker that could cause data loss, security exposure, failed deployment, or unrecoverable release state.
- Escalate when release authority or versioning policy is unclear.
- Do not publish, deploy, or tag unless explicitly authorized by the user or repo instructions.
