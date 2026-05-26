# Operating Modes

## Purpose

Operating modes define common ways to combine skills, subagents, workflows, validation, and handoffs. Use them as starting patterns, not as mandatory process for every request.

## Solo Implementation

Use for small scoped changes where the main agent can inspect, edit, validate, and report without delegation.

- Workflow: `feature-development.md`
- Skills: `context-engineering`, `source-driven-development`, `incremental-implementation`, domain skill, `pull-request-prep`
- Subagents: none by default
- Gate: focused validation runs or a stated reason validation is unavailable
- Handoff: only when context pressure appears or work continues across turns

## Review And Validate

Use when a concrete diff, branch, or review package already exists.

- Workflow: `pull-request-review.md`
- Skills: `code-review-and-quality`, `security-review` when relevant, `architecture-review` when relevant, `pull-request-prep`
- Subagents: `code-reviewer`, `validation-runner`, plus `security-reviewer` or `architecture-reviewer` as needed
- Gate: findings are evidence-based and ordered by severity
- Handoff: review summary with findings, validation reviewed, and merge recommendation

## Multi-Agent Investigation

Use for unfamiliar, noisy, or cross-cutting work where isolated context reduces risk.

- Workflow: `bug-diagnosis.md` or `bug-reproduction-loop.md`
- Skills: `context-engineering`, `error-message-triage`, `debugging-and-error-recovery`, `handoff`
- Subagents: `repo-scout`, `bug-reproducer`, `validation-runner`
- Gate: first actionable failure and reproduction path are identified before fixing
- Handoff: exact commands, observed output, hypotheses, and next action

## Architecture Decision

Use before broad refactors, new boundaries, data-flow changes, or durable technical decisions.

- Workflow: `architecture-review.md`
- Skills: `architecture-review`, `source-driven-development`, `documentation-and-adrs`
- Subagents: `architecture-reviewer`, `repo-scout`, `code-reviewer`
- Gate: tradeoffs and affected boundaries are grounded in source context
- Handoff: decision, alternatives, consequences, and follow-up validation

## Release Gate

Use before tagging, publishing, deploying, or handing off a release candidate.

- Workflow: `release-gate-loop.md`
- Skills: `release-readiness`, `ci-cd-pipeline-maintenance`, `documentation-and-adrs`, `security-review`
- Subagents: `validation-runner`, `ci-pipeline-reviewer`, `documentation-reviewer`, `security-reviewer`, `release-reviewer`
- Gate: validation, documentation, rollback, and known risks are resolved or escalated
- Handoff: release decision record and exact remaining action

## Documentation Drafting

Use when source-grounded docs, ADRs, setup guides, or model methodology docs are needed.

- Workflow: `model-methodology-documentation.md` for extracted model documentation packages; otherwise use `documentation-and-adrs`
- Skills: `context-engineering`, `source-driven-development`, `documentation-and-adrs`
- Subagents: `documentation-reviewer`, `validation-runner` when docs have executable examples
- Gate: claims trace to inspected source or are labeled as assumptions
- Handoff: files changed, source basis, validation, and human-review needs

## Azure DevOps PR Delivery

Use only for Azure Repos, Azure Boards, and Azure Pipelines delivery work in a target repo that authorizes Azure DevOps operations.

- Workflow: `azure-devops-pr-lifecycle.md`, `azure-devops-work-item-to-pr.md`, or `azure-devops-pipeline-response.md`
- Skills: `azure-devops-pr-lifecycle`, `azure-boards-work-item-management`, `azure-pipelines-validation`, `pull-request-prep`
- Subagents: `azure-devops-pr-reviewer`, `ci-pipeline-reviewer`, `validation-runner`, `release-reviewer`
- Gate: explicit authority exists for PR creation, work item updates, voting, auto-complete, or completion
- Handoff: PR ID, work items, reviewers, policy state, validation, and exact next action

## GitHub PR Delivery

Use only for GitHub pull request, issue, and GitHub Actions delivery work in a target repo that authorizes GitHub operations.

- Workflow: `github-pr-lifecycle.md`, `github-issue-to-pr.md`, or `github-actions-response.md`
- Skills: `github-pr-lifecycle`, `github-issues-management`, `github-actions-validation`, `pull-request-prep`
- Subagents: `github-pr-reviewer`, `ci-pipeline-reviewer`, `validation-runner`, `release-reviewer`
- Gate: explicit authority exists for PR creation, issue updates, reviews, auto-merge, or merge
- Handoff: PR number, issues, reviewers, check state, validation, and exact next action

## Failure To Eval

Use when a real agent failure should become reusable regression coverage.

- Workflow: `failure-to-eval-loop.md`
- Skills: `context-engineering`, `agent-evaluation`, `prompt-regression-testing`, `skill-review`, `workflow-dry-run`, `handoff-quality-review`
- Subagents: none by default; add reviewers only when the failed target needs independent review
- Gate: expected behavior, actual behavior, pass criteria, failure signals, and target metadata are explicit
- Handoff: scenario id, catalog row, fixture status, validation result, maturity recommendation, and exact next action
