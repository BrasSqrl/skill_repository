# Pull Request Review Workflow

## Trigger

Use when reviewing a diff, branch, pull request, patch set, or pending merge package.

## Ordered Skills

1. `context-engineering`
2. `code-review-and-quality`
3. `security-review` when auth, secrets, input handling, data access, dependencies, or permissions are touched
4. `architecture-review` when boundaries, cross-cutting design, or major dependencies change
5. `pull-request-prep`

## Phase Outputs

- Change scope summary.
- Findings ordered by severity with file and line references.
- Missing validation or test gaps.
- Merge readiness recommendation.

## Validation Gates

- Findings describe concrete failure modes, not style preferences.
- Each blocking issue includes reproduction or reasoning from source context.
- Security and architecture concerns are clearly separated from ordinary maintainability notes.
- The final summary does not hide open risks.

## Handoff Format

List findings first, then open questions, validation reviewed, and concise change summary.

## Escalation Rules

- Ask for target branch or diff source if not discoverable.
- Escalate if a finding depends on policy or risk tolerance outside the repo.
- Do not rewrite the implementation unless explicitly asked after review.
