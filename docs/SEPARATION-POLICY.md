# Separation Policy

This repository is **public**. All content is MIT-licensed and available to the world. That has implications for what can and cannot be committed here.

## What belongs here

- Generic, broadly-applicable patterns (frameworks, libraries, protocols, standards)
- Fully generic code samples and scaffolds
- References to public documentation
- ForgePoint Labs branding (we own it)

## What does not belong here

- Client or employer code, architecture, or naming
- Internal product names, internal API shapes, internal service names
- Environment-specific credentials, hostnames, or secrets
- Proprietary business logic of any kind
- Anything you would not want to read aloud to a competitor

## Automated enforcement

`.github/scripts/separation-audit.sh` maintains a list of forbidden substrings. Matches fail the build.

The audit runs:

- **Locally** as a git pre-commit hook (install via `scripts/install-pre-commit-hook.sh`)
- **In CI** as `.github/workflows/audit.yml` on every pull request and push to `main` / `prod`

## Adding a new forbidden pattern

If you discover a leak risk - a new client, a newly-introduced internal term - add it to `FORBIDDEN_PATTERNS` in `.github/scripts/separation-audit.sh`. No PR review threshold; this is a no-brainer.

## What if I need to reference an internal pattern?

Move it to a private repository (e.g. a separate organization-internal marketplace). Do not attempt to publish internal patterns here "with names changed" - the audit catches obvious leaks but not subtle ones, and this is a no-forgiveness zone.

## If you catch a leak after merge

1. Open a revert PR immediately.
2. Force-push after the revert if the content is sensitive enough to warrant removing from git history (`git filter-repo`).
3. Rotate any secrets that touched the repo.
4. Add a new pattern to the audit so it cannot recur.
