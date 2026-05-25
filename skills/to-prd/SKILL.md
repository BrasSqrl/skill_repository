---
name: to-prd
description: Synthesize current conversation and repository context into a product requirements document for software implementation. Use when the user wants a PRD, feature brief, or issue-tracker-ready requirements document from already discussed context.
---

# To PRD

## Purpose

Create a PRD from known context without re-interviewing the user unless a blocking requirement is missing.

## When to Use

- Use when the user asks to create a PRD.
- Use when a conversation has enough context to document requirements.
- Use when a PRD should become the source for issue breakdown or implementation planning.

## When Not to Use

- Do not use when the user wants brainstorming rather than requirements capture.
- Do not invent product requirements not present in context.
- Do not publish to an issue tracker without confirmed tracker setup.

## Required Inputs

- Conversation context, plan, issue, or feature request.
- Repository context when implementation constraints matter.
- Target issue tracker and label vocabulary if publishing.
- Known out-of-scope items and implementation decisions.

## Workflow

1. Gather current conversation and source context.
2. Inspect repository structure if implementation modules or testing decisions must be named.
3. Synthesize the user problem, solution, stories, decisions, testing approach, and out-of-scope items.
4. Use project domain language where available.
5. Ask only for blockers that cannot be inferred from context.
6. Publish or save the PRD only after the target location is known.

## Quality Gates

- Requirements are grounded in known context.
- User stories are specific and implementation-relevant.
- Implementation and testing decisions are separated.
- Out-of-scope items are explicit.
- Publishing target and labels are confirmed.

## Anti-Patterns

- Interviewing the user again for already-known context.
- Writing a PRD full of generic product filler.
- Including stale file paths or code snippets unless they encode a durable decision.
- Confusing implementation tickets with requirements.

## Output Format

```markdown
PRD:
- Problem statement:
- Solution:
- User stories:
- Implementation decisions:
- Testing decisions:
- Out of scope:
- Further notes:

Publishing:
- Target:
- Labels:
```

## References

No bundled references are required.
