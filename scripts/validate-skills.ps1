<#
.SYNOPSIS
Validate OpenAI-style skill folders and repository metadata.

.DESCRIPTION
Checks each folder under ./skills for a valid SKILL.md file, validates catalog
metadata, bundle membership, harness profiles, reference links, and
third-party license traceability.

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

function Import-RequiredTsv {
    param(
        [string]$Path,
        [string[]]$RequiredColumns
    )

    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        throw "Required metadata file not found: $Path"
    }

    $rows = @(Import-Csv -LiteralPath $Path -Delimiter "`t")
    $columns = @()
    if ($rows.Count -gt 0) {
        $columns = @($rows[0].PSObject.Properties.Name)
    } else {
        $header = Get-Content -LiteralPath $Path -TotalCount 1
        $columns = @($header -split "`t")
    }

    foreach ($column in $RequiredColumns) {
        if ($columns -notcontains $column) {
            throw "Metadata file '$Path' is missing required column '$column'"
        }
    }

    return $rows
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

$requiredCatalogColumns = @(
    "name",
    "category",
    "maturity",
    "source",
    "license",
    "harnesses",
    "upstream_repo",
    "upstream_ref",
    "upstream_path",
    "import_mode",
    "description"
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

$catalogPath = Join-Path $repoRoot "catalog\skills.tsv"
$catalogRows = @()
$catalogByName = @{}

try {
    $catalogRows = Import-RequiredTsv -Path $catalogPath -RequiredColumns $requiredCatalogColumns
    foreach ($row in $catalogRows) {
        if ([string]::IsNullOrWhiteSpace($row.name)) {
            Write-Fail "catalog/skills.tsv: row with empty name"
            $failed++
            continue
        }

        if ($catalogByName.ContainsKey($row.name)) {
            Write-Fail "catalog/skills.tsv: duplicate skill entry '$($row.name)'"
            $failed++
            continue
        }

        $catalogByName[$row.name] = $row

        if ($row.name -notmatch "^[a-z0-9]+(-[a-z0-9]+)*$") {
            Write-Fail "catalog/skills.tsv: skill '$($row.name)' must use lowercase kebab-case"
            $failed++
        }

        foreach ($column in @("category", "maturity", "source", "license", "harnesses", "import_mode", "description")) {
            if ([string]::IsNullOrWhiteSpace($row.$column)) {
                Write-Fail "catalog/skills.tsv: '$($row.name)' is missing required metadata '$column'"
                $failed++
            }
        }
    }
} catch {
    Write-Fail $_.Exception.Message
    $failed++
}

foreach ($skillDir in $skillDirs) {
    $skillName = $skillDir.Name
    $skillFile = Join-Path $skillDir.FullName "SKILL.md"
    $skillFailed = $false

    if ($skillName -notmatch "^[a-z0-9]+(-[a-z0-9]+)*$") {
        Write-Fail "${skillName}: folder name must use lowercase kebab-case"
        $skillFailed = $true
    }

    if (-not $catalogByName.ContainsKey($skillName)) {
        Write-Fail "${skillName}: missing catalog entry in catalog/skills.tsv"
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

    if ($catalogByName.ContainsKey($skillName)) {
        $catalogEntry = $catalogByName[$skillName]
        if ($catalogEntry.source -eq "third-party") {
            if ([string]::IsNullOrWhiteSpace($catalogEntry.license) -or $catalogEntry.license -eq "repo-tbd") {
                Write-Fail "${skillName}: third-party catalog entry must include a concrete license"
                $skillFailed = $true
            }

            if (-not (Test-Path -LiteralPath (Join-Path $skillDir.FullName "LICENSE") -PathType Leaf)) {
                Write-Fail "${skillName}: third-party skill is missing local LICENSE file"
                $skillFailed = $true
            }

            foreach ($optionalColumn in @("upstream_repo", "upstream_ref", "upstream_path")) {
                if ([string]::IsNullOrWhiteSpace($catalogEntry.$optionalColumn) -or $catalogEntry.$optionalColumn -eq "unavailable") {
                    Write-Warn "${skillName}: optional upstream tracking '$optionalColumn' is incomplete"
                    $warnings++
                }
            }
        }
    }

    if ($skillFailed) {
        $failed++
    } else {
        Write-Pass "$skillName"
        $passed++
    }
}

foreach ($catalogName in @($catalogByName.Keys | Sort-Object)) {
    if (-not (Test-Path -LiteralPath (Join-Path $SkillsPath $catalogName) -PathType Container)) {
        Write-Fail "catalog/skills.tsv: entry '$catalogName' has no matching skill folder"
        $failed++
    }
}

try {
    $bundleCatalogPath = Join-Path $repoRoot "catalog\bundles.tsv"
    $bundleRows = Import-RequiredTsv -Path $bundleCatalogPath -RequiredColumns @("id", "label", "purpose", "recommendation")
    $bundleIds = New-Object System.Collections.Generic.HashSet[string]
    $bundleDir = Join-Path $repoRoot "catalog\bundles"
    if (-not (Test-Path -LiteralPath $bundleDir -PathType Container)) {
        Write-Fail "Bundle directory not found: $bundleDir"
        $failed++
    }

    foreach ($bundle in $bundleRows) {
        if ([string]::IsNullOrWhiteSpace($bundle.id)) {
            Write-Fail "catalog/bundles.tsv: row with empty id"
            $failed++
            continue
        }

        if ($bundle.id -notmatch "^[a-z0-9]+(-[a-z0-9]+)*$") {
            Write-Fail "catalog/bundles.tsv: bundle '$($bundle.id)' must use lowercase kebab-case"
            $failed++
        }

        foreach ($column in @("label", "purpose", "recommendation")) {
            if ([string]::IsNullOrWhiteSpace($bundle.$column)) {
                Write-Fail "catalog/bundles.tsv: '$($bundle.id)' is missing '$column'"
                $failed++
            }
        }

        if (-not $bundleIds.Add($bundle.id)) {
            Write-Fail "catalog/bundles.tsv: duplicate bundle '$($bundle.id)'"
            $failed++
        }

        $bundlePath = Join-Path $bundleDir "$($bundle.id).txt"
        if (-not (Test-Path -LiteralPath $bundlePath -PathType Leaf)) {
            Write-Fail "catalog/bundles: missing bundle file '$($bundle.id).txt'"
            $failed++
            continue
        }

        $seenBundleSkills = New-Object System.Collections.Generic.HashSet[string]
        foreach ($bundleSkill in @(Get-Content -LiteralPath $bundlePath | ForEach-Object { $_.Trim() } | Where-Object { -not [string]::IsNullOrWhiteSpace($_) -and -not $_.StartsWith("#") })) {
            if (-not $seenBundleSkills.Add($bundleSkill)) {
                Write-Warn "$($bundle.id): duplicate bundle skill '$bundleSkill'"
                $warnings++
            }

            if (-not $catalogByName.ContainsKey($bundleSkill)) {
                Write-Fail "$($bundle.id): bundle references unknown skill '$bundleSkill'"
                $failed++
            }
        }
    }

    foreach ($bundleFile in @(Get-ChildItem -LiteralPath $bundleDir -Filter "*.txt" -File)) {
        $bundleFileId = [System.IO.Path]::GetFileNameWithoutExtension($bundleFile.Name)
        if (-not $bundleIds.Contains($bundleFileId)) {
            Write-Fail "catalog/bundles: '$($bundleFile.Name)' has no matching row in bundles.tsv"
            $failed++
        }
    }
} catch {
    Write-Fail $_.Exception.Message
    $failed++
}

try {
    $harnessDir = Join-Path $repoRoot "harnesses"
    $requiredProfiles = @("codex", "claude-code", "opencode")
    $requiredProfileKeys = @("id", "label", "global_env", "global_suffix", "global_default", "project_subpath", "supports_project_default", "skills_format", "instructions_file")
    foreach ($profileName in $requiredProfiles) {
        $profilePath = Join-Path $harnessDir "$profileName.profile"
        $profile = Read-KeyValueFile -Path $profilePath
        foreach ($key in $requiredProfileKeys) {
            if (-not $profile.ContainsKey($key)) {
                Write-Fail "harnesses/$profileName.profile: missing '$key'"
                $failed++
            }
        }

        if ($profile.ContainsKey("id") -and $profile["id"] -ne $profileName) {
            Write-Fail "harnesses/$profileName.profile: id '$($profile["id"])' does not match file name"
            $failed++
        }
    }
} catch {
    Write-Fail $_.Exception.Message
    $failed++
}

$noticesPath = Join-Path $repoRoot "THIRD_PARTY_NOTICES.md"
if (Test-Path -LiteralPath $noticesPath -PathType Leaf) {
    $noticesContent = Get-Content -Raw -LiteralPath $noticesPath
    foreach ($row in @($catalogRows | Where-Object { $_.source -eq "third-party" })) {
        if ($noticesContent -notmatch [regex]::Escape($row.name)) {
            Write-Fail "THIRD_PARTY_NOTICES.md: missing notice entry for third-party skill '$($row.name)'"
            $failed++
        }
    }
} else {
    if (@($catalogRows | Where-Object { $_.source -eq "third-party" }).Count -gt 0) {
        Write-Fail "THIRD_PARTY_NOTICES.md is required when third-party skills exist"
        $failed++
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
