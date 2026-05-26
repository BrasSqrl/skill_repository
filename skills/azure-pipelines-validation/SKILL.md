---
name: azure-pipelines-validation
description: Inspect Azure Pipelines and Azure Repos branch-policy validation for failed checks, logs, gates, and rerun decisions. Use when an agent must diagnose or summarize Azure DevOps CI status before PR completion or release handoff.
---

# Azure Pipelines Validation

## Purpose

Classify Azure Pipelines and branch-policy validation results so PR and release decisions are based on concrete check evidence.

## When to Use

- Use when Azure DevOps PR policies, build validation, or pipeline checks are pending, failed, flaky, or unclear.
- Use when a PR completion decision depends on Azure Pipelines status.
- Use when pipeline failure output must be routed to debugging, dependency, CI/CD, or release-readiness workflows.

## When Not to Use

- Do not use for non-Azure CI providers.
- Do not use to deploy, release, approve environments, or mutate pipeline settings unless explicitly authorized.
- Do not rerun pipelines when failures are caused by deterministic code, test, or configuration issues that should be fixed first.

## Required Inputs

- Azure DevOps organization URL, project, repository, PR ID, pipeline ID, build ID, or failing policy name.
- Target branch, source branch, and expected validation policy.
- Relevant local validation commands and known environment constraints.
- Permission boundary for reruns, queueing policy evaluation, or reading protected logs.

## Workflow

1. Confirm Azure CLI, Azure DevOps extension, authentication, and configured defaults.
2. Inspect PR policy status, pipeline/build list, and the first failed or blocking check.
3. Capture failing job, stage, task, error summary, exit code, and relevant log excerpt.
4. Compare the failure with local validation commands and repository CI configuration.
5. Classify the cause as code, test, dependency, environment, pipeline config, permission, or external service.
6. Rerun or queue policy evaluation only when failure is likely transient and rerun is authorized.
7. Route fixes through debugging, dependency management, CI/CD maintenance, or release-readiness skills.
8. Report policy state, failed checks, evidence, classification, and next action.

## Quality Gates

- The first actionable failure is identified before broad speculation.
- Protected or unavailable logs are reported as access blockers, not inferred.
- Rerun recommendations distinguish flaky/transient failures from deterministic failures.
- PR completion is blocked when required policy status is failed, pending, or unknown.
- The final output includes exact command sources or UI locations inspected.

## Anti-Patterns

- Treating local success as equivalent to Azure policy success.
- Rerunning failed pipelines repeatedly without classifying the failure.
- Editing pipeline YAML before reading the failing stage and task.
- Ignoring branch policy configuration when YAML PR triggers do not apply to Azure Repos.
- Reporting generic CI failure summaries without evidence.

## Output Format

```markdown
Azure Pipelines Validation:
- Scope:
- Policy Or Pipeline Status:
- First Actionable Failure:
- Evidence:
- Local Equivalent:
- Classification:
- Recommended Next Action:
- PR Or Release Impact:
```

## References

- `references/azure-pipelines-command-reference.md`: Use for Azure Pipelines, build, and PR policy command examples.
