# Agent Instructions

Copy this file into a target software repository as `AGENTS.md`, then replace bracketed placeholders with project-specific guidance.

## Project Overview

`<Describe what this project does, who uses it, and the primary runtime or platform.>`

## Setup Commands

Windows:

```powershell
<setup command>
```

Linux:

```bash
<setup command>
```

## Test Commands

Windows:

```powershell
<test command>
```

Linux:

```bash
<test command>
```

## Lint Commands

Windows:

```powershell
<lint command>
```

Linux:

```bash
<lint command>
```

## Build Commands

Windows:

```powershell
<build command>
```

Linux:

```bash
<build command>
```

## Coding Standards

- `<language and formatting standards>`
- `<naming conventions>`
- `<error handling expectations>`
- `<test coverage expectations>`

## Architecture Notes

- `<major modules and responsibilities>`
- `<important boundaries or layering rules>`
- `<integration points and external systems>`

## Important Directories

- `<path>/`: `<purpose>`
- `<path>/`: `<purpose>`
- `<path>/`: `<purpose>`

## Installed Agent Skills

- `<bundle or skill name>`: `<when agents should use it in this repo>`
- `<agent bundle or subagent name>`: `<when subagents should be used in this repo>`
- Installed skill record: `docs/agents/installed-skills.md`

## Optional Delivery Platforms

Use only the platform add-ons that apply to this project:

- `templates/project-AGENTS.github.md` for GitHub PRs, issues, checks, and merge rules.
- `templates/project-AGENTS.azure-devops.md` for Azure Repos PRs, Azure Boards, Azure Pipelines, and completion rules.

Do not install or invoke delivery-platform skills unless this project guidance or the user explicitly authorizes the action.

## Subagent Use

Use subagents when isolated context or independent review reduces risk:

- independent repository discovery before planning
- parallel read-only research
- code review of a concrete diff
- validation runs or noisy failure summaries
- security review
- architecture review
- release review

Do not use subagents for:

- small local edits with known files and commands
- tightly coupled implementation loops
- tasks that require frequent user interaction
- work where handoff overhead is higher than risk reduction

When delegating to a subagent, provide objective, scope, required inputs, allowed actions, forbidden actions, expected output, and escalation conditions. The main agent owns final edits, final validation decisions, and final user-facing reporting.

## Context Continuity

For long-running workflows, create a checkpoint before starting a new phase, after major validation output, before large edits, when the harness warns about context limits, or when context pressure is noticeable.

Use the `handoff` skill when available and review the handoff with `handoff-quality-review` before ending or transferring work. Save handoff artifacts outside the repository by default unless this project explicitly requires a project-local generated-output location.

Continuity checkpoints must include workflow name and current phase, objective and success criteria, completed and pending steps, files inspected or changed, commands run and validation results, decisions, assumptions, blockers, risks, exact next action, and recommended skills or subagents for continuation.

## Forbidden Changes

- `<files, directories, generated artifacts, or workflows agents must not edit>`
- `<changes requiring explicit human approval>`
- `<risky operations agents must avoid>`

## Secrets And Security Rules

- Never commit secrets, credentials, tokens, private keys, or local environment files.
- `<secret storage conventions>`
- `<security-sensitive areas of the codebase>`
- `<required security checks for changes>`

## Agent Workflow

1. Inspect the relevant source files before making changes.
2. For multi-phase work, use `agentic-workflow-runtime` to select or explicitly start a workflow and persist its run outside this repository.
3. Follow only the current phase contract and its permission boundary.
4. Keep changes small and scoped to the request.
5. Prefer existing project patterns over new abstractions.
6. Record concrete evidence for each required gate before advancing.
7. Run the relevant tests, lint checks, and build commands.
8. Generate a workflow handoff before transfer, context loss, or user escalation.
9. Report changed files, validation results, and unresolved risks.
10. Add or update an eval scenario when a repeatable agent failure exposes a missing gate, unsafe action, or unclear instruction.

## Validation Checklist

- `<setup command completed, or was not required>`
- `<tests passed, or skipped with a stated reason>`
- `<lint passed, or skipped with a stated reason>`
- `<build passed, or skipped with a stated reason>`
- `<security-sensitive changes were reviewed>`
- `<documentation was updated when behavior changed>`
