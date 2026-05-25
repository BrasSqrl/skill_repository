---
name: setup-agent-skills
description: Set up project-local agent instructions and support docs so workflow skills can use issue tracker, triage label, and domain documentation context. Use before issue triage, PRD creation, issue breakdown, diagnosis, architecture improvement, or when a repo lacks agent workflow context.
---

# Setup Agent Skills

## Purpose

Create or update a target repository's agent guidance so workflow skills know where issues live, how labels map, and where domain docs are maintained.

## When to Use

- Use before `triage`, `to-issues`, or `to-prd` in a repo without agent setup.
- Use when issue tracker, label vocabulary, or domain docs are unclear.
- Use when creating or updating an `AGENTS.md` agent skills section.

## When Not to Use

- Do not use when the target repo already has current agent setup docs.
- Do not assume one issue tracker without inspecting remotes and docs.
- Do not overwrite existing project instructions without preserving local content.

## Required Inputs

- Target repository root.
- Existing `AGENTS.md` or equivalent instruction files.
- Issue tracker location or repository remote, if any.
- Label vocabulary and domain documentation layout, if known.
- User approval for tracker and label decisions.

## Workflow

1. Inspect remotes, root agent instructions, context docs, ADRs, and existing `docs/agents/`.
2. Present findings and missing setup pieces.
3. Confirm issue tracker choice: GitHub, GitLab, local markdown, or other.
4. Confirm triage role label mappings.
5. Confirm domain docs layout: single context or multi-context.
6. Draft the `## Agent skills` block and support docs.
7. Update or create `AGENTS.md` and `docs/agents/*.md` after confirmation.
8. Report what was configured and when setup should be rerun.

## Quality Gates

- Existing instructions are updated in place rather than duplicated.
- Issue tracker and label mappings are explicit.
- Domain doc layout is recorded.
- User-approved choices are reflected in support docs.
- Setup does not assume a specific downstream tool beyond documented compatibility needs.

## Anti-Patterns

- Guessing label vocabulary.
- Creating docs before checking existing project instructions.
- Mixing project setup with implementation work.
- Re-running setup without a changed tracker, label, or docs layout.

## Output Format

```markdown
Agent Setup:
- Instruction file:
- Issue tracker:
- Triage labels:
- Domain docs:
- Files changed:
- Follow-up:
```

## References

- `references/issue-tracker-github.md`: Use when the target repo uses GitHub Issues.
- `references/issue-tracker-gitlab.md`: Use when the target repo uses GitLab Issues.
- `references/issue-tracker-local.md`: Use when issues are tracked as local markdown.
- `references/triage-labels.md`: Use when writing label mapping docs.
- `references/domain.md`: Use when documenting context and ADR layout.
