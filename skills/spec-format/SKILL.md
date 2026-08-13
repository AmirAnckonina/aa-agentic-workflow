---
name: spec-format
description: "The pipeline's artifact contract: Requirements doc, Approach Brief, Feature Plan, and Spec formats, their lifecycle states and validation rules. Shared by aa-requirements-composition (front stage), the Architect (produces brief/plan/specs), the Builder (implements against), and the Reviewer (validates against)."
user-invocable: false
---

## Keywords
specification, approach brief, architecture, contract, acceptance criteria, interfaces, review gates, TDD, spec lifecycle

## The Two Artifacts

The pipeline produces two artifacts, at different altitudes, gated separately:

| Artifact | Altitude | Location | Gate |
|---|---|---|---|
| **Approach Brief** (~1 page) | Is this the right way to build it? | `docs/briefs/<topic>.md` | `/aa-approach-review` (Gate A) |
| **Spec** (full contract) | Exactly what to build | `docs/specs/<topic>.md` | `/aa-spec-review` (Gate B) |

The brief is challenged **before** the spec is written — rework is cheap on one page, expensive on a full spec.

## Lifecycle

```
Approach Brief:  Draft ──→ Approach Review ──→ Approach-Approved
                              └─ RETHINK ──→ Draft (Architect revises brief)

Spec:            Draft ──→ Detail Audit ──→ Approved
                              └─ Blocking ──→ Draft (Architect revises spec)
```

**Gate A proportionality (quality preserved, ceremony scaled):**
- **Standard feature (default):** the brief is presented *inline in chat* (chosen approach, ≥1 rejected alternative with a real reason, key risk) — no file, no gate run. The user's nod is the approval; the spec's `**Brief:**` line records `_Inline — Gate A waived: [reason]_`. The reasoning lenses still apply — only the ceremony is compressed.
- **Open-design feature** (multiple viable approaches, new dependency, contract changes) **and every system change:** full brief artifact + `/aa-approach-review`. **Gate A cannot be waived for a system change.**
- If a real design question surfaces after an inline brief, the Architect stops and promotes to the full brief + Gate A — no designing through it.

**Gate B skips** (user's call, always recorded): all Review Notes rows set to `⏭️ Skipped`, Status advances to `Approved` directly (trivial changes only).

When a gate sends an artifact back to `Draft`, the Architect revises and the cycle restarts **from that gate**, not from scratch. Prior review rounds are preserved in the artifact.

**The `Status:` field is the single source of truth.** Each gate sets it when it starts and when it verdicts. The Builder checks the spec's status — if not `Approved`, stop.

**Gate consent (canonical rule):** a gate never assumes consent — after any verdict, the next step is the user's call. Exception: **segment consent** granted upfront (e.g. *"run through Gate B"*) lets pass verdicts flow to the next stage without re-asking; any non-pass verdict (RETHINK/Blocking) always stops the segment. Segment consent changes who says "go" between gates, never whether a gate runs, and never substitutes for `Status: Approved` — the Builder's gate is structural.

---

## Requirements & Feature Plan Artifacts (optional — bracket the brief/spec)

Two more artifacts sit around the brief/spec. Both are optional — a known single task uses neither. `spec-format` owns their *format*; the *method* lives elsewhere (`aa-requirements-composition` for requirements; the Architect's on-demand `decomposition` skill for the plan).

- **Requirements doc** — an optional **front stage** (`/aa-requirements`), produced *before* any design: what/why in EARS with `R#` IDs.
- **Feature Plan** — produced by the **Architect**, *after* the brief, and **only when a feature is more than one spec** (spec-then-tasks — the design comes first, tasks derive from it). It designs the feature *as a system* — runtime flow, stages, and the seam contracts the split specs must agree on — and doubles as the ledger of those specs. **Ungated below system scale** (reviewed inline; its lifecycle rides the brief's Gate A); an optional read-only coverage audit runs for system changes only.

### Requirements Doc Format

Location: `docs/requirements/<feature>.md`. Lifecycle: `Draft → Approved` — **Approved only when no `[NEEDS CLARIFICATION]` marker remains and the user approves.**

```markdown
# <Feature> — Requirements

**Status:** Draft | Approved

## User Stories
- As a <role>, I want <capability>, so that <benefit>.

## Acceptance Criteria (EARS)
<!-- Each criterion carries a stable R# ID and uses EARS syntax.
     Templates: aa-requirements-composition/references/ears.md -->
- **R1** — WHEN <trigger>, THE SYSTEM SHALL <response>.
- **R2** — WHILE <precondition>, THE SYSTEM SHALL <response>.
- **R3** — IF <unwanted trigger>, THEN THE SYSTEM SHALL <response>.

## Success Metrics
[How we know it worked — measurable]

## Out of Scope
[Explicitly not this round]

## Open Questions
<!-- Each [NEEDS CLARIFICATION] blocks Approval until resolved -->
- [NEEDS CLARIFICATION] <question>
```

**Rules:** WHAT/WHY only — no tech stack, interfaces, or file names (that's the Architect's job downstream). `R#` IDs are stable and never reused. A criterion you can't write a pass/fail test against isn't done.

### Feature Plan Format

Location: `docs/plan/<feature>-plan.md`. Produced by the Architect from the brief when the feature is multi-spec. Ungated below system scale; optional coverage audit for system changes.

The plan is where the feature is designed **as a system** before it's built as tasks: how the pieces run together, in what order they land, and which interfaces the split specs must agree on. Keep each section as short as the feature allows — two tasks sharing one interface need three lines of seam contract, not a document.

```markdown
# <Feature> — Feature Plan

**Status:** Draft | Approved
**Brief:** docs/briefs/<feature>.md
**Requirements:** docs/requirements/<feature>.md  (or _None_)

## Flow
<!-- The runtime story: the end-to-end path(s) through the components this feature touches —
     "how does the request/job/event travel", not "what are the tasks". A short numbered
     sequence or a small mermaid diagram. -->

## Stages
<!-- Tasks grouped into ordered stages; each stage ends demonstrable. One stage is fine.
     S1 — <name>: T01, T02 → demonstrable: <what provably works when the stage closes> -->

## Seam Contracts
<!-- The frozen interfaces BETWEEN tasks — signatures/types/shapes two or more specs share.
     Defined once here; each spec copies its seams verbatim, never redefines them. Changing
     a seam means updating this plan first, then the affected specs.
     _N/A — tasks share no interfaces_ when the split is seamless. -->

## Tasks
| Task | Title | Path | Stage | Requirements | Depends-on | [P] | Status | Spec | Commit | Verdict |
|------|-------|------|-------|--------------|-----------|-----|--------|------|--------|---------|
| T01  | …     | feature | S1  | R1, R2       | —         | P   | pending | —   | —      | —       |
| T02  | …     | task | S1     | R3           | T01       |     | pending | —   | —      | —       |

## Coverage Audit
<!-- System changes only: populated by the Architect's read-only auditor. Do not edit manually. -->
_Not audited (task/feature) | Not audited yet (system change)_
```

**Columns:** `Path` = how the task runs (`task` = straight to the Builder, no spec · `feature` = spec + Gate B). `Stage` = the stage the task belongs to. `Requirements` = the `R#`s this task satisfies (the traceability spine). `Depends-on` = task IDs that must be `complete` first. `[P]` = parallel-safe (no shared files, no dependency). `Spec`/`Commit`/`Verdict` fill in as the task moves through the pipeline. Status values: `pending → in_progress → review → complete | blocked`.

**Close each stage with an integration checkpoint** — a final `task`-path row whose acceptance criteria are the stage's *demonstrable* line, wiring the stage's pieces together and proving the Flow section's path actually runs end-to-end. No spec needed; it's a bounded task.

---

## Repo Spec Standards (optional, per-repo)

A target repo may declare its design non-negotiables in **`docs/spec-standards.md`** (or another path declared in `docs/agentic-context.md`). Plain markdown, small (keep under ~10 KB), team-owned. Each standard is a short rule — API conventions, security posture, scale realities, naming — optionally marked `[CRITICAL]` in its heading.

How the pipeline uses it:
- **Architect** reads it at Step 0 and writes briefs/specs *to* it.
- **Gate B** injects it verbatim into every auditor: standards override the generic charters on conflict; a `[CRITICAL]` violation is always Blocking; and beyond the charters' own named traps, the file is the auditors' **only license for convention-level findings** — no standard cited, no convention nag.
- **Missing file is not an error** — the pipeline runs on its generic charters alone.

---

## Approach Brief Format

**Hard cap: one page.** If it doesn't fit, the scope is too big — split before briefing.

```markdown
# [Topic] — Approach Brief

**Status:** Draft | Approach Review | Approach-Approved
**Path:** feature | system

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
<!-- Populated by /aa-approach-review. Do not edit manually. -->
_Not reviewed yet_
```

**Rules:** Options Considered must contain at least one real alternative with a real rejection reason — "considered nothing else" is a RETHINK on arrival. No interfaces, no signatures, no file lists — that's spec territory.

---

## Spec Format (Strict Contract)

Every specification MUST contain these sections. The Builder implements against them. The Reviewer validates against them.

**N/A escape hatch (any spec):** a section may be filled with `_N/A — [reason]_` instead of content when it genuinely doesn't apply (e.g., Security Considerations on a log-message fix). The heading itself is never omitted — structure stays greppable. Never write filler to satisfy a heading; `N/A` with a reason beats invented content. Acceptance Criteria and Interfaces are exempt: a spec with no testable criteria or no defined contract is not a spec.

**Conditional sections — N/A is the expected default.** Three sections carry content **only when a written trigger fires**; without the trigger, `_N/A — [reason]_` is the *correct* answer, not a shortcut:

| Section | Write content only when… |
|---|---|
| Security Considerations | the spec's surface includes auth, external/untrusted input, secrets, or sensitive data |
| Failure Modes | the spec introduces or touches an external dependency, or a multi-step operation that can partially fail |
| Component Responsibilities | more than one component is modified |

Untriggered content in these sections is weight, not diligence. Gate B audits the *reason* on an N/A, never the absence itself.

```markdown
# [Feature Name]

**Status:** Draft | Detail Audit | Approved
**Brief:** docs/briefs/<topic>.md (Approach-Approved) | _Inline — Gate A waived: [reason]_
**Plan:** docs/plan/<feature>-plan.md   <!-- decomposed features only — omit the line otherwise -->
**Requirements:** R1, R3 (docs/requirements/<feature>.md) | _N/A — inline task_

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
<!-- Populated by /aa-spec-review (detail audits). Do not edit manually. -->
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

**Plan linkage (decomposed features):** the `**Plan:**` line links the Feature Plan this spec derives from. The spec **copies its seam contracts from the plan verbatim into its `Interfaces` section**, each annotated `(seam — defined in plan)` — so the Builder and Reviewer enforce them through the normal Interfaces contract. A seam is defined in the plan and never unilaterally changed in a spec. Single-spec features omit the line.

**Requirements traceability:** the `**Requirements:**` line lists the `R#` IDs this spec satisfies — the link back up the chain requirement → task → spec. When the feature came from a Feature Plan, copy the `R#`s from the task's row; when it came from a requirements doc directly, list the `R#`s the spec covers. Individual acceptance criteria may annotate their source as `(R#)`. When the spec originates from a lone task with no requirements doc (the standalone Architect path), the line reads `_N/A — inline task_`. The Reviewer checks this line in Pass 1.

---

## Rules

- **Acceptance criteria** must be testable — no vague language like "should be fast."
- **Interfaces** must be exact — the Builder implements them as-is, not interprets them.
- Every function signature must include its error/exception cases.
- Missing or ambiguous sections → STOP and ask. Do not assume or invent.

## Scope Guidelines — the unit contract

This is the pipeline's **unit contract**: the build loop consumes exactly one shape of work — one spec covering one cohesive capability, independently implementable, testable, and reviewable in one cycle. Everything upstream of the Builder exists to convert work of any maturity into approved units; nothing bigger ever reaches implementation.

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

**Ordering split specs:** Number them and note dependencies (e.g., "Prerequisite: Spec 1 must be complete"). Split specs share one Approach-Approved brief and derive from one Feature Plan, copying their seam contracts from it.

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

- **Architect:** Produces the brief first (feature and system paths); after `Approach-Approved` (or a recorded skip), produces the spec following this format exactly. All section headings required (`N/A — reason` allowed per the escape hatch above; conditional sections default to N/A absent their trigger). For multi-spec features, produces the Feature Plan first and copies each spec's seam contracts from it. Writes function signatures and type definitions — never function bodies. When finishing the spec, asks the user which reviews to run before advancing status.
- **Approach Review (`/aa-approach-review`, Gate A):** Reads the brief. Writes challenge rounds into the brief's `## Approach Review` section. Sets brief Status: `Approach Review` while active → `Approach-Approved` on PASS, `Draft` on RETHINK.
- **Detail Audit (`/aa-spec-review`, Gate B):** Verifies the linked brief is `Approach-Approved` (or the skip is recorded). Its fresh-context auditors read the full spec + brief. Fills the `## Review Notes` table per perspective. Updates spec `Status` to `Detail Audit` while active, back to `Draft` if blocking issues, or to `Approved` if all pass.
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
