# claude-kit - ForgePoint Labs Plugins for Claude Code

> A curated plugin marketplace for [Claude Code](https://code.claude.com). Skills, subagents, and MCP server starters from real production work.

## Install the marketplace

```bash
/plugin marketplace add forgepoint-labs/claude-kit
```

## Install any plugin

```bash
/plugin install <plugin-name>@forgepoint-labs
```

## Available plugins

| Plugin | What it is |
|---|---|
| **`agent-workflows`** | GitHub-native agent workflows: structured PR review, issue triage, spec-driven implementation, and repo bootstrap. Adapted from [oz-for-oss](https://github.com/warpdotdev/oz-for-oss). |
| **`self-improvement`** | Self-improvement loops: analyze agent feedback, refine local companion skills, respond to `@oz-agent` mentions. |
| **`mcp-authoring`** | Opinionated scaffold + publish workflow for building MCP servers (builds on `anthropic/mcp-server-dev`). |
| **`bubbletea-cli-kit`** | Go 1.25 TUI CLI patterns using Bubbletea + Bubbles + Lipgloss. Includes a scaffold skill, release conventions, and testing patterns. |
| **`homelab-ops`** | Raspberry Pi + Ubuntu homelab admin: systemd units, Docker + Podman, ufw, SSH hardening, unattended-upgrades. |
| **`nextjs-app-router-kit`** | Next.js 16 + App Router + React 19 + Tailwind 4 + shadcn/ui conventions. |
| **`aws-serverless-patterns`** | Generic AWS CDK + SAM patterns with middy middleware and Powertools. |

## Local development

Test without installing from the marketplace:

```bash
git clone https://github.com/forgepoint-labs/claude-kit
cd claude-kit
claude --plugin-dir ./plugins/<plugin-name>
```

## Contributing

- **Don't submit client or employer-specific code.** This repo is public. A separation audit runs on every PR (`.github/workflows/audit.yml`).
- Install the local pre-commit hook so you catch leaks before pushing: `bash scripts/install-pre-commit-hook.sh`.
- Each plugin ships with a `plugin.json` manifest. Bump `version` using semver.
- PRs should describe: what the plugin does, when Claude should invoke it, one example interaction.

## Roadmap

- [x] Ship `agent-workflows` v0.1 — PR review, triage, spec-driven implementation
- [x] Ship `self-improvement` v0.1 — feedback loops and `@oz-agent` mention handling
- [ ] Ship `mcp-authoring` v0.1 (priority one)
- [ ] Ship `gh-tools-mcp` native Go MCP server - see sibling repo when published
- [ ] First external contribution
- [ ] Submit `io.github.forgepoint-labs/gh-tools` to the [MCP Registry](https://modelcontextprotocol.io/registry/about)

## License

MIT - see [LICENSE](./LICENSE).

## About ForgePoint Labs

Tooling, consulting, and opinionated patterns for building agentic dev environments. https://forgepoint.io
