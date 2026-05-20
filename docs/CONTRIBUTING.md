# Contributing to claude-kit

Thanks for your interest! A few rules that keep this repo useful.

## Repository is public

Do not submit anything specific to a client, employer, or internal project. The separation audit (`.github/workflows/audit.yml` + `.github/scripts/separation-audit.sh`) enforces this. See [`SEPARATION-POLICY.md`](./SEPARATION-POLICY.md).

Install the pre-commit hook once:

```sh
bash scripts/install-pre-commit-hook.sh
```

## Plugin structure

```
plugins/<plugin-name>/
├── .claude-plugin/
│   └── plugin.json          # manifest (required)
├── README.md                 # what the plugin is + list of skills (required)
└── skills/
    └── <skill-name>/
        └── SKILL.md          # YAML frontmatter + markdown body (at least one required)
```

Optional at the plugin root:

- `agents/` - subagent definitions
- `hooks/hooks.json` - lifecycle hooks
- `.mcp.json` - bundled MCP servers
- `settings.json` - default settings when enabled

## SKILL.md format

```markdown
---
name: my-skill
description: One-sentence description of what the skill does AND when Claude should invoke it. This is the routing signal - be precise.
---

# Title

Body markdown explaining procedure, templates, rules.
```

Good `description` fields answer **when**, not just **what**. The model uses them to decide auto-invocation.

## Version bumping

Each plugin is versioned independently via `plugin.json` → `version`. Use semver:

- Patch: doc tweaks, typo fixes, clarifications
- Minor: new skills, new templates, backward-compatible additions
- Major: changes that break existing usage patterns

When a plugin version changes, also update the entry in `.claude-plugin/marketplace.json`.

## PR checklist

- [ ] Pre-commit hook installed and passing
- [ ] New skill(s) have clear `name` + `description` frontmatter
- [ ] Plugin `README.md` lists the skills
- [ ] Marketplace entry matches `plugin.json` (name, version, description, tags)
- [ ] No client / employer / internal project references
