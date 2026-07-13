---
name: architect-methodology
description: "Use when evaluating a design or architecture decision — 'best approach', 'should I use X or Y', 'how should I structure', trade-off analysis, ADRs — or when writing a spec. Provides 5 reasoning lenses, a research protocol, and a gatekeeper checklist. Preloaded by the Architect agent; works standalone in direct chat (Advisory Mode)."
user-invocable: true
---

# Architecture Methodology

This skill defines **how to reason about design decisions**. It provides lenses (what to think about), a research protocol (how to gather evidence), a gatekeeper checklist (when to stop and push back), and an output format (how to communicate decisions).

## Modes

### Advisory Mode
**Triggers:** Questions — "best approach", "why", "how", "WDYT", "what do you think", "should I use X or Y"
**Output:** Reasoning + recommendation using relevant lenses. No formal spec produced.
**Depth:** Proportional — apply 2-3 lenses where they matter most, not necessarily all five.

### Spec Mode
**Triggers:** Concrete action requested — "write a spec", "write X", "implement Y", "design this feature"
**Output:** An **Approach Brief** first (~1 page, `docs/briefs/`), then — after Gate A passes or is skipped — a formal spec following the `spec-format` skill, delivered as **Draft**.
**Depth:** Full — all five lenses. Apply them to the *approach* when writing the brief; re-verify at spec depth when writing the spec.
**Handoff rule:** A Draft spec MUST go through Gate B before reaching the Builder. The Architect asks the user which gates to run (Gate A + Gate B, Gate B only, or skip — Gate A is mandatory for T3 work). Do not hand off directly to the Builder without asking. Mark artifacts `Draft` until the chosen gates complete and approve them.

### Workflow: Spec Mode Pipeline
```
Architect (Approach Brief, Draft)
    ↓
/approach-review [Gate A: strategic challenge on 1 page — PASS or RETHINK → revise brief]
    ↓
Architect (Full Spec, Draft — links the Approach-Approved brief)
    ↓
/spec-review [Gate B: parallel detail audits — Approved or Blocking → revise spec]
    ↓
Builder (implements against Approved spec)
    ↓
Reviewer (validates code against spec)
```

Each gate can send its artifact back to `Draft` for Architect revision, and never assumes consent — the user moves the pipeline forward, per-gate or via upfront segment consent ("run through Gate B"; any non-pass verdict still stops). Ordinary T2s take the fast track: inline chat brief (waiver recorded) instead of a brief artifact + Gate A. The Architect asks the user which gates to run when finishing the brief/spec.

---

## Keywords

architecture, design decision, ADR, system design, trade-off analysis, lens, gatekeeper, service boundary, scalability, observability, rollback, caching, consistency model, best approach, how should I design, what's the right way, should I use, which approach, design options, architecture options, how to structure

---

## Reasoning Lenses

Every design decision should be evaluated through all five lenses. Apply depth proportional to scope — a cross-service feature warrants full rigor on every lens; a localized design question may need only 2-3. If any lens reveals an unaddressed gap — stop and address it before proceeding.

### Trade-off Principle

> **All dimensions — security, scalability, maintainability, reliability, observability — carry equal weight.** None is automatically ranked above the others. When lenses conflict, make the trade-off explicit: state what you're trading, what you're gaining, and why it's the right call for this context. Never silently deprioritize a dimension.

### Lens 1: Zoom Out (System-Level Thinking)

Step back from the feature and evaluate its impact on the system as a whole.

- **Service boundaries.** Where does this feature live? Does it belong in an existing service or warrant a new one? What is the blast radius if it fails?
- **Data ownership.** Which service owns the data this feature touches? Are you introducing shared mutable state across boundaries?
- **Architecture fit.** Does the current system architecture (monolith, modular monolith, microservices) support this feature naturally, or are you fighting it? If the feature doesn't fit — flag it, don't force it.
- **System-wide side effects.** Does this change affect other teams, services, or deployment pipelines? Will it require coordinated rollouts?

### Lens 2: Deep Dive (Component-Level Rigor)

Zoom into the component and stress-test its internal design.

- **Data layer.** DB schema impact, query patterns, indexing needs, migration strategy. Are connections pooled and bounded? Is the schema forward-compatible?
- **Caching.** What to cache, invalidation strategy (TTL, event-driven, manual), cache-aside vs write-through, cold-start behavior. What happens on cache failure — graceful fallback or hard failure?
- **Consistency model.** Strong vs eventual consistency — which does this feature require? Transaction boundaries, distributed state, race conditions, idempotency of operations.
- **Concurrency.** Shared mutable state? Lock contention? Are operations atomic that need to be? What happens under concurrent writes?

### Lens 3: Day-2 Operations (What Happens After Deploy)

Design for the team that operates this at 3 AM, not just the team that builds it.

- **Rollout strategy.** Feature flags, canary, blue-green, percentage rollout? Can you validate the feature in production before full exposure?
- **Rollback plan.** Is this change reversible? Are DB migrations backward-compatible? Can you roll back the code without rolling back the data? What is the rollback time?
- **Observability.** Can you diagnose issues from logs, metrics, and traces alone — without attaching a debugger? Are SLIs/SLOs defined? Are alerts actionable?
- **Operational runbook.** What are the known failure scenarios and their manual recovery steps?

### Lens 4: Long-Term Health (Maintainability)

Optimize for the next developer who reads this code, not the one who writes it.

- **Comprehensibility.** Can a new team member understand this component in 30 minutes? If not, the design is too clever.
- **Pattern consistency.** Does this follow existing codebase patterns, or introduce a new one? If new — is the deviation justified and documented (ADR)?
- **Coupling & cohesion.** Are responsibilities clearly owned? Can this component be modified without cascading changes? Can it be tested in isolation?
- **Evolvability.** How hard is it to change this in 6 months? Are extension points where you'd actually extend, not where you imagine you might?

### Lens 5: Robustness (What Breaks and How)

Assume everything will fail. Design for graceful degradation, not perfection.

- **Failure modes.** Enumerate what can fail: network, DB, cache, downstream service, disk, clock skew. For each — what is the expected behavior?
- **Recovery.** Automatic retry with backoff? Circuit breaker? Dead letter queue? Manual intervention? Define the recovery path for each failure mode.
- **Partial failure.** If step 3 of 5 fails, what happens to steps 1-2? Is state consistent? Can the operation be safely retried?
- **Scale stress.** Does this design hold at 10x, 100x, 1000x current load? Where does it break first? What is the scaling strategy (horizontal, vertical, sharding)?
- **Idempotency.** Can the same operation be safely repeated? This matters for retries, message redelivery, and crash recovery.

---

## Research Protocol

Use research to inform design decisions — not to replace judgment.

### When to Research
- Unfamiliar problem domain or technology choice.
- Multiple viable approaches with non-obvious trade-offs.
- Performance-sensitive or security-sensitive decisions.

### When to Skip
- Well-understood CRUD patterns.
- The codebase already has an established convention that clearly applies.
- State: *"Skipping research: [reason]"* and move on.

### What to Research
- Industry best practices and established design patterns for the problem (Strategy, Repository, Circuit Breaker, CQRS, Saga, etc.).
- How major projects / frameworks solve similar problems — battle-tested approaches, not blog hype.
- Common pitfalls, anti-patterns, and known failure modes for candidate approaches.
- Security advisories or known vulnerabilities for libraries / patterns under consideration.
- Performance benchmarks or scalability data when the decision is performance-sensitive.

### How to Present Findings
- Summarize 2-3 candidate approaches with pros / cons sourced from research.
- Cite sources (official docs, reputable engineering blogs, RFCs).
- State your recommendation and why — grounded in both the research AND the project's existing patterns.
- Research informs judgment; it does not replace it. Do not adopt a pattern because it's popular. Evaluate fit.

---

## Gatekeeper Checklist

REJECT or CHALLENGE any design that:

- Has unaddressed gaps in **any** of the 5 lenses above.
- Lacks error handling and failure recovery (Lens 5).
- Has no observability plan — logging, metrics, tracing (Lens 3).
- Introduces security vulnerabilities (Lens 2, Lens 5).
- Creates tight coupling or violates separation of concerns (Lens 4).
- Is untestable — the Builder must be able to write a failing test against the design (Lens 4).
- Has no rollback story (Lens 3).
- Introduces inconsistency risk without defining the consistency model (Lens 2).
- Ignores scale — no analysis of what breaks under load (Lens 5).
- **Builds custom when existing solutions exist** — has the team searched for libraries, services, or SaaS that solve the problem before committing to custom code? (Lens 4).
- **Exposes APIs without design consistency** — missing versioning strategy, inconsistent request/response structures, non-idempotent operations that should be idempotent, or missing appropriate HTTP status codes (Lens 2, Lens 5).

---

## Example: Applying the Lenses

**Scenario:** "Add a rate limiter to the `/logs` API endpoint."

**Lens 1 — Zoom Out:** Rate limiting is cross-cutting. Does it belong in the service or in the API gateway? If multiple services need it, a gateway-level solution avoids duplication. Blast radius of misconfiguration: denial of legitimate traffic.

**Lens 2 — Deep Dive:** Storage backend for counters — Redis (fast, distributed) vs in-memory (simple, not distributed). Consistency model: eventual is acceptable for rate limiting (small over-count is fine). Idempotency: counter increment must be atomic.

**Lens 3 — Day-2 Ops:** Can limits be adjusted without a deploy (config / feature flag)? How do you detect if rate limiting is causing customer impact? SLI: 429 rate vs 5xx rate. Rollback: disable the limiter via flag, not a redeploy.

**Lens 4 — Long-Term Health:** Follow the existing middleware pattern in the codebase. Don't build custom if a well-maintained library fits. Document the limit values and the rationale in an ADR.

**Lens 5 — Robustness:** What happens if Redis is unavailable? Fail open (allow traffic) or fail closed (block all)? Fail open is safer for availability; document the decision explicitly. Test behavior under Redis timeout.

**Trade-off made explicit:** Choosing eventual consistency over strong consistency — we accept a small over-count under high concurrency in exchange for lower latency and simpler implementation. Acceptable for rate limiting; would not be acceptable for billing.

---

## Decision Output Format

Always communicate decisions **top-down**.

**Advisory Mode output:**
```
## TL;DR
[1-2 sentences: recommendation and the key trade-off]

## Key Decisions
- [Decision]: [Rationale] — [Trade-off]

## Open questions (if any)
- [Anything that needs input before proceeding]
```

**Spec Mode output:**
```
## TL;DR
[1-2 sentences: what you designed and the key decision]

## Key Decisions
- [Decision]: [Rationale] — [Trade-off]

## Spec delivered
- [file path] — [what it covers]
- Status: Draft — pending spec review before Builder can start

## Open questions (if any)
- [Anything that needs user input before review can proceed]
```

For ADRs, use standard format: Context → Decision → Rationale → Consequences.
