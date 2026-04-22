# bubbletea-cli-kit

Opinionated Go 1.25 patterns for building TUI CLIs with the Charm stack (Bubbletea v2 + Bubbles + Lipgloss).

## Skills

- `bubbletea-scaffold` — scaffold a new Bubbletea v2 CLI with sensible defaults (Makefile, `cmd/<app>`, `internal/tui`, release pipeline)
- `bubbletea-list-view` — pattern for a selectable list view with keybindings and status bar
- `bubbletea-form-view` — pattern for a multi-field form with validation
- `bubbletea-test` — testing strategies for Bubbletea models (model-only unit tests + snapshot tests)

## Conventions this plugin encodes

- Go 1.25 modules
- `cmd/<app>/main.go` entrypoint, all logic in `internal/`
- `make install` installs to `~/.local/bin/<app>`
- `-ldflags '-s -w -X main.version=...'` for small release binaries
- Lipgloss styles live in a single `internal/tui/styles.go`
- Keybindings defined once in `internal/tui/keys.go`
