# Runtime Command Reference

## Contents

- Selecting and starting
- Executing a phase
- Retry and escalation
- Handoff and recovery
- State storage
- Manifest authoring

## Selecting And Starting

From the skill directory:

```powershell
.\scripts\run-agent-workflow.ps1 -Action Validate
.\scripts\run-agent-workflow.ps1 -Action List
.\scripts\run-agent-workflow.ps1 -Action Select -Task "Implement a tested API feature"
$TargetRepo = "<target-repo>"
.\scripts\run-agent-workflow.ps1 -Action Start -Workflow feature-quality-loop -Objective "Add export support" -ProjectPath $TargetRepo
```

The selector uses explicit routing keywords and returns ranked candidates. It does not infer authorization. `Start -Task` starts automatically only when the highest score is positive and unambiguous.

Use the repository launcher when working from this source repository:

```powershell
.\scripts\run-agent-workflow.ps1 -Action List
```

Linux with PowerShell 7:

```bash
bash ./scripts/run-agent-workflow.sh -Action List
```

## Executing A Phase

Inspect the active contract:

```powershell
$RunPath = "<run-state-path>"
.\scripts\run-agent-workflow.ps1 -Action Status -RunPath $RunPath
```

Perform only the displayed phase. Then record each required evidence item:

```powershell
.\scripts\run-agent-workflow.ps1 -Action Record -RunPath $RunPath -EvidenceName source-files -EvidenceValue "src/export.ps1; tests/export.tests.ps1"
.\scripts\run-agent-workflow.ps1 -Action Record -RunPath $RunPath -EvidenceName acceptance-criteria -EvidenceValue "Exports active records as UTF-8 CSV"
.\scripts\run-agent-workflow.ps1 -Action Advance -RunPath $RunPath
```

`Advance` fails without changing phase state when any required evidence is missing.

Evidence values should identify artifacts, commands, exit codes, decisions, or short conclusions. Never store secrets or large raw logs. Store the durable artifact elsewhere and record its safe path or summary.

## Retry And Escalation

Retry only when new evidence or a narrower approach can change the outcome:

```powershell
.\scripts\run-agent-workflow.ps1 -Action Retry -RunPath $RunPath -Reason "Fixture setup caused the first validation failure"
```

Retry clears current-phase evidence unless `-PreserveEvidence` is supplied. The manifest limits retries.

Pause when a user decision, permission, credential, or contradictory source blocks work:

```powershell
.\scripts\run-agent-workflow.ps1 -Action Escalate -RunPath $RunPath -Reason "Public response compatibility requires a product decision"
.\scripts\run-agent-workflow.ps1 -Action Resume -RunPath $RunPath -Resolution "Preserve the existing response and add a new optional field"
```

## Handoff And Recovery

Generate a Markdown checkpoint beside the run-state file:

```powershell
.\scripts\run-agent-workflow.ps1 -Action Handoff -RunPath $RunPath
```

Resume from another session by opening the handoff, then running `Status` against the recorded run path. The state contains a snapshot of the selected manifest, phase status, attempts, evidence, resolved and open blockers, and event history. Existing runs therefore keep their original contract after catalog updates.

## State Storage

By default, run state is stored under the operating system's local application-data directory in `agent-workflow-runs`. Use `-StateRoot` for an explicit external location. Do not commit run state by default because it may contain repository paths and operational evidence.

The runtime modifies only its state and handoff files. A workflow phase may authorize workspace or external changes, but the runtime never performs those phase actions itself.

## Manifest Authoring

Add one catalog row and one JSON manifest for each workflow document. Keep both the source-repository catalog and the installed-skill routing catalog aligned.

Every phase must declare:

- stable lowercase kebab-case `id`
- human-readable `name`
- owner type and name
- permission boundary
- imperative instructions
- checkable output
- one or more required evidence keys
- bounded retry limit

Use evidence keys for observable facts, not subjective completion claims. Examples include `validation-command`, `validation-exit-code`, `review-findings`, `rollback-plan`, and `authorization-evidence`.

Run:

```powershell
.\scripts\run-agent-workflow.ps1 -Action Validate
.\scripts\test-workflow-runner.ps1
.\scripts\validate-skills.ps1
```
