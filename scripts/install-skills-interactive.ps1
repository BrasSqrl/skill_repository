<#
.SYNOPSIS
Interactive Windows installer for selecting an agent harness and skills.

.DESCRIPTION
This script is launched by install-all-skills-windows.bat. It asks which
agent harness should receive the skills, resolves the correct target
directory, shows installed status, warns before overwriting, and delegates the
actual copy operation to scripts/install-skills.ps1.
#>

[CmdletBinding()]
param()

$ErrorActionPreference = "Stop"

function Write-Info {
    param([string]$Message)
    Write-Host "[INFO] $Message"
}

function Write-WarnLine {
    param([string]$Message)
    Write-Host "[WARN] $Message" -ForegroundColor Yellow
}

function Write-ErrorLine {
    param([string]$Message)
    Write-Host "[ERROR] $Message" -ForegroundColor Red
}

function Convert-ToFullPath {
    param([string]$Path)

    $expanded = [Environment]::ExpandEnvironmentVariables($Path.Trim().Trim('"'))
    if ($expanded -eq "~") {
        return [System.IO.Path]::GetFullPath($HOME)
    }

    if ($expanded.StartsWith("~\")) {
        $expanded = Join-Path $HOME $expanded.Substring(2)
    } elseif ($expanded.StartsWith("~/")) {
        $expanded = Join-Path $HOME $expanded.Substring(2)
    }

    return [System.IO.Path]::GetFullPath($expanded)
}

function Get-GlobalTargetPath {
    param([string]$Harness)

    switch ($Harness) {
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
            throw "Unsupported harness: $Harness"
        }
    }
}

function Get-HarnessProfiles {
    return @(
        [pscustomobject]@{
            Id = "codex"
            Label = "Codex"
            GlobalTarget = Get-GlobalTargetPath -Harness "codex"
            ProjectSubpath = $null
        },
        [pscustomobject]@{
            Id = "claude-code"
            Label = "Claude Code"
            GlobalTarget = Get-GlobalTargetPath -Harness "claude-code"
            ProjectSubpath = ".claude\skills"
        },
        [pscustomobject]@{
            Id = "opencode"
            Label = "OpenCode"
            GlobalTarget = Get-GlobalTargetPath -Harness "opencode"
            ProjectSubpath = ".opencode\skills"
        }
    )
}

function Select-Harness {
    param([array]$Profiles)

    while ($true) {
        Write-Host ""
        Write-Host "Choose agent harness:"
        Write-Host ""

        for ($i = 0; $i -lt $Profiles.Count; $i++) {
            $number = $i + 1
            $profile = $Profiles[$i]
            Write-Host ("  {0}. {1,-12} global: {2}" -f $number, $profile.Label, $profile.GlobalTarget)
        }

        Write-Host "  q. Quit"
        Write-Host ""

        $choice = Read-Host "Harness [1]"
        if ([string]::IsNullOrWhiteSpace($choice)) {
            return $Profiles[0]
        }

        if ($choice -match "^(?i:q|quit)$") {
            return $null
        }

        if ($choice -match "^\d+$") {
            $index = [int]$choice
            if ($index -ge 1 -and $index -le $Profiles.Count) {
                return $Profiles[$index - 1]
            }
        }

        $matchingProfile = $Profiles | Where-Object {
            $_.Id -eq $choice -or $_.Label -eq $choice
        } | Select-Object -First 1

        if ($matchingProfile) {
            return $matchingProfile
        }

        Write-ErrorLine "Invalid harness selection."
    }
}

function Read-RequiredPath {
    param([string]$Prompt)

    while ($true) {
        $path = Read-Host $Prompt
        if (-not [string]::IsNullOrWhiteSpace($path)) {
            return (Convert-ToFullPath -Path $path)
        }

        Write-WarnLine "A path is required."
    }
}

function Select-InstallTarget {
    param([pscustomobject]$Profile)

    while ($true) {
        Write-Host ""
        Write-Host "Selected harness:"
        Write-Host "  $($Profile.Label)"
        Write-Host ""
        Write-Host "Choose install scope:"
        Write-Host "  1. Global machine install"
        Write-Host "     $($Profile.GlobalTarget)"
        Write-Host "  2. Project-local install"
        if ($Profile.ProjectSubpath) {
            Write-Host "     <project>\$($Profile.ProjectSubpath)"
        } else {
            Write-Host "     Codex has no confirmed project-local default; a custom skills directory is required."
        }
        Write-Host "  3. Custom skills directory"
        Write-Host "  q. Quit"
        Write-Host ""

        $choice = Read-Host "Scope [1]"
        if ([string]::IsNullOrWhiteSpace($choice)) {
            $choice = "1"
        }

        if ($choice -match "^(?i:q|quit)$") {
            return $null
        }

        switch ($choice) {
            "1" {
                return [pscustomobject]@{
                    HarnessId = $Profile.Id
                    HarnessLabel = $Profile.Label
                    Scope = "global"
                    TargetPath = Convert-ToFullPath -Path $Profile.GlobalTarget
                }
            }
            "2" {
                if ($Profile.ProjectSubpath) {
                    $projectRoot = Read-RequiredPath -Prompt "Project root"
                    return [pscustomobject]@{
                        HarnessId = $Profile.Id
                        HarnessLabel = $Profile.Label
                        Scope = "project"
                        TargetPath = Join-Path $projectRoot $Profile.ProjectSubpath
                    }
                }

                Write-WarnLine "Codex project scope needs an explicit skills directory."
                $targetPath = Read-RequiredPath -Prompt "Codex project skills directory"
                return [pscustomobject]@{
                    HarnessId = $Profile.Id
                    HarnessLabel = $Profile.Label
                    Scope = "project"
                    TargetPath = $targetPath
                }
            }
            "3" {
                $targetPath = Read-RequiredPath -Prompt "Custom skills directory"
                return [pscustomobject]@{
                    HarnessId = $Profile.Id
                    HarnessLabel = $Profile.Label
                    Scope = "custom"
                    TargetPath = $targetPath
                }
            }
            default {
                Write-ErrorLine "Invalid scope selection."
            }
        }
    }
}

function Get-InstalledStatus {
    param(
        [string]$TargetPath,
        [string]$SkillName
    )

    if (Test-Path -LiteralPath (Join-Path $TargetPath $SkillName) -PathType Container) {
        return "installed"
    }

    return "not installed"
}

function Select-Skills {
    param(
        [array]$Skills,
        [pscustomobject]$InstallTarget
    )

    while ($true) {
        Write-Host ""
        Write-Host "Harness:"
        Write-Host "  $($InstallTarget.HarnessLabel)"
        Write-Host "Scope:"
        Write-Host "  $($InstallTarget.Scope)"
        Write-Host "Target:"
        Write-Host "  $($InstallTarget.TargetPath)"
        Write-Host ""
        Write-Host "Available skills:"
        Write-Host ""

        for ($i = 0; $i -lt $Skills.Count; $i++) {
            $number = $i + 1
            $name = $Skills[$i].Name
            $status = Get-InstalledStatus -TargetPath $InstallTarget.TargetPath -SkillName $name
            Write-Host ("  {0,2}. {1} [{2}]" -f $number, $name, $status)
        }

        Write-Host ""
        Write-Host "Enter one of:"
        Write-Host "  all                         install all skills"
        Write-Host "  1,3,5                       install by number"
        Write-Host "  context-engineering,refactoring"
        Write-Host "  q                           quit"
        Write-Host ""

        $choice = Read-Host "Skills to install"
        if ([string]::IsNullOrWhiteSpace($choice)) {
            Write-WarnLine "No skills selected."
            continue
        }

        if ($choice -match "^(?i:q|quit)$") {
            return $null
        }

        $selected = New-Object System.Collections.Generic.List[string]
        $invalid = New-Object System.Collections.Generic.List[string]
        $tokens = $choice -split "[,\s]+" | Where-Object { -not [string]::IsNullOrWhiteSpace($_) }

        foreach ($token in $tokens) {
            if ($token -match "^(?i:all|a)$") {
                foreach ($skill in $Skills) {
                    if (-not $selected.Contains($skill.Name)) {
                        $selected.Add($skill.Name)
                    }
                }
                continue
            }

            if ($token -match "^\d+$") {
                $index = [int]$token
                if ($index -ge 1 -and $index -le $Skills.Count) {
                    $skillName = $Skills[$index - 1].Name
                    if (-not $selected.Contains($skillName)) {
                        $selected.Add($skillName)
                    }
                } else {
                    $invalid.Add($token)
                }
                continue
            }

            $matchingSkill = $Skills | Where-Object { $_.Name -eq $token } | Select-Object -First 1
            if ($matchingSkill) {
                if (-not $selected.Contains($matchingSkill.Name)) {
                    $selected.Add($matchingSkill.Name)
                }
            } else {
                $invalid.Add($token)
            }
        }

        if ($invalid.Count -gt 0) {
            Write-ErrorLine "Invalid selection(s): $($invalid -join ', ')"
            Write-Host "Choose numbers from the list or exact skill names."
            continue
        }

        if ($selected.Count -eq 0) {
            Write-WarnLine "No valid skills selected."
            continue
        }

        return @($selected)
    }
}

try {
    $scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
    $repoRoot = (Resolve-Path (Join-Path $scriptDir "..")).Path
    $skillsPath = Join-Path $repoRoot "skills"
    $installerPath = Join-Path $scriptDir "install-skills.ps1"

    if (-not (Test-Path -LiteralPath $installerPath -PathType Leaf)) {
        throw "Could not find installer script: $installerPath"
    }

    if (-not (Test-Path -LiteralPath $skillsPath -PathType Container)) {
        throw "Could not find skills directory: $skillsPath"
    }

    $skills = @(Get-ChildItem -LiteralPath $skillsPath -Directory |
        Where-Object { Test-Path -LiteralPath (Join-Path $_.FullName "SKILL.md") -PathType Leaf } |
        Sort-Object Name)

    if ($skills.Count -eq 0) {
        throw "No skills found in: $skillsPath"
    }

    Write-Host "AI skill installer for Windows"
    Write-Host ""
    Write-Host "Source repo:"
    Write-Host "  $repoRoot"

    $profiles = Get-HarnessProfiles
    $profile = Select-Harness -Profiles $profiles
    if ($null -eq $profile) {
        Write-Info "Cancelled."
        exit 1
    }

    $installTarget = Select-InstallTarget -Profile $profile
    if ($null -eq $installTarget) {
        Write-Info "Cancelled."
        exit 1
    }

    $selectedSkills = Select-Skills -Skills $skills -InstallTarget $installTarget
    if ($null -eq $selectedSkills) {
        Write-Info "Cancelled."
        exit 1
    }

    Write-Host ""
    Write-Host "Selected harness:"
    Write-Host "  $($installTarget.HarnessLabel)"
    Write-Host "Selected skills:"
    Write-Host "  $($selectedSkills -join ', ')"

    $alreadyInstalled = @($selectedSkills | Where-Object {
        Test-Path -LiteralPath (Join-Path $installTarget.TargetPath $_) -PathType Container
    })

    $force = $false
    if ($alreadyInstalled.Count -gt 0) {
        Write-Host ""
        Write-WarnLine "These selected skills are already installed in the target:"
        Write-Host "  $($alreadyInstalled -join ', ')"
        Write-Host ""
        $overwrite = Read-Host "Overwrite already installed selected skills? [y/N]"
        if ($overwrite -match "^(?i:y|yes)$") {
            $force = $true
        } else {
            $selectedSkills = @($selectedSkills | Where-Object { $alreadyInstalled -notcontains $_ })
            if ($selectedSkills.Count -eq 0) {
                Write-Info "Nothing to install after skipping already installed skills."
                exit 0
            }
        }
    }

    Write-Host ""
    Write-Host "Installing:"
    Write-Host "  $($selectedSkills -join ', ')"
    Write-Host "Into:"
    Write-Host "  $($installTarget.TargetPath)"
    if ($force) {
        Write-WarnLine "Overwrite mode enabled."
    }
    Write-Host ""

    $arguments = @(
        "-NoProfile",
        "-ExecutionPolicy", "Bypass",
        "-File", $installerPath,
        "-Harness", $installTarget.HarnessId,
        "-Scope", $installTarget.Scope,
        "-TargetPath", $installTarget.TargetPath,
        "-Skills", ($selectedSkills -join ",")
    )

    if ($force) {
        $arguments += "-Force"
    }

    & powershell.exe @arguments
    $exitCode = $LASTEXITCODE

    if ($exitCode -eq 0) {
        Write-Host ""
        Write-Host "[OK] Skill installation completed." -ForegroundColor Green
    } else {
        Write-Host ""
        Write-ErrorLine "Skill installation failed with exit code $exitCode."
    }

    exit $exitCode
} catch {
    Write-ErrorLine $_.Exception.Message
    exit 1
}
