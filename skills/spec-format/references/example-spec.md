# Example: Completed Spec

This is a minimal but complete example showing the spec-format in use. Use it as a reference when producing or reviewing specs.

---

# Rate Limiter Middleware

**Status:** Approved
**Brief:** _Inline — Gate A waived: simple single-component change_

## Overview
Add a token-bucket rate limiter as Express middleware. Limits requests per API key to prevent abuse and ensure fair resource allocation across tenants.

## Acceptance Criteria
- [ ] Requests without an API key receive 401 Unauthorized
- [ ] Requests exceeding the rate limit receive 429 Too Many Requests with a `Retry-After` header
- [ ] Rate limit state is stored in Redis (not in-memory) for horizontal scaling
- [ ] Each API key gets an independent token bucket (default: 100 requests/minute)
- [ ] Rate limit headers (`X-RateLimit-Limit`, `X-RateLimit-Remaining`, `X-RateLimit-Reset`) are present on every response
- [ ] If Redis is unavailable, requests are allowed through (fail-open) with a structured warning log

## Interfaces

### Types / Models

```typescript
interface RateLimitConfig {
  windowMs: number;          // Time window in milliseconds
  maxRequests: number;       // Max requests per window per key
  keyExtractor: (req: Request) => string | null;  // Returns API key or null
}

interface RateLimitInfo {
  limit: number;
  remaining: number;
  resetAt: Date;
}

type RateLimitResult =
  | { allowed: true; info: RateLimitInfo }
  | { allowed: false; info: RateLimitInfo; retryAfterMs: number };
```

### Public Functions / Methods

```typescript
function createRateLimiter(config: RateLimitConfig): RequestHandler;
// Throws: never (fail-open on Redis errors, logs warning)

function checkRateLimit(key: string, config: RateLimitConfig): Promise<RateLimitResult>;
// Throws: RedisConnectionError (caught internally by middleware)
```

## Files to Change
- `src/middleware/rate-limiter.ts` — New file: middleware factory and token bucket logic
- `src/middleware/index.ts` — Export the new middleware
- `src/config/rate-limit.ts` — New file: default config values, env var overrides
- `tests/middleware/rate-limiter.test.ts` — New file: unit + integration tests

## Component Responsibilities
**Rate Limiter Middleware** owns request interception, key extraction, and response header injection. It delegates bucket state to Redis via the existing `RedisClient` wrapper.

**Config module** owns default values and env var mapping. No business logic.

## Error Handling
- Missing API key: respond 401 immediately, do not consume a token
- Rate exceeded: respond 429 with `Retry-After` header (seconds until reset)
- Redis unavailable: allow the request through (fail-open), emit structured warning log with `{ event: "rate_limit_redis_unavailable", key }`

## Security Considerations
- API keys must not appear in logs (redact to last 4 characters)
- Rate limit headers must not leak other tenants' limits or state

## Failure Modes
- **Redis latency spike:** Middleware adds a 200ms timeout on Redis calls. On timeout, fail-open.
- **Key extractor returns null:** Treat as missing key (401), not as "unlimited."

## Constraints
- p99 latency overhead of the middleware must be < 5ms under normal Redis conditions
- Compatible with Express 4.x and 5.x
- No new npm dependencies (use existing `ioredis` client)

## Review Notes
| Perspective  | Status       | Issues |
|---|---|---|
| Security     | ✅ Approved  | — |
| Scalability  | ✅ Approved  | — |
| API Design   | ✅ Approved  | — |
| Completeness | ✅ Approved  | — |
| Scope        | ✅ Approved  | — |
