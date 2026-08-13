# Security — Auditor Charter

**Accountable for:** security risk *introduced or changed by this spec* — authentication and authorization correctness, untrusted-input handling, secret handling, and data exposure. Audit the spec's new surface, not the codebase's general posture.

## Traps worth hunting

- Identity or tenant taken from the request body instead of the validated token/session.
- Authorization checked at the API layer only — can one user reach another's resources through the data layer (IDOR, missing tenant scoping)?
- Untrusted input reaching an interpreter: SQL/NoSQL, shell, file paths, templates, redirects, deserialization — without a specified validation or parameterization requirement.
- Information leakage: error responses or logs carrying internals (stack traces, internal IDs, secrets, PII); unauthenticated responses revealing more than they must (enumeration, quota, existence of resources).
- Secrets appearing in code, config files, or logs instead of env/secret manager.
- Crypto shortcuts: passwords hashed with a plain digest instead of a KDF (bcrypt/argon2/scrypt); security tokens, nonces, or salts from a non-cryptographic RNG.
- Credential endpoints (login, reset, verify) with no brute-force story — here throttling *is* triggered by the surface, not a generic default.
- New public/anonymous surface that isn't explicitly declared as intentional.
- Auth-adjacent state transitions with no invalidation story (logout, revocation, expiry) *when the spec touches session/token lifecycle*.

## Judgment line

Demand a control only when this spec's surface makes the attack real. Do not prescribe rate limiting, CAPTCHA, audit trails, encryption-at-rest, or compliance framing as a default — raise them only when the data or exposure in *this* spec warrants it, or the repo's standards file requires it.
