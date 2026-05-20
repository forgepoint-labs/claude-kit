---
name: dynamodb-single-table
description: Design, query, or extend a DynamoDB single-table with partition/sort key conventions, GSI reuse strategy, entity schemas, and multi-tenant isolation. Use when adding a new entity or access pattern, debugging a DDB query, or evaluating whether a new GSI is needed.
---

# DynamoDB single-table design

Patterns for single-table DynamoDB with multi-tenant isolation, GSI reuse, and structured entity schemas.

## Table key schema

- `pk` — partition key, always scoped to the owning tenant: `TENANT#<id>#<ENTITY>` or `TENANT#<id>#<ENTITY>#<entity-id>`
- `sk` — sort key, varies per entity (entity id, timestamp, composite)
- GSIs reuse the same table with alternate key projections:
  - `gsi1` — `gsi1pk` / `gsi1sk` for the most common alternate access pattern
  - `gsi2` / `gsi3` — additional patterns; reuse before adding new GSIs

## Before adding an access pattern

1. **State it precisely**: "Given X, I need Y sorted by Z."
2. **Check existing GSIs** — can one satisfy the pattern with an additional projection?
3. Only add a new GSI if multiple access patterns need it (GSIs are expensive — storage doubles, writes amplify).
4. **Document it** in the entity's package README.

## Entity definition pattern

```ts
// packages/<domain>/schema.ts
export type Order = {
  tenantKey: string;
  orderId: string;
  createdAt: string;   // ISO 8601
  status: string;
  // ... fields
};

export const orderKey = (o: Pick<Order, "tenantKey" | "orderId">) => ({
  pk: `TENANT#${o.tenantKey}#ORDER`,
  sk: `ORDER#${o.orderId}`,
});
```

## Access pattern helpers

```ts
// packages/<domain>/repo.ts
export async function getOrder(tenantKey: string, orderId: string) {
  const { Item } = await ddb.get({
    Key: orderKey({ tenantKey, orderId }),
  });
  return Item as Order | undefined;
}
```

## Common access patterns

- **Get by id** → base table `pk`/`sk`
- **List by tenant + entity** → Query on `pk = TENANT#<id>#<ENTITY>`
- **List by secondary attribute** (e.g. status) → GSI where `gsi1pk = TENANT#<id>#<ENTITY>#<status>`
- **Time-ordered list** → `sk` is ISO timestamp, `ScanIndexForward: false` for reverse
- **Cross-tenant queries** → almost never wanted; these are internal admin ops only

## Streams

DynamoDB Streams enable downstream side effects:

- Search index sync (OpenSearch, Elasticsearch)
- Event-driven triggers (notifications, webhooks)
- Audit trail projection

Filter stream handlers by entity prefix to route events to the right consumer.

## Golden rules

- ✅ Every item includes the tenant identifier in its keys — full isolation.
- ✅ Document every access pattern in the domain's README.
- ✅ Reuse existing GSIs before adding new ones.
- ✅ For stream-driven side effects, add handlers in the same PR as the entity change.
- ❌ Don't Scan in production paths — always Query with a precise `pk`.
- ❌ Don't mix tenant scopes — no cross-tenant reads in application flow.
- ❌ Don't use `ProjectionType: ALL` on GSIs unless you need every attribute — it doubles storage.
