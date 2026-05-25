# Bug Diagnosis Workflow

## Trigger

Use when a test fails, build breaks, runtime error appears, regression is reported, or logs show unexplained failure.

## Ordered Skills

1. `error-message-triage`
2. `debugging-and-error-recovery`
3. `source-driven-development`
4. `test-driven-development`
5. `pull-request-prep`

## Phase Outputs

- First actionable failure and any noise deprioritized.
- Minimal reproduction command or scenario.
- Hypothesis list ordered by evidence.
- Root cause with source references.
- Fix plus regression validation.

## Validation Gates

- Reproduction happens before broad changes.
- The fix targets the cause, not only the symptom.
- Regression coverage is added when practical.
- Passing validation is shown with exact commands.

## Context Continuity

Treat this workflow as long-running when it spans multiple phases, uses subagents, runs validation, revises artifacts, changes multiple files, or may continue across turns. Create a checkpoint before starting a new phase, after major validation output, before large edits, when harness context warnings appear, or when context pressure is noticeable.

Use `handoff` when available and run `handoff-quality-review` before ending or transferring work. Save handoff artifacts outside the repository by default unless this workflow already defines generated-output artifacts or the user requests project-local state.

The checkpoint must include workflow name and current phase, objective and success criteria, completed and pending steps, files inspected or changed, commands run and validation results, decisions, assumptions, blockers, risks, exact next action, and recommended skills or subagents for continuation.

## Handoff Format

Report the failing symptom, root cause, fix, regression test, validation commands, and unresolved risks.

## Escalation Rules

- Escalate when failure requires credentials, services, data, or hardware that are not available.
- Stop speculative edits after two failed hypotheses and collect more evidence.
- Ask for priority when multiple unrelated failures appear.
