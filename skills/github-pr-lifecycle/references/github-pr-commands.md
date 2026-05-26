# GitHub PR Command Reference

Use placeholders for private values. Do not commit real owner names, repository names, project names, reviewer identities, or tokens to reusable repository files.

## Setup

Windows:

```powershell
gh --version
gh auth status
gh auth login
gh repo view --json nameWithOwner,defaultBranchRef,url
```

Linux:

```bash
gh --version
gh auth status
gh auth login
gh repo view --json nameWithOwner,defaultBranchRef,url
```

Use `GH_TOKEN` only as a process-scoped environment variable for automation. Never write token values to repository files.

## Create Or Update A PR

```powershell
git status --short
git switch -c "<branch-name>"
git push -u origin "<branch-name>"

gh pr create `
  --repo "<owner>/<repo>" `
  --base "<target-branch>" `
  --head "<branch-name>" `
  --title "<title>" `
  --body "<body>" `
  --draft `
  --reviewer "<reviewer-or-team>" `
  --label "<label>"
```

```bash
git status --short
git switch -c "<branch-name>"
git push -u origin "<branch-name>"

gh pr create \
  --repo "<owner>/<repo>" \
  --base "<target-branch>" \
  --head "<branch-name>" \
  --title "<title>" \
  --body "<body>" \
  --draft \
  --reviewer "<reviewer-or-team>" \
  --label "<label>"
```

Use issue-closing keywords in the PR body only when the repo intends merge to close the issue, for example `Closes #123`.

Useful follow-up checks:

```powershell
gh pr view <pr-number> --json number,url,title,body,baseRefName,headRefName,isDraft,mergeable,mergeStateStatus,reviewDecision,statusCheckRollup,closingIssuesReferences
gh pr checks <pr-number>
gh pr diff <pr-number> --name-only
```

## Review And Merge Gates

Post comments or reviews only when explicitly delegated:

```powershell
gh pr comment <pr-number> --body-file "<comment-file>"
gh pr review <pr-number> --comment --body-file "<review-file>"
gh pr review <pr-number> --approve --body "<approval-note>"
gh pr review <pr-number> --request-changes --body-file "<review-file>"
```

Merge only after required validation and branch protection are satisfied:

```powershell
gh pr merge <pr-number> --squash --delete-branch
gh pr merge <pr-number> --auto --squash --delete-branch
```

Choose `--merge`, `--squash`, or `--rebase` according to target repo policy. Do not use admin bypass or force operations unless a human explicitly authorizes the exact reason in the current task.

## Official References

- GitHub CLI manual: <https://cli.github.com/manual/>
- `gh pr create`: <https://cli.github.com/manual/gh_pr_create>
- `gh pr edit`: <https://cli.github.com/manual/gh_pr_edit>
- `gh pr review`: <https://cli.github.com/manual/gh_pr_review>
- `gh pr merge`: <https://cli.github.com/manual/gh_pr_merge>
- `gh pr checks`: <https://cli.github.com/manual/gh_pr_checks>
