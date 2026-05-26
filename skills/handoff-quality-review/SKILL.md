---
name: handoff-quality-review
description: Review handoff artifacts for continuity, accuracy, validation evidence, context sufficiency, and next-step clarity. Use when an agent creates a handoff, resumes from a handoff, or prepares work for another agent or future session.
---

# Handoff Quality Review

## Purpose

Decide whether a handoff is safe to resume from, and identify exact edits when continuity, evidence, validation, or next-action detail is missing.

## When to Use

- Use after creating a handoff document.
- Use before resuming work from a handoff.
- Use when work transfers between agents, sessions, machines, or harnesses.
- Use when a long task has validation results, risks, or partial progress that must be preserved.
- Use when reviewing a workflow `Context Continuity` checkpoint before ending or transferring work.

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
- Workflow name, current phase, completed steps, pending steps, and recommended continuation skills or subagents when reviewing a continuity checkpoint.

## Permitted Actions

- Inspect the handoff, referenced files, validation summaries, branch state, and artifacts needed to verify continuity.
- Return an accept, revise, or blocked decision.
- Do not invent missing facts or perform the continuation task while reviewing the handoff.

## Workflow

1. Check that the handoff states the goal, current state, and intended next step.
2. Verify file paths, branch names, commits, commands, and artifact references.
3. Separate completed work, pending work, assumptions, and blockers.
4. Confirm validation evidence is specific and recent.
5. Confirm workflow checkpoints include current phase, success criteria, files inspected or changed, commands run, exact next action, and recommended continuation skills or subagents.
6. Remove sensitive or irrelevant content.
7. Identify missing context that would force repeated discovery.
8. Produce required edits or an acceptance decision.

## Stop Condition

- Stop successfully when the handoff is accepted or required revisions are specific enough for the author to apply.
- Stop blocked when referenced artifacts are unavailable or the handoff cannot be validated without private context.

## Quality Gates

- A fresh agent can identify where to start.
- Claims are tied to files, commits, commands, or explicit assumptions.
- Validation results include command names and outcomes.
- Risks and blockers are not buried.
- No secrets or unnecessary personal data are included.
- Workflow checkpoints can be resumed without relying on chat history.
- The output contract includes a decision and exact missing fields or required edits.

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
