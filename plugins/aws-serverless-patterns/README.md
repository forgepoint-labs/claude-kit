# aws-serverless-patterns

Generic, framework-agnostic AWS serverless patterns for Node.js Lambda development. These are opinionated defaults - not client-specific.

## Skills

- `middy-lambda-authoring` - scaffold a middy-wrapped Lambda handler with validator, CORS, error handling, and Powertools logger
- `cdk-nested-stack` - CDK pattern for a parent stack composing nested feature stacks
- `sam-api-gateway` - SAM template for a REST API Gateway fronting Lambda handlers
- `powertools-logger` - structured logging with AWS Lambda Powertools (Node.js)

## Assumptions

- Node 22+ (Lambda Node 22 runtime)
- TypeScript 5
- ARM64 Lambdas by default (cheaper + better cold-start on most workloads)
- Middy v5 for middleware
- `@aws-lambda-powertools/*` for logger / tracer / metrics
- `esbuild` via CDK `NodejsFunction` or SAM `esbuild` build method
