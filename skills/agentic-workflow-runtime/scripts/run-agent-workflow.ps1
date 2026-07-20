<#
.SYNOPSIS
Select, start, and advance durable agent workflow runs.

.DESCRIPTION
Executes the state and gate bookkeeping for workflow manifests under
catalog/workflow-manifests. The language model or operator performs phase
work; this script prevents transitions without the declared evidence.

.EXAMPLES
.\scripts\run-agent-workflow.ps1 -Action Select -Task "Implement a tested API feature"

.\scripts\run-agent-workflow.ps1 -Action Start -Workflow feature-quality-loop -Objective "Add export support"

$RunPath = "<run-state-path>"
.\scripts\run-agent-workflow.ps1 -Action Record -RunPath $RunPath -EvidenceName source-files -EvidenceValue "src/export.ps1"

.\scripts\run-agent-workflow.ps1 -Action Advance -RunPath $RunPath
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidateSet("Validate", "List", "Select", "Start", "Status", "Record", "Advance", "Retry", "Escalate", "Resume", "Handoff")]
    [string]$Action,

    [string]$Workflow,
    [string]$Task,
    [string]$Objective,
    [string]$ProjectPath,
    [string]$StateRoot,
    [string]$RunPath,
    [string]$EvidenceName,
    [string]$EvidenceValue,
    [string]$Reason,
    [string]$Resolution,
    [switch]$PreserveEvidence,

    [ValidateSet("Text", "Json")]
    [string]$OutputFormat = "Text"
)

$ErrorActionPreference = "Stop"

function Get-RuntimeRoot {
    $skillRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
    $repoCandidate = [System.IO.Path]::GetFullPath((Join-Path $skillRoot "..\.."))
    if (Test-Path -LiteralPath (Join-Path $repoCandidate "catalog\workflows.tsv") -PathType Leaf) {
        return $repoCandidate
    }

    if (Test-Path -LiteralPath (Join-Path $skillRoot "references\workflows.tsv") -PathType Leaf) {
        return $skillRoot
    }

    throw "Could not locate catalog/workflows.tsv in a repository or references/workflows.tsv in the installed skill."
}

function Get-UtcTimestamp {
    return (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss.fffZ")
}

function Read-WorkflowCatalog {
    param([string]$RepoRoot)

    $path = Join-Path $RepoRoot "catalog\workflows.tsv"
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
        $path = Join-Path $RepoRoot "references\workflows.tsv"
    }
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
        throw "Workflow catalog not found: $path"
    }

    return @(Import-Csv -LiteralPath $path -Delimiter "`t")
}

function Get-WorkflowRow {
    param(
        [object[]]$Catalog,
        [string]$WorkflowId
    )

    if ([string]::IsNullOrWhiteSpace($WorkflowId) -or $WorkflowId -notmatch "^[a-z0-9]+(-[a-z0-9]+)*$") {
        throw "A valid lowercase kebab-case workflow id is required."
    }

    $row = @($Catalog | Where-Object { $_.id -eq $WorkflowId })
    if ($row.Count -ne 1) {
        throw "Workflow '$WorkflowId' was not found exactly once in catalog/workflows.tsv."
    }

    return $row[0]
}

function Read-WorkflowManifest {
    param(
        [string]$RepoRoot,
        [object]$CatalogRow
    )

    $relativePath = $CatalogRow.manifest -replace "/", [System.IO.Path]::DirectorySeparatorChar
    $rootPath = [System.IO.Path]::GetFullPath($RepoRoot).TrimEnd([System.IO.Path]::DirectorySeparatorChar, [System.IO.Path]::AltDirectorySeparatorChar) + [System.IO.Path]::DirectorySeparatorChar
    $path = [System.IO.Path]::GetFullPath((Join-Path $RepoRoot $relativePath))
    if (-not $path.StartsWith($rootPath, [System.StringComparison]::OrdinalIgnoreCase)) {
        throw "Workflow manifest path leaves the runtime root: $relativePath"
    }
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
        throw "Workflow manifest not found: $path"
    }

    try {
        $manifest = Get-Content -Raw -LiteralPath $path | ConvertFrom-Json
    } catch {
        throw "Workflow manifest is not valid JSON: $path. $($_.Exception.Message)"
    }

    return $manifest
}

function Get-WorkflowSelection {
    param(
        [object[]]$Catalog,
        [string]$TaskDescription
    )

    if ([string]::IsNullOrWhiteSpace($TaskDescription)) {
        throw "-Task is required for workflow selection."
    }

    $normalized = $TaskDescription.ToLowerInvariant()
    $candidates = foreach ($row in $Catalog) {
        $score = 0
        $matched = @()
        foreach ($keyword in @($row.keywords -split "," | ForEach-Object { $_.Trim() } | Where-Object { $_ })) {
            if ($normalized.Contains($keyword.ToLowerInvariant())) {
                $score += @($keyword -split "\s+" | Where-Object { $_ }).Count
                $matched += $keyword
            }
        }

        [pscustomobject]@{
            id = $row.id
            label = $row.label
            score = $score
            matched_keywords = @($matched)
            mutation = $row.mutation
            description = $row.description
        }
    }

    return @($candidates | Sort-Object @{ Expression = "score"; Descending = $true }, @{ Expression = "id"; Descending = $false } | Select-Object -First 3)
}

function Resolve-StateRoot {
    param([string]$RequestedRoot)

    if (-not [string]::IsNullOrWhiteSpace($RequestedRoot)) {
        return [System.IO.Path]::GetFullPath($RequestedRoot)
    }

    $localData = [Environment]::GetFolderPath([Environment+SpecialFolder]::LocalApplicationData)
    if ([string]::IsNullOrWhiteSpace($localData)) {
        $localData = [System.IO.Path]::GetTempPath()
    }

    return Join-Path $localData "agent-workflow-runs"
}

function Read-RunState {
    param([string]$Path)

    if ([string]::IsNullOrWhiteSpace($Path)) {
        throw "-RunPath is required for action '$Action'."
    }

    $fullPath = [System.IO.Path]::GetFullPath($Path)
    if (-not (Test-Path -LiteralPath $fullPath -PathType Leaf)) {
        throw "Workflow run state not found: $fullPath"
    }

    try {
        $state = Get-Content -Raw -LiteralPath $fullPath | ConvertFrom-Json
    } catch {
        throw "Workflow run state is not valid JSON: $fullPath. $($_.Exception.Message)"
    }

    return [pscustomobject]@{ Path = $fullPath; State = $state }
}

function Save-RunState {
    param(
        [object]$State,
        [string]$Path
    )

    if (-not $State.PSObject.Properties["revision"]) {
        $State | Add-Member -NotePropertyName revision -NotePropertyValue 0
    }
    $State.revision = [int]$State.revision + 1
    $State.updated_at = Get-UtcTimestamp
    $json = $State | ConvertTo-Json -Depth 20
    $directory = Split-Path -Parent $Path
    $temporaryPath = Join-Path $directory ("." + [System.IO.Path]::GetFileName($Path) + "." + [guid]::NewGuid().ToString("N") + ".tmp")
    try {
        Set-Content -LiteralPath $temporaryPath -Value $json -Encoding UTF8
        Move-Item -LiteralPath $temporaryPath -Destination $Path -Force
    } finally {
        if (Test-Path -LiteralPath $temporaryPath -PathType Leaf) {
            Remove-Item -LiteralPath $temporaryPath -Force
        }
    }
}

function Add-HistoryEvent {
    param(
        [object]$State,
        [string]$Event,
        [string]$Phase,
        [string]$Detail
    )

    $entry = [pscustomobject]@{
        at = Get-UtcTimestamp
        event = $Event
        phase = $Phase
        detail = $Detail
    }
    $State.history = @($State.history) + $entry
}

function Get-PhaseIndex {
    param(
        [object]$Manifest,
        [string]$PhaseId
    )

    for ($index = 0; $index -lt $Manifest.phases.Count; $index++) {
        if ($Manifest.phases[$index].id -eq $PhaseId) {
            return $index
        }
    }

    throw "Phase '$PhaseId' is not present in workflow '$($Manifest.id)'."
}

function Get-RunSummary {
    param(
        [object]$State,
        [object]$Manifest,
        [string]$Path
    )

    $contract = $null
    $missing = @()
    if ($State.current_phase) {
        $index = Get-PhaseIndex -Manifest $Manifest -PhaseId $State.current_phase
        $manifestPhase = $Manifest.phases[$index]
        $statePhase = @($State.phases | Where-Object { $_.id -eq $State.current_phase })[0]
        $recorded = @($statePhase.evidence | ForEach-Object { $_.name })
        $missing = @($manifestPhase.required_evidence | Where-Object { $recorded -notcontains $_ })
        $contract = [pscustomobject]@{
            id = $manifestPhase.id
            name = $manifestPhase.name
            owner = $manifestPhase.owner
            permission = $manifestPhase.permission
            instructions = $manifestPhase.instructions
            output = $manifestPhase.output
            required_evidence = @($manifestPhase.required_evidence)
            missing_evidence = @($missing)
            attempt = $statePhase.attempts
            retry_limit = $manifestPhase.retry_limit
        }
    }

    return [pscustomobject]@{
        run_id = $State.run_id
        run_path = $Path
        workflow = $State.workflow_id
        workflow_mutation = $Manifest.mutation
        approval_boundaries = @($Manifest.approval_boundaries)
        objective = $State.objective
        project_path = $State.project_path
        status = $State.status
        current_phase = $State.current_phase
        current_phase_contract = $contract
        missing_evidence = @($missing)
        updated_at = $State.updated_at
    }
}

function Write-Result {
    param(
        [object]$Result,
        [string]$TextSummary
    )

    if ($OutputFormat -eq "Json") {
        $Result | ConvertTo-Json -Depth 20
    } else {
        Write-Host $TextSummary
        if ($Result.current_phase_contract) {
            Write-Host "Workflow mutation: $($Result.workflow_mutation)"
            Write-Host "Approval boundaries: $(@($Result.approval_boundaries) -join ' | ')"
            Write-Host "Phase: $($Result.current_phase_contract.name) [$($Result.current_phase_contract.permission)]"
            Write-Host "Owner: $($Result.current_phase_contract.owner.type):$($Result.current_phase_contract.owner.name)"
            Write-Host "Instructions: $($Result.current_phase_contract.instructions)"
            Write-Host "Required evidence: $(@($Result.current_phase_contract.required_evidence) -join ', ')"
            if (@($Result.missing_evidence).Count -gt 0) {
                Write-Host "Missing evidence: $(@($Result.missing_evidence) -join ', ')"
            }
        }
    }
}

function Test-WorkflowCatalog {
    param(
        [string]$RepoRoot,
        [object[]]$Catalog
    )

    $errors = @()
    $skillCatalogPath = Join-Path $RepoRoot "catalog\skills.tsv"
    $agentCatalogPath = Join-Path $RepoRoot "catalog\agents.tsv"
    $workflowDocsPath = Join-Path $RepoRoot "workflows"
    $skillNames = if (Test-Path -LiteralPath $skillCatalogPath -PathType Leaf) { @(Import-Csv -LiteralPath $skillCatalogPath -Delimiter "`t" | ForEach-Object { $_.name }) } else { @() }
    $agentRows = if (Test-Path -LiteralPath $agentCatalogPath -PathType Leaf) { @(Import-Csv -LiteralPath $agentCatalogPath -Delimiter "`t") } else { @() }
    $agentNames = @($agentRows | ForEach-Object { $_.name })
    $workflowFiles = if (Test-Path -LiteralPath $workflowDocsPath -PathType Container) { @(Get-ChildItem -LiteralPath $workflowDocsPath -Filter "*.md" -File | ForEach-Object { $_.BaseName }) } else { @() }
    $manifestDir = Join-Path $RepoRoot "skills\agentic-workflow-runtime\references\workflow-manifests"
    if (-not (Test-Path -LiteralPath $manifestDir -PathType Container)) {
        $manifestDir = Join-Path $RepoRoot "references\workflow-manifests"
    }
    $manifestFiles = @(Get-ChildItem -LiteralPath $manifestDir -Filter "*.json" -File | ForEach-Object { $_.BaseName })
    $seen = @{}
    $allowedMutation = @("read-only", "validation-only", "workspace-write", "external-mutation")
    $allowedOwnerType = @("main-agent", "skill", "subagent")
    $allowedMaturity = @("draft", "stable")
    $permissionRank = @{ "read-only" = 0; "validation-only" = 1; "workspace-write" = 2; "external-mutation" = 3 }

    $schemaPath = Join-Path (Split-Path -Parent $manifestDir) "workflow-manifest.schema.json"
    if (-not (Test-Path -LiteralPath $schemaPath -PathType Leaf)) {
        $errors += "Workflow manifest schema not found: $schemaPath"
    } else {
        try {
            $null = Get-Content -Raw -LiteralPath $schemaPath | ConvertFrom-Json
        } catch {
            $errors += "Workflow manifest schema is not valid JSON: $schemaPath"
        }
    }

    $portableCatalogPath = Join-Path $RepoRoot "skills\agentic-workflow-runtime\references\workflows.tsv"
    if (Test-Path -LiteralPath $portableCatalogPath -PathType Leaf) {
        $portableRows = @(Import-Csv -LiteralPath $portableCatalogPath -Delimiter "`t")
        if ($portableRows.Count -ne $Catalog.Count) {
            $errors += "Portable workflow catalog has $($portableRows.Count) rows; repository catalog has $($Catalog.Count)."
        }
        foreach ($row in $Catalog) {
            $portable = @($portableRows | Where-Object { $_.id -eq $row.id })
            if ($portable.Count -ne 1) {
                $errors += "Portable workflow catalog does not contain '$($row.id)' exactly once."
                continue
            }
            foreach ($field in @("label", "maturity", "mutation", "keywords", "description")) {
                if ($portable[0].$field -ne $row.$field) {
                    $errors += "Portable workflow '$($row.id)' differs from the repository catalog in '$field'."
                }
            }
            if ([System.IO.Path]::GetFileName($portable[0].manifest) -ne [System.IO.Path]::GetFileName($row.manifest)) {
                $errors += "Portable workflow '$($row.id)' points to a different manifest file."
            }
        }
    }

    foreach ($row in $Catalog) {
        if ([string]::IsNullOrWhiteSpace($row.id) -or $row.id -notmatch "^[a-z0-9]+(-[a-z0-9]+)*$") {
            $errors += "Invalid workflow id '$($row.id)'."
            continue
        }
        if ($seen.ContainsKey($row.id)) {
            $errors += "Duplicate workflow catalog row '$($row.id)'."
            continue
        }
        $seen[$row.id] = $true

        foreach ($field in @("label", "maturity", "mutation", "manifest", "keywords", "description")) {
            if ([string]::IsNullOrWhiteSpace($row.$field)) {
                $errors += "Workflow '$($row.id)' is missing catalog field '$field'."
            }
        }
        if ($allowedMaturity -notcontains $row.maturity) {
            $errors += "Workflow '$($row.id)' has invalid maturity '$($row.maturity)'."
        }

        if ($workflowFiles.Count -gt 0 -and $workflowFiles -notcontains $row.id) {
            $errors += "Workflow '$($row.id)' has no workflows/$($row.id).md document."
        }
        if ($allowedMutation -notcontains $row.mutation) {
            $errors += "Workflow '$($row.id)' has invalid catalog mutation '$($row.mutation)'."
        }

        try {
            $manifest = Read-WorkflowManifest -RepoRoot $RepoRoot -CatalogRow $row
            if ($manifest.schema_version -ne 1) {
                $errors += "Workflow '$($row.id)' must use schema_version 1."
            }
            if ($manifest.id -ne $row.id) {
                $errors += "Workflow '$($row.id)' manifest id is '$($manifest.id)'."
            }
            if ($manifest.mutation -ne $row.mutation) {
                $errors += "Workflow '$($row.id)' mutation differs between catalog and manifest."
            }
            foreach ($field in @("name", "description")) {
                if ([string]::IsNullOrWhiteSpace($manifest.$field)) {
                    $errors += "Workflow '$($row.id)' manifest is missing '$field'."
                }
            }
            if (@($manifest.phases).Count -eq 0) {
                $errors += "Workflow '$($row.id)' has no executable phases."
            }
            if (@($manifest.approval_boundaries).Count -eq 0) {
                $errors += "Workflow '$($row.id)' has no approval boundaries."
            }

            $phaseIds = @{}
            foreach ($phase in @($manifest.phases)) {
                if ([string]::IsNullOrWhiteSpace($phase.id) -or $phase.id -notmatch "^[a-z0-9]+(-[a-z0-9]+)*$") {
                    $errors += "Workflow '$($row.id)' has invalid phase id '$($phase.id)'."
                } elseif ($phaseIds.ContainsKey($phase.id)) {
                    $errors += "Workflow '$($row.id)' repeats phase '$($phase.id)'."
                } else {
                    $phaseIds[$phase.id] = $true
                }

                if ($allowedOwnerType -notcontains $phase.owner.type) {
                    $errors += "Workflow '$($row.id)' phase '$($phase.id)' has invalid owner type '$($phase.owner.type)'."
                } elseif ($phase.owner.type -eq "subagent" -and $agentNames.Count -gt 0 -and $agentNames -notcontains $phase.owner.name) {
                    $errors += "Workflow '$($row.id)' phase '$($phase.id)' references unknown subagent '$($phase.owner.name)'."
                } elseif ($phase.owner.type -in @("skill", "main-agent") -and $skillNames.Count -gt 0 -and $skillNames -notcontains $phase.owner.name) {
                    $errors += "Workflow '$($row.id)' phase '$($phase.id)' references unknown skill '$($phase.owner.name)'."
                }

                if ($allowedMutation -notcontains $phase.permission) {
                    $errors += "Workflow '$($row.id)' phase '$($phase.id)' has invalid permission '$($phase.permission)'."
                } elseif ($permissionRank[$phase.permission] -gt $permissionRank[$manifest.mutation]) {
                    $errors += "Workflow '$($row.id)' phase '$($phase.id)' exceeds workflow mutation '$($manifest.mutation)'."
                }
                if ($phase.owner.type -eq "subagent" -and $agentNames -contains $phase.owner.name) {
                    $agentPermission = @($agentRows | Where-Object { $_.name -eq $phase.owner.name })[0].permission
                    if ($phase.permission -ne $agentPermission) {
                        $errors += "Workflow '$($row.id)' phase '$($phase.id)' permission '$($phase.permission)' differs from subagent '$($phase.owner.name)' permission '$agentPermission'."
                    }
                }
                if (@($phase.required_evidence).Count -eq 0) {
                    $errors += "Workflow '$($row.id)' phase '$($phase.id)' has no required evidence."
                }
                if ($null -eq $phase.retry_limit -or $phase.retry_limit -lt 0 -or $phase.retry_limit -gt 5) {
                    $errors += "Workflow '$($row.id)' phase '$($phase.id)' has invalid retry_limit."
                }
                foreach ($field in @("name", "instructions", "output")) {
                    if ([string]::IsNullOrWhiteSpace($phase.$field)) {
                        $errors += "Workflow '$($row.id)' phase '$($phase.id)' is missing '$field'."
                    }
                }
            }
        } catch {
            $errors += $_.Exception.Message
        }
    }

    foreach ($workflowId in $workflowFiles) {
        if (-not $seen.ContainsKey($workflowId)) {
            $errors += "Workflow document '$workflowId' has no catalog row."
        }
    }
    foreach ($manifestId in $manifestFiles) {
        if (-not $seen.ContainsKey($manifestId)) {
            $errors += "Workflow manifest '$manifestId' has no catalog row."
        }
    }

    return [pscustomobject]@{
        valid = ($errors.Count -eq 0)
        workflow_count = $Catalog.Count
        manifest_count = $manifestFiles.Count
        errors = @($errors)
    }
}

try {
    $repoRoot = Get-RuntimeRoot
    $catalog = Read-WorkflowCatalog -RepoRoot $repoRoot

    switch ($Action) {
        "Validate" {
            $result = Test-WorkflowCatalog -RepoRoot $repoRoot -Catalog $catalog
            if (-not $result.valid) {
                throw "Workflow catalog validation failed:`n$($result.errors -join "`n")"
            }
            Write-Result -Result $result -TextSummary "[PASS] Validated $($result.workflow_count) executable workflow manifests."
            exit 0
        }

        "List" {
            $result = @($catalog | ForEach-Object {
                [pscustomobject]@{ id = $_.id; label = $_.label; mutation = $_.mutation; description = $_.description }
            })
            if ($OutputFormat -eq "Json") {
                $result | ConvertTo-Json -Depth 10
            } else {
                $result | Format-Table -AutoSize
            }
            exit 0
        }

        "Select" {
            $candidates = Get-WorkflowSelection -Catalog $catalog -TaskDescription $Task
            $result = [pscustomobject]@{
                task = $Task
                selected = if ($candidates.Count -gt 0 -and $candidates[0].score -gt 0) { $candidates[0].id } else { $null }
                needs_confirmation = ($candidates.Count -eq 0 -or $candidates[0].score -eq 0 -or ($candidates.Count -gt 1 -and $candidates[0].score -eq $candidates[1].score))
                candidates = @($candidates)
            }
            if ($OutputFormat -eq "Json") {
                $result | ConvertTo-Json -Depth 20
            } else {
                Write-Host "Selected: $($result.selected); confirmation required: $($result.needs_confirmation)"
                $candidates | Format-Table id, score, mutation, @{ Label = "matched"; Expression = { $_.matched_keywords -join ", " } } -AutoSize
            }
            exit 0
        }

        "Start" {
            if (-not [string]::IsNullOrWhiteSpace($Workflow) -and -not [string]::IsNullOrWhiteSpace($Task)) {
                throw "Specify either -Workflow or -Task when starting a run, not both."
            }
            if ([string]::IsNullOrWhiteSpace($Workflow)) {
                $candidates = Get-WorkflowSelection -Catalog $catalog -TaskDescription $Task
                if ($candidates.Count -eq 0 -or $candidates[0].score -eq 0) {
                    throw "No workflow matched the task. Run -Action Select and choose -Workflow explicitly."
                }
                if ($candidates.Count -gt 1 -and $candidates[0].score -eq $candidates[1].score) {
                    throw "Workflow selection is ambiguous between '$($candidates[0].id)' and '$($candidates[1].id)'. Choose -Workflow explicitly."
                }
                $Workflow = $candidates[0].id
            }
            if ([string]::IsNullOrWhiteSpace($Objective)) {
                $Objective = $Task
            }
            if ([string]::IsNullOrWhiteSpace($Objective)) {
                throw "-Objective is required when starting a workflow by id."
            }

            $row = Get-WorkflowRow -Catalog $catalog -WorkflowId $Workflow
            $manifest = Read-WorkflowManifest -RepoRoot $repoRoot -CatalogRow $row
            $effectiveProject = if ([string]::IsNullOrWhiteSpace($ProjectPath)) { (Get-Location).Path } else { [System.IO.Path]::GetFullPath($ProjectPath) }
            if (-not (Test-Path -LiteralPath $effectiveProject -PathType Container)) {
                throw "Project path not found: $effectiveProject"
            }
            $effectiveStateRoot = Resolve-StateRoot -RequestedRoot $StateRoot
            if (-not (Test-Path -LiteralPath $effectiveStateRoot -PathType Container)) {
                New-Item -ItemType Directory -Path $effectiveStateRoot -Force | Out-Null
            }

            $runId = "$Workflow-$((Get-Date).ToUniversalTime().ToString('yyyyMMddTHHmmssZ'))-$([guid]::NewGuid().ToString('N').Substring(0,8))"
            $statePath = Join-Path $effectiveStateRoot "$runId.json"
            $now = Get-UtcTimestamp
            $phaseStates = @($manifest.phases | ForEach-Object {
                [pscustomobject]@{
                    id = $_.id
                    status = if ($_.id -eq $manifest.phases[0].id) { "in-progress" } else { "pending" }
                    attempts = if ($_.id -eq $manifest.phases[0].id) { 1 } else { 0 }
                    evidence = @()
                }
            })
            $state = [pscustomobject]@{
                schema_version = 1
                run_id = $runId
                workflow_id = $Workflow
                objective = $Objective
                project_path = $effectiveProject
                status = "running"
                current_phase = $manifest.phases[0].id
                created_at = $now
                updated_at = $now
                revision = 0
                workflow_manifest = $manifest
                phases = $phaseStates
                blockers = @()
                history = @([pscustomobject]@{ at = $now; event = "started"; phase = $manifest.phases[0].id; detail = "Workflow run started." })
            }
            Save-RunState -State $state -Path $statePath
            $result = Get-RunSummary -State $state -Manifest $manifest -Path $statePath
            Write-Result -Result $result -TextSummary "Started workflow '$Workflow'. Run state: $statePath"
            exit 0
        }

        { $_ -in @("Status", "Record", "Advance", "Retry", "Escalate", "Resume", "Handoff") } {
            $loaded = Read-RunState -Path $RunPath
            $state = $loaded.State
            $statePath = $loaded.Path
            if ($state.PSObject.Properties["workflow_manifest"]) {
                $manifest = $state.workflow_manifest
            } else {
                $row = Get-WorkflowRow -Catalog $catalog -WorkflowId $state.workflow_id
                $manifest = Read-WorkflowManifest -RepoRoot $repoRoot -CatalogRow $row
            }

            if ($Action -eq "Status") {
                $result = Get-RunSummary -State $state -Manifest $manifest -Path $statePath
                Write-Result -Result $result -TextSummary "Workflow '$($state.workflow_id)' is $($state.status)."
                exit 0
            }

            if ($Action -eq "Record") {
                if ($state.status -ne "running") {
                    throw "Evidence can only be recorded while a run is running; current status is '$($state.status)'."
                }
                if ([string]::IsNullOrWhiteSpace($EvidenceName) -or $EvidenceName -notmatch "^[a-z0-9]+(-[a-z0-9]+)*$") {
                    throw "-EvidenceName must use lowercase kebab-case."
                }
                if ([string]::IsNullOrWhiteSpace($EvidenceValue)) {
                    throw "-EvidenceValue must not be empty."
                }
                $phase = @($state.phases | Where-Object { $_.id -eq $state.current_phase })[0]
                $entry = [pscustomobject]@{ name = $EvidenceName; value = $EvidenceValue; recorded_at = Get-UtcTimestamp }
                $phase.evidence = @($phase.evidence | Where-Object { $_.name -ne $EvidenceName }) + $entry
                Add-HistoryEvent -State $state -Event "evidence-recorded" -Phase $state.current_phase -Detail $EvidenceName
                Save-RunState -State $state -Path $statePath
                $result = Get-RunSummary -State $state -Manifest $manifest -Path $statePath
                Write-Result -Result $result -TextSummary "Recorded '$EvidenceName' for phase '$($state.current_phase)'."
                exit 0
            }

            if ($Action -eq "Advance") {
                if ($state.status -ne "running") {
                    throw "Only a running workflow can advance; current status is '$($state.status)'."
                }
                $index = Get-PhaseIndex -Manifest $manifest -PhaseId $state.current_phase
                $manifestPhase = $manifest.phases[$index]
                $statePhase = @($state.phases | Where-Object { $_.id -eq $state.current_phase })[0]
                $recorded = @($statePhase.evidence | ForEach-Object { $_.name })
                $missing = @($manifestPhase.required_evidence | Where-Object { $recorded -notcontains $_ })
                if ($missing.Count -gt 0) {
                    throw "Cannot advance phase '$($state.current_phase)'; missing evidence: $($missing -join ', ')."
                }

                $completedPhase = $state.current_phase
                $statePhase.status = "completed"
                Add-HistoryEvent -State $state -Event "phase-completed" -Phase $completedPhase -Detail $manifestPhase.output
                if ($index -eq ($manifest.phases.Count - 1)) {
                    $state.status = "completed"
                    $state.current_phase = $null
                    Add-HistoryEvent -State $state -Event "workflow-completed" -Phase $completedPhase -Detail "All workflow gates passed."
                } else {
                    $nextPhase = $manifest.phases[$index + 1]
                    $nextState = @($state.phases | Where-Object { $_.id -eq $nextPhase.id })[0]
                    $nextState.status = "in-progress"
                    $nextState.attempts = 1
                    $state.current_phase = $nextPhase.id
                    Add-HistoryEvent -State $state -Event "phase-started" -Phase $nextPhase.id -Detail $nextPhase.instructions
                }
                Save-RunState -State $state -Path $statePath
                $result = Get-RunSummary -State $state -Manifest $manifest -Path $statePath
                Write-Result -Result $result -TextSummary "Advanced workflow '$($state.workflow_id)' to '$($state.current_phase)'."
                exit 0
            }

            if ($Action -eq "Retry") {
                if ($state.status -ne "running") {
                    throw "Only a running workflow phase can retry."
                }
                if ([string]::IsNullOrWhiteSpace($Reason)) {
                    throw "-Reason is required when retrying a phase."
                }
                $index = Get-PhaseIndex -Manifest $manifest -PhaseId $state.current_phase
                $manifestPhase = $manifest.phases[$index]
                $statePhase = @($state.phases | Where-Object { $_.id -eq $state.current_phase })[0]
                if ($statePhase.attempts -ge (1 + $manifestPhase.retry_limit)) {
                    throw "Retry limit reached for phase '$($state.current_phase)'. Escalate with the blocking evidence."
                }
                $statePhase.attempts++
                if (-not $PreserveEvidence) {
                    $statePhase.evidence = @()
                }
                Add-HistoryEvent -State $state -Event "phase-retried" -Phase $state.current_phase -Detail $Reason
                Save-RunState -State $state -Path $statePath
                $result = Get-RunSummary -State $state -Manifest $manifest -Path $statePath
                Write-Result -Result $result -TextSummary "Retrying phase '$($state.current_phase)' (attempt $($statePhase.attempts))."
                exit 0
            }

            if ($Action -eq "Escalate") {
                if ($state.status -ne "running") {
                    throw "Only a running workflow can be escalated."
                }
                if ([string]::IsNullOrWhiteSpace($Reason)) {
                    throw "-Reason is required when escalating."
                }
                $blocker = [pscustomobject]@{ phase = $state.current_phase; reason = $Reason; created_at = Get-UtcTimestamp; resolution = $null; resolved_at = $null }
                $state.blockers = @($state.blockers) + $blocker
                $state.status = "awaiting-input"
                Add-HistoryEvent -State $state -Event "escalated" -Phase $state.current_phase -Detail $Reason
                Save-RunState -State $state -Path $statePath
                $result = Get-RunSummary -State $state -Manifest $manifest -Path $statePath
                Write-Result -Result $result -TextSummary "Workflow paused for input: $Reason"
                exit 0
            }

            if ($Action -eq "Resume") {
                if ($state.status -ne "awaiting-input") {
                    throw "Only a workflow awaiting input can resume; current status is '$($state.status)'."
                }
                if ([string]::IsNullOrWhiteSpace($Resolution)) {
                    throw "-Resolution is required when resuming."
                }
                $open = @($state.blockers | Where-Object { [string]::IsNullOrWhiteSpace($_.resolution) })
                if ($open.Count -gt 0) {
                    $open[$open.Count - 1].resolution = $Resolution
                    $open[$open.Count - 1].resolved_at = Get-UtcTimestamp
                }
                $state.status = "running"
                Add-HistoryEvent -State $state -Event "resumed" -Phase $state.current_phase -Detail $Resolution
                Save-RunState -State $state -Path $statePath
                $result = Get-RunSummary -State $state -Manifest $manifest -Path $statePath
                Write-Result -Result $result -TextSummary "Resumed workflow at phase '$($state.current_phase)'."
                exit 0
            }

            if ($Action -eq "Handoff") {
                $summary = Get-RunSummary -State $state -Manifest $manifest -Path $statePath
                $handoffPath = [System.IO.Path]::ChangeExtension($statePath, ".handoff.md")
                $completed = @($state.phases | Where-Object { $_.status -eq "completed" } | ForEach-Object { $_.id })
                $pending = @($state.phases | Where-Object { $_.status -ne "completed" } | ForEach-Object { "$($_.id) [$($_.status)]" })
                $evidenceLines = @()
                foreach ($phase in $state.phases) {
                    foreach ($evidence in @($phase.evidence)) {
                        $evidenceLines += "- ``$($phase.id)/$($evidence.name)``: $($evidence.value)"
                    }
                }
                if ($evidenceLines.Count -eq 0) { $evidenceLines = @("- None recorded.") }
                $blockerLines = @($state.blockers | ForEach-Object {
                    if ([string]::IsNullOrWhiteSpace($_.resolution)) { "- OPEN [$($_.phase)]: $($_.reason)" } else { "- RESOLVED [$($_.phase)]: $($_.reason) - $($_.resolution)" }
                })
                if ($blockerLines.Count -eq 0) { $blockerLines = @("- None recorded.") }
                $nextAction = if ($state.status -eq "completed") {
                    "Review the completed workflow evidence and perform any separately authorized external action."
                } elseif ($state.status -eq "awaiting-input") {
                    "Resolve the open blocker, then resume this run."
                } else {
                    "Complete phase ``$($state.current_phase)``: $($summary.current_phase_contract.instructions)"
                }
                $lines = @(
                    "# Agent Workflow Handoff",
                    "",
                    "- Run: ``$($state.run_id)``",
                    "- State: ``$statePath``",
                    "- Workflow: ``$($state.workflow_id)``",
                    "- Status: ``$($state.status)``",
                    "- Project: ``$($state.project_path)``",
                    "",
                    "## Goal",
                    "",
                    $state.objective,
                    "",
                    "## Current State",
                    "",
                    "- Current phase: ``$($state.current_phase)``",
                    "- Completed phases: $($completed -join ', ')",
                    "- Pending phases: $($pending -join ', ')",
                    "",
                    "## Evidence",
                    ""
                ) + $evidenceLines + @(
                    "",
                    "## Blockers And Decisions",
                    ""
                ) + $blockerLines + @(
                    "",
                    "## Risks",
                    "",
                    "- Review phase evidence and workflow approval boundaries before mutation.",
                    "",
                    "## Exact Next Action",
                    "",
                    $nextAction
                )
                Set-Content -LiteralPath $handoffPath -Value $lines -Encoding UTF8
                $result = [pscustomobject]@{ run_id = $state.run_id; status = $state.status; handoff_path = $handoffPath; next_action = $nextAction }
                Write-Result -Result $result -TextSummary "Wrote workflow handoff: $handoffPath"
                exit 0
            }
        }
    }
} catch {
    $message = $_.Exception.Message
    if ($OutputFormat -eq "Json") {
        $errorJson = [pscustomobject]@{ error = $message; action = $Action } | ConvertTo-Json -Compress
        [Console]::Error.WriteLine($errorJson)
    } else {
        [Console]::Error.WriteLine("[ERROR] $message")
    }
    exit 1
}
