---
name: documentation-and-adrs
description: Create or update developer documentation and architecture decision records from inspected source context. Use when an agent needs to document behavior, setup, workflows, APIs, architecture, tradeoffs, or durable decisions without inventing project facts.
---

# Documentation And ADRs

## Purpose

Produce accurate, maintainable documentation and decision records grounded in source material, current behavior, and explicit decisions.

## When to Use

- Use when the user asks for docs, README updates, guides, runbooks, or ADRs.
- Use when behavior or architecture changed and documentation must stay aligned.
- Use when a technical decision needs context, options, consequences, and status.
- Use when onboarding material or operational instructions are missing.

## When Not to Use

- Do not use for code-only changes unless documentation is part of the requested outcome.
- Do not invent requirements, decisions, commands, or architecture facts.
- Do not create ADRs for trivial implementation details without durable consequence.

## Required Inputs

- Documentation target, audience, and intended use.
- Relevant source files, configs, tests, commands, or design notes.
- Decision status for ADRs: proposed, accepted, superseded, or rejected.
- Validation commands or examples, Windows-first with Linux alternatives where useful.
- Existing documentation style and location.

## Workflow

1. Inspect existing docs and source before writing.
2. Identify the exact behavior, command, workflow, or decision to document.
3. Choose the right artifact: inline docs, guide, README section, runbook, or ADR.
4. Write only durable information that a future agent or developer can verify.
5. For ADRs, include context, decision, considered options, consequences, and status.
6. Link to relevant source, commands, or related docs when useful.
7. Check the documentation against current files and commands.

## Quality Gates

- Documentation matches inspected source and current behavior.
- Setup, test, build, or operational commands are executable as written or clearly marked as examples.
- ADRs include context, decision, consequences, and status.
- The doc has a clear audience and maintenance owner or location.
- No stale or project-specific facts are invented.

## Anti-Patterns

- Writing aspirational docs that do not match code.
- Duplicating long content already maintained elsewhere.
- Using documentation to hide unresolved technical decisions.
- Adding generic explanations for concepts the repository does not need.
- Creating ADRs after the fact without recording actual tradeoffs.

## Output Format

```markdown
Documentation Result:
- Artifact:
- Audience:
- Source basis:
- Key updates:

Changed Files:
- 

Validation:
- 

Open Questions:
- 
```

## References

No bundled references are required. Add ADR templates or documentation examples to `references/` only if repeated use justifies them.
