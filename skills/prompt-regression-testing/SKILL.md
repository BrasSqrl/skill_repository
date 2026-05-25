---
name: prompt-regression-testing
description: Test prompt, skill, and agent-instruction behavior against repeatable scenarios and expected checks. Use when prompts or skills change, model behavior regresses, agent outputs become inconsistent, or LLM workflows need automated or semi-automated regression coverage.
---

# Prompt Regression Testing

## Purpose

Catch regressions in prompt-driven workflows by running stable scenarios with explicit expected behaviors and reviewable outputs.

## When to Use

- Use when changing `AGENTS.md`, skill descriptions, workflow templates, or agent prompts.
- Use when model or harness behavior changes.
- Use when a recurring agent failure needs a regression scenario.
- Use when comparing prompt variants or deciding whether a prompt change is safe.

## When Not to Use

- Do not overfit prompts to one example.
- Do not assert exact prose unless exact wording is required.
- Do not use LLM-as-judge without a clear rubric and spot checks.

## Required Inputs

- Prompt or instruction under test.
- Representative scenario inputs and source artifacts.
- Expected behaviors, forbidden behaviors, and validation checks.
- Baseline output or previous result when available.
- Evaluation command or manual review process.

## Workflow

1. Define the regression risk and scenario set.
2. Write expected behavior checks before changing the prompt.
3. Run the baseline if possible.
4. Apply the prompt or skill change.
5. Re-run scenarios and compare against expected behavior.
6. Review failures for real regressions versus intentional behavior changes.
7. Record results and keep only useful scenarios.

## Quality Gates

- Scenarios cover realistic task inputs.
- Checks focus on behavior, artifacts, safety, and validation evidence.
- Expected failures are documented.
- Results can be rerun with the same inputs.
- Prompt changes include a reason and observed effect.

## Anti-Patterns

- Snapshotting entire long responses as the only assertion.
- Judging prompts with vague preferences.
- Ignoring tool use and validation behavior.
- Keeping stale scenarios that no longer represent real workflows.
- Claiming success without comparing to baseline behavior.

## Output Format

```markdown
Prompt Regression:
- Change under test:
- Scenarios:
- Expected checks:
- Baseline:
- New result:
- Regressions:
- Decision:
```

## References

No bundled references are required. Add reusable scenario templates only after repeated use.
