# Portable Agent Skill Operating Kit

Reusable, tool-agnostic skills and subagent definitions for AI-assisted software development. This repository stores OpenAI-style skill folders, canonical subagents, install bundles, harness profiles, workflow templates, and validation scripts so the same agent setup can be cloned and installed on any machine.

The repository is Windows-first and Linux-second. PowerShell examples are primary; Bash alternatives are provided for parity.

## Quick Start

Validate the library:

```powershell
.\scripts\validate-skills.ps1
```

List install bundles:

```powershell
.\scripts\install-skills.ps1 -ListBundles
.\scripts\install-skills.ps1 -ListAgentBundles
```

Install the starter bundle for the current user:

```powershell
.\scripts\install-skills.ps1 -Harness codex -Bundle starter
.\scripts\install-skills.ps1 -Harness claude-code -Bundle starter
.\scripts\install-skills.ps1 -Harness opencode -Bundle starter
```

Install the starter bundle with the recommended subagent bundle:

```powershell
.\scripts\install-skills.ps1 -Harness claude-code -Bundle starter -IncludeAgents
.\scripts\install-skills.ps1 -Harness opencode -Bundle starter -IncludeAgents
```

Use the Windows guided installer:

```text
install-all-skills-windows.bat
```

The batch launcher asks for harness, install scope, bundle/all/individual skill selection, optional subagent installation, installed status, and overwrite confirmation.

Linux equivalents:

```bash
bash ./scripts/validate-skills.sh
bash ./scripts/install-skills.sh --list-bundles
bash ./scripts/install-skills.sh --list-agent-bundles
bash ./scripts/install-skills.sh --harness codex --bundle starter
```

## Install Examples

Install all skills:

```powershell
.\scripts\install-skills.ps1 -Harness codex -All
```

Install selected skills:

```powershell
.\scripts\install-skills.ps1 -Harness codex -Skills context-engineering,test-driven-development
```

Install a bundle:

```powershell
.\scripts\install-skills.ps1 -Harness claude-code -Bundle quality
```

Install a bundle and its mapped default subagent bundle:

```powershell
.\scripts\install-skills.ps1 -Harness claude-code -Bundle quality -IncludeAgents
```

Install an explicit subagent bundle:

```powershell
.\scripts\install-skills.ps1 -Harness opencode -Bundle security -IncludeAgents -AgentBundle security-review
```

Install explicit subagents:

```powershell
.\scripts\install-skills.ps1 -Harness claude-code -Bundle starter -IncludeAgents -Agents code-reviewer,validation-runner
```

Preview before copying:

```powershell
.\scripts\install-skills.ps1 -Harness opencode -Bundle starter -DryRun
```

Install into an explicit skills directory:

```powershell
$SkillTarget = "<target-skills-dir>"
.\scripts\install-skills.ps1 -TargetPath $SkillTarget -Bundle starter
```

Bash:

```bash
bash ./scripts/install-skills.sh --harness codex --all
bash ./scripts/install-skills.sh --harness claude-code --bundle quality
bash ./scripts/install-skills.sh --harness opencode --skills context-engineering,test-driven-development
bash ./scripts/install-skills.sh --harness opencode --bundle starter --dry-run
bash ./scripts/install-skills.sh --harness opencode --bundle starter --include-agents
```

## Bootstrap A Target Repo

Bootstrap installs a bundle, seeds `AGENTS.md` when missing, and writes `docs/agents/installed-skills.md` in the target repo.

```powershell
$TargetRepo = "<target-repo>"
.\scripts\bootstrap-agent-repo.ps1 -ProjectPath $TargetRepo -Harness claude-code -Bundle starter
.\scripts\bootstrap-agent-repo.ps1 -ProjectPath $TargetRepo -Harness claude-code -Bundle starter -IncludeAgents
```

Dry-run first:

```powershell
$TargetRepo = "<target-repo>"
.\scripts\bootstrap-agent-repo.ps1 -ProjectPath $TargetRepo -Harness opencode -Bundle starter -DryRun
```

Bash:

```bash
TARGET_REPO="<target-repo>"
bash ./scripts/bootstrap-agent-repo.sh --project-path "$TARGET_REPO" --harness claude-code --bundle starter
bash ./scripts/bootstrap-agent-repo.sh --project-path "$TARGET_REPO" --harness opencode --bundle starter --include-agents
```

## Harness Targets

| Harness | Global target | Project target |
| --- | --- | --- |
| Codex | `%CODEX_HOME%\skills` when set, otherwise `%USERPROFILE%\.codex\skills` | Use `-TargetPath` for explicit project-local installs |
| Claude Code | `%USERPROFILE%\.claude\skills` | `<project>\.claude\skills` |
| OpenCode | `%USERPROFILE%\.config\opencode\skills` | `<project>\.opencode\skills` |

Harness defaults live in `harnesses/*.profile`.

## Subagent Targets

Subagents are opt-in. Claude Code and OpenCode receive native Markdown agent files. Codex receives portable orchestration guidance during bootstrap because this repository does not encode a confirmed native Codex subagent file target.

| Harness | Global agent target | Project agent target | Behavior |
| --- | --- | --- | --- |
| Codex | Guidance only | Guidance only | Bootstrap writes `docs/agents/subagent-orchestration.md` and `docs/agents/available-subagents.md`. |
| Claude Code | `%USERPROFILE%\.claude\agents` | `<project>\.claude\agents` | Native Markdown subagents. |
| OpenCode | `%USERPROFILE%\.config\opencode\agents` | `<project>\.opencode\agents` | Native Markdown agents with `mode: subagent`. |

## Bundles

| Bundle | Purpose |
| --- | --- |
| `starter` | Baseline skills for a new software repository. |
| `backend` | Backend, API, data, observability, and performance workflows. |
| `frontend` | Frontend UI, client behavior, and browser-facing delivery workflows. |
| `quality` | Testing, review, verification, and skill quality workflows. |
| `delivery` | PR, release, CI/CD, documentation, and handoff workflows. |
| `security` | Security review, dependency, access, and risky-change workflows. |
| `agent-orchestration` | Agent workflow, evaluation, handoff, and skill quality workflows. |
| `all-software-dev` | Complete software-development skill set from this repository. |

Bundle membership is stored in `catalog/bundles/*.txt`.

## Agent Bundles

| Bundle | Purpose |
| --- | --- |
| `starter-review` | General read-only discovery, code review, validation, and release handoff agents. |
| `security-review` | Security-focused review plus validation support. |
| `delivery-review` | Validation, release readiness, and review agents. |
| `architecture-review` | Architecture, repo discovery, code review, and validation agents. |
| `testing-review` | Failure reproduction, test strategy, validation, and code review agents. |
| `backend-review` | API contract, code quality, security, and validation agents. |
| `data-review` | Database migration, validation, and release readiness agents. |
| `ci-review` | CI pipeline, dependency, validation, and release readiness agents. |
| `frontend-review` | Frontend accessibility, code quality, and validation agents. |
| `documentation-review` | Documentation drift and release handoff review agents. |
| `all-agents` | Complete subagent set from this repository. |

Agent bundle membership is stored in `catalog/agent-bundles/*.txt`.

Default `-IncludeAgents` mappings:

| Skill bundle | Default agent bundle |
| --- | --- |
| `starter` | `starter-review` |
| `backend` | `backend-review` |
| `frontend` | `frontend-review` |
| `quality` | `testing-review` |
| `delivery` | `delivery-review` |
| `security` | `security-review` |
| `agent-orchestration` | `all-agents` |
| `all-software-dev` | `all-agents` |

## Subagent Catalog

| Subagent | Permission | Purpose |
| --- | --- | --- |
| `repo-scout` | read-only | Map repository structure, commands, conventions, relevant files, and risks. |
| `code-reviewer` | read-only | Review code changes for correctness, regressions, maintainability, missing tests, and delivery risk. |
| `security-reviewer` | read-only | Review authentication, authorization, secrets, input handling, data exposure, dependency risk, and unsafe defaults. |
| `architecture-reviewer` | read-only | Review architecture, module boundaries, coupling, data flow, dependency direction, scalability constraints, and tradeoffs. |
| `validation-runner` | validation-only | Run or review tests, lint, build, type checks, and targeted verification commands. |
| `release-reviewer` | read-only | Review release readiness, validation evidence, changelog, versioning, migrations, rollback notes, docs, and known risks. |
| `bug-reproducer` | validation-only | Isolate failing behavior and return minimal reproduction commands and evidence. |
| `test-strategist` | read-only | Propose the smallest useful test plan for a feature, fix, refactor, or risky change. |
| `dependency-auditor` | read-only | Inspect manifests, lockfiles, runtime versions, upgrade risk, and environment drift. |
| `ci-pipeline-reviewer` | validation-only | Inspect CI config, failed checks, caches, matrices, artifacts, and release gates. |
| `api-contract-reviewer` | read-only | Review API, schema, webhook, SDK, and consumer compatibility changes. |
| `database-migration-reviewer` | read-only | Review migrations, rollback paths, indexes, backfills, destructive operations, and deploy ordering. |
| `frontend-accessibility-reviewer` | read-only | Review keyboard flow, semantics, focus, contrast, responsiveness, and screen-reader risk. |
| `documentation-reviewer` | read-only | Review README, docs, ADRs, examples, setup commands, and release notes for drift. |

The canonical machine-readable subagent catalog is `catalog/agents.tsv`.

## Workflow Templates

| Workflow | Use When |
| --- | --- |
| `feature-development.md` | Implementing a scoped feature or behavior change. |
| `bug-diagnosis.md` | Diagnosing failures and regressions. |
| `pull-request-review.md` | Reviewing diffs or PR-ready changes. |
| `release-prep.md` | Preparing a release or deployment handoff. |
| `architecture-review.md` | Reviewing design, boundaries, and tradeoffs. |
| `agent-skill-development.md` | Adding or revising skills. |
| `bug-reproduction-loop.md` | Reproducing a failure before implementation. |
| `feature-quality-loop.md` | Combining test strategy, implementation, validation, and review for a feature. |
| `backend-change-loop.md` | Reviewing backend, API, security, and contract changes. |
| `data-change-loop.md` | Reviewing schema, migration, backfill, and data workflow changes. |
| `dependency-upgrade-loop.md` | Managing dependency, runtime, install, or environment changes. |
| `release-gate-loop.md` | Running a release gate across validation, CI, docs, security, and release readiness. |
| `agent-skill-quality-loop.md` | Reviewing skills, subagents, bundles, and workflow templates for publication. |

## Folder Structure

```text
.
|-- AGENTS.md
|-- README.md
|-- THIRD_PARTY_NOTICES.md
|-- install-all-skills-windows.bat
|-- agents/
|-- catalog/
|   |-- skills.tsv
|   |-- bundles.tsv
|   |-- agents.tsv
|   |-- agent-bundles.tsv
|   |-- bundles/
|   `-- agent-bundles/
|-- docs/
|-- harnesses/
|-- scripts/
|   |-- bootstrap-agent-repo.ps1
|   |-- bootstrap-agent-repo.sh
|   |-- install-skills-interactive.ps1
|   |-- install-skills.ps1
|   |-- install-skills.sh
|   |-- score-skills.ps1
|   |-- score-skills.sh
|   |-- score-agents.ps1
|   |-- score-agents.sh
|   |-- validate-skills.ps1
|   `-- validate-skills.sh
|-- skills/
|   `-- skill-name/
|       |-- SKILL.md
|       `-- references/
|-- templates/
|   |-- project-AGENTS.md
|   |-- skill-template.md
|   `-- subagent-template.md
`-- workflows/
```

Each skill is a folder under `skills/` with a required `SKILL.md`. Optional `references/`, `scripts/`, `assets/`, and nested `agents/` folders may be added only when they directly support the skill.

## Recommended Starter Set

Use the `starter` bundle for most new repositories. It includes onboarding, context gathering, planning, incremental implementation, test-driven development, debugging, review, PR prep, and release readiness.

Add domain bundles when those workflows repeat:

- `backend` for service, API, and data-heavy repos.
- `frontend` for UI-heavy repos.
- `quality` for test strategy, prompt regression, and review workflows.
- `agent-orchestration` for multi-agent handoffs, evaluations, and workflow design.

## Skill Catalog

| Skill | Category | Purpose | When To Use |
| --- | --- | --- | --- |
| `agent-workflow-design` | agent-orchestration | Design repeatable AI coding-agent workflows, handoffs, validation loops, and skill sets. | Use when improving agent operating procedures or recurring AI-assisted development flows. |
| `agent-evaluation` | agent-orchestration | Evaluate AI coding-agent behavior against repeatable tasks, rubrics, artifacts, and validation gates. | Use when comparing agents, skills, prompts, or orchestration patterns. |
| `handoff-quality-review` | agent-orchestration | Review handoff artifacts for continuity, validation evidence, and restart readiness. | Use before another agent resumes work or after context compaction. |
| `prompt-regression-testing` | agent-orchestration | Test prompt, skill, and agent behavior against repeatable fixtures. | Use when changing prompts, skills, workflows, or agent instructions. |
| `setup-agent-skills` | agent-orchestration | Configure project-local agent workflow context. | Use before issue triage, PRD creation, or issue breakdown when tracker, labels, and domain docs are unclear. |
| `skill-review` | agent-orchestration | Review skill quality, trigger clarity, overlap, validation, references, and license metadata. | Use when adding, importing, or revising skills. |
| `workflow-dry-run` | agent-orchestration | Dry-run an agent workflow before execution to find missing inputs and weak gates. | Use before long or risky agent workflows. |
| `context-engineering` | context | Gather, compress, refresh, and preserve working context. | Use when starting unfamiliar work, recovering context, preparing handoff, or identifying relevant files and commands. |
| `repo-onboarding` | context | Map an unfamiliar repository's structure, stack, commands, conventions, and risks. | Use at the start of work in a new repo. |
| `zoom-out` | context | Produce a higher-level map of unfamiliar code, modules, and callers. | Use when local code details need broader system context. |
| `caveman` | conversation | Switch to ultra-compressed communication while preserving technical accuracy. | Use when the user asks for terse updates or fewer tokens. |
| `grill-me` | conversation | Stress-test a plan or design through focused questions. | Use when the user wants to be grilled on a plan. |
| `grill-with-docs` | conversation | Stress-test a plan against repository language and durable docs. | Use when terminology, context docs, or ADRs matter to a design. |
| `ci-cd-pipeline-maintenance` | delivery | Maintain CI/CD workflows, caches, gates, artifacts, and deployment checks. | Use when pipeline behavior, automation, or release gates change. |
| `documentation-and-adrs` | delivery | Create or update developer documentation and architecture decision records. | Use for guides, runbooks, ADRs, setup notes, or durable technical decisions. |
| `handoff` | delivery | Create a compact continuation document for another agent or future session. | Use when context is about to be lost or work should transfer cleanly. |
| `observability-and-monitoring` | delivery | Add or review logs, metrics, traces, dashboards, alerts, and diagnostics. | Use when runtime visibility or operational triage must improve. |
| `pull-request-prep` | delivery | Prepare software changes for review with validation evidence and risks. | Use before opening, updating, or handing off a PR or review package. |
| `release-readiness` | delivery | Assess release, deployment, tag, or publish readiness. | Use before release to check validation, versioning, rollback, docs, and known risks. |
| `debugging-and-error-recovery` | diagnosis | Reproduce, isolate, fix, and verify failing software behavior. | Use when tests fail, builds break, runtime errors appear, or behavior is broken. |
| `diagnose` | diagnosis | Run an intensive diagnosis loop for hard bugs and performance regressions. | Use when a fast deterministic feedback loop must be built before fixing. |
| `error-message-triage` | diagnosis | Classify noisy errors and identify the first actionable failure. | Use before deeper debugging of compiler, test, install, linter, or runtime output. |
| `performance-profiling` | diagnosis | Measure, isolate, optimize, and verify performance bottlenecks. | Use when performance regressions, slow queries, memory issues, or latency problems appear. |
| `dependency-environment-management` | environment | Manage dependencies, package managers, runtime versions, lockfiles, and setup drift. | Use when installs fail, dependencies change, or local and CI environments differ. |
| `api-backend-development` | implementation | Build or modify backend APIs, services, handlers, jobs, and server-side contracts. | Use for request handling, validation, auth hooks, service logic, jobs, and backend integrations. |
| `database-data-workflow-development` | implementation | Develop schema, migration, query, seed, ETL, reporting, and data workflow changes. | Use when modifying data models, migrations, indexes, fixtures, analytics queries, or data integrity checks. |
| `frontend-ui-development` | implementation | Build or modify frontend UI, components, state flows, styling, accessibility, and interactions. | Use for screens, components, forms, client state, responsive layout, and UI tests. |
| `incremental-implementation` | implementation | Implement changes in small, validated slices while preserving behavior. | Use when applying a scoped feature, bug fix, or maintenance change. |
| `prototype` | implementation | Build a throwaway prototype to answer a design, state, workflow, or UI question. | Use when a quick prototype can validate an idea before production implementation. |
| `refactoring` | implementation | Improve internal structure while preserving externally observable behavior. | Use when simplifying, reorganizing, decoupling, extracting, or consolidating code. |
| `source-driven-development` | implementation | Ground implementation or review in authoritative code, specs, schemas, or contracts. | Use when correctness depends on source material rather than inference. |
| `planning-and-task-breakdown` | planning | Convert goals into scoped, ordered, verifiable work slices. | Use for ambiguous, multi-step, risky, or cross-cutting requests before coding. |
| `to-issues` | product | Convert a plan, spec, PRD, or conversation into executable issues. | Use when a plan needs vertical-slice implementation tickets. |
| `to-prd` | product | Synthesize current context into a product requirements document. | Use when the user wants a PRD or feature brief from existing discussion and repo context. |
| `triage` | product | Triage bugs, feature requests, and issue tracker work through label states. | Use when classifying issues or preparing agent-ready issue briefs. |
| `api-contract-testing` | quality | Verify API contracts, schemas, compatibility, and consumer-provider expectations. | Use when API behavior or compatibility must be validated. |
| `property-based-testing` | quality | Design invariant, round-trip, generator, and stateful property tests. | Use when examples are insufficient to cover broad input spaces. |
| `test-driven-development` | quality | Drive changes with a red-green-refactor loop. | Use when behavior needs focused tests before implementation. |
| `architecture-review` | review | Review architecture, module boundaries, coupling, data flow, and design tradeoffs. | Use before large refactors, cross-cutting implementation, or design decisions. |
| `code-review-and-quality` | review | Review changes for correctness, regressions, maintainability, missing tests, and delivery risk. | Use for code review, quality passes, diff inspection, and pre-merge risk assessment. |
| `improve-codebase-architecture` | review | Find deeper architecture improvement opportunities across a codebase. | Use when the goal is architecture discovery, testability, locality, or agent navigability. |
| `security-review` | security | Review code or designs for security risks and unsafe defaults. | Use for auth, permissions, secrets, user input, sensitive data, network calls, or dependency exposure. |

The canonical machine-readable catalog is `catalog/skills.tsv`.

## Validation And Scoring

Validation checks skill folders, `SKILL.md` frontmatter, required sections, catalog entries, bundle membership, harness profiles, reference links, and third-party notice traceability.

```powershell
.\scripts\validate-skills.ps1
```

```bash
bash ./scripts/validate-skills.sh
```

Quality scoring is advisory:

```powershell
.\scripts\score-skills.ps1
.\scripts\score-agents.ps1
```

```bash
bash ./scripts/score-skills.sh
bash ./scripts/score-agents.sh
```

## Documentation

- [Usage guide](docs/usage-guide.md)
- [Windows setup](docs/windows-setup.md)
- [Linux setup](docs/linux-setup.md)
- [Using with Codex, Claude Code, OpenCode, or another agent](docs/using-with-codex.md)
- [Orchestration guide](docs/orchestration-guide.md)
- [Subagent orchestration guide](docs/subagent-orchestration-guide.md)
- [Skill authoring guide](docs/skill-authoring-guide.md)
- [Skill quality rubric](docs/skill-quality-rubric.md)
- [Curation policy](docs/curation-policy.md)
- [Release checklist](docs/release-checklist.md)

## Release Readiness

Before publishing or tagging this repository, use [docs/release-checklist.md](docs/release-checklist.md).
