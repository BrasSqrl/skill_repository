<#
.SYNOPSIS
Bootstrap a repository with agent skills and repository instructions.

.DESCRIPTION
Installs a selected skill bundle for Codex, Claude Code, or OpenCode, copies
the project AGENTS.md template when the target repo does not already have one,
and writes docs/agents/installed-skills.md with the installed bundle details.

.EXAMPLES
$TargetRepo = "<target-repo>"
.\scripts\bootstrap-agent-repo.ps1 -ProjectPath $TargetRepo -Harness claude-code -Bundle starter

.\scripts\bootstrap-agent-repo.ps1 -ProjectPath $TargetRepo -Harness codex -Scope global -Bundle starter -DryRun

$SkillTarget = "<target-skills-dir>"
.\scripts\bootstrap-agent-repo.ps1 -ProjectPath $TargetRepo -Harness opencode -Scope custom -TargetPath $SkillTarget -Bundle quality
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

    [string]$AgentTargetPath,

    [switch]$IncludeAgents,

    [string[]]$Agents,

    [string]$AgentBundle,

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

function Get-AgentBundleAgents {
    param(
        [string]$RepoRoot,
        [string]$BundleName
    )

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
    param([string]$SkillBundle)

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

function Resolve-SelectedAgents {
    param(
        [string]$RepoRoot,
        [string[]]$ExplicitAgents,
        [string]$ExplicitAgentBundle,
        [string]$SkillBundle
    )

    if ($ExplicitAgents -and $ExplicitAgents.Count -gt 0 -and -not [string]::IsNullOrWhiteSpace($ExplicitAgentBundle)) {
        throw "Specify only one agent selector: -Agents or -AgentBundle."
    }

    if (-not [string]::IsNullOrWhiteSpace($ExplicitAgentBundle)) {
        return [pscustomobject]@{
            Bundle = $ExplicitAgentBundle
            Agents = @(Get-AgentBundleAgents -RepoRoot $RepoRoot -BundleName $ExplicitAgentBundle)
        }
    }

    if ($ExplicitAgents -and $ExplicitAgents.Count -gt 0) {
        return [pscustomobject]@{
            Bundle = $null
            Agents = @(Normalize-NameList -RawNames $ExplicitAgents)
        }
    }

    $defaultBundle = Get-DefaultAgentBundle -SkillBundle $SkillBundle
    return [pscustomobject]@{
        Bundle = $defaultBundle
        Agents = @(Get-AgentBundleAgents -RepoRoot $RepoRoot -BundleName $defaultBundle)
    }
}

function Write-CodexAgentGuidance {
    param(
        [string]$RepoRoot,
        [string]$ProjectPath,
        [string[]]$SelectedAgents,
        [switch]$DryRun,
        [switch]$Force
    )

    $targetDir = Join-Path $ProjectPath "docs\agents"
    $guideSource = Join-Path $RepoRoot "docs\subagent-orchestration-guide.md"
    $guideTarget = Join-Path $targetDir "subagent-orchestration.md"
    $availableTarget = Join-Path $targetDir "available-subagents.md"
    $agentCatalog = Join-Path $RepoRoot "catalog\agents.tsv"

    if ($DryRun) {
        Write-Info "Dry run: would write Codex subagent guidance docs under $targetDir"
        return
    }

    if (-not (Test-Path -LiteralPath $targetDir -PathType Container)) {
        New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
    }

    if (Test-Path -LiteralPath $guideTarget -PathType Leaf) {
        if ($Force) {
            Copy-Item -LiteralPath $guideSource -Destination $guideTarget -Force
            Write-WarnLine "Replaced existing Codex subagent orchestration guide."
        } else {
            Write-Info "Preserved existing Codex subagent orchestration guide: $guideTarget"
        }
    } else {
        Copy-Item -LiteralPath $guideSource -Destination $guideTarget
        Write-Ok "Wrote Codex subagent orchestration guide: $guideTarget"
    }

    $catalogRows = @(Import-Csv -LiteralPath $agentCatalog -Delimiter "`t")
    $lines = @(
        "# Available Subagents",
        "",
        "Codex does not have a confirmed native subagent file target in this repository. Use these definitions as portable delegation guidance.",
        "",
        "## Installed Guidance Set",
        ""
    )

    foreach ($agentName in $SelectedAgents) {
        $row = $catalogRows | Where-Object { $_.name -eq $agentName } | Select-Object -First 1
        if ($row) {
            $lines += ("- ``{0}``: {1}" -f $row.name, $row.description)
        } else {
            $lines += ("- ``{0}``" -f $agentName)
        }
    }

    $lines += @(
        "",
        "## Invocation Pattern",
        "",
        "Ask the main agent to delegate using the named role, required inputs, forbidden actions, and expected output format from the source agent definition."
    )

    if ((Test-Path -LiteralPath $availableTarget -PathType Leaf) -and -not $Force) {
        Write-Info "Preserved existing available subagents doc: $availableTarget"
    } else {
        Set-Content -LiteralPath $availableTarget -Value $lines -Encoding UTF8
        Write-Ok "Wrote available subagents doc: $availableTarget"
    }
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
    $agentSelection = $null
    if ($IncludeAgents) {
        $agentSelection = Resolve-SelectedAgents -RepoRoot $repoRoot -ExplicitAgents $Agents -ExplicitAgentBundle $AgentBundle -SkillBundle $Bundle
    }

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
    if ($IncludeAgents) {
        Write-Info "Include agents: $($agentSelection.Agents -join ', ')"
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
    if ($AgentTargetPath) {
        $installerArgs["AgentTargetPath"] = $AgentTargetPath
    }
    if ($IncludeAgents) {
        $installerArgs["IncludeAgents"] = $true
        if ($AgentBundle) {
            $installerArgs["AgentBundle"] = $AgentBundle
        }
        if ($Agents -and $Agents.Count -gt 0) {
            $installerArgs["Agents"] = $Agents
        }
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
        if ($IncludeAgents -and $Harness -eq "codex") {
            Write-CodexAgentGuidance -RepoRoot $repoRoot -ProjectPath $projectFullPath -SelectedAgents $agentSelection.Agents -DryRun:$DryRun -Force:$Force
        }
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

    if ($IncludeAgents -and $Harness -eq "codex") {
        Write-CodexAgentGuidance -RepoRoot $repoRoot -ProjectPath $projectFullPath -SelectedAgents $agentSelection.Agents -Force:$Force
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

    if ($IncludeAgents) {
        $record += @(
            "",
            "## Agents",
            ""
        )
        foreach ($agent in $agentSelection.Agents) {
            $record += "- ``$agent``"
        }
        if ($agentSelection.Bundle) {
            $record += ""
            $record += "- Agent bundle: ``$($agentSelection.Bundle)``"
        }
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
