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

function Normalize-NameList {
    param([string]$Value)

    if ([string]::IsNullOrWhiteSpace($Value)) {
        return @()
    }

    return @($Value -split "," | ForEach-Object { $_.Trim() } | Where-Object { $_ } | Select-Object -Unique)
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

$deprecatedLicensePlaceholder = "repo" + "-tbd"
$deprecatedUnavailablePlaceholder = "un" + "available"

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

$requiredAgentColumns = @(
    "name",
    "label",
    "maturity",
    "harnesses",
    "skills",
    "permission",
    "description"
)

$requiredAgentSections = @(
    "Use When",
    "Do Not Use When",
    "Required Inputs",
    "Workflow",
    "Allowed Actions",
    "Forbidden Actions",
    "Output Format",
    "Escalation Rules"
)

$requiredWorkflowSections = @(
    "Trigger",
    "Ordered Skills",
    "Phase Outputs",
    "Phase Transitions",
    "Validation Gates",
    "Context Continuity",
    "Handoff Format",
    "Escalation Rules"
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
            if ([string]::IsNullOrWhiteSpace($catalogEntry.license) -or $catalogEntry.license -eq $deprecatedLicensePlaceholder) {
                Write-Fail "${skillName}: third-party catalog entry must include a concrete license"
                $skillFailed = $true
            }

            if (-not (Test-Path -LiteralPath (Join-Path $skillDir.FullName "LICENSE") -PathType Leaf)) {
                Write-Fail "${skillName}: third-party skill is missing local LICENSE file"
                $skillFailed = $true
            }

            foreach ($optionalColumn in @("upstream_repo", "upstream_ref", "upstream_path")) {
                if ([string]::IsNullOrWhiteSpace($catalogEntry.$optionalColumn) -or $catalogEntry.$optionalColumn -eq $deprecatedUnavailablePlaceholder) {
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
    $agentsPath = Join-Path $repoRoot "agents"
    $agentCatalogPath = Join-Path $repoRoot "catalog\agents.tsv"
    $agentBundleCatalogPath = Join-Path $repoRoot "catalog\agent-bundles.tsv"
    $agentBundleDir = Join-Path $repoRoot "catalog\agent-bundles"
    $agentCatalogRows = Import-RequiredTsv -Path $agentCatalogPath -RequiredColumns $requiredAgentColumns
    $agentCatalogByName = @{}

    if (-not (Test-Path -LiteralPath $agentsPath -PathType Container)) {
        Write-Fail "Agents directory not found: $agentsPath"
        $failed++
    } else {
        Write-Info "Validating canonical subagents in $agentsPath"
    }

    foreach ($row in $agentCatalogRows) {
        if ([string]::IsNullOrWhiteSpace($row.name)) {
            Write-Fail "catalog/agents.tsv: row with empty name"
            $failed++
            continue
        }

        if ($agentCatalogByName.ContainsKey($row.name)) {
            Write-Fail "catalog/agents.tsv: duplicate agent entry '$($row.name)'"
            $failed++
            continue
        }

        $agentCatalogByName[$row.name] = $row

        if ($row.name -notmatch "^[a-z0-9]+(-[a-z0-9]+)*$") {
            Write-Fail "catalog/agents.tsv: agent '$($row.name)' must use lowercase kebab-case"
            $failed++
        }

        foreach ($column in @("label", "maturity", "harnesses", "skills", "permission", "description")) {
            if ([string]::IsNullOrWhiteSpace($row.$column)) {
                Write-Fail "catalog/agents.tsv: '$($row.name)' is missing required metadata '$column'"
                $failed++
            }
        }

        foreach ($skill in @(Normalize-NameList -Value $row.skills)) {
            if (-not $catalogByName.ContainsKey($skill)) {
                Write-Fail "catalog/agents.tsv: '$($row.name)' references unknown skill '$skill'"
                $failed++
            }
        }
    }

    if (Test-Path -LiteralPath $agentsPath -PathType Container) {
        foreach ($agentFile in @(Get-ChildItem -LiteralPath $agentsPath -Filter "*.md" -File | Sort-Object Name)) {
            $agentName = [System.IO.Path]::GetFileNameWithoutExtension($agentFile.Name)
            $agentFailed = $false
            $content = Get-Content -Raw -LiteralPath $agentFile.FullName
            $frontmatterMatch = [regex]::Match($content, "(?s)\A---\s*\r?\n(.*?)\r?\n---\s*(\r?\n|$)")

            if ($agentName -notmatch "^[a-z0-9]+(-[a-z0-9]+)*$") {
                Write-Fail "${agentName}: agent file name must use lowercase kebab-case"
                $agentFailed = $true
            }

            if (-not $agentCatalogByName.ContainsKey($agentName)) {
                Write-Fail "${agentName}: missing catalog entry in catalog/agents.tsv"
                $agentFailed = $true
            }

            if (-not $frontmatterMatch.Success) {
                Write-Fail "${agentName}: missing or invalid YAML frontmatter"
                $failed++
                continue
            }

            $frontmatter = $frontmatterMatch.Groups[1].Value
            $name = Get-FrontmatterValue -Frontmatter $frontmatter -Key "name"
            $description = Get-FrontmatterValue -Frontmatter $frontmatter -Key "description"
            $skills = Normalize-NameList -Value (Get-FrontmatterValue -Frontmatter $frontmatter -Key "skills")
            $tools = Get-FrontmatterValue -Frontmatter $frontmatter -Key "tools"
            $permission = Get-FrontmatterValue -Frontmatter $frontmatter -Key "permission"

            if ([string]::IsNullOrWhiteSpace($name)) {
                Write-Fail "${agentName}: frontmatter is missing name"
                $agentFailed = $true
            } elseif ($name -ne $agentName) {
                Write-Fail "${agentName}: frontmatter name '$name' does not match file name"
                $agentFailed = $true
            }

            if ([string]::IsNullOrWhiteSpace($description)) {
                Write-Fail "${agentName}: frontmatter description is empty or missing"
                $agentFailed = $true
            } else {
                if ($description.Trim().Length -lt 80) {
                    Write-Fail "${agentName}: description is too short to be useful; use at least 80 characters"
                    $agentFailed = $true
                }

                if ($description -notmatch "\bUse (when|before|for|at)\b") {
                    Write-Fail "${agentName}: description must include trigger language such as 'Use when'"
                    $agentFailed = $true
                }
            }

            if ($permission -notin @("read-only", "validation-only")) {
                Write-Fail "${agentName}: permission must be read-only or validation-only"
                $agentFailed = $true
            }

            foreach ($skill in $skills) {
                if (-not $catalogByName.ContainsKey($skill)) {
                    Write-Fail "${agentName}: frontmatter references unknown skill '$skill'"
                    $agentFailed = $true
                }
            }

            foreach ($section in $requiredAgentSections) {
                $sectionPattern = "(?m)^## $([regex]::Escape($section))\s*$"
                if ($content -notmatch $sectionPattern) {
                    Write-Fail "${agentName}: missing required section '## $section'"
                    $agentFailed = $true
                }
            }

            $renderedClaude = @(
                "---",
                "name: $name",
                "description: $description",
                "tools: $tools"
            ) -join "`n"
            if ($renderedClaude -notmatch "(?m)^name:\s*\S+" -or
                $renderedClaude -notmatch "(?m)^description:\s*\S+" -or
                $renderedClaude -notmatch "(?m)^tools:\s*\S+") {
                Write-Fail "${agentName}: rendered Claude Code output would miss name, description, or tools"
                $agentFailed = $true
            }

            $renderedOpenCode = @(
                "---",
                "description: $description",
                "mode: subagent",
                "permission:"
            ) -join "`n"
            if ($renderedOpenCode -notmatch "(?m)^description:\s*\S+" -or
                $renderedOpenCode -notmatch "(?m)^mode:\s*subagent\s*$" -or
                $renderedOpenCode -notmatch "(?m)^permission:\s*$") {
                Write-Fail "${agentName}: rendered OpenCode output would miss description, mode, or permission"
                $agentFailed = $true
            }

            if ($agentFailed) {
                $failed++
            } else {
                Write-Pass "$agentName agent"
                $passed++
            }
        }

        foreach ($catalogAgentName in @($agentCatalogByName.Keys | Sort-Object)) {
            if (-not (Test-Path -LiteralPath (Join-Path $agentsPath "$catalogAgentName.md") -PathType Leaf)) {
                Write-Fail "catalog/agents.tsv: entry '$catalogAgentName' has no matching agent file"
                $failed++
            }
        }
    }

    $agentBundleRows = Import-RequiredTsv -Path $agentBundleCatalogPath -RequiredColumns @("id", "label", "purpose", "recommendation")
    $agentBundleIds = New-Object System.Collections.Generic.HashSet[string]
    if (-not (Test-Path -LiteralPath $agentBundleDir -PathType Container)) {
        Write-Fail "Agent bundle directory not found: $agentBundleDir"
        $failed++
    }

    foreach ($agentBundle in $agentBundleRows) {
        if ([string]::IsNullOrWhiteSpace($agentBundle.id)) {
            Write-Fail "catalog/agent-bundles.tsv: row with empty id"
            $failed++
            continue
        }

        if ($agentBundle.id -notmatch "^[a-z0-9]+(-[a-z0-9]+)*$") {
            Write-Fail "catalog/agent-bundles.tsv: bundle '$($agentBundle.id)' must use lowercase kebab-case"
            $failed++
        }

        foreach ($column in @("label", "purpose", "recommendation")) {
            if ([string]::IsNullOrWhiteSpace($agentBundle.$column)) {
                Write-Fail "catalog/agent-bundles.tsv: '$($agentBundle.id)' is missing '$column'"
                $failed++
            }
        }

        if (-not $agentBundleIds.Add($agentBundle.id)) {
            Write-Fail "catalog/agent-bundles.tsv: duplicate bundle '$($agentBundle.id)'"
            $failed++
        }

        $agentBundlePath = Join-Path $agentBundleDir "$($agentBundle.id).txt"
        if (-not (Test-Path -LiteralPath $agentBundlePath -PathType Leaf)) {
            Write-Fail "catalog/agent-bundles: missing bundle file '$($agentBundle.id).txt'"
            $failed++
            continue
        }

        $seenBundleAgents = New-Object System.Collections.Generic.HashSet[string]
        foreach ($bundleAgent in @(Get-Content -LiteralPath $agentBundlePath | ForEach-Object { $_.Trim() } | Where-Object { -not [string]::IsNullOrWhiteSpace($_) -and -not $_.StartsWith("#") })) {
            if (-not $seenBundleAgents.Add($bundleAgent)) {
                Write-Warn "$($agentBundle.id): duplicate bundle agent '$bundleAgent'"
                $warnings++
            }

            if (-not $agentCatalogByName.ContainsKey($bundleAgent)) {
                Write-Fail "$($agentBundle.id): agent bundle references unknown agent '$bundleAgent'"
                $failed++
            }
        }
    }

    if (Test-Path -LiteralPath $agentBundleDir -PathType Container) {
        foreach ($agentBundleFile in @(Get-ChildItem -LiteralPath $agentBundleDir -Filter "*.txt" -File)) {
            $agentBundleFileId = [System.IO.Path]::GetFileNameWithoutExtension($agentBundleFile.Name)
            if (-not $agentBundleIds.Contains($agentBundleFileId)) {
                Write-Fail "catalog/agent-bundles: '$($agentBundleFile.Name)' has no matching row in agent-bundles.tsv"
                $failed++
            }
        }
    }
} catch {
    Write-Fail $_.Exception.Message
    $failed++
}

try {
    $workflowsPath = Join-Path $repoRoot "workflows"
    if (-not (Test-Path -LiteralPath $workflowsPath -PathType Container)) {
        Write-Fail "Workflows directory not found: $workflowsPath"
        $failed++
    } else {
        $workflowFiles = @(Get-ChildItem -LiteralPath $workflowsPath -Filter "*.md" -File | Sort-Object Name)
        if ($workflowFiles.Count -eq 0) {
            Write-Fail "No workflow templates found under: $workflowsPath"
            $failed++
        } else {
            Write-Info "Validating $($workflowFiles.Count) workflow template(s) in $workflowsPath"
        }

        foreach ($workflowFile in $workflowFiles) {
            $workflowFailed = $false
            $content = Get-Content -Raw -LiteralPath $workflowFile.FullName

            if ($workflowFile.BaseName -notmatch "^[a-z0-9]+(-[a-z0-9]+)*$") {
                Write-Fail "$($workflowFile.Name): workflow file name must use lowercase kebab-case"
                $workflowFailed = $true
            }

            foreach ($section in $requiredWorkflowSections) {
                $sectionPattern = "(?m)^## $([regex]::Escape($section))\s*$"
                if ($content -notmatch $sectionPattern) {
                    Write-Fail "$($workflowFile.Name): missing required section '## $section'"
                    $workflowFailed = $true
                }
            }

            if ($workflowFailed) {
                $failed++
            } else {
                Write-Pass "$($workflowFile.Name) workflow"
                $passed++
            }
        }
    }
} catch {
    Write-Fail $_.Exception.Message
    $failed++
}

try {
    $harnessDir = Join-Path $repoRoot "harnesses"
    $requiredProfiles = @("codex", "claude-code", "opencode")
    $requiredProfileKeys = @(
        "id",
        "label",
        "global_env",
        "global_suffix",
        "global_default",
        "project_subpath",
        "supports_project_default",
        "skills_format",
        "instructions_file",
        "agent_support",
        "agent_format",
        "agent_global_env",
        "agent_global_suffix",
        "agent_global_default",
        "agent_project_subpath",
        "supports_agent_project_default"
    )
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

        if ($profile.ContainsKey("agent_support") -and $profile["agent_support"] -notin @("native", "guidance")) {
            Write-Fail "harnesses/$profileName.profile: agent_support must be native or guidance"
            $failed++
        }

        if ($profile.ContainsKey("agent_support") -and $profile["agent_support"] -eq "native") {
            if ($profile["agent_format"] -notin @("claude-subagent", "opencode-agent")) {
                Write-Fail "harnesses/$profileName.profile: native agent profile has unsupported agent_format '$($profile["agent_format"])'"
                $failed++
            }

            if ([string]::IsNullOrWhiteSpace($profile["agent_global_default"])) {
                Write-Fail "harnesses/$profileName.profile: native agent profile must declare agent_global_default"
                $failed++
            }
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

$workflowRuntime = Join-Path $repoRoot "scripts\run-agent-workflow.ps1"
if (Test-Path -LiteralPath $workflowRuntime -PathType Leaf) {
    Write-Info "Validating executable workflow manifests"
    & $workflowRuntime -Action Validate
    if ($LASTEXITCODE -ne 0) {
        Write-Fail "Executable workflow manifest validation failed"
        $failed++
    } else {
        $passed++
    }
} else {
    Write-Fail "Workflow runtime not found: $workflowRuntime"
    $failed++
}

$evalValidationScript = Join-Path $repoRoot "scripts\validate-evals.ps1"
if (Test-Path -LiteralPath $evalValidationScript -PathType Leaf) {
    Write-Info "Running eval scenario validation"
    $powershellCommand = Get-Command pwsh -ErrorAction SilentlyContinue
    if (-not $powershellCommand) {
        $powershellCommand = Get-Command powershell -ErrorAction SilentlyContinue
    }

    if ($powershellCommand) {
        & $powershellCommand.Source -NoProfile -ExecutionPolicy Bypass -File $evalValidationScript
        if ($LASTEXITCODE -ne 0) {
            Write-Fail "Eval scenario validation failed"
            $failed++
        }
    } else {
        Write-Fail "Could not find a PowerShell executable to run eval scenario validation"
        $failed++
    }
} else {
    Write-Fail "Eval validation script not found: $evalValidationScript"
    $failed++
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
