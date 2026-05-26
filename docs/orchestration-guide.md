# Orchestration Guide

## Purpose

This guide explains how to combine skills, bundles, workflow templates, and target repo instructions into repeatable agent operating patterns.

## Core Model

- Skills define reusable behavior for a specific engineering task.
- Subagents define isolated roles for discovery, review, validation, security, architecture, and release checks.
- Bundles define installable groups of skills for common repo types.
- Harness profiles define where skills are installed for Codex, Claude Code, and OpenCode.
- Workflow templates define ordered skill sequences for common work.
- Operating modes define common ways to combine workflows, skills, subagents, validation, and handoffs.
- Eval scenarios define repeatable checks for skill, agent, workflow, and bundle behavior.
- A target repo `AGENTS.md` supplies project-specific commands, architecture notes, and constraints.

## Recommended Bootstrap Flow

1. Choose the harness: `codex`, `claude-code`, or `opencode`.
2. Choose the install scope: global for machine-wide use, project for repo-local harnesses, or custom for explicit paths.
3. Choose a bundle, usually `starter` for a new repo.
4. Decide whether subagents are useful for the target repo.
5. Bootstrap the target repo with `templates/project-AGENTS.md`.
6. Add `templates/project-AGENTS.github.md` or `templates/project-AGENTS.azure-devops.md` only when the target repo uses that delivery platform.
7. Fill in project-specific commands, forbidden changes, and subagent use rules.
8. Ask the agent to use a workflow template and load only the needed skills.
9. Add or update an eval scenario when a repeated agent failure exposes a missing gate.

## Workflow Selection

- Use `workflows/feature-development.md` for scoped implementation.
- Use `workflows/bug-diagnosis.md` for failures and regressions.
- Use `workflows/pull-request-review.md` for reviewing diffs.
- Use `workflows/release-prep.md` before release or deployment.
- Use `workflows/architecture-review.md` before broad design changes.
- Use `workflows/agent-skill-development.md` when adding or revising skills.
- Use `workflows/bug-reproduction-loop.md` when a failure must be reproduced before implementation.
- Use `workflows/feature-quality-loop.md` when a feature needs test strategy, validation, and independent review.
- Use `workflows/backend-change-loop.md` for backend, API, integration, and contract-sensitive changes.
- Use `workflows/data-change-loop.md` for schema, migration, backfill, and data workflow changes.
- Use `workflows/dependency-upgrade-loop.md` for dependency upgrades, runtime changes, install failures, and environment drift.
- Use `workflows/release-gate-loop.md` before publish, tag, deploy, or release handoff.
- Use `workflows/model-methodology-documentation.md` to draft evidence-backed model methodology or technical model documentation from an extracted `llm_documentation_package/`.
- Use `workflows/agent-skill-quality-loop.md` when adding or revising skills, subagents, bundles, or workflow templates.
- Use `workflows/azure-devops-pr-lifecycle.md` when authorized to create, update, validate, auto-complete, or complete Azure Repos pull requests.
- Use `workflows/azure-devops-work-item-to-pr.md` when turning an Azure Boards work item into implementation, validation, and a linked PR.
- Use `workflows/azure-devops-pipeline-response.md` when Azure Pipelines or Azure Repos branch-policy validation blocks delivery.
- Use `workflows/github-pr-lifecycle.md` when authorized to create, update, review, validate, auto-merge, or merge GitHub pull requests.
- Use `workflows/github-issue-to-pr.md` when turning a GitHub issue into implementation, validation, and a linked PR.
- Use `workflows/github-actions-response.md` when GitHub Actions, required checks, rulesets, or branch protection block delivery.
- Use `workflows/failure-to-eval-loop.md` when a real skill, agent, workflow, bundle, installer, or bootstrap failure should become a reusable eval scenario.

## Skill Combination Rules

- Start with context and source-of-truth skills when the repo area is unfamiliar.
- Add one domain skill for the surface being changed.
- Add verification or review skills at the end of the workflow.
- Avoid loading every skill by default; broad context reduces precision.

## Phase Transitions

Every workflow template includes `Phase Transitions` so agents can run workflows as state machines instead of loose checklists.

- Start only when the trigger applies and required inputs are available or blockers are recorded.
- Complete a phase only when its phase output exists or a blocker is documented.
- Move to the next phase only after reviewing the prior output and satisfying the relevant gate.
- Stop when the final handoff output is complete and validation gates pass or are explicitly blocked.
- Retry a failed phase only when new evidence, narrower scope, or approved direction can change the result.
- Escalate when required inputs, permissions, validation evidence, or approval boundaries are missing or contradictory.

## Evaluation Scenarios

Use eval scenarios to make the agent system improve from failures.

- Store metadata in `catalog/evals.tsv`.
- Store scenario specs under `evals/scenarios/<scenario-id>/scenario.md`.
- Keep scenarios small, synthetic, and free of secrets.
- Write expected behavior and pass criteria before judging an output.
- Use `draft` for new scenarios, `validated` after representative passing evidence, and `retired` only for historical scenarios.
- Run `.\scripts\validate-evals.ps1` or `bash ./scripts/validate-evals.sh` before publishing scenario changes.

## Context Continuity

Every workflow template includes a `Context Continuity` section so long-running work can be resumed before context loss.

- Treat a workflow as long-running when it spans multiple phases, uses subagents, runs validation, revises artifacts, changes multiple files, or may continue across turns.
- Create a checkpoint before starting a new phase, after major validation output, before large edits, when harness context warnings appear, or when context pressure is noticeable.
- Use `handoff` when available and run `handoff-quality-review` before ending or transferring work.
- Save handoff artifacts outside the repository by default, unless the workflow defines generated-output artifacts or the user requests project-local state.
- Include workflow name and phase, objective, success criteria, completed and pending steps, files, commands, validation results, decisions, assumptions, blockers, risks, exact next action, and recommended skills or subagents.

## Subagent Use Rules

Use subagents at phase boundaries where isolated context or independent review reduces risk.

- Use `repo-scout` for unfamiliar repo discovery before planning.
- Use `code-reviewer` after there is a concrete diff to review.
- Use `security-reviewer` for authentication, authorization, secrets, user input, sensitive data, network calls, or dependency exposure.
- Use `architecture-reviewer` before broad refactors or cross-module design changes.
- Use `validation-runner` for noisy test, lint, build, type-check, or CI output.
- Use `release-reviewer` before tagging, publishing, deploying, or handing off a release candidate.
- Use `bug-reproducer` before implementation when a failure needs a minimal reproduction.
- Use `test-strategist` before implementation when the smallest useful test plan is unclear.
- Use `dependency-auditor` when manifests, lockfiles, runtime pins, or environment drift matter.
- Use `ci-pipeline-reviewer` when workflow files, checks, caches, matrices, artifacts, or release gates change.
- Use `api-contract-reviewer` when request, response, schema, webhook, SDK, or consumer compatibility may change.
- Use `database-migration-reviewer` when migrations, indexes, backfills, destructive operations, or deploy ordering are involved.
- Use `frontend-accessibility-reviewer` when UI changes affect keyboard flow, semantics, focus, contrast, responsiveness, or screen-reader behavior.
- Use `documentation-reviewer` when docs, ADRs, examples, setup commands, or release notes may drift from source behavior.
- Use `azure-devops-pr-reviewer` when Azure Repos PR metadata, linked work items, branch policies, reviewer state, comments, or CI status need independent read-only review.
- Use `github-pr-reviewer` when GitHub PR metadata, linked issues, branch protection, reviewer state, comments, or GitHub Actions status need independent read-only review.

Do not use subagents for small local edits, tightly coupled implementation loops, or tasks where a handoff would add more cost than clarity.

See [subagent-orchestration-guide.md](subagent-orchestration-guide.md) for permission boundaries, handoff format, and harness-specific behavior.

## Azure DevOps Delivery

Azure DevOps support is optional. Use the `azure-devops-delivery` bundle only in target repos that use Azure Repos, Azure Boards, or Azure Pipelines.

- Azure DevOps is the delivery platform, not the agent harness.
- Target repo instructions must provide organization, project, repository, branch, reviewer, work item, pipeline, and completion rules.
- Agents may create or update PRs and work items only when the user asks or target repo instructions authorize it.
- Agents may complete or auto-complete PRs only after local validation and required Azure policies pass.
- Do not use policy bypass, mutate pipeline secrets, or change work item state without explicit authorization.

## GitHub Delivery

GitHub support is optional. Use the `github-delivery` bundle only in target repos that use GitHub pull requests, issues, or GitHub Actions.

- GitHub is the delivery platform, not the agent harness.
- Target repo instructions must provide owner/repository, branch, reviewer, issue, project, required-check, ruleset, and merge rules.
- Agents may create or update PRs and issues only when the user asks or target repo instructions authorize it.
- Agents may merge or enable auto-merge only after local validation and required GitHub checks pass.
- Do not use admin bypass, force operations, mutate workflow secrets, or change issue state without explicit authorization.

Use [operating-modes.md](operating-modes.md) to choose between solo implementation, review-and-validate, multi-agent investigation, release gate, documentation drafting, Azure DevOps PR delivery, and GitHub PR delivery modes.

## Handoff Rules

Every multi-step agent workflow should end with:

- requested outcome
- files changed or reviewed
- commands run
- validation results
- risks and unresolved questions
- next recommended action

Use `handoff-quality-review` when work must be resumed by another agent or after context loss.

When using subagents, the main agent should include the role, objective, scope, required inputs, allowed actions, forbidden actions, expected output, and escalation conditions in the delegation prompt. The main agent remains responsible for final edits and final user-facing conclusions.

## Escalation Rules

Ask for user input when missing information changes the implementation path, release decision, or security posture. Continue without asking when repo inspection can answer the question safely.
