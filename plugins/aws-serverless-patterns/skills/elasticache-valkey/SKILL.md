---
name: elasticache-valkey
description: Use ElastiCache Valkey (Redis-compatible) for caching, rate limiting, and idempotency in serverless applications. Covers VPC connectivity, key conventions, TTL defaults, and atomic operations. Use when a Lambda needs caching, rate limiting, or distributed locking.
---

# ElastiCache Valkey patterns

Valkey is the Redis-compatible fork used by ElastiCache. It lives in the VPC and is not reachable from the public internet.

## Use cases

- **Session cache** — short-lived session data
- **Rate limiting** — per-tenant, per-endpoint counters
- **Idempotency keys** — dedupe repeated inputs within a TTL window
- **Transient state** — any data with a natural TTL that doesn't warrant DynamoDB

## VPC connectivity

Any Lambda talking to Valkey MUST:

1. Be attached to the VPC (`vpcConfig` in SAM / `vpc` prop in CDK)
2. Be in a private subnet with egress
3. Use a security group allowed ingress to the Valkey port (6379)

Non-VPC Lambdas cannot reach Valkey. Period.

## Client setup

Use a shared client that handles connection pooling and reconnection:

```ts
import Redis from "ioredis";

const valkey = new Redis({
  host: process.env.VALKEY_ENDPOINT,
  port: 6379,
  tls: {},
  lazyConnect: true,
  maxRetriesPerRequest: 3,
});

export { valkey };
```

## Key conventions

Keys use colon-separated namespaces:

```
session:<scope-id>
session:<scope-id>:lock
ratelimit:<service>:<scope-id>:<bucket>
idempotency:<workflow>:<key>
```

## TTL defaults

- Sessions: 15 min (`EX 900`)
- Rate-limit counters: 1 min (`EX 60`)
- Idempotency keys: 1 hour (`EX 3600`)

Define TTL constants in one place — don't scatter magic numbers.

## Atomic rate limiting

```ts
const key = `ratelimit:api:${scopeId}:${bucket}`;
const count = await valkey.incr(key);
if (count === 1) {
  await valkey.expire(key, 60);
}
if (count > limit) {
  throw new Error("Rate limit exceeded");
}
```

Use `INCR` + `EXPIRE`, not `GET` + `SET` — the latter races under concurrency.

## Distributed locking (SETNX)

```ts
const lockKey = `lock:${resource}`;
const acquired = await valkey.set(lockKey, "1", "EX", 30, "NX");
if (!acquired) throw new Error("Resource locked");
try {
  await doWork();
} finally {
  await valkey.del(lockKey);
}
```

## Failover

Valkey cluster has primary + replica. The client auto-handles failover. In a true outage, fall through to the authoritative source (usually DynamoDB) — Valkey is a cache, not a source of truth.

## Golden rules

- ✅ Always set a TTL — unbounded keys leak memory.
- ✅ Use a shared client; never instantiate raw `ioredis` per-handler.
- ✅ Atomic operations for counters (`INCR` + `EXPIRE`).
- ✅ Cache-miss fallback: read from the authoritative source if Valkey is unavailable.
- ✅ VPC attachment is REQUIRED.
- ❌ Don't store anything of record value in Valkey — it's volatile.
- ❌ Don't use `KEYS *` — use `SCAN` with cursors.
