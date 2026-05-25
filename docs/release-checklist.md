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

## Bootstrap Checks

- [ ] Bootstrap dry-run tested:
  ```powershell
  .\scripts\bootstrap-agent-repo.ps1 -ProjectPath "C:\path\to\repo" -Harness claude-code -Bundle starter -DryRun
  ```
- [ ] Bootstrap writes `docs/agents/installed-skills.md`.
- [ ] Existing target `AGENTS.md` is preserved unless force mode is used.
- [ ] Project-local bootstrap tested for Claude Code and OpenCode.
- [ ] Codex bootstrap tested with global or custom skill target.

## Skill Content Review

- [ ] Every skill description is specific enough to decide when to load the skill.
- [ ] No `SKILL.md` file is bloated; detailed support material is moved to `references/`.
- [ ] `references/` folders are used only where they materially improve the skill.
- [ ] Skills do not duplicate responsibilities in a way that creates unclear triggers.
- [ ] Skills avoid generic prompting advice and use operational workflow language.
- [ ] No project-specific assumptions remain.
- [ ] Examples are accurate and match implemented script options.
- [ ] Workflow templates include trigger, ordered skills, phase outputs, validation gates, handoff format, and escalation rules.

## Repository Review

- [ ] Folder structure is clean.
- [ ] README skill catalog matches the `skills/` directory.
- [ ] `catalog/skills.tsv` has one row per skill.
- [ ] Every bundle file points only to existing skills.
- [ ] Harness profiles are present for Codex, Claude Code, and OpenCode.
- [ ] Third-party skills are listed in `THIRD_PARTY_NOTICES.md` and retain local license files.
- [ ] Windows-first instructions are present.
- [ ] Linux alternatives are present.
- [ ] Templates are copyable and do not contain accidental unfinished placeholders.
- [ ] License decision documented.

## License

- [ ] TODO: Choose and add a public license before publication.
