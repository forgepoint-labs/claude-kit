---
name: secrets-manager-patterns
description: Manage AWS Secrets Manager with path conventions, IAM policy scoping, in-Lambda caching, and rotation strategies. Use when adding a new secret, scoping a Lambda's IAM policy, or designing a secret path hierarchy.
---

# Secrets Manager patterns

Conventions for organizing, accessing, and rotating secrets in AWS Secrets Manager.

## Path conventions

Organize secrets by service domain with hierarchical paths:

```
/<domain>/<purpose>
/<domain>/<scope>/<detail>
```

Example layout:

| Prefix | Purpose |
|---|---|
| `/app/session/*` | Application session secrets |
| `/app/oauth/*` | OAuth client secrets |
| `/integrations/<provider>/*` | Third-party API credentials |
| `/ci/*` | CI/CD tokens (GitHub, npm) |
| `/db/*` | Database connection strings |

Consistent naming = tight IAM scoping. Never invent ad-hoc prefixes.

## Loading secrets in a Lambda

Build a shared helper that caches in memory:

```ts
import { SecretsManagerClient, GetSecretValueCommand } from "@aws-sdk/client-secrets-manager";

const client = new SecretsManagerClient({});
const cache = new Map<string, { value: string; expiry: number }>();
const TTL = 5 * 60 * 1000; // 5 minutes

export async function getSecret<T = string>(secretId: string): Promise<T> {
  const cached = cache.get(secretId);
  if (cached && Date.now() < cached.expiry) {
    return JSON.parse(cached.value) as T;
  }

  const { SecretString } = await client.send(
    new GetSecretValueCommand({ SecretId: secretId })
  );
  if (!SecretString) throw new Error(`Secret not found: ${secretId}`);

  cache.set(secretId, { value: SecretString, expiry: Date.now() + TTL });
  return JSON.parse(SecretString) as T;
}
```

- Caches for the Lambda's lifetime (warm invocations skip API calls)
- Returns typed objects with a generic parameter
- Throws on missing secrets — don't catch this; let it crash

## IAM policy scoping

### SAM
```yaml
Policies:
  - Statement:
      - Effect: Allow
        Action: [secretsmanager:GetSecretValue]
        Resource: !Sub arn:aws:secretsmanager:${AWS::Region}:${AWS::AccountId}:secret:/integrations/stripe/*
```

### CDK
```ts
fn.addToRolePolicy(new PolicyStatement({
  actions: ["secretsmanager:GetSecretValue"],
  resources: [
    `arn:aws:secretsmanager:${this.region}:${this.account}:secret:/integrations/stripe/*`,
  ],
}));
```

Wildcard on path suffix only. Never `Resource: "*"` for secrets.

## Adding a new secret

1. Choose the right prefix from the path hierarchy.
2. Create via CloudFormation / CDK — never manually in the console.
3. Scope the reading Lambda's IAM policy to the specific prefix.
4. Document the purpose and rotation cadence in the owning stack's README.
5. If shared across services, create it in an infrastructure stack so it's provisioned once per env.

## Rotation strategies

- **Auto-rotated**: use Secrets Manager's built-in rotation with a Lambda rotation function.
- **OAuth refresh tokens**: auto-refresh in the consuming Lambda, write back to Secrets Manager.
- **Manual rotation**: set a CloudWatch alarm on secret age (e.g. > 90 days = alert).

## Golden rules

- ✅ Follow the path hierarchy. No ad-hoc prefixes.
- ✅ IAM policies scoped by path prefix — wildcard suffix, not whole ARN.
- ✅ Use a shared `getSecret` helper with in-memory caching.
- ✅ Document new secrets in the owning stack's README.
- ✅ Secrets live in Secrets Manager — not Parameter Store (it lacks rotation + audit).
- ❌ Don't log secret values, partial values, or ARNs with identifying suffixes.
- ❌ Don't cache secrets on disk — memory only.
- ❌ Don't share secrets across environments — every env has its own.
