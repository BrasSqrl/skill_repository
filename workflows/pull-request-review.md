# Pull Request Review Workflow

## Trigger

Use when reviewing a diff, branch, pull request, patch set, or pending merge package.

## Ordered Skills

1. `context-engineering`
2. `code-review-and-quality`
3. `security-review` when auth, secrets, input handling, data access, dependencies, or permissions are touched
4. `architecture-review` when boundaries, cross-cutting design, or major dependencies change
5. `pull-request-prep`

## Phase Outputs

- Change scope summary.
- Findings ordered by severity with file and line references.
- Missing validation or test gaps.
- Merge readiness recommendation.

## Phase Transitions

- Entry condition: start after the trigger applies and required inputs are available or blockers are recorded.
- Phase completion signal: each ordered phase produces its listed phase output or a documented blocker.
- Next phase trigger: move forward only after the previous phase output is reviewed and required gates for that point are satisfied.
- Stop condition: stop when the final handoff output is complete, validation gates pass or are explicitly blocked, and escalation rules have been checked.
- Retry limit: revise a failed phase only while new evidence, a narrower scope, or an approved direction change can alter the result; otherwise escalate.
- Escalation condition: escalate when required inputs, permissions, validation evidence, or approval boundaries are missing or contradictory.

## Validation Gates

- Findings describe concrete failure modes, not style preferences.
- Each blocking issue includes reproduction or reasoning from source context.
- Security and architecture concerns are clearly separated from ordinary maintainability notes.
- The final summary does not hide open risks.

## Context Continuity

Treat this workflow as long-running when it spans multiple phases, uses subagents, runs validation, revises artifacts, changes multiple files, or may continue across turns. Create a checkpoint before starting a new phase, after major validation output, before large edits, when harness context warnings appear, or when context pressure is noticeable.

Use `handoff` when available and run `handoff-quality-review` before ending or transferring work. Save handoff artifacts outside the repository by default unless this workflow already defines generated-output artifacts or the user requests project-local state.

The checkpoint must include workflow name and current phase, objective and success criteria, completed and pending steps, files inspected or changed, commands run and validation results, decisions, assumptions, blockers, risks, exact next action, and recommended skills or subagents for continuation.

## Handoff Format

List findings first, then open questions, validation reviewed, and concise change summary.

## Escalation Rules

- Ask for target branch or diff source if not discoverable.
- Escalate if a finding depends on policy or risk tolerance outside the repo.
- Do not rewrite the implementation unless explicitly asked after review.
