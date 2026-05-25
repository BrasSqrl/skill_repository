---
name: handoff
description: Create a compact handoff document so another agent or future session can continue work. Use when the user asks for a handoff, when context is about to be lost, or when work should be transferred without duplicating existing artifacts.
---

# Handoff

## Purpose

Write a concise continuation document that preserves current state, source references, validation, and suggested next skills.

## When to Use

- Use when the user asks for a handoff.
- Use before ending a long session with incomplete work.
- Use when another agent should pick up the task.
- Use when context is large but existing artifacts already hold some details.
- Use when a workflow `Context Continuity` checkpoint is needed before a phase change, large edit, validation pass, or context loss.

## When Not to Use

- Do not use for normal final summaries when no continuation is needed.
- Do not duplicate PRDs, ADRs, issues, commits, diffs, or plans.
- Do not include secrets or sensitive personal data.

## Required Inputs

- Current goal and status.
- Files changed or inspected.
- Commands run and validation results.
- Existing artifacts that should be linked instead of duplicated.
- Focus for the next session, if provided by the user.
- Workflow name, current phase, completed steps, pending steps, blockers, risks, and exact next action when creating a continuity checkpoint.

## Workflow

1. Identify what a fresh agent needs to continue safely.
2. Reference existing durable artifacts by path or URL instead of copying them.
3. Summarize current state, decisions, blockers, and next actions.
4. Include suggested skills for the next agent.
5. For workflow checkpoints, include objective, success criteria, files inspected or changed, commands run, validation results, assumptions, blockers, risks, exact next action, and recommended skills or subagents.
6. Redact secrets, tokens, credentials, and personal data.
7. Save the handoff document to the OS temporary directory, not the workspace, unless the user or active workflow explicitly requires a project-local generated-output location.
8. Report the absolute path to the user.

## Quality Gates

- A fresh agent can continue without reconstructing the full conversation.
- Existing artifacts are referenced rather than duplicated.
- Sensitive data is omitted or redacted.
- The handoff names suggested next skills.
- The file is saved outside the repository unless the user asked otherwise.
- Workflow checkpoints identify the current phase and exact next action.

## Anti-Patterns

- Writing a long transcript recap.
- Storing temporary handoff files in the repo by default.
- Omitting validation results.
- Leaving out unresolved blockers.

## Output Format

```markdown
Handoff Created:
- Path:

Contains:
- Goal:
- Current state:
- Suggested skills:
- Next action:
```

## References

No bundled references are required.
