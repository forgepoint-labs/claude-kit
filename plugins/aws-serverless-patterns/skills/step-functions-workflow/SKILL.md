---
name: step-functions-workflow
description: Author or debug an AWS Step Functions state machine with ASL conventions, retry and error-handler patterns, service integrations, and CDK/SAM wiring. Use when creating a new workflow, adding a state to an existing machine, or debugging a failing execution.
---

# Step Functions — ASL conventions

Patterns for building reliable Step Functions workflows with proper retry, catch, and observability.

## Standard ASL shape

```json
{
  "Comment": "Order processing workflow",
  "StartAt": "ValidateInput",
  "States": {
    "ValidateInput": {
      "Type": "Task",
      "Resource": "${ValidateFn.Arn}",
      "ResultPath": "$.validation",
      "Retry": [
        {
          "ErrorEquals": ["States.TaskFailed"],
          "IntervalSeconds": 2,
          "MaxAttempts": 3,
          "BackoffRate": 2.0
        }
      ],
      "Catch": [
        {
          "ErrorEquals": ["States.ALL"],
          "ResultPath": "$.error",
          "Next": "HandleFailure"
        }
      ],
      "Next": "ProcessOrder"
    }
  }
}
```

## Retry + error-handler conventions

- **Every Task state** gets a `Retry` for `States.TaskFailed` with exponential backoff.
- **Every Task state** gets a `Catch` routing to a shared `HandleFailure` state.
- `HandleFailure` logs the error, emits a failure event (SNS/EventBridge), updates entity status, and ends.
- Don't swallow errors silently — always route to `HandleFailure`.

## Input / Output conventions

- Use `ResultPath` to merge Task outputs into the workflow state instead of overwriting.
- Avoid `InputPath` unless strictly needed; prefer clean state objects passed forward.
- Keep state payload < 256KB. Large payloads (report HTML, file data) go in S3 + reference by key.

## Lambda tasks vs service integrations

- **Lambda Task** — flexible business logic, but invokes a whole function. Use for custom logic.
- **AWS SDK integration** (`arn:aws:states:::aws-sdk:s3:putObject`) — no Lambda needed. Use for pure AWS API calls.

Prefer service integrations for simple operations — one fewer cold start, one fewer IAM role, cheaper.

## Defining in CDK

```ts
import { StateMachine, DefinitionBody } from "aws-cdk-lib/aws-stepfunctions";

new StateMachine(this, "OrderMachine", {
  stateMachineName: `${props.prefix}-order-machine`,
  definitionBody: DefinitionBody.fromFile("state-machines/order/definition.json"),
  definitionSubstitutions: {
    ValidateFn: validateFn.functionArn,
    ProcessFn: processFn.functionArn,
  },
  tracingEnabled: true,
  logs: { destination: logGroup, level: LogLevel.ALL, includeExecutionData: true },
});
```

## Debugging a failed execution

1. Open Step Functions console → failing execution → Graph view.
2. Red state = the one that failed; click for input/output/error.
3. If a Task failed: check the Lambda's CloudWatch logs for that `executionArn`.
4. If a Choice state routed wrong: check JSONPath conditions against actual state.
5. Use "Redrive" to resume from a failed state after fixing the cause.

## Golden rules

- ✅ Every Task has Retry + Catch.
- ✅ Every machine has a single `HandleFailure` state that logs + emits.
- ✅ Use service integrations when the step is a pure AWS API call.
- ✅ `tracingEnabled: true` always — X-Ray traces workflows end-to-end.
- ✅ Test machines with representative inputs before promoting to production.
- ❌ Don't embed business logic in Choice states — keep them simple comparisons.
- ❌ Don't pass large payloads between states — offload to S3 and pass keys.
