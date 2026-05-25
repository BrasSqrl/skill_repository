---
name: dependency-environment-management
description: Manage development dependencies, package managers, runtime versions, lockfiles, environment setup, and reproducibility problems. Use when installs fail, dependencies need upgrades, tooling versions drift, or local/CI environments behave differently.
---

# Dependency Environment Management

## Purpose

Keep development environments reproducible while making dependency and tooling changes deliberately.

## When to Use

- Use when dependency installation, package resolution, runtime selection, or toolchain setup fails.
- Use when adding, removing, upgrading, or pinning dependencies.
- Use when lockfiles, environment files, containers, or version managers change.
- Use when behavior differs between local Windows, Linux, or CI environments.

## When Not to Use

- Do not use for feature implementation unless dependency work is the blocker.
- Do not upgrade broad dependency sets without user approval.
- Do not change environment assumptions without checking project instructions.

## Required Inputs

- Failing install or runtime command and exact output.
- Package manager files, lockfiles, runtime version files, and setup docs.
- Target operating systems and shell expectations.
- Security, compatibility, and license constraints when known.
- Validation commands, Windows-first with Linux alternatives where useful.

## Workflow

1. Identify the package manager, runtime versions, lockfile policy, and setup path.
2. Reproduce the environment or dependency failure when possible.
3. Inspect relevant manifests, lockfiles, config, and documentation.
4. Choose the smallest dependency or environment change that resolves the issue.
5. Preserve lockfile consistency with the project package manager.
6. Run install, targeted tests, and tool version checks.
7. Document any required setup command changes.
8. Report compatibility or security risks from dependency changes.

## Quality Gates

- The selected package manager and lockfile remain consistent.
- Runtime versions are explicit when version drift caused the issue.
- Dependency changes are minimal and justified.
- Installation and relevant validation commands pass or failures are documented.
- Windows behavior is considered first, with Linux differences noted where relevant.

## Anti-Patterns

- Deleting lockfiles to make resolution easier.
- Mixing package managers in one change.
- Upgrading unrelated dependencies during a targeted fix.
- Ignoring native module or path differences between Windows and Linux.
- Treating local success as proof of CI compatibility without checking config.

## Output Format

```markdown
Environment Result:
- Issue:
- Change:
- Version or lockfile impact:

Changed Files:
- 

Validation:
- 

Compatibility Risks:
- 
```

## References

- `references/environment-change-checklist.md`: Use when dependency or runtime changes affect lockfiles, setup commands, or cross-platform behavior.
