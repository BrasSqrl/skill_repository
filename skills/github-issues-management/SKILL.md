---
name: github-issues-management
description: Create, update, link, and summarize GitHub issues from plans, bugs, PRs, review findings, and delivery handoffs. Use when an agent is authorized to manage GitHub issue traceability for software development work.
---

# GitHub Issues Management

## Purpose

Manage GitHub issue traceability without turning backlog ownership into unreviewed agent automation.

## When to Use

- Use when the user asks to create or update GitHub issues from a plan, bug, PR, review, or handoff.
- Use when a PR must link to or close issues for traceability.
- Use when implementation work needs acceptance criteria, labels, milestones, projects, or discussion notes recorded in GitHub.

## When Not to Use

- Do not use for Azure Boards or non-GitHub issue trackers.
- Do not use when repository issue templates, labels, milestones, or project rules are unknown.
- Do not close, assign, prioritize, label, or move issues unless explicitly authorized.

## Required Inputs

- GitHub host, owner, repository, and issue/project conventions when known.
- Issue title, body, acceptance criteria, labels, milestone, assignees, project, and linked PR when applicable.
- Allowed issue actions and field changes from the user or target repo instructions.
- Existing issue IDs when updating or linking work.

## Workflow

1. Confirm GitHub CLI availability, authentication, repository target, and required scopes.
2. Identify whether the task requires a new issue, an update, a linked branch, a PR link, or a closing reference.
3. Convert source context into concise title, body, acceptance criteria, labels, and validation notes.
4. Create or update only authorized fields and preserve existing assignee, milestone, labels, and state unless instructed.
5. Link implementation through PR body references, issue development branches, comments, or project fields when required.
6. Read back the issue or PR links and verify the intended changes.
7. Report issue numbers, links, changed fields, rationale, and any policy or permission gaps.

## Quality Gates

- Issue content is specific, testable, and derived from source context.
- State, assignment, label, milestone, and project changes are authorized.
- PR links, closing keywords, and project references are verified after update.
- No tokens, private repo names, owner names, or user identities are written into reusable repo files.
- The final report lists every changed field and why it changed.

## Anti-Patterns

- Creating vague issues that an implementation agent cannot execute.
- Closing issues because a local change appears complete without PR and policy confirmation.
- Using issue updates as a substitute for a PR description or release note.
- Creating duplicate issues instead of checking an existing ID supplied by the user.
- Embedding one organization's label or project names into reusable skill content.

## Output Format

```markdown
GitHub Issue Update:
- Action:
- Issues:
- Linked PRs Or Branches:
- Fields Changed:
- Source Basis:
- Validation:
- Risks Or Manual Follow-Up:
```

## References

- `references/github-issues-command-reference.md`: Use for issue create, edit, develop, and PR linking command examples.
