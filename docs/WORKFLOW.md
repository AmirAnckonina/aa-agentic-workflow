# Agentic Workflow — User Guide

The SDLC pipeline: (requirements →) intake → discovery → approach → **decompose** → spec → build → review → ship.
Spec-driven: the design comes first; a feature is split into task-specs only *after* the brief, and only when it's more than one spec. Requirements are an optional front stage.
Design rationale lives in [DESIGN.md](DESIGN.md); worked paths in [EXAMPLES.md](EXAMPLES.md); this is the operating manual.

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

## Front stage & decomposition — the spec-driven shape

**Optional front stage.** Starting from fuzzy needs? Run `/requirements` first → a gated EARS requirements doc (`docs/requirements/<f>.md`, `R#` IDs). Already know the work? Skip it, go to `@architect`.

**Decomposition lives inside the Architect (spec-then-tasks).** You do *not* split work up front. Hand a feature to `@architect`; it designs the brief, then decides **one spec or many**. Most features are one spec. A larger one becomes a **Task Map** (`docs/plan/<f>-taskmap.md`) — the Architect's ledger of split specs — produced *after* the design, **ungated for T1/T2** (a T3 coverage audit is optional).

**The decision rule — "Can one spec hold it?"** A spec = one cohesive capability (~5–12 ACs, ≤5 interfaces, ≤3 components). Fits → one spec. Doesn't → the Architect decomposes. Unsure → hand it up anyway; the Architect tells you. **Don't pre-split out of caution.** Worked examples: [EXAMPLES.md](EXAMPLES.md).

**Driving a multi-spec feature (human-in-the-loop, no orchestrator).** With a Task Map, *you* schedule: pick the next `pending` task whose `Depends-on` are `complete` → the Architect writes that task's spec → Gate B → build → review → update the row. **The map coordinates; you schedule** — there is no auto-runner.

**Parallelize `[P]` tasks.** Tasks marked `[P]` share no files and have no dependency between them — build them **concurrently in separate git worktrees** (`superpowers:using-git-worktrees` + `superpowers:dispatching-parallel-agents`), then review each on its own. On a feature with 2–3 independent specs this roughly **halves** wall-clock; each still passes its own Gate B + review, so quality holds.

## Keeping it paced (speed without losing rigor)

The pipeline scales cost to risk — spend the rigor where it's warranted, not everywhere.

**Gate B — when to run, when not:**

| The spec is… | Gate B |
|---|---|
| Trivial/mechanical (no new logic, no external input, no contract change) | **Skip** — mark Approved directly (recorded). Rare — usually T0/T1 anyway. |
| Ordinary T2 (the default) | **Lite** — one **Opus** auditor, **focused** to the 2–3 perspectives that matter (Completeness + Scope always; Security / Scalability / API Design only if the surface triggers them) |
| T3, or a T2 touching **auth, migration, external API, or an irreversible change** | **Panel** — 5 Opus auditors. A lite auditor auto-escalates here if it smells real risk. |

**Don't over-tier or over-split.** Most everyday work is one T2-fast spec. Running T3 rigor on T2 work, or decomposing what one spec could hold, is the biggest self-inflicted cost. Keep the *"can one spec hold it?"* rule.

**Model tiering (built in).** Mechanical stages run on **Sonnet** — Reviewer, `/requirements`; design-critical stages stay **Opus** — Architect, Gate A, and **Gate B at both tiers** (it's the quality moat, so lite keeps full Opus depth — it's cheaper only by *breadth*, not model strength). Toggle **`/fast`** (a Claude Code session feature — faster Opus output, same model) for design-heavy sessions.

## The Pipeline (T2/T3)

```
1. DISCOVERY        superpowers:brainstorming (chat — no artifact)
2. APPROACH BRIEF   ordinary T2: inline in chat (your nod = approval, waiver recorded)
                    T3 / open-design T2: @architect → docs/briefs/<topic>.md   [Draft]
      ⛩ Gate A: /approach-review — challenge the HOW on one page (artifact briefs only)
                    PASS → Approach-Approved · RETHINK → revise brief
2.5 DECOMPOSE       @architect: one spec or many? multi-spec → docs/plan/<topic>-taskmap.md
                    (ungated T1/T2 · T3 coverage audit optional · specs written just-in-time)
3. FULL SPEC        @architect → docs/specs/<topic>.md           [Draft, links brief + R# reqs]
      ⛩ Gate B: /spec-review — detail audits: lite = 1 auditor (T2) · panel = 5 (T3)
                    N/A sections skip their perspective · Approved · Blocking → revise spec
4. BUILD            @builder — starts ONLY on Status: Approved
                    TDD / debugging / verification via Superpowers skills
5. REVIEW           first: commit the Builder's work to a feature branch — you, or ask
                    (the Builder never commits; the Reviewer diffs the branch)
                    then: @reviewer (or /review-internal)
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

## Run Modes — three ways to drive any agent stage

| Mode | How | Interactivity | Best for |
|---|---|---|---|
| **Main-session agent** | `claude --agent architect` (new terminal session) | Full — gates await your replies in-place | Design sessions; T2/T3 end-to-end |
| **Subagent** | `@architect …` / `@builder …` inside any session | One-shot — the agent ends its turn at a gate with the question as its result; your next message continues it | Running a stage inside a bigger conversation |
| **Headless** | `claude --agent builder -p "…"` (scripted/CI) | None — stops at gates, prints the pending question | Automation; bounded builds; smoke tests |

Notes that apply to all modes:
- **Subagents don't inherit CLAUDE.md.** Every stage's Step 0 reads the context manifest instead — check the `Context loaded:` line at the top of its output; if it's missing or wrong, stop and fix the manifest.
- **Gate skills run in the main session**, not as agents: `/approach-review`, `/spec-review`, `/review-internal` are slash commands wherever you are.
- Headless runs need scoped permissions, e.g. `--permission-mode acceptEdits --allowedTools "Bash(go:*)" "Skill" "Read" "Glob" "Grep"`.

## End-to-End Walkthroughs

### T0 — trivial
Just ask in direct chat. No pipeline, no artifacts.

### T1 — bounded task
```
@builder Add function X to package Y.
Acceptance criteria:
- …
- …
```
The Builder runs TDD (Superpowers), verifies, and prints a Build Report with an AC→Test map. No spec, no gates. Optional quality check afterwards: `/code-review`.
*If the Builder reports a design question surfaced — accept the promotion to T2; don't push it to improvise.*

### T2 — feature (the default path)
```text
1. claude --agent architect            # or @architect <task> from any session
     → confirms scope + tier + track (fast expected)
     → presents the inline brief in chat — your nod approves it
     → writes docs/specs/<topic>.md [Draft], stops at the Gate B question
2. /spec-review docs/specs/<topic>.md  # Gate B — lite mode (1 auditor)
     → verdict; on Approved the spec status flips
3. @builder Implement docs/specs/<topic>.md
     → starts only on Status: Approved; TDD; Build Report
4. Commit the work to a feature branch (you, or ask — the Builder never commits)
5. /review-internal [focus notes]
     → Pass 1 spec-compliance table + Pass 2 delegated /code-review → verdict
6. On SHIP IT, if you want: "commit / push / open PR" → gh-ops or glab-ops runs
```
**Fewer stops:** tell the Architect *"run it through Gate B"* (segment consent) — PASS verdicts flow without re-asking; any RETHINK/Blocking still halts.

### T3 — system-level
Same skeleton, full rigor — differences only:
```text
1a. Architect runs Discovery (questions) + Research, then writes a full brief
    file to docs/briefs/<topic>.md [Draft]
1b. /approach-review docs/briefs/<topic>.md   # Gate A — MANDATORY, not waivable
     → PASS (brief: Approach-Approved) or RETHINK (revise brief, re-run)
2.  Gate B runs in panel mode — 5 independent auditors
5.  Reviewer Pass 2 runs /code-review at high effort
```

### Gate phrase cheat-sheet
| Say | Effect |
|---|---|
| *"go"* / *"proceed"* | advance past the gate that just passed |
| *"run it through Gate B"* / *"…through the build"* | segment consent — PASS flows, non-pass stops |
| *"panel mode"* | force the 5-auditor Gate B on a T2 |
| *"skip Gate B"* | trivial changes only — recorded as ⏭️ Skipped in the spec |
| *"expand CRT-1"* / *"show AC coverage"* | drill into review findings |

### When something looks off
- No `Context loaded:` line → the stage skipped Step 0; rerun, and check `docs/agentic-context.md` exists and lists the right files.
- Builder refuses to start → check the spec's `**Status:**` — only `Approved` authorizes it. Run the missing gate.
- Reviewer says diff is empty → the work isn't committed; commit to a feature branch (or it will fall back to reviewing the working tree and say so).

## Complementary tools (outside the pipeline)

- **aa-code-review** — heavyweight independent sweeps: big features (manual, on request) or a CI quality gate. Zero coupling with this pipeline.
- **`/code-review ultra`** — release-critical deep review; user-triggered only.

## Quick reference

| I want to… | Do |
|---|---|
| Turn a raw need into structured requirements | `/requirements` |
| Design a feature (Architect splits it into task-specs if needed) | `@architect` (or `claude --agent architect`) |
| Challenge an approach | `/approach-review` on the brief |
| Audit a spec | `/spec-review` on the spec |
| Implement an Approved spec | `@builder` |
| Small bounded task, no spec | `@builder` with the task + ACs inline |
| Review the branch | `/review-internal [focus]` |
| Advisory design question | just ask — `architect-methodology` handles it in chat |
