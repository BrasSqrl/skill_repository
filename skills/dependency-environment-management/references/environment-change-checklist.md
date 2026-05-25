# Environment Change Checklist

Use this reference when dependency, runtime, or setup changes may affect reproducibility.

## Before Changing

- Identify package manager and lockfile policy.
- Record current runtime versions.
- Inspect setup docs and CI configuration.
- Confirm whether Windows and Linux use the same commands.
- Check whether the requested change is targeted or broad.

## Safe Change Rules

- Use one package manager per change.
- Keep manifest and lockfile in sync.
- Prefer targeted upgrades or pins.
- Avoid deleting lockfiles as a first fix.
- Record native, path, or shell-specific behavior.

## Useful Command Shapes

Windows:

```powershell
Get-Command node, python, git -ErrorAction SilentlyContinue
```

Linux:

```bash
command -v node python git
```

Use project-specific install, test, and build commands from repository docs instead of inventing new ones.

## Risk Flags

- Runtime major version changes.
- Package manager switch.
- Lockfile churn unrelated to the target dependency.
- Native modules or compiled extensions.
- Security-sensitive dependency updates.
- CI config differs from local setup.
