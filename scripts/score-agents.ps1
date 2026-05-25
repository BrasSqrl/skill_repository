<#
.SYNOPSIS
Score canonical subagent definition quality signals.

.DESCRIPTION
Produces advisory scores for agents based on frontmatter, trigger clarity,
required sections, referenced skills, catalog metadata, and permission
boundaries. Validation remains the blocking check.

.EXAMPLES
.\scripts\score-agents.ps1
#>

[CmdletBinding()]
param(
    [string]$AgentsPath
)

$ErrorActionPreference = "Stop"

function Get-RepoRoot {
    if ($PSScriptRoot) {
        return (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
    }

    return (Get-Location).Path
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

function Normalize-List {
    param([string]$Value)

    if ([string]::IsNullOrWhiteSpace($Value)) {
        return @()
    }

    return @($Value -split "," | ForEach-Object { $_.Trim() } | Where-Object { $_ } | Select-Object -Unique)
}

$repoRoot = Get-RepoRoot
if (-not $AgentsPath) {
    $AgentsPath = Join-Path $repoRoot "agents"
}

if (-not (Test-Path -LiteralPath $AgentsPath -PathType Container)) {
    Write-Host "[ERROR] Agents directory not found: $AgentsPath" -ForegroundColor Red
    exit 1
}

$catalogPath = Join-Path $repoRoot "catalog\agents.tsv"
$catalogByName = @{}
if (Test-Path -LiteralPath $catalogPath -PathType Leaf) {
    foreach ($row in @(Import-Csv -LiteralPath $catalogPath -Delimiter "`t")) {
        if (-not [string]::IsNullOrWhiteSpace($row.name)) {
            $catalogByName[$row.name] = $row
        }
    }
}

$skills = New-Object System.Collections.Generic.HashSet[string]
foreach ($skillDir in @(Get-ChildItem -LiteralPath (Join-Path $repoRoot "skills") -Directory)) {
    [void]$skills.Add($skillDir.Name)
}

$requiredSections = @(
    "Use When",
    "Do Not Use When",
    "Required Inputs",
    "Workflow",
    "Allowed Actions",
    "Forbidden Actions",
    "Output Format",
    "Escalation Rules"
)

$results = New-Object System.Collections.Generic.List[object]

foreach ($agentFile in @(Get-ChildItem -LiteralPath $AgentsPath -Filter "*.md" -File | Sort-Object Name)) {
    $agentName = [System.IO.Path]::GetFileNameWithoutExtension($agentFile.Name)
    $score = 0
    $notes = New-Object System.Collections.Generic.List[string]
    $content = Get-Content -Raw -LiteralPath $agentFile.FullName
    $frontmatterMatch = [regex]::Match($content, "(?s)\A---\s*\r?\n(.*?)\r?\n---\s*(\r?\n|$)")

    if ($frontmatterMatch.Success) {
        $score += 10
        $frontmatter = $frontmatterMatch.Groups[1].Value
        $name = Get-FrontmatterValue -Frontmatter $frontmatter -Key "name"
        $description = Get-FrontmatterValue -Frontmatter $frontmatter -Key "description"
        $permission = Get-FrontmatterValue -Frontmatter $frontmatter -Key "permission"
        $agentSkills = Normalize-List -Value (Get-FrontmatterValue -Frontmatter $frontmatter -Key "skills")

        if ($name -eq $agentName) {
            $score += 8
        } else {
            $notes.Add("name mismatch")
        }

        if (-not [string]::IsNullOrWhiteSpace($description)) {
            if ($description.Length -ge 120) {
                $score += 12
            } elseif ($description.Length -ge 80) {
                $score += 8
            } else {
                $score += 4
                $notes.Add("short description")
            }

            if ($description -match "\bUse (when|before|for|at)\b") {
                $score += 8
            } else {
                $notes.Add("weak trigger")
            }
        } else {
            $notes.Add("missing description")
        }

        if ($permission -in @("read-only", "validation-only")) {
            $score += 8
        } else {
            $notes.Add("unclear permission")
        }

        $missingSkills = @($agentSkills | Where-Object { -not $skills.Contains($_) })
        if ($missingSkills.Count -eq 0 -and $agentSkills.Count -gt 0) {
            $score += 10
        } else {
            $notes.Add("missing referenced skill")
        }
    } else {
        $notes.Add("missing frontmatter")
    }

    $sectionScore = 0
    foreach ($section in $requiredSections) {
        if ($content -match "(?m)^## $([regex]::Escape($section))\s*$") {
            $sectionScore += 3
        } else {
            $notes.Add("missing $section")
        }
    }
    $score += [Math]::Min(24, $sectionScore)

    if ($content -match "Do not edit files|Do not edit") {
        $score += 8
    } else {
        $notes.Add("weak forbidden actions")
    }

    if ($content -match "(?ms)^## Output Format\s+.*Subagent Result") {
        $score += 8
    } else {
        $notes.Add("weak output format")
    }

    if ($catalogByName.ContainsKey($agentName)) {
        $score += 12
    } else {
        $notes.Add("missing catalog entry")
    }

    $results.Add([pscustomobject]@{
        Agent = $agentName
        Score = [Math]::Min(100, $score)
        Notes = if ($notes.Count -gt 0) { $notes -join "; " } else { "ok" }
    })
}

$results | Sort-Object Score, Agent | Format-Table Agent, Score, Notes -Wrap

$average = if ($results.Count -gt 0) {
    [Math]::Round((($results | Measure-Object -Property Score -Average).Average), 1)
} else {
    0
}

Write-Host ""
Write-Host "Agent quality scoring summary:"
Write-Host "  Agents:  $($results.Count)"
Write-Host "  Average: $average"
Write-Host "  Below 80: $(@($results | Where-Object { $_.Score -lt 80 }).Count)"
Write-Host ""
Write-Host "Scores are advisory. Run validate-skills before publishing."

exit 0
