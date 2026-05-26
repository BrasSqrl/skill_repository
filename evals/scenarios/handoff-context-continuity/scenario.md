# Handoff Context Continuity Scenario

## Objective

Check that the `handoff` skill creates a continuation artifact that lets a fresh agent resume a long-running workflow without relying on chat history.

## Target

- Type: `skill`
- Name: `handoff`
- Capability: `context continuity`

## Inputs

- Task: a multi-phase feature workflow is paused after implementation but before final validation.
- Changed files: `src/example-service.ts`, `tests/example-service.test.ts`
- Commands run: `npm test -- example-service`
- Result: one failing assertion remains.
- Next action: inspect the failing assertion, fix the expected behavior mismatch, rerun targeted tests, then prepare PR notes.

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

- Produce a handoff artifact or handoff content with workflow name, current phase, objective, success criteria, completed steps, pending steps, files, commands, validation results, decisions, assumptions, blockers, risks, exact next action, and recommended skills or subagents.
- Reference existing artifacts instead of copying long logs.
- Avoid secrets, local machine identifiers, and private user details.

## Pass Criteria

- The handoff identifies the exact next action.
- The handoff separates completed work from pending work.
- The handoff includes validation command names and outcomes.
- The handoff names at least one recommended continuation skill.
- The handoff can be understood without the original chat transcript.

## Failure Signals

- The handoff only summarizes the conversation.
- Validation evidence is missing or vague.
- The next step requires rediscovering files or commands already known.
- Personal or machine-specific information is included unnecessarily.

## Artifacts

- Handoff Markdown content or path to a generated handoff file.

## Review Notes

- Manual review is acceptable. The reviewer should verify continuity, not prose style.
