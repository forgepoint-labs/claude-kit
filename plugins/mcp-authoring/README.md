# mcp-authoring

Opinionated scaffold + publish workflow for MCP servers. Complements the official `anthropic/mcp-server-dev` plugin by adding:

- A decision tree for transport (stdio vs Streamable HTTP) and runtime (Node vs Python vs Go)
- Naming + namespacing conventions for publishing to the [MCP Registry](https://registry.modelcontextprotocol.io)
- Repository layout patterns for wrapping existing CLIs as MCP tools
- Test harness checklists using MCP Inspector

## Skills

- `mcp-scaffold-ts` - scaffolds a new stdio MCP server in TypeScript using `@modelcontextprotocol/sdk` + Zod
- `mcp-scaffold-python` - scaffolds a new stdio MCP server using `FastMCP`
- `mcp-wrap-cli` - turns an existing CLI (e.g. Go/Rust binary) into an MCP server by mapping subcommands to tools
- `mcp-publish` - checklist to submit an `io.github.<owner>/<server>` entry to the official Registry
