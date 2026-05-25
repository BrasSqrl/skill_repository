---
name: handoff-quality-review
description: Review handoff artifacts for continuity, accuracy, validation evidence, context sufficiency, and next-step clarity. Use when an agent creates a handoff, resumes from a handoff, or prepares work for another agent or future session.
---

# Handoff Quality Review

## Purpose

Ensure a handoff lets another agent continue work without stale assumptions, missing files, hidden blockers, or duplicated investigation.

## When to Use

- Use after creating a handoff document.
- Use before resuming work from a handoff.
- Use when work transfers between agents, sessions, machines, or harnesses.
- Use when a long task has validation results, risks, or partial progress that must be preserved.

## When Not to Use

- Do not use for short final summaries that are not meant to continue work.
- Do not add sensitive data, secrets, tokens, or unnecessary personal information.
- Do not rewrite source facts without checking the referenced artifacts.

## Required Inputs

- Handoff artifact or summary.
- Current repository path, branch, and latest relevant commit or diff.
- Validation commands and results.
- Known blockers, risks, and next recommended action.
- Any artifacts that the next agent must inspect.

## Workflow

1. Check that the handoff states the goal, current state, and intended next step.
2. Verify file paths, branch names, commits, commands, and artifact references.
3. Separate completed work, pending work, assumptions, and blockers.
4. Confirm validation evidence is specific and recent.
5. Remove sensitive or irrelevant content.
6. Identify missing context that would force repeated discovery.
7. Produce required edits or an acceptance decision.

## Quality Gates

- A fresh agent can identify where to start.
- Claims are tied to files, commits, commands, or explicit assumptions.
- Validation results include command names and outcomes.
- Risks and blockers are not buried.
- No secrets or unnecessary personal data are included.

## Anti-Patterns

- Writing a narrative without next actions.
- Omitting dirty worktree or branch state.
- Claiming tests passed without command output or summary.
- Including raw logs when a concise summary is enough.
- Leaving stale assumptions after the repo changed.

## Output Format

```markdown
Handoff Review:
- Decision:
- Missing context:
- Stale or risky claims:
- Validation evidence:
- Required edits:
- Next action:
```

## References

No bundled references are required. Add handoff rubrics only if repeated reviews need more detail.
