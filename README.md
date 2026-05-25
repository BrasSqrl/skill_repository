# OpenAI-Style Agent Skills Repository

Reusable, tool-agnostic skills for AI-assisted software development. Skills can be copied or installed into other repositories to guide coding agents through repeatable engineering workflows.

This repository is Windows-first and Linux-second. Prefer PowerShell examples first, with Bash alternatives where useful.

## Quick Start

Validate the skill library:

```powershell
.\scripts\validate-skills.ps1
```

Windows double-click installer:

```text
install-all-skills-windows.bat
```

The double-click installer asks which harness to install for: Codex, Claude Code, or OpenCode. It then asks for global, project-local, or custom install scope and shows which skills are already installed before copying anything.

Install all skills for the current Windows user:

```powershell
.\scripts\install-skills.ps1 -Harness codex -All
.\scripts\install-skills.ps1 -Harness claude-code -All
.\scripts\install-skills.ps1 -Harness opencode -All
```

Install selected skills:

```powershell
.\scripts\install-skills.ps1 -Harness codex -Skills context-engineering,test-driven-development
```

Dry-run before copying to a harness default location:

```powershell
.\scripts\install-skills.ps1 -Harness opencode -All -DryRun
```

Install into an explicit skills directory:

```powershell
.\scripts\install-skills.ps1 -TargetPath "C:\path\to\repo\.agent\skills" -All
```

Linux equivalents:

```bash
./scripts/validate-skills.sh
./scripts/install-skills.sh --harness codex --all
./scripts/install-skills.sh --harness claude-code --skills context-engineering,test-driven-development
./scripts/install-skills.sh --harness opencode --all --dry-run
```

Default global targets:

| Harness | Windows target |
|---|---|
| Codex | `%CODEX_HOME%\skills` when set, otherwise `%USERPROFILE%\.codex\skills` |
| Claude Code | `%USERPROFILE%\.claude\skills` |
| OpenCode | `%USERPROFILE%\.config\opencode\skills` |

For practical harness workflows, see [docs/using-with-codex.md](docs/using-with-codex.md).

## Folder Structure

```text
.
|-- AGENTS.md
|-- install-all-skills-windows.bat
|-- README.md
|-- docs/
|-- scripts/
|   |-- install-skills.ps1
|   |-- install-skills-interactive.ps1
|   |-- install-skills.sh
|   |-- validate-skills.ps1
|   `-- validate-skills.sh
|-- skills/
|   `-- skill-name/
|       |-- SKILL.md
|       `-- references/
`-- templates/
    |-- project-AGENTS.md
    `-- skill-template.md
```

Each skill is a folder under `skills/` with a required `SKILL.md`. Optional `references/`, `scripts/`, `assets/`, and nested `agents/` folders may be added only when they directly support the skill.

## Recommended Starter Set

For a new software repository, start with:

- `repo-onboarding`
- `context-engineering`
- `planning-and-task-breakdown`
- `incremental-implementation`
- `test-driven-development`
- `debugging-and-error-recovery`
- `code-review-and-quality`
- `pull-request-prep`

Add specialized skills for backend, frontend, database, security, architecture, dependency, documentation, or release work when those workflows become common.

## Skill Catalog

### Context And Planning

| Skill | Purpose | When To Use |
|---|---|---|
| `context-engineering` | Build the smallest accurate context set needed for a task. | Use when starting unfamiliar work, recovering context, preparing handoff, or identifying relevant files and commands. |
| `repo-onboarding` | Map an unfamiliar repository's structure, stack, commands, conventions, and risks. | Use at the start of work in a new repo or when setup, test, lint, and build commands are unknown. |
| `zoom-out` | Produce a higher-level map of unfamiliar code and callers. | Use when local code details need broader system context before planning or debugging. |
| `planning-and-task-breakdown` | Convert goals into scoped, ordered, verifiable work slices. | Use for ambiguous, multi-step, risky, or cross-cutting requests before coding. |
| `agent-workflow-design` | Design repeatable AI coding-agent workflows, handoffs, validation loops, and skill sets. | Use when improving agent operating procedures or recurring AI-assisted development flows. |
| `setup-agent-skills` | Configure project-local agent workflow context. | Use before issue triage, PRD creation, or issue breakdown when tracker, labels, and domain docs are unclear. |

### Implementation Workflows

| Skill | Purpose | When To Use |
|---|---|---|
| `incremental-implementation` | Implement changes in small, validated slices while preserving existing behavior. | Use when applying a scoped feature, bug fix, or maintenance change. |
| `test-driven-development` | Drive changes with a red-green-refactor loop. | Use when the user requests TDD or when behavior needs focused tests before implementation. |
| `source-driven-development` | Ground implementation in authoritative code, specs, schemas, or contracts. | Use when correctness depends on tracing behavior to source material rather than inference. |
| `api-backend-development` | Build or modify backend services, APIs, endpoints, handlers, and server-side contracts. | Use for request handling, validation, authorization hooks, service logic, jobs, and backend integration behavior. |
| `frontend-ui-development` | Build or modify frontend UI, components, state flows, styling, accessibility, and interactions. | Use for screens, components, forms, client state, responsive layout, browser-facing behavior, and UI tests. |
| `database-data-workflow-development` | Develop schema, migration, query, seed, ETL, reporting, and data workflow changes. | Use when modifying data models, migrations, indexes, fixtures, analytics queries, or data integrity checks. |
| `prototype` | Build a throwaway prototype to answer a design, state, workflow, or UI question. | Use when a quick prototype can validate an idea before production implementation. |

### Diagnosis And Environment

| Skill | Purpose | When To Use |
|---|---|---|
| `error-message-triage` | Classify noisy errors and identify the first actionable failure. | Use for compiler, test, stack trace, install, linter, type-check, or runtime output before deeper debugging. |
| `debugging-and-error-recovery` | Reproduce, isolate, fix, and verify failing behavior. | Use when tests fail, builds break, runtime errors appear, or a user reports broken behavior. |
| `diagnose` | Run an intensive diagnosis loop for hard bugs, flaky failures, and performance regressions. | Use when a fast deterministic feedback loop must be built before fixing. |
| `dependency-environment-management` | Manage dependencies, package managers, runtime versions, lockfiles, and setup drift. | Use when installs fail, dependencies change, or local and CI environments behave differently. |

### Review And Quality

| Skill | Purpose | When To Use |
|---|---|---|
| `code-review-and-quality` | Review changes for correctness, regressions, maintainability, missing tests, and delivery risk. | Use for code review, quality passes, diff inspection, and pre-merge risk assessment. |
| `security-review` | Review code or designs for security risks and defensive mitigations. | Use for auth, permissions, secrets, cryptography, user input, sensitive data, network calls, or dependency exposure. |
| `architecture-review` | Assess architecture, boundaries, coupling, data flow, dependency direction, and tradeoffs. | Use before large refactors, cross-cutting implementation, or design decisions. |
| `improve-codebase-architecture` | Find deeper architecture improvement opportunities across a codebase. | Use when the goal is architecture discovery, testability, locality, or agent navigability. |
| `refactoring` | Improve internal structure while preserving externally observable behavior. | Use when simplifying, reorganizing, decoupling, extracting, consolidating, or reducing technical debt. |

### Delivery And Documentation

| Skill | Purpose | When To Use |
|---|---|---|
| `documentation-and-adrs` | Create or update developer documentation and architecture decision records. | Use for docs, README updates, guides, runbooks, ADRs, setup notes, or durable technical decisions. |
| `handoff` | Create a compact continuation document for another agent or future session. | Use when context is about to be lost or work should transfer cleanly. |
| `pull-request-prep` | Prepare a reviewer-ready change summary with validation evidence and risks. | Use before opening, updating, or handing off a pull request or equivalent code review package. |
| `release-readiness` | Assess whether changes are ready to release, deploy, tag, or publish. | Use before release to check validation, versioning, changelogs, migrations, rollback, docs, and known risks. |

### Issue And Product Workflows

| Skill | Purpose | When To Use |
|---|---|---|
| `triage` | Triage bugs, feature requests, and issue tracker work through label states. | Use when classifying issues, requesting information, or preparing agent-ready issue briefs. |
| `to-issues` | Convert a plan, spec, or PRD into independently executable implementation issues. | Use when a plan needs vertical-slice implementation tickets. |
| `to-prd` | Synthesize known context into a product requirements document. | Use when the user wants a PRD or feature brief from existing discussion and repo context. |

### Conversation And Design Facilitation

| Skill | Purpose | When To Use |
|---|---|---|
| `caveman` | Switch to ultra-compressed communication while preserving technical accuracy. | Use when the user asks for caveman mode, fewer tokens, or terse updates. |
| `grill-me` | Stress-test a plan by asking one decision-focused question at a time. | Use when the user wants to be grilled on a plan or design. |
| `grill-with-docs` | Stress-test a plan against domain docs and ADRs while updating durable docs. | Use when terminology, `CONTEXT.md`, or ADRs matter to a design. |

## Updating Installed Skills

Re-run the installer with `-Force` or `--force` to replace existing installed skill folders:

```powershell
.\scripts\install-skills.ps1 -Harness codex -All -Force
```

```bash
./scripts/install-skills.sh --harness codex --all --force
```

Use `-TargetPath` or `--target-path` when installing into a custom skills directory.

## Validation

Validation checks skill folders, required `SKILL.md` files, YAML frontmatter, required fields, useful descriptions, and required operational sections.

```powershell
.\scripts\validate-skills.ps1
```

```bash
./scripts/validate-skills.sh
```

## Release Readiness

Before publishing or tagging this repository, use [docs/release-checklist.md](docs/release-checklist.md).
