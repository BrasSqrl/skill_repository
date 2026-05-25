# Workflow Design Checklist

Use this reference when creating repeatable agent workflows, handoffs, or skill sets.

## Workflow Definition

- Trigger: exact task or failure mode that starts the workflow.
- Inputs: files, commands, logs, user decisions, or artifacts required.
- Phases: ordered work units with clear outputs.
- Gates: checks that must pass before moving on.
- Handoff: summary format for another agent or future session.
- Escalation: conditions requiring user input or approval.
- Stop condition: what completion means.

## Handoff Minimum

```markdown
Goal:
Current state:
Files touched:
Commands run:
Decisions made:
Open blockers:
Next action:
Risks:
```

## Failure Modes To Design Against

- Agent starts coding before reading source context.
- Context summary omits validation results.
- Handoff includes conclusions without evidence.
- Workflow requires a tool that may not exist.
- Approval boundaries for destructive actions are unclear.
- Validation happens only at the end of a large change.

## Review Questions

- Does each phase produce something checkable?
- Can a fresh agent continue from the handoff?
- Are tool-specific steps optional or clearly replaceable?
- Does the workflow reduce a real repeated failure?
