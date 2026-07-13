# Agentic Workflow — User Guide

The SDLC pipeline: intake → discovery → approach → spec → build → review → ship.
Design rationale lives in [DESIGN.md](DESIGN.md); this is the operating manual.

## The One Principle

**Own decisions, rent techniques.** This workflow owns *governance* — artifacts, gates, the status lifecycle, role boundaries. Everything generic is delegated: TDD/debugging/verification discipline to the [Superpowers](https://github.com/obra/superpowers) plugin (required dependency), generic quality review to the built-in `/code-review`.

## Routing: pick the tier first

Every task starts with a 10-second classification. You always have the final say.

| Tier | Signal | Process |
|---|---|---|
| **T0 — trivial** | typo, config tweak, no behavior change | Direct chat. No pipeline. |
| **T1 — bounded** | clear ACs, ≲3 files, no design questions | `@builder` directly (T1 mode) + TDD + `/code-review`. No spec. |
| **T2 — feature** | new behavior, design choices, single service | Full pipeline, **fast track default**: inline chat brief (Gate A waived + recorded) · Gate B **lite** (1 auditor) · `/code-review` medium. |
| **T3 — system** | cross-service, migrations, new infra, irreversible | Full pipeline, full rigor: brief artifact + Gate A **mandatory** · Gate B **panel** (5 auditors) · `/code-review` high. |

**Escalation:** if a T1 task surfaces a design question mid-build, the Builder stops and recommends promotion to T2. If an ordinary T2 surfaces one mid-spec, the Architect promotes to the full brief + Gate A. Nothing designs ad hoc.

## The Pipeline (T2/T3)

```
1. DISCOVERY        superpowers:brainstorming (chat — no artifact)
2. APPROACH BRIEF   ordinary T2: inline in chat (your nod = approval, waiver recorded)
                    T3 / open-design T2: @architect → docs/briefs/<topic>.md   [Draft]
      ⛩ Gate A: /approach-review — challenge the HOW on one page (artifact briefs only)
                    PASS → Approach-Approved · RETHINK → revise brief
3. FULL SPEC        @architect → docs/specs/<topic>.md           [Draft, links brief/waiver]
      ⛩ Gate B: /spec-review — detail audits: lite = 1 auditor (T2) · panel = 5 (T3)
                    N/A sections skip their perspective · Approved · Blocking → revise spec
4. BUILD            @builder — starts ONLY on Status: Approved
                    TDD / debugging / verification via Superpowers skills
5. REVIEW           @reviewer (or /review-internal)
                    Pass 1: spec compliance (per-AC table) — ours
                    Pass 2: /code-review (effort by tier) + /security-review when warranted
                    → SHIP IT | NEEDS WORK | BLOCKER — terminal report is the deliverable
6. SHIP (on request) superpowers:finishing-a-development-branch + gh-ops/glab-ops
```

**Gate semantics:** every gate ends with a verdict presented to you. Nothing assumes your consent — "go" is your word, given per-gate **or once for a segment** (*"run it through Gate B"* / *"through the build"*): PASS verdicts then flow onward, but any RETHINK/Blocking stops the segment cold. A non-pass sends the artifact back to `Draft`; the cycle re-enters at that gate, with prior rounds preserved. Segment consent never bypasses a gate — it only pre-answers "go" on PASS.

**Status is law.** The `Status:` field in the brief/spec is the single source of truth. The Builder refuses any spec that isn't `Approved` — structurally, not by convention.

## Context Contract

Each target repo may declare `docs/agentic-context.md`:

```markdown
# Agentic Context
- Architecture: docs/ARCHITECTURE.md
- Conventions: CLAUDE.md
- Domain: docs/domain/<area>.md
- Review rules: docs/review-rules.md         # optional — injected into Reviewer Pass 2
- Related repos: ../shared-protos (read-only)
```

Every pipeline stage reads the manifest at Step 0 and begins its output with `Context loaded: <list>` — your verification that it worked from the right context. No manifest → fallback to `CLAUDE.md` + `docs/`, stated explicitly.

## Complementary tools (outside the pipeline)

- **aa-code-review** — heavyweight independent sweeps: big features (manual, on request) or a CI quality gate. Zero coupling with this pipeline.
- **`/code-review ultra`** — release-critical deep review; user-triggered only.

## Quick reference

| I want to… | Do |
|---|---|
| Design a feature | `@architect` (or `claude --agent architect`) |
| Challenge an approach | `/approach-review` on the brief |
| Audit a spec | `/spec-review` on the spec |
| Implement an Approved spec | `@builder` |
| Small bounded task, no spec | `@builder` with the task + ACs inline |
| Review the branch | `/review-internal [focus]` |
| Advisory design question | just ask — `architect-methodology` handles it in chat |
