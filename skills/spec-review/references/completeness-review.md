# Completeness Review — Extended Checklist

## Section Presence

- [ ] **Overview** — present and substantive (not a one-liner placeholder)
- [ ] **Acceptance Criteria** — present with at least 2 testable items
- [ ] **Interfaces** — present with typed function signatures
- [ ] **Types / Models** — present if new types are introduced
- [ ] **API Contracts** — present if the spec includes HTTP endpoints
- [ ] **Files to Change** — present (optional but strongly recommended)
- [ ] **Component Responsibilities** — present if more than one component is involved
- [ ] **Error Handling** — present and covers more than just "return 500"
- [ ] **Security Considerations** — substantive (not "N/A" without justification)
- [ ] **Failure Modes** — present and covers external dependency failures
- [ ] **Constraints** — present with at least performance targets or key dependencies

## Acceptance Criteria Quality

Flag any AC that contains these anti-patterns:

| Anti-pattern phrase | Why it fails | Fix |
|---|---|---|
| "should work correctly" | Not testable | Specify the observable behavior |
| "should be fast" | Not testable | Specify latency target (e.g., p99 < 200ms) |
| "properly validates" | Not testable | List what is validated and what error is returned |
| "handles errors gracefully" | Not testable | Specify which errors and what the response is |
| "should be secure" | Not testable | Specify the security requirement (e.g., requires auth token) |
| "should log" | Partially testable | Specify log level, content, and trigger condition |
| "as needed" | Not testable | Specify the condition |

- [ ] Each AC maps to exactly one observable, testable outcome
- [ ] Each AC can be written as a test name: `TestFeatureX_WhenConditionY_ExpectsZ`
- [ ] No AC is a duplicate or subset of another
- [ ] Every AC is within the implementation scope of this spec (no cross-spec dependencies without noting them)

## Requirements Traceability

- [ ] List every stated requirement from the user request
- [ ] For each requirement — is there at least one AC that directly tests it?
- [ ] Are there ACs with no corresponding requirement? (scope creep — flag it)
- [ ] Are there requirements that are only partially addressed by the ACs?
- [ ] For bug fix specs — is the bug's root cause addressed, not just its symptom?

## Interface Completeness

- [ ] Every function signature includes: name, all parameter names and types, return type
- [ ] Every function signature includes its error/exception return type(s)
- [ ] Parameter constraints are documented (optional vs required, valid ranges, allowed values)
- [ ] Interface naming follows the codebase conventions (checked via Grep)
- [ ] Return types are concrete — no `any`, `interface{}`, or `object` without justification
- [ ] For methods on structs/classes — the receiver/this type is specified
- [ ] Constructor/factory functions are specified if new types are created
- [ ] Callback/handler signatures are specified if the spec involves event handling

## Error Handling Coverage

- [ ] Every external call has a failure case specified
- [ ] Every validation failure has a specified response (status code + body)
- [ ] Every not-found case has a specified response
- [ ] Every conflict case (duplicate, version mismatch) has a specified response
- [ ] Every permission denied case has a specified response
- [ ] Partial failure scenarios are addressed (what happens if step 3 of 5 fails?)
- [ ] Error propagation is specified — does the error bubble up, get wrapped, or get transformed?
- [ ] Retry behavior is specified where applicable (which errors are retryable?)

## Failure Modes

- [ ] All external dependencies are listed (DBs, caches, services, queues)
- [ ] For each dependency — what happens on timeout, connection failure, or error response?
- [ ] For each dependency — fail open (continue with degraded behavior) or fail closed (return error)?
- [ ] Network partition behavior is considered for distributed operations
- [ ] Data corruption scenarios are considered (partial writes, interrupted transactions)
- [ ] Clock skew is considered if timestamps are involved in logic
- [ ] What happens if the service restarts mid-operation? Is state recovered?

## Edge Cases

- [ ] Empty input (empty string, empty array, zero value)
- [ ] Null / missing optional fields
- [ ] Boundary values (min, max, exactly at limit)
- [ ] Concurrent access to the same resource
- [ ] Duplicate requests (same data submitted twice)
- [ ] Very large inputs (max file size, max array length)
- [ ] Unicode / special characters in string inputs
- [ ] Expired or revoked credentials
- [ ] Resource not found vs resource exists but access denied

## Files to Change Quality

- [ ] Are all new files listed?
- [ ] Are all modified files listed (not just new ones)?
- [ ] Are test files listed or implied?
- [ ] Are migration files listed if schema changes are involved?
- [ ] Are config files listed if new config values are introduced?
- [ ] Is the description for each file specific enough for the Builder to know what to do?

## Dependencies & Prerequisites

- [ ] Are all required libraries/packages declared?
- [ ] Are all required environment variables or config values declared?
- [ ] Are prerequisite specs listed? (specs that must be completed before this one)
- [ ] Are schema migrations listed as prerequisites if applicable?
- [ ] Are infrastructure changes (new queues, new DB tables, new secrets) listed?
