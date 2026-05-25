---
name: refactoring
description: Improve software structure while preserving externally observable behavior. Use when an agent is asked to simplify, reorganize, decouple, rename, extract, consolidate, or reduce technical debt without changing product behavior.
---

# Refactoring

## Purpose

Change internal structure safely while keeping behavior stable and making future work clearer or less risky.

## When to Use

- Use when the user asks to refactor, simplify, clean up, consolidate, or improve structure.
- Use when duplication, coupling, or misplaced responsibility blocks a requested change.
- Use before implementation only when the refactor reduces real risk for that implementation.
- Use after tests characterize current behavior or can be added.

## When Not to Use

- Do not use when the requested work requires behavior changes as the primary outcome.
- Do not refactor unrelated areas because they are nearby.
- Do not refactor without a way to verify behavior is preserved.

## Required Inputs

- Target code area and refactoring goal.
- Current behavior, public contracts, and compatibility constraints.
- Existing tests or characterization strategy.
- Validation commands, Windows-first with Linux alternatives where useful.
- Boundaries for files or modules that must not change.

## Workflow

1. Identify the behavior that must remain unchanged.
2. Inspect callers, tests, public contracts, and data flow.
3. Add or run characterization tests when behavior is not already covered.
4. Choose the smallest structural change that addresses the stated problem.
5. Apply the refactor in reversible steps.
6. Run focused validation after each meaningful step.
7. Remove dead code only after confirming it has no active callers or contract role.
8. Report structural changes separately from any unavoidable behavior changes.

## Quality Gates

- Observable behavior is preserved or any behavior change is explicitly approved.
- Tests or checks cover affected paths.
- The refactor reduces concrete complexity, duplication, coupling, or risk.
- Public APIs, schemas, and file formats remain compatible unless approved.
- The diff avoids style-only churn.

## Anti-Patterns

- Combining refactoring with feature work without separation.
- Renaming or moving files without checking import and build impact.
- Creating abstractions for hypothetical future needs.
- Deleting code based only on search results without understanding dynamic use.
- Treating formatting churn as refactoring value.

## Output Format

```markdown
Refactor Summary:
- Goal:
- Structural changes:
- Behavior changes:

Changed Files:
- 

Validation:
- 

Remaining Debt:
- 
```

## References

No bundled references are required. Add reference files only for repeated refactoring playbooks or architecture constraints.
