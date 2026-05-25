---
name: pull-request-prep
description: Prepare software changes for review by inspecting the final diff, running validation, summarizing behavior, noting tests, and identifying risks. Use before opening, updating, or handing off a pull request or equivalent code review package.
---

# Pull Request Prep

## Purpose

Create a reviewer-ready summary of a change set with accurate scope, validation evidence, and known risks.

## When to Use

- Use before opening or updating a pull request.
- Use when handing off local changes for review.
- Use after implementation when the final diff needs cleanup and explanation.
- Use when the user asks for PR title, description, checklist, or review notes.

## When Not to Use

- Do not use as a substitute for code review when defect-finding is the primary task.
- Do not use before implementation is complete enough to summarize.
- Do not invent validation results or review approvals.

## Required Inputs

- Current diff, changed files, branch, or commit range.
- User-facing behavior and task context.
- Tests, lint, build, and other validation commands.
- Known risks, follow-ups, migrations, dependency changes, or docs changes.
- Review destination format when known, without assuming a specific hosting platform.

## Workflow

1. Inspect the final diff and current worktree state.
2. Confirm the change scope matches the requested work.
3. Run or collect relevant validation, using Windows commands first and Linux alternatives where useful.
4. Identify user-facing changes, internal changes, tests, docs, migrations, and dependencies.
5. Note risks, skipped checks, rollout concerns, and follow-up tasks.
6. Draft a concise title and review description.
7. Include a validation checklist with exact commands and outcomes.

## Quality Gates

- The summary matches the actual diff.
- Validation results are real and include skipped checks with reasons.
- Risks and follow-ups are explicit.
- The PR text is concise and reviewer-oriented.
- No unrelated changes are hidden in the summary.

## Anti-Patterns

- Writing a marketing-style PR description.
- Claiming tests passed without running or seeing evidence.
- Omitting migrations, config, dependency, or docs impacts.
- Describing intended work instead of actual changes.
- Mixing new implementation work into final prep unless needed to fix an obvious issue.

## Output Format

```markdown
Title:

Summary:
- 

Validation:
- 

Risks And Follow-Ups:
- 

Reviewer Notes:
- 
```

## References

No bundled references are required. Add PR templates to `references/` only when repeated formats justify them.
