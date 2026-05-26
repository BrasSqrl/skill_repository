# Subagent Orchestration Guide

## Purpose

This guide defines when to use subagents, when to keep work in the main agent conversation, and how to hand off tasks across Codex, Claude Code, OpenCode, or another harness.

Skills are reusable workflows. Subagents are isolated workers with a narrower role, separate context, and explicit permission boundaries. Use both intentionally: skills guide the work, subagents isolate work that benefits from independent context or review.

## When To Use Subagents

Use a subagent when the task is self-contained and the main agent benefits from isolation.

- Use for independent repository discovery before planning.
- Use for review of a completed diff, branch, design, release package, or validation result.
- Use for security review when the reviewer should stay read-only.
- Use for architecture review when broad context may distract from implementation.
- Use for validation runs or failure summaries when command output may be noisy.
- Use for parallel read-only research that can return a compact summary.

## When Not To Use Subagents

Keep the task in the main agent conversation when handoff overhead is higher than risk reduction.

- Do not use for small local edits with known files and commands.
- Do not use for tightly coupled implementation loops that require frequent edits and retesting.
- Do not use when the subagent would need the full conversation history to act safely.
- Do not use when the request requires immediate back-and-forth with the user.
- Do not use nested subagents; chain subagents from the main agent instead.

## Permission Boundaries

Default subagents in this repository are conservative.

- `read-only` agents may inspect files, diffs, logs, and documentation but must not edit files.
- `validation-only` agents may run or review validation commands but must not edit files or change dependencies.
- Security and release reviewers should escalate risky findings instead of fixing them directly.
- The main agent owns final edits, final validation decisions, and user-facing status.

## Handoff Shape

When delegating, provide enough context for the subagent to work without loading the entire conversation.

```markdown
Subagent Task:
- Role:
- Objective:
- Scope:
- Required inputs:
- Files or commands to inspect:
- Allowed actions:
- Forbidden actions:
- Expected output:
- Escalation conditions:
```

The subagent result should be compact:

```markdown
Subagent Result:
- Role:
- Task:
- Findings:
- Evidence:
- Validation:
- Risks:
- Open questions:
- Recommended next action:
```

## Harness Behavior

Claude Code supports Markdown subagents with YAML frontmatter in user and project locations. This repository renders canonical `agents/*.md` files into Claude Code native files with `name`, `description`, `tools`, optional `skills`, and the markdown body.

OpenCode supports Markdown agents with YAML frontmatter and `mode: subagent`. This repository renders canonical agents into OpenCode native files with `description`, `mode: subagent`, a conservative `permission` block, and the markdown body.

Codex currently uses portable guidance in this repository because no confirmed native Codex subagent file format is encoded here. Bootstrap writes `docs/agents/subagent-orchestration.md` and `docs/agents/available-subagents.md` into the target repo when agents are requested for Codex.

## Agent Selection Rules

- Use `repo-scout` for isolated read-only discovery.
- Use `code-reviewer` for correctness, regression, maintainability, and test-gap review.
- Use `security-reviewer` for authentication, authorization, secrets, input handling, data exposure, and dependency risk.
- Use `architecture-reviewer` for boundaries, coupling, dependency direction, data flow, and design tradeoffs.
- Use `validation-runner` for tests, lint, build, type checks, and noisy validation output.
- Use `release-reviewer` for release readiness, changelog, versioning, rollback, migration, documentation, and known-risk review.
- Use `bug-reproducer` when the main agent needs a minimal reproduction, exact command, exit code, and evidence before fixing a failure.
- Use `test-strategist` when the smallest useful test scope is unclear for a feature, bug fix, refactor, or risky change.
- Use `dependency-auditor` for manifest, lockfile, runtime, package manager, upgrade, and environment drift review.
- Use `ci-pipeline-reviewer` for CI failures, workflow edits, cache or matrix changes, artifacts, and release gates.
- Use `api-contract-reviewer` for API, schema, webhook, SDK, OpenAPI, and consumer compatibility changes.
- Use `database-migration-reviewer` for migrations, indexes, backfills, destructive data operations, rollback, and deploy ordering.
- Use `frontend-accessibility-reviewer` for UI changes that affect keyboard navigation, semantics, focus, contrast, responsiveness, or screen-reader behavior.
- Use `documentation-reviewer` for README, docs, ADRs, examples, setup commands, usage guides, and release notes.
- Use `azure-devops-pr-reviewer` for Azure Repos PR metadata, linked work items, reviewer state, comments, branch policies, and CI status.
- Use `github-pr-reviewer` for GitHub PR metadata, linked issues, reviewer state, comments, branch protection, and GitHub Actions status.

## Agent Bundle Selection

- Use `starter-review` for a small default set: repo discovery, code review, validation, and release review.
- Use `testing-review` for bugs, regression fixes, and quality-focused validation loops.
- Use `backend-review` for backend, API, integration, and service changes.
- Use `data-review` for schema, migration, backfill, and data workflow changes.
- Use `ci-review` for CI failures, pipeline edits, dependency delivery risk, and release gate automation.
- Use `frontend-review` for user-facing UI and interaction changes.
- Use `documentation-review` for documentation-heavy changes and release notes.
- Use `azure-devops-review` for Azure DevOps PR delivery workflows that need PR metadata, work item traceability, pipeline policy review, and release readiness.
- Use `github-review` for GitHub PR delivery workflows that need PR metadata, issue traceability, Actions checks, branch protection review, and release readiness.
- Use `all-agents` only when broad subagent coverage is more useful than a concise harness suggestion list.

## Chaining Pattern

For multi-phase work, keep orchestration in the main agent and chain subagents only at phase boundaries.

1. Main agent gathers initial context and defines the task.
2. `repo-scout` maps unfamiliar areas when needed.
3. Main agent plans and implements small changes.
4. `validation-runner` reviews or runs validation when output is large or independent verification is useful.
5. `code-reviewer`, `security-reviewer`, or `architecture-reviewer` reviews the result.
6. Main agent applies any approved fixes and reports final validation.

## Escalation Rules

Escalate to the user when:

- The subagent finds a security or release blocker.
- Required commands need credentials, paid services, or destructive operations.
- The task scope conflicts with repository instructions.
- The subagent cannot distinguish expected behavior from a bug.
- The recommended next action changes the original implementation plan materially.

## Harness References

- Claude Code subagent behavior and file shape: <https://code.claude.com/docs/en/sub-agents>
- OpenCode agent behavior and Markdown permission shape: <https://opencode.ai/docs/agents/>
