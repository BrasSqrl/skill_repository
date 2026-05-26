# Failure To Eval Guide

## Purpose

Use this guide when real agent work exposes a repeatable failure. The goal is to convert that failure into a small evaluation scenario so the repository improves from experience instead of accumulating undocumented lessons.

## When To Create An Eval

Create an eval when:

- a skill was loaded for the wrong task
- a skill missed an important gate
- a workflow allowed unsafe sequencing
- a subagent handoff lacked required inputs
- an install or bootstrap path behaved unexpectedly
- a delivery-platform workflow needed an authorization boundary that was not explicit
- a handoff could not be resumed without reconstructing context

Do not create an eval for a one-off user preference unless it exposes a reusable failure mode.

## Capture Format

Record:

- failed target: skill, agent, workflow, or bundle
- expected behavior
- actual behavior
- minimal reproduction
- files, commands, logs, or prompts needed to reproduce
- pass criteria
- failure signals
- proposed scenario id
- whether the scenario should start as `draft`, `validated`, or `retired`

## Minimal Reproduction

Keep the reproduction small:

- use synthetic fixtures when possible
- remove private repository names and user identifiers
- include only the logs or diffs needed to trigger the behavior
- avoid copying entire conversations

## Promotion Rules

- Start new scenarios as `draft`.
- Promote to `validated` only after a representative run passes and review notes record the evidence.
- Keep failures visible until the target instruction or scenario expectation changes.
- Retire scenarios that no longer represent a current workflow, but keep the catalog row if the history explains an important design decision.

## Related Workflow

Use `workflows/failure-to-eval-loop.md` when converting a real failure into a scenario and catalog entry.
