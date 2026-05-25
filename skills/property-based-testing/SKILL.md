---
name: property-based-testing
description: Design invariant, round-trip, generator, and stateful tests that explore behavior beyond fixed examples. Use when code has parsers, serializers, validators, normalizers, data structures, algorithms, or state transitions where broad input coverage can expose edge cases.
---

# Property-Based Testing

## Purpose

Use generated inputs and invariants to verify behavior over classes of cases instead of only hand-picked examples.

## When to Use

- Use for encode/decode, parse/render, serialize/deserialize, import/export, and normalize/validate pairs.
- Use for pure functions, algorithms, data structures, state machines, and permission rules.
- Use when edge cases are numerous or previous example tests missed bugs.
- Use before refactors where behavior must remain stable over many inputs.

## When Not to Use

- Do not use when a single concrete regression test is sufficient.
- Do not generate unsafe production operations, external writes, or irreversible side effects.
- Do not add slow randomized tests without bounding input size, iteration count, and seed handling.

## Required Inputs

- Target behavior and authoritative expected properties.
- Existing test framework and supported property-testing library, if any.
- Valid input domain, invalid input domain, and shrinking constraints.
- Deterministic seed or reproducibility strategy.
- Focused command to run the new tests.

## Workflow

1. Identify the behavior class and the property that must always hold.
2. Choose the smallest useful generator domain, including boundary values.
3. Write one property at a time with deterministic seeds or reproducible failure output.
4. Add assumptions only when invalid generated cases are outside the behavior contract.
5. Run the property test and inspect shrunk counterexamples.
6. Fix the implementation or narrow the property based on authoritative behavior.
7. Keep a regression example for any important counterexample that should remain readable.

## Quality Gates

- Properties are tied to real contracts, not vague expectations.
- Generators include boundary, empty, malformed, and large-enough cases where relevant.
- Failures are reproducible from reported seed or counterexample.
- Runtime is acceptable for local and CI use.
- The final test command is reported.

## Anti-Patterns

- Testing implementation details instead of behavior.
- Generating arbitrary data that the system never accepts.
- Hiding failures by over-filtering generated cases.
- Adding nondeterministic tests with no seed capture.
- Treating property tests as a replacement for clear example tests.

## Output Format

```markdown
Property Tests:
- Target:
- Property:
- Generator domain:
- Counterexamples found:
- Implementation changes:
- Validation command:
- Residual limits:
```

## References

No bundled references are required. Add library-specific references only when repeated use justifies them.
