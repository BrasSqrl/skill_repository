---
name: to-issues
description: Convert a plan, spec, PRD, or conversation context into independently executable implementation issues. Use when the user wants implementation tickets, issue tracker work items, vertical slices, or agent-ready tasks derived from an approved plan.
---

# To Issues

## Purpose

Break a plan into small vertical-slice issues that can be implemented and validated independently.

## When to Use

- Use when the user asks to turn a plan or PRD into issues.
- Use when implementation work needs agent-ready tickets.
- Use when dependencies, human decisions, and AFK work must be separated.

## When Not to Use

- Do not use before the source plan is coherent enough to slice.
- Do not publish issues without knowing the target tracker.
- Do not create horizontal layer-only tasks unless the work is genuinely infrastructure-only.

## Required Inputs

- Plan, spec, PRD, issue, or conversation context.
- Target issue tracker and label vocabulary.
- Project domain language and relevant source context.
- User approval of final issue breakdown before publishing.

## Workflow

1. Gather the source plan and any parent issue context.
2. Inspect codebase context if issue titles or acceptance criteria depend on current implementation.
3. Draft vertical slices that each deliver a narrow complete path.
4. Mark each slice as AFK or human-in-the-loop.
5. Identify dependencies between slices.
6. Review granularity, ordering, and labels with the user.
7. Publish approved issues in dependency order.
8. Do not close or modify parent issues unless explicitly asked.

## Quality Gates

- Each issue has a verifiable end-to-end outcome.
- Dependencies are explicit.
- Acceptance criteria are concrete.
- Issue text avoids stale file paths unless necessary.
- User approves the breakdown before publishing.

## Anti-Patterns

- Creating one issue per technical layer.
- Publishing speculative slices before user review.
- Overloading one issue with several independent outcomes.
- Omitting blocked-by relationships.

## Output Format

```markdown
Issue Breakdown:
- Title:
  Type:
  Blocked by:
  What to build:
  Acceptance criteria:

Publishing:
- Tracker:
- Labels:
- Parent:
```

## References

No bundled references are required.
