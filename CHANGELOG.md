# Changelog

All notable changes to `aa-agentic-workflow`. Format loosely follows [Keep a Changelog](https://keepachangelog.com/); versions track `plugin.json`.

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
