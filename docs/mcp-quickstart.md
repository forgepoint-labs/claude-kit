# MCP Quickstart

Minimum viable knowledge to go from zero to a working MCP server in 30 minutes. For deeper dives, see the official docs at [modelcontextprotocol.io](https://modelcontextprotocol.io).

## What MCP is

The **Model Context Protocol** is an open standard for AI apps to connect to external systems. Think "USB-C for AI" — one protocol, many implementations.

Core message format: JSON-RPC 2.0. Two supported transports: `stdio` (local) and `Streamable HTTP` (remote).

## Server primitives (what servers expose)

- **Tools** — executable functions the model can call (e.g. `search_flights(from, to)`)
- **Resources** — read-only data the application attaches to context (e.g. a file, a DB schema)
- **Prompts** — templates the *user* picks from a menu (e.g. "Plan a vacation")

## Client primitives (what hosts expose)

- **Sampling** — server asks host to run an LLM completion on its behalf
- **Elicitation** — server asks the *user* for input mid-task
- **Roots** — host tells server which filesystem paths are in-scope

## stdio vs Streamable HTTP

| | stdio | Streamable HTTP |
|---|---|---|
| Runs where | Same machine | Remote |
| Auth | Process-level | OAuth / bearer / API key |
| Transport | Process pipes | HTTP POST + SSE for streaming |
| Good for | Personal tools, local CLIs | Multi-user, cloud services |
| Packaging | npm / PyPI / binary / `.mcpb` | Hosted service |

Default to stdio unless you specifically need remote.

## 30-minute path to your first server

1. Pick a language: Node (TypeScript, `@modelcontextprotocol/sdk`) or Python (`FastMCP`).
2. Use the `mcp-authoring` plugin (in this repo) — it scaffolds the layout + entrypoint + Zod/type-hint-based schemas.
3. Define 1–3 tools. Keep the input schemas precise.
4. Test with the Inspector: `npx @modelcontextprotocol/inspector <your-server-command>`.
5. Register with Claude Code: `claude mcp add --transport stdio <name> -- <command>`.
6. Start a session, run `/mcp`, and invoke your tool.

## Publishing

The [official MCP Registry](https://registry.modelcontextprotocol.io) is metadata-only. Package code lives on npm / PyPI / Docker Hub / go install. Namespaces: `io.github.<you>/<server>` (verified by GitHub repo) or `com.example/<server>` (verified by DNS).

Minimal `server.json` example in the `mcp-authoring/skills/mcp-publish/SKILL.md` file.

## Gotchas

- **Never print to stdout in a stdio server.** stdout is the JSON-RPC stream. Use stderr or a logger.
- **Use absolute paths in `claude_desktop_config.json`.** CWD is undefined when Claude Desktop launches servers.
- **`env` passes through selectively.** stdio servers inherit only a small subset of the launching shell's env; declare anything you need explicitly in config.
- **Tool descriptions are the routing signal.** The model picks your tool over alternatives based on the description, not the name.

## References

- Spec: [modelcontextprotocol.io/specification](https://modelcontextprotocol.io/specification)
- SDKs: [github.com/modelcontextprotocol](https://github.com/modelcontextprotocol)
- Registry: [registry.modelcontextprotocol.io](https://registry.modelcontextprotocol.io)
- Inspector: [npmjs.com/package/@modelcontextprotocol/inspector](https://www.npmjs.com/package/@modelcontextprotocol/inspector)
