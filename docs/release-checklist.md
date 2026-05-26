# Release Checklist

Use this checklist before publishing or tagging this skill library.

## Validation

- [ ] All skills validate with PowerShell:
  ```powershell
  .\scripts\validate-skills.ps1
  ```
- [ ] All skills validate with Bash:
  ```bash
  ./scripts/validate-skills.sh
  ```
- [ ] Validation reports `0` failures. Warnings are reviewed and accepted or fixed.
- [ ] Skill quality scoring reviewed:
  ```powershell
  .\scripts\score-skills.ps1
  ```
- [ ] Agent quality scoring reviewed:
  ```powershell
  .\scripts\score-agents.ps1
  ```
- [ ] Bash agent quality scoring reviewed:
  ```bash
  ./scripts/score-agents.sh
  ```

## Installer Checks

- [ ] README quick start commands work as written.
- [ ] Windows installer tested with starter bundle:
  ```powershell
  .\scripts\install-skills.ps1 -Harness codex -Bundle starter -DryRun
  ```
- [ ] Linux installer tested with starter bundle:
  ```bash
  ./scripts/install-skills.sh --harness codex --bundle starter --dry-run
  ```
- [ ] Bundle listing tested on Windows and Linux.
- [ ] Bundle install tested for Codex, Claude Code, and OpenCode.
- [ ] Harness defaults tested for Codex, Claude Code, and OpenCode.
- [ ] Project-local install tested for Claude Code and OpenCode.
- [ ] Dry-run mode tested on Windows and Linux.
- [ ] Force overwrite behavior tested on Windows and Linux.
- [ ] Selected-skill install tested on Windows and Linux.
- [ ] Installer refuses to overwrite existing skills without force mode.
- [ ] Windows batch flow reaches harness, scope, bundle/all/individual, and overwrite prompts.
- [ ] Windows batch flow reaches optional subagent selection, installed status, and overwrite prompts.
- [ ] Agent listing tested on Windows and Linux.
- [ ] Agent bundle install tested for Claude Code and OpenCode.
- [ ] Default agent-bundle mapping tested: `backend` -> `backend-review`, `frontend` -> `frontend-review`, and `quality` -> `testing-review`.
- [ ] New specialist agent bundles tested: `testing-review`, `backend-review`, `data-review`, `ci-review`, `frontend-review`, and `documentation-review`.
- [ ] Optional Azure DevOps bundle tested with `azure-devops-delivery` and `azure-devops-review`.
- [ ] Optional GitHub bundle tested with `github-delivery` and `github-review`.
- [ ] Codex `-IncludeAgents` dry run reports guidance-only behavior.
- [ ] Existing native agent files are blocked without force mode.
- [ ] Force mode replaces only files inside the resolved native agent target.

## Bootstrap Checks

- [ ] Bootstrap dry-run tested:
```powershell
  $TargetRepo = "<target-repo>"
  .\scripts\bootstrap-agent-repo.ps1 -ProjectPath $TargetRepo -Harness claude-code -Bundle starter -DryRun
```
- [ ] Bootstrap writes `docs/agents/installed-skills.md`.
- [ ] Existing target `AGENTS.md` is preserved unless force mode is used.
- [ ] Project-local bootstrap tested for Claude Code and OpenCode.
- [ ] Codex bootstrap tested with global or custom skill target.
- [ ] Codex bootstrap with agents writes `docs/agents/subagent-orchestration.md` and `docs/agents/available-subagents.md`.
- [ ] Claude Code bootstrap with agents writes `.claude/agents/*.md`.
- [ ] OpenCode bootstrap with agents writes `.opencode/agents/*.md`.

## Skill Content Review

- [ ] Every skill description is specific enough to decide when to load the skill.
- [ ] No `SKILL.md` file is bloated; detailed support material is moved to `references/`.
- [ ] `references/` folders are used only where they materially improve the skill.
- [ ] Skills do not duplicate responsibilities in a way that creates unclear triggers.
- [ ] Skills avoid generic prompting advice and use operational workflow language.
- [ ] No project-specific assumptions remain.
- [ ] Examples are accurate and match implemented script options.
- [ ] Workflow templates include trigger, ordered skills, phase outputs, validation gates, context continuity, handoff format, and escalation rules.
- [ ] Workflow continuity checkpoints specify phase, objective, completed work, pending work, files, commands, validation, blockers, risks, next action, and recommended continuation skills or subagents.
- [ ] Workflow loop templates reference subagents only for discovery, reproduction, review, audit, validation, and strategy.
- [ ] Azure DevOps workflows keep PR completion, policy bypass, work item transitions, and pipeline mutations behind explicit authorization gates.
- [ ] GitHub workflows keep PR merge, admin bypass, issue state changes, and workflow mutations behind explicit authorization gates.
- [ ] Subagent definitions include trigger descriptions, permission boundaries, forbidden actions, output format, and escalation rules.

## Repository Review

- [ ] Folder structure is clean.
- [ ] README skill catalog matches the `skills/` directory.
- [ ] `catalog/skills.tsv` has one row per skill.
- [ ] `catalog/agents.tsv` has one row per canonical subagent.
- [ ] Every bundle file points only to existing skills.
- [ ] Every agent bundle file points only to existing subagents.
- [ ] Harness profiles are present for Codex, Claude Code, and OpenCode.
- [ ] Harness profiles declare native or guidance-only subagent support.
- [ ] Third-party skills are listed in `THIRD_PARTY_NOTICES.md` and retain local license files.
- [ ] Windows-first instructions are present.
- [ ] Linux alternatives are present.
- [ ] Templates are copyable and do not contain accidental unfinished placeholders.
- [ ] Root `LICENSE` is present and catalog license metadata matches the release license for first-party content.

## License

- [ ] MIT license decision is documented in `LICENSE`.
- [ ] Imported MIT-licensed skills retain per-skill `LICENSE` files and entries in `THIRD_PARTY_NOTICES.md`.
