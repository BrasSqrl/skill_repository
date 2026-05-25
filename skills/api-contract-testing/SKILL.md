---
name: api-contract-testing
description: Verify API contracts, schemas, backward compatibility, and consumer-provider expectations. Use when implementing or changing APIs, OpenAPI specs, service integrations, request/response schemas, webhooks, SDK contracts, or microservice boundaries.
---

# API Contract Testing

## Purpose

Prevent integration regressions by checking that providers and consumers agree on request shape, response shape, status codes, errors, versioning, and compatibility.

## When to Use

- Use when an API endpoint, schema, event, webhook, SDK, or generated client changes.
- Use before merging breaking or potentially breaking API changes.
- Use when integration tests are slow, brittle, or missing.
- Use when existing OpenAPI, JSON Schema, protobuf, GraphQL, or contract fixtures exist.

## When Not to Use

- Do not use as a replacement for authorization, business logic, or end-to-end tests.
- Do not invent a contract when no consumer or authoritative schema exists.
- Do not approve a breaking change without migration and versioning guidance.

## Required Inputs

- API contract source: OpenAPI, schema, proto, GraphQL schema, fixtures, or consumer expectations.
- Provider implementation and relevant handlers.
- Consumer code, generated clients, or integration call sites when available.
- Compatibility policy and versioning expectations.
- Commands for tests, schema validation, or contract verification.

## Workflow

1. Identify the authoritative contract and current provider behavior.
2. Map affected consumers and compatibility-sensitive fields.
3. Add or update contract tests for request validation, response shape, errors, and status codes.
4. Check backward compatibility for removed fields, renamed fields, stricter validation, and changed defaults.
5. Run focused provider and contract validation.
6. Document intentional breaking changes with migration or versioning requirements.
7. Report contract evidence and remaining integration gaps.

## Quality Gates

- Contract tests fail for incompatible request or response changes.
- Required and optional fields are explicit.
- Error formats and status codes are covered for common failure cases.
- Versioning and deprecation rules are followed.
- Generated docs or clients are refreshed when required.

## Anti-Patterns

- Testing only happy-path examples.
- Treating implementation output as the contract without checking source material.
- Ignoring consumers because the provider tests pass.
- Changing validation strictness without compatibility review.
- Updating snapshots without understanding contract impact.

## Output Format

```markdown
Contract Check:
- Contract source:
- Provider surface:
- Consumers affected:
- Compatibility result:
- Tests added or changed:
- Validation command:
- Migration notes:
```

## References

No bundled references are required. Add framework-specific contract examples only when repeated use justifies them.
