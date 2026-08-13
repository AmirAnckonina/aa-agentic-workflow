# Workflow Guide

> **You are here:** the operating manual — how to drive the pipeline day to day. · [README](../README.md) · [Getting started](GETTING-STARTED.md) · [Design rationale](DESIGN.md)

The pipeline: *(requirements →)* intake → discovery → approach → **decompose** → spec → build → review → ship. It is **spec-driven** — the design comes first, and a feature is split into task-specs only *after* the design, and only when it's more than one spec.

---

## Routing — the pipeline proposes, you confirm

You don't classify work up front. Hand it over; the **Architect proposes** a tier in its first step and you confirm or override.

```mermaid
flowchart TD
    S["Work arrives"] --> Q1{"Does behavior<br/>change?"}
    Q1 -->|No| T0["<b>T0</b> — direct chat<br/>no pipeline, no artifacts"]
    Q1 -->|Yes| Q2{"Clear criteria, ≲3 files,<br/>no design questions?"}
    Q2 -->|Yes| T1["<b>T1</b> — @builder inline<br/>TDD · no spec · no gates"]
    Q2 -->|No| Q3{"Cross-service, migration,<br/>new infra, or irreversible?"}
    Q3 -->|Yes| T3["<b>T3-full</b><br/>brief file + Gate A <b>mandatory</b><br/>Gate B panel — 5 auditors<br/>/code-review high"]
    Q3 -->|No| Q4{"More than one<br/>viable approach?"}
    Q4 -->|Yes| T2O["<b>T2 open-design</b><br/>brief file + Gate A<br/>Gate B lite"]
    Q4 -->|No| T2F["<b>T2-fast</b> — the 90% path<br/>inline brief, Gate A waived<br/>Gate B lite — 1 auditor<br/>/code-review medium"]

    classDef q fill:#fef3c7,stroke:#d97706,stroke-width:1.5px,color:#0f172a
    classDef light fill:#dcfce7,stroke:#16a34a,stroke-width:1.5px,color:#0f172a
    classDef heavy fill:#dbeafe,stroke:#2563eb,stroke-width:1.5px,color:#0f172a
    class Q1,Q2,Q3,Q4 q
    class T0,T1,T2F light
    class T2O,T3 heavy
```

**T2-fast and T3-full carry almost everything.** The rest are **escalations the pipeline surfaces — never knobs you pre-select**:

- **Below T2, the agent tells you.** Hand a T0 or T1 to the Architect and it declines, naming the direct path instead.
- **Mid-flight promotion.** A T1 that surfaces a design question → the Builder stops and recommends T2. An ordinary T2 that surfaces one mid-spec → the Architect promotes to a full brief plus Gate A. **Nothing designs ad hoc.**
- **Gate-B breadth.** Lite by default; the auditor **auto-escalates to panel** on real risk (auth, migration, external API, irreversible). Force it with *"panel mode"*; waive it with *"skip Gate B"* (trivial changes only).

**Don't over-tier and don't over-split.** Running T3 rigor on T2 work, or decomposing what one spec could hold, is the biggest self-inflicted cost in the system.

## The pipeline, stage by stage

| # | Stage | Who | Produces | Gate |
|---|---|---|---|---|
| 1 | Discovery | `superpowers:brainstorming` | nothing — chat only | — |
| 2 | Approach Brief | `@architect` | inline in chat (T2) · `docs/briefs/<t>.md` (T3, open-design) | **Gate A** on file briefs — `/approach-review` |
| 2.5 | Decompose | `@architect` | `docs/plan/<t>-taskmap.md`, only if multi-spec | ungated for T1/T2 |
| 3 | Full spec | `@architect` | `docs/specs/<t>.md` [Draft] | **Gate B** — `/spec-review` |
| 4 | Build | `@builder` | code + tests + Build Report | refuses unless `Status: Approved` |
| 5 | Review | you commit, then `@reviewer` | Pass 1 spec compliance · Pass 2 `/code-review` | SHIP IT / NEEDS WORK / BLOCKER |
| 6 | Ship (on request) | `superpowers:finishing-a-development-branch` + `gh-ops`/`glab-ops` | branch merged | — |

Specs are written **just in time**, one at a time, even when a Task Map exists.

### The same path as a conversation

```mermaid
sequenceDiagram
    autonumber
    actor You
    participant A as @architect
    participant G as Gate B auditor
    participant B as @builder
    participant R as @reviewer

    You->>A: feature request
    A->>A: Step 0 — load declared context
    A-->>You: tier + inline brief — approve?
    You->>A: go
    A->>A: write docs/specs/x.md [Draft]
    A-->>You: run Gate B?

    You->>G: /spec-review docs/specs/x.md
    Note over G: fresh context —<br/>never sees the Architect's reasoning
    G-->>You: Approved → spec Status flips

    You->>B: implement docs/specs/x.md
    B->>B: verify Status: Approved, then TDD
    B-->>You: Build Report + AC → Test map

    You->>You: commit to a feature branch
    You->>R: /review-internal
    R->>R: Pass 1 — spec compliance
    R->>R: Pass 2 — /code-review
    R-->>You: SHIP IT | NEEDS WORK | BLOCKER
```

Two details in there matter more than the sequence: the Gate B auditor runs in **fresh context**, so it can't be argued into agreement by reasoning it never saw; and the commit is **yours**, because the Builder is structurally blocked from git writes — which guarantees the Reviewer has a real diff.

## Gate mechanics

### Status is law

Every artifact carries a `Status:` field. That field — not the conversation — is the single source of truth, and downstream stages check it **structurally**.

```mermaid
stateDiagram-v2
    direction LR
    [*] --> BriefDraft: @architect writes brief
    BriefDraft: Brief — Draft
    BriefDraft --> ApproachReview: /approach-review
    ApproachReview: Brief — Approach Review
    ApproachReview --> BriefDraft: RETHINK
    ApproachReview --> BriefApproved: PASS
    BriefApproved: Brief — Approach-Approved

    BriefApproved --> SpecDraft
    [*] --> SpecDraft: fast track — Gate A waived, recorded
    SpecDraft: Spec — Draft
    SpecDraft --> DetailAudit: /spec-review
    DetailAudit: Spec — Detail Audit
    DetailAudit --> SpecDraft: Blocking findings
    DetailAudit --> SpecApproved: clean
    SpecApproved: Spec — Approved

    SpecApproved --> Building: @builder unlocked
    Building --> [*]
```

A non-pass verdict always returns the artifact to `Draft`, and the cycle re-enters at that same gate with **prior rounds preserved** — review history is appended, never overwritten.

### Gate consent

Every gate ends with a verdict presented to you. Nothing assumes your consent. "Go" is your word, given **per-gate** or **once for a segment** (*"run it through Gate B"*, *"…through the build"*): PASS verdicts then flow onward, but any RETHINK or Blocking stops the segment cold.

Segment consent never bypasses a gate — it only pre-answers "go" on a pass, and never substitutes for `Status: Approved` at the Builder boundary.

### Gate B: which mode

| The spec is… | Gate B |
|---|---|
| Trivial or mechanical — no new logic, no external input, no contract change | **Skip** — marked Approved directly, recorded as `⏭️ Skipped`. Rare; such work is usually T0/T1 anyway. |
| Ordinary T2 (the default) | **Lite** — one **Opus** auditor, **focused** to the 2–3 perspectives that matter (Completeness + Scope always; Security / Scalability / API Design only if the surface triggers them) |
| T3, or a T2 touching **auth, migration, external API, or an irreversible change** | **Panel** — 5 independent Opus auditors in parallel. A lite auditor auto-escalates here if it smells real risk. |

Lite is cheaper by **breadth, not depth** — it keeps full Opus reasoning, because Gate B is the last check before code exists. Elsewhere the model tier does drop: mechanical stages (Reviewer, `/requirements`) run on Sonnet, design-critical ones (Architect, both gates) stay Opus.

## Front stage and decomposition

Starting from fuzzy needs? Run `/requirements` first for a gated EARS requirements doc (`docs/requirements/<f>.md`, `R#` IDs). Already know the work? Skip it — the fast path pays nothing for this stage existing.

**Decomposition lives inside the Architect.** You do **not** split work up front. Hand a feature over; it designs the brief, then decides **one spec or many**. Most features are one spec.

**The decision rule — "can one spec hold it?"** A spec is one cohesive capability: roughly 5–12 acceptance criteria, ≤5 interfaces, ≤3 components. Fits → one spec. Doesn't → the Architect decomposes into a **Task Map** (`docs/plan/<f>-taskmap.md`), produced *after* the design and ungated for T1/T2. Unsure → hand it up anyway. **Don't pre-split out of caution.**

```mermaid
flowchart LR
    BR["Approach Brief<br/>one design for the whole feature"] --> TM["Task Map<br/>docs/plan/reports-export-taskmap.md"]

    TM --> T01["<b>T01</b> export job + storage<br/>Depends-on: —"]
    TM --> T02["<b>T02</b> trigger/poll API<br/>Depends-on: T01"]
    TM --> T03["<b>T03</b> download endpoint<br/>Depends-on: T01 · <b>[P]</b>"]

    T01 -->|unblocks| T02
    T01 -->|unblocks| T03
    T02 -.->|"[P] — no shared files,<br/>build concurrently in<br/>separate worktrees"| T03

    T01 --> S1["spec → Gate B → build → review"]
    T02 --> S2["spec → Gate B → build → review"]
    T03 --> S3["spec → Gate B → build → review"]

    classDef art fill:#f1f5f9,stroke:#64748b,stroke-width:1.5px,color:#0f172a
    classDef task fill:#dbeafe,stroke:#2563eb,stroke-width:1.5px,color:#0f172a
    classDef run fill:#dcfce7,stroke:#16a34a,stroke-width:1.5px,color:#0f172a
    class BR,TM art
    class T01,T02,T03 task
    class S1,S2,S3 run
```

**You schedule; the map coordinates.** There is no orchestrator. Pick the next `pending` task whose `Depends-on` are `complete` → the Architect writes that spec just in time → Gate B → build → review → update the row. Mirror the rows into your session's native to-do list if you want a live board: the markdown map is the **durable ledger** (survives context resets), the to-do list is the **disposable view**.

**Parallelize `[P]` tasks.** They share no files and no dependencies — build them concurrently in separate worktrees (`superpowers:using-git-worktrees` + `superpowers:dispatching-parallel-agents`). On 2–3 independent specs this roughly **halves** wall-clock, and each still passes its own Gate B and review.

## Worked scenarios

The core question is always the same: **can one spec hold it?** The standard T2 path — one feature, one spec — is walked step by step in [GETTING-STARTED](GETTING-STARTED.md#4-your-first-feature-end-to-end); these are the other four shapes.

### 1. T1 — bounded task

You already know the change; ≤3 files, no design questions.

```text
@builder Add a SlugifyTitle(s string) string helper to internal/text.
Acceptance criteria:
- lowercases, trims, replaces space/punctuation runs with single hyphens
- collapses repeated hyphens; strips leading/trailing hyphens
```

→ Builder runs TDD, verifies, prints a Build Report with an AC → Test map. **No spec, no gates.** Optional `/code-review` afterwards.

*If the Builder reports that a design question surfaced, accept the promotion to T2 — don't push it to improvise.*

### 2. T3 — system change

```text
@architect Introduce an outbox pattern for order events across order-svc and billing-svc.
```

→ Architect runs Discovery + Research, writes `docs/briefs/order-outbox.md` [Draft].
→ `/approach-review docs/briefs/order-outbox.md` — Gate A, **mandatory for T3** → PASS.
→ Architect decides *"this decomposes into 3 specs"* → writes `docs/plan/order-outbox-taskmap.md` and offers the T3 coverage audit.
→ writes the first spec → Gate B **panel** → build → review → you pick the next task.

### 3. Multi-spec feature

Bigger than one spec — but you still don't pre-split.

```text
@architect Build CSV export for the reports page: a background job, an API to
trigger and poll it, and a download endpoint.
```

→ Architect: brief → *"this decomposes into 3 specs"* → `docs/plan/reports-export-taskmap.md`:

| Task | Title | Tier | Depends-on | [P] |
|------|-------|------|-----------|-----|
| T01  | export job + storage | T2 | — | |
| T02  | trigger/poll API | T2 | T01 | |
| T03  | download endpoint | T2 | T01 | P |

→ writes the spec for T01 now → Gate B → build → review. Then **you** pick T02 — or T03, since it's `[P]`.

### 4. Fuzzy, multi-piece need

The need is a paragraph, not crisp criteria yet.

```text
/requirements Users keep losing unsaved work; we want autosave + recovery.
```

→ Interview via `superpowers:brainstorming` → `docs/requirements/autosave.md` with EARS `R#` criteria. You resolve the `[NEEDS CLARIFICATION]` markers, approve → `Status: Approved`.

```text
@architect Design autosave from docs/requirements/autosave.md
```

→ Architect reads the `R#`s, writes the brief, decides one-spec-or-many, and produces a Task Map whose tasks cite the `R#`s. Traceability then runs `R#` → task → spec → test → review.

## Reference

### Gate phrases

| Say | Effect |
|---|---|
| *"go"* / *"proceed"* | advance past the gate that just passed |
| *"run it through Gate B"* / *"…through the build"* | segment consent — PASS flows, non-pass stops |
| *"panel mode"* | force the 5-auditor Gate B on a T2 |
| *"skip Gate B"* | trivial changes only — recorded as `⏭️ Skipped` in the spec |
| *"expand CRT-1"* / *"show AC coverage"* | drill into review findings |

### Quick reference

| I want to… | Do |
|---|---|
| Turn a raw need into structured requirements | `/requirements` |
| Design a feature (the Architect splits it if needed) | `@architect` (or `claude --agent architect`) |
| Challenge an approach | `/approach-review` on the brief |
| Audit a spec | `/spec-review` on the spec |
| Implement an Approved spec | `@builder` |
| Small bounded task, no spec | `@builder` with the task + inline ACs |
| Review the branch | `/review-internal [focus]` |
| Ask an advisory design question | just ask — `architect-methodology` handles it in chat |

### Complementary tools (outside the pipeline)

- **aa-code-review** — heavyweight independent sweeps: big features on request, or a CI quality gate. Zero coupling with this pipeline by design.
- **`/code-review ultra`** — release-critical deep review; user-triggered only.

---

**Setup, run modes, and troubleshooting:** [GETTING-STARTED.md](GETTING-STARTED.md) · **Why it's built this way:** [DESIGN.md](DESIGN.md)
