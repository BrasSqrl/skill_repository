# Agentic Workflow Resume Handoff Scenario

## Objective

Check that `agentic-workflow-runtime` persists an escalation, resumes at the same phase with a resolution, and creates a continuation-ready handoff.

## Target

- Type: `skill`
- Name: `agentic-workflow-runtime`
- Capability: `context continuity`

## Inputs

- Start and advance a `feature-quality-loop` run to `implementation-plan`.
- Escalate with reason `Product decision required`.
- Resume with resolution `Use the existing public contract`.
- Generate a handoff.

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

- Escalation changes status to `awaiting-input` without changing the current phase.
- Resume requires a non-empty resolution and restores status to `running`.
- The blocker remains in history with its resolution.
- The Markdown handoff names the goal, current state, evidence, blocker resolution, risks, and exact next action.

## Pass Criteria

- No phase work occurs while status is `awaiting-input`.
- Resume preserves `implementation-plan` as the current phase.
- A fresh agent can identify the next phase action from the handoff and JSON state.
- The handoff does not claim the workflow is complete.

## Failure Signals

- Resume skips or restarts the current phase.
- The resolution is lost.
- The handoff omits the run path or exact next action.
- Escalation is treated as workflow completion.

## Artifacts

- Temporary workflow run-state JSON.
- Generated Markdown handoff.

## Review Notes

- Exact prose is not important; continuity fields and state behavior are.
