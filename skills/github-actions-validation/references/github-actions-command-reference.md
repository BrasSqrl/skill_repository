# GitHub Actions Command Reference

Use placeholders for private owner, repo, PR number, workflow, run, branch, and commit values.

## Setup

```powershell
gh --version
gh auth status
gh auth login
gh repo view "<owner>/<repo>" --json nameWithOwner,url
```

Linux uses the same GitHub CLI commands.

## Inspect PR Checks

```powershell
gh pr checks <pr-number> --repo "<owner>/<repo>"
gh pr view <pr-number> --repo "<owner>/<repo>" --json statusCheckRollup,mergeStateStatus,reviewDecision,mergeable
gh pr status --repo "<owner>/<repo>" --conflict-status
```

## Inspect Workflow Runs

```powershell
gh run list --repo "<owner>/<repo>" --branch "<branch-name>" --limit 10
gh run view <run-id> --repo "<owner>/<repo>" --log
gh run view <run-id> --repo "<owner>/<repo>" --json jobs,conclusion,status,url
```

Watch a run only when useful for a merge or release decision:

```powershell
gh run watch <run-id> --repo "<owner>/<repo>" --compact --exit-status
```

## Rerun Guidance

Rerun only when one of these is true:

- The failure is classified as transient infrastructure, runner allocation, timeout, or external service instability.
- Required credentials or permissions were restored.
- The branch was updated with a fix and checks did not automatically requeue.

Commands:

```powershell
gh run rerun <run-id> --repo "<owner>/<repo>" --failed
```

Do not rerun to hide deterministic test, compile, lint, security, or packaging failures.

## Official References

- `gh pr checks`: <https://cli.github.com/manual/gh_pr_checks>
- `gh pr status`: <https://cli.github.com/manual/gh_pr_status>
- `gh run list`: <https://cli.github.com/manual/gh_run_list>
- `gh run view`: <https://cli.github.com/manual/gh_run_view>
- `gh run watch`: <https://cli.github.com/manual/gh_run_watch>
- `gh run rerun`: <https://cli.github.com/manual/gh_run_rerun>
