# Linux Setup

## Shell Usage

Run commands from the repository root:

```bash
cd <repo-root>
bash ./scripts/validate-skills.sh
bash ./scripts/validate-evals.sh
```

## Harness Defaults

| Harness | Global Linux target |
| --- | --- |
| Codex | `$CODEX_HOME/skills` when set, otherwise `$HOME/.codex/skills` |
| Claude Code | `$HOME/.claude/skills` |
| OpenCode | `$HOME/.config/opencode/skills` |

Subagent defaults:

| Harness | Global Linux target |
| --- | --- |
| Codex | Guidance only during bootstrap |
| Claude Code | `$HOME/.claude/agents` |
| OpenCode | `$HOME/.config/opencode/agents` |

Project-local defaults:

| Harness | Project target |
| --- | --- |
| Claude Code | `<project>/.claude/skills` |
| OpenCode | `<project>/.opencode/skills` |
| Codex | No project default; provide `--target-path` |

Project-local subagent defaults:

| Harness | Project target |
| --- | --- |
| Claude Code | `<project>/.claude/agents` |
| OpenCode | `<project>/.opencode/agents` |
| Codex | Guidance only during bootstrap |

## Example Commands

List bundles:

```bash
bash ./scripts/install-skills.sh --list-bundles
bash ./scripts/install-skills.sh --list-agent-bundles
bash ./scripts/install-skills.sh --list-agents
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
TARGET_REPO="<target-repo>"
bash ./scripts/install-skills.sh --harness opencode --scope project --project-path "$TARGET_REPO" --bundle starter
```

Install starter skills with the recommended subagent bundle:

```bash
bash ./scripts/install-skills.sh --harness claude-code --bundle starter --include-agents
bash ./scripts/install-skills.sh --harness opencode --bundle starter --include-agents
```

Install bundles with their mapped specialist subagent bundles:

```bash
bash ./scripts/install-skills.sh --harness opencode --bundle backend --include-agents
bash ./scripts/install-skills.sh --harness opencode --bundle frontend --include-agents
bash ./scripts/install-skills.sh --harness opencode --bundle quality --include-agents
```

Install an explicit subagent bundle:

```bash
bash ./scripts/install-skills.sh --harness opencode --bundle security --include-agents --agent-bundle security-review
bash ./scripts/install-skills.sh --harness claude-code --bundle starter --include-agents --agent-bundle all-agents --dry-run
```

Install optional Azure DevOps delivery support:

```bash
bash ./scripts/install-skills.sh --harness opencode --bundle azure-devops-delivery --include-agents --agent-bundle azure-devops-review --dry-run
bash ./scripts/install-skills.sh --harness opencode --bundle azure-devops-delivery --include-agents --agent-bundle azure-devops-review
```

Install optional GitHub delivery support:

```bash
bash ./scripts/install-skills.sh --harness opencode --bundle github-delivery --include-agents --agent-bundle github-review --dry-run
bash ./scripts/install-skills.sh --harness opencode --bundle github-delivery --include-agents --agent-bundle github-review
```

Install selected subagents:

```bash
bash ./scripts/install-skills.sh --harness claude-code --bundle starter --include-agents --agents code-reviewer,validation-runner
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
SKILL_TARGET="<target-skills-dir>"
bash ./scripts/install-skills.sh --target-path "$SKILL_TARGET" --bundle starter
```

Bootstrap a target repo:

```bash
TARGET_REPO="<target-repo>"
bash ./scripts/bootstrap-agent-repo.sh --project-path "$TARGET_REPO" --harness opencode --bundle starter
bash ./scripts/bootstrap-agent-repo.sh --project-path "$TARGET_REPO" --harness opencode --bundle starter --include-agents
```

Dry-run bootstrap:

```bash
TARGET_REPO="<target-repo>"
bash ./scripts/bootstrap-agent-repo.sh --project-path "$TARGET_REPO" --harness claude-code --bundle starter --dry-run
```

Score skills:

```bash
bash ./scripts/score-skills.sh
bash ./scripts/score-agents.sh
```

Validate eval scenarios:

```bash
bash ./scripts/validate-evals.sh
```

Use eval validation after adding or changing files under `evals/` or `catalog/evals.tsv`.

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
- Use `--agent-target-path` when `--scope custom` and `--include-agents` are used with a native-agent harness.
- Use `--project-path` only with `--scope project` or bootstrap.
- The installer creates the target skills directory if needed.
- Existing skill folders and native agent files are not overwritten unless `--force` is provided.

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

`Target already contains agent file`

Use `--force` only if replacing the installed subagent is intended.

`Custom scope requires --target-path`

Use `--target-path` with `--scope custom`, or use a harness global/project scope.

`Custom scope with --include-agents requires --agent-target-path`

Provide both paths when installing skills and native subagents into custom directories:

```bash
SKILL_TARGET="<target-skills-dir>"
AGENT_TARGET="<target-agents-dir>"
bash ./scripts/install-skills.sh --harness claude-code --scope custom --target-path "$SKILL_TARGET" --bundle starter --include-agents --agent-target-path "$AGENT_TARGET"
```

`Unknown argument`

Use the documented long options:

```bash
--harness opencode --skills context-engineering,test-driven-development
```
