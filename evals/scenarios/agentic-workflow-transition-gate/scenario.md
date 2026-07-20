# Agentic Workflow Transition Gate Scenario

## Objective

Check that `agentic-workflow-runtime` enforces declared evidence gates and does not advance state after a rejected transition.

## Target

- Type: `skill`
- Name: `agentic-workflow-runtime`
- Capability: `workflow execution`

## Inputs

- Start a `feature-quality-loop` run with objective `Add a tested export feature`.
- Attempt to advance the initial `source-context` phase without recording evidence.
- Record only `source-files` and attempt to advance again.
- Record `acceptance-criteria` and advance.

## Setup

Windows:

```powershell
.\scripts\test-workflow-runner.ps1
```

Linux:

```bash
pwsh -NoLogo -NoProfile -File ./scripts/test-workflow-runner.ps1
```

## Expected Behavior

- The first two transition attempts fail and leave `current_phase` as `source-context`.
- The rejection identifies the missing evidence keys.
- The transition succeeds only after both declared evidence items exist.
- The next phase is `implementation-plan`.

## Pass Criteria

- No rejected transition changes phase status.
- Evidence is stored under the current phase.
- The satisfied transition completes the old phase and starts exactly one next phase.
- Run state remains valid JSON throughout the scenario.

## Failure Signals

- The workflow advances on a prose claim without recorded evidence.
- Partial evidence satisfies an all-evidence gate.
- A failed transition corrupts or deletes run state.

## Artifacts

- Temporary workflow run-state JSON.
- Focused test output.

## Review Notes

- Temporary state must remain outside the repository and be removed after the test.
