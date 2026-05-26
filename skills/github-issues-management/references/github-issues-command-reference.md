# GitHub Issues Command Reference

Use placeholders for owner, repo, issue, labels, milestones, assignees, and projects.

## Setup

```powershell
gh --version
gh auth status
gh auth login
gh repo view "<owner>/<repo>" --json nameWithOwner,hasIssuesEnabled,url
```

Linux uses the same GitHub CLI commands.

For automation, use process-scoped `GH_TOKEN`. Never write token values to repository files.

## Create An Issue

```powershell
gh issue create `
  --repo "<owner>/<repo>" `
  --title "<title>" `
  --body "<body>" `
  --label "<label>" `
  --milestone "<milestone>" `
  --assignee "<login>"
```

Adding issues to GitHub Projects can require additional authorization:

```powershell
gh auth refresh -s project
gh issue create --repo "<owner>/<repo>" --title "<title>" --body "<body>" --project "<project-title>"
```

## Update An Issue

```powershell
gh issue edit <issue-number> `
  --repo "<owner>/<repo>" `
  --title "<title>" `
  --body-file "<body-file>" `
  --add-label "<label>" `
  --remove-label "<label>"
```

Only update state, assignment, labels, milestone, or project when the user or target repo instructions authorize those changes.

## Link Branches And PRs

Create or list development branches linked to an issue:

```powershell
gh issue develop <issue-number> --repo "<owner>/<repo>" --base "<target-branch>" --name "<branch-name>" --checkout
gh issue develop <issue-number> --repo "<owner>/<repo>" --list
```

Link a PR to an issue by referencing the issue in the PR body. Use closing keywords only when the issue should close on merge:

```markdown
Refs #123
Closes #123
```

## Official References

- `gh issue create`: <https://cli.github.com/manual/gh_issue_create>
- `gh issue edit`: <https://cli.github.com/manual/gh_issue_edit>
- `gh issue develop`: <https://cli.github.com/manual/gh_issue_develop>
- GitHub issue linking behavior: <https://docs.github.com/en/issues/tracking-your-work-with-issues/using-issues/linking-a-pull-request-to-an-issue>
