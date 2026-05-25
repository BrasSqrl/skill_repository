---
name: security-review
description: Review software changes or designs for security risks including authentication, authorization, secrets, input handling, dependency exposure, logging, data access, and unsafe defaults. Use for security-sensitive code, pre-release checks, or explicit security review requests.
---

# Security Review

## Purpose

Identify concrete security risks and recommend scoped mitigations grounded in the inspected code, configuration, and data flows.

## When to Use

- Use when the user asks for a security review or threat-focused assessment.
- Use when code touches auth, permissions, secrets, cryptography, file access, network calls, user input, payments, or sensitive data.
- Use before release for high-risk changes.
- Use when dependency or configuration changes may affect exposure.

## When Not to Use

- Do not use for general code quality review unless security risk is material.
- Do not provide exploit instructions beyond what is needed to explain defensive impact.
- Do not claim security approval without inspecting relevant code paths and configuration.

## Required Inputs

- Changed files, design, endpoint, data flow, or configuration under review.
- Trust boundaries, actors, roles, and data sensitivity when known.
- Authentication and authorization paths.
- Dependency and environment changes.
- Relevant validation commands or checks, Windows-first with Linux alternatives where useful.

## Workflow

1. Define the reviewed surface and trust boundaries.
2. Identify assets, actors, entry points, and privileged operations.
3. Inspect authentication, authorization, session, and permission checks.
4. Inspect input validation, parsing, encoding, file handling, and output escaping.
5. Inspect secret handling, logging, error messages, and data retention.
6. Inspect dependency, configuration, transport, and deployment exposure.
7. Rank findings by impact, exploitability, and confidence.
8. Recommend minimal mitigations and verification steps.

## Quality Gates

- Each finding is tied to a concrete code path, config, or design element.
- Severity includes impact and confidence.
- Mitigations are specific and testable.
- False positives and assumptions are labeled.
- Sensitive details are handled defensively.

## Anti-Patterns

- Producing a generic security checklist without inspected evidence.
- Treating absence of evidence as proof of safety.
- Ignoring authorization because authentication exists.
- Recommending broad rewrites when a scoped mitigation works.
- Logging or exposing secrets while investigating.

## Output Format

```markdown
Security Findings:
- Severity:
  Confidence:
  Surface:
  Risk:
  Recommendation:
  Verification:

Assumptions:
- 

Reviewed Scope:
- 
```

## References

- `references/security-review-rubric.md`: Use when ranking security findings or checking common defensive review surfaces.
