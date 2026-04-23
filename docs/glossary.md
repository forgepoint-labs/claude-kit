# Glossary

Plain-English definitions for the Claude Code + MCP + Warp ecosystem. Sorted alphabetically within each section. Technical-only terms are flagged 🔧.

## Model & agent fundamentals

**Agent** - a program that reads, reasons, acts, and loops. Not just a chatbot; it can use tools (run commands, edit files, call APIs). A "Claude Code agent" is Claude running in the Claude Code harness.

**Agent Skill** - a reusable `SKILL.md` markdown file with instructions Claude loads *only when relevant*. Think "chapter of a manual Claude opens when needed." Can include supporting files.

**Agent SDK** 🔧 - Python and TypeScript libraries (`@anthropic-ai/claude-agent-sdk`, `claude-agent-sdk`) that give you programmatic control of the Claude Code agent loop. Used for building custom agents.

**Agent Team** - multiple Claude Code *sessions* working together, messaging each other directly. A "lead" session coordinates; teammates have their own context windows. Experimental - enable with `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`.

**Agentic loop** - the cycle of *gather context → take action → verify* that Claude repeats autonomously. Unlike a chatbot that responds once, Claude chains dozens of steps and self-corrects.

**Auto mode** - a permission mode where a safety classifier model reviews every action before it runs, blocking anything that escalates. Needs Sonnet 4.6 or Opus 4.6/4.7.

## Claude-surface terminology

**Claude Code** - the agentic coding tool (CLI + IDE extensions + desktop + web + Slack + GitHub Actions).

**Claude Code on the Web** - browser interface to run agents on Anthropic-managed VMs.

**Claude Desktop** - the native macOS/Windows Claude app. Hosts Claude Chat + Code tab + Cowork. Reads MCP servers from `claude_desktop_config.json`.

**Claude Design** - Anthropic Labs tool for rapid UI prototyping; generates interactive mocks; can hand off a bundle to Claude Code.

**CLAUDE.md** - a markdown file Claude Code auto-loads at the start of every session. Persistent project context. Lives at repo root or `~/.claude/CLAUDE.md` for personal.

**CLAUDE.local.md** - gitignored personal-project CLAUDE.md.

**Cowork** - Claude Desktop's integration layer: Slack, HubSpot, GCal, Messages, etc.

## Permission & safety

**acceptEdits mode** - auto-approves file edits and safe filesystem commands. Still asks for shell commands.

**Default (ask) mode** - the safe default; Claude asks before any write.

**Plan mode** - read-only; Claude proposes a plan without editing.

**dontAsk mode** 🔧 - everything outside the pre-approved set is denied.

**bypassPermissions mode** 🔧 - NO prompts. For isolated containers/VMs only.

**Protected paths** - paths that never auto-approve (e.g. `.git`, `.claude`).

## Memory & context

**Auto memory** - Claude's own journal saved in `~/.claude/projects/<project>/memory/`.

**Context window** - the max tokens Claude can hold at once.

**Compaction** - when context fills, Claude summarizes old turns. `/compact` triggers manually.

**Output styles** - a system-prompt override (e.g. "Explanatory", "Learning").

## Extension building blocks

**Skill** - atomic unit; YAML frontmatter + markdown body. Auto-invoked by matching `description`, or manually via `/skill-name`.

**Subagent** - a Claude instance spawned inside your main session to do focused work in isolated context. Built-ins: `Explore`, `Plan`, `General-purpose`.

**Plugin** - a *bundle* of skills + agents + hooks + MCP servers, versioned and installable via a marketplace.

**Marketplace** - a git repo containing `.claude-plugin/marketplace.json` that catalogs plugins.

**Hook** - a shell command / HTTP call / LLM prompt run at a lifecycle event (`PreToolUse`, `PostToolUse`, `SessionStart`, etc.).

**Routine** - a *scheduled* Claude Code agent that runs on Anthropic cloud infrastructure.

**Channel** 🔧 - a way for MCP servers to *push* messages into your session.

**Rule** - like CLAUDE.md but path-scoped via frontmatter.

## MCP-specific

**MCP (Model Context Protocol)** - open-source standard for AI apps to connect to external systems. JSON-RPC 2.0 over stdio or Streamable HTTP.

**MCP Host** - the AI app that uses MCP (Claude Code, Claude Desktop, VS Code, Cursor, Warp).

**MCP Client** - a component inside the host that maintains a connection to *one* MCP server.

**MCP Server** - a program exposing Tools / Resources / Prompts over MCP.

**Tool** (MCP) - executable function Claude can call. Model-controlled.

**Resource** (MCP) - read-only data source. Application-controlled.

**Prompt** (MCP) - pre-built template the *user* picks. User-controlled.

**Sampling** (MCP) - servers asking the host to run LLM completions on their behalf.

**Elicitation** (MCP) - servers asking the *user* for input mid-task.

**Roots** (MCP) - filesystem boundaries the client tells the server about.

**Transport** - `stdio` (local pipes) or `Streamable HTTP` (HTTP POST + SSE).

**JSON-RPC 2.0** 🔧 - remote-procedure-call protocol; all MCP messages use it.

**MCPB (MCP Bundle)** - a `.mcpb` archive packaging a local stdio server *with* its runtime.

**MCP Apps** - an extension letting servers render interactive UI widgets inline in chat.

**MCP Registry** - the official directory of public MCP servers.

**MCP Inspector** - browser-based debugger for MCP servers. Run via `npx @modelcontextprotocol/inspector <command>`.

**Scope** (MCP config) - `local` (just you, this project), `project` (shared via `.mcp.json`), `user` (you, all projects).

## Warp / Oz

**Warp** - the agentic terminal. Hosts Warp Agents locally + Oz cloud agents.

**Oz** - Warp's cloud agent platform. CLI: `oz agent run`, `oz agent run-cloud`.

**Oz Environment** - runtime context for cloud agents: repo(s) cloned, network access, env vars, setup scripts.

**Oz Secrets** - managed credential store referenced in agent configs.

**Warp Drive** - shared team workspace (workflows, prompts, rules, env vars, notebooks).

**Warp Rules** - org-wide or team prompts Warp injects into sessions.

**Skill as Agent** - running an Oz agent *based on* a skill (`--skill owner/repo:name`).

## Power features & commands

**/btw** - ask a side question mid-session without adding to the main thread.

**/clear vs /compact** - `/clear` starts a new conversation; `/compact` summarizes the current one.

**/batch** - decompose a huge migration into parallel git-worktree agents.

**/fewer-permission-prompts** - scan your transcript and auto-append an allowlist.

**/ultraplan** - send a planning task to Claude Code on the web; approve back to terminal.

**/ultrareview** - run a multi-agent verified code review in the cloud.

**/insights** - analyze your Claude Code sessions for patterns.

**/cost** - token usage for current session (API users).

**/schedule** - create / list / update routines.

**/context** - visualize what's in context.

**Fast Mode** (`/fast`) - faster Opus at a higher $/token. Research preview.

**Headless mode** (`-p` or `--print`) - run Claude as a one-shot CLI command.

**Checkpointing** - Claude snapshots modified files before edits so you can rewind.
