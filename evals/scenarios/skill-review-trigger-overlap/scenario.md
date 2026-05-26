# Skill Review Trigger Overlap Scenario

## Objective

Check that `skill-review` identifies weak trigger language, duplicate responsibilities, missing gates, and metadata problems in a proposed skill.

## Target

- Type: `skill`
- Name: `skill-review`
- Capability: `skill quality`

## Inputs

Proposed skill frontmatter:

```yaml
---
name: better-coding
description: Helps agents write better code.
---
```

Body summary:

- no `When Not to Use`
- no output format
- overlaps with `incremental-implementation` and `code-review-and-quality`
- no catalog row yet

## Setup

Windows:

```powershell
No commands required
```

Linux:

```bash
No commands required
```

## Expected Behavior

- Return a revise or reject decision.
- Identify the description as too vague to trigger correctly.
- Name the overlapping existing skills.
- Require concrete workflow, gates, output format, and catalog metadata.

## Pass Criteria

- The review does not approve the skill.
- Required edits are concrete.
- Overlap is tied to existing skill names.
- Metadata and validation gaps are included.

## Failure Signals

- The response approves the skill because the topic is useful.
- The response gives generic writing advice without required edits.
- Existing skill overlap is ignored.

## Artifacts

- Skill review report.

## Review Notes

- Use this scenario when tightening authoring rules or scoring logic.
