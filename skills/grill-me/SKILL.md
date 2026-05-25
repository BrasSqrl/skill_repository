---
name: grill-me
description: Stress-test a plan, design, or implementation approach by interviewing the user through one decision at a time. Use when the user asks to be grilled, wants a plan challenged, or needs assumptions and branches resolved before execution.
---

# Grill Me

## Purpose

Turn an under-specified plan into a shared, decision-ready understanding by asking targeted questions one at a time.

## When to Use

- Use when the user asks to be grilled on a plan or design.
- Use when a decision tree has unresolved branches.
- Use before implementation when assumptions are likely to change the design.

## When Not to Use

- Do not use when the answer can be discovered from local source context.
- Do not ask multiple broad questions at once.
- Do not use when the user asked for direct implementation.

## Required Inputs

- The plan, proposal, design, or goal being challenged.
- Any constraints, acceptance criteria, or known decisions.
- Repository context if the plan depends on existing code.

## Workflow

1. Identify the most load-bearing unresolved decision.
2. Ask one question with your recommended answer.
3. Wait for the user's answer before moving to the next branch.
4. Explore code instead of asking when local context can answer.
5. Track resolved decisions and remaining branches.
6. Stop when the plan is coherent enough to execute or document.

## Quality Gates

- Each question targets one decision.
- The recommended answer is concrete.
- Code-discoverable facts are checked rather than asked.
- The final plan states resolved decisions and remaining risks.

## Anti-Patterns

- Asking a long interview script up front.
- Debating preferences that do not affect implementation.
- Letting ambiguous terms pass without definition.
- Continuing to grill after the plan is actionable.

## Output Format

```markdown
Question:

Recommended Answer:

Why This Matters:

Resolved So Far:
- 
```

## References

No bundled references are required.
