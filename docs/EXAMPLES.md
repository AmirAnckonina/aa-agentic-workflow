# Examples — picking the path and running it

Worked walkthroughs for the common entry points. The core question is always the same:

> **Can one spec hold it?** A spec covers one cohesive capability — ~5–12 acceptance criteria, ≤5 interfaces, ≤3 components, readable in under 5 minutes.
> - **Fits** → hand straight to `@architect` (it's one spec).
> - **Clearly doesn't** — 3+ independent pieces, spans services, multi-session → the Architect decomposes it into a Task Map.
> - **Unsure** → hand it to `@architect` anyway; it tells you if it needs to decompose. **Don't pre-split out of caution.**

Each example shows what you type, what comes back, and where artifacts land.

---

## 1. T1 — bounded task (the light default)

You already know the change; ≤3 files, no design questions.

```
@builder Add a SlugifyTitle(s string) string helper to internal/text.
Acceptance criteria:
- lowercases, trims, replaces space/punctuation runs with single hyphens
- collapses repeated hyphens; strips leading/trailing hyphens
```
→ Builder runs TDD, verifies, prints a Build Report with an AC→Test map. **No spec, no gates.** Optional `/code-review` after.

---

## 2. T2 — feature, one spec (straight to the Architect)

One cohesive capability. You hand the whole thing over and it turns out to be one spec.

```
@architect Add rate limiting to the POST /logs endpoint.
```
→ Architect loads context, confirms tier T2, presents an **inline brief** (chosen approach + one rejected alternative + key risk), says **"this is one spec,"** writes `docs/specs/logs-rate-limit.md` [Draft].
→ `/spec-review docs/specs/logs-rate-limit.md` (Gate B lite) → Approved.
→ `@builder Implement docs/specs/logs-rate-limit.md` → Build Report.
→ commit → `/review-internal` → SHIP IT.

**No decomposition, no Task Map** — the feature fit one spec. This is the 90% path.

---

## 3. T3 — system change (full brief + Gate A, then decompose)

Cross-service / irreversible. Full rigor.

```
@architect Introduce an outbox pattern for order events across order-svc and billing-svc.
```
→ Architect runs Discovery + Research, writes `docs/briefs/order-outbox.md` [Draft].
→ `/approach-review docs/briefs/order-outbox.md` (Gate A — mandatory for T3) → PASS.
→ Architect decides **"decomposes into 3 specs"** → writes `docs/plan/order-outbox-taskmap.md` and offers the T3 coverage audit.
→ writes the first spec → Gate B **panel** → build → review → picks the next task.

---

## 4. Multi-spec feature (Architect draws the seams)

Bigger than one spec — but you don't pre-split. Hand it up and let the design decide.

```
@architect Build CSV export for the reports page: a background job, an API to trigger and poll it, and a download endpoint.
```
→ Architect: brief (feature design) → **"this decomposes into 3 specs"** → `docs/plan/reports-export-taskmap.md`:

| Task | Title | Tier | Depends-on | [P] |
|------|-------|------|-----------|-----|
| T01  | export job + storage | T2 | — | |
| T02  | trigger/poll API | T2 | T01 | |
| T03  | download endpoint | T2 | T01 | P |

→ writes the spec for T01 now → Gate B → build → review. Then **you** pick T02 (or T03 — it's `[P]`, no shared files).
**The Task Map is the Architect's ledger; you schedule the next task — there's no auto-runner.**

---

## 5. Fuzzy, multi-piece need (start at requirements)

The need is a paragraph, not crisp criteria yet.

```
/requirements Users keep losing unsaved work; we want autosave + recovery.
```
→ Interview (via `superpowers:brainstorming`) → `docs/requirements/autosave.md` with EARS `R#` criteria; you resolve the `[NEEDS CLARIFICATION]` markers → approve → Status: Approved.
```
@architect Design autosave from docs/requirements/autosave.md
```
→ Architect reads the `R#`s, writes the brief, decides one-spec-or-many, and (if many) produces a Task Map whose tasks cite the `R#`s. Traceability runs `R#` → task → spec → test → review.

---

## Where things live

| Artifact | Path | Produced by |
|---|---|---|
| Requirements (EARS, `R#`) | `docs/requirements/<feature>.md` | `/requirements` (optional) |
| Approach Brief (feature design) | `docs/briefs/<feature>.md` | `@architect` |
| Task Map (only if multi-spec) | `docs/plan/<feature>-taskmap.md` | `@architect` |
| Spec (one per task) | `docs/specs/<feature>.md` | `@architect` |
