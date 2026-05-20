# Self-Improvement Loops

The self-improvement pattern lets agents get better at their job over time by accumulating evidence-backed guidance in repo-local companion skills.

## How it works

```
Agent does work (triage, review, implement)
         ↓
Human corrects or overrides the output
         ↓
self-improve-skills harvests the corrections
         ↓
Proposes updates to local companion skills via PR
         ↓
Maintainer reviews and merges
         ↓
Next agent run uses the improved guidance
```

## Setup

### 1. Install plugins

```bash
/plugin install agent-workflows@forgepoint-labs
/plugin install self-improvement@forgepoint-labs
```

### 2. Bootstrap your repository

Run `bootstrap-repo-agent` to create:

- `.github/issue-triage/config.json` — label taxonomy
- `.github/STAKEHOLDERS` — ownership mappings
- `.github/oz/config.yml` — self-improvement configuration

### 3. Add the GitHub Actions workflow

Copy `.github/workflows/oz-agent-feedback.yml` from this repository into your project. It handles:

- **`@oz-agent` mentions** — triggers the `respond-to-feedback` skill when someone comments `@oz-agent <feedback>` on an issue or PR
- **Weekly self-improvement** — runs every Monday at 06:00 UTC to analyze recent agent evidence and propose companion skill updates
- **Manual trigger** — run on demand via `workflow_dispatch`

### 4. Configure secrets

Add these secrets to your repository:

- `ANTHROPIC_API_KEY` — your Anthropic API key for Claude Code
- `GITHUB_TOKEN` is provided automatically by GitHub Actions

### 5. Configure reviewers (optional)

Edit `.github/oz/config.yml` to specify who reviews self-improvement PRs:

```yaml
version: 1
self_improvement:
  reviewers: [your-username]
  base_branch: auto
  lookback_days: 14
```

## Evidence sources

The self-improvement loop analyzes four evidence sources:

### Triage overrides
When a maintainer removes agent-applied labels and adds different ones, the maintainer's labels become ground truth for the local companion.

### Review feedback
When the agent requests changes but a maintainer approves anyway, the agent was too strict. Recurring nits become documented norms.

### `@oz-agent` feedback
Direct feedback like `@oz-agent stop flagging console.log in test files` counts as sufficient evidence on its own — no minimum item count needed.

### Closed-as-not-planned
Issues closed without implementation may indicate triage was wrong.

## Safety guarantees

- The loop **never modifies core skills** — only local companions
- The loop **never removes existing rules** — only adds or refines
- Every new rule **must cite evidence** from a specific issue or PR
- Changes are **always proposed via PR** — never applied directly
- The companion **cannot change** the parent skill's output schema or safety rules

## `@oz-agent` mention routing

When someone comments `@oz-agent` on an issue or PR, the `respond-to-feedback` skill classifies the intent and routes to the right action:

| Intent | Signal | Action |
|---|---|---|
| Skill improvement | "stop flagging", "our convention is", "we prefer" | Runs `self-improve-skills` with the feedback |
| Triage | "triage this", "classify", "label this" | Runs `triage-issue` |
| Review | "review this", `/oz-review` | Runs `review-pr` |
| Implementation | "implement this", "fix this", `/oz-implement` | Runs `implement-issue` |
| General | No clear signal | Posts a helpful reply |

## Companion skill locations

| Companion | Specializes | Override categories |
|---|---|---|
| `.agents/skills/review-pr-local/SKILL.md` | `review-pr` | Style norms, paths to skip, graceful degradation |
| `.agents/skills/triage-issue-local/SKILL.md` | `triage-issue` | Label taxonomy, follow-up patterns, heuristics |
| `.agents/skills/dedupe-issue-local/SKILL.md` | `dedupe-issue` | Known-duplicate clusters |
