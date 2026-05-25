---
name: frontend-ui-development
description: Build or modify frontend user interfaces, components, state flows, styling, accessibility behavior, and browser-facing interactions. Use when an agent needs to implement UI behavior, responsive layouts, client-side validation, visual states, or frontend tests without assuming a specific framework.
---

# Frontend UI Development

## Purpose

Deliver usable frontend changes that match existing patterns, handle states correctly, and are verified in the browser or component test environment.

## When to Use

- Use when adding or changing screens, components, forms, navigation, client state, or styling.
- Use when UI states such as loading, empty, error, disabled, hover, focus, or success need implementation.
- Use when responsive layout, accessibility, or visual behavior must be checked.
- Use when browser-facing behavior needs tests, screenshots, or manual verification.

## When Not to Use

- Do not use for backend-only API behavior.
- Do not use for visual design review only unless implementation changes are requested.
- Do not replace a security review when UI changes expose sensitive data or permissions.

## Required Inputs

- User-facing behavior and acceptance criteria.
- Relevant components, routes, styles, state management, tests, and design references.
- Supported browsers, responsive breakpoints, and accessibility requirements when known.
- API contracts or mock data needed by the UI.
- Local run and test commands, Windows-first with Linux alternatives where useful.

## Workflow

1. Inspect nearby UI patterns, components, styles, tests, and state conventions.
2. Identify all required states: default, loading, empty, error, success, disabled, and permission-limited.
3. Implement the smallest component or route changes that satisfy the workflow.
4. Preserve existing design system, accessibility patterns, and keyboard behavior.
5. Add or update tests for behavior that can be exercised automatically.
6. Run focused frontend validation and inspect the rendered UI when feasible.
7. Check responsive layout and text overflow for affected views.
8. Report visual or interaction risks that remain unverified.

## Quality Gates

- UI behavior matches the requested workflow and existing patterns.
- Interactive controls have accessible names and keyboard behavior where applicable.
- Loading, empty, and error states are handled.
- Responsive layout does not overlap or hide important content.
- Tests or browser verification cover the changed path where practical.

## Anti-Patterns

- Building a standalone design that ignores the existing UI system.
- Hardcoding data when the UI should use existing state or API paths.
- Implementing only the happy path.
- Adding decorative complexity that hurts clarity or performance.
- Claiming visual verification without rendering or testing the affected UI.

## Output Format

```markdown
Frontend Result:
- User flow:
- States handled:
- Accessibility notes:

Changed Files:
- 

Validation:
- 

Visual Risks:
- 
```

## References

No bundled references are required. Add design-system or framework notes to `references/` only when they are reusable and too long for this file.
