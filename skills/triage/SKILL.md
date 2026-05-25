---
name: triage
description: Triage bugs, feature requests, and issue tracker work through a small state machine of labels and agent-ready outcomes. Use when the user wants to create an issue, review incoming reports, classify issues, request missing information, or prepare work for an implementation agent.
---

# Triage

## Purpose

Move issues through clear triage states, preserving user-facing notes and producing agent-ready briefs when work is ready.

## When to Use

- Use when the user asks to triage issues.
- Use when reviewing incoming bugs or feature requests.
- Use when preparing an issue for an AFK implementation agent.
- Use when deciding whether an issue needs information, human judgment, or agent work.

## When Not to Use

- Do not use without issue tracker and label vocabulary setup.
- Do not apply labels or post comments without confirming intended changes.
- Do not reproduce or implement fixes beyond triage scope unless asked.

## Required Inputs

- Issue tracker location and label mapping.
- Issue body, comments, current labels, and reporter context.
- Repository context relevant to the report.
- Permission before posting comments, changing labels, or closing issues.

## Workflow

1. Load issue tracker and triage label setup.
2. Gather the full issue, comments, labels, reporter, and prior triage notes.
3. Classify category: bug or enhancement.
4. Recommend state: needs-triage, needs-info, ready-for-agent, ready-for-human, or wontfix.
5. For bugs, attempt reproduction when practical before recommending ready-for-agent.
6. Ask clarifying questions or use `grill-with-docs` when the issue needs refinement.
7. Confirm the intended label/comment/close action with the user.
8. Post triage notes, agent brief, or out-of-scope record as appropriate.

## Quality Gates

- Every issue has one category and one state recommendation.
- Reporter questions are specific and actionable.
- Ready-for-agent issues include a durable brief.
- Wontfix enhancements are recorded when useful to avoid repeated requests.
- All tracker mutations are confirmed before execution.

## Anti-Patterns

- Re-asking questions already answered in prior comments.
- Applying conflicting state labels.
- Posting vague needs-info comments.
- Treating issue triage as implementation.
- Omitting AI-generated triage disclosure when posting externally.

## Output Format

```markdown
Triage Recommendation:
- Issue:
- Category:
- State:
- Reason:
- Reproduction:
- Proposed action:

Draft Comment:
- 
```

## References

- `references/AGENT-BRIEF.md`: Use when preparing ready-for-agent or ready-for-human issue notes.
- `references/OUT-OF-SCOPE.md`: Use when recording rejected or repeated enhancement requests.
