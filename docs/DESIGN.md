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

- **Dev loop:** this repo is the source of truth; local install for iteration (symlink or `plugin install --local` — whichever the plugin tooling supports; verify at build time).
- **Distribution:** Claude Code plugin via marketplace — versioned, updatable, enable/disable, shareable. `custom-agentic-tools` keeps the unrelated capabilities (atlassian, slack-comms, service-ops…) and retires its agentic-workflow bundle after migration.

## 11. Dependencies

- **Superpowers plugin** — required. README states it; agents may check for a required skill at Step 0 and stop with an actionable message if absent. No duplicated fallback content (Principle 5).
- **Claude Code ≥ current** — nested subagents (Reviewer), agent `skills:` preloading, hooks.
- `jq` — write-guard hook (fails open if absent, as in v1).

## 12. Future Slots (reserved, not designed)

- **PRD stage** — product altitude (what/why/success metrics), above Discovery; its approval will absorb the "is this the right thing?" question, further narrowing approach-review to purely technical challenge.
- **Brainstorm-as-artifact** — if intent summaries prove worth persisting, Discovery gains an artifact + optional gate; today it stays a chat-level step.

## 13. Migration Plan

1. **M0 (this doc):** design approved → `Status: Approved` here.
2. **M1 — port governance:** copy the keep-column artifacts from v1; apply the delegation edits (Builder → superpowers TDD; Reviewer split; cto-review → approach-review + reposition; context contract into every Step 0).
   - **spec-review port notes** (reviewed 2026-07-13 — structure, iteration protocol, and feedback quality are sound; role unchanged): (a) skip perspectives whose target spec sections are `N/A — [reason]`, announcing the skip — no more auditing sections that don't exist; (b) rewire references: `/cto-review` → `/approach-review`, verify the linked brief is `Approach-Approved`, and have auditors read the brief so already-challenged concerns aren't re-raised as suggestions; (c) add the §7 Step-0 context read + `Context loaded:` line; (d) keep the 5 perspective checklists as-is — curated knowledge, no delegation target exists for spec auditing.
   - **Efficiency trims (2026-07-14, post-M1 heaviness review — quality preserved, ceremony scaled):** (1) T2 fast track is the default — inline chat brief with recorded waiver, promotion rule to full brief + Gate A on any real design question; (2) Gate B lite/panel modes — one fresh-context auditor for T2, 5-panel for T3, lite→panel escalation guardrail; (3) segment consent — batched "go" across pass verdicts, any non-pass stops. Ordinary T2 now costs 2-3 round-trips and 1 audit subagent instead of 6-7 and 5.
3. **M2 — package:** plugin manifest, local install side-by-side with v1 (rename-collision check: v1 bundle uninstalled first or agents renamed during overlap).
4. **M3 — smoke test:** ✅ **passed 2026-07-14** (20/20 checks; run before M2 by choice). T1 headless Builder + T2 staged pipeline (architect → Gate B lite → builder → /review-internal) in a Go sandbox. Verified: context contract (`Context loaded:` at every stage), fast-track inline brief + waiver, Gate B lite mode + N/A perspective skip, Approved-gate authorization, both Superpowers delegations, Reviewer→/code-review **direct** invocation from a subagent (fallback not needed), SHIP IT report. Fix applied from findings: commit-before-review documented + Reviewer empty-diff working-tree fallback.
5. **M4 — retire v1:** remove the agentic-workflow bundle from `custom-agentic-tools`, leave a pointer README.

## 14. Open Questions

1. **Plugin manifest schema** — verify current plugin.json format + local-install workflow against live Claude Code docs at M2 (do not trust memory).
2. ~~`/code-review` invocability from the Reviewer agent~~ — **Resolved at M1 (structurally):** the Reviewer attempts it via the Skill tool; on failure it reports **PASS 1 ONLY** and the `/review-internal` command wrapper runs `/code-review` from the main session and combines verdicts. Verify which path fires at M3 smoke test.
3. ~~Approach Brief format~~ — **Resolved at M1:** adopted as proposed into `spec-format` (+ `Tier:` line; Options Considered requires ≥1 real alternative).
4. ~~`build-report` skill~~ — **Resolved at M1: folded into the Builder's output protocol** as a compact Build Report whose AC → Test Map feeds Reviewer Pass 1.4 (trust-but-verify). Standalone skill dropped.
5. **`coding-standards`** — carried into this repo verbatim (agents preload it; a self-contained plugin must carry what it preloads). Future edits happen here, not in `custom-agentic-tools`.
