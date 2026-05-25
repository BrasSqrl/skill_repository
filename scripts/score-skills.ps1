<#
.SYNOPSIS
Score skill quality signals.

.DESCRIPTION
Produces an advisory score for each skill based on description specificity,
trigger clarity, required sections, quality gates, output format, reference
hygiene, catalog metadata completeness, and third-party license traceability.

.EXAMPLES
.\scripts\score-skills.ps1
#>

[CmdletBinding()]
param(
    [string]$SkillsPath
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

$repoRoot = Get-RepoRoot
if (-not $SkillsPath) {
    $SkillsPath = Join-Path $repoRoot "skills"
}

$deprecatedLicensePlaceholder = "repo" + "-tbd"

if (-not (Test-Path -LiteralPath $SkillsPath -PathType Container)) {
    Write-Host "[ERROR] Skills directory not found: $SkillsPath" -ForegroundColor Red
    exit 1
}

$catalogPath = Join-Path $repoRoot "catalog\skills.tsv"
$catalogByName = @{}
if (Test-Path -LiteralPath $catalogPath -PathType Leaf) {
    foreach ($row in @(Import-Csv -LiteralPath $catalogPath -Delimiter "`t")) {
        if (-not [string]::IsNullOrWhiteSpace($row.name)) {
            $catalogByName[$row.name] = $row
        }
    }
}

$noticesPath = Join-Path $repoRoot "THIRD_PARTY_NOTICES.md"
$noticesContent = if (Test-Path -LiteralPath $noticesPath -PathType Leaf) {
    Get-Content -Raw -LiteralPath $noticesPath
} else {
    ""
}

$requiredSections = @(
    "Purpose",
    "When to Use",
    "When Not to Use",
    "Required Inputs",
    "Workflow",
    "Quality Gates",
    "Anti-Patterns",
    "Output Format",
    "References"
)

$results = New-Object System.Collections.Generic.List[object]

foreach ($skillDir in @(Get-ChildItem -LiteralPath $SkillsPath -Directory | Sort-Object Name)) {
    $score = 0
    $notes = New-Object System.Collections.Generic.List[string]
    $skillFile = Join-Path $skillDir.FullName "SKILL.md"

    if (-not (Test-Path -LiteralPath $skillFile -PathType Leaf)) {
        $results.Add([pscustomobject]@{ Skill = $skillDir.Name; Score = 0; Notes = "missing SKILL.md" })
        continue
    }

    $content = Get-Content -Raw -LiteralPath $skillFile
    $frontmatterMatch = [regex]::Match($content, "(?s)\A---\s*\r?\n(.*?)\r?\n---\s*(\r?\n|$)")
    if ($frontmatterMatch.Success) {
        $score += 10
        $description = Get-FrontmatterValue -Frontmatter $frontmatterMatch.Groups[1].Value -Key "description"
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
                $notes.Add("weak trigger in description")
            }
        } else {
            $notes.Add("missing description")
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
    $score += [Math]::Min(25, $sectionScore)

    if ($content -match "(?ms)^## Quality Gates\s+.*\S") {
        $score += 10
    } else {
        $notes.Add("weak quality gates")
    }

    if ($content -match "(?ms)^## Output Format\s+.*\S") {
        $score += 10
    } else {
        $notes.Add("weak output format")
    }

    $referencesDir = Join-Path $skillDir.FullName "references"
    if (Test-Path -LiteralPath $referencesDir -PathType Container) {
        if ($content -match "references/") {
            $score += 8
        } else {
            $notes.Add("references folder not linked")
        }
    } else {
        $score += 6
    }

    if ($catalogByName.ContainsKey($skillDir.Name)) {
        $catalogEntry = $catalogByName[$skillDir.Name]
        $requiredMetadata = @("category", "maturity", "source", "license", "harnesses", "import_mode", "description")
        $completeMetadata = $true
        foreach ($field in $requiredMetadata) {
            if ([string]::IsNullOrWhiteSpace($catalogEntry.$field)) {
                $completeMetadata = $false
                $notes.Add("missing catalog $field")
            }
        }
        if ($completeMetadata) {
            $score += 10
        }

        if ($catalogEntry.source -eq "third-party") {
            if ($catalogEntry.license -and $catalogEntry.license -ne $deprecatedLicensePlaceholder -and
                (Test-Path -LiteralPath (Join-Path $skillDir.FullName "LICENSE") -PathType Leaf) -and
                $noticesContent -match [regex]::Escape($skillDir.Name)) {
                $score += 7
            } else {
                $notes.Add("third-party traceability gap")
            }
        } else {
            $score += 7
        }
    } else {
        $notes.Add("missing catalog entry")
    }

    $results.Add([pscustomobject]@{
        Skill = $skillDir.Name
        Score = [Math]::Min(100, $score)
        Notes = if ($notes.Count -gt 0) { $notes -join "; " } else { "ok" }
    })
}

$results | Sort-Object Score, Skill | Format-Table Skill, Score, Notes -Wrap

$average = if ($results.Count -gt 0) {
    [Math]::Round((($results | Measure-Object -Property Score -Average).Average), 1)
} else {
    0
}

Write-Host ""
Write-Host "Skill quality scoring summary:"
Write-Host "  Skills:  $($results.Count)"
Write-Host "  Average: $average"
Write-Host "  Below 80: $(@($results | Where-Object { $_.Score -lt 80 }).Count)"
Write-Host ""
Write-Host "Scores are advisory. Run validate-skills before publishing."

exit 0
