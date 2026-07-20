#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

RUNTIME_PATH="$SCRIPT_DIR/run-agent-workflow.ps1"

if command -v pwsh >/dev/null 2>&1; then
    exec pwsh -NoLogo -NoProfile -File "$RUNTIME_PATH" "$@"
fi

if command -v powershell.exe >/dev/null 2>&1 && command -v wslpath >/dev/null 2>&1; then
    WINDOWS_RUNTIME_PATH="$(wslpath -w "$RUNTIME_PATH")"
    exec powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "$WINDOWS_RUNTIME_PATH" "$@"
fi

echo "[ERROR] PowerShell 7 (pwsh) is required on Linux; WSL may also use Windows PowerShell through powershell.exe and wslpath." >&2
exit 1
