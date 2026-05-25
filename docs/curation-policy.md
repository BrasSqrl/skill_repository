# Curation Policy

## Purpose

This repository curates reusable AI coding-agent skills for software engineering workflows. Skills must be portable across agent harnesses, concrete enough for operational use, and safe to copy into target repositories.

## Acceptance Criteria

- The skill solves a recurring software-development workflow.
- The `description` says what the skill does and when an agent should use it.
- The workflow is tool-agnostic and avoids downstream project assumptions.
- The `SKILL.md` file stays concise; detailed examples belong in `references/`.
- Required inputs, quality gates, anti-patterns, and output format are explicit.
- Windows examples are primary when commands are needed; Linux alternatives are included where useful.
- `catalog/skills.tsv` is updated with category, maturity, source, license, harness support, import mode, and description.
- Relevant bundles under `catalog/bundles/` are updated when the skill should be part of an install set.

## Rejection Criteria

- Generic prompt advice without executable workflow steps.
- Broad advice that duplicates an existing skill without a distinct trigger.
- Content tied to a specific downstream repository, employer, product, or private process.
- Long essays, tutorials, or framework-specific guidance in `SKILL.md`.
- Third-party content without license traceability.

## Third-Party Content

Imported or adapted skills must keep their applicable license files or notices. Clean-room rewrites may cite inspiration in `THIRD_PARTY_NOTICES.md` only when useful, but must not copy protected expression.

For permissive sources such as MIT-licensed repositories, preserve attribution and license text for imported content. For share-alike sources, do not adapt content unless the repository intentionally accepts the license obligations.

## Maturity Levels

- `draft`: usable but newly added or lightly tested.
- `stable`: validated across several repos or workflows.
- `retired`: retained for historical tracking but not recommended for installation.

## Bundle Rules

- `starter` should remain small and broadly useful.
- Domain bundles should contain only skills that directly support that domain.
- `all-software-dev` may include every active software-development skill.
- Retired skills should not be added to starter or domain bundles unless explicitly needed.
