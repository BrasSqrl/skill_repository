# Context Compaction Checklist

Use this reference when a task has enough context that the agent needs a compact working summary or handoff.

## Include

- Current goal in one sentence.
- Relevant files and why each matters.
- Commands already run and their outcomes.
- Facts verified from source.
- Assumptions not yet verified.
- User constraints and forbidden changes.
- Current worktree state if changes exist.
- Next smallest actionable step.

## Exclude

- Full command logs unless the exact text is needed.
- Long code excerpts that can be reopened from file paths.
- Historical exploration that did not affect the current decision.
- Speculation without a label.

## Refresh Triggers

- New failing validation output appears.
- The user changes the scope.
- A branch, dependency, or generated file changes.
- More than one implementation path is abandoned.
- The agent is about to hand off the task.

## Compact Output Shape

```markdown
Goal:

Known Facts:
- 

Relevant Files:
- 

Validation:
- 

Assumptions:
- 

Open Blockers:
- 

Next Step:
- 
```
