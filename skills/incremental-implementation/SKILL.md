---
name: incremental-implementation
description: Implement software changes in small, verifiable slices while preserving existing behavior and local conventions. Use when an agent needs to edit code, apply a plan, or make progress without broad rewrites or unrelated churn.
---

# Incremental Implementation

## Purpose

Make the smallest useful code changes that satisfy the requested behavior, with frequent verification and minimal blast radius.

## When to Use

- Use when implementing a scoped feature, bug fix, or maintenance change.
- Use when applying an approved plan.
- Use when the safest path is a sequence of small edits and checks.
- Use when user or repository changes may exist and must be preserved.

## When Not to Use

- Do not use for analysis-only, review-only, or planning-only requests.
- Do not use for broad refactors unless the request is explicitly refactoring.
- Do not skip test-first workflow when the user explicitly requested TDD.

## Required Inputs

- Requested behavior or accepted plan.
- Relevant files, conventions, and ownership boundaries.
- Current worktree state.
- Focused validation commands, using Windows commands first and Linux equivalents when relevant.
- Any forbidden files, generated outputs, or compatibility constraints.

## Workflow

1. Inspect current status and relevant source before editing.
2. Identify the smallest vertical slice that can be changed and verified.
3. Follow existing local patterns for naming, structure, errors, and tests.
4. Edit only the files needed for the slice.
5. Run the narrowest useful validation command.
6. Repeat with the next slice only after the previous one is understood.
7. Stop when the requested behavior is complete and validation evidence is available.

## Quality Gates

- Changes are scoped to the requested outcome.
- Existing user changes are preserved.
- New abstractions are justified by real complexity or existing patterns.
- Validation is run after meaningful edits, or the reason it cannot run is stated.
- Final output identifies changed files and residual risk.

## Anti-Patterns

- Rewriting surrounding code to match personal style.
- Mixing behavior changes with unrelated cleanup.
- Editing generated files without confirming they are source-controlled outputs.
- Deferring all validation until the end of a large change.
- Claiming completion without checking the implemented path.

## Output Format

```markdown
Summary:
- 

Changed Files:
- 

Validation:
- 

Residual Risks:
- 
```

## References

No bundled references are required. Add references only for repeated implementation patterns that are too long for this file.
