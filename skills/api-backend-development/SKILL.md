---
name: api-backend-development
description: Build or modify backend services, APIs, endpoints, handlers, service logic, and server-side contracts. Use when an agent needs to implement request handling, validation, authorization hooks, domain services, background jobs, API tests, or backend integration behavior without assuming a specific framework.
---

# API Backend Development

## Purpose

Implement backend behavior through clear contracts, scoped service changes, and executable verification.

## When to Use

- Use when adding or changing endpoints, handlers, controllers, resolvers, jobs, or service methods.
- Use when request validation, response shape, status codes, authorization checks, or error handling change.
- Use when backend behavior must coordinate persistence, external services, or domain logic.
- Use when API tests or contract checks are needed for server-side work.

## When Not to Use

- Do not use for frontend-only changes.
- Do not use for database schema design alone; use a data workflow skill for migrations and data movement.
- Do not use for security-sensitive review as the primary workflow; use security review when threat assessment is needed.

## Required Inputs

- Requested backend behavior and acceptance criteria.
- Relevant route, handler, service, model, schema, and test files.
- API contract details: request shape, response shape, errors, status codes, and compatibility constraints.
- Auth, permission, idempotency, and side-effect requirements.
- Focused test or run commands, Windows-first with Linux alternatives where useful.

## Workflow

1. Locate the existing backend entry point and the closest similar implementation.
2. Trace request flow through validation, auth, domain logic, persistence, and response mapping.
3. Confirm the contract and backward-compatibility expectations before editing.
4. Add or update focused tests for success, failure, auth, and edge cases.
5. Implement the smallest backend change that satisfies the contract.
6. Keep validation, domain logic, persistence, and presentation responsibilities aligned with local patterns.
7. Run targeted backend tests and broader checks when shared code changes.
8. Report changed contract behavior, validation run, and compatibility risks.

## Quality Gates

- Request and response behavior is explicit and tested where practical.
- Error handling is deterministic and does not leak sensitive internals.
- Authorization and permission expectations are preserved or updated intentionally.
- Side effects are idempotent or documented when retry behavior matters.
- Shared service changes are covered by affected tests.

## Anti-Patterns

- Adding endpoint logic without tracing the full request path.
- Returning inconsistent error shapes or status semantics.
- Bypassing existing validation, auth, service, or repository layers.
- Mixing unrelated backend cleanup into the feature change.
- Assuming framework defaults are sufficient without checking local conventions.

## Output Format

```markdown
Backend Result:
- Contract:
- Implementation:
- Edge cases:

Changed Files:
- 

Validation:
- 

Compatibility Risks:
- 
```

## References

No bundled references are required. Add framework-specific backend patterns to `references/` only if repeated use justifies them.
