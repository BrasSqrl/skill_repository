<#
.SYNOPSIS
Install skill folders and optional subagent definitions into harness targets.

.DESCRIPTION
Copies selected folders from ./skills into a harness-specific skills directory.
When -IncludeAgents is provided, renders canonical ./agents/*.md definitions
for the selected harness. Claude Code and OpenCode receive native markdown
agent files. Codex is guidance-only until a native subagent file format is
confirmed.

.EXAMPLES
.\scripts\install-skills.ps1 -Harness codex -Bundle starter

.\scripts\install-skills.ps1 -Harness claude-code -Bundle starter -IncludeAgents

.\scripts\install-skills.ps1 -Harness opencode -Bundle security -IncludeAgents -AgentBundle security-review

.\scripts\install-skills.ps1 -Harness claude-code -Skills context-engineering,test-driven-development

.\scripts\install-skills.ps1 -ListBundles

.\scripts\install-skills.ps1 -ListAgents
#>

[CmdletBinding()]
param(
    [string]$TargetPath,

    [string]$AgentTargetPath,

    [ValidateSet("codex", "claude-code", "opencode")]
    [string]$Harness,

    [ValidateSet("global", "project", "custom")]
    [string]$Scope = "global",

    [string]$ProjectPath,

    [string[]]$Skills,

    [string]$Bundle,

    [switch]$All,

    [switch]$IncludeAgents,

    [string[]]$Agents,

    [string]$AgentBundle,

    [switch]$ListBundles,

    [switch]$ListSkills,

    [switch]$ListAgents,

    [switch]$ListAgentBundles,

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

function Resolve-AgentTargetPath {
    param([hashtable]$Profile)

    if ($Profile["agent_support"] -ne "native") {
        return $null
    }

    if (-not [string]::IsNullOrWhiteSpace($AgentTargetPath)) {
        return [System.IO.Path]::GetFullPath($AgentTargetPath)
    }

    switch ($Scope) {
        "global" {
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
        "project" {
            if ($Profile["supports_agent_project_default"] -ne "true") {
                throw "$($Profile["label"]) project scope has no native agent target."
            }
            if ([string]::IsNullOrWhiteSpace($ProjectPath)) {
                throw "Agent project scope requires -ProjectPath unless -AgentTargetPath is provided."
            }
            return [System.IO.Path]::GetFullPath((Join-PortablePath -BasePath $ProjectPath -RelativePath $Profile["agent_project_subpath"]))
        }
        "custom" {
            throw "Custom scope with -IncludeAgents requires -AgentTargetPath for native agent harnesses."
        }
        default {
            throw "Unsupported scope: $Scope"
        }
    }
}

function Normalize-NameList {
    param([string[]]$RawNames)

    $normalized = @()
    foreach ($item in $RawNames) {
        if ([string]::IsNullOrWhiteSpace($item)) {
            continue
        }

        foreach ($part in ($item -split ",")) {
            $name = $part.Trim()
            if ($name) {
                $normalized += $name
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

function Get-AgentBundleAgents {
    param(
        [string]$RepoRoot,
        [string]$BundleName
    )

    if ($BundleName -notmatch "^[a-z0-9]+(-[a-z0-9]+)*$") {
        throw "Invalid agent bundle name '$BundleName'. Agent bundle names must use lowercase kebab-case."
    }

    $bundlePath = Join-Path $RepoRoot "catalog\agent-bundles\$BundleName.txt"
    if (-not (Test-Path -LiteralPath $bundlePath -PathType Leaf)) {
        throw "Agent bundle not found: $BundleName"
    }

    return @(Get-Content -LiteralPath $bundlePath |
        ForEach-Object { $_.Trim() } |
        Where-Object { -not [string]::IsNullOrWhiteSpace($_) -and -not $_.StartsWith("#") } |
        Select-Object -Unique)
}

function Get-DefaultAgentBundle {
    param(
        [string]$SkillSelectionMode,
        [string]$SkillBundle
    )

    if ($SkillSelectionMode -eq "bundle") {
        switch ($SkillBundle) {
            { $_ -in @("starter", "backend", "frontend", "quality") } { return "starter-review" }
            "security" { return "security-review" }
            "delivery" { return "delivery-review" }
            { $_ -in @("agent-orchestration", "all-software-dev") } { return "all-agents" }
            default { return "starter-review" }
        }
    }

    return "starter-review"
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

function Get-FrontmatterValue {
    param(
        [string]$Frontmatter,
        [string]$Key
    )

    $pattern = "(?m)^$([regex]::Escape($Key)):\s*(.+?)\s*$"
    $match = [regex]::Match($Frontmatter, $pattern)
    if (-not $match.Success) {
        return $null
    }

    return $match.Groups[1].Value.Trim().Trim('"').Trim("'")
}

function Get-AgentDefinition {
    param([string]$Path)

    $content = Get-Content -Raw -LiteralPath $Path
    $frontmatterMatch = [regex]::Match($content, "(?s)\A---\s*\r?\n(.*?)\r?\n---\s*(\r?\n|$)")
    if (-not $frontmatterMatch.Success) {
        throw "Agent definition missing YAML frontmatter: $Path"
    }

    $frontmatter = $frontmatterMatch.Groups[1].Value
    $body = $content.Substring($frontmatterMatch.Length).TrimStart()

    return [pscustomobject]@{
        Name = Get-FrontmatterValue -Frontmatter $frontmatter -Key "name"
        Description = Get-FrontmatterValue -Frontmatter $frontmatter -Key "description"
        Skills = @(Normalize-NameList -RawNames @((Get-FrontmatterValue -Frontmatter $frontmatter -Key "skills")))
        Tools = Get-FrontmatterValue -Frontmatter $frontmatter -Key "tools"
        Permission = Get-FrontmatterValue -Frontmatter $frontmatter -Key "permission"
        Body = $body
    }
}

function Render-ClaudeAgent {
    param([pscustomobject]$Agent)

    $lines = New-Object System.Collections.Generic.List[string]
    $lines.Add("---")
    $lines.Add("name: $($Agent.Name)")
    $lines.Add("description: $($Agent.Description)")
    if (-not [string]::IsNullOrWhiteSpace($Agent.Tools)) {
        $lines.Add("tools: $($Agent.Tools)")
    }
    if ($Agent.Skills.Count -gt 0) {
        $lines.Add("skills:")
        foreach ($skill in $Agent.Skills) {
            $lines.Add("  - $skill")
        }
    }
    $lines.Add("---")
    $lines.Add("")
    $lines.Add($Agent.Body.Trim())
    return ($lines -join [Environment]::NewLine)
}

function Render-OpenCodeAgent {
    param([pscustomobject]$Agent)

    $lines = New-Object System.Collections.Generic.List[string]
    $lines.Add("---")
    $lines.Add("description: $($Agent.Description)")
    $lines.Add("mode: subagent")
    $lines.Add("permission:")
    $lines.Add("  edit: deny")
    $lines.Add("  bash:")
    $lines.Add('    "*": ask')
    $lines.Add('    "git status*": allow')
    $lines.Add('    "git diff*": allow')
    $lines.Add('    "git log*": allow')
    $lines.Add('    "rg *": allow')
    $lines.Add('    "grep *": allow')
    $lines.Add('    "ls *": allow')
    $lines.Add("---")
    $lines.Add("")
    $lines.Add($Agent.Body.Trim())
    return ($lines -join [Environment]::NewLine)
}

function Render-AgentForHarness {
    param(
        [pscustomobject]$Agent,
        [string]$AgentFormat
    )

    switch ($AgentFormat) {
        "claude-subagent" { return Render-ClaudeAgent -Agent $Agent }
        "opencode-agent" { return Render-OpenCodeAgent -Agent $Agent }
        default { throw "Unsupported native agent format: $AgentFormat" }
    }
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

function Show-AgentBundles {
    param([string]$RepoRoot)

    $agentBundleCatalog = Join-Path $RepoRoot "catalog\agent-bundles.tsv"
    if (-not (Test-Path -LiteralPath $agentBundleCatalog -PathType Leaf)) {
        throw "Agent bundle catalog not found: $agentBundleCatalog"
    }

    Import-Csv -LiteralPath $agentBundleCatalog -Delimiter "`t" |
        Sort-Object id |
        Format-Table id, label, recommendation -Wrap
}

function Show-Agents {
    param([string]$RepoRoot)

    $agentCatalog = Join-Path $RepoRoot "catalog\agents.tsv"
    if (-not (Test-Path -LiteralPath $agentCatalog -PathType Leaf)) {
        throw "Agent catalog not found: $agentCatalog"
    }

    Import-Csv -LiteralPath $agentCatalog -Delimiter "`t" |
        Sort-Object name |
        Format-Table name, maturity, permission, skills, description -Wrap
}

try {
    $repoRoot = Get-RepoRoot
    $sourcePath = Join-Path $repoRoot "skills"
    $agentSourcePath = Join-Path $repoRoot "agents"

    $listed = $false
    if ($ListBundles) {
        Show-Bundles -RepoRoot $repoRoot
        $listed = $true
    }
    if ($ListSkills) {
        Show-Skills -RepoRoot $repoRoot
        $listed = $true
    }
    if ($ListAgentBundles) {
        Show-AgentBundles -RepoRoot $repoRoot
        $listed = $true
    }
    if ($ListAgents) {
        Show-Agents -RepoRoot $repoRoot
        $listed = $true
    }
    if ($listed) {
        exit 0
    }

    if (($Agents -and $Agents.Count -gt 0) -or -not [string]::IsNullOrWhiteSpace($AgentBundle)) {
        if (-not $IncludeAgents) {
            throw "Agent selectors require -IncludeAgents."
        }
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

    $skillSelectionMode = "skills"
    if ($All) {
        $selectedSkills = @(Get-ChildItem -LiteralPath $sourcePath -Directory | Sort-Object Name | ForEach-Object { $_.Name })
        $skillSelectionMode = "all"
    } elseif (-not [string]::IsNullOrWhiteSpace($Bundle)) {
        $selectedSkills = Get-BundleSkills -RepoRoot $repoRoot -BundleName $Bundle
        $skillSelectionMode = "bundle"
    } else {
        $selectedSkills = Normalize-NameList -RawNames $Skills
        $skillSelectionMode = "skills"
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

    $profile = $null
    if (-not [string]::IsNullOrWhiteSpace($Harness)) {
        $profile = Get-HarnessProfile -RepoRoot $repoRoot -HarnessName $Harness
    }

    $selectedAgents = @()
    $resolvedAgentBundle = $null
    if ($IncludeAgents) {
        if ([string]::IsNullOrWhiteSpace($Harness)) {
            throw "-IncludeAgents requires -Harness so the agent format can be resolved."
        }
        if (-not (Test-Path -LiteralPath $agentSourcePath -PathType Container)) {
            throw "Source agents directory not found: $agentSourcePath"
        }

        if ($Agents -and $Agents.Count -gt 0 -and -not [string]::IsNullOrWhiteSpace($AgentBundle)) {
            throw "Specify only one agent selector: -Agents or -AgentBundle."
        }

        if (-not [string]::IsNullOrWhiteSpace($AgentBundle)) {
            $resolvedAgentBundle = $AgentBundle
            $selectedAgents = Get-AgentBundleAgents -RepoRoot $repoRoot -BundleName $resolvedAgentBundle
        } elseif ($Agents -and $Agents.Count -gt 0) {
            $selectedAgents = Normalize-NameList -RawNames $Agents
        } else {
            $resolvedAgentBundle = Get-DefaultAgentBundle -SkillSelectionMode $skillSelectionMode -SkillBundle $Bundle
            $selectedAgents = Get-AgentBundleAgents -RepoRoot $repoRoot -BundleName $resolvedAgentBundle
        }

        foreach ($agentName in $selectedAgents) {
            if ($agentName -notmatch "^[a-z0-9]+(-[a-z0-9]+)*$") {
                throw "Invalid agent name '$agentName'. Agent names must use lowercase kebab-case."
            }

            $agentPath = Join-Path $agentSourcePath "$agentName.md"
            if (-not (Test-Path -LiteralPath $agentPath -PathType Leaf)) {
                throw "Source agent not found: $agentName"
            }
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
        Write-Info "Dry run mode: no skill files will be copied."
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

    if ($IncludeAgents) {
        Write-Info "Selected agents: $($selectedAgents -join ', ')"
        if (-not [string]::IsNullOrWhiteSpace($resolvedAgentBundle)) {
            Write-Info "Agent bundle: $resolvedAgentBundle"
        }

        if ($profile["agent_support"] -ne "native") {
            Write-Info "$($profile["label"]) has no confirmed native subagent file target. No agent files will be copied; use bootstrap to write portable guidance docs."
        } else {
            $agentTargetFullPath = Resolve-AgentTargetPath -Profile $profile
            Write-Info "Agent target: $agentTargetFullPath"

            if (-not $DryRun -and -not (Test-Path -LiteralPath $agentTargetFullPath -PathType Container)) {
                New-Item -ItemType Directory -Path $agentTargetFullPath -Force | Out-Null
                Write-Info "Created agent target directory: $agentTargetFullPath"
            }

            $blockedAgents = @()
            foreach ($agentName in $selectedAgents) {
                $targetAgentPath = Join-Path $agentTargetFullPath "$agentName.md"
                if ((Test-Path -LiteralPath $targetAgentPath) -and -not $Force) {
                    $blockedAgents += $agentName
                }
            }

            if ($blockedAgents.Count -gt 0 -and $DryRun) {
                Write-Info "Dry run found existing target agent file(s) that would be skipped without -Force: $($blockedAgents -join ', ')"
            } elseif ($blockedAgents.Count -gt 0) {
                throw "Target already contains agent file(s): $($blockedAgents -join ', '). Re-run with -Force to overwrite."
            }

            foreach ($agentName in $selectedAgents) {
                $sourceAgentPath = Join-Path $agentSourcePath "$agentName.md"
                $targetAgentPath = Join-Path $agentTargetFullPath "$agentName.md"
                $agentDefinition = Get-AgentDefinition -Path $sourceAgentPath
                $renderedAgent = Render-AgentForHarness -Agent $agentDefinition -AgentFormat $profile["agent_format"]

                if ($DryRun) {
                    if ((Test-Path -LiteralPath $targetAgentPath) -and $Force) {
                        Write-Info "Would replace agent: $targetAgentPath"
                    } elseif (Test-Path -LiteralPath $targetAgentPath) {
                        Write-Info "Would skip existing agent '$agentName' at '$targetAgentPath'"
                        continue
                    }
                    Write-Info "Would render agent '$agentName' to '$targetAgentPath'"
                    continue
                }

                if ((Test-Path -LiteralPath $targetAgentPath) -and $Force) {
                    if (-not (Test-ChildPath -Parent $agentTargetFullPath -Child $targetAgentPath)) {
                        throw "Refusing to remove path outside agent target directory: $targetAgentPath"
                    }
                    Remove-Item -LiteralPath $targetAgentPath -Force
                    Write-Info "Removed existing agent: $targetAgentPath"
                }

                Set-Content -LiteralPath $targetAgentPath -Value $renderedAgent -Encoding UTF8
                Write-Success "Installed agent $agentName"
            }
        }
    }

    if ($DryRun) {
        Write-Success "Dry run completed successfully."
    } else {
        Write-Success "Installed $($selectedSkills.Count) skill(s) into $targetFullPath"
        if ($IncludeAgents -and $profile["agent_support"] -eq "native") {
            Write-Success "Installed $($selectedAgents.Count) agent(s)."
        }
    }

    exit 0
} catch {
    Write-Failure $_.Exception.Message
    exit 1
}
