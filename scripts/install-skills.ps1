<#
.SYNOPSIS
Install skill folders into a harness-specific skills directory.

.DESCRIPTION
Copies selected folders from ./skills into a target directory. Skill selection
can come from -All, -Skills, or -Bundle. Harness defaults are read from
./harnesses/*.profile. By default, existing target skill folders are not
overwritten. Use -Force to replace them.

.EXAMPLES
.\scripts\install-skills.ps1 -Harness codex -Bundle starter

.\scripts\install-skills.ps1 -Harness claude-code -Skills context-engineering,test-driven-development

.\scripts\install-skills.ps1 -Harness opencode -All -DryRun

.\scripts\install-skills.ps1 -ListBundles

.\scripts\install-skills.ps1 -ListSkills
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

    [string]$Bundle,

    [switch]$All,

    [switch]$ListBundles,

    [switch]$ListSkills,

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

function Read-KeyValueFile {
    param([string]$Path)

    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        throw "Required profile file not found: $Path"
    }

    $values = @{}
    foreach ($line in Get-Content -LiteralPath $Path) {
        $trimmed = $line.Trim()
        if ([string]::IsNullOrWhiteSpace($trimmed) -or $trimmed.StartsWith("#")) {
            continue
        }

        $parts = $trimmed -split "=", 2
        if ($parts.Count -ne 2) {
            throw "Invalid key=value line in ${Path}: $line"
        }

        $values[$parts[0].Trim()] = $parts[1].Trim()
    }

    return $values
}

function Get-HarnessProfile {
    param(
        [string]$RepoRoot,
        [string]$HarnessName
    )

    $profilePath = Join-Path $RepoRoot "harnesses\$HarnessName.profile"
    $profile = Read-KeyValueFile -Path $profilePath
    if ($profile["id"] -ne $HarnessName) {
        throw "Harness profile id '$($profile["id"])' does not match '$HarnessName'"
    }

    return $profile
}

function Join-PortablePath {
    param(
        [string]$BasePath,
        [string]$RelativePath
    )

    $parts = $RelativePath -split "[/\\]" | Where-Object { -not [string]::IsNullOrWhiteSpace($_) }
    $result = $BasePath
    foreach ($part in $parts) {
        $result = Join-Path $result $part
    }

    return $result
}

function Resolve-InstallTargetPath {
    param(
        [string]$RepoRoot,
        [string]$HarnessName
    )

    if (-not [string]::IsNullOrWhiteSpace($TargetPath)) {
        return [System.IO.Path]::GetFullPath($TargetPath)
    }

    if ([string]::IsNullOrWhiteSpace($HarnessName)) {
        throw "Specify -TargetPath or provide -Harness codex, claude-code, or opencode."
    }

    $profile = Get-HarnessProfile -RepoRoot $RepoRoot -HarnessName $HarnessName

    switch ($Scope) {
        "global" {
            $globalEnv = $profile["global_env"]
            if (-not [string]::IsNullOrWhiteSpace($globalEnv)) {
                $envValue = [Environment]::GetEnvironmentVariable($globalEnv)
                if (-not [string]::IsNullOrWhiteSpace($envValue)) {
                    $suffix = $profile["global_suffix"]
                    if ([string]::IsNullOrWhiteSpace($suffix)) {
                        return [System.IO.Path]::GetFullPath($envValue)
                    }
                    return [System.IO.Path]::GetFullPath((Join-PortablePath -BasePath $envValue -RelativePath $suffix))
                }
            }

            return [System.IO.Path]::GetFullPath((Join-PortablePath -BasePath $HOME -RelativePath $profile["global_default"]))
        }
        "project" {
            if ($profile["supports_project_default"] -ne "true") {
                throw "$($profile["label"]) project scope has no default target. Use -TargetPath with the desired skills directory."
            }
            if ([string]::IsNullOrWhiteSpace($ProjectPath)) {
                throw "Project scope requires -ProjectPath unless -TargetPath is provided."
            }
            return [System.IO.Path]::GetFullPath((Join-PortablePath -BasePath $ProjectPath -RelativePath $profile["project_subpath"]))
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

        foreach ($part in ($item -split ",")) {
            $skill = $part.Trim()
            if ($skill) {
                $normalized += $skill
            }
        }
    }

    return @($normalized | Select-Object -Unique)
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
        Where-Object { -not [string]::IsNullOrWhiteSpace($_) -and -not $_.StartsWith("#") } |
        Select-Object -Unique)
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

function Show-Bundles {
    param([string]$RepoRoot)

    $bundleCatalog = Join-Path $RepoRoot "catalog\bundles.tsv"
    if (-not (Test-Path -LiteralPath $bundleCatalog -PathType Leaf)) {
        throw "Bundle catalog not found: $bundleCatalog"
    }

    Import-Csv -LiteralPath $bundleCatalog -Delimiter "`t" |
        Sort-Object id |
        Format-Table id, label, recommendation -Wrap
}

function Show-Skills {
    param([string]$RepoRoot)

    $skillCatalog = Join-Path $RepoRoot "catalog\skills.tsv"
    if (-not (Test-Path -LiteralPath $skillCatalog -PathType Leaf)) {
        throw "Skill catalog not found: $skillCatalog"
    }

    Import-Csv -LiteralPath $skillCatalog -Delimiter "`t" |
        Sort-Object name |
        Format-Table name, category, maturity, source, license, description -Wrap
}

try {
    $repoRoot = Get-RepoRoot
    $sourcePath = Join-Path $repoRoot "skills"

    if ($ListBundles) {
        Show-Bundles -RepoRoot $repoRoot
        exit 0
    }

    if ($ListSkills) {
        Show-Skills -RepoRoot $repoRoot
        exit 0
    }

    $selectorCount = 0
    if ($All) { $selectorCount++ }
    if ($Skills -and $Skills.Count -gt 0) { $selectorCount++ }
    if (-not [string]::IsNullOrWhiteSpace($Bundle)) { $selectorCount++ }

    if ($selectorCount -ne 1) {
        throw "Specify exactly one selector: -All, -Skills, or -Bundle."
    }

    if (-not (Test-Path -LiteralPath $sourcePath -PathType Container)) {
        throw "Source skills directory not found: $sourcePath"
    }

    if ($All) {
        $selectedSkills = @(Get-ChildItem -LiteralPath $sourcePath -Directory | Sort-Object Name | ForEach-Object { $_.Name })
    } elseif (-not [string]::IsNullOrWhiteSpace($Bundle)) {
        $selectedSkills = Get-BundleSkills -RepoRoot $repoRoot -BundleName $Bundle
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

    $targetFullPath = Resolve-InstallTargetPath -RepoRoot $repoRoot -HarnessName $Harness
    Write-Info "Source: $sourcePath"
    if (-not [string]::IsNullOrWhiteSpace($Harness)) {
        Write-Info "Harness: $Harness"
        Write-Info "Scope: $Scope"
    }
    if (-not [string]::IsNullOrWhiteSpace($Bundle)) {
        Write-Info "Bundle: $Bundle"
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
