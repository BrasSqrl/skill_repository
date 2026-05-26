# Azure DevOps Pipeline Response Workflow

## Trigger

Use when Azure Pipelines, Azure Repos branch policies, or PR build validation fail, hang, remain pending, or block PR completion.

## Ordered Skills

1. `azure-pipelines-validation`
2. `error-message-triage`
3. `debugging-and-error-recovery` when failures reproduce locally
4. `dependency-environment-management` when install, lockfile, runtime, or environment drift is implicated
5. `ci-cd-pipeline-maintenance` when pipeline configuration or policy wiring is implicated
6. Subagent: `ci-pipeline-reviewer`
7. Subagent: `validation-runner`
8. `azure-devops-pr-lifecycle` when PR status or policy evaluation must be updated
9. `handoff-quality-review`

## Phase Outputs

- Failed policy, pipeline, build, stage, job, task, and first actionable error.
- Classification as code, test, dependency, environment, pipeline config, permission, or external service.
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

- The first actionable failure is identified from Azure evidence before broad changes.
- Reruns are used only for likely transient failures or after a fix changes the branch.
- Protected logs, permissions, or missing credentials are reported as blockers.
- Pipeline YAML, branch policy, and local validation commands are not conflated.
- PR completion remains blocked until required policies pass or authorized escalation occurs.

## Context Continuity

Treat this workflow as long-running when it spans multiple phases, uses subagents, runs validation, revises artifacts, changes multiple files, or may continue across turns. Create a checkpoint before starting a new phase, after major validation output, before large edits, when harness context warnings appear, or when context pressure is noticeable.

Use `handoff` when available and run `handoff-quality-review` before ending or transferring work. Save handoff artifacts outside the repository by default unless this workflow already defines generated-output artifacts or the user requests project-local state.

The checkpoint must include workflow name and current phase, objective and success criteria, completed and pending steps, files inspected or changed, commands run and validation results, decisions, assumptions, blockers, risks, exact next action, and recommended skills or subagents for continuation.

## Handoff Format

Report PR or build ID, failed policy or pipeline, failure classification, evidence, commands run, fix or rerun status, remaining blockers, and recommended next action.

## Escalation Rules

- Escalate when diagnosis requires protected logs, deployment approvals, secret access, paid services, or runner administration.
- Escalate before rerunning expensive or deployment-adjacent pipelines.
- Do not modify pipeline secrets, environments, service connections, release approvals, or branch policies without explicit authorization.
