# Architecture Review Workflow

## Trigger

Use when assessing a proposed design, subsystem boundary, refactor direction, dependency change, data flow, or technical strategy.

## Ordered Skills

1. `context-engineering`
2. `source-driven-development`
3. `architecture-review`
4. `security-review` when the design changes trust boundaries or data exposure
5. `documentation-and-adrs`

## Phase Outputs

- Current architecture facts from code, docs, and tests.
- Proposed change summary.
- Tradeoff analysis with constraints and alternatives.
- Recommendation and decision record when durable.

## Phase Transitions

- Entry condition: start after the trigger applies and required inputs are available or blockers are recorded.
- Phase completion signal: each ordered phase produces its listed phase output or a documented blocker.
- Next phase trigger: move forward only after the previous phase output is reviewed and required gates for that point are satisfied.
- Stop condition: stop when the final handoff output is complete, validation gates pass or are explicitly blocked, and escalation rules have been checked.
- Retry limit: revise a failed phase only while new evidence, a narrower scope, or an approved direction change can alter the result; otherwise escalate.
- Escalation condition: escalate when required inputs, permissions, validation evidence, or approval boundaries are missing or contradictory.

## Validation Gates

- Claims are tied to inspected sources or labeled as assumptions.
- Coupling, ownership, data flow, runtime behavior, and operational constraints are considered.
- The recommendation distinguishes now-versus-later work.
- ADRs are added only for durable decisions.

## Context Continuity

Treat this workflow as long-running when it spans multiple phases, uses subagents, runs validation, revises artifacts, changes multiple files, or may continue across turns. Create a checkpoint before starting a new phase, after major validation output, before large edits, when harness context warnings appear, or when context pressure is noticeable.

Use `handoff` when available and run `handoff-quality-review` before ending or transferring work. Save handoff artifacts outside the repository by default unless this workflow already defines generated-output artifacts or the user requests project-local state.

The checkpoint must include workflow name and current phase, objective and success criteria, completed and pending steps, files inspected or changed, commands run and validation results, decisions, assumptions, blockers, risks, exact next action, and recommended skills or subagents for continuation.

## Handoff Format

Report current state, proposed direction, decision drivers, recommendation, rejected alternatives, validation gaps, and next implementation slices.

## Escalation Rules

- Ask for product or operational priorities when tradeoffs cannot be ranked from repo context.
- Escalate when changing public contracts, persistence formats, or deployment boundaries.
- Do not implement the architecture change during review unless explicitly requested.
