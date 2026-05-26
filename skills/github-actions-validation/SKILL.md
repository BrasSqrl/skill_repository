---
name: github-actions-validation
description: Inspect GitHub Actions runs, pull-request checks, branch protection status, logs, and rerun decisions. Use when an agent must diagnose or summarize GitHub CI status before PR merge or release handoff.
---

# GitHub Actions Validation

## Purpose

Classify GitHub Actions and pull-request check results so PR and release decisions are based on concrete check evidence.

## When to Use

- Use when GitHub PR checks, Actions workflows, branch protection, or required status checks are pending, failed, flaky, or unclear.
- Use when a PR merge decision depends on GitHub Actions status.
- Use when workflow failure output must be routed to debugging, dependency, CI/CD, or release-readiness workflows.

## When Not to Use

- Do not use for Azure Pipelines or non-GitHub CI providers.
- Do not use to deploy, approve environments, cancel runs, delete runs, or mutate workflow settings unless explicitly authorized.
- Do not rerun workflows when failures are caused by deterministic code, test, or configuration issues that should be fixed first.

## Required Inputs

- GitHub host, owner, repository, PR number, workflow name, run ID, branch, commit SHA, or failing check name.
- Target branch and expected branch protection or required checks.
- Relevant local validation commands and known environment constraints.
- Permission boundary for reruns, watching checks, or reading protected logs.

## Workflow

1. Confirm GitHub CLI availability, authentication, repository target, and required scopes.
2. Inspect PR checks, workflow runs, and the first failed or blocking check.
3. Capture failing workflow, job, step, error summary, exit code, and relevant log excerpt.
4. Compare the failure with local validation commands and repository workflow configuration.
5. Classify the cause as code, test, dependency, environment, workflow config, permission, or external service.
6. Rerun only failed jobs or runs when failure is likely transient and rerun is authorized.
7. Route fixes through debugging, dependency management, CI/CD maintenance, or release-readiness skills.
8. Report check state, failed job, evidence, classification, rerun status, and PR or release impact.

## Quality Gates

- The first actionable failure is identified before broad speculation.
- Protected or unavailable logs are reported as access blockers, not inferred.
- Rerun recommendations distinguish flaky/transient failures from deterministic failures.
- PR merge is blocked when required checks are failed, pending, cancelled, or unknown.
- The final output includes exact command sources or UI locations inspected.

## Anti-Patterns

- Treating local success as equivalent to GitHub required check success.
- Rerunning failed workflows repeatedly without classifying the failure.
- Editing workflow YAML before reading the failing job and step.
- Ignoring branch protection or rulesets when PR checks appear green but merge remains blocked.
- Reporting generic CI failure summaries without evidence.

## Output Format

```markdown
GitHub Actions Validation:
- Scope:
- Check Or Workflow Status:
- First Actionable Failure:
- Evidence:
- Local Equivalent:
- Classification:
- Recommended Next Action:
- PR Or Release Impact:
```

## References

- `references/github-actions-command-reference.md`: Use for GitHub Actions, PR checks, run inspection, and rerun command examples.
