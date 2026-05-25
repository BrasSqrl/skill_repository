# Architecture Review Rubric

Use this reference when comparing design options or reviewing cross-cutting structure.

## Questions To Answer

- What decision is being made?
- What behavior or quality attribute is at stake?
- Which modules own which responsibilities?
- Which dependency directions are allowed?
- What data crosses each boundary?
- What must remain compatible during migration?
- What validation would prove the design works?

## Risk Lenses

- Coupling: changes require edits across unrelated modules.
- Cohesion: one module owns unrelated responsibilities.
- Cycles: dependency direction prevents isolated testing or deployment.
- Hidden contracts: behavior depends on undocumented ordering or state.
- Scalability: data volume, latency, or concurrency exceeds current assumptions.
- Operability: errors, observability, rollback, or config are unclear.
- Migration: adopting the design requires risky all-at-once change.

## Option Comparison

```markdown
Option:
Benefits:
Costs:
Migration path:
Compatibility impact:
Validation:
When to reject:
```

## Recommendation Bar

Recommend the smallest design move that addresses a current risk. Do not recommend a broad architecture shift unless the inspected evidence shows the current structure cannot support the required work.
