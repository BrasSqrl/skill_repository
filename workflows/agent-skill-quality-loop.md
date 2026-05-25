# Agent Skill Quality Loop Workflow

## Trigger

Use when adding, revising, importing, scoring, or preparing reusable skills, subagents, bundles, or workflow templates for publication.

## Ordered Skills

1. `skill-review`
2. `agent-workflow-design`
3. `prompt-regression-testing`
4. `workflow-dry-run`
5. Subagent: `documentation-reviewer`
6. Subagent: `validation-runner`
7. `handoff-quality-review`

## Phase Outputs

- Skill or subagent trigger clarity review.
- Catalog, bundle, harness, and workflow metadata changes.
- Dry-run notes showing when the asset should and should not be used.
- Documentation review for installation and usage accuracy.
- Validation and scoring results.

## Validation Gates

- New assets have specific descriptions and do not duplicate existing responsibilities.
- Bundles install only useful default combinations and avoid overcrowding harness suggestions.
- Validation and scoring scripts run or skipped reasons are documented.
- License and provenance metadata are present when content is imported or adapted.

## Handoff Format

Report assets changed, catalog and bundle updates, quality concerns, validation results, scoring results, documentation updates, and remaining curation decisions.

## Escalation Rules

- Escalate when a proposed asset overlaps an existing skill or subagent enough to confuse selection.
- Escalate before adding non-MIT or third-party-adapted content.
- Escalate when validation rules need to change to accommodate new repository structure.
