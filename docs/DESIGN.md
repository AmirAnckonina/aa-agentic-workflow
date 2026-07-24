# Agentic Workflow v2 — Design

**Status:** Approved
**Owner:** Amir
**Date:** 2026-07-13
**Supersedes:** `custom-agentic-tools/capabilities/agentic-workflow/` (v1 stays live until migration completes)

---

## 1. TL;DR

One SDLC workflow covering intake → discovery → approach → spec → build → review → ship, where **we own only the governance layer** (artifacts, gates, status lifecycle, role wiring) and everything else is **delegated**: techniques to Superpowers, tactical verbs to Claude Code built-ins. A routing layer sizes the process to the task so small work never pays pipeline tax. A per-repo context contract makes every stage's context explicit and user-controlled. Packaged as a Claude Code plugin in this dedicated repo.

## 2. Goals & Non-Goals

**Goals**
- G1: Effective SDLC governance — spec-as-source-of-truth, enforced gates, clear role boundaries.
- G2: Minimal maintenance surface — never reimplement what Superpowers or built-ins maintain.
- G3: Proportional process — trivial fixes stay frictionless; big features get full rigor.
- G4: Explicit, user-controlled context — every stage states what it read; nothing implicit.
- G5: User controls the flow — gates present verdicts; the pipeline never auto-advances past a gate without the user.
- G6: Distributable — installable/updatable as a versioned plugin, not a pile of symlinks.

**Non-Goals (for v2.0)**
- PRD authoring stage (slot reserved, see §12).
- Multi-user / team features (single-user first; plugin packaging keeps the door open).
- CI/CD integration beyond what gh-ops/glab-ops already do on request.

## 3. Design Principles

1. **Own decisions, rent techniques.** Custom artifacts encode *our* rules (gates, lifecycle, roles). Generic know-how (TDD, debugging, brainstorming, quality review) is invoked from its upstream owner.
2. **Artifact + gate per stage.** Every stage produces a named artifact with a `Status:` field; the status is the single source of truth; downstream stages check it structurally, not by convention.
3. **Cheap before expensive.** Challenge the approach on a one-pager before anyone writes a full spec; audit details only after the approach survives.
4. **Explicit context.** Subagents don't inherit CLAUDE.md — every stage's Step 0 loads the declared context and reports it. This is a feature: it's the control point.
5. **Declared dependencies, no fallbacks.** Superpowers is a prerequisite. We do not carry duplicate prose "in case it's missing" — that duplication is exactly v1's maintenance debt.

## 4. The Pipeline

```
        ┌─ INTAKE & ROUTING (direct chat) — classify task → tier (§5)
        │
[future]│  PRD — what / why / success criteria          (slot reserved, §12)
        │
  T2+   ▼
  1. DISCOVERY          superpowers:brainstorming        → intent summary (chat, no artifact)
  2. APPROACH BRIEF     @architect (~1 page)             → docs/briefs/<topic>.md   [Draft]
        ── Gate A: /approach-review ──  challenge the HOW while rework is cheap
                       PASS → brief Status: Approach-Approved | RETHINK → back to 2
  3. FULL SPEC          @architect (elaborates brief)    → docs/specs/<topic>.md    [Draft]
        ── Gate B: /spec-review ──  5 parallel detail audits
                       Approved → spec Status: Approved  | Blocking → back to 3
  4. BUILD              @builder — refuses unless Status: Approved
                          • TDD loop        → superpowers:test-driven-development
                          • stuck/bug       → superpowers:systematic-debugging
                          • isolation       → superpowers:using-git-worktrees
                          • done-claim      → superpowers:verification-before-completion
  5. REVIEW             @reviewer
                          • Pass 1 (ours): spec-compliance — code vs Approved spec
                          • Pass 2 (delegated): /code-review — canonical quality pass
                          → terminal report; verdict SHIP IT / NEEDS WORK / BLOCKER
  6. SHIP (on request)  superpowers:finishing-a-development-branch
                          + gh-ops / glab-ops (per actual remote)
```

**Gate semantics (G5):** a gate ends with a verdict presented to the user. Advancing is a user action ("go") — given per-gate or once for a segment (*"run through Gate B"*): PASS flows onward under segment consent, any non-pass verdict always stops. Consent is explicit and scoped, never assumed, and never substitutes for `Status: Approved` at the Builder boundary.

## 5. Routing Tiers — proportional process

Intake classifies every task; the **user always has final say** on tier (the router suggests, the user decides). Default suggestions:

| Tier | Signal | Process |
|---|---|---|
| **T0 — trivial** | typo, config tweak, one-liner, no behavior change | Direct chat. No pipeline, no artifacts. Built-ins as needed. |
| **T1 — bounded task** | clear acceptance criteria, ≲3 files, no design questions | Skip Architect. @builder inline-task mode (Approved-gate exempt, as in v1) + TDD + `/code-review`. Artifact: none, or a 5-line task card in the chat. |
| **T2 — feature** | new behavior, design choices exist, single service | Full pipeline (§4), **fast-track default**: inline chat brief (Gate A waived + recorded; promoted to full brief + Gate A if a real design question surfaces) · Gate B **lite** (one fresh-context auditor, all applicable checklists; escalates to panel on blocking Security/Scalability findings or above-tier risk). Spec may use `N/A — [reason]` escape hatches. |
| **T3 — system** | cross-service, data migrations, new infra, irreversible | Full pipeline + full 5-lens depth + research protocol in the Approach Brief; approach-review mandatory (cannot be skipped). |

Escalation rule: if a T1 task surfaces a design question mid-build, the Builder stops and recommends promotion to T2 — it does not design ad hoc.

## 6. Ownership Matrix

| Concern | Owner | Artifact / mechanism |
|---|---|---|
| Spec format & lifecycle | **ours** | `spec-format` skill (extended with Approach Brief + statuses) |
| Approach challenge (Gate A) | **ours** | `approach-review` skill (renamed + repositioned cto-review) |
| Detail audits (Gate B) | **ours** | `spec-review` skill (unchanged in role) |
| Role agents & wiring | **ours** | `agents/architect.md`, `agents/builder.md`, `agents/reviewer.md` |
| Approved-gate enforcement | **ours** | Builder Step-0 refusal; Architect write-guard hook |
| Spec-compliance review | **ours** | Reviewer Pass 1 |
| Architecture reasoning lenses | **ours** (curated) | `architect-methodology` skill |
| Ideation / intent discovery | **Superpowers** | `brainstorming` |
| TDD discipline | **Superpowers** | `test-driven-development` |
| Debugging discipline | **Superpowers** | `systematic-debugging` |
| Done-claim verification | **Superpowers** | `verification-before-completion` |
| Branch finishing / worktrees | **Superpowers** | `finishing-a-development-branch`, `using-git-worktrees` |
| Generic quality review | **built-in** | `/code-review` (canonical; replaces Reviewer's 6 lenses) |
| Security scan | **built-in** | `/security-review` (Reviewer may invoke in Pass 2 when the diff touches auth/input/secrets) |
| One-task planning | **built-in** | plan mode (T0/T1 only; T2+ planning lives in briefs/specs) |
| Git-host operations | **ours (thin)** | `gh-ops` / `glab-ops` (remote-verified, on request) |

**Dropped from v1:** `review-lenses` skill and the Reviewer's 6-lens dispatch machinery (superseded by `/code-review`), `build-report` (folded into Builder prompt or dropped — decide at porting).

**Complementary tools (outside the pipeline):** aa-code-review is deliberately NOT part of this workflow — the pipeline optimizes for shipping tasks fast with front-loaded gates. aa-code-review's place is heavyweight independent sweeps: big features (run manually, on request) or a CI quality gate. It shares nothing with the pipeline and neither depends on the other.

## 7. Context Contract

**Per-repo manifest:** `docs/agentic-context.md` in each target repo (optional):

```markdown
# Agentic Context
- Architecture: docs/ARCHITECTURE.md
- Conventions: CLAUDE.md
- Domain: docs/domain/<area>.md
- Review rules: docs/review-rules.md         # optional — injected into Reviewer Pass 2 (§9)
- Related repos: ../shared-protos (read-only), ../platform-api (read-only)
```

**Step-0 rule (all pipeline stages — Architect, audit subagents, Builder, Reviewer):**
1. Read `docs/agentic-context.md` if present; read every listed file/path (related repos read-only).
2. Fallback when absent: repo CLAUDE.md + `docs/` scan, and say so.
3. Output must begin with a `Context loaded: <list>` line — the user's verification that the stage worked from the right context.

Built-in skills and Superpowers skills invoked *from* a stage inherit that stage's conversation, so they operate on the same loaded context — no extra wiring needed.

## 8. Artifact Lifecycle

```
Approach Brief:  Draft → Approach Review → Approach-Approved | Rethink→Draft
Full Spec:       Draft → Detail Audit    → Approved          | Blocking→Draft
```

- Briefs live in the target repo's `docs/briefs/`, specs in `docs/specs/` (v1 used flat `docs/` — subdirs keep multi-feature repos navigable).
- The spec's front-matter links its brief; Gate B checks the brief is `Approach-Approved` (or that Gate A was explicitly skipped by the user — recorded in the spec, T3 excepted).
- Builder starts only on `Status: Approved` (unchanged v1 invariant, T1 inline tasks exempt).

## 9. Reviewer v2 (the split)

- **Pass 1 — spec compliance (ours, the moat):** mechanical check of code vs Approved spec: every AC covered by a test, interfaces match, no unspecified behavior added, no spec section silently unimplemented. Output: per-AC table.
- **Pass 2 — quality (delegated):** invoke `/code-review` at an effort level suggested by tier (T2: medium, T3: high; `ultra` reserved for release-critical, on explicit request); add `/security-review` when the diff touches auth, input handling, or secrets.
  - **Per-repo review rules (optional input):** if the target repo's context manifest (§7) declares a review-rules file (past incidents, conventions, tribal knowledge), the Reviewer injects those rules into the Pass 2 prompt.
- **Verdict (ours):** SHIP IT / NEEDS WORK / BLOCKER synthesized from both passes. Terminal report is the deliverable; git actions on explicit request only (v1 decision, retained).

This deletes the 6-lens dispatch, the lens-injection contract, and `review-lenses` — v1's largest maintenance surface.

## 10. Packaging & Repo Layout

```
agentic-workflow/
├── .claude-plugin/plugin.json     # plugin manifest (schema TBV against live docs — see Open Questions)
├── agents/        architect.md, builder.md, reviewer.md
├── skills/        spec-format/, approach-review/, spec-review/, architect-methodology/
├── commands/      review-internal.md (or fold into @reviewer — decide at porting)
├── hooks/         architect write-guard
├── docs/          DESIGN.md (this file), WORKFLOW.md (user guide), MIGRATION.md
└── README.md
```

- **Dev loop:** this repo is the source of truth; iterate with `claude --plugin-dir <repo>` (live, no install) or a local-marketplace install refreshed via `claude plugin update` on a version bump.
- **Distribution:** Claude Code plugin via marketplace — versioned, updatable, enable/disable, shareable. `custom-agentic-tools` keeps the unrelated capabilities (atlassian, slack-comms, service-ops…) and retires its agentic-workflow bundle after migration.

## 11. Dependencies

- **Superpowers plugin** — required. README states it; agents may check for a required skill at Step 0 and stop with an actionable message if absent. No duplicated fallback content (Principle 5).
- **Claude Code ≥ current** — nested subagents (Reviewer), agent `skills:` preloading, hooks.
- `jq` — Architect write-guard + Builder spec-gate / git-guard hooks (fail open if absent, as in v1).

## 12. Future Slots

- ~~**PRD stage**~~ — **implemented in v0.5.0** (§15): the optional `requirements-composition` front stage (`/requirements`, EARS + `R#`) supplies the product what/why; the Architect owns design and — spec-then-tasks — decomposition.
- **Brainstorm-as-artifact** — partly addressed: `/requirements` rents `superpowers:brainstorming` and can structure an existing brainstorming design doc into the Requirements doc. A standalone persisted intent-summary artifact remains unreserved.

## 13. Migration Plan

1. **M0 (this doc):** design approved → `Status: Approved` here.
2. **M1 — port governance:** copy the keep-column artifacts from v1; apply the delegation edits (Builder → superpowers TDD; Reviewer split; cto-review → approach-review + reposition; context contract into every Step 0).
   - **spec-review port notes** (reviewed 2026-07-13 — structure, iteration protocol, and feedback quality are sound; role unchanged): (a) skip perspectives whose target spec sections are `N/A — [reason]`, announcing the skip — no more auditing sections that don't exist; (b) rewire references: `/cto-review` → `/approach-review`, verify the linked brief is `Approach-Approved`, and have auditors read the brief so already-challenged concerns aren't re-raised as suggestions; (c) add the §7 Step-0 context read + `Context loaded:` line; (d) keep the 5 perspective checklists as-is — curated knowledge, no delegation target exists for spec auditing.
   - **Efficiency trims (2026-07-14, post-M1 heaviness review — quality preserved, ceremony scaled):** (1) T2 fast track is the default — inline chat brief with recorded waiver, promotion rule to full brief + Gate A on any real design question; (2) Gate B lite/panel modes — one fresh-context auditor for T2, 5-panel for T3, lite→panel escalation guardrail; (3) segment consent — batched "go" across pass verdicts, any non-pass stops. Ordinary T2 now costs 2-3 round-trips and 1 audit subagent instead of 6-7 and 5.
3. **M2 — package:** ✅ **done 2026-07-14.** Schema verified against live docs (open question #1 closed): `.claude-plugin/plugin.json` (name-only required; default component dirs match our layout) + `.claude-plugin/marketplace.json` (same repo is its own marketplace, source `"./"`). `superpowers` declared via the manifest `dependencies` field. Version pinned (`0.2.0`) so updates ship on version bumps, not every commit. `claude plugin validate . --strict` passes. Dev-phase install (final decision, 2026-07-14): **skills-dir plugin** — the repo symlinked at `~/.claude/skills/agentic-workflow` loads in place as `agentic-workflow@skills-dir`; live edits, no marketplace, no version-bump-per-change. Fully self-contained and decoupled: NOT listed in aa-tools (aa-code-review is a separate project) and NO manifest `dependencies` (Superpowers is a documented prerequisite checked at agent Step 0 — the cross-marketplace dependency machinery was tried and deliberately removed as over-coupling). Distribution later = a marketplace entry pointing at this repo (HTTPS `url` source; the `github` source type requires SSH host keys). Note: plugin components are namespaced (`agentic-workflow:spec-review`); symlink dev-loop and plugin install are mutually exclusive.
   - **Superseded 2026-07-24:** the skills-dir symlink was found *not* to register agents or commands (a whole-repo symlink exposes only nested skills, double-nested and undiscovered), so it never actually activated the pipeline. Corrected to a real plugin install — `.claude-plugin/marketplace.json` (marketplace `aa`, source `"."`) + `claude plugin install aa-agentic-workflow@aa`; `claude --plugin-dir <repo>` for the live dev loop. Shipped in **v0.6.0** alongside the structural Builder hook gates (spec-gate + git-guard) and the two-default routing. Also reversed from M1/M2: `superpowers` is now declared in `plugin.json` `dependencies` (resolved from the official marketplace), so install pulls it automatically — the Step-0 skill check remains as a safety net.
4. **M3 — smoke test:** ✅ **passed 2026-07-14** (20/20 checks; run before M2 by choice). T1 headless Builder + T2 staged pipeline (architect → Gate B lite → builder → /review-internal) in a Go sandbox. Verified: context contract (`Context loaded:` at every stage), fast-track inline brief + waiver, Gate B lite mode + N/A perspective skip, Approved-gate authorization, both Superpowers delegations, Reviewer→/code-review **direct** invocation from a subagent (fallback not needed), SHIP IT report. Fix applied from findings: commit-before-review documented + Reviewer empty-diff working-tree fallback.
5. **M4 — retire v1:** remove the agentic-workflow bundle from `custom-agentic-tools`, leave a pointer README.

## 14. Open Questions

1. **Plugin manifest schema** — verify current plugin.json format + local-install workflow against live Claude Code docs at M2 (do not trust memory).
2. ~~`/code-review` invocability from the Reviewer agent~~ — **Resolved at M1 (structurally):** the Reviewer attempts it via the Skill tool; on failure it reports **PASS 1 ONLY** and the `/review-internal` command wrapper runs `/code-review` from the main session and combines verdicts. Verify which path fires at M3 smoke test.
3. ~~Approach Brief format~~ — **Resolved at M1:** adopted as proposed into `spec-format` (+ `Tier:` line; Options Considered requires ≥1 real alternative).
4. ~~`build-report` skill~~ — **Resolved at M1: folded into the Builder's output protocol** as a compact Build Report whose AC → Test Map feeds Reviewer Pass 1.4 (trust-but-verify). Standalone skill dropped.
5. **`coding-standards`** — carried into this repo verbatim (agents preload it; a self-contained plugin must carry what it preloads). Future edits happen here, not in `custom-agentic-tools`.

## 15. v0.5.0 — Spec-Driven Front Stage + In-Architect Decomposition (Model A)

**Problem.** The pipeline governed single-task SDLC well but had no altitude above one spec: no way to compose raw needs into structured requirements, and no explicit path for a feature bigger than one spec. In practice this made "am I handing the Architect one task or many?" ambiguous.

**Research grounding.** Three passes over Spec Kit, Kiro, OpenSpec, Taskmaster, BMAD, and Anthropic guidance found unanimous convergence on **spec-then-tasks**: a *feature-level* design comes first, and tasks are **derived from it afterward** by a **cheap step run by the same agent** (a separate role/gate only earns its keep at team scale). One spec = many tasks; a task ≈ one independently testable unit. For solo/fast work the consensus is **keep the artifact, drop the gate** (gate only system-level work). An earlier draft (v0.4.0, unmerged) built the inverse — a gated `/decompose` front stage producing one-spec-per-task ("Model B") — the one model no tool uses; it was rejected.

**Decisions (consistent with Principles §3):**
1. **Optional requirements front stage.** `requirements-composition` (`/requirements`): raw need → gated EARS doc with `R#` IDs. Rents `superpowers:brainstorming` for the interview (superpowers ships no PRD skill). À la carte — the fast single-task path pays nothing.
2. **Decomposition lives inside the Architect, downstream of the brief.** It is the existing `spec-format` "split the spec" decision made explicit and given a ledger (the Task Map). Method in the preloaded `decomposition` skill; the agent gains one short beat (step 3.5) — the Architect's surface stays two modes + a reasoning toolkit, not a new mode or a 6th lens.
3. **Ungated for T1/T2; T3 coverage audit optional.** The approach was already challenged at Gate A; the split is a derivative. Avoids the "waterfall in markdown" failure mode the research flags.
4. **Specs written just-in-time** (spec durable, context disposable); the Architect hands the Builder one spec at a time.
5. **Traceability spine** — `R#` → Task Map `Requirements` column → spec `**Requirements:**` line → Builder AC→Test map → Reviewer Pass-1 check 1.7 (IMPORTANT, never blocking).
6. **No orchestrator (retained).** The Task Map + the existing per-task flow are the whole loop; the human schedules.
7. **Cost scaled to risk (pacing).** Mechanical stages run on **Sonnet** (Reviewer — Pass 1 is objective + Pass 2 delegates to `/code-review`; `/requirements` — EARS is a constrained format); design-critical stages stay **Opus** (Architect, Gate A, and **Gate B at both tiers** — it is the quality moat, so it keeps full reasoning depth). Gate B lite is made cheaper by **breadth, not depth** — **focused** to the 2–3 perspectives the spec's surface triggers (Completeness + Scope always), one auditor vs the panel's five, with the lite→panel escalation guardrail intact. Independent (`[P]`) specs build in parallel worktrees. Depth-critical work stays heavy; the savings come from not spending Opus on mechanical work, focusing (not weakening) the audit, not over-tiering, and not serializing independent specs.
