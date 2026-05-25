---
name: repo-onboarding
description: Onboard an AI coding agent to an unfamiliar software repository by mapping structure, stack, commands, conventions, tests, risks, and agent instructions. Use when starting work in a new repo, preparing a repo summary, or creating initial development context.
---

# Repo Onboarding

## Purpose

Create a practical repository map that lets an agent make safe first changes without guessing project structure or commands.

## When to Use

- Use at the start of work in an unfamiliar repository.
- Use when the user asks for a repo overview, map, or onboarding summary.
- Use before adding skills or project instructions to a target repository.
- Use when setup, test, lint, or build commands are not yet known.

## When Not to Use

- Do not use for a narrow task in a repo that is already understood.
- Do not produce an exhaustive inventory of every file.
- Do not replace task-specific context gathering when a concrete implementation task is already scoped.

## Required Inputs

- Repository root and current working directory.
- Existing agent instructions, README files, package manifests, config, and docs.
- Current worktree state.
- User's intended type of work, if known.
- Windows shell context first; Linux alternatives when the repo supports them.

## Workflow

1. Inspect root files, repository instructions, and directory layout.
2. Identify languages, frameworks, package managers, runtimes, and major entry points.
3. Locate setup, test, lint, build, format, and run commands.
4. Identify important directories, generated files, forbidden areas, and config boundaries.
5. Inspect existing tests and validation patterns.
6. Note risks, missing instructions, and commands that need confirmation.
7. Produce a compact onboarding summary useful for future tasks.

## Quality Gates

- The summary is based on inspected files, not guesses.
- Commands include Windows form first and Linux alternatives when known.
- Important directories and ownership boundaries are named.
- Unknowns are explicit and limited to meaningful gaps.
- The output is short enough to reuse as working context.

## Anti-Patterns

- Summarizing every folder without explaining why it matters.
- Assuming package manager or commands from file names alone when scripts are available.
- Running expensive setup before reading instructions.
- Ignoring existing agent guidance.
- Mixing onboarding with unrelated code changes.

## Output Format

```markdown
Repo Onboarding:
- Stack:
- Important directories:
- Setup:
- Test:
- Lint:
- Build:
- Run:
- Agent rules:
- Risks or unknowns:
- Recommended first task context:
```

## References

No bundled references are required. Add reusable onboarding report examples to `references/` only if needed.
