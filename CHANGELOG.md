# Changelog

All notable changes to `aa-agentic-workflow`. Format loosely follows [Keep a Changelog](https://keepachangelog.com/); versions track `plugin.json`.

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
