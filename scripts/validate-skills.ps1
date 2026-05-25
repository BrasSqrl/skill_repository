<#
.SYNOPSIS
Validate OpenAI-style skill folders.

.DESCRIPTION
Checks each folder under ./skills for a SKILL.md file, required YAML
frontmatter, useful descriptions, required operational sections, allowed
resource folders, and linked reference files.

.EXAMPLES
.\scripts\validate-skills.ps1

.\scripts\validate-skills.ps1 -SkillsPath ".\skills"
#>

[CmdletBinding()]
param(
    [string]$SkillsPath
)

$ErrorActionPreference = "Stop"

function Write-Info {
    param([string]$Message)
    Write-Host "[INFO] $Message"
}

function Write-Pass {
    param([string]$Message)
    Write-Host "[PASS] $Message"
}

function Write-Fail {
    param([string]$Message)
    Write-Host "[FAIL] $Message" -ForegroundColor Red
}

function Write-Warn {
    param([string]$Message)
    Write-Host "[WARN] $Message" -ForegroundColor Yellow
}

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

if (-not (Test-Path -LiteralPath $SkillsPath -PathType Container)) {
    Write-Fail "Skills directory not found: $SkillsPath"
    exit 1
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

$allowedResourceFolders = @(
    "references",
    "scripts",
    "assets",
    "agents"
)

$skillDirs = @(Get-ChildItem -LiteralPath $SkillsPath -Directory | Sort-Object Name)
if ($skillDirs.Count -eq 0) {
    Write-Fail "No skill folders found under: $SkillsPath"
    exit 1
}

$passed = 0
$failed = 0
$warnings = 0

Write-Info "Validating $($skillDirs.Count) skill folder(s) in $SkillsPath"

foreach ($skillDir in $skillDirs) {
    $skillName = $skillDir.Name
    $skillFile = Join-Path $skillDir.FullName "SKILL.md"
    $skillFailed = $false

    if ($skillName -notmatch "^[a-z0-9]+(-[a-z0-9]+)*$") {
        Write-Fail "${skillName}: folder name must use lowercase kebab-case"
        $skillFailed = $true
    }

    if (-not (Test-Path -LiteralPath $skillFile -PathType Leaf)) {
        Write-Fail "${skillName}: missing SKILL.md"
        $failed++
        continue
    }

    $content = Get-Content -Raw -LiteralPath $skillFile
    $frontmatterMatch = [regex]::Match($content, "(?s)\A---\s*\r?\n(.*?)\r?\n---\s*(\r?\n|$)")

    if (-not $frontmatterMatch.Success) {
        Write-Fail "${skillName}: missing or invalid YAML frontmatter"
        $failed++
        continue
    }

    $frontmatter = $frontmatterMatch.Groups[1].Value
    $name = Get-FrontmatterValue -Frontmatter $frontmatter -Key "name"
    $description = Get-FrontmatterValue -Frontmatter $frontmatter -Key "description"

    if ([string]::IsNullOrWhiteSpace($name)) {
        Write-Fail "${skillName}: frontmatter is missing name"
        $skillFailed = $true
    } elseif ($name -ne $skillName) {
        Write-Warn "${skillName}: frontmatter name '$name' does not match folder name"
        $warnings++
    }

    if ([string]::IsNullOrWhiteSpace($description)) {
        Write-Fail "${skillName}: frontmatter description is empty or missing"
        $skillFailed = $true
    } else {
        if ($description.Trim().Length -lt 80) {
            Write-Fail "${skillName}: description is too short to be useful; use at least 80 characters"
            $skillFailed = $true
        }

        if ($description -notmatch "\bUse (when|before|for|at)\b") {
            Write-Fail "${skillName}: description must include specific trigger language such as 'Use when', 'Use before', or 'Use for'"
            $skillFailed = $true
        }
    }

    foreach ($section in $requiredSections) {
        $sectionPattern = "(?m)^## $([regex]::Escape($section))\s*$"
        if ($content -notmatch $sectionPattern) {
            Write-Fail "${skillName}: missing required section '## $section'"
            $skillFailed = $true
        }
    }

    $childDirs = @(Get-ChildItem -LiteralPath $skillDir.FullName -Directory)
    foreach ($childDir in $childDirs) {
        if ($allowedResourceFolders -notcontains $childDir.Name) {
            Write-Fail "${skillName}: unexpected resource folder '$($childDir.Name)'"
            $skillFailed = $true
        }
    }

    $referencesDir = Join-Path $skillDir.FullName "references"
    if ((Test-Path -LiteralPath $referencesDir -PathType Container) -and $content -notmatch "references/") {
        Write-Fail "${skillName}: references folder exists but SKILL.md does not link to it"
        $skillFailed = $true
    }

    $referenceMatches = @()
    $referenceMatches += [regex]::Matches($content, '`(references/[^`]+)`')
    $referenceMatches += [regex]::Matches($content, '\[[^\]]+\]\((references/[^)]+)\)')

    foreach ($referenceMatch in $referenceMatches) {
        $referencePath = if ($referenceMatch.Groups.Count -gt 1) {
            $referenceMatch.Groups[1].Value
        } else {
            $referenceMatch.Value.Trim('`')
        }

        $referencePath = ($referencePath -split "#")[0]
        if ([string]::IsNullOrWhiteSpace($referencePath)) {
            continue
        }

        $localReferencePath = Join-Path $skillDir.FullName ($referencePath -replace "/", [System.IO.Path]::DirectorySeparatorChar)
        if (-not (Test-Path -LiteralPath $localReferencePath -PathType Leaf)) {
            Write-Fail "${skillName}: missing linked reference '$referencePath'"
            $skillFailed = $true
        }
    }

    if ($skillFailed) {
        $failed++
    } else {
        Write-Pass "$skillName"
        $passed++
    }
}

Write-Host ""
Write-Host "Validation summary:"
Write-Host "  Passed:   $passed"
Write-Host "  Failed:   $failed"
Write-Host "  Warnings: $warnings"

if ($failed -gt 0) {
    exit 1
}

exit 0
