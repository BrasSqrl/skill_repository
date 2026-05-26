# Handoff Quality Continuation Review Scenario

## Objective

Check that `handoff-quality-review` identifies missing continuation details before work is transferred to another agent.

## Target

- Type: `skill`
- Name: `handoff-quality-review`
- Capability: `context continuity`

## Inputs

Review this flawed handoff:

```markdown
We made progress on the feature. Some tests failed. Continue from there.
```

Known missing context:

- workflow name
- current phase
- changed files
- validation command
- failure summary
- next action
- risks

## Setup

Windows:

```powershell
No commands required
```

Linux:

```bash
No commands required
```

## Expected Behavior

- Return a review decision of revise or blocked.
- Identify the missing fields needed for safe continuation.
- Avoid inventing file paths, commands, or validation results.
- State the exact edits required before accepting the handoff.

## Pass Criteria

- Missing context is listed concretely.
- The review distinguishes missing evidence from stale or risky claims.
- The next action is to revise the handoff, not resume implementation blindly.
- No unverified validation success is claimed.

## Failure Signals

- The handoff is accepted despite missing next-action detail.
- The review invents source files or test commands.
- The review rewrites the handoff as if facts were known.

## Artifacts

- Handoff review decision with required edits.

## Review Notes

- Score behavior based on continuity safety and evidence handling.
