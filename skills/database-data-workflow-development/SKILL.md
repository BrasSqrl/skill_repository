---
name: database-data-workflow-development
description: Develop database, migration, query, seed, ETL, reporting, and data workflow changes. Use when an agent needs to modify schemas, indexes, data access, migrations, fixtures, analytics queries, import/export flows, or data integrity checks.
---

# Database Data Workflow Development

## Purpose

Make data changes safely by preserving integrity, compatibility, reversibility, and observable query behavior.

## When to Use

- Use when adding or changing schemas, migrations, indexes, constraints, seeds, or fixtures.
- Use when modifying queries, data access layers, import/export flows, or reporting logic.
- Use when data backfills, transformations, or cleanup require validation.
- Use when performance or data integrity depends on query behavior.

## When Not to Use

- Do not use for backend API logic unless persistence or data shape changes are central.
- Do not run destructive data operations without explicit approval and rollback planning.
- Do not use for security review of sensitive data access as the primary workflow.

## Required Inputs

- Target data model, schema, query, migration, or workflow.
- Current schema definitions, migrations, models, fixtures, and data access code.
- Data compatibility, rollback, and retention requirements.
- Sample data, expected row counts, or invariants when available.
- Test, migration, and verification commands, Windows-first with Linux alternatives where useful.

## Workflow

1. Inspect current schema, migration history, data access code, and tests.
2. Identify data invariants, compatibility needs, and rollback constraints.
3. Design the smallest schema, query, or workflow change that satisfies the task.
4. Add or update migrations, fixtures, queries, and model mappings together.
5. Include safe defaults, constraints, and indexes only when justified by access patterns.
6. Validate on representative data or tests before broader execution.
7. Check forward and rollback behavior when the project supports rollback.
8. Report data risks, irreversible operations, and verification evidence.

## Quality Gates

- Schema, model, query, and fixture changes are consistent.
- Migrations are ordered and repeatable.
- Data integrity constraints and nullability are intentional.
- Destructive or irreversible steps are explicit and approved.
- Query behavior and performance-sensitive paths are tested or explained.

## Anti-Patterns

- Changing schema without updating access code or tests.
- Assuming empty databases when existing data may exist.
- Adding indexes without checking query patterns.
- Running broad update/delete operations without a bounded plan.
- Hiding migration risks behind generic validation output.

## Output Format

```markdown
Data Workflow Result:
- Data change:
- Integrity checks:
- Migration or query impact:

Changed Files:
- 

Validation:
- 

Data Risks:
- 
```

## References

No bundled references are required. Add database-specific migration playbooks to `references/` only when repeated patterns justify them.
