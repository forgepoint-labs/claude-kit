---
name: bubbletea-form-view
description: Implement a multi-field form in Bubbletea v2 with focus management, per-field validation, and submit/cancel flow. Use when the user wants a TUI form to collect multiple inputs (new PR, issue template, config setup, etc.).
---

# Bubbletea multi-field form view

Use when the user wants a TUI form — several text / textarea / select fields, Tab to move between them, Enter to submit.

## Two idioms

- **For 1-4 simple text fields**: hand-roll with `bubbles/textinput` and `bubbles/textarea`, tracked focus index.
- **For 5+ fields or complex flows**: use `huh` (`github.com/charmbracelet/huh`) — it's the forms framework from Charm, built on Bubbletea, with built-in validation and theme support.

Default to `huh` unless the user has a strong reason to hand-roll.

## `huh` skeleton (preferred)

```go
import "github.com/charmbracelet/huh"

form := huh.NewForm(
	huh.NewGroup(
		huh.NewInput().
			Title("PR title").
			Validate(func(s string) error {
				if len(s) < 5 { return fmt.Errorf("too short") }
				return nil
			}).
			Value(&title),
		huh.NewSelect[string]().
			Title("Label").
			Options(
				huh.NewOption("bug", "bug"),
				huh.NewOption("feature", "feature"),
				huh.NewOption("chore", "chore"),
			).
			Value(&label),
		huh.NewText().
			Title("Description").
			CharLimit(2000).
			Value(&description),
	),
)
if err := form.Run(); err != nil { return err }
```

## Hand-rolled skeleton (simple forms)

```go
type Model struct {
	inputs    []textinput.Model
	focus     int
	submitted bool
}

func (m Model) Update(msg tea.Msg) (tea.Model, tea.Cmd) {
	switch msg := msg.(type) {
	case tea.KeyMsg:
		switch msg.String() {
		case "tab", "down":
			m.focus = (m.focus + 1) % len(m.inputs)
		case "shift+tab", "up":
			m.focus = (m.focus - 1 + len(m.inputs)) % len(m.inputs)
		case "enter":
			if m.focus == len(m.inputs)-1 {
				m.submitted = true
				return m, tea.Quit
			}
		}
		for i := range m.inputs {
			m.inputs[i].Blur()
		}
		m.inputs[m.focus].Focus()
	}
	var cmd tea.Cmd
	m.inputs[m.focus], cmd = m.inputs[m.focus].Update(msg)
	return m, cmd
}
```

## Validation

- Per-field validators run on value change (huh) or on submit (hand-rolled).
- Surface errors inline next to the field, not as a popup.
- Disable submit until all required fields validate.

## Golden rules

- ✅ Default to `huh` — avoid reinventing focus management.
- ✅ One Enter on the last field submits; Esc or Ctrl+C cancels.
- ✅ Validate on-commit, not on keystroke (except for trivial checks like non-empty).
- ✅ Show a clear "submitting…" state after Enter — long operations need feedback.
- ❌ Don't stack more than one form on screen at once; push a new model instead.

## Related skills

- `bubbletea-scaffold` — the outer program
- `bubbletea-list-view` — often precedes a form ("pick X, then fill out…")
