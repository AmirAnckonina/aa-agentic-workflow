# Changelog

All notable changes to `aa-agentic-workflow`. Format loosely follows [Keep a Changelog](https://keepachangelog.com/); versions track `plugin.json`.

## [Unreleased]

### Changed
- **Documentation restructured for external readers.** The doc set is now four files with a clear reading order: `README` (landing page — problem, approach, gates, install, worked example), `docs/GETTING-STARTED` (setup, verification, first end-to-end run, troubleshooting), `docs/WORKFLOW` (operating manual), `docs/DESIGN` (rationale). Six Mermaid diagrams added: pipeline flow, tier routing, T2 sequence, artifact status lifecycle, Task Map fan-out, and the owned-vs-rented component map.
- **`DESIGN.md` rewritten as design rationale.** The migration plan, open questions, and v1 comparisons moved out to *Project history* below; what remains is goals, principles, architecture, and the reasoning behind each decision.
- `docs/EXAMPLES.md` folded into `WORKFLOW.md` as *Worked scenarios*; run modes and troubleshooting moved from `WORKFLOW.md` to `GETTING-STARTED.md`.

### Added
- `LICENSE` — MIT. Previously declared in `README` and `plugin.json` with no license file present.

## [0.7.0] — 2026-07-26

Context slimming per Anthropic's "[The new rules of context engineering for Claude 5 generation models](https://claude.com/blog/the-new-rules-of-context-engineering-for-claude-5-generation-models)" (Thariq Shihipar, 2026-07-24). ~20% fewer words across agent/skill context with no process change: every gate, hook, tier, and artifact contract is intact.

### Changed
- **`coding-standards` rewritten around team-specific opinions** (1,190 → ~560 words): kept coverage bar, concurrency/async discipline, fail-fast, error contracts (incl. the swagger status-code rule), size defaults, library-first + NIH list, boundary DTOs, security musts, data-layer performance, logging conventions. Dropped what a Claude 5-gen model infers from the surrounding codebase: naming/readability prose, SOLID/encapsulation boilerplate, comments policy, language-idiom sections (*rules → judgment*).
- **Gate-consent semantics single-sourced in `spec-format`** ("Gate consent (canonical rule)"); `architect.md`, `architect-methodology`, `approach-review`, and `spec-review` now reference it instead of restating it (*repeat yourself → single source*).
- **`architect.md` deduplicated against its co-loaded skills**: Weight Discipline compressed to a pointer at `spec-format`'s anti-pattern table; split thresholds referenced, not restated.
- **`decomposition` no longer preloaded** by the Architect — loaded on demand at step 3.5, where it's actually used (*upfront → progressive disclosure*).
- **Old-model babysitting removed** from all three agents: "a turn with 0 tool uses is a failed turn" blocks, emoji-rendering directive, "protocol violation" framing (*rules → judgment*).
- **`MEMORY MANAGEMENT` checklists → `MEMORY SCOPE` one-liners** in all agents — auto-memory captures content; the sections now state only what's in/out of scope (*manual memory → auto-memory*).
- `architect-methodology`: worked rate-limiter example removed — the five lens definitions carry the method (*examples → interface design*).

## [0.6.0] — 2026-07-24

### Added
- **Structural Builder gates (PreToolUse hooks in `builder.md`).** The two load-bearing Builder invariants are now enforced by the harness, not by prompt adherence:
  - **spec-gate** (`Write`/`Edit`) — blocks implementation edits when the branch's matched `docs/specs` spec is not `Approved`. Fail-open at every external step; `AA_GATE_OFF=1` bypass for deliberate pre-work; `docs/` edits always allowed.
  - **git-guard** (`Bash`) — blocks `git commit`/`push`/`merge`/`rebase`/`reset`/`checkout -b`; read-only git still allowed. Builder-scoped, so the human's own commits are unaffected.
- **`.claude-plugin/marketplace.json`** — the repo is now its own marketplace (`aa`), installable in two commands locally and from GitHub.
- **Native Task Map board** — the driving session mirrors Task Map rows into the native to-do list for live tracking; the markdown map stays the durable ledger (tracks, never auto-runs).

### Changed
- **Routing collapsed to two proposed defaults** (`T2-fast` / `T3-full`) in `WORKFLOW.md`; T0/T1 and Gate-B breadth are now escalations the pipeline surfaces, not knobs the human pre-selects.
- **Install method** — proper plugin install (marketplace `aa`) replaces the whole-repo skills-dir symlink, which never registered agents/commands. Dev loop is now `claude --plugin-dir <repo>`.
- `superpowers` is declared in `plugin.json` `dependencies` (resolved from the official marketplace); the Step-0 skill check remains a safety net.
- Docs (`README`, `DESIGN`) reconciled to the above.

## [0.5.0] — 2026-07-14

### Added
- Spec-driven rebuild (Model A): in-Architect decomposition (spec-then-tasks), optional EARS `/requirements` front stage with `R#` traceability.
- Model tiering + focused Gate B (lite/panel), segment consent.

## [0.2.x] — 2026-07 (pre-release)

- Initial plugin packaging of the Architect → gates → Builder → Reviewer pipeline, ported from the `custom-agentic-tools` v1 capability.

---

# Project history

How v2 was built, kept for the record. Nothing here is required to use the plugin — start at the [README](README.md).

## Origin

v2 supersedes the `agentic-workflow` capability in `custom-agentic-tools` (v1), a bundle of symlinked skills. The rebuild had two motives: package the pipeline as a real, versioned, distributable plugin, and cut the maintenance surface by deleting everything that duplicated an upstream owner. Design approved 2026-07-13.

## Build-out (2026-07)

| Milestone | Outcome |
|---|---|
| **M1 — port governance** | Keep-column artifacts copied from v1, then rewired for delegation: Builder → `superpowers:test-driven-development`; Reviewer split into spec-compliance + delegated `/code-review`; `cto-review` renamed to `approach-review` and repositioned as Gate A; the Step-0 context contract added to every stage. |
| **M2 — package** | Manifest schema verified against live docs. `plugin.json` + `marketplace.json` (repo is its own marketplace, source `"."`); `claude plugin validate . --strict` passes; version pinned so updates ship on bumps, not commits. |
| **M3 — smoke test** | Passed 2026-07-14, 20/20 checks, in a Go sandbox. Verified the context contract at every stage, fast-track inline brief + recorded waiver, Gate B lite mode with N/A perspective skipping, Approved-gate authorization, both Superpowers delegations, the Reviewer's direct `/code-review` invocation from a subagent, and a full SHIP IT report. |
| **M4 — retire v1** | The `agentic-workflow` bundle removed from `custom-agentic-tools`, which keeps its unrelated capabilities. |

## Course corrections worth recording

- **Efficiency trims (2026-07-14).** A post-M1 heaviness review found ordinary features paying T3 ceremony. Three changes — T2 fast track as the default, Gate B lite/panel modes, and segment consent — cut an ordinary T2 from 6–7 round-trips and 5 audit subagents to 2–3 and 1, with the quality moat intact.
- **Skills-dir symlink reversed (2026-07-24).** The chosen dev-phase install — the whole repo symlinked into `~/.claude/skills/` — was found *not* to register agents or commands, since a whole-repo symlink exposes only nested skills, double-nested and undiscovered. It never actually activated the pipeline. Corrected to a real plugin install plus `claude --plugin-dir` for the live dev loop.
- **Superpowers dependency, reversed twice.** Originally a documented prerequisite checked at Step 0; then declared in the manifest `dependencies`; briefly removed as over-coupling; finally restored in v0.6.0 once cross-marketplace resolution worked, with the Step-0 check kept as a safety net.
- **Model A over Model B (v0.5.0).** An unmerged v0.4.0 draft built a gated `/decompose` front stage producing one spec per task. Research across Spec Kit, Kiro, OpenSpec, Taskmaster, and BMAD found no tool uses that model; it was rejected in favor of spec-then-tasks with decomposition inside the Architect. Rationale in [docs/DESIGN.md §6.6](docs/DESIGN.md).

## Resolved design questions

- **Can the Reviewer invoke `/code-review` from a subagent?** Yes — confirmed at the M3 smoke test. The Reviewer calls it directly via the Skill tool; the `/review-internal` command wrapper remains as a fallback that runs the quality pass from the main session and combines verdicts.
- **Approach Brief format** — adopted into `spec-format` with a `Tier:` line; Options Considered requires at least one real alternative with a real rejection reason. A brief with no alternatives is a RETHINK on arrival.
- **Standalone `build-report` skill** — dropped. Folded into the Builder's output protocol as a compact Build Report whose AC → Test map feeds Reviewer Pass 1.
- **`coding-standards` ownership** — carried into this repo verbatim; a self-contained plugin must ship what its agents preload. Future edits happen here.
- **PRD stage** — was a reserved slot, implemented in v0.5.0 as the optional `requirements-composition` front stage (`/requirements`, EARS + `R#`).
