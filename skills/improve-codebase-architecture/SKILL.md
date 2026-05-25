---
name: improve-codebase-architecture
description: Find architecture deepening opportunities in a codebase by reviewing module depth, locality, test seams, and documented domain language. Use when the user asks to improve architecture, find refactoring opportunities, consolidate tightly coupled modules, or make a codebase more testable and agent-navigable.
---

# Improve Codebase Architecture

## Purpose

Identify concrete architecture improvements that make modules deeper, boundaries clearer, and future agent work easier.

## When to Use

- Use when the user asks for architecture improvement opportunities.
- Use when the goal is discovery rather than one specific design review.
- Use when a codebase feels hard to navigate, test, or change.
- Use when domain docs and ADRs should guide architecture analysis.

## When Not to Use

- Do not use for line-level code review.
- Do not use for an already-scoped refactor; use `refactoring`.
- Do not propose large rewrites without evidence of current friction.

## Required Inputs

- Repository source context and relevant docs.
- Existing `CONTEXT.md`, `CONTEXT-MAP.md`, and ADRs when present.
- Target area, if the user named one.
- Validation or analysis commands if recommendations depend on behavior.

## Workflow

1. Read relevant domain language and ADRs before judging architecture.
2. Inspect code organically for shallow modules, poor locality, hidden coupling, and weak test seams.
3. Apply the deletion test to suspected shallow modules.
4. Group findings into candidate deepening opportunities.
5. Produce a visual or structured report outside the repo unless the user asks to commit it.
6. Rank candidates by strength and implementation value.
7. Ask which candidate the user wants to explore before proposing detailed interfaces.

## Quality Gates

- Each candidate names concrete files or modules.
- Recommendations use consistent architecture vocabulary.
- Benefits are framed as locality, leverage, testability, or navigability.
- ADR conflicts are called out only when friction justifies reopening them.
- The top recommendation is actionable and scoped.

## Anti-Patterns

- Proposing abstractions because the current code is unfamiliar.
- Ignoring domain vocabulary or existing ADRs.
- Treating pass-through helpers as architecture value.
- Turning discovery into implementation without user choice.

## Output Format

```markdown
Architecture Opportunities:
- Candidate:
  Files:
  Problem:
  Proposed direction:
  Benefits:
  Strength:

Top Recommendation:
- 

Next Decision:
- 
```

## References

- `references/LANGUAGE.md`: Use for architecture vocabulary and decision rules.
- `references/HTML-REPORT.md`: Use when producing the optional visual report.
- `references/DEEPENING.md`: Use when evaluating deep module opportunities.
- `references/INTERFACE-DESIGN.md`: Use only after the user chooses a candidate to explore.
