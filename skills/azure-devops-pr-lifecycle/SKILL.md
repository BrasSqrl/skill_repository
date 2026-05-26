---
name: azure-devops-pr-lifecycle
description: Create, update, validate, submit, auto-complete, or complete Azure DevOps pull requests with guarded git and Azure CLI steps. Use when an agent is explicitly authorized to operate an Azure Repos PR lifecycle for a private or team repository.
---

# Azure DevOps PR Lifecycle

## Purpose

Operate Azure Repos pull requests with traceable git changes, work item links, reviewer state, policy validation, and explicit completion gates.

## When to Use

- Use when the user asks to create, update, submit, auto-complete, or complete an Azure DevOps pull request.
- Use when target repo instructions authorize full PR lifecycle work through Azure Repos.
- Use when branch, commit, PR metadata, reviewers, linked work items, and policy status must stay aligned.

## When Not to Use

- Do not use for GitHub, GitLab, or generic review-only PR work.
- Do not use when Azure DevOps organization, project, repository, branch, or authorization is missing.
- Do not complete or auto-complete a PR unless repo instructions or the user explicitly authorize that action.

## Required Inputs

- Azure DevOps organization URL, project, repository, source branch, and target branch.
- PR objective, acceptance criteria, reviewer policy, and work item IDs when applicable.
- Local validation commands and Azure Pipelines or branch-policy expectations.
- Confirmation of allowed PR actions: create, update, vote, auto-complete, complete, delete source branch, transition work items.

## Workflow

1. Confirm the working tree status, current branch, target branch, and intended PR scope.
2. Verify Azure CLI, Azure DevOps extension, authentication, and configured organization/project.
3. Create or update the branch with focused commits and push only intended changes.
4. Create or update the PR with title, description, target branch, reviewers, draft state, and linked work items.
5. Inspect linked work items, reviewer state, merge conflicts, and PR policy results.
6. Run or confirm required local validation before requesting completion.
7. Complete or set auto-complete only when validation passes, required review state is satisfied, and bypass is not used.
8. Report PR ID, URL, branch, linked work items, validation evidence, policy state, and any remaining manual action.

## Quality Gates

- The PR scope matches the committed diff and excludes unrelated work.
- Work item links, title, description, reviewers, and target branch match repo instructions.
- Required local validation and Azure policy status are passing or explicitly escalated.
- `--bypass-policy` is not used unless a human explicitly approves it for a documented emergency.
- Completion actions preserve the target repo's merge, source-branch, and work-item transition policy.

## Anti-Patterns

- Creating a PR from a dirty or ambiguous working tree.
- Completing a PR because local tests passed while branch policies are still pending or failed.
- Storing organization URLs, project names, repo names, PATs, or reviewer identities in reusable skill content.
- Updating work item state without recording the changed fields and rationale.
- Treating Azure DevOps as the agent harness; it is only the delivery platform.

## Output Format

```markdown
Azure DevOps PR Lifecycle:
- Action:
- Organization/Project/Repository:
- Source -> Target:
- PR:
- Work Items:
- Reviewers:
- Validation:
- Policy Status:
- Completion State:
- Risks Or Manual Follow-Up:
```

## References

- `references/azure-devops-pr-commands.md`: Use for guarded Azure CLI command examples and completion gates.
