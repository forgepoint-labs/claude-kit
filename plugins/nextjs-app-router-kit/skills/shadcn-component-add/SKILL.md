---
name: shadcn-component-add
description: Add a shadcn/ui component to a Next.js 16 + Tailwind 4 project via the shadcn CLI, and wire it with design tokens defined in app/globals.css @theme. Use when scaffolding a new shadcn component (button, dialog, input, etc.) or customizing one that was previously generated.
---

# Adding shadcn/ui components

shadcn/ui isn't an npm dependency; it's a CLI that copies component source into your repo. That's the point - you own the code, customize freely.

## Prerequisites

- `components.json` exists at repo root (created by `pnpm dlx shadcn@latest init`)
- Tailwind 4 set up with design tokens in `src/globals.css` under `@theme`
- `src/lib/utils.ts` exports `cn(...)` (created by init)

## Adding a component

```sh
pnpm dlx shadcn@latest add button
pnpm dlx shadcn@latest add dialog dropdown-menu input label   # multiple at once
```

Lands in `src/components/ui/<name>.tsx`.

## `components.json` structure

```json
{
  "$schema": "https://ui.shadcn.com/schema.json",
  "style": "new-york",
  "rsc": true,
  "tsx": true,
  "tailwind": {
    "config": "",
    "css": "src/globals.css",
    "baseColor": "zinc",
    "cssVariables": true
  },
  "aliases": {
    "components": "@/components",
    "utils": "@/lib/utils",
    "ui": "@/components/ui",
    "lib": "@/lib",
    "hooks": "@/hooks"
  }
}
```

`style: "new-york"` is the tighter, more modern variant. `cssVariables: true` wires into the `@theme` block.

## Design tokens in `src/globals.css`

Tailwind 4 uses `@theme` instead of `tailwind.config.js`:

```css
@import "tailwindcss";

@theme {
  --color-background: hsl(0 0% 100%);
  --color-foreground: hsl(240 10% 3.9%);
  --color-primary: hsl(240 5.9% 10%);
  --color-primary-foreground: hsl(0 0% 98%);
  --color-destructive: hsl(0 84.2% 60.2%);
  --radius: 0.5rem;
}

.dark {
  @theme {
    --color-background: hsl(240 10% 3.9%);
    --color-foreground: hsl(0 0% 98%);
    /* ... */
  }
}
```

shadcn components reference these via `bg-primary`, `text-destructive`, etc.

## Customizing a generated component

The file lives in `src/components/ui/<name>.tsx` - edit directly. Common customizations:

- **Size variants**: add to the `cva` `variants: { size: { ... } }` block
- **Color variants**: same, plus you may want new `--color-*` tokens in `@theme`
- **Behavior**: Radix primitives are composed, so wrap with your own logic as needed

## Re-running add

Re-adding a component **overwrites** your customizations. Either:
1. Don't re-run `add` once you've customized
2. Move your customizations into a wrapper component (`@/components/<name>.tsx` that imports `@/components/ui/<name>.tsx`)

The wrapper pattern is cleaner for non-trivial customizations.

## Golden rules

- ✅ Check in `src/components/ui/` - these are your source files, not generated.
- ✅ Use the `cn(...)` helper for conditional classes.
- ✅ Tokens go in `@theme`; components consume them via Tailwind utility classes.
- ✅ For non-trivial customizations, wrap don't edit.
- ❌ Don't mix shadcn components with a second component library - dedupe early.
- ❌ Don't add every component preemptively - add as needed.

## Related skills

- `nextjs-route-scaffold` - where these components get used
- `nextjs-server-action` - common pairing (form + button)
