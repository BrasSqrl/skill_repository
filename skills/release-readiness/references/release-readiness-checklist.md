# Release Readiness Checklist

Use this reference for a final go/no-go release assessment.

## Scope

- Candidate branch, commit, tag, or package version is identified.
- Included changes match the intended release scope.
- Unrelated local changes are excluded or explained.

## Validation Evidence

- Tests: command and result.
- Lint or static checks: command and result.
- Build or package: command and result.
- Migration or data checks: command and result when relevant.
- Manual verification: exact flow checked when automated coverage is insufficient.

## Release Artifacts

- Version number or tag is correct.
- Changelog or release notes match the diff.
- Documentation changed when behavior changed.
- Config, feature flags, or deployment notes are captured.

## Risk Review

- Rollback path is known.
- Migration or data changes are reversible or explicitly approved.
- Dependency and environment changes are called out.
- Security-sensitive changes received review.
- Known issues are separated from blockers.

## Recommendation Values

- Go: required checks passed and no blockers remain.
- No-go: at least one blocker remains.
- Conditional go: explicit owner decision or external condition is required.
