---
name: coding-standards
description: "Team-specific code quality opinions for writing and reviewing code: coverage bar, concurrency discipline, library-first stance, API/error contracts, logging conventions. Use when writing code, reviewing code, or checking quality. Loaded by Builder and Reviewer agents."
user-invocable: false
---

## Coding Standards

Team-specific opinions and defaults for production code. General good practice (idiomatic style, naming, SOLID, encapsulation, comments) is assumed — match the surrounding codebase and language conventions; only what's listed here needs stating.

> **Numeric thresholds are defaults, not laws.** They apply when a repo declares nothing. A repo's `CLAUDE.md` or established team conventions override them — flag a deviation only when the repo itself has no stated convention.

## 1. Test Coverage

- All public methods/endpoints covered — happy path AND failure paths.
- Branch coverage ≥ 80% on changed code.
- Tests assert behavior, not implementation details.

## 2. Concurrency & Async

- Spawned goroutines/threads/tasks are bounded — never unbounded spawning in loops or request handlers.
- Async operations have defined cancellation and lifecycle — no fire-and-forget unless explicitly intentional.
- Async errors propagated or handled at the call site — never silently swallowed by a detached goroutine/thread/promise.
- Timeout and retry behavior addressed for external calls.

## 3. Fail Fast

- Validate inputs early at system boundaries and surface errors immediately — don't let bad data propagate.
- Code distinguishes "absent" from "present but empty"; default values are intentional.

## 4. Error Contracts

- All HTTP status codes documented in swagger/OpenAPI annotations must have explicit handling paths in the implementation. A `default` case that maps undocumented-but-valid responses to 500 is a bug.
- Consistent error response structure for APIs; messages aid debugging without leaking internals.
- No inline error codes (magic numbers) — named constants or enums.
- No suppressed compiler/linter warnings without a justifying comment and ticket.

## 5. Size Defaults

Functions ≤ 80 lines (aim for under 50); files ≤ 200 lines; nesting ≤ 3 levels — extract or split when exceeded. No generic dump modules (`utils`, `helpers`, `common`) — use intention-revealing, domain-specific names.

## 6. Library-First

- Search for existing libraries/services before writing custom code. Every line of custom code is a maintenance liability. Custom code is justified only for: unique business logic, performance-critical paths, security-sensitive code, or when existing solutions don't fit after evaluation.
- **NIH anti-patterns to avoid:** custom auth when identity providers exist, custom retry/circuit-breaker over established libraries, custom serialization/logging/HTTP clients when mature options are available.
- DRY only when the duplication is the same concept — three similar lines solving different problems beat a premature abstraction.

## 7. Boundary Types

- Request/response payloads modeled as dedicated types (DTOs/models), not raw maps, generic objects, or inline literals.
- Prefer immutable models at boundaries — DTOs and value objects are not mutated after construction.
- Dependencies injected via interfaces at component boundaries — testable in isolation.

## 8. Security

- No secrets in code or committed config; parameterized queries only; auth checks on all protected endpoints; input validation at system boundaries.
- Third-party dependencies checked for known CVEs before adding; outdated dependencies flagged.

## 9. Data-Layer Performance

- No N+1 patterns — batch/bulk operations instead of row-by-row iteration against DB, repository, or external API.
- Filtering and aggregation pushed to the data layer (WHERE, GROUP BY), not fetch-all-then-filter.
- Large collections paginated or streamed.

## 10. Logging & Observability

- Flow reconstructable from logs alone without a debugger; key operations logged (entry points, state transitions, external calls).
- Levels: DEBUG internals, INFO business events, WARN recoverable, ERROR failures. Follow the project's existing log format/library.
- Correlation/request IDs in distributed flows; no sensitive data (tokens, passwords, PII) in logs.
