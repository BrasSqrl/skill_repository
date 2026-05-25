---
name: architecture-review
description: Review software architecture, module boundaries, coupling, data flow, dependency direction, scalability constraints, and design tradeoffs. Use when an agent must assess a design, proposed refactor, subsystem boundary, or cross-cutting technical direction before implementation.
---

# Architecture Review

## Purpose

Evaluate whether a design or existing structure supports the required behavior with clear boundaries, manageable coupling, and explicit tradeoffs.

## When to Use

- Use when reviewing architecture, design proposals, module boundaries, or subsystem structure.
- Use before large refactors or cross-cutting implementation.
- Use when code changes reveal coupling, ownership, or dependency direction problems.
- Use when the user asks for architectural risks, options, or tradeoffs.

## When Not to Use

- Do not use for line-level code review unless architectural risk is the issue.
- Do not use to justify speculative abstractions.
- Do not replace source-driven development when a fixed spec or contract controls behavior.

## Required Inputs

- Design proposal, target subsystem, or architecture question.
- Relevant modules, dependencies, data flow, APIs, tests, and docs.
- Nonfunctional constraints such as scale, reliability, latency, maintainability, or portability.
- Known delivery constraints and migration limits.
- Validation or analysis commands, Windows-first with Linux alternatives where useful.

## Workflow

1. Define the architectural question and decision horizon.
2. Inspect current boundaries, dependencies, data flow, and ownership.
3. Identify coupling, cycles, hidden contracts, shared state, and migration constraints.
4. Evaluate options against required behavior and nonfunctional constraints.
5. Distinguish immediate risks from long-term maintainability concerns.
6. Recommend the smallest architectural move that addresses the real problem.
7. State tradeoffs, rejected options, and validation needed before implementation.

## Quality Gates

- Recommendations are grounded in inspected source or explicit design inputs.
- Tradeoffs are concrete, not aesthetic.
- The review separates architecture risks from ordinary code cleanup.
- Migration and compatibility impact are considered.
- Suggested changes are actionable and scoped.

## Anti-Patterns

- Proposing a new architecture because the current one is unfamiliar.
- Treating naming or formatting issues as architecture problems.
- Ignoring tests, deployment, or migration constraints.
- Recommending abstractions without current pressure.
- Presenting one option without tradeoffs.

## Output Format

```markdown
Architecture Review:
- Question:
- Current structure:
- Risks:
- Options:
- Recommendation:
- Tradeoffs:
- Validation needed:
```

## References

- `references/architecture-review-rubric.md`: Use when comparing design options, module boundaries, or architectural risks.
