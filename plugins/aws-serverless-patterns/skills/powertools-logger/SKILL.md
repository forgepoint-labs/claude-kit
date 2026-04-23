---
name: powertools-logger
description: Wire AWS Lambda Powertools Logger (Node.js) into a handler via the middy middleware, with structured logging, correlation ids, sampling, and POWERTOOLS_SERVICE_NAME env var. Use when adding structured logging to a new Lambda or migrating from console.log.
---

# Powertools Logger — structured logging for Lambda

JSON-structured logs in CloudWatch with request context automatically injected. No more `console.log` breadcrumbs.

## Install

```sh
pnpm add @aws-lambda-powertools/logger
```

## Basic usage — middy-wrapped

```ts
import middy from "@middy/core";
import { Logger } from "@aws-lambda-powertools/logger";
import { injectLambdaContext } from "@aws-lambda-powertools/logger/middleware";
import type { APIGatewayProxyHandler } from "aws-lambda";

const logger = new Logger({
  serviceName: "my-service",
  // level defaults to INFO; override via LOG_LEVEL env var in non-prod
});

const baseHandler: APIGatewayProxyHandler = async (event) => {
  logger.info("request received", { path: event.path });

  // business logic...

  logger.info("request complete", { outcome: "ok" });
  return { statusCode: 200, body: JSON.stringify({ ok: true }) };
};

export const handler = middy(baseHandler)
  .use(injectLambdaContext(logger, {
    logEvent: false,           // don't log the full event body (PII risk)
    clearState: true,          // reset persistent keys between invocations
  }));
```

## What the middleware adds automatically

- `function_name`, `function_request_id`, `function_arn`, `function_memory_size`
- `cold_start: true` on the first invocation
- `xray_trace_id` if X-Ray tracing is active
- Correlation id if you call `logger.setCorrelationId(...)` somewhere

## Environment variables

| Variable | Effect |
|---|---|
| `POWERTOOLS_SERVICE_NAME` | service name (overrides constructor) |
| `LOG_LEVEL` | `DEBUG` / `INFO` / `WARN` / `ERROR` / `CRITICAL` |
| `POWERTOOLS_LOG_LEVEL_FORCE` | force level regardless of env |
| `POWERTOOLS_LOG_EVENT` | log full event (dev only) |
| `POWERTOOLS_DEV` | pretty-print + color (local only) |
| `POWERTOOLS_LOGGER_SAMPLE_RATE` | `0.0`–`1.0`: probability to log DEBUG at runtime |

Set via CloudFormation / SAM `Environment.Variables` or CDK `environment`.

## Attaching persistent keys

For keys that should appear on every log line within one invocation (e.g. an org id, customer id, correlation id):

```ts
const baseHandler: APIGatewayProxyHandler = async (event) => {
  const orgId = event.requestContext.authorizer?.claims?.orgId;
  if (orgId) logger.appendKeys({ orgId });

  logger.info("processing");  // includes orgId automatically
  // ...
};
```

`clearState: true` in the middleware wipes these between invocations so keys don't leak across warm starts.

## Sampling debug logs

Capture DEBUG on a fraction of requests in prod without drowning CloudWatch:

```sh
POWERTOOLS_LOGGER_SAMPLE_RATE=0.05   # 5% of invocations log at DEBUG
```

## Errors

Use `logger.error` with the error object as a value, not in the message:

```ts
try {
  await riskyOperation();
} catch (err) {
  logger.error("operation failed", { err, context: "riskyOperation" });
  throw err;
}
```

Powertools serializes `Error` objects (name, message, stack) automatically.

## Local dev ergonomics

```sh
POWERTOOLS_DEV=true LOG_LEVEL=DEBUG pnpm dev
```

Pretty-printed logs with color, structured JSON still under the hood.

## Golden rules

- ✅ Every Lambda has a `serviceName` (via constructor or env var).
- ✅ `injectLambdaContext` middleware on every handler.
- ✅ `logEvent: false` unless you're sure the event contains no PII.
- ✅ `clearState: true` to prevent persistent-key leaks between invocations.
- ✅ Use `logger.error(msg, { err })` — never string-concatenate errors.
- ✅ Don't log secrets, tokens, SSNs, credit data, or session ids.
- ❌ Don't use `console.log` in a Lambda — it loses structure and context.
- ❌ Don't log at DEBUG in prod without sampling.

## Related skills

- `middy-lambda-authoring` — the handler pattern this middleware wraps
- `sam-api-gateway` — wiring `POWERTOOLS_SERVICE_NAME` at the SAM level
- `cdk-nested-stack` — wiring it at the CDK level via `environment`
