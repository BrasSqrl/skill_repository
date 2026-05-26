---
name: debugging-and-error-recovery
description: Diagnose and recover from failing software behavior by reproducing errors, narrowing scope, forming hypotheses, instrumenting carefully, fixing the cause, and adding regression verification. Use when tests fail, builds break, runtime errors appear, or a user reports broken behavior.
---

# Debugging And Error Recovery

## Purpose

Convert failing behavior into a reproducible case, identify the first confirmed cause, apply the smallest fix, and prove the failure is resolved.

## When to Use

- Use when tests, builds, type checks, linters, or runtime flows fail.
- Use when an error message, stack trace, crash, or incorrect behavior is reported.
- Use when a previous fix attempt failed or made the state confusing.
- Use when recovery requires separating symptoms from root cause.

## When Not to Use

- Do not use for planned feature work without a failure signal.
- Do not use to rewrite a subsystem before reproducing the problem.
- Do not assume the newest error is the root cause without checking.

## Required Inputs

- Exact error text, logs, failing command, or reproduction steps.
- Current worktree state and recent relevant changes.
- Expected behavior and observed behavior.
- Focused validation command, using Windows command form first and Linux equivalent when useful.
- Environment details that affect reproduction.

## Permitted Actions

- Run reproduction, targeted tests, logs, and inspection commands needed to isolate the failure.
- Add temporary instrumentation only to answer a stated hypothesis, then remove it before completion.
- Edit code only after the failure boundary and likely cause are grounded in evidence.

## Workflow

1. Reproduce the failure or identify why it cannot be reproduced.
2. Capture the exact command, input, output, and error boundary.
3. Reduce the problem to the smallest failing path.
4. Inspect relevant code, tests, configuration, and recent diffs.
5. Form one or more concrete hypotheses tied to evidence.
6. Add temporary instrumentation only when it will answer a specific question.
7. Implement the smallest fix for the confirmed cause.
8. Add or update regression coverage when practical.
9. Rerun the failing command and any affected broader validation.
10. Remove temporary diagnostics before finishing.

## Stop Condition

- Stop successfully when the failing path passes, the cause and fix are documented, and regression validation exists or is explicitly deferred.
- Stop blocked when reproduction is impossible, required systems are unavailable, or the observed behavior conflicts with the source of truth.

## Quality Gates

- The failure is reproduced or the inability to reproduce is documented.
- The fix is tied to a confirmed cause, not just a symptom.
- Regression validation exists or a reason is stated.
- Temporary logging, debug flags, and probes are removed.
- Final report includes the before and after validation evidence.
- The output contract separates failure, cause, fix, before evidence, and after evidence.

## Anti-Patterns

- Guessing fixes without reproducing.
- Changing multiple unrelated variables at once.
- Hiding the error by catching or suppressing it.
- Leaving noisy diagnostics in production code.
- Treating flaky behavior as fixed after one lucky pass.

## Output Format

```markdown
Diagnosis:
- Failure:
- Cause:
- Fix:

Changed Files:
- 

Validation:
- Before:
- After:

Follow-Up Risk:
- 
```

## References

- `references/diagnosis-decision-tree.md`: Use when a failure has multiple possible causes, noisy logs, or repeated unsuccessful fix attempts.
