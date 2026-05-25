# Usage Guide

## Purpose

This repository provides reusable AI coding-agent skills, canonical subagents, bundles, harness profiles, and workflow templates for software-development work. Copy or install selected skills into another repository so agents have durable guidance for recurring workflows.

Skills are tool-agnostic. A target repository can use them with any agent system that reads skill folders containing `SKILL.md`. Subagents are optional and install only when requested.

## Manual Copy Workflow

Use manual copy when you want exact control over what enters a target repository.

1. Choose the skills or bundle needed for the target repository.
2. Create the target skills directory if it does not exist.
3. Copy each selected folder from `skills/` into the target skills directory.
4. Copy `templates/project-AGENTS.md` into the target repository as `AGENTS.md` if the project does not already have one.
5. Edit the target `AGENTS.md` with project-specific setup, test, lint, build, security, and workflow details.
6. Validate this library before committing library changes.

Windows:

```powershell
$SkillTarget = "<target-skills-dir>"
New-Item -ItemType Directory -Force $SkillTarget
Copy-Item -Recurse .\skills\context-engineering $SkillTarget
```

Linux:

```bash
SKILL_TARGET="<target-skills-dir>"
mkdir -p "$SKILL_TARGET"
cp -R ./skills/context-engineering "$SKILL_TARGET/"
```

Common targets:

| Harness | Global target | Project target |
| --- | --- | --- |
| Codex | `~/.codex/skills` or `$CODEX_HOME/skills` | Custom target only |
| Claude Code | `~/.claude/skills` | `<project>/.claude/skills` |
| OpenCode | `~/.config/opencode/skills` | `<project>/.opencode/skills` |

Subagent targets:

| Harness | Global target | Project target |
| --- | --- | --- |
| Codex | Guidance only | Guidance only |
| Claude Code | `~/.claude/agents` | `<project>/.claude/agents` |
| OpenCode | `~/.config/opencode/agents` | `<project>/.opencode/agents` |

## Script-Based Workflow

Use the installer when you want repeatable copying with source checks, bundle support, dry-run support, and no-overwrite protection.

List bundles and skills:

```powershell
.\scripts\install-skills.ps1 -ListBundles
.\scripts\install-skills.ps1 -ListSkills
.\scripts\install-skills.ps1 -ListAgentBundles
.\scripts\install-skills.ps1 -ListAgents
```

Install by bundle:

```powershell
.\scripts\install-skills.ps1 -Harness codex -Bundle starter
.\scripts\install-skills.ps1 -Harness claude-code -Bundle quality
.\scripts\install-skills.ps1 -Harness opencode -Bundle agent-orchestration
```

Install skills with the mapped default subagent bundle:

```powershell
.\scripts\install-skills.ps1 -Harness claude-code -Bundle starter -IncludeAgents
.\scripts\install-skills.ps1 -Harness opencode -Bundle security -IncludeAgents
```

Install explicit subagents:

```powershell
.\scripts\install-skills.ps1 -Harness claude-code -Bundle starter -IncludeAgents -Agents code-reviewer,validation-runner
```

Install selected skills:

```powershell
.\scripts\install-skills.ps1 -Harness codex -Skills context-engineering,test-driven-development
```

Install all skills:

```powershell
.\scripts\install-skills.ps1 -Harness codex -All
```

Project-local install:

```powershell
$TargetRepo = "<target-repo>"
.\scripts\install-skills.ps1 -Harness claude-code -Scope project -ProjectPath $TargetRepo -Bundle starter
.\scripts\install-skills.ps1 -Harness opencode -Scope project -ProjectPath $TargetRepo -Bundle starter
```

Dry-run and force:

```powershell
.\scripts\install-skills.ps1 -Harness opencode -Bundle starter -DryRun
.\scripts\install-skills.ps1 -Harness codex -Bundle starter -Force
```

Linux:

```bash
bash ./scripts/install-skills.sh --list-bundles
bash ./scripts/install-skills.sh --list-agent-bundles
bash ./scripts/install-skills.sh --harness codex --bundle starter
bash ./scripts/install-skills.sh --harness claude-code --skills context-engineering,test-driven-development
bash ./scripts/install-skills.sh --harness opencode --bundle starter --dry-run
bash ./scripts/install-skills.sh --harness opencode --bundle starter --include-agents
```

## Bootstrap Workflow

Use bootstrap when setting up a target repo. It installs a bundle, creates `AGENTS.md` from the template when missing, and writes `docs/agents/installed-skills.md`.

Windows:

```powershell
$TargetRepo = "<target-repo>"
.\scripts\bootstrap-agent-repo.ps1 -ProjectPath $TargetRepo -Harness claude-code -Bundle starter
.\scripts\bootstrap-agent-repo.ps1 -ProjectPath $TargetRepo -Harness claude-code -Bundle starter -IncludeAgents
```

Linux:

```bash
TARGET_REPO="<target-repo>"
bash ./scripts/bootstrap-agent-repo.sh --project-path "$TARGET_REPO" --harness opencode --bundle starter
bash ./scripts/bootstrap-agent-repo.sh --project-path "$TARGET_REPO" --harness opencode --bundle starter --include-agents
```

Use `-DryRun` or `--dry-run` first when the target already has agent instructions.

## Choosing Skills

Install only skills that match repeated work in the target repository. Too many installed skills can add maintenance overhead and reduce trigger clarity.

Recommended first install:

```powershell
.\scripts\install-skills.ps1 -Harness codex -Bundle starter
```

Add bundles by repo shape:

- `backend` for service, API, data, observability, and performance work.
- `frontend` for UI, component, browser, and accessibility work.
- `quality` for testing, review, and verification work.
- `delivery` for PR, CI/CD, documentation, release, and handoff work.
- `security` for auth, permissions, secrets, dependencies, and risk review.
- `agent-orchestration` for multi-agent workflows, evaluation, and handoff quality.

Recommended first subagent set:

```powershell
.\scripts\install-skills.ps1 -Harness claude-code -Bundle starter -IncludeAgents
```

Use subagents when independent context, read-only review, validation, security review, architecture review, or release review reduces risk. Do not install subagents by default for tiny repos where the main agent can handle all work with a small context window.

## Updating Installed Skills

Use force mode to replace previously installed folders. The installer replaces whole skill folders, so review target customizations first.

Windows:

```powershell
.\scripts\install-skills.ps1 -Harness codex -Bundle starter -Force
.\scripts\install-skills.ps1 -Harness claude-code -Bundle starter -IncludeAgents -Force
```

Linux:

```bash
bash ./scripts/install-skills.sh --harness codex --bundle starter --force
bash ./scripts/install-skills.sh --harness claude-code --bundle starter --include-agents --force
```

## Customizing Skills For A Target Repo

Keep reusable workflow guidance in the skill. Put project-specific facts in the target repo's `AGENTS.md`.

Good target customizations:

- Exact setup, test, lint, build, and run commands.
- Important directories and ownership boundaries.
- Security rules and forbidden files.
- Installed bundles and local workflow expectations.
- Subagent rules, installed agent bundles, and permission boundaries.
- Project-specific validation checklist.

Avoid putting these into reusable skills:

- Company-specific secrets or paths.
- One project's architecture facts.
- Tool-only instructions that do not generalize.
- Long examples that belong in `references/`.

## Avoiding Target Repo Bloat

- Install `starter` first, then add bundles as needs repeat.
- Prefer bundles over installing every skill.
- Install subagents only when independent review or validation is useful.
- Avoid copying unused references manually.
- Keep target `AGENTS.md` project-specific and keep skills reusable.
- Remove skills that do not trigger or improve agent behavior.

## Validate Before Committing

Run validation after editing skills, templates, references, catalog files, harness profiles, scripts, or repository rules.

Windows:

```powershell
.\scripts\validate-skills.ps1
.\scripts\score-skills.ps1
.\scripts\score-agents.ps1
```

Linux:

```bash
bash ./scripts/validate-skills.sh
bash ./scripts/score-skills.sh
bash ./scripts/score-agents.sh
```

Validation returns a nonzero exit code on failure. Scoring is advisory.
