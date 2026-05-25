# Security Review Rubric

Use this reference to rank concrete security findings and avoid generic checklist output.

## Review Surfaces

- Authentication: identity proof, session handling, token validation.
- Authorization: object-level and action-level permission checks.
- Input handling: parsing, validation, normalization, encoding.
- Output handling: escaping, error messages, data exposure.
- Secrets: storage, logs, config, generated artifacts, test fixtures.
- Data access: tenant boundaries, sensitive fields, retention.
- Dependencies: vulnerable packages, unsafe defaults, supply chain risk.
- Transport and config: TLS, CORS, cookies, debug flags, admin surfaces.

## Severity Guide

| Severity | Use when |
|---|---|
| Critical | Direct unauthorized access, secret exposure, or remote code execution is likely. |
| High | Sensitive data, privileged action, or broad account impact is plausible. |
| Medium | Exploit requires constraints but impact is meaningful. |
| Low | Hard to exploit, limited impact, or defense-in-depth gap. |

## Finding Shape

```markdown
Severity:
Confidence:
Surface:
Evidence:
Impact:
Recommendation:
Verification:
```

## Common False Positives

- A missing check in one layer when an enforced lower layer guarantees it.
- Test-only secrets that cannot reach production.
- Internal-only endpoints that still have external exposure through deployment config.
- Sanitization that happens in a shared framework path not visible in the local diff.
