---
name: spec-review
description: >
  Use when a spec needs its detail audits before the Builder starts — "spec review",
  "detail audit", "audit the spec", "run detail audits". Gate B of the pipeline:
  up to 5 independent perspectives (Security, Scalability, API Design, Completeness,
  Scope). Runs after /approach-review passes or is skipped.
user-invocable: true
---

# Spec Review (Gate B — Detail Audits)

## Overview

This skill runs **independent detail audits** against an architecture spec. Each perspective
examines the spec for specific concerns — security gaps, scalability risks, API inconsistencies,
completeness gaps, and scope issues.

**Position in the pipeline:**
```
Architect (Brief) → /approach-review (Gate A) → Architect (Spec, Draft) → /spec-review (Gate B) → Builder
                                                        ↑                        ↓
                                                        └──── ❌ Blocking ───────┘
```

This skill runs AFTER the approach review has passed (or been explicitly skipped). It checks the
**details** the approach review deliberately does not cover.

---

## Keywords

spec review, detail audit, review spec, audit spec, check spec, security review,
scalability review, API review, completeness check, scope review, spec approval, before builder

---

## Step 1: Orient

Before reviewing, gather context:

1. Read `docs/agentic-context.md` in the target repo if present; read every file it lists (related repos read-only). Fallback: repo `CLAUDE.md` + a `docs/` scan — and say so. **Begin your output with a `Context loaded: <list>` line.**
2. Read the spec file in full — do not skim
3. **Check the spec's `**Brief:**` line:**
   - Links a brief → read the brief in full and verify its Status is `Approach-Approved`. If it isn't, STOP: Gate A is not done — point the user to `/approach-review`.
   - `_Inline — Gate A waived: [reason]_` (or legacy `_None — Gate A skipped: [reason]_`) → proceed; the waiver is recorded. (A system-change spec without an Approach-Approved brief is itself a **blocking finding** — Gate A is mandatory for system changes.)
4. Check `**Status:**` — should be `Draft` or `Detail Audit`. Then set it to `Detail Audit` — the status field must reflect where the pipeline actually is while you work.
5. If Status is `Approved`, ask before re-reviewing
6. Read the brief's `## Approach Review` section — understand what strategic concerns were already raised and answered
7. Read referenced files in spec (interfaces, existing code patterns):
   - Use Read + Grep to locate relevant existing implementations
   - Understand the codebase conventions this spec must conform to
8. Note the requirements source — what was the user actually asking for?

**Do NOT:**
- Assume you know what the Architect intended
- Carry over any reasoning from the Architect's or approach-review session
- Skip sections because they look fine at a glance
- Re-litigate Gate A concerns (approach, strategic fit) — that gate is done; do not re-raise its settled findings as suggestions

---

## Step 2: Select Mode & Perspectives

### Mode selection (proportionality — announce your choice)

| Mode | When | Shape |
|---|---|---|
| **Skip** | trivial/mechanical spec — no new logic branches, no external input, no contract change (record the reason) | mark all Review Notes `⏭️ Skipped`, Status → Approved directly |
| **Lite** | feature (default) | **One Opus** subagent runs the **focused** perspective set (below) in a single pass |
| **Panel** | system change (always) · a feature touching **auth/security, data migration, external API contract, or an irreversible/high-blast-radius change** · or on escalation | 5 independent parallel **Opus** subagents |

Both modes dispatch **fresh-context subagents** — the auditor never inherits the Architect's (or your) reasoning; clean eyes are non-negotiable in either mode. The user can always demand panel.

**Lite → panel escalation (quality guardrail):** if the lite auditor returns a blocking issue in Security or Scalability, or judges the spec riskier than its path suggests (new external dependency, data migration, auth surface, irreversible step), recommend running the **panel** for the re-review round.

### Perspective selection (both modes)

Map each perspective to its target spec sections. If a perspective's target sections are all `_N/A — [reason]_`, **skip that perspective** and announce the skip with the reason — do not audit sections that don't exist.

| # | Perspective | Reference File | Target Spec Sections | Skip when |
|---|---|---|---|---|
| 1 | Security | `references/security-review.md` | Security Considerations, Interfaces | Security Considerations is N/A **and** no external input/auth surface in Interfaces |
| 2 | Scalability | `references/scalability-review.md` | Constraints, Failure Modes, Component Responsibilities | never skipped by N/A alone — skip only if the change has no runtime behavior (e.g., docs/config rename) |
| 3 | API Design | `references/api-design-review.md` | API Contracts | API Contracts absent or N/A |
| 4 | Completeness | `references/completeness-review.md` | whole spec | never skipped |
| 5 | Scope | `references/scope-review.md` | whole spec | never skipped |

Completeness and Scope always run — they are the audits that catch wrongly-N/A'd sections.

### Lite mode dispatch (feature default) — focused

Launch **one** subagent with `model: "opus"`, receiving: the spec path, the brief path (when one exists), and the reference-checklist paths of the **focused perspective set** — not a blanket sweep:
- **Always run Completeness + Scope** — they catch wrongly-`N/A`'d sections and scope creep.
- **Add a risk perspective only when the spec's surface triggers it:** Security (external input / auth / secrets), Scalability (new runtime behavior under load), API Design (new or changed API contract).

Name the selection and why (*"running Completeness, Scope, Security — the spec adds an auth-checked endpoint"*). Instructions: apply each selected checklist, perform the Step 3 cross-perspective checks, and return findings **per perspective** as in panel mode (so the Review Notes table fills identically). Announce: *"Gate B mode: lite (feature) — [N] focused perspectives: [list]."*

Lite runs on **Opus** — Gate B is the quality moat, so its auditor keeps full reasoning depth in both modes; the lite/panel difference is *breadth* (focused set vs all 5, one auditor vs five), not model strength. The **lite → panel escalation guardrail still holds**: if the auditor finds a blocking Security or Scalability issue (or judges the spec riskier than its path), it recommends re-running the full **panel**.

### Panel mode dispatch (system changes; features on request/escalation)

Each selected perspective runs as an **independent subagent**. They do not share context or influence
each other — this is by design. Cross-perspective checks happen after all complete.

Launch all selected perspectives in parallel using the Agent tool, each with `model: "opus"` (audit judgment quality over speed — the spec is small, the stakes are the whole build). Each subagent receives:
- The full spec file path AND the brief file path (when one exists)
- Its specific perspective reference file
- Instructions to read the spec, apply its checklist, and return findings

### Subagent Prompt Template

For each perspective, launch a subagent with:

```
You are a spec auditor reviewing from the [PERSPECTIVE] perspective.

1. Read the spec file at: [SPEC_PATH]
2. Read the Approach Brief at: [BRIEF_PATH] — its "Approach Review" section lists strategic
   concerns already settled at Gate A. Do NOT re-raise those; audit the details instead.
   [Omit this line when Gate A was skipped.]
3. Read your reference checklist at: [SKILL_DIR]/references/[REFERENCE_FILE]
4. Read the codebase files referenced in the spec to verify patterns and conventions.
5. Apply every challenge question from your checklist against the spec.
6. For each question: note whether the spec addresses it, and if not, whether it's BLOCKING or a SUGGESTION.

Return your findings in this format:

### [Perspective Name]
Verdict: ✅ Approved | ❌ Blocking Issues | ⚠️ Suggestions Only

BLOCKING:
- [Issue] — [spec section] — [why it's blocking]

SUGGESTIONS:
- [Suggestion] — [spec section] — [why it improves the spec]

CODEBASE NOTES:
- [Any inconsistencies with existing codebase patterns]
```

`[SKILL_DIR]` is this skill's own directory (where this SKILL.md lives) — resolve it to an absolute path when constructing the prompt.

---

## Step 3: Collect and Cross-Check

**Lite mode:** the auditor performed these checks inline — verify its output includes a cross-perspective section; if missing, run the checks yourself on its findings.

**Panel mode:** after all launched subagents return, check for cross-perspective inconsistencies (skip pairs whose perspective was skipped):

- **Security ↔ API Design:** Do error responses from API Design leak internal info flagged by Security?
- **Scalability ↔ Completeness:** Do Failure Modes cover the scalability failure cases (timeout, pool exhaustion)?
- **Scope ↔ Completeness:** Are all in-scope requirements actually specified? Are out-of-scope items accidentally specified? Are the spec's `N/A` sections genuinely N/A?
- **API Design ↔ Interfaces:** Does the function signature in Interfaces match what the API contract implies?
- **Security ↔ Completeness:** Is Security Considerations substantive, or is it a placeholder?

Add any cross-perspective findings to the relevant perspective's output.

---

## Step 4: Produce Output

### Per-Perspective Verdict

For each perspective, output:

```
### [Perspective Name]
Verdict: ✅ Approved | ❌ Blocking Issues | ⚠️ Suggestions Only | ⏭️ Skipped — [reason]

BLOCKING:
- [Issue 1] — [specific location in spec] — [why it's blocking]

SUGGESTIONS:
- [Suggestion 1] — [specific location] — [why it improves the spec]
```

### Overall Verdict

```
Context loaded: [files/paths]

## Spec Review: [Feature Name]
Overall: ✅ Approved | ❌ Not Approved — [N] blocking issues across [perspectives]
Mode: lite (feature) | panel (system / escalated) · Perspectives run: [list] · Skipped: [list with reasons, or "none"]

### Must Fix (Blocking)
1. [Issue] — [Perspective] — [Action required]

### Suggestions (Non-blocking)
1. [Suggestion] — [Perspective]

### Cross-Perspective Notes
- [Any inconsistencies found]

### Next Step
[If approved]: Status → Approved. Builder may start (on your go).
[If blocking]: Status → Draft. Architect to revise. Re-run /spec-review after revision.
```

### Update the Spec File

Update the `## Review Notes` table in the spec:

```markdown
| Perspective  | Status              | Issues                    |
|---|---|---|
| Security     | ✅ Approved / ❌ Issues Found / ⏭️ Skipped | [summary, skip reason, or "—"] |
| Scalability  | ... | ... |
| API Design   | ... | ... |
| Completeness | ... | ... |
| Scope        | ... | ... |
```

**Verdict mapping:** a perspective returning `⚠️ Suggestions Only` counts as approved — record it in the table as `✅ Approved` with the suggestions summarized in the Issues column. Only `❌ Blocking Issues` blocks. A `⏭️ Skipped` perspective never blocks — but its skip reason must be recorded.

**Status update:**
- If no perspective has blocking issues → set `**Status:**` to `Approved`
- If any ❌ → set `**Status:**` to `Draft` (back to Architect for revision)

**Consent:** present the verdict and stop — starting the Builder is the user's call, per the gate-consent rule in `spec-format` (segment consent lets an Approved verdict flow onward; any Blocking verdict always stops; consent never substitutes for `Status: Approved`).

---

## Step 5: Iteration Protocol

When the Architect revises after blocking issues and asks for re-review:

1. Re-read the **full spec** (not just changed sections — revisions can introduce new issues)
2. Re-run only the perspectives that had blocking issues, plus cross-perspective checks
3. Check that each blocking issue from the previous round is resolved — do not close an issue unless the fix is complete
4. Update the Review Notes table with the new round's results
5. If new issues surface in unchanged sections — flag them (normal and expected)

---

## When NOT to Use This Skill

- You want a strategic/approach challenge → use `/approach-review` (on the brief, before the spec exists)
- Reviewing code (not specs) → use the Reviewer agent
- Advisory architecture questions → use `architect-methodology`
- The spec Status is already `Approved` and nothing has changed
- Reviewing a design doc that is not a formal spec (no ACs, no Interfaces)
