---
name: aa-spec-review
description: >
  Use when a spec needs its detail audits before the Builder starts — "spec review",
  "detail audit", "audit the spec", "run detail audits". Gate B of the pipeline:
  up to 5 independent perspectives (Security, Scalability, API Design, Completeness,
  Scope). Runs after /aa-approach-review passes or is skipped.
user-invocable: true
---

# Spec Review (Gate B — Detail Audits)

## Overview

This skill runs **independent detail audits** against an architecture spec, through fresh-context
auditors that never inherit the Architect's reasoning. Its output is **findings, not coverage**:
a short list of things actually wrong with *this* spec — never a walkthrough of everything that's fine.

**Position in the pipeline:**
```
Architect (Brief) → /aa-approach-review (Gate A) → Architect (Spec, Draft) → /aa-spec-review (Gate B) → Builder
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

## Step 1: Orient (light — the auditors own the deep read)

The dispatching session validates and routes; it does **not** duplicate the auditors' reading.

1. Read the spec file.
2. **Check the spec's `**Brief:**` line:**
   - Links a brief → verify the brief's Status is `Approach-Approved`. If it isn't, STOP: Gate A is not done — point the user to `/aa-approach-review`.
   - `_Inline — Gate A waived: [reason]_` (or legacy `_None — Gate A skipped: [reason]_`) → proceed; the waiver is recorded. (A system-change spec without an Approach-Approved brief is itself a **blocking finding** — Gate A is mandatory for system changes.)
3. Check `**Status:**` — should be `Draft` or `Detail Audit`. Then set it to `Detail Audit` — the status field must reflect where the pipeline actually is while you work. If Status is `Approved`, ask before re-reviewing.
4. **Locate repo spec standards:** if `docs/agentic-context.md` declares a spec-standards file, or `docs/spec-standards.md` exists, read it → `SPEC_STANDARDS`. Missing → `(none)` — never an error. Begin your output with one line: `Context loaded: <spec path> · standards: <path | none>`.

Do **not** read the brief in full, the context-manifest file list, or the codebase files the spec references — that is the auditors' job, with clean eyes. Do not carry over any reasoning from the Architect's session.

---

## Step 2: Select Mode & Perspectives

### Mode selection (proportionality — announce your choice)

The feature-vs-system classification comes from the brief's `**Path:**` line; for a waived-Gate-A spec, from the Architect's recorded rigor diagnosis (ask the user if genuinely unclear).

| Mode | When | Shape |
|---|---|---|
| **Skip** | trivial/mechanical spec — no new logic branches, no external input, no contract change (record the reason) | mark all Review Notes `⏭️ Skipped`, Status → Approved directly |
| **Lite** | feature (default) | **One Opus** subagent runs the **focused** perspective set (below) in a single pass |
| **Panel** | system change (always) · a feature touching **auth/security, data migration, external API contract, or an irreversible/high-blast-radius change** · or on escalation | up to 5 independent parallel **Opus** subagents |

Both modes dispatch **fresh-context subagents** — clean eyes are non-negotiable in either mode. The user can always demand panel.

**Lite → panel escalation (quality guardrail):** if the lite auditor returns a blocking issue in Security or Scalability, or judges the spec riskier than its path suggests (new external dependency, data migration, auth surface, irreversible step), recommend running the **panel** for the re-review round.

### Perspective selection (both modes)

Map each perspective to its target spec sections. If a perspective's target sections are all `_N/A — [reason]_`, **skip that perspective** and announce the skip with the reason.

| # | Perspective | Charter File | Target Spec Sections | Skip when |
|---|---|---|---|---|
| 1 | Security | `references/security-review.md` | Security Considerations, Interfaces | Security Considerations is N/A **and** no external input, auth surface, or sensitive data in Interfaces |
| 2 | Scalability | `references/scalability-review.md` | Constraints, Failure Modes, Component Responsibilities | the change has no runtime behavior (e.g., docs/config rename) |
| 3 | API Design | `references/api-design-review.md` | API Contracts | API Contracts absent or N/A |
| 4 | Completeness | `references/completeness-review.md` | whole spec | never skipped |
| 5 | Scope | `references/scope-review.md` | whole spec | never skipped |

Completeness and Scope always run — they are the audits that catch wrongly-N/A'd sections.

### Lite mode dispatch (feature default) — focused

Launch **one** subagent with `model: "opus"` carrying the **focused perspective set**:
- **Always Completeness + Scope.**
- **Add a risk perspective only when the spec's surface triggers it:** Security (external input / auth / secrets / sensitive data), Scalability (new runtime behavior under load), API Design (new or changed API contract).

Name the selection and why (*"running Completeness, Scope, Security — the spec adds an auth-checked endpoint"*). Announce: *"Gate B mode: lite (feature) — [N] focused perspectives: [list]."*

Lite runs on **Opus** — Gate B is the quality moat; the lite/panel difference is *breadth*, not model strength.

### Panel mode dispatch (system changes; features on request/escalation)

Each selected perspective runs as an **independent subagent** — no shared context, by design. Launch all selected perspectives in parallel using the Agent tool, each with `model: "opus"`.

### Auditor Prompt Template

Both modes use this prompt (lite: one agent, all selected charters; panel: one agent per charter):

```
You are a fresh-context spec auditor. Your output is FINDINGS, NOT COVERAGE — report only
what is wrong; never walk through what you checked and found fine.

1. Read the spec at: [SPEC_PATH]
2. Read the Approach Brief at: [BRIEF_PATH] — its "Approach Review" section lists strategic
   concerns already settled at Gate A. Do NOT re-raise those. [Omit when Gate A was waived.]
3. If the spec carries a **Plan:** line, read that Feature Plan's Flow and Seam Contracts —
   a spec that contradicts a frozen seam contract is BLOCKING (the fix goes through the plan
   first, never unilaterally in the spec).
4. Read your charter(s): [CHARTER_PATHS]
5. Read the codebase files the spec references, plus the files listed in docs/agentic-context.md
   when it exists — verify the spec's contracts against the code and the repo's actual conventions.
6. The original need this spec serves: [REQUIREMENTS_PATH | the brief's Problem section |
   one-line summary from the dispatcher]. Under- and over-delivery are measured against this.

## Repo Spec Standards
[SPEC_STANDARDS verbatim, or "(none declared)"]
These standards override the charters where they conflict. A violation of a standard marked
[CRITICAL] is always BLOCKING. Standards are your ONLY license for convention-level findings —
if neither a standard nor your charter's traps cover a stylistic/conventional concern, do not raise it.

## Reporting contract
- BLOCKING requires articulated evidence — the finding must state, concretely:
  (1) the failure or wrong build it causes in THIS spec's context, and
  (2) why nothing existing (codebase, brief decision, another spec section) already covers it.
  Cannot articulate both → it is a SUGGESTION. When in doubt, downgrade. The downgrade rule
  governs disputable judgment calls — NOT unresolved safety-relevant holes: when the spec's own
  silence is the defect (new surface with unspecified auth, data-loss, or failure behavior),
  that silence IS the evidence — block on the unanswered question. A cited [CRITICAL] repo
  standard is likewise sufficient evidence on its own — as is a contradiction of a frozen
  seam contract (item 3).
- Caps: at most 8 findings total, at most 3 of them suggestions — severity-first. If you found
  more, keep the top ones and add one line: "Cap hit — N lower-value items omitted."
- Do NOT report: generic best practices this spec's surface doesn't trigger; conventions the
  codebase or its tooling already enforces; a section's absence when its N/A reason holds;
  approach/strategy concerns (Gate A territory); pre-existing issues in code this spec doesn't change.
- No praise findings. Clean perspective = verdict line + one sentence on what you checked.
- End with one line, ONLY if true: "Risk note: this spec is riskier than its path suggests —
  [new external dependency / data migration / auth surface / irreversible step]." The dispatcher
  uses it to recommend panel mode for the next round.

Return, per perspective:

### [Perspective Name]
Verdict: ✅ Approved | ❌ Blocking Issues | ⚠️ Suggestions Only

BLOCKING:
- [Issue] — [spec section] — [evidence per the contract above]

SUGGESTIONS:
- [Suggestion] — [spec section] — [why it materially improves the spec]
```

`[CHARTER_PATHS]` resolve inside this skill's own directory — use absolute paths.

---

## Step 3: Collect and Cross-Check

After auditors return: dedup the same defect reported twice (keep highest severity, merge evidence), and check the findings for contradictions between perspectives (e.g., Scope says cut a piece Completeness says specify further — resolve or surface the tension). In lite mode a single auditor makes this mostly a formality — don't manufacture cross-perspective commentary.

---

## Step 4: Produce Output

### Overall Verdict

```
Context loaded: <spec path> · standards: <path | none>

## Spec Review: [Feature Name]
Overall: ✅ Approved | ❌ Not Approved — [N] blocking issues across [perspectives]
Mode: lite (feature) | panel (system / escalated) · Perspectives run: [list] · Skipped: [list with reasons, or "none"]

### Must Fix (Blocking)
1. [Issue] — [Perspective] — [Action required]

### Suggestions (Non-blocking)
1. [Suggestion] — [Perspective]

### Next Step
[If approved]: Status → Approved. Builder may start (on your go).
[If blocking]: Status → Draft. Architect to revise. Re-run /aa-spec-review after revision.
```

Relay the per-perspective verdicts as returned. Do not pad clean perspectives with commentary.

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

**Verdict mapping:** `⚠️ Suggestions Only` counts as approved — record it as `✅ Approved` with the suggestions summarized in the Issues column. Only `❌ Blocking Issues` blocks. A `⏭️ Skipped` perspective never blocks — but its skip reason must be recorded.

**Status update:**
- If no perspective has blocking issues → set `**Status:**` to `Approved`
- If any ❌ → set `**Status:**` to `Draft` (back to Architect for revision)

**Consent:** present the verdict and stop — starting the Builder is the user's call, per the gate-consent rule in `spec-format` (segment consent lets an Approved verdict flow onward; any Blocking verdict always stops; consent never substitutes for `Status: Approved`).

---

## Step 5: Iteration Protocol

When the Architect revises after blocking issues and asks for re-review:

1. The re-review auditor reads the **full spec** (revisions can introduce new issues), but re-runs only the perspectives that had blocking issues
2. Check that each previous blocking issue is resolved — do not close an issue unless the fix is complete
3. Update the Review Notes table with the new round's results
4. New issues in unchanged sections are normal — the reporting contract still applies to them

---

## When NOT to Use This Skill

- You want a strategic/approach challenge → use `/aa-approach-review` (on the brief, before the spec exists)
- Reviewing code (not specs) → use the Reviewer agent
- Advisory architecture questions → use `aa-architect-methodology`
- The spec Status is already `Approved` and nothing has changed
- Reviewing a design doc that is not a formal spec (no ACs, no Interfaces)
