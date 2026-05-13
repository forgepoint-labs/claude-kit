# Agent Workflows

GitHub-native agent workflows for Claude Code. This guide covers the `agent-workflows` and `self-improvement` plugins.

## Quick start

```bash
# Install both plugins
/plugin install agent-workflows@forgepoint-labs
/plugin install self-improvement@forgepoint-labs

# Bootstrap agent infrastructure in your repo
# (seeds triage config, stakeholders, and self-improvement config)
```

Then ask Claude to run `bootstrap-repo-agent` in your repository.

## Available workflows

### PR Review (`review-pr`)

Structured pull request review with severity labels and machine-readable output.

```
Review PR #42 using the review-pr skill
```

Produces `review.json` with verdict (`APPROVE` / `REJECT`), summary, and inline comments with severity labels (`🚨 CRITICAL`, `⚠️ IMPORTANT`, `💡 SUGGESTION`, `🧹 NIT`). Applies via `gh pr review`.

### Issue Triage (`triage-issue`)

Automated issue classification with duplicate detection.

```
Triage issue #15 using the triage-issue skill
```

Produces `triage_result.json` with classification, labels, reproducibility estimate, root cause analysis, and duplicate detection. Applies via `gh issue edit` and `gh issue comment`.

### Issue Implementation (`implement-issue`)

Spec-aware issue implementation that keeps specs and code aligned.

```
Implement issue #30 using the implement-issue skill
```

Reads product and tech specs when available, implements the feature, updates specs if implementation diverges, and validates with the repo's test/lint tooling.

### Product Spec (`write-product-spec`)

Write a behavior-focused product spec before implementation.

```
Write a product spec for the new auth flow
```

Produces `specs/<feature>/PRODUCT.md` with problem, goals, user experience, success criteria, and validation plan.

### Tech Spec (`write-tech-spec`)

Write an implementation-focused tech spec grounded in the current codebase.

```
Write a tech spec for the API rate limiting feature
```

Produces `specs/<feature>/TECH.md` with relevant code, proposed changes, risks, and testing plan.

### Spec Compliance Check (`check-impl-against-spec`)

Compare a PR's implementation against approved specs during review.

Used automatically by `review-pr` when spec files exist. Folds material mismatches into the review as `⚠️ IMPORTANT` concerns.

### Repository Bootstrap (`bootstrap-repo-agent`)

One-time setup for agent infrastructure.

```
Run bootstrap-repo-agent to set up agent workflows
```

Creates `.github/issue-triage/config.json`, `.github/STAKEHOLDERS`, and `.github/oz/config.yml`.

## Local companion skills

The core skills support a "specialization" pattern. Each core skill defines overridable categories (style norms, label taxonomy, follow-up patterns, etc.) and a consuming repository can ship a `*-local/SKILL.md` companion that customizes only those categories.

Companion skills live at `.agents/skills/<skill>-local/SKILL.md` in the consuming repository. They are created automatically by the self-improvement loop or manually by maintainers.

Example: `.agents/skills/review-pr-local/SKILL.md` might contain:

```markdown
---
name: review-pr-local
specializes: review-pr
description: Repo-specific review guidance.
---

## Style norms

- Allow console.log in test files
- Prefer early returns over nested conditionals

## Paths to skip

- vendor/
- generated/
```

## Spec-driven development flow

The recommended flow for substantial features:

1. **Issue** → describes the problem
2. **Product spec** → defines behavior (`write-product-spec`)
3. **Tech spec** → defines implementation (`write-tech-spec`)
4. **Implementation** → builds the feature (`implement-issue`)
5. **Review** → validates against specs (`review-pr` + `check-impl-against-spec`)

For smaller changes, skip specs and go straight from issue to implementation.
