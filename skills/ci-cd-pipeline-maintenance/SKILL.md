---
name: ci-cd-pipeline-maintenance
description: Maintain CI/CD pipelines, workflow jobs, caches, artifacts, secrets, deployment gates, and release automation. Use when checks fail, workflows are added or changed, pipelines are slow or flaky, or deployment automation needs safer validation.
---

# CI/CD Pipeline Maintenance

## Purpose

Keep automation reliable, reproducible, secure, and fast enough to support development and release workflows.

## When to Use

- Use when CI checks fail, become flaky, or diverge from local validation.
- Use when adding or changing build, test, lint, package, deploy, or release workflows.
- Use when cache, artifact, matrix, runner, or secret behavior changes.
- Use before release when automation is part of the delivery gate.

## When Not to Use

- Do not change deployment behavior without understanding environment and approval rules.
- Do not expose secrets through logs, artifacts, cache keys, or test output.
- Do not mask failing tests by removing checks without explicit approval.

## Required Inputs

- CI/CD platform files and job logs.
- Local equivalent commands for failing jobs.
- Required runtime versions, package managers, caches, and artifacts.
- Secret, environment, and deployment approval rules.
- Expected branch, tag, or release triggers.

## Workflow

1. Identify the first failing or unreliable job and its trigger.
2. Map CI steps to local commands and repository scripts.
3. Fix configuration, environment, cache, artifact, or command drift in the smallest slice.
4. Preserve required gates and security boundaries.
5. Add comments only where workflow behavior is non-obvious.
6. Dry-run locally where possible and rerun the relevant CI path.
7. Report changed jobs, validation evidence, and remaining platform-only risk.

## Quality Gates

- CI commands match documented local commands or explain necessary differences.
- Secrets are not printed, cached, or stored in artifacts.
- Cache keys are specific enough to avoid stale dependency reuse.
- Matrix jobs cover supported platforms and versions.
- Deployment jobs have explicit gates and target environments.

## Anti-Patterns

- Deleting failing jobs to make checks green.
- Mixing unrelated pipeline cleanup with a targeted fix.
- Adding broad permissions to avoid diagnosing access failures.
- Caching build outputs without invalidation rules.
- Assuming Linux-only behavior in a Windows-first repo.

## Output Format

```markdown
Pipeline Result:
- Workflow/job:
- Root cause:
- Changes:
- Security impact:
- Validation:
- Remaining CI-only risk:
```

## References

No bundled references are required. Add platform-specific workflow examples only when repeated use justifies them.
