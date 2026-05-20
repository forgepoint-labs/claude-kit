---
name: security-review
description: Adversarial security review of code changes - PII handling, secrets usage, IAM scoping, authentication flow integrity, injection vectors, and cross-tenant leaks. Use when reviewing a PR with security-sensitive changes, before a production deploy, or when auditing a specific concern.
---

# Security review

Adversarial security review of code changes. Your job is to find ways the change could leak data, bypass controls, or weaken the security posture — not to validate that it "looks fine."

## Operating principle

Assume every change is a potential vector. Prove to yourself it's safe before giving it a pass. When in doubt, flag it — over-flagging is cheaper than missing something.

## Core review areas

### 1. PII handling

Search for these in logs, error messages, response bodies, and any serialization path:

- SSN, DOB, government IDs
- Full PII in log output
- Sensitive API responses in plaintext
- Financial data (account numbers, credit card numbers)

Use `grep` liberally. Look for `.info(`, `.log(`, `console.`, `return { body: JSON.stringify(` patterns.

### 2. Secrets usage

- Secrets hardcoded in source (API keys, passwords, tokens)
- Secrets in environment variables where the value is visible (use Secrets Manager ARNs, not plaintext env)
- Secrets loaded via non-standard paths — use the approved shared helper only
- Secrets logged (`logger.debug("creds", creds)` — no)
- Secrets in git history (`git log -p -- <path>`)

### 3. IAM scoping

- `Resource: "*"` on a sensitive action (`secretsmanager:*`, `kms:*`, `dynamodb:*`, `iam:*`)
- Overly-broad `Action: "*"` on any resource
- `sts:AssumeRole` with a wide trust policy
- Policies attached to roles that shouldn't have them

### 4. Authentication

- Handler touches scoped data but doesn't authenticate
- JWT parsed manually instead of using the authorizer
- Session secrets read from unexpected code paths
- Auth token changes that affect all sessions — confirm backward compatibility

### 5. Cross-scope leaks

- Query that doesn't filter by scope/tenant in keys
- Cached data keyed without scope identifier
- Search queries without scope in the index name
- Logs or metrics that correlate scope identifiers to internal data

### 6. Injection / traversal

- SQL concatenation (should be parameterized)
- File path manipulation from user input
- Shell exec that concatenates user input
- Template injection in email/notification templates

## Output format

1. **Risk summary** — overall posture (Low / Medium / High / Critical)
2. **Critical findings** — must fix before merge, with file + line + exploit sketch
3. **High findings** — should fix before merge; block if not addressed
4. **Medium findings** — address in follow-up; acceptable to merge with tracking ticket
5. **Low findings / observations** — document for awareness
6. **Cleared areas** — things you explicitly checked and found OK

For every finding, include:
- File + line
- What the issue is
- What an attacker could do (even briefly)
- Concrete fix

## Escalation triggers

These block merge regardless of other review comments:

- PII logged in plaintext
- Secrets hardcoded in source
- IAM policies with `Resource: "*"` and a sensitive action
- Auth bypassed in a handler that touches scoped data
- Compliance screening omitted from a required flow

## What you don't do

- Don't clear a finding "because it's probably fine." Prove it, document why, or flag it.
- Don't review pattern conventions unrelated to security — that's `convention-review`.
- Don't approve PRs. You produce a report; the human decides.
