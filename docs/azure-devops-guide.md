# Azure DevOps Guide

## Purpose

Use this guide when installing or invoking this repository's optional Azure DevOps delivery skills. Azure DevOps is treated as a delivery platform for Azure Repos, Azure Boards, and Azure Pipelines, not as an agent harness.

## Install The Azure DevOps Bundle

Windows:

```powershell
.\scripts\install-skills.ps1 -Harness opencode -Bundle azure-devops-delivery -IncludeAgents -AgentBundle azure-devops-review
.\scripts\install-skills.ps1 -Harness claude-code -Bundle azure-devops-delivery -IncludeAgents -AgentBundle azure-devops-review
```

Linux:

```bash
bash ./scripts/install-skills.sh --harness opencode --bundle azure-devops-delivery --include-agents --agent-bundle azure-devops-review
bash ./scripts/install-skills.sh --harness claude-code --bundle azure-devops-delivery --include-agents --agent-bundle azure-devops-review
```

Use `-DryRun` or `--dry-run` before replacing existing installed skills or agents.

## Target Repo Setup

Copy or bootstrap `templates/project-AGENTS.md` into the target repo and fill in:

- Azure DevOps organization URL
- project name
- repository name
- default target branch
- branch naming convention
- allowed PR actions
- work item process and allowed fields
- reviewer and policy requirements
- pipeline validation commands
- PR completion and auto-complete rules

Do not store secrets, PAT values, private organization URLs, project names, or repository names in this reusable repository.

## Azure CLI Setup

Windows:

```powershell
az --version
az extension add --name azure-devops
az extension update --name azure-devops
az login
az devops configure --defaults organization="<organization-url>" project="<project-name>"
```

Linux:

```bash
az --version
az extension add --name azure-devops
az extension update --name azure-devops
az login
az devops configure --defaults organization="<organization-url>" project="<project-name>"
```

Use PAT authentication only when required by the environment:

```powershell
az devops login --organization "<organization-url>"
```

For non-interactive automation, use a process-scoped `AZURE_DEVOPS_EXT_PAT`. Never write token values to repository files.

## Common Workflows

- Use `workflows/azure-devops-work-item-to-pr.md` to turn an Azure Boards item into branch work, implementation, validation, and a linked PR.
- Use `workflows/azure-devops-pr-lifecycle.md` to create, update, validate, submit, auto-complete, or complete an Azure Repos PR.
- Use `workflows/azure-devops-pipeline-response.md` to diagnose failed Azure Pipelines or branch-policy validation.
- Use subagent `azure-devops-pr-reviewer` for read-only review of PR metadata, linked work items, reviewer state, branch policies, and CI status.

## Safety Rules

- Create or update PRs only when the user asks or target repo instructions authorize it.
- Complete or auto-complete PRs only after required local validation and Azure policy checks pass.
- Do not use `--bypass-policy` unless a human explicitly authorizes that exact action.
- Do not update work item state, priority, assignment, area, or iteration unless authorized.
- Report every work item field changed and every PR action taken.

## Official References

- Azure DevOps CLI: <https://learn.microsoft.com/en-us/azure/devops/cli/>
- Azure DevOps CLI authentication: <https://learn.microsoft.com/en-us/azure/devops/cli/log-in-via-pat>
- Azure Repos PRs: <https://learn.microsoft.com/en-us/azure/devops/repos/git/pull-requests>
- Azure Boards work item CLI: <https://learn.microsoft.com/en-us/cli/azure/boards/work-item>
- Azure Pipelines CLI: <https://learn.microsoft.com/en-us/azure/devops/pipelines/get-started/manage-pipelines-with-azure-cli>
