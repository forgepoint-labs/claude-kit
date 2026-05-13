# agent-workflows

GitHub-native agent workflows for Claude Code. Structured PR review, issue triage, spec-driven implementation, and repo bootstrap — adapted from the patterns in [oz-for-oss](https://github.com/warpdotdev/oz-for-oss) but generalized for any repository.

## Skills

- `review-pr` — Structured PR review with severity labels, suggestion blocks, and `review.json` output. Use when reviewing a PR diff.
- `triage-issue` — Analyze a GitHub issue: classify, estimate reproducibility, detect duplicates, produce `triage_result.json`. Use when triaging a new or reopened issue.
- `implement-issue` — Implement a GitHub issue with spec awareness. Reads product and tech specs when available, keeps specs and code aligned. Use when assigned an issue.
- `write-product-spec` — Write a `PRODUCT.md`-style product spec focused on user-facing behavior, invariants, and validation. Use before implementation of substantial features.
- `write-tech-spec` — Write a `TECH.md`-style tech spec grounded in actual codebase patterns. Use when the implementation warrants architectural documentation.
- `check-impl-against-spec` — Compare a PR diff against approved spec context and fold mismatches into review. Use during PR review when specs exist.
- `bootstrap-repo-agent` — Bootstrap triage config, stakeholders, and local companion skill stubs for a repository. Run once to set up agent infrastructure.

## Local companion skills

Several skills support a "local companion" pattern: the generic skill defines the contract, and a repo-specific `*-local/SKILL.md` file can override narrow categories (label taxonomy, style norms, follow-up patterns) without changing the core behavior. See `bootstrap-repo-agent` for setup and `self-improvement` plugin for automatic updates.

## Related

- [`self-improvement`](../self-improvement/) — Automated self-improvement loops that refine local companion skills from evidence.
