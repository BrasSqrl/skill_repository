<#
.SYNOPSIS
Interactive Windows installer for agent skill harnesses.

.DESCRIPTION
This script is launched by install-all-skills-windows.bat. It reads harness
profiles and bundle metadata from the repository, asks which harness and
install scope should receive the skills, lets the user choose a bundle, all
skills, or individual skills, warns before overwriting, and delegates the
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

function Read-KeyValueFile {
    param([string]$Path)

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

function Resolve-GlobalTargetPath {
    param([hashtable]$Profile)

    $globalEnv = $Profile["global_env"]
    if (-not [string]::IsNullOrWhiteSpace($globalEnv)) {
        $envValue = [Environment]::GetEnvironmentVariable($globalEnv)
        if (-not [string]::IsNullOrWhiteSpace($envValue)) {
            $suffix = $Profile["global_suffix"]
            if ([string]::IsNullOrWhiteSpace($suffix)) {
                return [System.IO.Path]::GetFullPath($envValue)
            }

            return [System.IO.Path]::GetFullPath((Join-PortablePath -BasePath $envValue -RelativePath $suffix))
        }
    }

    return [System.IO.Path]::GetFullPath((Join-PortablePath -BasePath $HOME -RelativePath $Profile["global_default"]))
}

function Get-HarnessProfiles {
    param([string]$RepoRoot)

    $profileDir = Join-Path $RepoRoot "harnesses"
    if (-not (Test-Path -LiteralPath $profileDir -PathType Container)) {
        throw "Harness profile directory not found: $profileDir"
    }

    $profiles = New-Object System.Collections.Generic.List[object]
    foreach ($profileFile in @(Get-ChildItem -LiteralPath $profileDir -Filter "*.profile" | Sort-Object Name)) {
        $profile = Read-KeyValueFile -Path $profileFile.FullName
        foreach ($requiredKey in @("id", "label", "global_default", "supports_project_default", "project_subpath")) {
            if (-not $profile.ContainsKey($requiredKey)) {
                throw "Harness profile '$($profileFile.Name)' is missing '$requiredKey'"
            }
        }

        $profiles.Add([pscustomobject]@{
            Id = $profile["id"]
            Label = $profile["label"]
            GlobalTarget = Resolve-GlobalTargetPath -Profile $profile
            ProjectSubpath = $profile["project_subpath"]
            SupportsProjectDefault = ($profile["supports_project_default"] -eq "true")
        })
    }

    $order = @{
        "codex" = 0
        "claude-code" = 1
        "opencode" = 2
    }

    return @($profiles | Sort-Object { if ($order.ContainsKey($_.Id)) { $order[$_.Id] } else { 99 } })
}

function Get-Bundles {
    param([string]$RepoRoot)

    $bundleCatalog = Join-Path $RepoRoot "catalog\bundles.tsv"
    if (-not (Test-Path -LiteralPath $bundleCatalog -PathType Leaf)) {
        throw "Bundle catalog not found: $bundleCatalog"
    }

    return @(Import-Csv -LiteralPath $bundleCatalog -Delimiter "`t" | Sort-Object id)
}

function Get-BundleSkills {
    param(
        [string]$RepoRoot,
        [string]$BundleId
    )

    $bundlePath = Join-Path $RepoRoot "catalog\bundles\$BundleId.txt"
    if (-not (Test-Path -LiteralPath $bundlePath -PathType Leaf)) {
        throw "Bundle file not found: $bundlePath"
    }

    return @(Get-Content -LiteralPath $bundlePath |
        ForEach-Object { $_.Trim() } |
        Where-Object { -not [string]::IsNullOrWhiteSpace($_) -and -not $_.StartsWith("#") } |
        Select-Object -Unique)
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
        if ($Profile.SupportsProjectDefault) {
            Write-Host "     <project>\$($Profile.ProjectSubpath)"
        } else {
            Write-Host "     $($Profile.Label) has no confirmed project-local default; use custom path."
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
                    ProjectPath = $null
                }
            }
            "2" {
                if (-not $Profile.SupportsProjectDefault) {
                    Write-WarnLine "$($Profile.Label) project scope needs an explicit skills directory."
                    $targetPath = Read-RequiredPath -Prompt "$($Profile.Label) project skills directory"
                    return [pscustomobject]@{
                        HarnessId = $Profile.Id
                        HarnessLabel = $Profile.Label
                        Scope = "custom"
                        TargetPath = $targetPath
                        ProjectPath = $null
                    }
                }

                $projectRoot = Read-RequiredPath -Prompt "Project root"
                return [pscustomobject]@{
                    HarnessId = $Profile.Id
                    HarnessLabel = $Profile.Label
                    Scope = "project"
                    TargetPath = Join-PortablePath -BasePath $projectRoot -RelativePath $Profile.ProjectSubpath
                    ProjectPath = $projectRoot
                }
            }
            "3" {
                $targetPath = Read-RequiredPath -Prompt "Custom skills directory"
                return [pscustomobject]@{
                    HarnessId = $Profile.Id
                    HarnessLabel = $Profile.Label
                    Scope = "custom"
                    TargetPath = $targetPath
                    ProjectPath = $null
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

function Select-Bundle {
    param([array]$Bundles)

    while ($true) {
        Write-Host ""
        Write-Host "Available bundles:"
        Write-Host ""
        for ($i = 0; $i -lt $Bundles.Count; $i++) {
            $number = $i + 1
            $bundle = $Bundles[$i]
            Write-Host ("  {0,2}. {1,-22} {2}" -f $number, $bundle.id, $bundle.label)
            Write-Host ("      {0}" -f $bundle.recommendation)
        }

        Write-Host "  q. Quit"
        Write-Host ""

        $choice = Read-Host "Bundle [starter]"
        if ([string]::IsNullOrWhiteSpace($choice)) {
            $choice = "starter"
        }

        if ($choice -match "^(?i:q|quit)$") {
            return $null
        }

        if ($choice -match "^\d+$") {
            $index = [int]$choice
            if ($index -ge 1 -and $index -le $Bundles.Count) {
                return $Bundles[$index - 1]
            }
        }

        $matchingBundle = $Bundles | Where-Object { $_.id -eq $choice } | Select-Object -First 1
        if ($matchingBundle) {
            return $matchingBundle
        }

        Write-ErrorLine "Invalid bundle selection."
    }
}

function Select-IndividualSkills {
    param(
        [array]$Skills,
        [pscustomobject]$InstallTarget
    )

    while ($true) {
        Write-Host ""
        Write-Host "Harness:"
        Write-Host "  $($InstallTarget.HarnessLabel)"
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

function Select-InstallPackage {
    param(
        [array]$Skills,
        [array]$Bundles,
        [pscustomobject]$InstallTarget,
        [string]$RepoRoot
    )

    while ($true) {
        Write-Host ""
        Write-Host "Choose what to install:"
        Write-Host "  1. Bundle"
        Write-Host "  2. All skills"
        Write-Host "  3. Individual skills"
        Write-Host "  q. Quit"
        Write-Host ""

        $choice = Read-Host "Install selection [1]"
        if ([string]::IsNullOrWhiteSpace($choice)) {
            $choice = "1"
        }

        if ($choice -match "^(?i:q|quit)$") {
            return $null
        }

        switch ($choice) {
            "1" {
                $bundle = Select-Bundle -Bundles $Bundles
                if ($null -eq $bundle) {
                    return $null
                }
                $bundleSkills = Get-BundleSkills -RepoRoot $RepoRoot -BundleId $bundle.id
                return [pscustomobject]@{
                    Mode = "bundle"
                    Bundle = $bundle.id
                    Skills = $bundleSkills
                }
            }
            "2" {
                return [pscustomobject]@{
                    Mode = "all"
                    Bundle = $null
                    Skills = @($Skills | ForEach-Object { $_.Name })
                }
            }
            "3" {
                $selectedSkills = Select-IndividualSkills -Skills $Skills -InstallTarget $InstallTarget
                if ($null -eq $selectedSkills) {
                    return $null
                }
                return [pscustomobject]@{
                    Mode = "skills"
                    Bundle = $null
                    Skills = $selectedSkills
                }
            }
            default {
                Write-ErrorLine "Invalid install selection."
            }
        }
    }
}

function Show-SelectedSkillStatus {
    param(
        [string[]]$SelectedSkills,
        [pscustomobject]$InstallTarget
    )

    Write-Host ""
    Write-Host "Selected harness:"
    Write-Host "  $($InstallTarget.HarnessLabel)"
    Write-Host "Scope:"
    Write-Host "  $($InstallTarget.Scope)"
    Write-Host "Target:"
    Write-Host "  $($InstallTarget.TargetPath)"
    Write-Host ""
    Write-Host "Selected skill status:"
    Write-Host ""

    foreach ($skill in $SelectedSkills) {
        $status = Get-InstalledStatus -TargetPath $InstallTarget.TargetPath -SkillName $skill
        Write-Host ("  {0,-38} [{1}]" -f $skill, $status)
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

    $profiles = Get-HarnessProfiles -RepoRoot $repoRoot
    $bundles = Get-Bundles -RepoRoot $repoRoot

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

    $selection = Select-InstallPackage -Skills $skills -Bundles $bundles -InstallTarget $installTarget -RepoRoot $repoRoot
    if ($null -eq $selection) {
        Write-Info "Cancelled."
        exit 1
    }

    $selectedSkills = @($selection.Skills)
    Show-SelectedSkillStatus -SelectedSkills $selectedSkills -InstallTarget $installTarget

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
            $selection = [pscustomobject]@{
                Mode = "skills"
                Bundle = $null
                Skills = $selectedSkills
            }
        }
    }

    Write-Host ""
    Write-Host "Installing:"
    if ($selection.Mode -eq "bundle") {
        Write-Host "  bundle: $($selection.Bundle)"
    } elseif ($selection.Mode -eq "all") {
        Write-Host "  all skills"
    } else {
        Write-Host "  $($selectedSkills -join ', ')"
    }
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
        "-TargetPath", $installTarget.TargetPath
    )

    if ($selection.Mode -eq "bundle" -and $selectedSkills.Count -eq $selection.Skills.Count) {
        $arguments += @("-Bundle", $selection.Bundle)
    } elseif ($selection.Mode -eq "all" -and $selectedSkills.Count -eq $skills.Count) {
        $arguments += "-All"
    } else {
        $arguments += @("-Skills", ($selectedSkills -join ","))
    }

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
