# Scalability Review — Extended Checklist

## Load & Throughput

- [ ] What is the expected request rate at launch? At 10x? At 100x?
- [ ] Is there a throughput SLO (requests/second) stated or implied? Does the design support it?
- [ ] Are there any synchronous operations that could become serial bottlenecks under load?
- [ ] Is any operation O(n) in user data where n could grow unbounded?
- [ ] Is there a queue or buffer for spiky workloads, or does the system take load directly?
- [ ] Are batch operations bounded in size? Is there a max batch size to prevent resource exhaustion?
- [ ] Is there a backpressure mechanism when downstream systems are slow or saturated?

## Database & Storage

- [ ] Are all query patterns indexed? (filter columns, join columns, sort columns)
- [ ] Are N+1 query patterns possible? (loading a list, then querying each item individually)
- [ ] Are queries paginated? Is there a maximum page size enforced?
- [ ] Are large result sets streamed, or loaded fully into memory?
- [ ] Are write operations single-row or multi-row? Are bulk writes batched?
- [ ] Is there a risk of table lock contention under concurrent writes?
- [ ] Are DB connections pooled? Is the pool size bounded? What happens at pool exhaustion?
- [ ] Is the schema designed for read-heavy or write-heavy access? Does the design match the expected pattern?
- [ ] Are there any full-table scans possible? Are they acceptable at scale?
- [ ] Is the storage medium appropriate? (relational for transactions, document for flexible schema, object storage for blobs)
- [ ] Is there a data archival or TTL strategy for data that grows without bound?
- [ ] For time-series or log data — is partitioning or sharding considered?

## Caching

- [ ] What is cached? Is the cache key uniquely scoped? (no cache poisoning risk)
- [ ] Is the TTL specified? Is it appropriate for the data's freshness requirements?
- [ ] What is the invalidation strategy? (TTL expiry, event-driven invalidation, manual purge)
- [ ] What happens on cache miss — is the fallback acceptable at scale? (stampede protection for hot keys)
- [ ] What happens on cache failure? Fail open (query DB) or fail closed (return error)?
- [ ] Is there a cache warm-up strategy for cold starts (deploys, restarts)?
- [ ] Is cache size bounded? What is the eviction policy (LRU, LFU)?
- [ ] Are cache keys namespaced per environment/tenant to prevent cross-contamination?
- [ ] For distributed caches (Redis) — is the client configured with timeouts and circuit breakers?

## Concurrency & State

- [ ] Are there shared mutable resources accessed by multiple concurrent requests?
- [ ] Are database operations that must be atomic wrapped in transactions?
- [ ] Is there a risk of lost updates? (read-modify-write without locking or optimistic concurrency)
- [ ] Are there race conditions in the spec? (e.g., check-then-act without atomic guarantee)
- [ ] Is idempotency specified for operations that may be retried?
- [ ] Is there any in-process state (singleton, global variable) that breaks under horizontal scaling?
- [ ] Are background workers/jobs safe to run on multiple instances simultaneously?
- [ ] Is there a distributed lock needed? Is the locking mechanism specified?

## External Dependencies

- [ ] Are all external service calls (HTTP, gRPC, message queue) given a timeout?
- [ ] Is retry behavior specified? (max retries, backoff strategy, jitter)
- [ ] Is there a circuit breaker for external calls to prevent cascade failure?
- [ ] Is the behavior specified when an external dependency is unavailable? (degrade gracefully vs fail hard)
- [ ] Are external dependencies called synchronously in the request path? Could they be async?
- [ ] Is the latency budget of external calls accounted for in the overall response time SLO?

## Memory & Resource Management

- [ ] Are large payloads (file uploads, large responses) streamed — not fully loaded into memory?
- [ ] Are goroutines/threads/workers bounded? Is there a risk of unbounded spawning?
- [ ] Are file descriptors, connections, and other OS resources released properly?
- [ ] Is memory usage per request bounded? (e.g., limiting request body size)
- [ ] Are there any operations that allocate large buffers proportional to input size?

## Horizontal Scaling

- [ ] Does the design assume sticky sessions or local state that breaks under load balancing?
- [ ] Are session/auth tokens stateless (JWT) or stored server-side? If server-side — is the store shared across instances?
- [ ] Are scheduled jobs safe to run on multiple instances? Is there a distributed scheduler or leader election?
- [ ] Is any configuration loaded at startup that could become stale across rolling deploys?
- [ ] Are WebSocket/long-polling connections handled in a way that works with load balancers?
