---
name: mcp-publish
description: Checklist to submit an MCP server to the official MCP Registry using an io.github.<owner>/<server> namespace. Use when the user is ready to publish an MCP server publicly.
---

# Publish an MCP server to the official Registry

The official Registry at [registry.modelcontextprotocol.io](https://registry.modelcontextprotocol.io) is metadata-only - your package lives on npm, PyPI, Docker Hub, or as a Go binary. The Registry entry points at it.

## Prerequisites

- The server is **public** (GitHub repo, OSS license, no secrets).
- The server passes Inspector end-to-end.
- Someone other than you has verified they can install + run it.
- You own the namespace - either `io.github.<your-github>/<name>` (verified via a repo) or `com.example/<name>` (verified via DNS).

## server.json

Every Registry submission is a `server.json` file. Minimal example:

```json
{
  "$schema": "https://modelcontextprotocol.io/schemas/draft/2025-09-29/server.schema.json",
  "name": "io.github.forgepoint-labs/gh-tools",
  "description": "Wrap the gh-tools CLI as MCP tools for GitHub workflows.",
  "version": "0.1.0",
  "repository": {
    "url": "https://github.com/forgepoint-labs/gh-tools-mcp",
    "source": "github"
  },
  "packages": [
    {
      "registry_type": "go",
      "identifier": "github.com/forgepoint-labs/gh-tools-mcp/cmd/gh-tools-mcp",
      "version": "0.1.0",
      "transport": { "type": "stdio" }
    }
  ]
}
```

## Submission checklist

- [ ] `server.json` validates against the current schema
- [ ] `name` uses a namespace you can verify
- [ ] `version` matches a published tag on the package registry
- [ ] README includes install instructions for each packaging listed
- [ ] At least one transport example config (for claude_desktop_config.json or `claude mcp add`)
- [ ] PR opened against [modelcontextprotocol/registry](https://github.com/modelcontextprotocol/registry)
- [ ] CI green on the PR
- [ ] Wait for review - 1-5 business days

## After publishing

- Add a marketplace-style badge to the README: ![MCP Registry](badge)
- Add install snippets for Claude Desktop, Claude Code, Cursor, VS Code, and Warp.
- Submit to downstream curators (they auto-pull from the Registry but a mention accelerates discovery).
- Open a thread on `#mcp-developers` in the MCP Discord with a link + GIF of it working.
