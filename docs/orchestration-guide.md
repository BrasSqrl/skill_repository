# Orchestration Guide

## Purpose

This guide explains how to combine skills, bundles, workflow templates, and target repo instructions into repeatable agent operating patterns.

## Core Model

- Skills define reusable behavior for a specific engineering task.
- Bundles define installable groups of skills for common repo types.
- Harness profiles define where skills are installed for Codex, Claude Code, and OpenCode.
- Workflow templates define ordered skill sequences for common work.
- A target repo `AGENTS.md` supplies project-specific commands, architecture notes, and constraints.

## Recommended Bootstrap Flow

1. Choose the harness: `codex`, `claude-code`, or `opencode`.
2. Choose the install scope: global for machine-wide use, project for repo-local harnesses, or custom for explicit paths.
3. Choose a bundle, usually `starter` for a new repo.
4. Bootstrap the target repo with `templates/project-AGENTS.md`.
5. Fill in project-specific commands and forbidden changes.
6. Ask the agent to use a workflow template and load only the needed skills.

## Workflow Selection

- Use `workflows/feature-development.md` for scoped implementation.
- Use `workflows/bug-diagnosis.md` for failures and regressions.
- Use `workflows/pull-request-review.md` for reviewing diffs.
- Use `workflows/release-prep.md` before release or deployment.
- Use `workflows/architecture-review.md` before broad design changes.
- Use `workflows/agent-skill-development.md` when adding or revising skills.

## Skill Combination Rules

- Start with context and source-of-truth skills when the repo area is unfamiliar.
- Add one domain skill for the surface being changed.
- Add verification or review skills at the end of the workflow.
- Avoid loading every skill by default; broad context reduces precision.

## Handoff Rules

Every multi-step agent workflow should end with:

- requested outcome
- files changed or reviewed
- commands run
- validation results
- risks and unresolved questions
- next recommended action

Use `handoff-quality-review` when work must be resumed by another agent or after context loss.

## Escalation Rules

Ask for user input when missing information changes the implementation path, release decision, or security posture. Continue without asking when repo inspection can answer the question safely.
