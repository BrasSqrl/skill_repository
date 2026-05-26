---
name: azure-boards-work-item-management
description: Create, update, link, and summarize Azure Boards work items from plans, bugs, PRs, review findings, and delivery handoffs. Use when an agent is authorized to manage Azure Boards traceability for software development work.
---

# Azure Boards Work Item Management

## Purpose

Manage Azure Boards work item traceability without turning backlog ownership into unreviewed agent automation.

## When to Use

- Use when the user asks to create or update Azure Boards work items from a plan, bug, PR, review, or handoff.
- Use when a PR must be linked to work items for policy or traceability.
- Use when implementation work needs acceptance criteria, task breakdown, state updates, or discussion notes recorded in Azure Boards.

## When Not to Use

- Do not use for non-Azure issue trackers.
- Do not use when the work item process, allowed types, or state transition rules are unknown.
- Do not reorder backlog priority, change ownership, or close work items unless explicitly authorized.

## Required Inputs

- Azure DevOps organization URL, project, and work item process details when known.
- Work item type, title, description, acceptance criteria, area, iteration, tags, and assigned user when applicable.
- PR ID or branch when linking work to implementation.
- Allowed field updates and state transitions from the user or target repo instructions.

## Workflow

1. Confirm Azure CLI, Azure DevOps extension, authentication, and default organization/project.
2. Identify whether the task requires a new work item, an update, a relation, or a PR link.
3. Convert source context into concise title, description, acceptance criteria, and validation notes.
4. Create or update only authorized fields and preserve existing owner, priority, and state unless instructed.
5. Link related work items, commits, or PRs when traceability is required.
6. Read back the changed work item or PR links and verify the intended fields changed.
7. Report IDs, links, changed fields, rationale, and any policy or permission gaps.

## Quality Gates

- Work item content is specific, testable, and derived from source context.
- State, assignment, priority, area, and iteration changes are authorized.
- PR links and parent/child/dependency relations are verified after update.
- No secrets, private URLs, or user identities are written into reusable repo files.
- The final report lists every changed field and why it changed.

## Anti-Patterns

- Creating vague backlog items that an implementation agent cannot execute.
- Changing state to done because a local change appears complete without repo policy confirmation.
- Using work item updates as a substitute for a PR description or release note.
- Creating duplicate work items instead of checking for an existing ID supplied by the user.
- Embedding one organization's process names into reusable skill content.

## Output Format

```markdown
Azure Boards Update:
- Action:
- Work Items:
- Linked PRs Or Relations:
- Fields Changed:
- Source Basis:
- Validation:
- Risks Or Manual Follow-Up:
```

## References

- `references/azure-boards-command-reference.md`: Use for work item create, update, relation, and PR linking command examples.
