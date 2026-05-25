---
name: workflow-dry-run
description: Dry-run an AI agent workflow before execution to find missing context, unclear gates, unsafe steps, and handoff gaps. Use before launching multi-step, multi-agent, risky, or long-running software-development workflows.
---

# Workflow Dry Run

## Purpose

Simulate an agent workflow before execution so missing inputs, weak validation gates, and unsafe assumptions are caught early.

## When to Use

- Use before multi-agent or multi-phase work.
- Use before risky changes such as releases, migrations, security work, or broad refactors.
- Use when a workflow has unclear ownership, stopping points, or validation.
- Use when a user asks to sanity-check an agent plan before starting.

## When Not to Use

- Do not use for trivial single-command tasks.
- Do not treat the dry run as approval to skip validation.
- Do not invent missing requirements; mark them as blockers or assumptions.

## Required Inputs

- Proposed workflow or ordered skill sequence.
- Goal, scope, constraints, and forbidden actions.
- Required artifacts and validation commands.
- Approval boundaries and handoff points.
- Expected final output.

## Workflow

1. Restate the goal and planned phases.
2. Walk through each phase as if executing it.
3. Identify required context, tools, permissions, and artifacts.
4. Check validation gates and stopping conditions.
5. Identify failure modes, unsafe steps, and missing decisions.
6. Recommend changes to the workflow before execution.
7. Produce a go, revise, or blocked decision.

## Quality Gates

- Every phase has an owner, input, output, and validation gate.
- Risky operations have approval or rollback boundaries.
- Missing context is explicit.
- Handoffs include enough information to continue.
- The dry run ends with a concrete decision.

## Anti-Patterns

- Rewriting the workflow during execution without calling it out.
- Treating assumptions as facts.
- Ignoring validation because the plan sounds reasonable.
- Adding unnecessary phases that do not reduce risk.
- Running the actual workflow while claiming it is a dry run.

## Output Format

```markdown
Workflow Dry Run:
- Goal:
- Planned phases:
- Missing inputs:
- Risk points:
- Validation gates:
- Handoff gaps:
- Decision:
```

## References

No bundled references are required. Add workflow-specific checklists only after repeated use.
