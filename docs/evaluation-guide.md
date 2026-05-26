# Evaluation Guide

## Purpose

This repository uses lightweight evaluation scenarios to check whether skills, subagents, workflows, and bundles behave like reusable agent programs rather than generic advice.

Evaluations are dependency-free by default. They describe inputs, expected behavior, pass criteria, and failure signals. They do not require one specific LLM harness.

## Evaluation Model

Evaluation metadata lives in `catalog/evals.tsv`.

Required columns:

- `id`
- `target_type`
- `target_name`
- `capability`
- `mode`
- `status`
- `description`

Allowed values:

- `target_type`: `skill`, `agent`, `workflow`, or `bundle`
- `mode`: `manual`, `dry-run`, or `fixture`
- `status`: `draft`, `validated`, or `retired`

Each scenario lives at:

```text
evals/scenarios/<scenario-id>/scenario.md
```

Optional fixtures and expected outputs may be stored under:

```text
evals/scenarios/<scenario-id>/fixtures/
evals/scenarios/<scenario-id>/expected/
```

## Scenario Quality

A useful scenario has:

- a narrow target
- realistic inputs
- expected behavior written before judging an output
- pass criteria that can be checked without guessing intent
- failure signals that map to concrete instruction changes
- artifacts that can be saved, reviewed, or compared later

Avoid exact prose snapshots unless exact wording is the product requirement. Prefer behavior checks such as required fields, forbidden claims, command summaries, evidence handling, and escalation behavior.

## Maturity Rules

- `draft`: Scenario exists but has not been exercised enough to prove repeatability.
- `validated`: Scenario has passed in at least one real or representative run, with review notes updated.
- `retired`: Scenario is kept only for traceability and should not be used for current release confidence.

A skill, agent, or workflow can remain installable while its eval coverage is draft. Do not treat `stable` maturity as permanent if repeated evals fail.

## Running Validation

Windows:

```powershell
.\scripts\validate-evals.ps1
.\scripts\validate-skills.ps1
```

Linux:

```bash
bash ./scripts/validate-evals.sh
bash ./scripts/validate-skills.sh
```

`validate-skills` calls eval validation as part of repository validation.

## Adding A Scenario

1. Copy `templates/eval-scenario.md` into `evals/scenarios/<scenario-id>/scenario.md`.
2. Fill every required section.
3. Add one row to `catalog/evals.tsv`.
4. Use a real target name from `skills/`, `agents/`, `workflows/`, or bundle catalog files.
5. Keep fixtures small, synthetic, and free of secrets.
6. Run validation.

## Interpreting Failures

When a scenario fails, classify the failure:

- Target instruction is unclear.
- Target instruction is wrong or unsafe.
- Scenario expectation is unrealistic.
- Fixture is incomplete or stale.
- Harness behavior changed.
- User or repo policy overrides the expected behavior.

Turn repeated failures into edits to the target skill, agent, workflow, bundle, or scenario.
