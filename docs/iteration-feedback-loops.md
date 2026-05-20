# Iteration & Feedback Loops

> The competitive advantage isn't AI — it's *the speed you learn* from it. This doc is the instrumentation.

## The improvement loop

```
Use Claude on real work → Measure outputs & costs → Identify friction → Update CLAUDE.md / skills / hooks → Share with team → Repeat
```

Each trip around takes ~a week if you're deliberate.

## What to measure

### Per-session signals (every session)

- **Token usage** — `/cost` or `/stats` — under $5/session for simple tasks
- **Context usage** — `/context` — don't cross 70% before compact
- **Permission prompts** — count them — decreasing week over week
- **Manual corrections** — subjective — decreasing
- **Time to first useful output** — wall clock — under 2 min for simple asks

### Per-repo signals (weekly)

- **PRs co-authored by Claude** — `git log --grep "Co-Authored-By"` — track trend
- **PR cycle time** — open → merge — reduce 25% in 8 weeks
- **Bugs escaped to prod** — issue tracker — decrease
- **CI failure rate** — GitHub Actions — decrease
- **CLAUDE.md drift** — diff against 3mo ago — intentional changes only

### Org-wide signals (monthly)

- Total tokens (analytics dashboard)
- Active developer days
- Cost per active dev per month
- Adoption rate (% of team that used Claude in last 7d)
- Skill / plugin usage (`/insights` + marketplace stats)

## Seven patterns for iteratively improving a repo

### Pattern 1: CLAUDE.md changelog

Keep a running changelog in `CLAUDE.md` or a sibling file:

```markdown
## 2026-04-20
- Added middleware wrapper requirement after Claude forgot it twice
- Removed stale note about Node 20 (upgraded to 24)

## 2026-04-13
- Added path-scoped rule for packages/auth/*
```

Every entry represents a learning. If you can't add an entry in 2 weeks, the repo's at a local maximum.

### Pattern 2: The "mistake twice" rule

If Claude makes the same mistake twice, don't correct it in chat — update CLAUDE.md or a skill. If you catch yourself re-explaining something, that's a signal.

### Pattern 3: Permission prompt reduction

Run `/fewer-permission-prompts` monthly. It scans transcripts and proposes an allowlist of tools you've been approving anyway. Slashes 20-40% of prompts.

### Pattern 4: Review gate vs. feedback gate

Use `/ultrareview` as the **authority gate** (final check before merge). Use a GitHub Action with Claude as the **continuous feedback gate** (every commit).

Feedback gate + authority gate together = fast iteration without quality loss.

### Pattern 5: Docs drift routine

Weekly routine: scan merged PRs from the past 7 days, find any that touch public APIs, read the corresponding docs, and open a PR to fix any drift.

### Pattern 6: Auto-generated CLAUDE.md suggestions

Monthly routine: analyze the last 30 days of sessions, propose 5 additions to CLAUDE.md based on repeat corrections. Open a PR with the suggestions. Lets Claude improve Claude.

### Pattern 7: Cost regression detector

Daily routine: get the last 24h Claude Code cost, compare against 7-day rolling average. Alert if >25% above.

## Weekly checklist

Every Sunday:

- Run `/insights` on last 7 days
- Read one friction pattern; fix it in CLAUDE.md or a skill
- Check `/cost` or analytics dashboard — spot outliers
- Run `/fewer-permission-prompts` (~monthly)
- One repo gets a CLAUDE.md changelog entry
- Post one "win" or "lesson" in your team channel

## Signs you're NOT iterating well

- CLAUDE.md hasn't changed in 3 weeks, but you're still correcting Claude
- Same permission prompts keep showing up
- Costs are climbing but output isn't
- Developers report "Claude just doesn't get our codebase"
- People are writing the same prompt manually instead of using a skill

## AI config tech debt

Just like code has tech debt, AI config has it too:

- Skills drift out of date when patterns change
- CLAUDE.md contradicts itself over time
- Hooks reference scripts that no longer exist
- MCP servers get abandoned upstream

Dedicate one hour per month to AI config maintenance: re-run `/init`, prune stale CLAUDE.md entries, update plugin versions, test MCP connections.

## The compounding effect

Every improvement is permanent. One better CLAUDE.md line saves 30 seconds per session × dozens of sessions per week × everyone using that repo. After 6 months of deliberate iteration, you're not a "Claude user" — you're running an AI platform.
