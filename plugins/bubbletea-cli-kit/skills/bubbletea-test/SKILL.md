---
name: bubbletea-test
description: Test a Bubbletea v2 TUI model by driving Update with synthetic messages (pure, fast) and snapshotting View output for regression. Use when adding tests for a Bubbletea model, debugging a flaky UI, or setting up the test harness for a new CLI.
---

# Testing Bubbletea models

Bubbletea's model is pure: `Init`, `Update`, and `View` are deterministic functions of the current model + incoming message. That makes unit testing trivial.

## Two test styles

1. **Model-only unit tests** - drive `Update` with synthetic messages, assert on the returned model state. Fast, no I/O, no TTY.
2. **Golden-file snapshot tests** - render `View()` with a fixed window size, compare to a stored `.golden` file. Catch rendering regressions.

Both live under `internal/tui/` alongside the model.

## Model-only test

```go
func TestListModel_SelectsItem(t *testing.T) {
	m := New([]list.Item{
		item{title: "alpha"},
		item{title: "beta"},
	})
	m, _ = m.Update(tea.WindowSizeMsg{Width: 80, Height: 24}).(Model), nil

	// simulate j + enter
	m, _ = m.Update(tea.KeyMsg{Type: tea.KeyRunes, Runes: []rune("j")}).(Model), nil
	m, _ = m.Update(tea.KeyMsg{Type: tea.KeyEnter}).(Model), nil

	if m.picked != "beta" {
		t.Fatalf("picked = %q, want %q", m.picked, "beta")
	}
}
```

## Golden-file snapshot test

```go
func TestListModel_View(t *testing.T) {
	m := New([]list.Item{
		item{title: "alpha"},
		item{title: "beta"},
	})
	m, _ = m.Update(tea.WindowSizeMsg{Width: 80, Height: 24}).(Model), nil

	got := m.View()
	goldenFile := "testdata/list_view.golden"

	if *update {
		os.WriteFile(goldenFile, []byte(got), 0644)
	}
	want, err := os.ReadFile(goldenFile)
	if err != nil { t.Fatal(err) }

	if got != string(want) {
		t.Errorf("View() mismatch.\ngot:\n%s\n\nwant:\n%s", got, want)
	}
}

var update = flag.Bool("update", false, "update golden files")
```

Run `go test -update ./internal/tui/...` once to regenerate goldens after intentional changes.

## `teatest` (official test helper)

For end-to-end tests that exercise the full program:

```go
import "github.com/charmbracelet/x/exp/teatest/v2"

func TestProgram(t *testing.T) {
	tm := teatest.NewTestModel(t, New(...), teatest.WithInitialTermSize(80, 24))
	tm.Send(tea.KeyMsg{Type: tea.KeyRunes, Runes: []rune("j")})
	tm.Send(tea.KeyMsg{Type: tea.KeyEnter})
	fm := tm.FinalModel(t).(Model)
	if fm.picked != "beta" { t.Fatal("bad pick") }
}
```

`teatest` handles timing, buffers output, and is the most realistic test harness.

## Golden rules

- ✅ Keep `Update` pure - no I/O. I/O goes in `tea.Cmd`s, which you can mock.
- ✅ Model-only tests for business logic; snapshot tests for rendering regressions.
- ✅ Use `teatest` for full program flows.
- ✅ Commit `.golden` files to git - they're the UI contract.
- ❌ Don't snapshot on a non-fixed window size - fail non-deterministically.
- ❌ Don't sleep or poll in tests - use `tea.Cmd` + an injected fake clock if you need time.

## Related skills

- `bubbletea-scaffold` - the model under test
- `bubbletea-list-view` / `bubbletea-form-view` - typical test targets
