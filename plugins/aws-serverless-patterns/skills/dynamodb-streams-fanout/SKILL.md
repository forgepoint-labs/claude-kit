---
name: dynamodb-streams-fanout
description: Fan out DynamoDB Stream events to multiple downstream consumers - search sync, webhooks, notifications, audit trails - with entity-prefix filtering, idempotent handlers, and error isolation. Use when adding a new stream consumer or debugging a broken downstream sync.
---

# DynamoDB Streams fanout

Patterns for routing DynamoDB Stream events to multiple downstream consumers with proper filtering and error isolation.

## Architecture

```
DynamoDB table (Streams enabled)
  → Lambda event source mapping (batch size 10-100)
  → Router handler
    → OpenSearch sync (search indexing)
    → Webhook dispatcher (external notifications)
    → Audit trail writer (compliance)
    → Notification trigger (user alerts)
```

## Entity-prefix filtering

Single-table designs produce mixed stream events. Filter by entity prefix:

```ts
import { DynamoDBStreamHandler } from "aws-lambda";
import { unmarshall } from "@aws-sdk/util-dynamodb";

export const handler: DynamoDBStreamHandler = async (event) => {
  for (const record of event.Records) {
    const image = record.dynamodb?.NewImage
      ? unmarshall(record.dynamodb.NewImage)
      : null;

    const pk = image?.pk as string || "";

    if (pk.includes("#ORDER")) {
      await handleOrderChange(record);
    } else if (pk.includes("#REPORT")) {
      await handleReportChange(record);
    }
    // Unknown entity prefixes are silently skipped
  }
};
```

## Event source mapping config

```ts
// CDK
new EventSourceMapping(this, "StreamMapping", {
  target: streamHandler,
  eventSourceArn: table.tableStreamArn!,
  startingPosition: StartingPosition.TRIM_HORIZON,
  batchSize: 25,
  maxBatchingWindow: Duration.seconds(5),
  bisectBatchOnError: true,
  retryAttempts: 3,
  reportBatchItemFailures: true,
  filters: [
    FilterCriteria.filter({
      eventName: FilterRule.isEqual("INSERT"),
    }),
    FilterCriteria.filter({
      eventName: FilterRule.isEqual("MODIFY"),
    }),
  ],
});
```

Key settings:
- `bisectBatchOnError: true` — isolates poison records by splitting the batch
- `reportBatchItemFailures: true` — returns partial failures instead of retrying the whole batch
- `maxBatchingWindow` — trade latency for throughput

## Partial batch failure reporting

```ts
export const handler: DynamoDBStreamHandler = async (event) => {
  const failures: string[] = [];

  for (const record of event.Records) {
    try {
      await processRecord(record);
    } catch (err) {
      failures.push(record.eventID!);
      logger.error("Failed to process record", { eventID: record.eventID, err });
    }
  }

  return {
    batchItemFailures: failures.map((id) => ({ itemIdentifier: id })),
  };
};
```

## Idempotency

Stream events can replay. Every handler must be idempotent:

- Use the `eventID` as an idempotency key if needed.
- Upserts into OpenSearch / downstream are naturally idempotent.
- Side effects (emails, webhooks) need dedup via a cache key (Valkey / DynamoDB).

## Error isolation

Don't let one consumer failure block others:

```ts
await Promise.allSettled([
  syncToOpenSearch(record),
  dispatchWebhook(record),
  writeAuditTrail(record),
]);
```

Log failures per consumer; don't throw unless ALL consumers fail.

## Golden rules

- ✅ Filter by entity prefix — don't process events you don't care about.
- ✅ `bisectBatchOnError` + `reportBatchItemFailures` — isolate poison records.
- ✅ Every handler is idempotent — stream replays must produce the same result.
- ✅ Error isolation between consumers — use `Promise.allSettled`.
- ✅ Monitor per-consumer error rates separately.
- ❌ Don't process the entire record if you only need the key — use `Keys` projection.
- ❌ Don't block all consumers because one is failing.
