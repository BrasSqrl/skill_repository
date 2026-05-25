# Skill Authoring Guide

## Purpose

This guide explains how to write useful OpenAI-style skills for AI coding agents.

A good skill turns a recurring software-development workflow into concise operational guidance. It should help an agent choose the right context, follow a reliable process, avoid known mistakes, verify the result, and communicate the outcome.

## Required Skill Shape

Each skill lives in its own folder under `skills/`:

```text
skills/
  example-skill/
    SKILL.md
    references/
    scripts/
    assets/
    agents/
```

Only `SKILL.md` is required. Optional folders should exist only when they support the skill.

Every `SKILL.md` must start with YAML frontmatter:

```yaml
---
name: example-skill
description: Use when an AI coding agent needs to perform a specific, repeatable software-development workflow with clear inputs, steps, quality gates, and output expectations.
---
```

The `name` must match the folder name. Use lowercase kebab-case.

## What Makes A Skill Useful

Useful skills are specific, repeatable, and verifiable. They do not tell an agent to "do better"; they tell the agent what to inspect, what decisions to make, what order to work in, what to avoid, and how to prove the work is complete.

Prefer:

- Concrete workflows.
- Required inputs.
- Quality gates.
- Anti-patterns.
- Output formats.
- References to detailed supporting material.

Avoid:

- Generic prompting tips.
- Long essays inside `SKILL.md`.
- Tool-specific assumptions.
- Advice that cannot be verified.

## Writing Strong Descriptions

The `description` is the primary trigger text. Write it so an agent can decide when to load the skill before seeing the body.

A strong description includes:

- The workflow the skill supports.
- The conditions that should trigger it.
- Common task names or situations.
- Any important exclusions if confusion is likely.

Good:

```yaml
description: Debug failing software changes by reproducing the issue, reducing scope, inspecting logs, forming hypotheses, implementing the smallest fix, and adding regression verification. Use when tests fail, runtime errors appear, builds break, or a user reports broken behavior.
```

Good:

```yaml
description: Prepare pull requests for software changes. Use when an agent needs to inspect the diff, run final validation, summarize changes, call out risks, and produce reviewer-ready notes without assuming a specific hosting platform.
```

Bad:

```yaml
description: Helps with coding.
```

Bad:

```yaml
description: Use this to think carefully and produce better results.
```

Bad:

```yaml
description: A useful skill for developers.
```

## Progressive Disclosure

Skills should preserve context by loading detail only when needed.

Use three levels:

1. Frontmatter: short trigger metadata.
2. `SKILL.md`: core workflow, gates, anti-patterns, and output format.
3. Optional resources: detailed examples, scripts, assets, and reference material.

If `SKILL.md` is becoming long, move detailed sections into `references/` and link to them from the `References` section.

## `SKILL.md` Versus `references/`

Put this in `SKILL.md`:

- Purpose.
- When to use and when not to use.
- Required inputs.
- Main workflow.
- Quality gates.
- Anti-patterns.
- Output format.
- Short pointers to references.

Put this in `references/`:

- Long examples.
- Framework-specific notes.
- Extended checklists.
- Comparison tables.
- Detailed troubleshooting trees.
- Source excerpts or domain references.

Do not duplicate the same guidance in both places. `SKILL.md` should tell the agent when to open a reference file.

## Catalog And Bundle Metadata

When adding a skill, update `catalog/skills.tsv` in the same change. Required fields are:

- `name`
- `category`
- `maturity`
- `source`
- `license`
- `harnesses`
- `upstream_repo`
- `upstream_ref`
- `upstream_path`
- `import_mode`
- `description`

Use `MIT` for original first-party skills covered by this repository's root license. Use a concrete license value and notice entry for third-party or adapted material.

Add the skill to bundle files under `catalog/bundles/` only when it should be installed with that workflow set. Do not add a skill to `starter` unless it is broadly useful in most software repositories.

## Review Checklist

Use this checklist before adding or changing a skill:

- The folder name is lowercase kebab-case.
- `SKILL.md` exists.
- YAML frontmatter includes `name` and `description`.
- The `name` matches the folder name.
- The `description` clearly states when to use the skill.
- The body is operational and concise.
- Required inputs are explicit.
- Workflow steps are concrete and ordered.
- Quality gates are verifiable.
- Anti-patterns identify likely failure modes.
- Output format is clear.
- Long examples are in `references/`, not `SKILL.md`.
- Language is tool-agnostic.
- Windows-first commands are provided when commands are needed.
- Linux alternatives are included where useful.
- `catalog/skills.tsv` has one matching row.
- Relevant bundle files are updated intentionally.
- Third-party or adapted content is tracked in `THIRD_PARTY_NOTICES.md`.
- Validation scripts pass, or any inability to run them is documented.
- Skill quality scoring has been reviewed:
  ```powershell
  .\scripts\score-skills.ps1
  ```
