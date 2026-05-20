---
name: mcp-scaffold-python
description: Scaffold a new stdio MCP server in Python using FastMCP. Use when the user wants a Python MCP server, is in a Python-heavy project, or wants to expose Python code to Claude.
---

# Scaffold a Python stdio MCP server (FastMCP)

Use when the user wants an MCP server in Python - FastMCP is the lowest-friction option and ships with the official `mcp` SDK.

## Decision questions (ask first)

1. **Python version**: 3.11+ recommended (use `uv` for env management)
2. **What tools** will this server expose? (3-5 tool names + descriptions)
3. **Deployment**: local only, internal network, or public?

## Layout

```
my-mcp/
├── pyproject.toml
├── README.md
└── my_mcp/
    ├── __init__.py
    └── server.py     # entrypoint
```

## Entrypoint template

```python
from mcp.server.fastmcp import FastMCP
import sys

mcp = FastMCP("my-mcp")

@mcp.tool()
def example(input: str) -> str:
    """Short description shown to the model.

    Args:
        input: What this argument does.
    """
    return f"You sent: {input}"

if __name__ == "__main__":
    mcp.run(transport="stdio")
```

## Golden rules

- ❌ Never `print()` to stdout - stdout is the JSON-RPC stream. Use `print(..., file=sys.stderr)` or the `logging` module.
- ✅ FastMCP auto-derives the schema from **type hints + docstrings**. Write clear Google-style docstrings.
- ✅ Include a `[project.scripts]` entry in `pyproject.toml` (`my-mcp = "my_mcp.server:mcp.run"`) so `uvx my-mcp` works.

## Test with Inspector

```sh
npx @modelcontextprotocol/inspector uv --directory . run my_mcp/server.py
```

## Install in Claude Code

```sh
claude mcp add --transport stdio my-mcp \
  -- uv --directory /abs/path/to/my-mcp run my_mcp/server.py
```
