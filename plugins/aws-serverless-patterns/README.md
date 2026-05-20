# aws-serverless-patterns

Generic, framework-agnostic AWS serverless patterns. Opinionated defaults for Lambda, DynamoDB, Step Functions, and the broader serverless ecosystem.

## Skills — Lambda & middleware

- `middy-lambda-authoring` — scaffold a middy-wrapped Lambda handler with validator, CORS, error handling, and Powertools logger
- `powertools-logger` — structured logging with AWS Lambda Powertools (Node.js)

## Skills — IaC (CDK + SAM)

- `cdk-nested-stack` — CDK pattern for a parent stack composing nested feature stacks
- `sam-api-gateway` — SAM template for a REST API Gateway fronting Lambda handlers
- `codebuild-buildspec` — CodeBuild buildspec.yml conventions: phases, caching, artifacts, secret sourcing

## Skills — data & state

- `dynamodb-single-table` — single-table design with GSI reuse, entity schemas, and multi-tenant isolation
- `dynamodb-streams-fanout` — fan out DynamoDB Stream events to multiple consumers with error isolation
- `opensearch-sync` — sync DynamoDB into OpenSearch via Streams for full-text search
- `elasticache-valkey` — Valkey (Redis-compatible) for caching, rate limiting, and idempotency
- `secrets-manager-patterns` — path conventions, IAM scoping, in-Lambda caching, and rotation
- `flyway-migrations` — Flyway SQL migration authoring with idempotent patterns and destructive safeguards

## Skills — networking & security

- `cloudfront-spa` — CloudFront + S3 SPA hosting with OAC, cache policies, and security headers
- `waf-baseline` — AWS WAF with managed rules, rate-based rules, and IP allow/deny sets
- `apigateway-websocket` — API Gateway WebSocket APIs with connection management and broadcast

## Skills — notifications

- `ses-notifications` — SES templated emails, SNS topics, and EventBridge Scheduler for delayed sends

## Skills — orchestration

- `step-functions-workflow` — Step Functions ASL conventions, retry/catch patterns, and service integrations

## Assumptions

- Node 22+ (Lambda Node 22 runtime)
- TypeScript 5
- ARM64 Lambdas by default (cheaper + better cold-start on most workloads)
- Middy v5 for middleware
- `@aws-lambda-powertools/*` for logger / tracer / metrics
- `esbuild` via CDK `NodejsFunction` or SAM `esbuild` build method
