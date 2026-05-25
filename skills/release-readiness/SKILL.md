---
name: release-readiness
description: Assess whether software changes are ready to release by checking scope, validation, versioning, changelogs, migrations, compatibility, rollback, documentation, and known risks. Use before publishing, deploying, tagging, or handing off a release candidate.
---

# Release Readiness

## Purpose

Produce a release-ready assessment that identifies validation status, blocking risks, and required follow-up before deployment or publication.

## When to Use

- Use before a release, deploy, tag, package publish, or production handoff.
- Use when a change includes migrations, config changes, dependency updates, or public contract changes.
- Use when the user asks for a release checklist or go/no-go assessment.
- Use when final validation evidence must be collected across several areas.

## When Not to Use

- Do not use during early feature design unless release constraints drive the design.
- Do not replace security review for high-risk security surfaces.
- Do not mark a release ready when validation is missing or blocked.

## Required Inputs

- Release scope, changed files, commits, or candidate branch.
- Required test, lint, build, packaging, and deployment checks.
- Versioning, changelog, migration, rollback, and compatibility requirements.
- Known incidents, feature flags, config changes, or operational notes.
- Windows-first commands for local checks and Linux alternatives where useful.

## Workflow

1. Define the release candidate and included scope.
2. Inspect changes for public contracts, migrations, dependencies, config, and docs.
3. Run or review required tests, lint, build, and packaging checks.
4. Verify versioning, changelog, release notes, and documentation updates.
5. Check rollback, migration safety, feature flags, and operational readiness.
6. Identify blockers, non-blocking risks, and owner-needed decisions.
7. Produce a go/no-go recommendation with evidence.

## Quality Gates

- Release scope is explicit.
- Required validation checks are complete or clearly blocked.
- Versioning and changelog state match the release type.
- Rollback and migration risks are understood.
- The final recommendation separates blockers from residual risk.

## Anti-Patterns

- Treating a passing unit test as full release readiness.
- Ignoring documentation, config, migration, or rollback impacts.
- Hiding skipped validation in a summary.
- Adding last-minute unrelated changes during readiness review.
- Giving a go recommendation without evidence.

## Output Format

```markdown
Release Readiness:
- Candidate:
- Recommendation:
- Blockers:
- Non-blocking risks:

Validation:
- 

Release Notes:
- 

Rollback Or Migration Notes:
- 
```

## References

- `references/release-readiness-checklist.md`: Use when preparing a final go/no-go release assessment or checking release evidence.
