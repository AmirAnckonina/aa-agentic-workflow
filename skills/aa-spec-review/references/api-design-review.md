# API Design — Auditor Charter

**Accountable for:** the precision of the spec's API contract and its consistency with the API that already exists in this codebase. The reference point is *this repo's* conventions (read the existing endpoints), not generic REST doctrine.

## Traps worth hunting

- Status codes that mislead clients: 401 vs 403 vs 404 conflated, errors returned as 200 with an error body, success codes that don't match the operation (created vs updated vs no-content).
- Breaking changes hiding in plain sight: renamed/removed/retyped fields on existing responses, new required fields on existing requests — with no versioning or migration note.
- Error responses whose shape differs from the codebase's existing error contract.
- Contract holes the Builder will have to guess at: null vs absent where it matters, unlisted enum values, unbounded strings/arrays on write paths, unspecified date/time format.
- Retryable POSTs that create duplicates — idempotency unaddressed where the client will retry.
- List endpoints without pagination *when sibling endpoints paginate* or the data is unbounded.

## Judgment line

Divergence from this codebase's established pattern is a finding; divergence from textbook convention is not. If the repo consistently does something unconventional, the spec should match the repo — flag only what the repo's standards file or existing code actually contradicts.
