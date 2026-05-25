---
name: performance-profiling
description: Measure, isolate, optimize, and verify software performance bottlenecks and regressions. Use when code is slow, resource usage increases, latency changes, builds or tests regress, or a user requests performance optimization.
---

# Performance Profiling

## Purpose

Improve performance using measurements and reproducible benchmarks instead of speculative optimization.

## When to Use

- Use when latency, throughput, memory, CPU, I/O, build time, or test time regresses.
- Use when a user asks to speed up code or reduce resource usage.
- Use before and after risky optimizations.
- Use when performance behavior depends on input size, concurrency, or environment.

## When Not to Use

- Do not optimize without a baseline and target.
- Do not trade correctness, security, or maintainability for unproven gains.
- Do not rely on one noisy measurement.
- Do not benchmark against production data unless privacy and safety are clear.

## Required Inputs

- Performance symptom, target, and affected scenario.
- Reproduction command, benchmark, trace, profile, or log source.
- Representative input sizes and environment constraints.
- Existing performance tests or monitoring data.
- Correctness validation command.

## Workflow

1. Establish a baseline with repeatable command, input, and environment notes.
2. Identify whether CPU, memory, I/O, network, database, build tooling, or algorithmic cost dominates.
3. Profile before editing when tooling exists.
4. Make one optimization at a time and preserve behavior.
5. Re-run the benchmark multiple times or use stable aggregate measurements.
6. Run correctness tests after optimization.
7. Record before/after results, tradeoffs, and residual bottlenecks.

## Quality Gates

- Baseline and optimized measurements use comparable conditions.
- Correctness validation passes after the change.
- Performance gains are meaningful relative to noise.
- Tradeoffs are documented.
- The benchmark or monitoring query can be repeated later.

## Anti-Patterns

- Optimizing code that is not on the hot path.
- Rewriting broad areas without measurement.
- Ignoring cold start, cache state, or input-size effects.
- Reporting only the best run.
- Removing validation to improve speed numbers.

## Output Format

```markdown
Performance Result:
- Scenario:
- Baseline:
- Bottleneck evidence:
- Change:
- After measurement:
- Correctness validation:
- Tradeoffs:
```

## References

No bundled references are required. Add stack-specific profiler commands only when repeated use justifies them.
