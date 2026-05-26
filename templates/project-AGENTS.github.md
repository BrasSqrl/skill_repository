# GitHub Delivery Add-On

Copy this section into a target repo `AGENTS.md` only when the project uses GitHub pull requests, issues, or GitHub Actions.

## GitHub Delivery

- Host: `<github.com, GitHub Enterprise host, or "not used">`
- Repository: `<owner>/<repo>`
- Default target branch: `<main branch>`
- Branch naming: `<branch prefix and issue convention>`
- PR authority: `<review only, create/update, comment, review, approve, request changes, auto-merge, merge>`
- Issue conventions: `<labels, milestones, projects, templates, and closing rules>`
- Allowed issue changes: `<fields and state changes agents may update>`
- Reviewer policy: `<required reviewers, teams, CODEOWNERS, or approval rules>`
- Check validation: `<required GitHub Actions, status checks, rulesets, or branch protection>`
- Merge rules: `<merge method, source branch deletion, auto-merge, issue closing rules>`

Agents may use GitHub PR or issue skills only when this section authorizes the action or the user explicitly asks for that action. Agents must not use admin bypass, force operations, mutate workflow secrets, or merge PRs with failed, pending, cancelled, or unknown required checks unless a human explicitly authorizes the exact exception.

## GitHub Validation Checklist

- [ ] `gh auth status` succeeds or the required manual credential step is documented.
- [ ] Source branch and target branch are confirmed.
- [ ] Required checks, rulesets, and branch protection are known.
- [ ] Issue linking and closing behavior are authorized.
- [ ] Merge or auto-merge authority is explicit.
