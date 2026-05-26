# Azure DevOps PR Command Reference

Use placeholders for private values. Do not commit real organization URLs, project names, repository names, reviewer identities, or tokens to reusable repository files.

## Setup

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

Use `az devops login --organization "<organization-url>"` only when the repo or environment requires PAT authentication. Prefer interactive Entra authentication where available.

## Create Or Update A PR

```powershell
git status --short
git switch -c "<branch-name>"
git push -u origin "<branch-name>"

az repos pr create `
  --repository "<repository-name>" `
  --source-branch "<branch-name>" `
  --target-branch "<target-branch>" `
  --title "<title>" `
  --description "<description>" `
  --draft true `
  --work-items <work-item-id>
```

```bash
git status --short
git switch -c "<branch-name>"
git push -u origin "<branch-name>"

az repos pr create \
  --repository "<repository-name>" \
  --source-branch "<branch-name>" \
  --target-branch "<target-branch>" \
  --title "<title>" \
  --description "<description>" \
  --draft true \
  --work-items <work-item-id>
```

Useful follow-up checks:

```powershell
az repos pr show --id <pr-id> --output json
az repos pr work-item list --id <pr-id> --output table
az repos pr reviewer list --id <pr-id> --output table
az repos pr policy list --id <pr-id> --output table
```

## Reviewer, Vote, And Completion Gates

Add reviewers only when repo instructions identify required reviewers or reviewer groups:

```powershell
az repos pr reviewer add --id <pr-id> --reviewers "<reviewer-or-group>"
```

Vote only when explicitly delegated:

```powershell
az repos pr set-vote --id <pr-id> --vote approve
az repos pr set-vote --id <pr-id> --vote wait-for-author
```

Set auto-complete only after required local validation passes and branch policies are expected to pass:

```powershell
az repos pr update --id <pr-id> --auto-complete true --delete-source-branch true --transition-work-items true
```

Complete immediately only when explicitly authorized and all required checks are satisfied:

```powershell
az repos pr update --id <pr-id> --status completed --delete-source-branch true --transition-work-items true
```

Do not use `--bypass-policy` unless a human explicitly authorizes the exact reason in the current task.

## Official References

- Azure DevOps CLI: <https://learn.microsoft.com/en-us/azure/devops/cli/>
- Azure DevOps CLI authentication: <https://learn.microsoft.com/en-us/azure/devops/cli/log-in-via-pat>
- Azure Repos PR commands: <https://learn.microsoft.com/en-us/cli/azure/repos/pr>
- Create Azure Repos pull requests: <https://learn.microsoft.com/en-us/azure/devops/repos/git/pull-requests>
- Complete Azure Repos pull requests: <https://learn.microsoft.com/en-us/azure/devops/repos/git/complete-pull-requests>
