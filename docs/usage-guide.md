# Usage Guide

## Purpose

This repository provides reusable AI coding-agent skills for software-development work. Copy or install selected skills into another repository so agents have durable guidance for recurring workflows.

Skills are tool-agnostic. A target repository can use them with any agent system that understands skill folders containing `SKILL.md`. The installer has built-in profiles for Codex, Claude Code, and OpenCode.

## Manual Copy Workflow

Use manual copy when you want exact control over what enters a target repository.

1. Choose the skills needed for the target repository.
2. Create the target skills directory if it does not exist.
3. Copy each selected folder from `skills/` into the target skills directory.
4. Copy `templates/project-AGENTS.md` into the target repository as `AGENTS.md` if the project does not already have one.
5. Edit the target `AGENTS.md` with project-specific setup, test, lint, build, security, and workflow details.
6. Validate the skill library before committing changes.

Windows:

```powershell
New-Item -ItemType Directory -Force "C:\path\to\repo\.agent\skills"
Copy-Item -Recurse .\skills\context-engineering "C:\path\to\repo\.agent\skills\"
```

Linux:

```bash
mkdir -p /path/to/repo/.agent/skills
cp -R ./skills/context-engineering /path/to/repo/.agent/skills/
```

Replace `.agent\skills` or `.agent/skills` with the target skills directory used by the agent runtime. Common targets are:

| Harness | Global target | Project target |
|---|---|---|
| Codex | `~/.codex/skills` or `$CODEX_HOME/skills` | Custom target only |
| Claude Code | `~/.claude/skills` | `<project>/.claude/skills` |
| OpenCode | `~/.config/opencode/skills` | `<project>/.opencode/skills` |

## Script-Based Workflow

Use the installer when you want repeatable copying with validation of source existence, dry-run support, and no-overwrite protection.

Install all skills globally on Windows:

```powershell
.\scripts\install-skills.ps1 -Harness codex -All
.\scripts\install-skills.ps1 -Harness claude-code -All
.\scripts\install-skills.ps1 -Harness opencode -All
```

Install selected skills on Windows:

```powershell
.\scripts\install-skills.ps1 -Harness codex -Skills context-engineering,test-driven-development
```

Install project-local skills for Claude Code:

```powershell
.\scripts\install-skills.ps1 -Harness claude-code -Scope project -ProjectPath "C:\path\to\repo" -All
```

Dry-run:

```powershell
.\scripts\install-skills.ps1 -Harness opencode -All -DryRun
```

Linux:

```bash
./scripts/install-skills.sh --harness codex --all
./scripts/install-skills.sh --harness claude-code --skills context-engineering,test-driven-development
./scripts/install-skills.sh --harness opencode --all --dry-run
```

Use an explicit custom target when the agent runtime uses a different directory:

```powershell
.\scripts\install-skills.ps1 -TargetPath "C:\path\to\repo\.agent\skills" -All
```

## Choosing Skills

Install only skills that match repeated work in the target repository. Too many skills can add maintenance overhead and reduce trigger clarity.

Start with:

- `repo-onboarding`
- `context-engineering`
- `planning-and-task-breakdown`
- `incremental-implementation`
- `test-driven-development`
- `debugging-and-error-recovery`
- `code-review-and-quality`
- `pull-request-prep`

Add specialized skills when the repo regularly needs backend, frontend, database, security, architecture, dependency, documentation, or release workflows.

## Updating Installed Skills

Use force mode to replace previously installed folders.

Windows:

```powershell
.\scripts\install-skills.ps1 -Harness codex -Skills context-engineering,test-driven-development -Force
```

Linux:

```bash
./scripts/install-skills.sh --harness codex --skills context-engineering,test-driven-development --force
```

If target skills were customized, review the diff before forcing an update. The installer replaces whole skill folders.

## Customizing Skills For A Target Repo

Keep reusable workflow guidance in the skill. Put project-specific facts in the target repo's `AGENTS.md`.

Good target customizations:

- Exact setup, test, lint, build, and run commands.
- Important directories and ownership boundaries.
- Security rules and forbidden files.
- Project-specific validation checklist.

Avoid putting these into reusable skills:

- Company-specific secrets or paths.
- One project's architecture facts.
- Tool-only instructions that do not generalize.
- Long examples that belong in `references/`.

## Avoiding Target Repo Bloat

- Install the starter set first, then add skills as needs repeat.
- Avoid copying unused references.
- Do not install every skill just because it exists.
- Keep target `AGENTS.md` project-specific and keep skills reusable.
- Remove skills that do not trigger or do not improve agent behavior.

## Validate Before Committing

Run validation after editing skills, templates, references, or repository rules.

Windows:

```powershell
.\scripts\validate-skills.ps1
```

Linux:

```bash
./scripts/validate-skills.sh
```

Validation returns a nonzero exit code on failure and prints pass, fail, and warning counts.
