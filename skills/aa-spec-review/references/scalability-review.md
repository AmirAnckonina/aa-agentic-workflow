# Scalability — Auditor Charter

**Accountable for:** whether the specified design survives its *realistic* load and the failure of anything it depends on. Anchor "realistic" in the repo's actual scale (context files, standards file, existing infra) — not in hypothetical 100x growth.

## Traps worth hunting

- Unbounded work: O(n) over data that grows without limit, unbounded batch/result sizes, unbounded fan-out of goroutines/threads/requests, full result sets loaded into memory.
- N+1 query patterns and missing pagination on paths that will actually be hot.
- External calls in the request path with no timeout, and retried operations with no idempotency requirement.
- Lost updates and check-then-act races on shared state; missing transaction boundaries where the spec implies atomicity.
- In-process state (caches, counters, schedulers) that silently breaks with more than one instance — *if the repo runs more than one instance*.
- Failure behavior unspecified for a dependency the spec introduces: what happens when it's down — degrade or error?
- A cache the spec itself introduces with no invalidation/staleness story — serving stale permissions or stale config is a correctness failure, not a tuning concern.

## Judgment line

Do not demand SLOs, caching layers, circuit breakers, queues, or sharding as a default — propose them only when the spec's own constraints or the repo's reality make the simpler design fail. A design that is merely *simple* is not a finding; a design that falls over at the repo's actual scale is.
