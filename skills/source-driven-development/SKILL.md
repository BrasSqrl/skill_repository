---
name: source-driven-development
description: Implement or review software behavior from authoritative sources such as existing code, tests, specifications, schemas, protocol docs, API contracts, or product requirements. Use when correctness depends on tracing requirements from source material rather than inference.
---

# Source Driven Development

## Purpose

Ground implementation decisions in authoritative source material and keep code, tests, and documentation aligned with that source.

## When to Use

- Use when a task depends on specs, schemas, API contracts, protocol rules, or existing source behavior.
- Use when multiple sources may conflict and the agent must identify the authority.
- Use when implementing compatibility behavior.
- Use when the user asks to derive behavior from docs or source files.

## When Not to Use

- Do not use when no authoritative source exists and the task is exploratory.
- Do not use to justify behavior from memory or convention alone.
- Do not treat stale documentation as authoritative when current code or tests contradict it without noting the conflict.

## Required Inputs

- The source material or paths to locate it.
- Priority order for conflicting sources, if known.
- Target files, APIs, tests, or docs to update.
- Expected validation commands, with Windows commands first and Linux alternatives where useful.
- Compatibility or backward-compatibility constraints.

## Workflow

1. Identify the authoritative source or state that authority is unresolved.
2. Extract the specific rules, fields, states, edge cases, or contracts that affect the task.
3. Trace each required behavior to code, tests, docs, or configuration.
4. Resolve conflicts by priority, recency, or user decision; document unresolved conflicts.
5. Implement the smallest change that satisfies the sourced behavior.
6. Add or update tests that encode the sourced contract when practical.
7. Verify the implementation against both tests and the source material.

## Quality Gates

- Every material behavior change maps to a cited source artifact.
- Conflicting sources are called out explicitly.
- Tests cover contract-visible behavior where practical.
- The implementation does not add behavior beyond the source without approval.
- Final notes include source files or documents used.

## Anti-Patterns

- Inferring requirements from naming or intuition when sources exist.
- Copying long source excerpts into the answer.
- Updating code without updating affected contract tests or docs.
- Ignoring source conflicts to keep implementation moving.
- Treating examples as complete specifications.

## Output Format

```markdown
Source Basis:
- 

Implemented Behavior:
- 

Changed Files:
- 

Validation:
- 

Conflicts Or Gaps:
- 
```

## References

No bundled references are required. Add reference files only for recurring source hierarchies or contract interpretation rules.
