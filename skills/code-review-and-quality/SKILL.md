---
name: code-review-and-quality
description: Review software changes for correctness, maintainability, regressions, missing tests, and delivery risk. Use when an agent is asked to review code, inspect a diff, assess quality before merge, or provide findings without making implementation changes unless requested.
---

# Code Review And Quality

## Purpose

Find actionable defects and quality risks in software changes, prioritizing correctness and regressions over style preferences.

## When to Use

- Use when the user asks for a review, quality pass, or risk assessment.
- Use before pull request preparation when the diff needs scrutiny.
- Use when evaluating changes made by another agent or contributor.
- Use when deciding whether validation coverage is sufficient.

## When Not to Use

- Do not use as the main workflow for implementing requested changes.
- Do not focus on style-only comments unless they affect correctness or maintainability.
- Do not duplicate a dedicated security review for security-sensitive changes.

## Required Inputs

- Diff, branch, commit range, changed files, or review target.
- Relevant tests, docs, and source context.
- Project quality standards or repository instructions.
- Validation outputs when available.
- Windows-first commands for inspecting and testing, with Linux alternatives where useful.

## Workflow

1. Identify the changed behavior and affected surfaces.
2. Inspect the diff and the surrounding unchanged code needed to judge it.
3. Check for correctness bugs, regressions, data loss, race conditions, and edge cases.
4. Check whether tests cover the changed behavior and important failure modes.
5. Check maintainability risks: duplication, misplaced responsibility, confusing abstractions, and hidden coupling.
6. Verify claims against source or executable evidence.
7. Report findings first, ordered by severity, with precise file and line references when available.

## Quality Gates

- Findings are actionable and tied to concrete evidence.
- Severity reflects user impact and likelihood.
- Each finding identifies the affected file or code area.
- Missing tests are reported when they create real risk.
- Summary is secondary to findings.

## Anti-Patterns

- Listing preferences as defects.
- Reviewing only the diff while missing required surrounding context.
- Giving generic approval without checking tests or behavior.
- Overstating uncertain risks as confirmed bugs.
- Mixing implementation fixes into the review unless the user requested fixes.

## Output Format

```markdown
Findings:
- Severity:
  Location:
  Issue:
  Recommendation:

Open Questions:
- 

Validation Reviewed:
- 

Summary:
- 
```

## References

No bundled references are required. Add review checklists to `references/` only if they become domain-specific or long.
