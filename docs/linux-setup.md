# Linux Setup

## Shell Usage

Run commands from the repository root:

```bash
cd /path/to/ai_setup
bash ./scripts/validate-skills.sh
```

## Harness Defaults

| Harness | Global Linux target |
| --- | --- |
| Codex | `$CODEX_HOME/skills` when set, otherwise `$HOME/.codex/skills` |
| Claude Code | `$HOME/.claude/skills` |
| OpenCode | `$HOME/.config/opencode/skills` |

Project-local defaults:

| Harness | Project target |
| --- | --- |
| Claude Code | `<project>/.claude/skills` |
| OpenCode | `<project>/.opencode/skills` |
| Codex | No project default; provide `--target-path` |

## Example Commands

List bundles:

```bash
bash ./scripts/install-skills.sh --list-bundles
```

Install the starter bundle globally for Codex:

```bash
bash ./scripts/install-skills.sh --harness codex --bundle starter
```

Install a quality bundle for Claude Code:

```bash
bash ./scripts/install-skills.sh --harness claude-code --bundle quality
```

Install selected skills for OpenCode:

```bash
bash ./scripts/install-skills.sh --harness opencode --skills context-engineering,test-driven-development
```

Install project-local skills for OpenCode:

```bash
bash ./scripts/install-skills.sh --harness opencode --scope project --project-path "/path/to/repo" --bundle starter
```

Preview without copying:

```bash
bash ./scripts/install-skills.sh --harness opencode --bundle starter --dry-run
```

Replace existing installed skills:

```bash
bash ./scripts/install-skills.sh --harness codex --bundle starter --force
```

Install into an explicit skills directory:

```bash
bash ./scripts/install-skills.sh --target-path "/path/to/repo/.agent/skills" --bundle starter
```

Bootstrap a target repo:

```bash
bash ./scripts/bootstrap-agent-repo.sh --project-path /path/to/repo --harness opencode --bundle starter
```

Dry-run bootstrap:

```bash
bash ./scripts/bootstrap-agent-repo.sh --project-path /path/to/repo --harness claude-code --bundle starter --dry-run
```

Score skills:

```bash
bash ./scripts/score-skills.sh
```

## Executable Permissions

If the shell scripts are not executable, run:

```bash
chmod +x ./scripts/*.sh
```

You can also invoke them through Bash without changing permissions:

```bash
bash ./scripts/validate-skills.sh
bash ./scripts/install-skills.sh --harness codex --bundle starter
```

## Path Notes

- Quote paths that contain spaces.
- Use `--harness` for known Codex, Claude Code, or OpenCode defaults.
- Use `--bundle`, `--skills`, or `--all`; the installer requires exactly one install selector.
- Use `--target-path` for a custom destination skills directory, not the target repo root.
- Use `--project-path` only with `--scope project` or bootstrap.
- The installer creates the target skills directory if needed.
- Existing skill folders are not overwritten unless `--force` is provided.

## Troubleshooting

`Permission denied`

Run `chmod +x ./scripts/*.sh` or invoke the script with `bash`.

`No such file or directory`

Run from the repository root or use an absolute path.

`Specify exactly one selector: --all, --skills, or --bundle`

Choose one install mode:

```bash
bash ./scripts/install-skills.sh --harness codex --bundle starter
```

`Target already contains skill folder`

Use `--force` only if replacing the installed skill is intended.

`Custom scope requires --target-path`

Use `--target-path` with `--scope custom`, or use a harness global/project scope.

`Unknown argument`

Use the documented long options:

```bash
--harness opencode --skills context-engineering,test-driven-development
```
