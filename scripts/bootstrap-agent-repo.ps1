<#
.SYNOPSIS
Bootstrap a repository with agent skills and repository instructions.

.DESCRIPTION
Installs a selected skill bundle for Codex, Claude Code, or OpenCode, copies
the project AGENTS.md template when the target repo does not already have one,
and writes docs/agents/installed-skills.md with the installed bundle details.

.EXAMPLES
.\scripts\bootstrap-agent-repo.ps1 -ProjectPath "C:\work\app" -Harness claude-code -Bundle starter

.\scripts\bootstrap-agent-repo.ps1 -ProjectPath "C:\work\app" -Harness codex -Scope global -Bundle starter -DryRun

.\scripts\bootstrap-agent-repo.ps1 -ProjectPath "C:\work\app" -Harness opencode -Scope custom -TargetPath "C:\tools\opencode-skills" -Bundle quality
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$ProjectPath,

    [ValidateSet("codex", "claude-code", "opencode")]
    [string]$Harness = "codex",

    [string]$Bundle = "starter",

    [ValidateSet("auto", "global", "project", "custom")]
    [string]$Scope = "auto",

    [string]$TargetPath,

    [switch]$DryRun,

    [switch]$Force
)

$ErrorActionPreference = "Stop"

function Write-Info {
    param([string]$Message)
    Write-Host "[INFO] $Message"
}

function Write-Ok {
    param([string]$Message)
    Write-Host "[OK] $Message" -ForegroundColor Green
}

function Write-WarnLine {
    param([string]$Message)
    Write-Host "[WARN] $Message" -ForegroundColor Yellow
}

function Write-ErrorLine {
    param([string]$Message)
    Write-Host "[ERROR] $Message" -ForegroundColor Red
}

function Get-RepoRoot {
    if ($PSScriptRoot) {
        return (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
    }

    return (Get-Location).Path
}

function Get-BundleSkills {
    param(
        [string]$RepoRoot,
        [string]$BundleName
    )

    if ($BundleName -notmatch "^[a-z0-9]+(-[a-z0-9]+)*$") {
        throw "Invalid bundle name '$BundleName'. Bundle names must use lowercase kebab-case."
    }

    $bundlePath = Join-Path $RepoRoot "catalog\bundles\$BundleName.txt"
    if (-not (Test-Path -LiteralPath $bundlePath -PathType Leaf)) {
        throw "Bundle not found: $BundleName"
    }

    return @(Get-Content -LiteralPath $bundlePath |
        ForEach-Object { $_.Trim() } |
        Where-Object { -not [string]::IsNullOrWhiteSpace($_) -and -not $_.StartsWith("#") })
}

function Resolve-BootstrapScope {
    param(
        [string]$HarnessName,
        [string]$RequestedScope,
        [string]$RequestedTargetPath
    )

    if (-not [string]::IsNullOrWhiteSpace($RequestedTargetPath)) {
        return "custom"
    }

    if ($RequestedScope -ne "auto") {
        return $RequestedScope
    }

    if ($HarnessName -eq "codex") {
        return "global"
    }

    return "project"
}

try {
    $repoRoot = Get-RepoRoot
    $projectFullPath = [System.IO.Path]::GetFullPath($ProjectPath)
    $installerPath = Join-Path $repoRoot "scripts\install-skills.ps1"
    $templatePath = Join-Path $repoRoot "templates\project-AGENTS.md"
    $recordDir = Join-Path $projectFullPath "docs\agents"
    $recordPath = Join-Path $recordDir "installed-skills.md"
    $agentsPath = Join-Path $projectFullPath "AGENTS.md"
    $effectiveScope = Resolve-BootstrapScope -HarnessName $Harness -RequestedScope $Scope -RequestedTargetPath $TargetPath
    $bundleSkills = Get-BundleSkills -RepoRoot $repoRoot -BundleName $Bundle

    if (-not (Test-Path -LiteralPath $projectFullPath -PathType Container)) {
        throw "Project path not found: $projectFullPath"
    }

    if (-not (Test-Path -LiteralPath $installerPath -PathType Leaf)) {
        throw "Installer script not found: $installerPath"
    }

    if (-not (Test-Path -LiteralPath $templatePath -PathType Leaf)) {
        throw "Project AGENTS.md template not found: $templatePath"
    }

    Write-Info "Project: $projectFullPath"
    Write-Info "Harness: $Harness"
    Write-Info "Bundle: $Bundle"
    Write-Info "Scope: $effectiveScope"
    if ($TargetPath) {
        Write-Info "Target override: $([System.IO.Path]::GetFullPath($TargetPath))"
    }

    $installerArgs = @{
        Harness = $Harness
        Scope = $effectiveScope
        ProjectPath = $projectFullPath
        Bundle = $Bundle
    }

    if ($TargetPath) {
        $installerArgs["TargetPath"] = $TargetPath
    }

    if ($DryRun) {
        $installerArgs["DryRun"] = $true
    }

    if ($Force) {
        $installerArgs["Force"] = $true
    }

    & $installerPath @installerArgs
    $installExitCode = $LASTEXITCODE
    if ($installExitCode -ne 0) {
        throw "Skill installation failed with exit code $installExitCode"
    }

    if ($DryRun) {
        Write-Info "Dry run: would inspect $agentsPath"
        if (Test-Path -LiteralPath $agentsPath -PathType Leaf) {
            if ($Force) {
                Write-Info "Dry run: would replace existing AGENTS.md from template."
            } else {
                Write-Info "Dry run: would preserve existing AGENTS.md."
            }
        } else {
            Write-Info "Dry run: would copy templates/project-AGENTS.md to AGENTS.md."
        }

        Write-Info "Dry run: would write $recordPath"
        Write-Ok "Bootstrap dry run completed."
        exit 0
    }

    if (Test-Path -LiteralPath $agentsPath -PathType Leaf) {
        if ($Force) {
            Copy-Item -LiteralPath $templatePath -Destination $agentsPath -Force
            Write-WarnLine "Replaced existing AGENTS.md because -Force was provided."
        } else {
            Write-Info "Preserved existing AGENTS.md. Use -Force to replace it from the template."
        }
    } else {
        Copy-Item -LiteralPath $templatePath -Destination $agentsPath
        Write-Ok "Created AGENTS.md from template."
    }

    if (-not (Test-Path -LiteralPath $recordDir -PathType Container)) {
        New-Item -ItemType Directory -Path $recordDir -Force | Out-Null
    }

    $timestamp = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
    $record = @(
        "# Installed Agent Skills",
        "",
        'Generated by `scripts/bootstrap-agent-repo.ps1`.',
        "",
        "- Harness: ``$Harness``",
        "- Bundle: ``$Bundle``",
        "- Scope: ``$effectiveScope``",
        "- Installed at: ``$timestamp``",
        "",
        "## Skills",
        ""
    )

    foreach ($skill in $bundleSkills) {
        $record += "- ``$skill``"
    }

    $record += @(
        "",
        "## Validation Notes",
        "",
        "- Validate the target repository after installing skills.",
        '- Keep project-specific edits in the target repo''s `AGENTS.md`; keep reusable workflow logic in installed skills.',
        '- Re-run the installer with `-DryRun` before overwriting installed skills.'
    )

    Set-Content -LiteralPath $recordPath -Value $record -Encoding UTF8
    Write-Ok "Wrote installed skill record: $recordPath"
    Write-Ok "Bootstrap completed."
    exit 0
} catch {
    Write-ErrorLine $_.Exception.Message
    exit 1
}
