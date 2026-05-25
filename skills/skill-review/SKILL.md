---
name: skill-review
description: Review AI coding-agent skills for trigger clarity, operational workflow, overlap, context cost, validation gates, references, and metadata quality. Use when adding, modifying, importing, or publishing skills in a reusable skill library.
---

# Skill Review

## Purpose

Assess whether a skill is useful, maintainable, discoverable, and safe for agents to load in real software-development work.

## When to Use

- Use before accepting a new skill into a shared library.
- Use when editing skill descriptions, workflows, references, or metadata.
- Use when two skills overlap or trigger ambiguously.
- Use before publishing, bundling, or importing third-party skills.

## When Not to Use

- Do not use to judge the underlying software task solved by the skill.
- Do not require long examples in `SKILL.md` when references are more appropriate.
- Do not approve skills that are only generic prompt advice.

## Required Inputs

- Skill folder and `SKILL.md`.
- Intended audience and triggering scenarios.
- Existing nearby skills for overlap comparison.
- Validation rules and catalog metadata.
- License and source information for imported content.

## Workflow

1. Check frontmatter name and description for specific trigger language.
2. Review body for required inputs, operational steps, gates, anti-patterns, and output format.
3. Compare against neighboring skills to find duplicate responsibilities.
4. Inspect references for progressive disclosure and link integrity.
5. Verify metadata, bundle membership, maturity, source, and license fields.
6. Identify concrete edits required before acceptance.
7. Recommend accept, revise, consolidate, or reject.

## Quality Gates

- The description tells an agent exactly when to use the skill.
- The workflow guides behavior rather than explaining concepts.
- The skill has clear boundaries and does not duplicate existing skills.
- References are linked and materially useful.
- Third-party content has license and notice handling.

## Anti-Patterns

- Approving vague advice because the topic is useful.
- Burying trigger logic only inside the body.
- Allowing long copied examples to bloat `SKILL.md`.
- Ignoring overlap with existing skills.
- Treating license metadata as optional for imported content.

## Output Format

```markdown
Skill Review:
- Skill:
- Decision:
- Findings:
- Overlap:
- Required edits:
- Metadata/license:
- Validation:
```

## References

No bundled references are required. Use repository-level quality rubrics when available.
