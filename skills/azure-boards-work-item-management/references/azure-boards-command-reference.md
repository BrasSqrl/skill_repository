# Azure Boards Command Reference

Use placeholders for organization, project, area, iteration, assignee, and work item IDs.

## Setup

```powershell
az extension add --name azure-devops
az login
az devops configure --defaults organization="<organization-url>" project="<project-name>"
```

Linux uses the same Azure CLI commands.

For PAT-based environments, use `az devops login --organization "<organization-url>"` or a process-scoped `AZURE_DEVOPS_EXT_PAT`; do not write PAT values to files.

## Create A Work Item

```powershell
az boards work-item create `
  --type "User Story" `
  --title "<title>" `
  --description "<description>" `
  --fields "Microsoft.VSTS.Common.AcceptanceCriteria=<acceptance-criteria>" `
  --area "<area-path>" `
  --iteration "<iteration-path>"
```

Use the target project's process names. Common types vary by process, such as `Bug`, `Task`, `User Story`, `Issue`, or `Product Backlog Item`.

## Update A Work Item

```powershell
az boards work-item update `
  --id <work-item-id> `
  --discussion "<update-summary>" `
  --fields "System.State=<state>"
```

Only update state, assignment, priority, area, or iteration when the user or target repo instructions authorize those fields.

## Link Work Items To PRs

```powershell
az repos pr work-item add --id <pr-id> --work-items <work-item-id>
az repos pr work-item list --id <pr-id> --output table
```

## Review A Work Item

```powershell
az boards work-item show --id <work-item-id> --output json
```

## Official References

- Azure Boards work item commands: <https://learn.microsoft.com/en-us/cli/azure/boards/work-item>
- Azure Boards work item guidance: <https://learn.microsoft.com/en-us/azure/devops/boards/work-items/view-add-work-items>
- Azure Repos PR work item linking: <https://learn.microsoft.com/en-us/cli/azure/repos/pr>
