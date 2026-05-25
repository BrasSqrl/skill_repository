# Agent Instructions

Copy this file into a target software repository as `AGENTS.md`, then replace bracketed placeholders with project-specific guidance.

## Project Overview

`<Describe what this project does, who uses it, and the primary runtime or platform.>`

## Setup Commands

Windows:

```powershell
<setup command>
```

Linux:

```bash
<setup command>
```

## Test Commands

Windows:

```powershell
<test command>
```

Linux:

```bash
<test command>
```

## Lint Commands

Windows:

```powershell
<lint command>
```

Linux:

```bash
<lint command>
```

## Build Commands

Windows:

```powershell
<build command>
```

Linux:

```bash
<build command>
```

## Coding Standards

- `<language and formatting standards>`
- `<naming conventions>`
- `<error handling expectations>`
- `<test coverage expectations>`

## Architecture Notes

- `<major modules and responsibilities>`
- `<important boundaries or layering rules>`
- `<integration points and external systems>`

## Important Directories

- `<path>/`: `<purpose>`
- `<path>/`: `<purpose>`
- `<path>/`: `<purpose>`

## Forbidden Changes

- `<files, directories, generated artifacts, or workflows agents must not edit>`
- `<changes requiring explicit human approval>`
- `<risky operations agents must avoid>`

## Secrets And Security Rules

- Never commit secrets, credentials, tokens, private keys, or local environment files.
- `<secret storage conventions>`
- `<security-sensitive areas of the codebase>`
- `<required security checks for changes>`

## Agent Workflow

1. Inspect the relevant source files before making changes.
2. Keep changes small and scoped to the request.
3. Prefer existing project patterns over new abstractions.
4. Run the relevant tests, lint checks, and build commands.
5. Report changed files, validation results, and unresolved risks.

## Validation Checklist

- `<setup command completed, or was not required>`
- `<tests passed, or skipped with a stated reason>`
- `<lint passed, or skipped with a stated reason>`
- `<build passed, or skipped with a stated reason>`
- `<security-sensitive changes were reviewed>`
- `<documentation was updated when behavior changed>`
