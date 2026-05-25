# Agent Instructions

## Repository Purpose

This repository stores reusable AI coding-agent skills for software development work. Skills are written in an OpenAI-style folder format so they can be copied or installed into other repositories without depending on one specific agent tool.

Each skill should help an AI coding agent perform a concrete engineering workflow, such as context gathering, planning, implementation, testing, debugging, review, security checks, refactoring, documentation, or release preparation.

## Working Rules

- Make small, focused changes. Avoid broad rewrites unless the task explicitly requires them.
- Preserve tool-agnostic language. Do not assume a specific downstream agent, editor, repository, company, or hosting platform.
- Prefer Windows-first commands and examples. Add Linux alternatives where they are useful for parity or portability.
- Write deterministic, operational guidance. Favor steps, checks, commands, decision rules, and expected outputs.
- Validate before reporting work complete. Run the repository validation script when skill files or repository rules change.
- Keep documentation scoped to this repository. Do not reference any specific downstream project.

## Skill Format Rules

- Every skill must live in its own folder under `skills/`.
- Every skill folder must contain a required `SKILL.md`.
- Every `SKILL.md` must start with YAML frontmatter containing at least `name` and `description`.
- The `name` value must match the skill folder name.
- Skill names must use lowercase kebab-case.
- The `description` must clearly state what the skill does and when an agent should use it.
- Keep `SKILL.md` concise. Put detailed examples, long checklists, framework-specific notes, and extended references in `references/`.
- Use optional `scripts/` only for deterministic helpers that are worth running instead of rewriting.
- Use optional `assets/` only for reusable files copied or transformed by the skill.
- Use optional nested `agents/` only for agent metadata or sub-agent instructions that directly support the skill.

## Writing Standards

- Forbid vague prompt advice such as "be careful", "think deeply", or "write good code" unless paired with concrete actions.
- Prefer concrete workflows, quality gates, anti-patterns, and output formats.
- State required inputs and assumptions explicitly.
- Include verification steps that an agent can execute.
- Use imperative language.
- Avoid motivational, marketing, or tutorial filler.
- Avoid duplicating the same instruction in `SKILL.md` and `references/`.

## Validation

Run validation after changing skills, references, templates, scripts, or repository rules:

```powershell
.\scripts\validate-skills.ps1
```

Linux alternative:

```bash
./scripts/validate-skills.sh
```

If validation cannot be run, report that clearly and explain why.
