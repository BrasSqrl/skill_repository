---
name: zoom-out
description: Produce a higher-level map of unfamiliar code, modules, callers, and context before continuing detailed work. Use when the user asks to zoom out, wants broader context, or needs to understand how a local code area fits into the larger system.
---

# Zoom Out

## Purpose

Give the user or agent a broader technical map of the relevant system area without starting implementation.

## When to Use

- Use when the user asks to zoom out.
- Use when a code area is unfamiliar and local details are hard to interpret.
- Use before planning or debugging when caller relationships are unclear.

## When Not to Use

- Do not use for full repo onboarding.
- Do not use when task-specific context is already sufficient.
- Do not implement changes during the zoom-out pass.

## Required Inputs

- Starting file, module, feature, error, or concept.
- Repository source context.
- Domain glossary or architecture docs if present.
- User's question about the broader system.

## Workflow

1. Identify the focal area and the level of abstraction needed.
2. Inspect callers, callees, neighboring modules, docs, tests, and data flow.
3. Map responsibilities and relationships in plain technical language.
4. Use project domain vocabulary when available.
5. Highlight the most relevant files for the next deeper pass.
6. State what remains unknown.

## Quality Gates

- The map includes concrete files or modules.
- Relationships are based on inspected source.
- The output stays higher-level than implementation details.
- Unknowns and assumptions are labeled.

## Anti-Patterns

- Replacing source inspection with guesses.
- Producing a broad repo summary when the user asked about one area.
- Diving into code edits.
- Hiding uncertainty.

## Output Format

```markdown
Zoom-Out Map:
- Focal area:
- Main responsibilities:
- Key modules:
- Callers and callees:
- Data flow:
- Tests or docs:
- Unknowns:
- Recommended next focus:
```

## References

No bundled references are required.
