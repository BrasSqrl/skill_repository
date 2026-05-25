# Diagnosis Decision Tree

Use this reference when a failure has noisy output, multiple possible causes, or repeated failed fixes.

## First Branch

1. Can the failure be reproduced?
   - Yes: record the command, input, and exact output.
   - No: identify missing environment, data, timing, or dependency context.
2. Is there a first actionable error?
   - Yes: start there.
   - No: use error-message triage before editing code.
3. Is the failure recent?
   - Yes: inspect recent diffs and dependency changes.
   - No: reduce the path and inspect contracts.

## Hypothesis Test

For each hypothesis, write:

```markdown
Hypothesis:
Evidence for:
Evidence against:
Probe:
Expected result:
```

Only run probes that can change the confidence in a hypothesis.

## Common Failure Modes

- Cascading errors hide the first failure.
- Test data differs from runtime data.
- Environment variables or paths differ across Windows and Linux.
- Dependency versions changed without source changes.
- A catch block hides the real exception.
- A race or cache makes one passing run meaningless.

## Stop Conditions

- Root cause is confirmed and fixed.
- Reproduction remains impossible after checking environment, data, and command context.
- A risky operation would be required without user approval.
