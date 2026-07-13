# API Design Review — Extended Checklist

## HTTP Semantics

- [ ] Is GET used only for safe, idempotent, read-only operations? (No side effects on GET)
- [ ] Is POST used for non-idempotent creation or complex operations?
- [ ] Is PUT used for full resource replacement (idempotent)?
- [ ] Is PATCH used for partial updates? Is the patch semantics specified (JSON Merge Patch, JSON Patch, or custom)?
- [ ] Is DELETE idempotent? (Deleting a non-existent resource should return 204 or 404 consistently)
- [ ] Are safe methods (GET, HEAD, OPTIONS) free from mutation side effects?

## Status Codes

- [ ] 200 OK — used for successful reads and updates that return a body
- [ ] 201 Created — used when a new resource is created; includes Location header?
- [ ] 204 No Content — used for successful operations with no response body (DELETE, some PUT)
- [ ] 400 Bad Request — used for client validation errors (malformed input, missing required field)
- [ ] 401 Unauthorized — used for unauthenticated requests (missing or invalid token)
- [ ] 403 Forbidden — used for authenticated but unauthorized requests (valid token, wrong permissions)
- [ ] 404 Not Found — used when the resource doesn't exist (not for auth failures)
- [ ] 409 Conflict — used for state conflicts (duplicate create, version mismatch, optimistic lock failure)
- [ ] 410 Gone — used when a resource existed but has been permanently deleted
- [ ] 422 Unprocessable Entity — used for semantically invalid input (passes format validation, fails business rules)
- [ ] 429 Too Many Requests — used for rate limit exceeded; includes Retry-After header?
- [ ] 500 Internal Server Error — used only for unexpected server faults, never for client errors
- [ ] 502 Bad Gateway — used when an upstream/downstream service returns an invalid response; never for client errors
- [ ] 503 Service Unavailable — used for planned downtime or dependency failure with Retry-After

## Idempotency

- [ ] Are all PUT and DELETE operations idempotent?
- [ ] Are POST operations that must not be duplicated protected by an idempotency key?
- [ ] Is the idempotency key in a header (Idempotency-Key) or request body? Is the field named?
- [ ] Is the TTL for idempotency key storage specified?
- [ ] Is the behavior defined for a duplicate request with the same idempotency key?
  (Return cached response? Return conflict? Ignore duplicate?)

## Request Shape

- [ ] Are all required fields explicitly listed and typed?
- [ ] Are all optional fields listed with their defaults?
- [ ] Is the distinction between null (explicit null) and missing (field absent) specified where it matters?
- [ ] Are string fields length-constrained? Are numeric fields range-constrained?
- [ ] Are enum fields exhaustively listed? Is an unknown value rejected or ignored?
- [ ] Are nested objects fully specified, or left as generic "object"?
- [ ] Are arrays bounded in size? Is an empty array vs null specified?
- [ ] Is date/time format specified? (ISO 8601 preferred — is timezone handling explicit?)

## Response Shape

- [ ] Is every response field named, typed, and documented?
- [ ] Are nullable fields identified?
- [ ] Is the response envelope consistent with the rest of the API? (e.g., `{ "data": {...} }` vs flat)
- [ ] Are list responses paginated? Is the pagination envelope consistent with existing list endpoints?
- [ ] Is the response on error consistent across all endpoints? (same error shape everywhere)
- [ ] Are 404 responses distinguishable from 403 responses from the client's perspective?

## Error Response Format

- [ ] Is the error response shape consistent across all endpoints in the API?
- [ ] Does the error response include: error code, human-readable message, optional detail?
- [ ] Are error codes machine-readable (snake_case string, not just HTTP status)?
- [ ] Does the error message help the client understand what to fix — without leaking internals?
- [ ] For validation errors — does the response identify *which field(s)* failed and why?
- [ ] Are error responses localized or always in English?

## URL Design

- [ ] Are URLs resource-oriented and noun-based? (not `/getUser`, but `/users/{id}`)
- [ ] Is the URL hierarchy consistent with the resource ownership model?
- [ ] Are IDs in the path for specific resources, query params for filters?
- [ ] Is URL casing consistent? (kebab-case preferred for multi-word segments)
- [ ] Are collection endpoints plural? (`/users`, not `/user`)
- [ ] Are nested resources justified? (`/users/{id}/orders` vs `/orders?userId={id}`)
- [ ] Is the URL pattern consistent with existing routes in the codebase?

## Versioning & Backward Compatibility

- [ ] Does this API need versioning? (Is it externally consumed? Will it evolve?)
- [ ] If versioned — is the version in the URL (`/v1/`) or header (`Accept: application/vnd.api.v1+json`)?
- [ ] Are any existing fields being renamed, removed, or changed in type? That's a breaking change.
- [ ] Are new required fields being added to existing requests? That's a breaking change.
- [ ] Is there a deprecation strategy for old versions? (sunset header, deprecation notice period)
- [ ] Are clients expected to handle unknown fields gracefully? Is this documented?

## Pagination

- [ ] Is pagination specified for all list endpoints?
- [ ] Is the pagination strategy specified? (offset/limit, cursor-based, page number)
- [ ] Is cursor-based pagination used for datasets that change frequently?
- [ ] Is the default page size specified? Is the maximum page size enforced?
- [ ] Is the total count returned? Is it expensive to compute at scale?
- [ ] Is the pagination envelope consistent with other list endpoints in the API?
- [ ] Is the sort order specified and stable across pages?

## Consistency with Codebase

- [ ] Do field names follow the project's convention? (camelCase vs snake_case)
- [ ] Does the auth header location match existing endpoints? (Authorization: Bearer vs X-API-Key)
- [ ] Does the error format match the existing error handler middleware?
- [ ] Are content types consistent? (application/json everywhere, or mixed?)
- [ ] Do new endpoints follow the same router/handler file structure as existing ones?
