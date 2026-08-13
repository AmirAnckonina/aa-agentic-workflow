---
name: aa-requirements-composition
description: "Optional front stage — compose raw needs into a structured Requirements doc: user stories + EARS-format acceptance criteria with R# IDs, success metrics, explicit out-of-scope. Use for 'compose requirements', 'write requirements', 'turn this idea into requirements', '/aa-requirements'. Produces docs/requirements/<feature>.md (Draft → Approved). Standalone; feeds the Architect."
user-invocable: true
---

# Requirements Composition (optional front stage)

## Overview

Turn a raw need — a paragraph, a chat idea, a ticket — into a **structured, gated Requirements doc**: user stories plus **EARS-format acceptance criteria**, each carrying an `R#` ID that the rest of the pipeline traces to.

This is the front of the pipeline and it is **optional and standalone**: run it when you're starting from fuzzy needs and want them pinned down before any design. If you already know what the work is, skip it and go straight to `@architect`.

**Position (spec-driven / Model A):**
```
raw need → /aa-requirements → docs/requirements/<feature>.md [Approved]
                                      ↓
                    @architect  →  Brief (design) → decompose (if needed) → spec(s)
```

Requirements state **what/why**; the Architect owns the **how** (design, then — only if the feature is more than one spec — decomposition). Format is owned by `spec-format`; this skill owns the **method**.

---

## Keywords

requirements, PRD, user stories, EARS, acceptance criteria, needs, intake, product spec, requirement IDs, [NEEDS CLARIFICATION], compose requirements, requirements doc

---

## Step 0: Load Context

1. Read `docs/agentic-context.md` at the repo root if present; read every file it lists. Fallback: `CLAUDE.md` + a `docs/` scan — and say so.
2. **Begin your first output with a `Context loaded: <list>` line.**
3. Skim existing `docs/requirements/` — if a doc already covers this need, **update it in place** rather than duplicating.

## Step 1: Interview — surface intent

Use **`superpowers:brainstorming`** to explore intent, scope, and edge cases in chat first — it's the maintained tool for this (superpowers ships no dedicated requirements/PRD skill) and it keeps you from hallucinating scope. If a brainstorming design doc already exists (under `docs/superpowers/specs/`), read it and structure its content into the requirements doc instead of re-interviewing.

Drive toward: **who/what** (user stories), **success** (metrics), **boundaries** (out of scope), **unhappy paths** (failures, guardrails). Ask only a few high-value questions per round; anything genuinely unresolved becomes a `[NEEDS CLARIFICATION]` marker, not a guess.

## Step 2: Draft the Requirements doc

Write `docs/requirements/<feature>.md` following the **Requirements doc format** in `spec-format`:
- **User stories** in `As a <role>, I want <capability>, so that <benefit>` form.
- **Acceptance criteria in EARS syntax**, each with a stable `R#` ID (see `references/ears.md` for the six templates). EARS makes each criterion unambiguous and directly mappable to a test — the traceability spine.
- **WHAT/WHY only** — no tech stack, interfaces, or file names (that's the Architect's job downstream).
- **`[NEEDS CLARIFICATION] <question>`** wherever the need is ambiguous — these block approval.

Set `**Status:** Draft`.

## Step 3: Requirements gate (the DoD)

`Approved` only when both hold:
1. **No `[NEEDS CLARIFICATION]` markers remain.**
2. **The user explicitly approves.** Present top-down (stories → `R#` criteria → out-of-scope) and get the nod. Read-only gate — never self-approve.

On approval, set `**Status:** Approved`.

---

## Handoff

An `Approved` requirements doc is the input to **`@architect`**, which designs the feature and — only if it's more than one spec — decomposes it, each task/spec citing the `R#`s it satisfies. You can also stop here: a clean requirements doc is a valid standalone deliverable.

## When NOT to use this skill

- You already know the work → skip to `@architect` (features, system changes) or `@builder` (bounded tasks).
- A chore or bounded task with obvious acceptance criteria → no requirements doc needed.
- You want to challenge an *approach* → that's Gate A (`/aa-approach-review`), later and lower.
