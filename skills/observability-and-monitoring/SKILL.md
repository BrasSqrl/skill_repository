---
name: observability-and-monitoring
description: Add or review logs, metrics, traces, dashboards, alerts, and production diagnosis signals. Use when implementing services, debugging production-like behavior, preparing releases, or changing workflows that need operational visibility.
---

# Observability And Monitoring

## Purpose

Make software behavior diagnosable in production by adding actionable telemetry with clear ownership, correlation, and failure signals.

## When to Use

- Use when adding or changing backend services, jobs, queues, integrations, or critical frontend flows.
- Use when a bug would be difficult to diagnose from existing logs or metrics.
- Use before release when operational readiness is uncertain.
- Use when incidents, alerts, dashboards, or SLOs are missing or noisy.

## When Not to Use

- Do not add telemetry that logs secrets, tokens, personal data, or sensitive payloads.
- Do not add high-cardinality labels without checking cost and retention impact.
- Do not create alerts with no owner, action, threshold basis, or runbook.

## Required Inputs

- Runtime surface and critical user or system flows.
- Existing logging, tracing, metrics, and alerting conventions.
- Privacy and data retention constraints.
- Known failure modes and expected diagnosis questions.
- Validation command or local observability check.

## Workflow

1. Identify the operational questions future responders must answer.
2. Inspect existing telemetry patterns and naming conventions.
3. Add structured logs at decision points, errors, and lifecycle boundaries.
4. Add metrics for throughput, latency, errors, saturation, and business-critical counts.
5. Add tracing or correlation IDs across process, network, queue, or job boundaries.
6. Review alert thresholds, dashboard visibility, and runbook links where applicable.
7. Verify telemetry does not expose secrets or excessive cardinality.

## Quality Gates

- Telemetry answers concrete diagnosis questions.
- Logs include stable event names and correlation fields.
- Metrics have units, bounded labels, and meaningful aggregation.
- Errors include enough context without leaking sensitive data.
- Alerts are actionable and tied to ownership or runbooks.

## Anti-Patterns

- Logging every variable instead of meaningful events.
- Adding metrics nobody can interpret.
- Emitting personal data or credentials.
- Creating dashboards without release or incident use.
- Treating observability as a replacement for tests.

## Output Format

```markdown
Observability Result:
- Flow covered:
- Logs:
- Metrics:
- Traces/correlation:
- Alerts/dashboards:
- Privacy checks:
- Validation:
```

## References

No bundled references are required. Add stack-specific telemetry naming guides only when repeated use justifies them.
