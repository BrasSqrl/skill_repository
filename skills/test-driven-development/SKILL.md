---
name: test-driven-development
description: Drive software changes with a red-green-refactor loop. Use when the user requests TDD, when behavior must be specified before implementation, or when a bug fix or feature needs focused tests and regression coverage.
---

# Test Driven Development

## Purpose

Implement behavior by first proving the expected test fails, then making the smallest change to pass, then refactoring while tests stay green.

## When to Use

- Use when the user asks for TDD, red-green-refactor, or test-first work.
- Use for bug fixes that need regression coverage.
- Use for features with clear observable behavior.
- Use when adding tests will reduce ambiguity or prevent recurrence.

## When Not to Use

- Do not use when no executable test harness exists and creating one is outside scope.
- Do not use for purely exploratory code reading or documentation-only changes.
- Do not write brittle tests that assert implementation details without need.

## Required Inputs

- Expected behavior or failing scenario.
- Existing test framework, test locations, and naming conventions.
- Targeted test command, with Windows invocation first and Linux alternative when relevant.
- Files or modules under test.
- Acceptance criteria for passing behavior.

## Workflow

1. Inspect existing tests and nearby production code.
2. Choose the smallest behavior to specify.
3. Write or update a focused test that should fail for the right reason.
4. Run the targeted test and record the red result.
5. Implement the minimal production change to pass the test.
6. Run the targeted test again and record the green result.
7. Refactor only after tests pass; rerun affected tests after refactoring.
8. Run broader validation when the change affects shared behavior.

## Quality Gates

- The failing test is observed before implementation unless an existing failing test already proves the bug.
- The test exercises user-visible or contract-visible behavior.
- The production change is no broader than needed to pass the test.
- Refactoring does not change behavior.
- Final validation includes the commands and outcomes.

## Anti-Patterns

- Writing tests after implementation and calling it TDD.
- Making tests pass by weakening assertions.
- Testing mocks instead of behavior without a clear reason.
- Ignoring an unexpected red failure.
- Broadening scope during refactor.

## Output Format

```markdown
TDD Result:
- Red:
- Green:
- Refactor:

Changed Files:
- 

Validation:
- 

Notes:
- 
```

## References

- `references/red-green-refactor-checklist.md`: Use when planning or reporting a TDD loop and when failures need classification before moving from red to green.
