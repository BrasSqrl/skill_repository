# Azure DevOps Delivery Add-On

Copy this section into a target repo `AGENTS.md` only when the project uses Azure Repos, Azure Boards, or Azure Pipelines.

## Azure DevOps Delivery

- Organization URL: `<Azure DevOps organization URL, or "not used">`
- Project: `<Azure DevOps project name>`
- Repository: `<Azure Repos repository name>`
- Default target branch: `<main branch>`
- Branch naming: `<branch prefix and work item convention>`
- PR authority: `<review only, create/update, vote, auto-complete, complete>`
- Work item process: `<Basic, Agile, Scrum, CMMI, or custom>`
- Allowed work item changes: `<types, fields, and state transitions agents may update>`
- Reviewer policy: `<required reviewers, groups, or approval rules>`
- Pipeline validation: `<required Azure Pipelines or branch-policy checks>`
- Completion rules: `<merge strategy, source branch deletion, work item transition, auto-complete rules>`

Agents may use Azure DevOps PR or work item skills only when this section authorizes the action or the user explicitly asks for that action. Agents must not use policy bypass, mutate pipeline secrets, or complete PRs with failed, pending, or unknown required policies unless a human explicitly authorizes the exact exception.

## Azure DevOps Validation Checklist

- [ ] `az extension add --name azure-devops` has been completed or the extension is already available.
- [ ] `az devops configure` organization and project are confirmed outside this reusable repo.
- [ ] Source branch and target branch are confirmed.
- [ ] Branch policies and pipeline validation are known.
- [ ] Work item linking and state transitions are authorized.
- [ ] Completion or auto-complete authority is explicit.
