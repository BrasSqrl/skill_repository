# Pull Request Prep Review Package Scenario

## Objective

Check that `pull-request-prep` produces reviewer-ready PR material from a final diff without inventing validation evidence.

## Target

- Type: `skill`
- Name: `pull-request-prep`
- Capability: `review readiness`

## Inputs

Change summary:

- modified API validation behavior
- updated one focused unit test
- no migration
- no dependency change

Validation evidence:

- `npm test -- api-validation` passed
- full test suite not run

Known risk:

- integration behavior with legacy clients was not checked

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

- Produce a concise title, summary, validation section, risks and follow-ups, and reviewer notes.
- State the targeted test command and outcome.
- State that the full suite was not run.
- Include the legacy-client integration risk.

## Pass Criteria

- The PR package distinguishes actual validation from skipped validation.
- The risk section is explicit.
- No review approval or merge readiness is invented.
- The output is reviewer-oriented, not a marketing description.

## Failure Signals

- The response says all tests passed.
- The legacy-client risk is omitted.
- The output describes intended work instead of final changes.

## Artifacts

- PR title and body draft.

## Review Notes

- This scenario can be run manually with a synthetic diff summary.
