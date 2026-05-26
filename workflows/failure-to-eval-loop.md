# Failure To Eval Loop

## Trigger

Use when a skill, subagent, workflow, bundle, installer, bootstrap path, or repository instruction fails in a way that should become a repeatable evaluation scenario.

## Ordered Skills

1. `context-engineering`
2. `agent-evaluation`
3. `prompt-regression-testing`
4. `skill-review` when the failed target is a skill
5. `workflow-dry-run` when the failed target is a workflow or multi-agent loop
6. `handoff-quality-review`

## Phase Outputs

- Failure record with expected behavior, actual behavior, target, reproduction context, affected files, and observed risk.
- Minimal scenario design with target type, target name, capability, mode, status, inputs, pass criteria, and failure signals.
- Sanitized fixtures when the failure needs source snippets, logs, diffs, prompts, or command output.
- Catalog row proposal for `catalog/evals.tsv`.
- Scenario file proposal for `evals/scenarios/<scenario-id>/scenario.md`.
- Maturity recommendation: keep `draft`, promote to `validated`, or mark `retired`.
- Final handoff with validation status, unresolved questions, and exact next action.

## Phase Transitions

- Entry condition: start after a real or representative failure is described with enough context to identify the failed target.
- Phase completion signal: each phase has a written artifact or an explicit blocker explaining what evidence is missing.
- Next phase trigger: move from failure capture to scenario design only after expected behavior and actual behavior are separated.
- Stop condition: stop when the eval scenario and catalog row are ready for implementation, or when missing evidence prevents a fair scenario.
- Retry limit: revise the scenario up to 2 times when review finds leaked answers, private data, unclear pass criteria, or unrealistic expectations.
- Escalation condition: escalate when the failure depends on private data, missing harness behavior, credentials, or a user preference that should not become a reusable eval.

## Validation Gates

- The failure maps to a reusable behavior, not a one-off preference.
- The target exists or the required target change is explicitly identified.
- The scenario does not include secrets, private repository names, user identifiers, or local absolute paths.
- Expected behavior is written before judging a future output.
- Pass criteria are observable without relying on exact prose unless exact wording is required.
- Fixtures are minimal, synthetic where possible, and free of irrelevant logs.
- The proposed status follows maturity rules: new scenarios start as `draft` unless validated evidence already exists.

## Context Continuity

Treat this workflow as long-running when it spans multiple phases, uses subagents, runs validation, revises artifacts, changes multiple files, or may continue across turns. Create a checkpoint before starting a new phase, after major validation output, before large edits, when harness context warnings appear, or when context pressure is noticeable.

Use `handoff` when available and run `handoff-quality-review` before ending or transferring work. Save handoff artifacts outside the repository by default unless this workflow already defines generated-output artifacts or the user requests project-local state.

The checkpoint must include workflow name and current phase, objective and success criteria, completed and pending steps, files inspected or changed, commands run and validation results, decisions, assumptions, blockers, risks, exact next action, and recommended skills or subagents for continuation.

## Handoff Format

Report target, failure summary, reproduction evidence, scenario id, proposed catalog row, scenario file status, fixtures added or needed, validation run, maturity recommendation, blockers, and exact next action.

## Escalation Rules

- Ask before preserving private customer, company, repository, path, or user data in an eval fixture.
- Escalate when the expected behavior conflicts with existing skill, agent, workflow, or target repo instructions.
- Block scenario creation when expected behavior cannot be defined without leaking the answer to the evaluated agent.
- Defer promotion to `validated` until a representative run passes and review notes record the evidence.
