@echo off
setlocal

rem Double-click installer for Windows users.
rem Launches an interactive PowerShell menu to choose Codex, Claude Code,
rem or OpenCode, then install selected skills and optional subagents.

set "REPO_DIR=%~dp0"
set "INTERACTIVE_SCRIPT=%REPO_DIR%scripts\install-skills-interactive.ps1"

if not exist "%INTERACTIVE_SCRIPT%" (
    echo [ERROR] Could not find interactive installer:
    echo %INTERACTIVE_SCRIPT%
    echo.
    pause
    exit /b 1
)

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%INTERACTIVE_SCRIPT%"
set "EXIT_CODE=%ERRORLEVEL%"

echo.
if "%EXIT_CODE%"=="0" (
    echo [OK] Installer finished.
) else (
    echo [ERROR] Installer failed or was cancelled with exit code %EXIT_CODE%.
)

echo.
pause
exit /b %EXIT_CODE%
