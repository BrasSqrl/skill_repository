---
name: diagnose
description: Run an intensive diagnosis loop for hard bugs, flaky failures, and performance regressions. Use when the user explicitly asks to diagnose or debug a difficult issue, when simpler debugging has failed, or when a fast deterministic feedback loop must be built before fixing.
---

# Diagnose

## Purpose

Build a reliable feedback loop for difficult failures, then use hypotheses and targeted probes to confirm the cause before fixing.

## When to Use

- Use when the user says to diagnose, debug deeply, or investigate a hard failure.
- Use when a bug is flaky, performance-related, or not reproducible yet.
- Use when previous fixes failed or there is no trusted pass/fail signal.
- Use when `debugging-and-error-recovery` is too lightweight for the problem.

## When Not to Use

- Do not use for simple, already-localized errors.
- Do not use for feature implementation without a failure signal.
- Do not hypothesize without first trying to build a feedback loop.

## Required Inputs

- Reported symptom, failing command, trace, log, benchmark, or reproduction notes.
- Expected behavior and observed behavior.
- Environment details that may affect reproduction.
- Relevant code, tests, recent changes, and validation commands.
- Approval before risky instrumentation or destructive operations.

## Workflow

1. Build the fastest reliable feedback loop available: test, CLI, HTTP script, browser script, replay, harness, fuzz loop, or benchmark.
2. Confirm the loop reproduces the user's failure, not a nearby unrelated failure.
3. Minimize the failing path until it is fast enough for repeated runs.
4. List three to five ranked, falsifiable hypotheses.
5. Probe one hypothesis at a time with targeted instrumentation or measurement.
6. Convert the minimized failure into regression coverage when a correct test seam exists.
7. Apply the smallest fix for the confirmed cause.
8. Rerun the minimized loop and the original scenario.
9. Remove temporary instrumentation and summarize the confirmed cause.

## Quality Gates

- A feedback loop exists, or the inability to build one is documented.
- Hypotheses are falsifiable and ranked.
- Probes are tied to hypotheses.
- The original failure path is verified after the fix.
- Regression coverage exists, or the missing seam is recorded as follow-up.

## Anti-Patterns

- Guessing fixes before reproducing.
- Testing multiple hypotheses with one broad change.
- Logging everything instead of probing a boundary.
- Treating one lucky pass as proof for flaky behavior.
- Leaving debug logs or throwaway harnesses behind.

## Output Format

```markdown
Diagnosis:
- Feedback loop:
- Confirmed failure:
- Cause:
- Fix:

Validation:
- Before:
- After:

Cleanup:
- 

Follow-Up:
- 
```

## References

- `scripts/hitl-loop.template.sh`: Use only as a last resort when a human-in-the-loop reproduction must be structured.
