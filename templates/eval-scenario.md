# Eval Scenario Template

Use this template for dependency-free evaluation scenarios under `evals/scenarios/<scenario-id>/scenario.md`.

## Objective

State the behavior being evaluated and the failure mode the scenario should catch.

## Target

- Type: `<skill|agent|workflow|bundle>`
- Name: `<target-name>`
- Capability: `<capability>`

## Inputs

- `<prompt, task brief, fixture path, diff summary, logs, or source files>`

## Setup

Windows:

```powershell
<commands or "No commands required">
```

Linux:

```bash
<commands or "No commands required">
```

## Expected Behavior

- `<observable behavior expected from the target>`
- `<required boundary or refusal behavior>`

## Pass Criteria

- `<specific check>`
- `<specific check>`
- `<specific check>`

## Failure Signals

- `<observable failure>`
- `<observable failure>`

## Artifacts

- `<expected output, report, table, command summary, or review notes>`

## Review Notes

- `<manual review instructions, scoring notes, or accepted limitations>`
