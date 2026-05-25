# Agent Skill Development Workflow

## Trigger

Use when creating, importing, reviewing, or revising reusable AI coding-agent skills.

## Ordered Skills

1. `context-engineering`
2. `skill-review`
3. `agent-workflow-design`
4. `workflow-dry-run`
5. `handoff-quality-review`

## Phase Outputs

- Skill purpose and activation trigger.
- `SKILL.md` using the repository standard sections.
- Catalog metadata and bundle placement when the skill is added to this repo.
- Dry-run result showing how an agent would apply the skill.
- Review notes covering overlap, specificity, references, and licensing.

## Validation Gates

- `name` matches the folder name and uses lowercase kebab-case.
- `description` states what the skill does and when to use it.
- `SKILL.md` is concise and operational.
- Long examples and reusable rubrics live in `references/`.
- Catalog and bundle metadata are updated before completion.

## Context Continuity

Treat this workflow as long-running when it spans multiple phases, uses subagents, runs validation, revises artifacts, changes multiple files, or may continue across turns. Create a checkpoint before starting a new phase, after major validation output, before large edits, when harness context warnings appear, or when context pressure is noticeable.

Use `handoff` when available and run `handoff-quality-review` before ending or transferring work. Save handoff artifacts outside the repository by default unless this workflow already defines generated-output artifacts or the user requests project-local state.

The checkpoint must include workflow name and current phase, objective and success criteria, completed and pending steps, files inspected or changed, commands run and validation results, decisions, assumptions, blockers, risks, exact next action, and recommended skills or subagents for continuation.

## Handoff Format

Report new or changed skills, catalog and bundle updates, validation results, known overlaps, and remaining curation decisions.

## Escalation Rules

- Escalate imported or adapted third-party content before changing license treatment.
- Ask for approval when a new skill substantially overlaps an existing skill.
- Do not add framework-specific content to a general skill unless it is isolated in references.
