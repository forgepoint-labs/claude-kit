---
name: cloudfront-spa
description: Host an SPA on CloudFront + S3 with OAC, SPA rewrite (404 → index.html), cache policies for hashed vs. HTML assets, WAF attachment, and security headers. Use when adding a new distribution, debugging stale assets, or tuning cache.
---

# CloudFront + S3 SPA hosting

Patterns for hosting single-page applications on CloudFront with proper caching, security, and SPA routing.

## Architecture

```
user → CloudFront → OAC → S3 origin (dist/ uploaded by pipeline)
```

## Origin access

Use **Origin Access Control (OAC)**, not legacy OAI:

```json
{
  "Effect": "Allow",
  "Principal": { "Service": "cloudfront.amazonaws.com" },
  "Action": "s3:GetObject",
  "Resource": "arn:aws:s3:::<bucket>/*",
  "Condition": {
    "StringEquals": { "AWS:SourceArn": "<distribution-arn>" }
  }
}
```

S3 stays private — only CloudFront can read it.

## SPA rewrite (404 → index.html)

SPAs use client-side routing; paths like `/orders/123` don't exist in S3. Configure custom error responses:

```
ErrorCode: 403 → ResponseCode: 200, ResponsePagePath: /index.html, ErrorCachingMinTTL: 0
ErrorCode: 404 → ResponseCode: 200, ResponsePagePath: /index.html, ErrorCachingMinTTL: 0
```

Both 403 and 404 because S3 can return either for a missing object depending on bucket policy.

## Cache policies (two tiers)

**Immutable (hashed assets)** — `assets/index.abc123.js`, `assets/style.def456.css`:
- `Cache-Control: public, max-age=31536000, immutable`
- Use the `CachingOptimized` managed policy

**HTML** — `index.html`:
- `Cache-Control: no-cache, must-revalidate`
- Use the `CachingDisabled` policy (or very short TTL)

Vite/webpack builds emit hashed filenames — set the right `Cache-Control` during S3 sync.

## Invalidation

Usually NOT needed for hashed assets. Always needed for `index.html`:

```sh
aws cloudfront create-invalidation --distribution-id EXXXXXX --paths "/index.html" "/"
```

Don't invalidate `/*` to "force freshness" — hashed filenames handle this.

## Security headers

Attach a **Response Headers Policy**:

```
Strict-Transport-Security: max-age=31536000; includeSubDomains; preload
X-Content-Type-Options: nosniff
X-Frame-Options: DENY
Referrer-Policy: strict-origin-when-cross-origin
Permissions-Policy: camera=(), microphone=(), geolocation=()
```

One policy reused across all distributions.

## WAF attachment

Attach a Web ACL with:
- AWS managed CommonRuleSet
- AWS managed KnownBadInputs
- Rate-based rule (2000 req / 5 min per IP)
- IP allow list for internal tools / QA

## Debugging stale assets

1. Hard-refresh (Cmd+Shift+R). If new content shows, it's browser cache.
2. Check `x-cache` header — `Hit from cloudfront` means CF cached, `Miss` means fresh fetch.
3. If `index.html` is stale: confirm the deploy pipeline ran the invalidation step.
4. If a hashed asset is stale: check whether the HTML was updated (the hash in the URL should change).

## Golden rules

- ✅ Use OAC, not OAI.
- ✅ 403 → index.html AND 404 → index.html for SPA routing.
- ✅ Separate cache policies for immutable assets vs HTML.
- ✅ Let the pipeline handle invalidations.
- ✅ WAF attached on every distribution.
- ✅ Security headers via Response Headers Policy.
- ❌ Don't make S3 buckets public. Ever.
- ❌ Don't invalidate `/*` to force freshness — hashed filenames are the answer.
