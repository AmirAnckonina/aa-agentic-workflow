# Security Review — Extended Checklist

## Authentication & Identity

- [ ] Is the authentication mechanism explicitly named? (JWT, OAuth2, session cookie, API key, mTLS)
- [ ] Is the token/credential validated on every request, or assumed valid after initial auth?
- [ ] Are 401 (unauthenticated) and 403 (unauthorized) used correctly and distinctly?
- [ ] Is there a mechanism to invalidate tokens/sessions on logout or compromise?
- [ ] Are service-to-service calls authenticated separately from user-facing calls?
- [ ] Is the identity claim (user ID, org ID, role) extracted from the token, not from the request body?
- [ ] If API keys are used — are they hashed at rest? Are they never logged?
- [ ] Are anonymous/public endpoints explicitly listed? Is public access intentional and documented?

## Authorization & Access Control

- [ ] Is the authorization model specified? (RBAC, ABAC, ownership-based, scope-based)
- [ ] Are permissions checked at the data layer, not just the API layer? (prevents IDOR)
- [ ] Can a user access or mutate another user's resources through this spec?
- [ ] Are admin-only operations gated separately from regular user operations?
- [ ] Is permission denied behavior specified — silent (404) or explicit (403)?
- [ ] For multi-tenant systems — is tenant isolation enforced at every data access point?
- [ ] Are privilege escalation paths analyzed? Can a low-privilege token trigger high-privilege operations indirectly?

## Input Validation & Injection

- [ ] Is every input field validated for type, format, length, and allowed values?
- [ ] Are validation errors returned as 400 with enough detail for the client, but not internal detail?
- [ ] Are SQL/NoSQL queries parameterized — no string concatenation of user input?
- [ ] Are file paths constructed from user input validated against directory traversal (../, %2e%2e)?
- [ ] Is shell command execution involved? If so, are inputs sanitized and escaped?
- [ ] Are XML/JSON inputs protected against entity expansion or prototype pollution?
- [ ] Are template/expression injections possible (server-side template, eval, dynamic require)?
- [ ] Are URL redirects validated against an allowlist? (open redirect prevention)
- [ ] Are uploaded files validated for type, size, and content — not just extension?

## Data Exposure & Information Leakage

- [ ] Do error messages return only safe, generic information — no stack traces, internal IDs, or system paths?
- [ ] Are response bodies scoped to the minimum fields the caller needs?
- [ ] Are internal identifiers (DB primary keys, UUIDs, internal service names) excluded from responses where not needed?
- [ ] Are debug endpoints, health details, or verbose error modes disabled in production?
- [ ] Are logs free of sensitive data? (passwords, tokens, PII, credit card numbers)
- [ ] Is sensitive data masked in logs? (e.g., last 4 digits only, token prefix only)
- [ ] Are response headers free of server/framework version information?

## Sensitive Data Handling

- [ ] Is PII, financial data, or health data involved? If so — is it encrypted at rest?
- [ ] Is all transmission over TLS (HTTPS, TLS 1.2+)?
- [ ] Are secrets/credentials stored in environment variables or a secrets manager — never in code or config files?
- [ ] Is key rotation considered? Are secrets rotatable without downtime?
- [ ] Is data retention specified? Is there a deletion path for user data?
- [ ] Are backups of sensitive data encrypted?

## Rate Limiting & Abuse Prevention

- [ ] Is rate limiting applied to this endpoint? Is the limit specified (requests/second, requests/minute)?
- [ ] Are rate limits applied per user, per IP, or globally?
- [ ] Is there protection against enumeration attacks? (e.g., probing for valid user IDs, email addresses)
- [ ] Is brute force protection specified for auth endpoints?
- [ ] Are responses to rate-limited requests consistent enough not to leak information? (429 with Retry-After)
- [ ] Is there a CAPTCHA or challenge for operations prone to bot abuse?

## Audit & Compliance

- [ ] Are sensitive operations (login, data access, data mutation, permission change) logged?
- [ ] Do audit logs include: who, what, when, from where (IP/service), and outcome?
- [ ] Are audit logs immutable — write-only, not deletable by application code?
- [ ] Is the spec compliant with relevant regulations? (GDPR data access, SOC2 audit requirements, HIPAA PHI handling)
- [ ] Are data access events exportable for compliance reporting?

## Cryptography

- [ ] Are modern, approved algorithms used? (AES-256, RSA-2048+, SHA-256+, bcrypt/argon2 for passwords)
- [ ] Are weak or deprecated algorithms explicitly forbidden? (MD5, SHA1, DES, RC4)
- [ ] Are random values (tokens, nonces, salts) generated with a cryptographically secure RNG?
- [ ] Are passwords hashed with a proper KDF (bcrypt, argon2, scrypt) — not SHA or MD5?
- [ ] Is IV/nonce reuse prevented for symmetric encryption?
