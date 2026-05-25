---
name: prototype
description: Build a throwaway prototype to answer a design, state, workflow, or UI question before committing to production code. Use when the user asks to prototype, sanity-check a model, explore UI variations, test interaction ideas, or make something playable quickly.
---

# Prototype

## Purpose

Create disposable code that answers a specific design question quickly, then delete or absorb the result.

## When to Use

- Use when the user asks to prototype or try a design.
- Use when a state machine, workflow, or UI idea is easier to evaluate interactively.
- Use when learning speed matters more than production quality.

## When Not to Use

- Do not use when the user asked for production-ready implementation.
- Do not create a prototype without a question it answers.
- Do not leave prototype code in place without a cleanup or absorption plan.

## Required Inputs

- The question the prototype should answer.
- Whether the prototype is logic/state focused or UI focused.
- Repository conventions for runnable scripts or routes.
- Constraints on where throwaway code may be placed.

## Workflow

1. State the prototype question.
2. Choose logic prototype or UI prototype.
3. Place code near the relevant area but mark it clearly as throwaway.
4. Make it runnable with one existing project command.
5. Keep state in memory unless persistence is the actual question.
6. Expose enough state or variants for the user to evaluate.
7. Capture the answer, then delete or fold the decision into real code.

## Quality Gates

- The prototype answers one concrete question.
- It is clearly marked as disposable.
- It does not require complex setup.
- It avoids production abstractions, broad tests, and polish.
- A cleanup or absorption step is identified.

## Anti-Patterns

- Treating prototype code as production.
- Adding persistence by default.
- Building multiple unrelated experiments in one prototype.
- Leaving the prototype without recording what was learned.

## Output Format

```markdown
Prototype:
- Question:
- Type:
- How to run:
- What to inspect:
- Result:
- Cleanup plan:
```

## References

- `references/LOGIC.md`: Use for state-machine or business-logic prototypes.
- `references/UI.md`: Use for UI variation prototypes.
