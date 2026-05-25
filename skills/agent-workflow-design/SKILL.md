---
name: agent-workflow-design
description: Design repeatable AI coding-agent workflows, skill sets, handoffs, validation loops, context boundaries, and multi-agent task flows. Use when an agent needs to create or improve agent operating procedures for software development work without depending on a specific tool.
---

# Agent Workflow Design

## Purpose

Create practical workflows that help AI coding agents perform software-development tasks reliably with clear context, boundaries, validation, and handoff points.

## When to Use

- Use when designing agent instructions, skill sets, task flows, or handoff formats.
- Use when repeated agent work fails because context, scope, or validation is unclear.
- Use when splitting work across multiple agents or phases.
- Use when improving repository-level agent guidance.

## When Not to Use

- Do not use to solve the underlying software task directly unless workflow design is the task.
- Do not create tool-specific procedures unless the user explicitly requests them.
- Do not add process for one-off tasks that are already simple and clear.

## Required Inputs

- Target workflow, recurring task, or failure mode.
- Repository constraints, validation commands, and existing agent instructions.
- Roles, handoff points, required artifacts, and approval boundaries.
- Expected output format for agents and humans.
- Windows-first operational commands, with Linux alternatives where useful.

## Workflow

1. Define the recurring task and the failure the workflow must prevent.
2. Identify required context, decision points, validation gates, and stopping conditions.
3. Split the workflow into phases with clear ownership and outputs.
4. Specify what agents must inspect, produce, verify, and report.
5. Add escalation rules for blockers, risky operations, and missing context.
6. Remove tool-specific assumptions unless explicitly required.
7. Test the workflow mentally against a realistic task and tighten ambiguous steps.

## Quality Gates

- The workflow has concrete triggers and outputs.
- Validation gates are executable or reviewable.
- Handoffs include enough context for another agent to continue.
- Approval boundaries are explicit.
- The workflow reduces repeated failure modes without excessive process.

## Anti-Patterns

- Writing generic prompt advice instead of operational procedure.
- Overfitting the workflow to one tool or one contributor.
- Adding roles or handoffs that do not reduce risk.
- Omitting validation because the process sounds reasonable.
- Designing for ideal conditions without failure recovery.

## Output Format

```markdown
Agent Workflow:
- Trigger:
- Roles or phases:
- Required context:
- Steps:
- Validation gates:
- Handoff format:
- Escalation rules:
- Failure modes addressed:
```

## References

- `references/workflow-design-checklist.md`: Use when designing repeatable agent workflows, handoffs, and validation gates.
