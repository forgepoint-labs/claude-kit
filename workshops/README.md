# ForgePoint Workshops

A 12-week, self-paced curriculum to take you from "I have Claude Code installed" to "I run an agentic engineering practice with public plugins, MCP servers, and routines." Designed for ForgePoint Labs (solo), one week at a time.

## How to use

Each week lives in its own directory: `week-01/`, `week-02/`, etc. Open the week's `README.md` and follow the four sections in order:

1. **Prep** (15 to 30 minutes before the session): installs, accounts, repo clones.
2. **Walkthrough** (60 to 90 minutes): the meat of the lesson, with concrete commands and live decisions.
3. **Exercise** (30 to 90 minutes self-paced): a small piece of real work that exercises the lesson.
4. **Done when**: a short checklist that confirms you actually internalized it.

You're working solo, so treat the "session" as a focused block on your calendar. Block 2 hours, do prep + walkthrough + exercise back to back, then check off "done when" at the end.

## Pacing

* One week at a time. Do not jump ahead.
* If something doesn't click, repeat the week before moving on. Skills compound.
* If a week's exercise feels trivial, you've probably done the prep work already; move on.

## Schedule

| Week | Theme | Outcome |
|---|---|---|
| 01 | Install Claude Code, first agentic session | Working `claude` install, a real session, first CLAUDE.md tweak |
| 02 | CLAUDE.md, skills, and Warp skill discovery | A repo-scoped CLAUDE.md and one skill that Claude auto-invokes |
| 03 | Plugin authoring and the marketplace | First plugin loaded locally with `--plugin-dir`, published to your marketplace |
| 04 | MCP server authoring in TypeScript | A working stdio MCP server, tested with Inspector, registered in Claude Code |
| 05 | MCP server authoring in Python or Go | Same exercise in a second language, published as a Go binary or PyPI package |
| 06 | Hooks and subagents | A `PostToolUse` hook that formats edits, plus a custom code-reviewer subagent |
| 07 | Routines and scheduled agents | One routine running on a cron in Anthropic cloud, opening PRs against a real repo |
| 08 | Claude Design to Claude Code handoff | A small UI prototyped in Claude Design, handed off, and shipped as code |
| 09 | Playwright MCP and agent-driven E2E | One E2E flow for a real site, run via Playwright MCP from a Claude session |
| 10 | Publish a public plugin and an MCP server | Plugin and `io.github.forgepoint-labs/...` server submitted to the official MCP Registry |
| 11 | Productize the consulting offering | A landing page, a `weekly-audit` routine template, a 3-min demo video |
| 12 | Review and plan next quarter | Cost review, metric review, Q2 roadmap |

## Conventions used in every week's `README.md`

* **Audience**: who the week is for. (Always you for this curriculum.)
* **Time**: a realistic block to schedule.
* **Prereqs**: what must be true before you start. If a prereq isn't met, do the prereq first.
* **Walkthrough**: numbered steps, each with the exact command or click.
* **Exercise**: one piece of real work, not a toy. Always tied to a real repo or product.
* **Reflect**: 2 or 3 questions to capture in your weekly notes. These feed into Week 12.
* **Resources**: links worth bookmarking, in priority order.

## Tracking progress

Keep a running `~/.claude/projects/forgepoint-workshops/journal.md` (or anywhere you like) with:

* Date completed
* What surprised you
* What you'll change in your daily Claude use because of this week

You'll re-read this in Week 12 to plan the next quarter.

## Adjacent material

* `docs/glossary.md` for vocabulary.
* `docs/mcp-quickstart.md` for the 30-minute MCP onramp.
* `docs/CONTRIBUTING.md` for how plugins are structured (you'll author plugins from Week 3 on).
