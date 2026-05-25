---
name: agent-evaluation
description: Evaluate AI coding-agent behavior against repeatable tasks, rubrics, expected artifacts, and validation gates. Use when designing, comparing, or regression-testing agent workflows, skills, prompts, orchestration patterns, or handoff quality.
---

# Agent Evaluation

## Purpose

Measure whether an agent workflow produces correct, useful, safe, and repeatable outcomes on representative software-development tasks.

## When to Use

- Use when adding or changing skills, workflows, prompts, or agent instructions.
- Use when comparing multiple agent workflows or models.
- Use when an agent repeatedly fails a task class and the failure needs a regression test.
- Use before publishing an agent operating procedure as stable.

## When Not to Use

- Do not use for a one-off coding task unless the task is also an evaluation case.
- Do not leak the expected answer into the evaluation prompt.
- Do not treat subjective preference as correctness without a rubric.

## Required Inputs

- Evaluation goal and task class.
- Representative prompts or fixtures.
- Expected artifacts, pass/fail checks, or scoring rubric.
- Allowed tools, time budget, and safety boundaries.
- Method for recording results and regressions.

## Workflow

1. Define the capability being evaluated and the failure mode to catch.
2. Create small representative tasks with source artifacts and clear success criteria.
3. Separate hidden expected outcomes from the prompt given to the evaluated agent.
4. Run the workflow consistently and capture outputs, tool use, validation, and failures.
5. Score results against correctness, completeness, safety, validation, and communication.
6. Identify instruction, skill, or workflow changes needed.
7. Re-run after changes and record before/after evidence.

## Quality Gates

- Evaluation tasks are representative and repeatable.
- Scoring criteria are explicit before running the evaluation.
- Expected answers are not leaked to the evaluated agent.
- Results include raw outputs or links to artifacts.
- Regressions can be rerun later.

## Anti-Patterns

- Grading only style while ignoring correctness.
- Changing the test prompt after seeing the output.
- Using one easy example as proof of reliability.
- Letting the evaluating agent also design the expected answer after the run.
- Treating validation failure as acceptable without a documented reason.

## Output Format

```markdown
Agent Evaluation:
- Capability:
- Tasks:
- Rubric:
- Results:
- Failures:
- Recommended changes:
- Regression checks:
```

## References

No bundled references are required. Add reusable rubrics or fixtures only when they are stable enough to maintain.
