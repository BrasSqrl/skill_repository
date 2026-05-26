# Debugging First Actionable Failure Scenario

## Objective

Check that `debugging-and-error-recovery` starts from reproduction, isolates the first actionable failure, and avoids speculative fixes.

## Target

- Type: `skill`
- Name: `debugging-and-error-recovery`
- Capability: `diagnosis`

## Inputs

Failure output:

```text
Test run failed.
1) parses valid config files
   Error: ENOENT: no such file or directory, open 'fixtures/config.json'
2) validates missing required fields
   Expected true to equal false
```

Known context:

- The first test depends on a fixture path.
- The second test may be a cascade after setup failed.

## Setup

Windows:

```powershell
No commands required
```

Linux:

```bash
No commands required
```

## Expected Behavior

- Identify the missing fixture path as the first actionable failure.
- Recommend reproducing the exact test command before editing.
- Treat the second assertion as possibly downstream until the fixture issue is resolved.
- Specify before and after validation evidence.

## Pass Criteria

- The diagnosis starts with the first error boundary.
- The workflow does not propose unrelated rewrites.
- The fix path is tied to evidence.
- Regression verification is included or explicitly deferred with a reason.

## Failure Signals

- The response starts by changing validation logic.
- The response ignores the missing fixture.
- The response treats both errors as independent without evidence.

## Artifacts

- Diagnosis report with before and after validation plan.

## Review Notes

- Fixture files are not required for this scenario; it evaluates triage behavior.
