---
name: sam-api-gateway
description: Author a SAM template fronting Lambda handlers with API Gateway REST API - events, CORS, stages, authorizers, and esbuild build. Use when adding a new HTTP endpoint in a SAM project or wiring a new API Gateway from scratch.
---

# SAM API Gateway template

A `template.yaml` pattern for a REST API Gateway fronting Lambda handlers, using esbuild to bundle TypeScript.

## Minimal template

```yaml
AWSTemplateFormatVersion: '2010-09-09'
Transform: AWS::Serverless-2016-10-31

Parameters:
  Environment:
    Type: String
    AllowedValues: [dev, staging, prod]

Globals:
  Function:
    Runtime: nodejs22.x
    Architectures: [arm64]
    MemorySize: 512
    Timeout: 30
    Tracing: Active
    Environment:
      Variables:
        ENV: !Ref Environment
        POWERTOOLS_SERVICE_NAME: my-api
  Api:
    Cors:
      AllowMethods: "'GET,POST,PUT,DELETE,OPTIONS'"
      AllowHeaders: "'Content-Type,Authorization'"
      AllowOrigin: "'*'"                # tighten per env in practice

Resources:
  Api:
    Type: AWS::Serverless::Api
    Properties:
      Name: !Sub my-api-${Environment}
      StageName: !Ref Environment
      TracingEnabled: true

  CreateItemFn:
    Type: AWS::Serverless::Function
    Properties:
      FunctionName: !Sub my-api-${Environment}-create-item
      CodeUri: src/
      Handler: handlers/create-item/index.handler
      Events:
        Api:
          Type: Api
          Properties:
            RestApiId: !Ref Api
            Path: /items
            Method: post
    Metadata:
      BuildMethod: esbuild
      BuildProperties:
        Target: es2022
        Sourcemap: true
        External:
          - "@aws-sdk/*"
          - "aws-lambda"
          - "@aws-lambda-powertools/*"
```

## CORS

For real environments, use `!Sub` to interpolate allowed origins per env rather than `"'*'"`:

```yaml
Parameters:
  AllowedOrigin:
    Type: String
    Default: https://dev.example.com

Globals:
  Api:
    Cors:
      AllowOrigin: !Sub "'${AllowedOrigin}'"
```

## Authorizers

Cognito:

```yaml
Api:
  Type: AWS::Serverless::Api
  Properties:
    Auth:
      DefaultAuthorizer: CognitoAuth
      Authorizers:
        CognitoAuth:
          UserPoolArn: !Ref UserPoolArn
```

Lambda authorizer:

```yaml
Auth:
  DefaultAuthorizer: CustomAuth
  Authorizers:
    CustomAuth:
      FunctionArn: !GetAtt AuthorizerFn.Arn
      Identity:
        Headers: [Authorization]
        ReauthorizeEvery: 60
```

Opt out per function with:

```yaml
Events:
  Api:
    Type: Api
    Properties:
      Auth:
        Authorizer: NONE
```

## Local development

```sh
sam build --cached
sam local start-api --env-vars env.json

# Invoke a specific handler with a test event
sam local invoke CreateItemFn -e events/create-item.json --env-vars env.json
```

## Deploy

```sh
sam deploy --config-env dev --parameter-overrides Environment=dev
```

`samconfig.toml` holds per-env config:

```toml
[dev.deploy.parameters]
stack_name = "my-api-dev"
region = "us-east-1"
confirm_changeset = false
parameter_overrides = "Environment=dev"

[prod.deploy.parameters]
stack_name = "my-api-prod"
region = "us-east-1"
confirm_changeset = true
parameter_overrides = "Environment=prod"
```

## Golden rules

- ✅ Use `BuildMethod: esbuild` for TS - faster, smaller, same metadata shape.
- ✅ Mark `@aws-sdk/*` and Powertools as external - they're in the runtime.
- ✅ ARM64 + Node 22 - cheaper and faster.
- ✅ Cognito authorizer unless you have a reason to roll your own.
- ✅ TracingEnabled + per-function Tracing: Active - X-Ray end-to-end.
- ✅ Tight CORS per env, not `*` in prod.
- ❌ Don't define resource-level CORS per function - use Globals.Api.

## Related skills

- `middy-lambda-authoring` - the handler inside each function
- `powertools-logger` - logging + metrics patterns
- `cdk-nested-stack` - CDK alternative if you're not on SAM
