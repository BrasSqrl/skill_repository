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
$script:BackToken = "__BACK__"

function Test-IsBack {
    param([object]$Value)

    return ($Value -is [string] -and $Value -eq $script:BackToken)
}

function New-DefaultAgentSelection {
    return [pscustomobject]@{
        IncludeAgents = $false
        Mode = "none"
        Bundle = $null
        Agents = @()
        AgentTargetPath = $null
    }
}

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

function Resolve-GlobalAgentTargetPath {
    param([hashtable]$Profile)

    if ($Profile["agent_support"] -ne "native") {
        return $null
    }

    $agentEnv = $Profile["agent_global_env"]
    if (-not [string]::IsNullOrWhiteSpace($agentEnv)) {
        $envValue = [Environment]::GetEnvironmentVariable($agentEnv)
        if (-not [string]::IsNullOrWhiteSpace($envValue)) {
            $suffix = $Profile["agent_global_suffix"]
            if ([string]::IsNullOrWhiteSpace($suffix)) {
                return [System.IO.Path]::GetFullPath($envValue)
            }

            return [System.IO.Path]::GetFullPath((Join-PortablePath -BasePath $envValue -RelativePath $suffix))
        }
    }

    return [System.IO.Path]::GetFullPath((Join-PortablePath -BasePath $HOME -RelativePath $Profile["agent_global_default"]))
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
        foreach ($requiredKey in @("id", "label", "global_default", "supports_project_default", "project_subpath", "agent_support", "agent_global_default", "agent_project_subpath", "supports_agent_project_default")) {
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
            AgentSupport = $profile["agent_support"]
            GlobalAgentTarget = Resolve-GlobalAgentTargetPath -Profile $profile
            AgentProjectSubpath = $profile["agent_project_subpath"]
            SupportsAgentProjectDefault = ($profile["supports_agent_project_default"] -eq "true")
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

function Get-AgentBundles {
    param([string]$RepoRoot)

    $agentBundleCatalog = Join-Path $RepoRoot "catalog\agent-bundles.tsv"
    if (-not (Test-Path -LiteralPath $agentBundleCatalog -PathType Leaf)) {
        throw "Agent bundle catalog not found: $agentBundleCatalog"
    }

    return @(Import-Csv -LiteralPath $agentBundleCatalog -Delimiter "`t" | Sort-Object id)
}

function Get-Agents {
    param([string]$RepoRoot)

    $agentCatalog = Join-Path $RepoRoot "catalog\agents.tsv"
    if (-not (Test-Path -LiteralPath $agentCatalog -PathType Leaf)) {
        throw "Agent catalog not found: $agentCatalog"
    }

    return @(Import-Csv -LiteralPath $agentCatalog -Delimiter "`t" | Sort-Object name)
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

function Get-AgentBundleAgents {
    param(
        [string]$RepoRoot,
        [string]$BundleId
    )

    $bundlePath = Join-Path $RepoRoot "catalog\agent-bundles\$BundleId.txt"
    if (-not (Test-Path -LiteralPath $bundlePath -PathType Leaf)) {
        throw "Agent bundle file not found: $bundlePath"
    }

    return @(Get-Content -LiteralPath $bundlePath |
        ForEach-Object { $_.Trim() } |
        Where-Object { -not [string]::IsNullOrWhiteSpace($_) -and -not $_.StartsWith("#") } |
        Select-Object -Unique)
}

function Get-DefaultAgentBundle {
    param(
        [string]$SelectionMode,
        [string]$SkillBundle
    )

    if ($SelectionMode -eq "bundle") {
        switch ($SkillBundle) {
            "starter" { return "starter-review" }
            "backend" { return "backend-review" }
            "frontend" { return "frontend-review" }
            "quality" { return "testing-review" }
            "security" { return "security-review" }
            "delivery" { return "delivery-review" }
            "azure-devops-delivery" { return "azure-devops-review" }
            "github-delivery" { return "github-review" }
            { $_ -in @("agent-orchestration", "all-software-dev") } { return "all-agents" }
            default { return "starter-review" }
        }
    }

    return "starter-review"
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
    param(
        [string]$Prompt,
        [switch]$AllowBack
    )

    while ($true) {
        $path = Read-Host $Prompt
        if ($AllowBack -and $path -match "^(?i:b|back)$") {
            return $script:BackToken
        }

        if (-not [string]::IsNullOrWhiteSpace($path)) {
            return (Convert-ToFullPath -Path $path)
        }

        if ($AllowBack) {
            Write-WarnLine "A path is required. Enter 'b' to go back."
        } else {
            Write-WarnLine "A path is required."
        }
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
        Write-Host "  b. Back"
        Write-Host "  q. Quit"
        Write-Host ""

        $choice = Read-Host "Scope [1]"
        if ([string]::IsNullOrWhiteSpace($choice)) {
            $choice = "1"
        }

        if ($choice -match "^(?i:q|quit)$") {
            return $null
        }

        if ($choice -match "^(?i:b|back)$") {
            return $script:BackToken
        }

        switch ($choice) {
            "1" {
                return [pscustomobject]@{
                    HarnessId = $Profile.Id
                    HarnessLabel = $Profile.Label
                    Scope = "global"
                    TargetPath = Convert-ToFullPath -Path $Profile.GlobalTarget
                    AgentTargetPath = $Profile.GlobalAgentTarget
                    AgentSupport = $Profile.AgentSupport
                    ProjectPath = $null
                }
            }
            "2" {
                if (-not $Profile.SupportsProjectDefault) {
                    Write-WarnLine "$($Profile.Label) project scope needs an explicit skills directory."
                    $targetPath = Read-RequiredPath -Prompt "$($Profile.Label) project skills directory (b=back)" -AllowBack
                    if (Test-IsBack $targetPath) {
                        continue
                    }
                    return [pscustomobject]@{
                        HarnessId = $Profile.Id
                        HarnessLabel = $Profile.Label
                        Scope = "custom"
                        TargetPath = $targetPath
                        AgentTargetPath = $null
                        AgentSupport = $Profile.AgentSupport
                        ProjectPath = $null
                    }
                }

                $projectRoot = Read-RequiredPath -Prompt "Project root (b=back)" -AllowBack
                if (Test-IsBack $projectRoot) {
                    continue
                }
                $agentProjectTarget = $null
                if ($Profile.AgentSupport -eq "native" -and $Profile.SupportsAgentProjectDefault) {
                    $agentProjectTarget = Join-PortablePath -BasePath $projectRoot -RelativePath $Profile.AgentProjectSubpath
                }
                return [pscustomobject]@{
                    HarnessId = $Profile.Id
                    HarnessLabel = $Profile.Label
                    Scope = "project"
                    TargetPath = Join-PortablePath -BasePath $projectRoot -RelativePath $Profile.ProjectSubpath
                    AgentTargetPath = $agentProjectTarget
                    AgentSupport = $Profile.AgentSupport
                    ProjectPath = $projectRoot
                }
            }
            "3" {
                $targetPath = Read-RequiredPath -Prompt "Custom skills directory (b=back)" -AllowBack
                if (Test-IsBack $targetPath) {
                    continue
                }
                return [pscustomobject]@{
                    HarnessId = $Profile.Id
                    HarnessLabel = $Profile.Label
                    Scope = "custom"
                    TargetPath = $targetPath
                    AgentTargetPath = $null
                    AgentSupport = $Profile.AgentSupport
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

function Get-InstalledAgentStatus {
    param(
        [string]$TargetPath,
        [string]$AgentName
    )

    if ([string]::IsNullOrWhiteSpace($TargetPath)) {
        return "guidance only"
    }

    if (Test-Path -LiteralPath (Join-Path $TargetPath "$AgentName.md") -PathType Leaf) {
        return "installed"
    }

    return "not installed"
}

function Resolve-InteractiveAgentTarget {
    param([pscustomobject]$InstallTarget)

    if ($InstallTarget.AgentSupport -ne "native") {
        return $null
    }

    if (-not [string]::IsNullOrWhiteSpace($InstallTarget.AgentTargetPath)) {
        return $InstallTarget.AgentTargetPath
    }

    return (Read-RequiredPath -Prompt "$($InstallTarget.HarnessLabel) native agent directory (b=back)" -AllowBack)
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

        Write-Host "  b. Back"
        Write-Host "  q. Quit"
        Write-Host ""

        $choice = Read-Host "Bundle [starter]"
        if ([string]::IsNullOrWhiteSpace($choice)) {
            $choice = "starter"
        }

        if ($choice -match "^(?i:q|quit)$") {
            return $null
        }

        if ($choice -match "^(?i:b|back)$") {
            return $script:BackToken
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
        Write-Host "  b                           back"
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

        if ($choice -match "^(?i:b|back)$") {
            return $script:BackToken
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
        Write-Host "  b. Back"
        Write-Host "  q. Quit"
        Write-Host ""

        $choice = Read-Host "Install selection [1]"
        if ([string]::IsNullOrWhiteSpace($choice)) {
            $choice = "1"
        }

        if ($choice -match "^(?i:q|quit)$") {
            return $null
        }

        if ($choice -match "^(?i:b|back)$") {
            return $script:BackToken
        }

        switch ($choice) {
            "1" {
                $bundle = Select-Bundle -Bundles $Bundles
                if (Test-IsBack $bundle) {
                    continue
                }
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
                if (Test-IsBack $selectedSkills) {
                    continue
                }
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

function Select-AgentBundle {
    param(
        [array]$AgentBundles,
        [string]$DefaultBundle
    )

    while ($true) {
        Write-Host ""
        Write-Host "Available agent bundles:"
        Write-Host ""
        for ($i = 0; $i -lt $AgentBundles.Count; $i++) {
            $number = $i + 1
            $bundle = $AgentBundles[$i]
            Write-Host ("  {0,2}. {1,-22} {2}" -f $number, $bundle.id, $bundle.label)
            Write-Host ("      {0}" -f $bundle.recommendation)
        }
        Write-Host "  b. Back"
        Write-Host "  q. Quit"
        Write-Host ""

        $choice = Read-Host "Agent bundle [$DefaultBundle]"
        if ([string]::IsNullOrWhiteSpace($choice)) {
            $choice = $DefaultBundle
        }

        if ($choice -match "^(?i:q|quit)$") {
            return $null
        }

        if ($choice -match "^(?i:b|back)$") {
            return $script:BackToken
        }

        if ($choice -match "^\d+$") {
            $index = [int]$choice
            if ($index -ge 1 -and $index -le $AgentBundles.Count) {
                return $AgentBundles[$index - 1]
            }
        }

        $matchingBundle = $AgentBundles | Where-Object { $_.id -eq $choice } | Select-Object -First 1
        if ($matchingBundle) {
            return $matchingBundle
        }

        Write-ErrorLine "Invalid agent bundle selection."
    }
}

function Select-IndividualAgents {
    param(
        [array]$Agents,
        [string]$AgentTargetPath
    )

    while ($true) {
        Write-Host ""
        Write-Host "Available subagents:"
        Write-Host ""

        for ($i = 0; $i -lt $Agents.Count; $i++) {
            $number = $i + 1
            $name = $Agents[$i].name
            $status = Get-InstalledAgentStatus -TargetPath $AgentTargetPath -AgentName $name
            Write-Host ("  {0,2}. {1} [{2}]" -f $number, $name, $status)
        }

        Write-Host ""
        Write-Host "Enter one of:"
        Write-Host "  1,3,5                       install by number"
        Write-Host "  code-reviewer,validation-runner"
        Write-Host "  b                           back"
        Write-Host "  q                           quit"
        Write-Host ""

        $choice = Read-Host "Agents to install"
        if ([string]::IsNullOrWhiteSpace($choice)) {
            Write-WarnLine "No agents selected."
            continue
        }

        if ($choice -match "^(?i:q|quit)$") {
            return $null
        }

        if ($choice -match "^(?i:b|back)$") {
            return $script:BackToken
        }

        $selected = New-Object System.Collections.Generic.List[string]
        $invalid = New-Object System.Collections.Generic.List[string]
        $tokens = $choice -split "[,\s]+" | Where-Object { -not [string]::IsNullOrWhiteSpace($_) }

        foreach ($token in $tokens) {
            if ($token -match "^\d+$") {
                $index = [int]$token
                if ($index -ge 1 -and $index -le $Agents.Count) {
                    $agentName = $Agents[$index - 1].name
                    if (-not $selected.Contains($agentName)) {
                        $selected.Add($agentName)
                    }
                } else {
                    $invalid.Add($token)
                }
                continue
            }

            $matchingAgent = $Agents | Where-Object { $_.name -eq $token } | Select-Object -First 1
            if ($matchingAgent) {
                if (-not $selected.Contains($matchingAgent.name)) {
                    $selected.Add($matchingAgent.name)
                }
            } else {
                $invalid.Add($token)
            }
        }

        if ($invalid.Count -gt 0) {
            Write-ErrorLine "Invalid selection(s): $($invalid -join ', ')"
            Write-Host "Choose numbers from the list or exact agent names."
            continue
        }

        if ($selected.Count -eq 0) {
            Write-WarnLine "No valid agents selected."
            continue
        }

        return @($selected)
    }
}

function Select-AgentPackage {
    param(
        [array]$Agents,
        [array]$AgentBundles,
        [pscustomobject]$SkillSelection,
        [pscustomobject]$InstallTarget,
        [string]$RepoRoot,
        [string]$AgentTargetPath
    )

    $defaultAgentBundle = Get-DefaultAgentBundle -SelectionMode $SkillSelection.Mode -SkillBundle $SkillSelection.Bundle

    while ($true) {
        Write-Host ""
        Write-Host "Choose subagents to install:"
        if ($InstallTarget.AgentSupport -eq "native") {
            Write-Host "  Native agent target: $AgentTargetPath"
        } else {
            Write-Host "  $($InstallTarget.HarnessLabel) will receive portable guidance docs only during bootstrap."
        }
        Write-Host ""
        Write-Host "  1. Recommended agent bundle ($defaultAgentBundle)"
        Write-Host "  2. Different agent bundle"
        Write-Host "  3. All subagents"
        Write-Host "  4. Individual subagents"
        Write-Host "  5. Skip subagents"
        Write-Host "  b. Back"
        Write-Host "  q. Quit"
        Write-Host ""

        $choice = Read-Host "Subagent selection [1]"
        if ([string]::IsNullOrWhiteSpace($choice)) {
            $choice = "1"
        }

        if ($choice -match "^(?i:q|quit)$") {
            return $null
        }

        if ($choice -match "^(?i:b|back)$") {
            return $script:BackToken
        }

        switch ($choice) {
            "1" {
                return [pscustomobject]@{
                    IncludeAgents = $true
                    Mode = "bundle"
                    Bundle = $defaultAgentBundle
                    Agents = @(Get-AgentBundleAgents -RepoRoot $RepoRoot -BundleId $defaultAgentBundle)
                    AgentTargetPath = $AgentTargetPath
                }
            }
            "2" {
                $bundle = Select-AgentBundle -AgentBundles $AgentBundles -DefaultBundle $defaultAgentBundle
                if (Test-IsBack $bundle) {
                    continue
                }
                if ($null -eq $bundle) {
                    return $null
                }
                return [pscustomobject]@{
                    IncludeAgents = $true
                    Mode = "bundle"
                    Bundle = $bundle.id
                    Agents = @(Get-AgentBundleAgents -RepoRoot $RepoRoot -BundleId $bundle.id)
                    AgentTargetPath = $AgentTargetPath
                }
            }
            "3" {
                return [pscustomobject]@{
                    IncludeAgents = $true
                    Mode = "agents"
                    Bundle = $null
                    Agents = @($Agents | ForEach-Object { $_.name })
                    AgentTargetPath = $AgentTargetPath
                }
            }
            "4" {
                $selectedAgents = Select-IndividualAgents -Agents $Agents -AgentTargetPath $AgentTargetPath
                if (Test-IsBack $selectedAgents) {
                    continue
                }
                if ($null -eq $selectedAgents) {
                    return $null
                }
                return [pscustomobject]@{
                    IncludeAgents = $true
                    Mode = "agents"
                    Bundle = $null
                    Agents = $selectedAgents
                    AgentTargetPath = $AgentTargetPath
                }
            }
            "5" {
                return [pscustomobject]@{
                    IncludeAgents = $false
                    Mode = "none"
                    Bundle = $null
                    Agents = @()
                    AgentTargetPath = $AgentTargetPath
                }
            }
            default {
                Write-ErrorLine "Invalid subagent selection."
            }
        }
    }
}

function Show-SelectedAgentStatus {
    param(
        [string[]]$SelectedAgents,
        [string]$AgentTargetPath,
        [pscustomobject]$InstallTarget
    )

    if ($SelectedAgents.Count -eq 0) {
        return
    }

    Write-Host ""
    Write-Host "Selected subagent status:"
    Write-Host ""
    foreach ($agent in $SelectedAgents) {
        $status = Get-InstalledAgentStatus -TargetPath $AgentTargetPath -AgentName $agent
        Write-Host ("  {0,-28} [{1}]" -f $agent, $status)
    }

    if ($InstallTarget.AgentSupport -ne "native") {
        Write-Host ""
        Write-WarnLine "$($InstallTarget.HarnessLabel) has no confirmed native subagent install target in this repo. Direct installer runs will not copy agent files."
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

function Read-IncludeAgentsChoice {
    while ($true) {
        Write-Host ""
        Write-Host "Install subagents too?"
        Write-Host "  y. Yes"
        Write-Host "  n. No"
        Write-Host "  b. Back"
        Write-Host "  q. Quit"
        Write-Host ""

        $choice = Read-Host "Subagents [n]"
        if ([string]::IsNullOrWhiteSpace($choice)) {
            return $false
        }

        if ($choice -match "^(?i:y|yes)$") {
            return $true
        }

        if ($choice -match "^(?i:n|no)$") {
            return $false
        }

        if ($choice -match "^(?i:b|back)$") {
            return $script:BackToken
        }

        if ($choice -match "^(?i:q|quit)$") {
            return $null
        }

        Write-ErrorLine "Invalid subagent choice."
    }
}

function Resolve-SkillOverwrite {
    param(
        [string[]]$SelectedSkills,
        [pscustomobject]$Selection,
        [pscustomobject]$InstallTarget
    )

    Show-SelectedSkillStatus -SelectedSkills $SelectedSkills -InstallTarget $InstallTarget

    $alreadyInstalled = @($SelectedSkills | Where-Object {
        Test-Path -LiteralPath (Join-Path $InstallTarget.TargetPath $_) -PathType Container
    })

    if ($alreadyInstalled.Count -eq 0) {
        return [pscustomobject]@{
            SelectedSkills = $SelectedSkills
            Selection = $Selection
            Force = $false
        }
    }

    while ($true) {
        Write-Host ""
        Write-WarnLine "These selected skills are already installed in the target:"
        Write-Host "  $($alreadyInstalled -join ', ')"
        Write-Host ""
        Write-Host "  y. Overwrite already installed selected skills"
        Write-Host "  n. Skip already installed selected skills"
        Write-Host "  b. Back"
        Write-Host "  q. Quit"
        Write-Host ""

        $overwrite = Read-Host "Overwrite skills? [n]"
        if ([string]::IsNullOrWhiteSpace($overwrite)) {
            $overwrite = "n"
        }

        if ($overwrite -match "^(?i:q|quit)$") {
            return $null
        }

        if ($overwrite -match "^(?i:b|back)$") {
            return $script:BackToken
        }

        if ($overwrite -match "^(?i:y|yes)$") {
            return [pscustomobject]@{
                SelectedSkills = $SelectedSkills
                Selection = $Selection
                Force = $true
            }
        }

        if ($overwrite -match "^(?i:n|no)$") {
            $remainingSkills = @($SelectedSkills | Where-Object { $alreadyInstalled -notcontains $_ })
            if ($remainingSkills.Count -eq 0) {
                Write-WarnLine "No new selected skills remain after skipping installed skills. Choose Back to change selection or Quit to cancel."
                continue
            }

            return [pscustomobject]@{
                SelectedSkills = $remainingSkills
                Selection = [pscustomobject]@{
                    Mode = "skills"
                    Bundle = $null
                    Skills = $remainingSkills
                }
                Force = $false
            }
        }

        Write-ErrorLine "Invalid overwrite choice."
    }
}

function Resolve-AgentOverwrite {
    param(
        [pscustomobject]$AgentSelection,
        [pscustomobject]$InstallTarget
    )

    if (-not $AgentSelection.IncludeAgents) {
        return [pscustomobject]@{
            AgentSelection = $AgentSelection
            Force = $false
        }
    }

    Show-SelectedAgentStatus -SelectedAgents $AgentSelection.Agents -AgentTargetPath $AgentSelection.AgentTargetPath -InstallTarget $InstallTarget

    $alreadyInstalledAgents = @()
    if (-not [string]::IsNullOrWhiteSpace($AgentSelection.AgentTargetPath)) {
        $alreadyInstalledAgents = @($AgentSelection.Agents | Where-Object {
            Test-Path -LiteralPath (Join-Path $AgentSelection.AgentTargetPath "$_.md") -PathType Leaf
        })
    }

    if ($alreadyInstalledAgents.Count -eq 0) {
        return [pscustomobject]@{
            AgentSelection = $AgentSelection
            Force = $false
        }
    }

    while ($true) {
        Write-Host ""
        Write-WarnLine "These selected subagents are already installed in the target:"
        Write-Host "  $($alreadyInstalledAgents -join ', ')"
        Write-Host ""
        Write-Host "  y. Overwrite already installed selected subagents"
        Write-Host "  n. Skip already installed selected subagents"
        Write-Host "  b. Back"
        Write-Host "  q. Quit"
        Write-Host ""

        $overwriteAgents = Read-Host "Overwrite subagents? [n]"
        if ([string]::IsNullOrWhiteSpace($overwriteAgents)) {
            $overwriteAgents = "n"
        }

        if ($overwriteAgents -match "^(?i:q|quit)$") {
            return $null
        }

        if ($overwriteAgents -match "^(?i:b|back)$") {
            return $script:BackToken
        }

        if ($overwriteAgents -match "^(?i:y|yes)$") {
            return [pscustomobject]@{
                AgentSelection = $AgentSelection
                Force = $true
            }
        }

        if ($overwriteAgents -match "^(?i:n|no)$") {
            $remainingAgents = @($AgentSelection.Agents | Where-Object { $alreadyInstalledAgents -notcontains $_ })
            if ($remainingAgents.Count -eq 0) {
                Write-WarnLine "No new selected subagents remain after skipping installed subagents. Choose Back to change selection or continue without subagents."
                return [pscustomobject]@{
                    AgentSelection = [pscustomobject]@{
                        IncludeAgents = $false
                        Mode = "none"
                        Bundle = $null
                        Agents = @()
                        AgentTargetPath = $AgentSelection.AgentTargetPath
                    }
                    Force = $false
                }
            }

            return [pscustomobject]@{
                AgentSelection = [pscustomobject]@{
                    IncludeAgents = $true
                    Mode = "agents"
                    Bundle = $null
                    Agents = $remainingAgents
                    AgentTargetPath = $AgentSelection.AgentTargetPath
                }
                Force = $false
            }
        }

        Write-ErrorLine "Invalid overwrite choice."
    }
}

function Confirm-FinalInstall {
    param(
        [pscustomobject]$InstallTarget,
        [pscustomobject]$Selection,
        [string[]]$SelectedSkills,
        [pscustomobject]$AgentSelection,
        [bool]$Force
    )

    while ($true) {
        Write-Host ""
        Write-Host "Review install choices:"
        Write-Host ""
        Write-Host "Harness:"
        Write-Host "  $($InstallTarget.HarnessLabel)"
        Write-Host "Scope:"
        Write-Host "  $($InstallTarget.Scope)"
        Write-Host "Skill target:"
        Write-Host "  $($InstallTarget.TargetPath)"
        Write-Host "Skills:"
        if ($Selection.Mode -eq "bundle") {
            Write-Host "  bundle: $($Selection.Bundle)"
        } elseif ($Selection.Mode -eq "all") {
            Write-Host "  all skills"
        } else {
            Write-Host "  $($SelectedSkills -join ', ')"
        }

        if ($AgentSelection.IncludeAgents) {
            Write-Host "Subagents:"
            if ($AgentSelection.Bundle) {
                Write-Host "  agent bundle: $($AgentSelection.Bundle)"
            } else {
                Write-Host "  agents: $($AgentSelection.Agents -join ', ')"
            }
            if ($AgentSelection.AgentTargetPath) {
                Write-Host "Agent target:"
                Write-Host "  $($AgentSelection.AgentTargetPath)"
            }
        } else {
            Write-Host "Subagents:"
            Write-Host "  skipped"
        }

        if ($Force) {
            Write-WarnLine "Overwrite mode enabled."
        }

        Write-Host ""
        Write-Host "  y. Install"
        Write-Host "  b. Back"
        Write-Host "  q. Quit"
        Write-Host ""

        $choice = Read-Host "Proceed? [y]"
        if ([string]::IsNullOrWhiteSpace($choice)) {
            return $true
        }

        if ($choice -match "^(?i:y|yes)$") {
            return $true
        }

        if ($choice -match "^(?i:b|back)$") {
            return $script:BackToken
        }

        if ($choice -match "^(?i:q|quit)$") {
            return $null
        }

        Write-ErrorLine "Invalid final review choice."
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
    $agentBundles = Get-AgentBundles -RepoRoot $repoRoot
    $agents = Get-Agents -RepoRoot $repoRoot

    $profile = $null
    $installTarget = $null
    $selection = $null
    $selectedSkills = @()
    $agentSelection = New-DefaultAgentSelection
    $skillForce = $false
    $agentForce = $false
    $force = $false
    $agentTargetPath = $null
    $step = "harness"
    $finalBackStep = "include-agents"

    while ($true) {
        switch ($step) {
            "harness" {
                $profile = Select-Harness -Profiles $profiles
                if ($null -eq $profile) {
                    Write-Info "Cancelled."
                    exit 1
                }

                $installTarget = $null
                $selection = $null
                $selectedSkills = @()
                $agentSelection = New-DefaultAgentSelection
                $skillForce = $false
                $agentForce = $false
                $force = $false
                $agentTargetPath = $null
                $step = "target"
            }
            "target" {
                $targetResult = Select-InstallTarget -Profile $profile
                if (Test-IsBack $targetResult) {
                    $step = "harness"
                    continue
                }
                if ($null -eq $targetResult) {
                    Write-Info "Cancelled."
                    exit 1
                }

                $installTarget = $targetResult
                $selection = $null
                $selectedSkills = @()
                $agentSelection = New-DefaultAgentSelection
                $skillForce = $false
                $agentForce = $false
                $force = $false
                $agentTargetPath = $null
                $step = "package"
            }
            "package" {
                $packageResult = Select-InstallPackage -Skills $skills -Bundles $bundles -InstallTarget $installTarget -RepoRoot $repoRoot
                if (Test-IsBack $packageResult) {
                    $step = "target"
                    continue
                }
                if ($null -eq $packageResult) {
                    Write-Info "Cancelled."
                    exit 1
                }

                $selection = $packageResult
                $selectedSkills = @($selection.Skills)
                $agentSelection = New-DefaultAgentSelection
                $skillForce = $false
                $agentForce = $false
                $force = $false
                $agentTargetPath = $null
                $step = "skill-overwrite"
            }
            "skill-overwrite" {
                $overwriteResult = Resolve-SkillOverwrite -SelectedSkills $selectedSkills -Selection $selection -InstallTarget $installTarget
                if (Test-IsBack $overwriteResult) {
                    $step = "package"
                    continue
                }
                if ($null -eq $overwriteResult) {
                    Write-Info "Cancelled."
                    exit 1
                }

                $selectedSkills = @($overwriteResult.SelectedSkills)
                $selection = $overwriteResult.Selection
                $skillForce = [bool]$overwriteResult.Force
                $agentSelection = New-DefaultAgentSelection
                $agentForce = $false
                $force = $skillForce
                $agentTargetPath = $null
                $step = "include-agents"
            }
            "include-agents" {
                $includeAgentsChoice = Read-IncludeAgentsChoice
                if (Test-IsBack $includeAgentsChoice) {
                    $step = "skill-overwrite"
                    continue
                }
                if ($null -eq $includeAgentsChoice) {
                    Write-Info "Cancelled."
                    exit 1
                }

                if (-not $includeAgentsChoice) {
                    $agentSelection = New-DefaultAgentSelection
                    $agentForce = $false
                    $force = $skillForce
                    $finalBackStep = "include-agents"
                    $step = "final-review"
                    continue
                }

                $agentTargetPath = Resolve-InteractiveAgentTarget -InstallTarget $installTarget
                if (Test-IsBack $agentTargetPath) {
                    continue
                }
                $step = "agent-package"
            }
            "agent-package" {
                $agentPackageResult = Select-AgentPackage -Agents $agents -AgentBundles $agentBundles -SkillSelection $selection -InstallTarget $installTarget -RepoRoot $repoRoot -AgentTargetPath $agentTargetPath
                if (Test-IsBack $agentPackageResult) {
                    $step = "include-agents"
                    continue
                }
                if ($null -eq $agentPackageResult) {
                    Write-Info "Cancelled."
                    exit 1
                }

                $agentSelection = $agentPackageResult
                $agentForce = $false
                $force = $skillForce
                if ($agentSelection.IncludeAgents) {
                    $step = "agent-overwrite"
                } else {
                    $finalBackStep = "agent-package"
                    $step = "final-review"
                }
            }
            "agent-overwrite" {
                $agentOverwriteResult = Resolve-AgentOverwrite -AgentSelection $agentSelection -InstallTarget $installTarget
                if (Test-IsBack $agentOverwriteResult) {
                    $step = "agent-package"
                    continue
                }
                if ($null -eq $agentOverwriteResult) {
                    Write-Info "Cancelled."
                    exit 1
                }

                $agentSelection = $agentOverwriteResult.AgentSelection
                $agentForce = [bool]$agentOverwriteResult.Force
                $force = ($skillForce -or $agentForce)
                $finalBackStep = "agent-overwrite"
                $step = "final-review"
            }
            "final-review" {
                $confirmResult = Confirm-FinalInstall -InstallTarget $installTarget -Selection $selection -SelectedSkills $selectedSkills -AgentSelection $agentSelection -Force $force
                if (Test-IsBack $confirmResult) {
                    $step = $finalBackStep
                    continue
                }
                if ($null -eq $confirmResult) {
                    Write-Info "Cancelled."
                    exit 1
                }

                $step = "install"
            }
            default {
                throw "Unknown installer step: $step"
            }
        }

        if ($step -eq "install") {
            break
        }
    }

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

    if ($agentSelection.IncludeAgents) {
        $arguments += "-IncludeAgents"
        if ($agentSelection.Bundle) {
            $arguments += @("-AgentBundle", $agentSelection.Bundle)
        } else {
            $arguments += @("-Agents", ($agentSelection.Agents -join ","))
        }
        if ($agentSelection.AgentTargetPath) {
            $arguments += @("-AgentTargetPath", $agentSelection.AgentTargetPath)
        }
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
