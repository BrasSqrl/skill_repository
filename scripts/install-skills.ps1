<#
.SYNOPSIS
Install skill folders into a harness-specific skills directory.

.DESCRIPTION
Copies selected folders from ./skills into a target directory. By default,
existing target skill folders are not overwritten. Use -Force to replace them.
Use -Harness to install to a known agent harness location, or -TargetPath to
provide an explicit destination.

.EXAMPLES
.\scripts\install-skills.ps1 -Harness codex -All

.\scripts\install-skills.ps1 -Harness claude-code -Skills context-engineering,test-driven-development

.\scripts\install-skills.ps1 -Harness opencode -All -DryRun

.\scripts\install-skills.ps1 -Harness claude-code -Scope project -ProjectPath "C:\path\to\repo" -All

.\scripts\install-skills.ps1 -TargetPath "C:\path\to\repo\.agent\skills" -All -Force
#>

[CmdletBinding()]
param(
    [string]$TargetPath,

    [ValidateSet("codex", "claude-code", "opencode")]
    [string]$Harness,

    [ValidateSet("global", "project", "custom")]
    [string]$Scope = "global",

    [string]$ProjectPath,

    [string[]]$Skills,

    [switch]$All,

    [switch]$DryRun,

    [switch]$Force
)

$ErrorActionPreference = "Stop"

function Write-Info {
    param([string]$Message)
    Write-Host "[INFO] $Message"
}

function Write-Success {
    param([string]$Message)
    Write-Host "[OK] $Message" -ForegroundColor Green
}

function Write-Failure {
    param([string]$Message)
    Write-Host "[ERROR] $Message" -ForegroundColor Red
}

function Get-RepoRoot {
    if ($PSScriptRoot) {
        return (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
    }

    return (Get-Location).Path
}

function Get-GlobalHarnessTargetPath {
    param([string]$HarnessName)

    switch ($HarnessName) {
        "codex" {
            if ($env:CODEX_HOME) {
                return (Join-Path $env:CODEX_HOME "skills")
            }

            return (Join-Path $HOME ".codex\skills")
        }
        "claude-code" {
            return (Join-Path $HOME ".claude\skills")
        }
        "opencode" {
            return (Join-Path $HOME ".config\opencode\skills")
        }
        default {
            throw "Unsupported harness: $HarnessName"
        }
    }
}

function Get-ProjectHarnessTargetPath {
    param(
        [string]$HarnessName,
        [string]$RootPath
    )

    if ([string]::IsNullOrWhiteSpace($RootPath)) {
        throw "Project scope requires -ProjectPath unless -TargetPath is provided."
    }

    $projectFullPath = [System.IO.Path]::GetFullPath($RootPath)

    switch ($HarnessName) {
        "claude-code" {
            return (Join-Path $projectFullPath ".claude\skills")
        }
        "opencode" {
            return (Join-Path $projectFullPath ".opencode\skills")
        }
        "codex" {
            throw "Codex project scope has no default target. Use -TargetPath with the desired skills directory."
        }
        default {
            throw "Unsupported harness: $HarnessName"
        }
    }
}

function Resolve-InstallTargetPath {
    if (-not [string]::IsNullOrWhiteSpace($TargetPath)) {
        return [System.IO.Path]::GetFullPath($TargetPath)
    }

    if ([string]::IsNullOrWhiteSpace($Harness)) {
        throw "Specify -TargetPath or provide -Harness codex, claude-code, or opencode."
    }

    switch ($Scope) {
        "global" {
            return [System.IO.Path]::GetFullPath((Get-GlobalHarnessTargetPath -HarnessName $Harness))
        }
        "project" {
            return [System.IO.Path]::GetFullPath((Get-ProjectHarnessTargetPath -HarnessName $Harness -RootPath $ProjectPath))
        }
        "custom" {
            throw "Custom scope requires -TargetPath."
        }
        default {
            throw "Unsupported scope: $Scope"
        }
    }
}

function Normalize-SkillList {
    param([string[]]$RawSkills)

    $normalized = @()
    foreach ($item in $RawSkills) {
        if ([string]::IsNullOrWhiteSpace($item)) {
            continue
        }

        $parts = $item -split ","
        foreach ($part in $parts) {
            $skill = $part.Trim()
            if ($skill) {
                $normalized += $skill
            }
        }
    }

    return @($normalized | Select-Object -Unique)
}

function Test-ChildPath {
    param(
        [string]$Parent,
        [string]$Child
    )

    $parentFull = [System.IO.Path]::GetFullPath($Parent).TrimEnd([System.IO.Path]::DirectorySeparatorChar, [System.IO.Path]::AltDirectorySeparatorChar)
    $childFull = [System.IO.Path]::GetFullPath($Child).TrimEnd([System.IO.Path]::DirectorySeparatorChar, [System.IO.Path]::AltDirectorySeparatorChar)
    $comparison = [System.StringComparison]::OrdinalIgnoreCase
    return $childFull.StartsWith($parentFull + [System.IO.Path]::DirectorySeparatorChar, $comparison) -or
        $childFull.StartsWith($parentFull + [System.IO.Path]::AltDirectorySeparatorChar, $comparison)
}

try {
    if ($All -and $Skills -and $Skills.Count -gt 0) {
        throw "Use either -All or -Skills, not both."
    }

    if (-not $All -and (-not $Skills -or $Skills.Count -eq 0)) {
        throw "Specify -All or provide one or more names with -Skills."
    }

    $repoRoot = Get-RepoRoot
    $sourcePath = Join-Path $repoRoot "skills"

    if (-not (Test-Path -LiteralPath $sourcePath -PathType Container)) {
        throw "Source skills directory not found: $sourcePath"
    }

    if ($All) {
        $selectedSkills = @(Get-ChildItem -LiteralPath $sourcePath -Directory | Sort-Object Name | ForEach-Object { $_.Name })
    } else {
        $selectedSkills = Normalize-SkillList -RawSkills $Skills
    }

    if ($selectedSkills.Count -eq 0) {
        throw "No skills selected."
    }

    foreach ($skill in $selectedSkills) {
        if ($skill -notmatch "^[a-z0-9]+(-[a-z0-9]+)*$") {
            throw "Invalid skill name '$skill'. Skill names must use lowercase kebab-case."
        }

        $skillSource = Join-Path $sourcePath $skill
        $skillFile = Join-Path $skillSource "SKILL.md"
        if (-not (Test-Path -LiteralPath $skillSource -PathType Container)) {
            throw "Source skill not found: $skill"
        }

        if (-not (Test-Path -LiteralPath $skillFile -PathType Leaf)) {
            throw "Source skill '$skill' is missing SKILL.md"
        }
    }

    $targetFullPath = Resolve-InstallTargetPath
    Write-Info "Source: $sourcePath"
    if (-not [string]::IsNullOrWhiteSpace($Harness)) {
        Write-Info "Harness: $Harness"
        Write-Info "Scope: $Scope"
    }
    Write-Info "Target: $targetFullPath"
    Write-Info "Selected skills: $($selectedSkills -join ', ')"

    if ($DryRun) {
        Write-Info "Dry run mode: no files will be copied."
    } else {
        if (-not (Test-Path -LiteralPath $targetFullPath -PathType Container)) {
            New-Item -ItemType Directory -Path $targetFullPath -Force | Out-Null
            Write-Info "Created target directory: $targetFullPath"
        }
    }

    $blocked = @()
    foreach ($skill in $selectedSkills) {
        $targetSkillPath = Join-Path $targetFullPath $skill
        if ((Test-Path -LiteralPath $targetSkillPath) -and -not $Force) {
            $blocked += $skill
        }
    }

    if ($blocked.Count -gt 0 -and $DryRun) {
        Write-Info "Dry run found existing target skill folder(s) that would be skipped without -Force: $($blocked -join ', ')"
    } elseif ($blocked.Count -gt 0) {
        throw "Target already contains skill folder(s): $($blocked -join ', '). Re-run with -Force to overwrite."
    }

    foreach ($skill in $selectedSkills) {
        $skillSource = Join-Path $sourcePath $skill
        $targetSkillPath = Join-Path $targetFullPath $skill

        if ($DryRun) {
            if ((Test-Path -LiteralPath $targetSkillPath) -and $Force) {
                Write-Info "Would replace: $targetSkillPath"
            } elseif (Test-Path -LiteralPath $targetSkillPath) {
                Write-Info "Would skip existing '$skill' at '$targetSkillPath'"
                continue
            }
            Write-Info "Would copy '$skill' to '$targetSkillPath'"
            continue
        }

        if ((Test-Path -LiteralPath $targetSkillPath) -and $Force) {
            if (-not (Test-ChildPath -Parent $targetFullPath -Child $targetSkillPath)) {
                throw "Refusing to remove path outside target directory: $targetSkillPath"
            }
            Remove-Item -LiteralPath $targetSkillPath -Recurse -Force
            Write-Info "Removed existing skill: $targetSkillPath"
        }

        Copy-Item -LiteralPath $skillSource -Destination $targetFullPath -Recurse -Force:$Force
        Write-Success "Installed $skill"
    }

    if ($DryRun) {
        Write-Success "Dry run completed successfully."
    } else {
        Write-Success "Installed $($selectedSkills.Count) skill(s) into $targetFullPath"
    }

    exit 0
} catch {
    Write-Failure $_.Exception.Message
    exit 1
}
