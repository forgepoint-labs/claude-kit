---
name: svg-component-add
description: Convert SVG files to React components for Next.js 16 + Tailwind 4 projects using SVGR. Handles Illustrator exports, programmatic fill via currentColor, viewBox preservation, and responsive sizing. Use when adding SVG logos, icons, or illustrations as inline React components.
---

# Converting SVGs to React components

Turn SVG files into typed React components that support programmatic color and sizing via Tailwind classes.

## When to use this vs next/image

- **Inline React component** (this skill): when you need programmatic fill colors, theme-aware rendering, or CSS animations on the SVG paths. Typical for logos, icons, and brand marks.
- **next/image**: when the SVG is decorative, static, or very large and you don't need to control individual paths. Better for illustrations where bundle size matters.

## Prerequisites

No install needed. Uses `npx` to run tools on demand:

- `svgo` (SVG optimizer) - strips Illustrator/Figma export cruft
- `@svgr/cli` (SVG to React) - converts to typed TSX components

## Step 1: Optimize the SVG

```sh
npx svgo -f src/assets/svgs/ -o src/assets/svgs/
```

Typical reduction: 25-40% on Illustrator exports.

## Step 2: Convert to React components

```sh
npx @svgr/cli \
  --typescript \
  --jsx-runtime automatic \
  --no-dimensions \
  --svgo-config '{"plugins":[{"name":"preset-default","params":{"overrides":{"removeViewBox":false}}}]}' \
  --out-dir src/components/logos \
  src/assets/svgs/
```

Critical flags:
- `--no-dimensions` removes hardcoded `width`/`height` so sizing is controlled via CSS
- `removeViewBox: false` MUST be set. Without `viewBox`, SVGs collapse to zero size when dimensions are removed. This is the most common mistake.
- `--typescript` generates `.tsx` with `SVGProps<SVGSVGElement>` typing
- `--jsx-runtime automatic` avoids explicit React imports

SVGR generates a barrel `index.ts` automatically.

## Step 3: Fix fills for programmatic color

SVGO lowercases hex colors, so `--replace-attr-values "#EAB308=currentColor"` won't match `#eab308`. Run sed after SVGR:

```sh
sed -i '' 's/fill="#eab308"/fill="currentColor"/g' src/components/logos/*.tsx
```

For multiple fill colors, chain replacements:

```sh
sed -i '' \
  -e 's/fill="#eab308"/fill="currentColor"/g' \
  -e 's/fill="#1a1a1a"/fill="currentColor"/g' \
  src/components/logos/*.tsx
```

If the SVG has multiple distinct colors that need independent control, keep the fills as-is and use CSS custom properties instead.

## Step 4: Clean up Illustrator artifacts

```sh
sed -i '' 's/ xmlSpace="preserve"//g' src/components/logos/*.tsx
```

## Usage in components

With `fill="currentColor"`, the SVG inherits its color from the CSS `color` property. Tailwind's `text-*` classes control it:

```tsx
import { Logo } from "@/components/logos";

// Fixed brand color
<Logo className="h-12 w-auto text-brand-gold" />

// Theme-aware: dark gold, light foreground
<Logo className="h-12 w-auto text-foreground dark:text-brand-gold" />

// Responsive sizing via width constraints (better for wide logos)
<Logo className="h-auto w-full max-w-md sm:max-w-2xl lg:max-w-5xl" />
```

### Sizing strategy

- **Square/portrait SVGs** (1:1 ratio): use `h-*` with `w-auto`
- **Wide/landscape SVGs** (2:1+ ratio): use `w-full` with `max-w-*` breakpoints and `h-auto`. This scales naturally with the viewport.
- Never set both `h-*` and `w-*` on an SVG unless you want to distort the aspect ratio.

## Common pitfalls

- **SVG renders at zero size**: `viewBox` was removed. Regenerate with `removeViewBox: false`.
- **Color doesn't change**: fill is still hardcoded hex. Check `grep -r 'fill="#' src/components/logos/` and replace with `currentColor`.
- **SVG has wrong aspect ratio**: the original `viewBox` doesn't match the visible content. Open the raw SVG and adjust the viewBox bounds.
- **Bundle too large**: Illustrator SVGs with hundreds of anchor points bloat the JS bundle. Consider using `next/image` for non-interactive SVGs, or run SVGO with `convertPathData` and `mergePaths` enabled.
- **Multiple colors in one SVG**: don't blanket-replace all fills with `currentColor`. Instead, use CSS custom properties or separate the SVG into layered components.

## Regenerating after source changes

Re-running SVGR overwrites all components. If you've customized a component, either:
1. Edit the source SVG and regenerate
2. Wrap the generated component instead of editing it directly

## Related skills

- `shadcn-component-add` - when the SVG is used inside a shadcn component
- `nextjs-route-scaffold` - pages where SVG components get used
