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

## Validation Gates

- Reproduction is captured before code changes begin.
- Reproduction command and exit code are recorded exactly.
- The main agent fixes the cause, not only the symptom.
- Regression validation uses the smallest useful test plus broader checks when needed.

## Handoff Format

Report failure symptom, minimal reproduction, root cause, changed files, validation commands, validation results, and unresolved risks.

## Escalation Rules

- Escalate when reproduction requires credentials, unavailable services, private data, or destructive setup.
- Pause implementation when no reliable reproduction exists and additional evidence is required.
- Escalate when multiple unrelated failures appear and priority is unclear.
