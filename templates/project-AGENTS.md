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

## Azure DevOps Delivery

- Organization URL: `<Azure DevOps organization URL, or "not used">`
- Project: `<Azure DevOps project name>`
- Repository: `<Azure Repos repository name>`
- Default target branch: `<main branch>`
- Branch naming: `<branch prefix and work item convention>`
- PR authority: `<review only, create/update, vote, auto-complete, complete>`
- Work item process: `<Basic, Agile, Scrum, CMMI, or custom>`
- Allowed work item changes: `<types, fields, and state transitions agents may update>`
- Reviewer policy: `<required reviewers, groups, or approval rules>`
- Pipeline validation: `<required Azure Pipelines or branch-policy checks>`
- Completion rules: `<merge strategy, source branch deletion, work item transition, auto-complete rules>`

Agents may use Azure DevOps PR or work item skills only when this section authorizes the action or the user explicitly asks for that action. Agents must not use policy bypass, mutate pipeline secrets, or complete PRs with failed, pending, or unknown required policies unless a human explicitly authorizes the exact exception.

## GitHub Delivery

- Host: `<github.com, GitHub Enterprise host, or "not used">`
- Repository: `<owner>/<repo>`
- Default target branch: `<main branch>`
- Branch naming: `<branch prefix and issue convention>`
- PR authority: `<review only, create/update, comment, review, approve, request changes, auto-merge, merge>`
- Issue conventions: `<labels, milestones, projects, templates, and closing rules>`
- Allowed issue changes: `<fields and state changes agents may update>`
- Reviewer policy: `<required reviewers, teams, CODEOWNERS, or approval rules>`
- Check validation: `<required GitHub Actions, status checks, rulesets, or branch protection>`
- Merge rules: `<merge method, source branch deletion, auto-merge, issue closing rules>`

Agents may use GitHub PR or issue skills only when this section authorizes the action or the user explicitly asks for that action. Agents must not use admin bypass, force operations, mutate workflow secrets, or merge PRs with failed, pending, cancelled, or unknown required checks unless a human explicitly authorizes the exact exception.

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
2. Keep changes small and scoped to the request.
3. Prefer existing project patterns over new abstractions.
4. Run the relevant tests, lint checks, and build commands.
5. Report changed files, validation results, and unresolved risks.

## Validation Checklist

- `<setup command completed, or was not required>`
- `<tests passed, or skipped with a stated reason>`
- `<lint passed, or skipped with a stated reason>`
- `<build passed, or skipped with a stated reason>`
- `<security-sensitive changes were reviewed>`
- `<documentation was updated when behavior changed>`
