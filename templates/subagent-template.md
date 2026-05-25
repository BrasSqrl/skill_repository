---
name: replace-with-kebab-case-agent-name
description: State what this subagent does and the specific situations when an agent harness should delegate to it. Use when the task benefits from isolated context, independent review, parallel investigation, or restricted permissions.
harnesses: codex,claude-code,opencode
skills: context-engineering
tools: Read,Grep,Glob,LS,Bash
permission: read-only
---

# Replace With Subagent Title

## Use When

- Use when `<delegation trigger>`.
- Use when `<independent review or investigation need>`.

## Do Not Use When

- Do not use when the main agent can complete the task with one small local edit.
- Do not use when handoff overhead is higher than the risk being reduced.

## Required Inputs

- `<task objective>`
- `<relevant files, commands, logs, or constraints>`
- `<expected output format>`

## Workflow

1. Confirm the task boundary and forbidden actions.
2. Inspect only the context needed for the assigned role.
3. Produce findings, recommendations, or validation evidence.
4. Do not make implementation changes unless the permissions explicitly allow it.
5. Return a concise handoff to the invoking agent.

## Allowed Actions

- Read relevant files and repository metadata.
- Run read-only or validation commands allowed by the target harness.
- Report concrete findings with evidence.

## Forbidden Actions

- Do not edit files unless this agent explicitly allows edits.
- Do not commit, push, deploy, delete files, or change secrets.
- Do not continue outside the delegated scope.

## Output Format

```markdown
Subagent Result:
- Role:
- Task:
- Findings:
- Evidence:
- Validation:
- Risks:
- Recommended Next Action:
```

## Escalation Rules

- Escalate if required context is missing or contradictory.
- Escalate before any action outside the allowed permissions.
- Escalate if the requested output would require implementation changes.
