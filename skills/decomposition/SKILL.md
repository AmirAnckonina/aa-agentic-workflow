---
name: decomposition
description: "How the Architect decomposes a feature into a Feature Plan — deciding one spec vs many, then designing the runtime flow, stages, and seam contracts the split specs derive from. Loaded on demand by the Architect at step 3.5; runs downstream of the brief, not as a front stage. Not user-invocable."
user-invocable: false
---

# Decomposition (Architect method)

## What this is

The method the Architect uses to answer one question once the design brief exists: **is this feature one spec, or many?** — and, if many, to produce a **Feature Plan** the specs derive from.

This is **spec-then-tasks** — the model every leading spec-driven tool uses (Spec Kit, Kiro, OpenSpec, Taskmaster, BMAD): the feature-level design (Approach Brief) comes first; tasks are derived from it. It is **not** a front stage and **not** user-invokable — it's a beat inside the Architect's Spec Mode, between Gate A and the spec(s).

It's the existing "split the spec" decision (`spec-format`) made explicit and given a plan. **For the common case the answer is "one spec" and this method costs one line.**

## Position

```
Approach Brief (Gate A) → [THIS: one spec or many?] → Spec(s) (Gate B) → Builder
```

## Keywords

decomposition, feature plan, task map, split the spec, one spec or many, tasks, stages, seam contracts, dependencies, right-sizing, requirement traceability, waves, integration checkpoint

---

## Step 1: One spec or many?

Apply the `spec-format` split criteria to the brief's design. It's **one spec** — write it directly, skip the rest of this skill — **unless** any of these hold, in which case it's **many**:

- more than ~12 acceptance criteria, or >3 components modified;
- independent capabilities that ship and test separately;
- spans layers/services (e.g. migration + backend + API);
- you catch yourself writing "Phase 1 / Phase 2".

State the decision in one line: *"This is one spec"* or *"This decomposes into N specs — writing a Feature Plan."* Don't manufacture a split; most features are one spec.

## Step 2: Design the Feature Plan (only when "many")

Write `docs/plan/<feature>-plan.md` per the **Feature Plan format** in `spec-format`. Work top-down — system first, tasks last:

1. **Flow** — narrate the runtime path end to end: how the request/job/event travels through the components this feature touches. If you can't tell this story from the brief, the design isn't settled — go back before splitting. The flow is what makes the split *coherent* rather than merely *sized*.
2. **Seams** — the split boundaries fall out of the flow: Lens-1 service boundaries and Lens-4 cohesion from the brief tell you where. **Every boundary two tasks share becomes a seam contract** — write the shared signature/type/shape into `## Seam Contracts` *now*, before any spec exists. Specs copy their seams verbatim; a seam changes by updating the plan first. This is what lets just-in-time specs, written weeks apart, not drift.
3. **Stages** — group the tasks into ordered stages, each ending *demonstrable* (something provably runs when the stage closes). Prefer **vertical slices** — a thin end-to-end path first, then widen — over layer-by-layer (all models, then all services) when the flow allows it; a walking skeleton beats a warehouse of parts. One stage is fine for small splits.
4. **Tasks** — each task: **one independently testable unit** (a reviewer could accept it alone) — size to the seam, not a clock; carries a **path** (`task` — straight to the Builder, no spec · `feature` — spec + Gate B) per `docs/WORKFLOW.md` routing; its **stage**; the **`R#`s** it satisfies when a requirements doc exists; **`Depends-on`** and **`[P]`** when parallel-safe. **Close each stage with an integration checkpoint** — a `task`-path row whose ACs are the stage's demonstrable line, proving the Flow actually runs.

The Feature Plan is the **durable ledger**. The human's driving session mirrors its task rows into the native to-do board for live tracking (see `docs/WORKFLOW.md`) — that board is the driver's, not yours; you own the plan file.

## Step 3: Right-weight check (ungated below system scale)

Present the Feature Plan top-down and refine it inline with the user. **Do not gate it** for ordinary work — review, adjust, proceed. The design was already challenged at Gate A; the split is a derivative, not a new decision.

**System changes only:** offer a read-only coverage audit — a fresh-context subagent (the Gate-B dispatch pattern) checking that every `R#` is covered by ≥1 task, no task cites a dangling `R#`, `Depends-on` is acyclic, the path assignments are sane, and **every interface shared by two tasks appears in Seam Contracts**. Record it in the plan's `## Coverage Audit` section. This is the *only* place decomposition adds a gate, and only at system scale.

## Step 4: Specs, just-in-time

Write the **first** spec now; author the rest **per task as the user schedules them** — spec durable, context disposable. Each spec links the plan in its `**Plan:**` line, **copies its seam contracts from the plan verbatim**, records its `R#`s in its `**Requirements:**` line, and links the shared brief. If writing a spec reveals a seam contract is wrong, stop — fix the plan, flag the impact on dependent tasks, then continue. The Architect hands the Builder **one spec at a time**; the human picks the next task from the plan.

---

## Boundaries

- Decomposition never runs before a design brief exists (spec-then-tasks, never tasks-first).
- The Feature Plan is the Architect's **ledger**, not an orchestrator — no auto-dispatch, no running the pipeline for the user. The human schedules the next task.
- Stages are **committed work, ordered** — not speculation. "Phase 2 someday" content still belongs nowhere; a stage exists only if its tasks are in the table.
- One concept, not two: this *is* `spec-format`'s "split the spec" — don't invent a parallel mechanism.
