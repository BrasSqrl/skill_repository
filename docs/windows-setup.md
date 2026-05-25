# Windows Setup

## PowerShell Usage

Run commands from the repository root:

```powershell
cd C:\path\to\ai_setup
.\scripts\validate-skills.ps1
```

For a double-click installer, run:

```text
install-all-skills-windows.bat
```

The batch launcher opens an interactive PowerShell menu. It asks for the harness first, then install scope, then skills. It shows which skills are already installed in the selected target and warns before overwriting.

## Harness Defaults

| Harness | Global Windows target |
|---|---|
| Codex | `%CODEX_HOME%\skills` when set, otherwise `%USERPROFILE%\.codex\skills` |
| Claude Code | `%USERPROFILE%\.claude\skills` |
| OpenCode | `%USERPROFILE%\.config\opencode\skills` |

Project-local defaults:

| Harness | Project target |
|---|---|
| Claude Code | `<project>\.claude\skills` |
| OpenCode | `<project>\.opencode\skills` |
| Codex | No project default; provide `-TargetPath` |

## Example Commands

Install all skills globally for Codex:

```powershell
.\scripts\install-skills.ps1 -Harness codex -All
```

Install all skills globally for Claude Code:

```powershell
.\scripts\install-skills.ps1 -Harness claude-code -All
```

Install selected skills globally for OpenCode:

```powershell
.\scripts\install-skills.ps1 -Harness opencode -Skills context-engineering,test-driven-development
```

Install project-local skills for Claude Code:

```powershell
.\scripts\install-skills.ps1 -Harness claude-code -Scope project -ProjectPath "C:\path\to\repo" -All
```

Preview without copying:

```powershell
.\scripts\install-skills.ps1 -Harness opencode -All -DryRun
```

Replace existing installed skills:

```powershell
.\scripts\install-skills.ps1 -Harness codex -All -Force
```

Install into an explicit skills directory:

```powershell
.\scripts\install-skills.ps1 -TargetPath "C:\path\to\repo\.agent\skills" -All
```

## Execution Policy

If PowerShell blocks local scripts, use a process-scoped bypass for the current shell:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
```

Then rerun the command. Avoid changing machine-wide policy unless your environment requires it.

The batch launcher already invokes PowerShell with `-ExecutionPolicy Bypass` for that process.

## Path Notes

- Quote paths that contain spaces.
- Use `-Harness` for known Codex, Claude Code, or OpenCode defaults.
- Use `-TargetPath` for a custom destination skills directory, not the target repo root.
- Use `-ProjectPath` only with `-Scope project`.
- The installer creates the target skills directory if needed.
- Existing skill folders are not overwritten unless `-Force` is provided.

## Troubleshooting

`The term '.\scripts\validate-skills.ps1' is not recognized`

Run from the repository root, or use the full script path.

`Access to the path is denied`

Check folder permissions and whether another process has a file open.

`Target already contains skill folder`

Use `-Force` only if replacing the installed skill is intended. The batch installer also lets you skip already-installed selected skills.

`Custom scope requires -TargetPath`

Use `-TargetPath` with `-Scope custom`, or use a harness global/project scope.

`Cannot bind parameter 'Skills'`

Pass skill names as comma-separated values:

```powershell
-Skills context-engineering,test-driven-development
```
