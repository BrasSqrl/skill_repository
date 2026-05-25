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
- [ ] Validation reports `0` failures and `0` warnings.

## Installer Checks

- [ ] README quick start commands work as written.
- [ ] Windows installer tested with all skills:
  ```powershell
  .\scripts\install-skills.ps1 -Harness codex -All -DryRun
  ```
- [ ] Linux installer tested with all skills:
  ```bash
  ./scripts/install-skills.sh --harness codex --all --dry-run
  ```
- [ ] Harness defaults tested for Codex, Claude Code, and OpenCode.
- [ ] Project-local install tested for Claude Code and OpenCode.
- [ ] Dry-run mode tested on Windows and Linux.
- [ ] Force overwrite behavior tested on Windows and Linux.
- [ ] Selected-skill install tested on Windows and Linux.
- [ ] Installer refuses to overwrite existing skills without force mode.

## Skill Content Review

- [ ] Every skill description is specific enough to decide when to load the skill.
- [ ] No `SKILL.md` file is bloated; detailed support material is moved to `references/`.
- [ ] `references/` folders are used only where they materially improve the skill.
- [ ] Skills do not duplicate responsibilities in a way that creates unclear triggers.
- [ ] Skills avoid generic prompting advice and use operational workflow language.
- [ ] No project-specific assumptions remain.
- [ ] Examples are accurate and match implemented script options.

## Repository Review

- [ ] Folder structure is clean.
- [ ] README skill catalog matches the `skills/` directory.
- [ ] Windows-first instructions are present.
- [ ] Linux alternatives are present.
- [ ] Templates are copyable and do not contain accidental unfinished placeholders.
- [ ] License decision documented.

## License

- [ ] TODO: Choose and add a public license before publication.
