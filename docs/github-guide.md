# GitHub Guide

## Purpose

Use this guide when installing or invoking this repository's optional GitHub delivery skills. GitHub is treated as a delivery platform for pull requests, issues, and GitHub Actions, not as an agent harness.

## Install The GitHub Bundle

Windows:

```powershell
.\scripts\install-skills.ps1 -Harness opencode -Bundle github-delivery -IncludeAgents -AgentBundle github-review
.\scripts\install-skills.ps1 -Harness claude-code -Bundle github-delivery -IncludeAgents -AgentBundle github-review
```

Linux:

```bash
bash ./scripts/install-skills.sh --harness opencode --bundle github-delivery --include-agents --agent-bundle github-review
bash ./scripts/install-skills.sh --harness claude-code --bundle github-delivery --include-agents --agent-bundle github-review
```

Use `-DryRun` or `--dry-run` before replacing existing installed skills or agents.

## Target Repo Setup

Copy or bootstrap `templates/project-AGENTS.md` into the target repo and fill in:

- GitHub host and owner/repository
- default target branch
- branch naming convention
- allowed PR actions
- issue labels, milestones, projects, and closing rules
- reviewer and code owner policy
- required GitHub Actions or status checks
- merge method, auto-merge, and source branch deletion rules

Do not store secrets, tokens, private owner names, private repository names, or reviewer identities in this reusable repository.

## GitHub CLI Setup

Windows:

```powershell
gh --version
gh auth status
gh auth login
gh repo view "<owner>/<repo>" --json nameWithOwner,defaultBranchRef,url
```

Linux:

```bash
gh --version
gh auth status
gh auth login
gh repo view "<owner>/<repo>" --json nameWithOwner,defaultBranchRef,url
```

For automation, use a process-scoped `GH_TOKEN`. Never write token values to repository files.

## Common Workflows

- Use `workflows/github-issue-to-pr.md` to turn a GitHub issue into branch work, implementation, validation, and a linked PR.
- Use `workflows/github-pr-lifecycle.md` to create, update, review, submit, enable auto-merge, or merge a GitHub PR.
- Use `workflows/github-actions-response.md` to diagnose failed GitHub Actions, required checks, rulesets, or branch protection.
- Use subagent `github-pr-reviewer` for read-only review of PR metadata, linked issues, reviewer state, comments, branch protection, and GitHub Actions status.

## Safety Rules

- Create or update PRs only when the user asks or target repo instructions authorize it.
- Merge or enable auto-merge only after required local validation and GitHub checks pass.
- Do not use admin bypass or force operations unless a human explicitly authorizes that exact action.
- Do not update issue state, labels, assignment, milestone, or project unless authorized.
- Report every issue field changed and every PR action taken.

## Official References

- GitHub CLI manual: <https://cli.github.com/manual/>
- GitHub CLI authentication: <https://cli.github.com/manual/gh_auth_login>
- GitHub PR commands: <https://cli.github.com/manual/gh_pr>
- GitHub issue commands: <https://cli.github.com/manual/gh_issue>
- GitHub Actions run commands: <https://cli.github.com/manual/gh_run>
