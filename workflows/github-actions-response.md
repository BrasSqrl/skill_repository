# GitHub Actions Response Workflow

## Trigger

Use when GitHub Actions, required checks, rulesets, or branch protection fail, hang, remain pending, or block PR merge.

## Ordered Skills

1. `github-actions-validation`
2. `error-message-triage`
3. `debugging-and-error-recovery` when failures reproduce locally
4. `dependency-environment-management` when install, lockfile, runtime, or environment drift is implicated
5. `ci-cd-pipeline-maintenance` when workflow configuration or check wiring is implicated
6. Subagent: `ci-pipeline-reviewer`
7. Subagent: `validation-runner`
8. `github-pr-lifecycle` when PR status or checks must be updated
9. `handoff-quality-review`

## Phase Outputs

- Failed check, workflow, run, job, step, and first actionable error.
- Classification as code, test, dependency, environment, workflow config, permission, or external service.
- Local reproduction command or explanation why local reproduction is unavailable.
- Fix route, rerun decision, and PR or release impact.
- Validation result after fix or rerun.

## Phase Transitions

- Entry condition: start after the trigger applies and required inputs are available or blockers are recorded.
- Phase completion signal: each ordered phase produces its listed phase output or a documented blocker.
- Next phase trigger: move forward only after the previous phase output is reviewed and required gates for that point are satisfied.
- Stop condition: stop when the final handoff output is complete, validation gates pass or are explicitly blocked, and escalation rules have been checked.
- Retry limit: revise a failed phase only while new evidence, a narrower scope, or an approved direction change can alter the result; otherwise escalate.
- Escalation condition: escalate when required inputs, permissions, validation evidence, or approval boundaries are missing or contradictory.

## Validation Gates

- The first actionable failure is identified from GitHub evidence before broad changes.
- Reruns are used only for likely transient failures or after a fix changes the branch.
- Protected logs, permissions, or missing credentials are reported as blockers.
- Workflow YAML, branch protection, rulesets, and local validation commands are not conflated.
- PR merge remains blocked until required checks pass or authorized escalation occurs.

## Context Continuity

Treat this workflow as long-running when it spans multiple phases, uses subagents, runs validation, revises artifacts, changes multiple files, or may continue across turns. Create a checkpoint before starting a new phase, after major validation output, before large edits, when harness context warnings appear, or when context pressure is noticeable.

Use `handoff` when available and run `handoff-quality-review` before ending or transferring work. Save handoff artifacts outside the repository by default unless this workflow already defines generated-output artifacts or the user requests project-local state.

The checkpoint must include workflow name and current phase, objective and success criteria, completed and pending steps, files inspected or changed, commands run and validation results, decisions, assumptions, blockers, risks, exact next action, and recommended skills or subagents for continuation.

## Handoff Format

Report PR or run ID, failed check or workflow, failure classification, evidence, commands run, fix or rerun status, remaining blockers, and recommended next action.

## Escalation Rules

- Escalate when diagnosis requires protected logs, deployment approvals, secret access, paid services, or runner administration.
- Escalate before rerunning expensive or deployment-adjacent workflows.
- Do not modify workflow secrets, environments, deployment approvals, branch protection, or repository rulesets without explicit authorization.
