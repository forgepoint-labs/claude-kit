# self-improvement

Self-improvement loops for agent skills. The core idea: agents get better at their job by accumulating evidence-backed guidance in repo-local companion skills, updated automatically from feedback.

Inspired by the self-improvement patterns in [oz-for-oss](https://github.com/warpdotdev/oz-for-oss).

## How it works

1. **Core skills** (in `agent-workflows`) define the generic contract — how to review PRs, triage issues, etc.
2. **Local companion skills** (`*-local/SKILL.md`) live in each consuming repository and specialize the core skills with repo-specific guidance.
3. **Self-improvement loops** analyze recent agent performance and propose updates to companion skills via pull requests.
4. **`@oz-agent` mentions** in GitHub comments trigger the agent to process feedback and route it to the right workflow.

## Skills

- `self-improve-skills` — Analyze closed issues, merged PRs, and maintainer overrides to propose updates to local companion skills. Run periodically (weekly cron) or on demand.
- `respond-to-feedback` — Handle `@oz-agent <feedback>` mentions on issues and PRs. Parse the feedback, determine if it's a skill improvement, triage request, or implementation task, and route accordingly.

## Setup

1. Install the `agent-workflows` plugin for the core skills.
2. Run `bootstrap-repo-agent` to seed triage config and `.github/oz/config.yml`.
3. Add the GitHub Actions workflow (see `docs/self-improvement.md`) to handle `@oz-agent` mentions.
4. Companion skills will be created automatically by the self-improvement loop as evidence accumulates.

## Related

- [`agent-workflows`](../agent-workflows/) — The core agent workflow skills that companion skills specialize.
