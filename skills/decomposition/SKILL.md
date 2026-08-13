---
name: decomposition
description: "How the Architect decomposes a feature into a Task Map — deciding one spec vs many, then right-sizing, tiering, ordering, and R#-mapping the tasks that derive from the Approach Brief. Loaded on demand by the Architect at step 3.5; runs downstream of the brief, not as a front stage. Not user-invocable."
user-invocable: false
---

# Decomposition (Architect method)

## What this is

The method the Architect uses to answer one question once the design brief exists: **is this feature one spec, or many?** — and, if many, to produce a **Task Map** the specs derive from.

This is **spec-then-tasks** — the model every leading spec-driven tool uses (Spec Kit, Kiro, OpenSpec, Taskmaster, BMAD): the feature-level design (Approach Brief) comes first; tasks are derived from it. It is **not** a front stage and **not** user-invokable — it's a beat inside the Architect's Spec Mode, between Gate A and the spec(s).

It's the existing "split the spec" decision (`spec-format`) made explicit and given a ledger. **For the common case the answer is "one spec" and this method costs one line.**

## Position

```
Approach Brief (Gate A) → [THIS: one spec or many?] → Spec(s) (Gate B) → Builder
```

## Keywords

decomposition, task map, split the spec, one spec or many, tasks, dependencies, tiering, right-sizing, requirement traceability, waves

---

## Step 1: One spec or many?

Apply the `spec-format` split criteria to the brief's design. It's **one spec** — write it directly, skip the rest of this skill — **unless** any of these hold, in which case it's **many**:

- more than ~12 acceptance criteria, or >3 components modified;
- independent capabilities that ship and test separately;
- spans layers/services (e.g. migration + backend + API);
- you catch yourself writing "Phase 1 / Phase 2".

State the decision in one line: *"This is one spec"* or *"This decomposes into N specs — writing a Task Map."* Don't manufacture a split; most features are one spec.

## Step 2: Derive the Task Map (only when "many")

Write `docs/plan/<feature>-taskmap.md` per the **Task Map format** in `spec-format`. Each task:

- is **one independently testable unit** (a reviewer could accept it alone) — size to the seam, not a clock;
- carries a **path** (`task` — straight to the Builder, no spec · `feature` — spec + Gate B) per the routing rules in `docs/WORKFLOW.md`;
- lists the **`R#`** requirement IDs it satisfies (the traceability spine) when a requirements doc exists;
- names its **`Depends-on`** tasks and a **`[P]`** marker when it shares no files with, and doesn't depend on, its siblings (parallel-safe);
- names the **spec** it becomes (filled in as specs are written).

Order by dependency (models → services → endpoints; independent tasks in the same "wave" are `[P]`). Let the design draw the seams: Lens-1 service boundaries and Lens-4 cohesion from the brief tell you where tasks split.

The Task Map is the **durable ledger**. The human's driving session mirrors its rows into the native to-do board for live tracking (`docs/WORKFLOW.md` → *Track it on the native board*) — that board is the driver's, not yours; you own the map file.

## Step 3: Right-weight check (ungated below system scale)

Present the Task Map top-down and refine it inline with the user. **Do not gate it** for ordinary work — review, adjust, proceed. The design was already challenged at Gate A; the split is a derivative, not a new decision.

**System changes only:** offer a read-only coverage audit — a fresh-context subagent (the Gate-B dispatch pattern) checking that every `R#` is covered by ≥1 task, no task cites a dangling `R#`, `Depends-on` is acyclic, and the path assignments are sane. Record it in the map's `## Coverage Audit` section. This is the *only* place decomposition adds a gate, and only at system scale.

## Step 4: Specs, just-in-time

Write the **first** spec now; author the rest **per task as the user schedules them** — spec durable, context disposable, so you never write N specs that drift. Each spec records its `R#`s in its `**Requirements:**` line and links the shared brief. The Architect hands the Builder **one spec at a time**; the human picks the next task from the map.

---

## Boundaries

- Decomposition never runs before a design brief exists (spec-then-tasks, never tasks-first).
- The Task Map is the Architect's **ledger**, not an orchestrator — no auto-dispatch, no running the pipeline for the user. The human schedules the next task.
- One concept, not two: this *is* `spec-format`'s "split the spec" — don't invent a parallel mechanism.
