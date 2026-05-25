# Linux Setup

## Shell Usage

Run commands from the repository root:

```bash
cd /path/to/ai_setup
./scripts/validate-skills.sh
```

## Harness Defaults

| Harness | Global Linux target |
|---|---|
| Codex | `$CODEX_HOME/skills` when set, otherwise `$HOME/.codex/skills` |
| Claude Code | `$HOME/.claude/skills` |
| OpenCode | `$HOME/.config/opencode/skills` |

Project-local defaults:

| Harness | Project target |
|---|---|
| Claude Code | `<project>/.claude/skills` |
| OpenCode | `<project>/.opencode/skills` |
| Codex | No project default; provide `--target-path` |

## Example Commands

Install all skills globally for Codex:

```bash
./scripts/install-skills.sh --harness codex --all
```

Install all skills globally for Claude Code:

```bash
./scripts/install-skills.sh --harness claude-code --all
```

Install selected skills globally for OpenCode:

```bash
./scripts/install-skills.sh --harness opencode --skills context-engineering,test-driven-development
```

Install project-local skills for OpenCode:

```bash
./scripts/install-skills.sh --harness opencode --scope project --project-path "/path/to/repo" --all
```

Preview without copying:

```bash
./scripts/install-skills.sh --harness opencode --all --dry-run
```

Replace existing installed skills:

```bash
./scripts/install-skills.sh --harness codex --all --force
```

Install into an explicit skills directory:

```bash
./scripts/install-skills.sh --target-path "/path/to/repo/.agent/skills" --all
```

## Executable Permissions

If the shell scripts are not executable, run:

```bash
chmod +x ./scripts/*.sh
```

You can also invoke them through Bash without changing permissions:

```bash
bash ./scripts/validate-skills.sh
bash ./scripts/install-skills.sh --harness codex --all
```

## Path Notes

- Quote paths that contain spaces.
- Use `--harness` for known Codex, Claude Code, or OpenCode defaults.
- Use `--target-path` for a custom destination skills directory, not the target repo root.
- Use `--project-path` only with `--scope project`.
- The installer creates the target skills directory if needed.
- Existing skill folders are not overwritten unless `--force` is provided.

## Troubleshooting

`Permission denied`

Run `chmod +x ./scripts/*.sh` or invoke the script with `bash`.

`No such file or directory`

Run from the repository root or use an absolute path.

`Target already contains skill folder`

Use `--force` only if replacing the installed skill is intended.

`Custom scope requires --target-path`

Use `--target-path` with `--scope custom`, or use a harness global/project scope.

`Unknown argument`

Use the documented long options:

```bash
--harness opencode --skills context-engineering,test-driven-development
```
