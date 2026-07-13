---
name: spec-format
description: "The pipeline's artifact contract: Approach Brief and Spec formats, lifecycle states (Brief: Draft → Approach-Approved; Spec: Draft → Approved), and validation rules. Shared by Architect (produces), Builder (implements against), and Reviewer (validates against)."
user-invocable: false
---

## Keywords
specification, approach brief, architecture, contract, acceptance criteria, interfaces, review gates, TDD, spec lifecycle

## The Two Artifacts

The pipeline produces two artifacts, at different altitudes, gated separately:

| Artifact | Altitude | Location | Gate |
|---|---|---|---|
| **Approach Brief** (~1 page) | Is this the right way to build it? | `docs/briefs/<topic>.md` | `/approach-review` (Gate A) |
| **Spec** (full contract) | Exactly what to build | `docs/specs/<topic>.md` | `/spec-review` (Gate B) |

The brief is challenged **before** the spec is written — rework is cheap on one page, expensive on a full spec.

## Lifecycle

```
Approach Brief:  Draft ──→ Approach Review ──→ Approach-Approved
                              └─ RETHINK ──→ Draft (Architect revises brief)

Spec:            Draft ──→ Detail Audit ──→ Approved
                              └─ Blocking ──→ Draft (Architect revises spec)
```

**Gate A proportionality (quality preserved, ceremony scaled):**
- **Ordinary T2 (default):** the brief is presented *inline in chat* (chosen approach, ≥1 rejected alternative with a real reason, key risk) — no file, no gate run. The user's nod is the approval; the spec's `**Brief:**` line records `_Inline — Gate A waived: [reason]_`. The reasoning lenses still apply — only the ceremony is compressed.
- **Open-design T2** (multiple viable approaches, new dependency, contract changes) **and all T3:** full brief artifact + `/approach-review`. **Gate A cannot be waived for T3.**
- If a real design question surfaces after an inline brief, the Architect stops and promotes to the full brief + Gate A — no designing through it.

**Gate B skips** (user's call, always recorded): all Review Notes rows set to `⏭️ Skipped`, Status advances to `Approved` directly (trivial changes only).

When a gate sends an artifact back to `Draft`, the Architect revises and the cycle restarts **from that gate**, not from scratch. Prior review rounds are preserved in the artifact.

**The `Status:` field is the single source of truth.** Each gate sets it when it starts and when it verdicts. The Builder checks the spec's status — if not `Approved`, stop.

---

## Approach Brief Format

**Hard cap: one page.** If it doesn't fit, the scope is too big — split before briefing.

```markdown
# [Topic] — Approach Brief

**Status:** Draft | Approach Review | Approach-Approved
**Tier:** T2 | T3

## Problem
[What we're solving and for whom — 2-4 sentences]

## Constraints
[Hard limits: tech, timeline, compatibility, team]

## Options Considered
1. **[Option A]** — rejected: [reason]
2. **[Option B]** — rejected: [reason]
3. **[Chosen]** — see below

## Chosen Approach
[The approach in 3-6 sentences: components touched, data flow, key pattern]

## Risks
[What could make this the wrong call — with mitigation or "accepted"]

## Blast Radius
[What breaks if this fails; other systems/teams affected]

## Approach Review
<!-- Populated by /approach-review. Do not edit manually. -->
_Not reviewed yet_
```

**Rules:** Options Considered must contain at least one real alternative with a real rejection reason — "considered nothing else" is a RETHINK on arrival. No interfaces, no signatures, no file lists — that's spec territory.

---

## Spec Format (Strict Contract)

Every specification MUST contain these sections. The Builder implements against them. The Reviewer validates against them.

**N/A escape hatch (simple / fast-track specs):** a section may be filled with `_N/A — [reason]_` instead of content when it genuinely doesn't apply (e.g., Security Considerations on a log-message fix). The heading itself is never omitted — structure stays greppable. Never write filler to satisfy a heading; `N/A` with a reason beats invented content. Acceptance Criteria and Interfaces are exempt: a spec with no testable criteria or no defined contract is not a spec.

```markdown
# [Feature Name]

**Status:** Draft | Detail Audit | Approved
**Brief:** docs/briefs/<topic>.md (Approach-Approved) | _Inline — Gate A waived: [reason]_

## Overview
[1-2 paragraphs: what this is and why]

## Acceptance Criteria
- [ ] [Testable requirement — the Builder writes tests against these]
- [ ] [Each criterion must be verifiable with a pass/fail test]

## Interfaces
[Exact function signatures, types, and contracts in the target language]

### Types / Models
[Struct/class definitions, enums, error types]

### Public Functions / Methods
[Signatures with parameter types, return types, and error cases]

### API Contracts (if applicable)
[Endpoints, request/response shapes, status codes]

## Files to Change (optional but recommended)
[List of files to create or modify, with a one-line description of what changes.
Do NOT include implementation code — just what and where.]

## Component Responsibilities
[Which component owns what — one paragraph per component]

## Error Handling
[Expected error cases and how each must be handled]

## Security Considerations
[Auth, input validation, data protection requirements]

## Failure Modes
[What can go wrong and the expected recovery behavior]

## Constraints
[Performance targets, compatibility, dependencies]

## Review Notes
<!-- Populated by /spec-review (detail audits). Do not edit manually. -->
| Perspective  | Status     | Issues |
|---|---|---|
| Security     | ⬜ Pending | —      |
| Scalability  | ⬜ Pending | —      |
| API Design   | ⬜ Pending | —      |
| Completeness | ⬜ Pending | —      |
| Scope        | ⬜ Pending | —      |

<!-- Status values: ⬜ Pending · ✅ Approved · ❌ Issues Found · ⏭️ Skipped -->
```

Strategic/approach concerns live in the **brief's** `## Approach Review` section — the spec has no strategic-review section. Gate B auditors read the linked brief to know what was already challenged.

---

## Rules

- **Acceptance criteria** must be testable — no vague language like "should be fast."
- **Interfaces** must be exact — the Builder implements them as-is, not interprets them.
- Every function signature must include its error/exception cases.
- Missing or ambiguous sections → STOP and ask. Do not assume or invent.

## Scope Guidelines

A well-scoped spec should:
- Cover **one cohesive capability** (not multiple bundled features)
- Have **5-12 acceptance criteria** (not 25+)
- Define **1-5 function signatures** in the Interfaces section (not 10+)
- Be **readable in under 5 minutes**

**Split the spec** when:
- Acceptance criteria exceed 12 items
- More than 3 components are being modified
- The spec covers independent capabilities that could be implemented and tested separately
- You find yourself writing "Phase 1" and "Phase 2" in the same spec

**Ordering split specs:** Number them and note dependencies (e.g., "Prerequisite: Spec 1 must be complete"). Split specs may share one Approach-Approved brief.

## Anti-Patterns (What NOT to Include)

The spec defines **what** and **why**. The Builder decides **how**. Do NOT include:

| Anti-Pattern | Why It's Wrong | What to Write Instead |
|---|---|---|
| Function body pseudocode | Builder's job — they follow TDD to discover the implementation | Function signature + error cases + acceptance criterion that tests the behavior |
| Step-by-step implementation walkthrough | Removes Builder's autonomy and creates false precision | Files to Change section with one-line descriptions |
| Complete mock/test code | Builder writes tests as part of TDD Red step | List test case names in acceptance criteria |
| Before/after code diffs | Brittle — code may have changed since spec was written | Describe the behavioral change, not the diff |
| "Phase 2 Notes" or future speculation | Out of scope — design Phase 2 when Phase 2 starts | Constraints section: "Phase 2 will add X — design for extensibility but do not implement" |
| Exact log messages or log field names | Implementation detail | "Structured log entry emitted for [operation] including [key context fields]" |

**The test:** If you delete all code blocks from your spec and it still conveys the full design intent, it's the right weight. If it becomes meaningless, you embedded too much implementation.

## How Each Agent Uses This

- **Architect:** Produces the brief first (T2+); after `Approach-Approved` (or a recorded skip), produces the spec following this format exactly. All section headings required (`N/A — reason` allowed per the escape hatch above). Writes function signatures and type definitions — never function bodies. When finishing the spec, asks the user which reviews to run before advancing status.
- **Approach Review (`/approach-review`, Gate A):** Reads the brief. Writes challenge rounds into the brief's `## Approach Review` section. Sets brief Status: `Approach Review` while active → `Approach-Approved` on PASS, `Draft` on RETHINK.
- **Detail Audit (`/spec-review`, Gate B):** Verifies the linked brief is `Approach-Approved` (or the skip is recorded). Reads the full spec + brief. Fills the `## Review Notes` table per perspective. Updates spec `Status` to `Detail Audit` while active, back to `Draft` if blocking issues, or to `Approved` if all pass.
- **Builder:** First checks spec `Status` — if not `Approved`, stop and point to the gates. Then maps each section to implementation:
  - Acceptance Criteria → test cases (at least one per criterion)
  - Interfaces → exact implementation (no renaming, no reordering)
  - Files to Change → implementation plan and file creation order
  - Error Handling → recovery behavior
  - Constraints → performance/compatibility targets
- **Reviewer:** Validates implementation against the spec:
  - Signatures, types, error cases match exactly
  - Every acceptance criterion has a corresponding test
  - Scope matches — nothing extra, nothing missing
