---
name: middy-lambda-authoring
description: Scaffold a middy-wrapped AWS Lambda handler with JSON Schema validation, CORS, HTTP error handling, and Powertools structured logging. Use when creating a new Node.js Lambda handler behind API Gateway.
---

# Middy-wrapped Lambda handler

Use when creating a new Node.js Lambda behind API Gateway REST or HTTP API.

## Decision questions (ask first)

1. **Handler purpose** - one sentence.
2. **Auth** - public, API key, Cognito, custom authorizer?
3. **Inputs** - path params, query, body. What's the shape?
4. **VPC** - does this need VPC attachment (e.g. RDS, ElastiCache)?
5. **Timeout + memory** - default is 90s / 512MB unless the user has a reason to change.

## Layout

```
src/handlers/<name>/
├── index.ts          # handler entrypoint
├── schema.ts         # JSON Schema for input validation
└── index.test.ts     # unit test
```

## Handler template

```ts
import middy from "@middy/core";
import validator from "@middy/validator";
import { transpileSchema } from "@middy/validator/transpile";
import httpErrorHandler from "@middy/http-error-handler";
import cors from "@middy/http-cors";
import { Logger } from "@aws-lambda-powertools/logger";
import type { APIGatewayProxyHandler } from "aws-lambda";
import { inputSchema } from "./schema.js";

const logger = new Logger({ serviceName: "<service>" });

const baseHandler: APIGatewayProxyHandler = async (event) => {
  logger.info("handler invoked", { path: event.path });

  // business logic here

  return {
    statusCode: 200,
    body: JSON.stringify({ ok: true }),
  };
};

export const handler = middy(baseHandler)
  .use(validator({ eventSchema: transpileSchema(inputSchema) }))
  .use(httpErrorHandler())
  .use(cors());
```

## schema.ts

```ts
export const inputSchema = {
  type: "object",
  required: ["body"],
  properties: {
    body: {
      type: "object",
      required: ["example"],
      properties: {
        example: { type: "string", minLength: 1 },
      },
    },
  },
};
```

## Powertools gotchas

- Set `POWERTOOLS_SERVICE_NAME` as a Lambda env var for consistent log attribution.
- Use `@aws-lambda-powertools/tracer` with `captureLambdaHandler` middleware for X-Ray spans.
- Use `@aws-lambda-powertools/metrics` with `logMetrics` middleware to emit EMF-formatted CloudWatch metrics cheaply.

## Golden rules

- ✅ Every handler is wrapped in `middy` - no raw handlers.
- ✅ Validate with JSON Schema at the middleware layer, not inside the handler.
- ✅ Throw `createError(400, "…")` from `http-errors` for client errors; `httpErrorHandler` translates to clean responses.
- ✅ Log via `logger.info/warn/error`, not `console.*`.
- ✅ ARM64 + Node 22 unless a native dep forces x86_64.
- ❌ Don't bundle `@aws-sdk/*` - mark as external; they're provided by the runtime.
