<#
.SYNOPSIS
Launch the agentic workflow runtime bundled with its skill.
#>

$runtime = Join-Path $PSScriptRoot "..\skills\agentic-workflow-runtime\scripts\run-agent-workflow.ps1"
& $runtime @args
exit $LASTEXITCODE
