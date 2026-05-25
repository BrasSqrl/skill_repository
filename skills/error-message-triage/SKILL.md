---
name: error-message-triage
description: Classify and prioritize compiler errors, test failures, stack traces, install errors, linter output, and runtime messages before deeper debugging. Use when an agent has noisy or unfamiliar error output and must identify the first actionable failure.
---

# Error Message Triage

## Purpose

Turn noisy error output into a short, prioritized diagnosis path with the first error to investigate and the evidence needed next.

## When to Use

- Use when build, test, install, lint, type-check, or runtime output contains multiple errors.
- Use when the user pastes an error message and asks what it means.
- Use before deep debugging when the first actionable failure is unclear.
- Use when logs may contain cascading failures or unrelated warnings.

## When Not to Use

- Do not use after the root cause is already known; proceed to debugging or implementation.
- Do not use for security-sensitive logs without protecting secrets.
- Do not fix code during triage unless the user asks for a fix.

## Required Inputs

- Exact command that produced the output.
- Full relevant error text, stack trace, or log excerpt.
- Recent changes and environment details when available.
- Repository context for files, paths, and tooling.
- Windows or Linux shell context that ran the command.

## Workflow

1. Preserve the exact error text and command context.
2. Identify the tool that emitted the message and the failure phase.
3. Separate primary errors from warnings, cascades, and cleanup failures.
4. Extract file paths, line numbers, symbols, exit codes, and missing dependencies.
5. Rank likely first causes by locality, chronology, and specificity.
6. Map the next inspection step to concrete files or commands.
7. Recommend whether to use debugging, dependency management, TDD, or another skill next.

## Quality Gates

- The first actionable failure is identified or uncertainty is explicit.
- Cascading errors are not treated as independent root causes.
- Sensitive values are not repeated in the output.
- Recommended next steps are concrete and minimal.
- The triage preserves enough detail for later debugging.

## Anti-Patterns

- Guessing from the last line of output only.
- Ignoring the command that produced the error.
- Treating all warnings as blockers.
- Redacting so much that the error becomes unusable.
- Starting broad code edits before identifying the failure class.

## Output Format

```markdown
Error Triage:
- Command:
- Failure phase:
- First actionable error:
- Likely cause:
- Cascading or secondary messages:
- Next inspection step:
- Recommended next skill:
```

## References

No bundled references are required. Add error taxonomy references only if repeated triage patterns justify them.
