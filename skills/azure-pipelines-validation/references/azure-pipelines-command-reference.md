# Azure Pipelines Command Reference

Use placeholders for private organization, project, pipeline, build, branch, and PR values.

## Setup

```powershell
az extension add --name azure-devops
az login
az devops configure --defaults organization="<organization-url>" project="<project-name>"
```

Linux uses the same Azure CLI commands.

## Inspect PR Policy Status

```powershell
az repos pr show --id <pr-id> --output json
az repos pr policy list --id <pr-id> --output table
az repos pr policy queue --id <pr-id>
```

Queue policy evaluation only when the target repo allows it and the rerun is justified.

## Inspect Pipelines And Builds

```powershell
az pipelines list --output table
az pipelines show --id <pipeline-id> --output json
az pipelines build list --branch "<branch-name>" --reason pullRequest --top 10 --output table
az pipelines build show --id <build-id> --output json
```

If logs are only available through the Azure DevOps UI or protected endpoints, report the access blocker and provide the exact build or job link when available.

## Rerun Guidance

Rerun only when one of these is true:

- The failure is classified as transient infrastructure, agent allocation, timeout, or external service instability.
- The pipeline was blocked by missing permission and the permission has been restored.
- The branch was updated with a fix and the policy did not automatically requeue.

Do not rerun to hide deterministic test, compile, lint, security, or packaging failures.

## Official References

- Azure Pipelines CLI management: <https://learn.microsoft.com/en-us/azure/devops/pipelines/get-started/manage-pipelines-with-azure-cli>
- Azure Pipelines CLI commands: <https://learn.microsoft.com/en-us/cli/azure/pipelines>
- Azure Pipelines build commands: <https://learn.microsoft.com/en-us/cli/azure/pipelines/build>
- Azure Repos PR validation note: <https://learn.microsoft.com/en-us/azure/devops/pipelines/yaml-schema/pr>
