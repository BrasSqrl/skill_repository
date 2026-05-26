---
name: context-engineering
description: Gather, compress, refresh, and preserve working context for AI-assisted software-development tasks. Use when an agent needs to understand a repository area, recover after context loss, prepare a handoff, identify relevant files and commands, or separate facts, assumptions, and open questions before coding.
---

# Context Engineering

## Purpose

Build the smallest accurate context set needed for the current task and produce a reusable context packet for planning, implementation, review, or continuation.

## When to Use

- Use at the start of unfamiliar or multi-file work.
- Use when resuming after context loss, interruption, or a long debugging loop.
- Use before planning, implementation, review, or handoff when relevant files and commands are not obvious.
- Use when the user asks for a repo map, task context, or compact summary.

## When Not to Use

- Do not use for a single obvious command or trivial file lookup.
- Do not use to replace a task-specific skill when the necessary context is already known.
- Do not create broad architecture summaries unless the task needs them.

## Required Inputs

- User goal, issue, bug report, or requested outcome.
- Repository root and current working directory.
- Current worktree state, including uncommitted changes when available.
- Known constraints, deadlines, forbidden files, or validation commands.
- Windows command environment first; Linux shell alternatives when the target repo supports them.

## Permitted Actions

- Inspect repository instructions, manifests, source files, tests, docs, logs, and diffs.
- Run read-only discovery commands and targeted validation only when needed to identify context.
- Do not edit files unless another loaded skill or the user request authorizes implementation.

## Workflow

1. Inspect repository instructions, root files, and current status before drawing conclusions.
2. Locate likely source files with fast search tools and directory listings.
3. Identify authoritative context: code, tests, docs, schemas, config, logs, and recent diffs.
4. Separate facts from assumptions and list open questions only when they block progress.
5. Reduce context to the files, symbols, commands, and decisions needed for the next task.
6. Refresh the context after edits, new failures, user changes, or branch changes.
7. Produce a compact context summary that another agent could continue from.

## Stop Condition

- Stop successfully when the next agent action has enough files, commands, facts, assumptions, and blockers to proceed.
- Stop blocked when the task requires unavailable private systems, missing files, contradictory instructions, or a user decision.

## Quality Gates

- The summary names concrete files, commands, or artifacts.
- Claims are grounded in inspected source or explicitly marked as assumptions.
- The context set is scoped to the current task.
- User or pre-existing changes are identified and not overwritten.
- Open questions are limited to blockers.
- The output contract is a compact context packet, not a broad repo essay.

## Anti-Patterns

- Reading the entire repository when targeted search is enough.
- Treating generated summaries as source of truth without checking files.
- Mixing assumptions into facts.
- Keeping stale context after edits or test failures.
- Producing a long narrative instead of actionable context.

## Output Format

```markdown
Context:
- Goal:
- Relevant files:
- Relevant commands:
- Facts:
- Assumptions:
- Open questions:
- Recommended next step:
```

## References

- `references/context-compaction-checklist.md`: Use when preparing a compact task summary, handoff, or context refresh after a long work session.
