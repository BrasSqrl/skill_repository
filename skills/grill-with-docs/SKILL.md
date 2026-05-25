---
name: grill-with-docs
description: Stress-test a plan against repository domain language and documented decisions while updating glossary and ADR artifacts as decisions crystallize. Use when the user wants a design grilled against CONTEXT.md, ADRs, or established project terminology.
---

# Grill With Docs

## Purpose

Challenge a plan against existing domain language and durable decisions, then update documentation when terminology or decisions are resolved.

## When to Use

- Use when the user asks to grill a plan against project docs.
- Use when unclear domain terms or ADR conflicts affect a design.
- Use when decisions should update `CONTEXT.md` or create an ADR.

## When Not to Use

- Do not use for implementation-only tasks.
- Do not create ADRs for minor or reversible details.
- Do not update docs with speculative terms that are not resolved.

## Required Inputs

- Plan, proposal, or design to challenge.
- Existing `CONTEXT.md`, `CONTEXT-MAP.md`, or ADR locations when present.
- User willingness to answer one question at a time.
- Repository source context when claims can be verified locally.

## Workflow

1. Inspect existing context docs and ADRs relevant to the plan.
2. Identify terms, relationships, and decisions that are unclear or conflicting.
3. Ask one targeted question at a time, including a recommended answer.
4. Verify code-backed claims against source when possible.
5. Update `CONTEXT.md` immediately when a domain term is resolved.
6. Offer an ADR only for hard-to-reverse, surprising, trade-off-driven decisions.
7. Stop with a concise summary of resolved terms, decisions, and next work.

## Quality Gates

- Terminology matches the repository glossary or is explicitly updated.
- ADRs are offered only when they record durable decisions.
- Code contradictions are surfaced.
- Documentation updates are scoped and factual.
- The user confirms each meaningful decision.

## Anti-Patterns

- Creating docs before decisions are resolved.
- Treating `CONTEXT.md` as a spec or scratchpad.
- Asking questions that source inspection can answer.
- Recording ephemeral preferences as ADRs.

## Output Format

```markdown
Resolved Terms:
- 

Resolved Decisions:
- 

Docs Updated:
- 

Remaining Questions:
- 
```

## References

- `references/CONTEXT-FORMAT.md`: Use when creating or updating `CONTEXT.md`.
- `references/ADR-FORMAT.md`: Use when writing an ADR for a resolved decision.
