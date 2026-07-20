<#
.SYNOPSIS
Run focused behavioral tests for the agentic workflow runtime.
#>

[CmdletBinding()]
param()

$ErrorActionPreference = "Stop"

function Assert-Equal {
    param(
        [object]$Actual,
        [object]$Expected,
        [string]$Message
    )

    if ($Actual -ne $Expected) {
        throw "$Message Expected '$Expected', got '$Actual'."
    }
}

function Assert-True {
    param(
        [bool]$Condition,
        [string]$Message
    )

    if (-not $Condition) {
        throw $Message
    }
}

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$runner = Join-Path $PSScriptRoot "run-agent-workflow.ps1"
$testRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("agent-workflow-test-" + [guid]::NewGuid().ToString("N"))

try {
    New-Item -ItemType Directory -Path $testRoot | Out-Null

    $selectionJson = & $runner -Action Select -Task "Implement a tested feature with independent review" -OutputFormat Json
    Assert-Equal -Actual $LASTEXITCODE -Expected 0 -Message "Workflow selection should succeed."
    $selection = $selectionJson | ConvertFrom-Json
    Assert-Equal -Actual $selection.selected -Expected "feature-quality-loop" -Message "Routing should select the quality loop for a tested feature with independent review."
    Assert-Equal -Actual $selection.needs_confirmation -Expected $false -Message "A unique positive routing match should not require confirmation."

    $startJson = & $runner -Action Start -Workflow feature-quality-loop -Objective "Add a tested feature" -ProjectPath $repoRoot -StateRoot $testRoot -OutputFormat Json
    Assert-Equal -Actual $LASTEXITCODE -Expected 0 -Message "Start should succeed."
    $start = $startJson | ConvertFrom-Json
    Assert-Equal -Actual $start.status -Expected "running" -Message "A new run should be active."
    Assert-Equal -Actual $start.current_phase -Expected "source-context" -Message "A new run should begin at the first phase."
    Assert-True -Condition (Test-Path -LiteralPath $start.run_path -PathType Leaf) -Message "Start should create a durable run-state file."
    $startedState = Get-Content -Raw -LiteralPath $start.run_path | ConvertFrom-Json
    Assert-Equal -Actual $startedState.workflow_manifest.id -Expected "feature-quality-loop" -Message "A run should freeze its workflow manifest for durable resume behavior."
    Assert-True -Condition ($startedState.revision -gt 0) -Message "State writes should increment a revision."

    $powerShellHost = (Get-Process -Id $PID).Path
    $previousErrorAction = $ErrorActionPreference
    $ErrorActionPreference = "SilentlyContinue"
    $null = & $powerShellHost -NoLogo -NoProfile -File $runner -Action Advance -RunPath $start.run_path -OutputFormat Json 2>$null
    $rejectedExitCode = $LASTEXITCODE
    $ErrorActionPreference = $previousErrorAction
    Assert-True -Condition ($rejectedExitCode -ne 0) -Message "Advance should fail while required evidence is missing."
    $unchanged = Get-Content -Raw -LiteralPath $start.run_path | ConvertFrom-Json
    Assert-Equal -Actual $unchanged.current_phase -Expected "source-context" -Message "A rejected transition must not advance state."

    $null = & $runner -Action Record -RunPath $start.run_path -EvidenceName source-files -EvidenceValue "src/example.ps1" -OutputFormat Json
    Assert-Equal -Actual $LASTEXITCODE -Expected 0 -Message "Recording source evidence should succeed."
    $null = & $runner -Action Record -RunPath $start.run_path -EvidenceName acceptance-criteria -EvidenceValue "Behavior is observable and testable" -OutputFormat Json
    Assert-Equal -Actual $LASTEXITCODE -Expected 0 -Message "Recording acceptance criteria should succeed."

    $advanceJson = & $runner -Action Advance -RunPath $start.run_path -OutputFormat Json
    Assert-Equal -Actual $LASTEXITCODE -Expected 0 -Message "Advance should succeed after the gate is satisfied."
    $advanced = $advanceJson | ConvertFrom-Json
    Assert-Equal -Actual $advanced.current_phase -Expected "implementation-plan" -Message "Advance should select the next phase."

    $null = & $runner -Action Escalate -RunPath $start.run_path -Reason "Product decision required" -OutputFormat Json
    Assert-Equal -Actual $LASTEXITCODE -Expected 0 -Message "Escalation should succeed."
    $escalated = Get-Content -Raw -LiteralPath $start.run_path | ConvertFrom-Json
    Assert-Equal -Actual $escalated.status -Expected "awaiting-input" -Message "Escalation should pause the run."

    $resumeJson = & $runner -Action Resume -RunPath $start.run_path -Resolution "Use the existing public contract" -OutputFormat Json
    Assert-Equal -Actual $LASTEXITCODE -Expected 0 -Message "Resume should succeed after a resolution is supplied."
    $resumed = $resumeJson | ConvertFrom-Json
    Assert-Equal -Actual $resumed.status -Expected "running" -Message "Resume should reactivate the run."
    Assert-Equal -Actual $resumed.current_phase -Expected "implementation-plan" -Message "Resume should preserve the current phase."

    $handoffJson = & $runner -Action Handoff -RunPath $start.run_path -OutputFormat Json
    Assert-Equal -Actual $LASTEXITCODE -Expected 0 -Message "Handoff generation should succeed."
    $handoff = $handoffJson | ConvertFrom-Json
    Assert-True -Condition (Test-Path -LiteralPath $handoff.handoff_path -PathType Leaf) -Message "Handoff should create a Markdown artifact."
    $handoffText = Get-Content -Raw -LiteralPath $handoff.handoff_path
    Assert-True -Condition ($handoffText -match "## Exact Next Action") -Message "Handoff should identify the next action."
    Assert-True -Condition ($handoffText -match [regex]::Escape($start.run_path)) -Message "Handoff should include the durable run-state path."

    $completion = $resumed
    while ($completion.status -eq "running") {
        foreach ($missingEvidence in @($completion.missing_evidence)) {
            $null = & $runner -Action Record -RunPath $start.run_path -EvidenceName $missingEvidence -EvidenceValue "Synthetic test evidence for $missingEvidence" -OutputFormat Json
            Assert-Equal -Actual $LASTEXITCODE -Expected 0 -Message "Recording completion evidence should succeed."
        }
        $completionJson = & $runner -Action Advance -RunPath $start.run_path -OutputFormat Json
        Assert-Equal -Actual $LASTEXITCODE -Expected 0 -Message "A fully satisfied phase should advance."
        $completion = $completionJson | ConvertFrom-Json
    }
    Assert-Equal -Actual $completion.status -Expected "completed" -Message "Advancing the final satisfied phase should complete the workflow."
    Assert-True -Condition ([string]::IsNullOrWhiteSpace($completion.current_phase)) -Message "A completed workflow should not retain a current phase."

    $portableSkill = Join-Path $testRoot "agentic-workflow-runtime"
    Copy-Item -LiteralPath (Join-Path $repoRoot "skills\agentic-workflow-runtime") -Destination $portableSkill -Recurse
    $portableRunner = Join-Path $portableSkill "scripts\run-agent-workflow.ps1"
    $portableJson = & $portableRunner -Action Validate -OutputFormat Json
    Assert-Equal -Actual $LASTEXITCODE -Expected 0 -Message "The installed-skill layout should validate without repository files."
    $portable = $portableJson | ConvertFrom-Json
    Assert-Equal -Actual $portable.workflow_count -Expected 21 -Message "The portable skill should retain every workflow manifest."

    Write-Host "[PASS] workflow runner start, gate, advance, escalation, resume, handoff, and installed-skill behavior"
    exit 0
} catch {
    Write-Host "[FAIL] $($_.Exception.Message)" -ForegroundColor Red
    exit 1
} finally {
    if (Test-Path -LiteralPath $testRoot -PathType Container) {
        $resolvedTemp = [System.IO.Path]::GetFullPath([System.IO.Path]::GetTempPath())
        $resolvedTest = [System.IO.Path]::GetFullPath($testRoot)
        if ($resolvedTest.StartsWith($resolvedTemp, [System.StringComparison]::OrdinalIgnoreCase)) {
            Remove-Item -LiteralPath $resolvedTest -Recurse -Force
        }
    }
}
