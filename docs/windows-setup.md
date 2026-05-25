# Windows Setup

## PowerShell Usage

Run commands from the repository root:

```powershell
cd C:\path\to\ai_setup
.\scripts\validate-skills.ps1
```

Use the double-click guided installer:

```text
install-all-skills-windows.bat
```

The batch launcher opens an interactive PowerShell menu. It asks for harness, scope, bundle/all/individual skill selection, shows installed status, and warns before overwriting.

## Harness Defaults

| Harness | Global Windows target |
| --- | --- |
| Codex | `%CODEX_HOME%\skills` when set, otherwise `%USERPROFILE%\.codex\skills` |
| Claude Code | `%USERPROFILE%\.claude\skills` |
| OpenCode | `%USERPROFILE%\.config\opencode\skills` |

Project-local defaults:

| Harness | Project target |
| --- | --- |
| Claude Code | `<project>\.claude\skills` |
| OpenCode | `<project>\.opencode\skills` |
| Codex | No project default; provide `-TargetPath` |

## Example Commands

List bundles:

```powershell
.\scripts\install-skills.ps1 -ListBundles
```

Install the starter bundle globally for Codex:

```powershell
.\scripts\install-skills.ps1 -Harness codex -Bundle starter
```

Install a quality bundle for Claude Code:

```powershell
.\scripts\install-skills.ps1 -Harness claude-code -Bundle quality
```

Install selected skills for OpenCode:

```powershell
.\scripts\install-skills.ps1 -Harness opencode -Skills context-engineering,test-driven-development
```

Install project-local skills for Claude Code:

```powershell
.\scripts\install-skills.ps1 -Harness claude-code -Scope project -ProjectPath "C:\path\to\repo" -Bundle starter
```

Preview without copying:

```powershell
.\scripts\install-skills.ps1 -Harness opencode -Bundle starter -DryRun
```

Replace existing installed skills:

```powershell
.\scripts\install-skills.ps1 -Harness codex -Bundle starter -Force
```

Install into an explicit skills directory:

```powershell
.\scripts\install-skills.ps1 -TargetPath "C:\path\to\repo\.agent\skills" -Bundle starter
```

Bootstrap a target repo:

```powershell
.\scripts\bootstrap-agent-repo.ps1 -ProjectPath "C:\path\to\repo" -Harness claude-code -Bundle starter
```

Dry-run bootstrap:

```powershell
.\scripts\bootstrap-agent-repo.ps1 -ProjectPath "C:\path\to\repo" -Harness opencode -Bundle starter -DryRun
```

Score skills:

```powershell
.\scripts\score-skills.ps1
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
- Use `-Bundle`, `-Skills`, or `-All`; the installer requires exactly one install selector.
- Use `-TargetPath` for a custom destination skills directory, not the target repo root.
- Use `-ProjectPath` only with `-Scope project` or bootstrap.
- The installer creates the target skills directory if needed.
- Existing skill folders are not overwritten unless `-Force` is provided.

## Troubleshooting

`The term '.\scripts\validate-skills.ps1' is not recognized`

Run from the repository root, or use the full script path.

`Access to the path is denied`

Check folder permissions and whether another process has a file open.

`Specify exactly one selector: -All, -Skills, or -Bundle`

Choose one install mode:

```powershell
.\scripts\install-skills.ps1 -Harness codex -Bundle starter
```

`Target already contains skill folder`

Use `-Force` only if replacing the installed skill is intended. The batch installer also lets you skip already-installed selected skills.

`Custom scope requires -TargetPath`

Use `-TargetPath` with `-Scope custom`, or use a harness global/project scope.

`Cannot bind parameter 'Skills'`

Pass skill names as comma-separated values:

```powershell
-Skills context-engineering,test-driven-development
```
