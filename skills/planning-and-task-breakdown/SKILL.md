---
name: planning-and-task-breakdown
description: Convert software-development goals into scoped, ordered, verifiable implementation plans. Use when a request is ambiguous, multi-step, risky, cross-cutting, or needs issue-style task breakdown before coding begins.
---

# Planning And Task Breakdown

## Purpose

Turn a software-development goal into executable work slices with clear inputs, dependencies, validation gates, approval boundaries, and stop conditions.

## When to Use

- Use before multi-file or multi-phase implementation.
- Use when the request has unclear scope, acceptance criteria, dependencies, or risks.
- Use when breaking a plan into independently executable tasks.
- Use when the user asks for a plan, implementation phases, or issue breakdown.

## When Not to Use

- Do not use when the user requested an immediate narrow code edit and the path is obvious.
- Do not use as a substitute for reading the repository.
- Do not create a plan that hides unresolved blockers.

## Required Inputs

- User goal and any stated acceptance criteria.
- Relevant source, tests, docs, and configuration.
- Known constraints, dependencies, and forbidden changes.
- Available validation commands, with Windows commands first and Linux alternatives where useful.
- Expected delivery format: plan, issues, checklist, or implementation sequence.

## Permitted Actions

- Inspect source, tests, docs, configs, and existing plans to ground the breakdown.
- Produce plans, issue outlines, checklists, and decision records.
- Do not edit implementation files unless the user has moved from planning into execution.

## Workflow

1. Restate the desired outcome in one concrete sentence.
2. Inspect enough source context to avoid planning from guesses.
3. Identify assumptions, blockers, external dependencies, and risk areas.
4. Split work into vertical slices that each produce a verifiable result.
5. Order slices by dependency, risk reduction, and feedback speed.
6. Attach validation steps and rollback considerations to each slice.
7. Call out decisions that require user approval before implementation.

## Stop Condition

- Stop successfully when each slice has an outcome, scope, validation gate, dependency, and risk note.
- Stop blocked when a required product, architecture, security, or release decision changes the implementation path.

## Quality Gates

- Each task has a clear outcome and validation method.
- The plan is scoped to the requested goal.
- Dependencies and sequencing are explicit.
- Blockers are surfaced instead of buried.
- The plan can be executed incrementally.
- The output contract does not require the implementer to invent missing gates.

## Anti-Patterns

- Producing a vague checklist such as "implement feature, test, document".
- Planning without inspecting the codebase.
- Combining unrelated work into one large task.
- Treating optional polish as required scope.
- Asking questions that can be answered from local context.

## Output Format

```markdown
Plan:
1. Outcome:
   Scope:
   Validation:
   Risks:

Assumptions:
- 

Decisions Needed:
- 
```

## References

No bundled references are required. Move reusable issue templates or large planning examples into `references/` only when needed.
