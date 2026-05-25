# Red Green Refactor Checklist

Use this reference to keep a TDD loop observable and avoid silently skipping the red step.

## Red

- Name the behavior under test.
- Add the smallest failing test for that behavior.
- Run the narrowest relevant test command.
- Confirm the failure is for the expected reason.
- Stop if the test cannot fail because the behavior already exists.

## Green

- Make the smallest production change that satisfies the test.
- Do not weaken assertions to pass.
- Re-run the same test command.
- Keep unrelated cleanup out of the green step.

## Refactor

- Refactor only after the focused test is green.
- Preserve public behavior and test expectations.
- Re-run affected tests after structural changes.
- Broaden validation if shared code changed.

## Failure Classification

| Failure | Next action |
|---|---|
| Test fails for expected assertion | Implement the minimum behavior. |
| Test fails for setup or fixture issue | Fix the test setup before production code. |
| Existing tests fail unexpectedly | Triage before continuing. |
| No test harness exists | State the gap and ask or choose the smallest approved harness path. |

## Reporting

```markdown
Red: command and expected failure
Green: command and passing result
Refactor: changes made and validation rerun
```
