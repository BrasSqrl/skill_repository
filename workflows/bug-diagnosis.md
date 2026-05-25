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

## Handoff Format

Report the failing symptom, root cause, fix, regression test, validation commands, and unresolved risks.

## Escalation Rules

- Escalate when failure requires unavailable credentials, services, data, or hardware.
- Stop speculative edits after two failed hypotheses and collect more evidence.
- Ask for priority when multiple unrelated failures appear.
