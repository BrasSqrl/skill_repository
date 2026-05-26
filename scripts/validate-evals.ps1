<#
.SYNOPSIS
Validate dependency-free evaluation scenarios and catalog metadata.

.EXAMPLES
.\scripts\validate-evals.ps1

.\scripts\validate-evals.ps1 -EvalsPath ".\evals"
#>

[CmdletBinding()]
param(
    [string]$EvalsPath
)

$ErrorActionPreference = "Stop"

function Write-Pass {
    param([string]$Message)
    Write-Host "[PASS] $Message"
}

function Write-Fail {
    param([string]$Message)
    Write-Host "[FAIL] $Message" -ForegroundColor Red
}

function Write-Info {
    param([string]$Message)
    Write-Host "[INFO] $Message"
}

function Get-RepoRoot {
    if ($PSScriptRoot) {
        return (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
    }

    return (Get-Location).Path
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

function Test-EvalTarget {
    param(
        [string]$RepoRoot,
        [string]$TargetType,
        [string]$TargetName
    )

    switch ($TargetType) {
        "skill" {
            return (Test-Path -LiteralPath ([System.IO.Path]::Combine($RepoRoot, "skills", $TargetName, "SKILL.md")) -PathType Leaf)
        }
        "agent" {
            return (Test-Path -LiteralPath ([System.IO.Path]::Combine($RepoRoot, "agents", "$TargetName.md")) -PathType Leaf)
        }
        "workflow" {
            return (Test-Path -LiteralPath ([System.IO.Path]::Combine($RepoRoot, "workflows", "$TargetName.md")) -PathType Leaf)
        }
        "bundle" {
            return (
                (Test-Path -LiteralPath ([System.IO.Path]::Combine($RepoRoot, "catalog", "bundles", "$TargetName.txt")) -PathType Leaf) -or
                (Test-Path -LiteralPath ([System.IO.Path]::Combine($RepoRoot, "catalog", "agent-bundles", "$TargetName.txt")) -PathType Leaf)
            )
        }
        default {
            return $false
        }
    }
}

$repoRoot = Get-RepoRoot
if (-not $EvalsPath) {
    $EvalsPath = Join-Path $repoRoot "evals"
}

$catalogPath = Join-Path $repoRoot "catalog\evals.tsv"
$requiredColumns = @("id", "target_type", "target_name", "capability", "mode", "status", "description")
$requiredSections = @(
    "Objective",
    "Target",
    "Inputs",
    "Setup",
    "Expected Behavior",
    "Pass Criteria",
    "Failure Signals",
    "Artifacts",
    "Review Notes"
)

$passed = 0
$failed = 0

try {
    if (-not (Test-Path -LiteralPath $EvalsPath -PathType Container)) {
        Write-Fail "Evals directory not found: $EvalsPath"
        exit 1
    }

    $rows = Import-RequiredTsv -Path $catalogPath -RequiredColumns $requiredColumns
    Write-Info "Validating $($rows.Count) eval scenario(s)"

    $seen = New-Object System.Collections.Generic.HashSet[string]
    foreach ($row in $rows) {
        $scenarioFailed = $false

        if ([string]::IsNullOrWhiteSpace($row.id)) {
            Write-Fail "catalog/evals.tsv: row with empty id"
            $failed++
            continue
        }

        if (-not $seen.Add($row.id)) {
            Write-Fail "catalog/evals.tsv: duplicate eval id '$($row.id)'"
            $failed++
            continue
        }

        if ($row.id -notmatch "^[a-z0-9]+(-[a-z0-9]+)*$") {
            Write-Fail "$($row.id): eval id must use lowercase kebab-case"
            $scenarioFailed = $true
        }

        if ($row.target_type -notin @("skill", "agent", "workflow", "bundle")) {
            Write-Fail "$($row.id): target_type must be skill, agent, workflow, or bundle"
            $scenarioFailed = $true
        }

        if ($row.mode -notin @("manual", "dry-run", "fixture")) {
            Write-Fail "$($row.id): mode must be manual, dry-run, or fixture"
            $scenarioFailed = $true
        }

        if ($row.status -notin @("draft", "validated", "retired")) {
            Write-Fail "$($row.id): status must be draft, validated, or retired"
            $scenarioFailed = $true
        }

        foreach ($column in $requiredColumns) {
            if ([string]::IsNullOrWhiteSpace($row.$column)) {
                Write-Fail "$($row.id): missing required metadata '$column'"
                $scenarioFailed = $true
            }
        }

        if (-not (Test-EvalTarget -RepoRoot $repoRoot -TargetType $row.target_type -TargetName $row.target_name)) {
            Write-Fail "$($row.id): target '$($row.target_type):$($row.target_name)' does not exist"
            $scenarioFailed = $true
        }

        $scenarioPath = [System.IO.Path]::Combine($EvalsPath, "scenarios", $row.id, "scenario.md")
        if (-not (Test-Path -LiteralPath $scenarioPath -PathType Leaf)) {
            Write-Fail "$($row.id): missing scenario.md"
            $scenarioFailed = $true
        } else {
            $content = Get-Content -Raw -LiteralPath $scenarioPath
            foreach ($section in $requiredSections) {
                if ($content -notmatch "(?m)^## $([regex]::Escape($section))\s*$") {
                    Write-Fail "$($row.id): missing required section '## $section'"
                    $scenarioFailed = $true
                }
            }
        }

        if ($scenarioFailed) {
            $failed++
        } else {
            Write-Pass $row.id
            $passed++
        }
    }
} catch {
    Write-Fail $_.Exception.Message
    $failed++
}

Write-Host ""
Write-Host "Eval validation summary:"
Write-Host "  Passed: $passed"
Write-Host "  Failed: $failed"

if ($failed -gt 0) {
    exit 1
}

exit 0
