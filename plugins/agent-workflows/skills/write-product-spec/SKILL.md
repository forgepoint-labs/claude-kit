---
name: write-product-spec
description: Write a PRODUCT.md-style spec for a significant feature, focused on user-facing behavior, invariants, edge cases, and validation. Use when the user asks for a product spec, PRD, or behavior doc, or when a feature is substantial enough that a written spec would improve implementation quality.
---

# Write a product spec

Write a `PRODUCT.md`-style spec for a significant feature in the current repository.

## Overview

The product spec makes desired behavior unambiguous enough that an agent can implement it correctly and avoid regressions. Focus on product behavior, UX, invariants, and validation — not implementation details.

Write specs under `specs/` in the repository. Prefer a clear structure:

- `specs/<feature>/PRODUCT.md`
- `specs/GH<issue>/product.md` when driven by a GitHub issue

## Before writing

Gather the minimum context needed:

- Feature summary
- Target users or workflow
- Key user-facing behaviors and constraints
- Known edge cases
- Expected verification plan

When important details are missing, ask the user instead of guessing.

If the feature includes UI or interaction changes, ask whether there is a Figma mock. Note its presence or absence explicitly:

- `Figma: <link>`
- `Figma: none provided`

## Structure

### 1. Summary

Describe the feature in a few sentences and state the desired outcome.

### 2. Problem

Explain what user or product problem is being solved.

### 3. Goals

List the outcomes this change must achieve.

### 4. Non-goals

List adjacent ideas or follow-ups that are explicitly out of scope.

### 5. Figma / design references

Link the Figma mock if it exists, or explicitly note that none was provided.

### 6. User experience

Describe expected behavior in concrete, exhaustive, testable terms. Be explicit about:

- default behavior
- state transitions
- edge cases
- empty states
- error states
- keyboard or interaction expectations when relevant

Prefer a list of invariants or behavior rules over broad prose.

### 7. Success criteria

Define what will be true if the feature works correctly. Each criterion should map to observable user behavior and be specific enough to verify with tests or code review.

### 8. Validation

Describe how the behavior should be verified. Prefer checks that map to tests, videos, screenshots, or manual validation steps.

### 9. Open questions

Call out unresolved product decisions rather than burying them in the narrative.

## Writing guidance

- Prefer concrete behavior over aspirational wording.
- Write for the implementer and reviewer, not for marketing.
- Make the spec precise enough that an agent can follow it.
- Capture invariants that must not regress.
- Include edge cases that are easy to miss.
- Avoid implementation details unless unavoidable for understanding UX.

## Keep the spec current

If implementation changes intended product behavior, update the spec so it matches what ships. Keep spec updates in the same PR as the related code changes.

## When to skip

Skip the product spec when the change is small enough that the overhead outweighs the value. Specs are most useful for significant features, not small edits.
