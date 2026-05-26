# Curation Policy

## Purpose

This repository curates reusable AI coding-agent skills for software engineering workflows. Skills must be portable across agent harnesses, concrete enough for operational use, and safe to copy into target repositories.

Canonical subagents are curated under the same standard. They must provide isolated roles for discovery, review, validation, security, architecture, or release work without becoming project-specific assistants.

## Acceptance Criteria

- The skill solves a recurring software-development workflow.
- The `description` says what the skill does and when an agent should use it.
- The workflow is tool-agnostic and avoids downstream project assumptions.
- The `SKILL.md` file stays concise; detailed examples belong in `references/`.
- Required inputs, quality gates, anti-patterns, and output format are explicit.
- Action boundaries and stop conditions are explicit when the skill can mutate files, run commands, delegate work, or affect delivery platforms.
- Windows examples are primary when commands are needed; Linux alternatives are included where useful.
- `catalog/skills.tsv` is updated with category, maturity, source, license, harness support, import mode, and description.
- Relevant bundles under `catalog/bundles/` are updated when the skill should be part of an install set.
- Subagents include explicit permission boundaries and are listed in `catalog/agents.tsv`.
- Agent bundles under `catalog/agent-bundles/` include only subagents that should be installed together.
- High-traffic or risky behavior has an eval scenario in `catalog/evals.tsv`, or the omission is intentional.

## Rejection Criteria

- Generic prompt advice without executable workflow steps.
- Broad advice that duplicates an existing skill without a distinct trigger.
- Content tied to a specific downstream repository, employer, product, or private process.
- Long essays, tutorials, or framework-specific guidance in `SKILL.md`.
- Third-party content without license traceability.
- Subagents that perform implementation edits by default or duplicate a skill without adding context isolation, independent review, or permission control.

## Third-Party Content

Imported or adapted skills must be MIT-licensed, listed in `THIRD_PARTY_NOTICES.md`, and stored with the required license file or notice. Do not add third-party content with a different license without explicit approval and a documented reason.

## Maturity Levels

- `draft`: usable but newly added, lightly tested, or covered only by draft eval scenarios.
- `stable`: validated across representative repos, workflows, or eval scenarios with documented passing evidence.
- `retired`: retained for historical tracking but not recommended for installation or new workflows.

## Eval Scenario Rules

- New behavior that closes a repeated failure should include an eval scenario under `evals/scenarios/`.
- Scenario metadata must be tracked in `catalog/evals.tsv`.
- New scenarios start as `draft` unless representative passing evidence already exists.
- Promote a scenario to `validated` only after review notes record a representative pass.
- Retire scenarios that no longer represent current workflows, but keep enough context to explain why.

## Bundle Rules

- `starter` should remain small and broadly useful.
- Domain bundles should contain only skills that directly support that domain.
- `all-software-dev` may include every active software-development skill.
- Retired skills should not be added to starter or domain bundles unless explicitly needed.

## Agent Bundle Rules

- `starter-review` should remain a small default review set.
- Security, delivery, and architecture bundles should include only agents needed for those review gates.
- `all-agents` may include every active canonical subagent.
- Codex remains guidance-only for subagents until this repository adopts a confirmed native Codex subagent file target.
