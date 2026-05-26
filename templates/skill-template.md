---
name: replace-with-kebab-case-name
description: State the workflow, trigger condition, expected output, and use boundary. Use when an AI coding agent must perform this exact repeatable task.
---

# Replace With Skill Title

## Purpose

State the concrete engineering capability this skill provides. Treat the skill like a small callable program: identify the input state it handles and the output state it must produce.

## When to Use

- Use when `<trigger condition>`.
- Use when `<task type>`.
- Use when `<failure mode or workflow need>`.

## When Not to Use

- Do not use when `<narrower skill or simpler workflow applies>`.
- Do not use when `<required input is missing and cannot be discovered>`.
- Do not use when a more specific existing skill covers the task better.

## Required Inputs

- `<repository context, file paths, issue links, logs, screenshots, API docs, or user decisions>`
- `<required commands or environment details>`
- `<acceptance criteria or expected output>`

## Permitted Actions

- `<files, commands, analysis, or review actions the agent may perform>`
- `<whether edits, validation commands, or read-only inspection are allowed>`

## Workflow

1. Inspect the relevant source context.
2. Identify constraints, assumptions, and open questions.
3. Make the smallest useful change or produce the requested analysis.
4. Run the relevant verification steps.
5. Stop when the output contract and validation gate are satisfied, or when a blocker prevents safe completion.

## Stop Condition

- Stop successfully when `<observable completion state>`.
- Stop blocked when `<missing input, failed gate, unsafe operation, or approval boundary>`.

## Quality Gates

- The agent has read the relevant source files before making claims.
- The work is scoped to the requested task.
- The output includes concrete verification evidence.
- The result does not introduce tool-specific assumptions.
- The stop condition is met or the blocker is explicit.

## Anti-Patterns

- Avoid vague prompt advice.
- Avoid broad rewrites unrelated to the task.
- Avoid repeating long examples in `SKILL.md`; move them to `references/`.
- Avoid claiming validation passed when commands were not run.

## Output Format

Use this format unless the user asks for a different one:

```markdown
Summary:
- <brief outcome>

Changed Files:
- <path and purpose>

Validation:
- <command and result>

Risks:
- <remaining risk or "None known">
```

## References

- `references/<file-name>.md`: Read when `<specific condition>`.
