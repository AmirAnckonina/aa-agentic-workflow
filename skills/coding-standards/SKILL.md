---
name: coding-standards
description: "Code quality principles for writing and reviewing code. 13 standards covering error handling, testing, security, performance, null safety, and more. Use when writing code, reviewing code, or checking quality. Loaded by Builder and Reviewer agents."
user-invocable: false
---

## Coding Standards

The 13 principles that define **how production code must be written and evaluated**.

- **Builder:** Apply during implementation.
- **Reviewer:** Evaluate against during review.
- **Direct chat:** Follow when writing or reviewing code.

> **Numeric thresholds are defaults, not laws.** Coverage %, function/file size limits, and nesting depth below are the baseline when a repo declares nothing. A repo's `CLAUDE.md` or established team conventions override them — flag a deviation only when the repo itself has no stated convention.

---

## 1. Test Coverage

- All public methods/endpoints covered by tests.
- Happy path AND failure paths tested.
- Tests assert behavior, not implementation details.
- Branch coverage ≥ 80% on changed code.
- Test names descriptive of the scenario they verify.

## 2. Edge Cases

- Boundary values handled (max, min, off-by-one).
- Concurrent/race conditions considered where applicable.
- Async operations have defined cancellation and lifecycle — no fire-and-forget unless explicitly intentional.
- Async errors propagated or handled at the call site — not silently swallowed by a detached goroutine/thread/promise.
- Spawned goroutines/threads/tasks are bounded — never unbounded spawning in loops or request handlers.
- Timeout and retry scenarios addressed.
- Unexpected input shapes handled (wrong type, extra fields, truncated data).

## 3. Null & Empty Safety

- **Fail fast:** Validate inputs early and surface errors immediately — don't let bad data propagate.
- Nullable inputs checked before use (no blind dereferencing).
- Empty collections/strings handled explicitly (not assumed non-empty).
- Optional/Maybe types used instead of returning null where the language supports it.
- API responses validated for missing/null fields before access.
- Default values intentional, not accidental (`""` vs `null` vs `undefined`).
- Code distinguishes between "absent" and "present but empty".

## 4. Error Handling

- Errors caught at appropriate levels — never swallowed silently.
- No bare `catch` / `except` without specific handling.
- Catch blocks are minimal and specific — no excessive nesting, no suppressing or generalizing the original error.
- Recoverable vs. fatal errors are distinguished.
- Consistent error response structure for APIs.
- Error messages aid debugging without leaking internals.
- No inline error codes (magic numbers) — use named constants or enums.
- No suppressed compiler/linter warnings without a justifying comment and ticket.
- All HTTP status codes documented in swagger/OpenAPI annotations must have explicit handling paths in the implementation. A `default` case that maps undocumented-but-valid responses to 500 is a bug.

## 5. Naming & Readability

- Names (variables, functions, classes) are self-documenting.
- A new team member can understand each function within 30 seconds.
- Nesting depth ≤ 3 levels. If deeper, extract. Prefer early returns over nested conditions.
- Single Responsibility: each function does exactly one thing.
- **Size limits:** Functions ≤ 80 lines (aim for under 50). Files ≤ 200 lines — split into focused modules when exceeded.
- No magic numbers or strings — use named constants. This includes HTTP header names, query param keys, config keys, event names, and any string used in more than one place. Define once, reference everywhere.
- Prefer meaningful names over comments. Comments explain *why*, not *what*.
- **Avoid generic dump names:** `utils`, `helpers`, `common`, `shared` with unclear purpose. Use intention-revealing, domain-specific names (`OrderCalculator`, `UserAuthenticator`).

## 6. Simplicity & SOLID

- SOLID principles applied: single responsibility, open/closed, Liskov substitution, interface segregation, dependency inversion.
- The solution is the simplest that meets requirements.
- No premature abstractions, unnecessary patterns, or gold-plating.
- No dead code, unused imports, or commented-out blocks.
- **Library-first:** Always search for existing libraries/services before writing custom code. Every line of custom code is a maintenance liability. Custom code justified only for: unique business logic, performance-critical paths, security-sensitive code, or when existing solutions don't fit after evaluation.
- DRY — but only when the duplication represents the same concept, not coincidental similarity. Three similar lines that solve different problems are better than a premature abstraction.
- Prefer immutable data structures. Mutate only when performance or API constraints require it.
- **NIH anti-patterns to avoid:** custom auth when identity providers exist, custom retry/circuit-breaker over established libraries, custom serialization/logging/HTTP clients when mature options are available.

## 7. Access Modifiers & Encapsulation

- Fields and methods private by default, only widened when genuinely needed.
- No public fields that should be behind accessors or encapsulated.
- Internal implementation details hidden from the public API surface.
- `protected` access justified by actual inheritance needs, not speculative extensibility.
- Module/package-level visibility used where appropriate (`internal`, package-private, etc.).
- Utility/helper classes restrict instantiation when appropriate (private constructors, sealed/final).

## 8. Interface-Based Design

- Dependencies injected via interfaces/abstractions, not concrete classes.
- Components testable in isolation (mockable boundaries).
- Contracts (input/output types) explicitly defined.
- Modules loosely coupled with clear boundaries.
- Request/response payloads modeled as dedicated types (DTOs/models), not raw maps, generic objects, or inline literals.
- Prefer immutable models at boundaries — DTOs and value objects should not be mutated after construction.

## 9. Security

- No secrets, tokens, or credentials in code or committed config.
- Input validation at system boundaries (user input, API params, file uploads).
- OWASP Top 10 awareness: injection, XSS, CSRF, broken auth, etc.
- SQL/NoSQL queries use parameterized statements — no string concatenation of user input.
- Principle of least privilege in permissions and scopes.
- Auth checks present on all protected endpoints.
- Third-party dependencies checked for known CVEs before adding; outdated dependencies flagged for update.

## 10. Performance

- No N+1 patterns — use batch/bulk operations instead of row-by-row iteration against DB, repository, or external API.
- Filtering and aggregation pushed to the data layer (WHERE, GROUP BY) rather than fetch-all-then-filter.
- No unbounded loops or memory leaks in hot paths.
- Large collections paginated or streamed.
- Expensive operations cached or deferred where appropriate.
- No unnecessary allocations or redundant computations.

## 11. Logging & Observability

- Key operations logged (entry points, state transitions, external calls).
- Flow reconstructable from logs alone without a debugger.
- Log levels correct: DEBUG for internals, INFO for business events, WARN for recoverable issues, ERROR for failures.
- Logs follow the project's existing conventions (format, library, structure).
- No sensitive data in logs (tokens, passwords, PII).
- Log messages are actionable — *what happened* and *where*.
- Correlation/request IDs included for traceability in distributed flows.

## 12. Comments & Documentation

- Self-explanatory code left without unnecessary comments.
- Non-obvious elements commented: business logic, workarounds, regex, algorithms.
- Public API interfaces documented (params, returns, throws).
- TODO/FIXME/HACK comments tracked with ticket references.

## 13. Language Idioms & Consistency

- Follow language-specific conventions (PEP 8, gofmt, Google Java Style, etc.).
- Code follows existing project conventions (naming, structure, patterns).
- Similar problems solved the same way across the codebase.
- Code style consistent with surrounding files.
- Error handling patterns consistent with the rest of the codebase.
- Prefer explicit over implicit. Define variable types where supported.
