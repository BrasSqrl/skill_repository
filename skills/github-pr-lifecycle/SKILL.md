---
name: github-pr-lifecycle
description: Create, update, review, submit, enable auto-merge, or merge GitHub pull requests with guarded git and GitHub CLI steps. Use when an agent is explicitly authorized to operate a GitHub PR lifecycle for a private or team repository.
---

# GitHub PR Lifecycle

## Purpose

Operate GitHub pull requests with traceable git changes, linked issues, reviewer state, status checks, and explicit merge gates.

## When to Use

- Use when the user asks to create, update, review, submit, auto-merge, or merge a GitHub pull request.
- Use when target repo instructions authorize full PR lifecycle work through GitHub CLI.
- Use when branch, commit, PR metadata, reviewers, linked issues, and status checks must stay aligned.

## When Not to Use

- Do not use for Azure DevOps, GitLab, or generic review-only PR work.
- Do not use when GitHub owner, repository, branch, issue, or authorization is missing.
- Do not merge or enable auto-merge unless repo instructions or the user explicitly authorize that action.

## Required Inputs

- GitHub host, owner, repository, source branch, and target branch.
- PR objective, acceptance criteria, reviewer policy, and linked issue IDs when applicable.
- Local validation commands, required GitHub Actions checks, and branch protection expectations.
- Confirmation of allowed PR actions: create, update, comment, review, approve, request changes, auto-merge, merge, delete source branch, close issues.

## Workflow

1. Confirm working tree status, current branch, remote, target branch, and intended PR scope.
2. Verify GitHub CLI availability, authentication, repository target, and required scopes.
3. Create or update the branch with focused commits and push only intended changes.
4. Create or update the PR with title, body, target branch, draft state, reviewers, labels, projects, and linked issues.
5. Inspect linked issues, reviewer state, mergeability, review decision, comments, and status checks.
6. Run or confirm required local validation before requesting review or merge.
7. Approve, request changes, enable auto-merge, or merge only when explicitly authorized and branch protection is satisfied.
8. Report PR number, URL, branch, linked issues, validation evidence, check state, review state, and remaining manual action.

## Quality Gates

- The PR scope matches the committed diff and excludes unrelated work.
- Linked issues, title, body, reviewers, labels, projects, and target branch match repo instructions.
- Required local validation and GitHub status checks pass before merge or auto-merge.
- Admin bypass, force pushes, and destructive branch actions are not used unless explicitly authorized.
- Merge method, source-branch deletion, and issue-closing behavior match target repo policy.

## Anti-Patterns

- Creating a PR from a dirty or ambiguous working tree.
- Merging because local tests passed while required GitHub checks are pending or failed.
- Storing owner names, repo names, project names, tokens, or reviewer identities in reusable skill content.
- Posting comments or reviews without showing the user-facing text when approval is required.
- Treating GitHub as the agent harness; it is only the delivery platform.

## Output Format

```markdown
GitHub PR Lifecycle:
- Action:
- Repository:
- Source -> Target:
- PR:
- Issues:
- Reviewers:
- Validation:
- Check Status:
- Merge State:
- Risks Or Manual Follow-Up:
```

## References

- `references/github-pr-commands.md`: Use for guarded GitHub CLI command examples and merge gates.
