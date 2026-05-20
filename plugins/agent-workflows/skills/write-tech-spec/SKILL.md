---
name: write-tech-spec
description: Write a TECH.md-style spec for a significant feature grounded in actual codebase patterns, documenting architecture, tradeoffs, and validation. Use when the user asks for a technical spec, implementation plan, or architecture doc tied to a product spec.
---

# Write a tech spec

Write a `TECH.md`-style spec for a significant feature in the current repository.

## Overview

The tech spec translates product intent into an implementation plan that fits the existing codebase, documents architectural choices, and makes the work easier for agents to execute and reviewers to evaluate.

Write specs under `specs/` in the repository. Prefer:

- `specs/<feature>/TECH.md`
- `specs/GH<issue>/tech.md` when driven by a GitHub issue

## When to use

Prefer a tech spec when:

- The feature is substantial
- The implementation spans multiple modules or layers
- There are meaningful architectural decisions or tradeoffs
- Extensibility matters
- Reviewers will benefit from understanding the plan before the raw code

For pure UI changes, a tech spec may be unnecessary. Be pragmatic.

## Prerequisites

Prefer to have a product spec first so the technical plan is anchored to agreed behavior. If the implementation is too uncertain, it can be better to prototype first and then write the tech spec from what was learned.

## Research before writing

Before drafting:

1. Read the relevant product spec if it exists.
2. Inspect existing patterns in the codebase.
3. Identify the main files, types, data flow, and ownership boundaries involved.
4. Understand the current behavior and where it falls short.
5. Note dependencies, rollout constraints, risks, and likely validation strategy.

Do not guess about current architecture when the code can be inspected directly.

## Structure

### 1. Problem

State the technical problem and how it relates to the product behavior.

### 2. Relevant code

Point to the most relevant files, types, and entry points:

- `src/module.py:42` — entry point for the user flow
- `src/module.py (120-220)` — state and event handling that will likely change

### 3. Current state

Describe how the system works today and what limitations matter.

### 4. Proposed changes

Lay out the implementation plan. Be explicit about:

- Which modules or components change
- New types, APIs, or state introduced
- Data flow and event flow
- Ownership boundaries
- How this follows existing patterns

### 5. End-to-end flow

Explain the path through the system for the main user interaction.

### 6. Risks and mitigations

Call out failure modes, regressions, migration concerns, or rollout hazards.

### 7. Testing and validation

List the tests and verification needed to show the implementation matches the intended behavior.

### 8. Follow-ups

Note deferred cleanup, extensions, or future work.

## Writing guidance

- Ground the plan in actual codebase structure and patterns.
- Prefer concrete implementation guidance over generic architecture language.
- Explain why the proposed design fits this repo.
- Call out tradeoffs when there is more than one reasonable path.
- Keep concise but specific enough that an agent can implement from it.

## Keep the spec current

If implementation diverges from the plan, update the tech spec so it matches reality. Keep spec updates in the same PR as the related code changes.
