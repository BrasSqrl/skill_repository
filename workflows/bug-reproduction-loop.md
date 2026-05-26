# Bug Reproduction Loop Workflow

## Trigger

Use when a bug report, failing test, runtime error, CI failure, or flaky symptom needs a reliable reproduction before implementation.

## Ordered Skills

1. `error-message-triage`
2. `context-engineering`
3. Subagent: `bug-reproducer`
4. `debugging-and-error-recovery`
5. Subagent: `validation-runner`
6. `pull-request-prep`

## Phase Outputs

- First actionable failure with unrelated noise excluded.
- Minimal reproduction command, input, file, or scenario.
- Confirmed facts, hypotheses, and blocked reproduction notes.
- Root cause and fix plan owned by the main agent.
- Regression validation evidence after the main agent implements the fix.

## Phase Transitions

- Entry condition: start after the trigger applies and required inputs are available or blockers are recorded.
- Phase completion signal: each ordered phase produces its listed phase output or a documented blocker.
- Next phase trigger: move forward only after the previous phase output is reviewed and required gates for that point are satisfied.
- Stop condition: stop when the final handoff output is complete, validation gates pass or are explicitly blocked, and escalation rules have been checked.
- Retry limit: revise a failed phase only while new evidence, a narrower scope, or an approved direction change can alter the result; otherwise escalate.
- Escalation condition: escalate when required inputs, permissions, validation evidence, or approval boundaries are missing or contradictory.

## Validation Gates

- Reproduction is captured before code changes begin.
- Reproduction command and exit code are recorded exactly.
- The main agent fixes the cause, not only the symptom.
- Regression validation uses the smallest useful test plus broader checks when needed.

## Context Continuity

Treat this workflow as long-running when it spans multiple phases, uses subagents, runs validation, revises artifacts, changes multiple files, or may continue across turns. Create a checkpoint before starting a new phase, after major validation output, before large edits, when harness context warnings appear, or when context pressure is noticeable.

Use `handoff` when available and run `handoff-quality-review` before ending or transferring work. Save handoff artifacts outside the repository by default unless this workflow already defines generated-output artifacts or the user requests project-local state.

The checkpoint must include workflow name and current phase, objective and success criteria, completed and pending steps, files inspected or changed, commands run and validation results, decisions, assumptions, blockers, risks, exact next action, and recommended skills or subagents for continuation.

## Handoff Format

Report failure symptom, minimal reproduction, root cause, changed files, validation commands, validation results, and unresolved risks.

## Escalation Rules

- Escalate when reproduction requires credentials, unavailable services, private data, or destructive setup.
- Pause implementation when no reliable reproduction exists and additional evidence is required.
- Escalate when multiple unrelated failures appear and priority is unclear.
