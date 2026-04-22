---
name: bubbletea-scaffold
description: Scaffold a new Go TUI CLI using Bubbletea v2, Bubbles, and Lipgloss with a clean layout (cmd/ + internal/tui/ + Makefile). Use when the user wants a new Go CLI, a terminal UI, or a Bubbletea project.
---

# Scaffold a Bubbletea v2 CLI

Use when the user wants a fresh Go TUI CLI. Default to Go 1.25 modules.

## Decision questions (ask first)

1. **CLI name** (lowercase, hyphen-separated)
2. **Purpose in one sentence** (for the README + `--help`)
3. **GitHub integration?** If yes, use `cli/go-gh/v2` (avoid re-rolling `gh` auth).
4. **Single screen or multi-view?** Start with single screen unless there's a clear reason to nest.

## Layout

```
<app>/
├── go.mod
├── Makefile
├── README.md
├── cmd/
│   └── <app>/
│       └── main.go        # entrypoint, wires TUI
├── internal/
│   └── tui/
│       ├── model.go       # tea.Model impl
│       ├── update.go      # Msg handling
│       ├── view.go        # render
│       ├── styles.go      # Lipgloss styles
│       └── keys.go        # Keymap definitions
└── bin/                    # build output
```

## Entrypoint template

```go
package main

import (
	"fmt"
	"os"

	tea "github.com/charmbracelet/bubbletea/v2"
	"github.com/forgepoint-labs/<app>/internal/tui"
)

var version = "dev"

func main() {
	p := tea.NewProgram(tui.New(), tea.WithAltScreen())
	if _, err := p.Run(); err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
}
```

## Makefile

```makefile
APP ?= <app>
VERSION ?= $(shell git describe --tags --always --dirty)
LDFLAGS := -s -w -X main.version=$(VERSION)

.PHONY: build install test clean

build:
	go build -ldflags '$(LDFLAGS)' -o bin/$(APP) ./cmd/$(APP)

install: build
	mkdir -p $(HOME)/.local/bin
	cp bin/$(APP) $(HOME)/.local/bin/$(APP)

test:
	go test ./...

clean:
	rm -rf bin/
```

## Golden rules

- ✅ Use Bubbletea **v2** (the v2 API is significantly cleaner).
- ✅ Always call `tea.WithAltScreen()` for full-screen apps.
- ✅ Keep `Update` side-effect-free — return commands (`tea.Cmd`) for I/O.
- ✅ Split large models into sub-models; don't jam everything into one `Update` switch.
- ✅ Define all keybindings in `internal/tui/keys.go` via `key.Binding` — makes help text trivial.
- ❌ Don't print to stdout/stderr inside a Bubbletea program; use `tea.Println` or collect messages.
