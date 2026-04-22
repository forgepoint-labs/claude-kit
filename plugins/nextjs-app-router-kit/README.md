# nextjs-app-router-kit

Conventions for Next.js 16 + App Router + React 19 + TypeScript 5 + Tailwind CSS 4 + shadcn/ui projects.

## Skills

- `nextjs-route-scaffold` — scaffold a route segment (page, loading, error, layout) with server components by default
- `nextjs-server-action` — shape a Server Action with auth check + Zod validation + returning a `{ ok, data } | { ok: false, error }` discriminated union
- `shadcn-component-add` — add a shadcn/ui component and wire Tailwind 4 tokens

## Assumptions baked into the skills

- React Server Components by default; `"use client"` only when strictly required (event handlers, state, browser APIs)
- Tailwind CSS 4 with the `@theme` directive; design tokens live in `app/globals.css`
- `@/` path alias → `src/`
- `pnpm` as package manager
- `Makefile` wrapping common tasks (`make dev`, `make build`, `make lint`)
- Dark mode via `next-themes` with `className` strategy
